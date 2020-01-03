//
//  GenericTracker.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

protocol GenericTrackerConvertible {
    var asGenericTracker: GenericTracker { get }
}

protocol GenericRouteConvertible {
    var asGenericRoute: GenericRoute { get }
}

struct GenericTracker {
    
    let id: Int
    let title: String
    var route: GenericRoute
    let location: CLLocation
    let status: Status
    let provider: TrackerProvider
    
    enum Status {
        case idle
        case moving
        case noConnection
    }
    
}

struct GenericRoute {
    let id: Int
    var title: String
    let subtitle: String?
    let busType: BusType?
    let provider: TrackerProvider
}

enum TrackerProvider {
    case desyde
    case transGPS
    case both
}

enum BusType: Int {
    case bus = 1
    case trolley = 2
    
    var stringValue: String {
        return "\(self)"
    }
    
    var titleValue: String {
        switch self {
        case .bus: return ""
        case .trolley: return "Т "
        }
    }
    
}


struct RouteKey: Hashable {
    
    let type: BusType
    let routeNumber: Int?
    let routeLetter: String?
    
    var title: String {
        if let number = routeNumber {
            var letter = routeLetter ?? ""
            if letter.count > 1 {
                letter = " \(letter)"
            }
            return "\(type.titleValue)\(number)\(letter)"
        }
        return routeLetter ?? "invalid \(type.stringValue)"
    }
    
}

class RouteStore {
    
    var routes: [RouteKey: RouteData] = [:] {
        didSet {
            guard let mapVC = MapViewController.shared else { return }
            var updatedTrackers: [GenericTracker] = []
            for tracker in mapVC.trackers {
                var newTracker = tracker
                if let gotRoute = findRoute(routeId: tracker.route.id) {
                    newTracker.route = gotRoute
                }
                updatedTrackers.append(newTracker)
            }
            mapVC.trackers = updatedTrackers
        }
    }
    
    var routeIdMap: [Int: RouteKey] = [:]
    
    static let shared = RouteStore()
    
    private init() { }
    
    func findRoute(routeId: Int) -> GenericRoute? {
        guard let route = routes.first(where: { $0.key == routeIdMap[routeId] }) else { return nil }
        return route.value.genericData(routeKey: route.key)
    }
    
    func insert(transportCVData: TransportCVRoute) {
        let busType: BusType
        if transportCVData.name.localizedCaseInsensitiveContains("Т") {
            busType = .trolley
        } else {
            busType = .bus
        }
        let routeKey = getRouteKey(busType: busType, name: transportCVData.name)
        
        if let routeData = routes[routeKey] {
            routeData.transportCVData = transportCVData
        } else {
            let newRouteData = RouteData()
            newRouteData.transportCVData = transportCVData
            routes[routeKey] = newRouteData
        }
        routeIdMap[transportCVData.id] = routeKey
    }
    
    func insert(transGPSCVData: TransGPSCVRoute) {
        let busType = transGPSCVData.busType ?? .bus
        let refinedName = transGPSCVData.name.components(separatedBy: "/").first ?? ""
        let routeKey = getRouteKey(busType: busType, name: refinedName)
        
        if let routeData = routes[routeKey] {
            routeData.transGPSCVData = transGPSCVData
        } else {
            let newRouteData = RouteData()
            newRouteData.transGPSCVData = transGPSCVData
            routes[routeKey] = newRouteData
        }
        routeIdMap[transGPSCVData.id] = routeKey
    }
    
    private func getRouteKey(busType: BusType, name: String) -> RouteKey {
        let numberString = name.filter("0123456789".contains)
        let routeNumber = Int(numberString)
        
        var routeLetter: String? = nil
        if busType == .bus {
            routeLetter = name.components(separatedBy: .decimalDigits).last
        } else if routeNumber == nil {
            routeLetter = name
        }
        routeLetter = routeLetter?.trimmingCharacters(in: .whitespacesAndNewlines)
        routeLetter = routeLetter?.applyingTransform(.latinToCyrillic, reverse: false)
        routeLetter = routeLetter?.capitalized
        
        return RouteKey(type: busType,
                        routeNumber: routeNumber,
                        routeLetter: routeLetter)
    }
    
}

class RouteData {
    
    var transportCVData: TransportCVRoute?
    var transGPSCVData: TransGPSCVRoute?
    
    func genericData(routeKey: RouteKey) -> GenericRoute? {
        if let transportCVData = transportCVData {
            if let transGPSCVData = transGPSCVData {
                return merge(routeKey: routeKey,
                             transportCVData: transportCVData,
                             transGPSCVData: transGPSCVData)
            }
            var route = transportCVData.asGenericRoute
            route.title = routeKey.title
            return route
        }
        if let transGPSCVData = transGPSCVData {
            if let transportCVData = transportCVData {
                return merge(routeKey: routeKey,
                             transportCVData: transportCVData,
                             transGPSCVData: transGPSCVData)
            }
            var route = transGPSCVData.asGenericRoute
            route.title = routeKey.title
            return route
        }
        return nil
    }
    
    private func merge(routeKey: RouteKey,
                       transportCVData: TransportCVRoute,
                       transGPSCVData: TransGPSCVRoute) -> GenericRoute {
        return GenericRoute(id: transGPSCVData.id * transportCVData.id,
                            title: routeKey.title,
                            subtitle: transportCVData.description ?? transGPSCVData.priceString,
                            busType: transGPSCVData.busType,
                            provider: .both)
    }
    
}



