//
//  RouteStore.swift
//  TransportCV
//
//  Created by Stanislav on 08.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

class RouteStore {
    
    var routes: [RouteKey: RouteData] = [:] {
        didSet {
            guard let mapVC = MapViewController.shared else { return }
            var updatedTrackers: [GenericTracker] = []
            for tracker in mapVC.trackers {
                var newTracker = tracker
                if let gotRoute = RouteStore.shared.findRoute(key: tracker.routeKey) {
                    newTracker.route = gotRoute
                } else {
                    if tracker.route == nil {
                        print("failed to find route for \(tracker.routeId) \(tracker.title)!")
                    }
                }
                updatedTrackers.append(newTracker)
            }
            mapVC.trackers = updatedTrackers
        }
    }
    
    static let shared = RouteStore()
    
    private init() { }
    
    func findRoute(key: RouteKey?) -> GenericRoute? {
        guard let routeKey = key else {
            return nil }
        guard let route = routes[routeKey] else {
            return nil }
        return route.genericData(routeKey: routeKey)
    }
    
    func insert(transportCVData: [TransportCVRoute]) {
        var newRoutes: [RouteKey: RouteData] = [:]
        for transportRoute in transportCVData {
            let routeKey = transportRoute.routeKey
            if let routeData = newRoutes[routeKey] {
                routeData.transportCVRoute = transportRoute
            } else {
                let newRouteData = RouteData()
                newRouteData.transportCVRoute = transportRoute
                newRoutes[routeKey] = newRouteData
            }
        }
        routes.merge(newRoutes) {
            let r = RouteData()
            r.transportCVRoute = $1.transportCVRoute ?? $0.transportCVRoute
            r.transGPSCVRoute = $0.transGPSCVRoute
            return r
        }
    }
    
    func insert(transGPSCVData: [TransGPSCVRoute]) {
        var newRoutes: [RouteKey: RouteData] = [:]
        for transGPSRoute in transGPSCVData {
            let routeKey = transGPSRoute.routeKey
            if let routeData = newRoutes[routeKey] {
                routeData.transGPSCVRoute = transGPSRoute
            } else {
                let newRouteData = RouteData()
                newRouteData.transGPSCVRoute = transGPSRoute
                newRoutes[routeKey] = newRouteData
            }
        }
        routes.merge(newRoutes) {
            let r = RouteData()
            r.transportCVRoute = $0.transportCVRoute
            r.transGPSCVRoute = $1.transGPSCVRoute ?? $0.transGPSCVRoute
            return r
        }
    }
    
}

class RouteData {
    
    var transportCVRoute: TransportCVRoute?
    var transGPSCVRoute: TransGPSCVRoute?
    var transportCVTrackers: [TransportCVTracker] = []
    var transGPSCVTrackers: [TransGPSCVTracker] = []
    
    func genericData(routeKey: RouteKey) -> GenericRoute? {
        switch (transportCVRoute, transGPSCVRoute) {
        case let (transportCVRoute?, transGPSCVRoute?):
            return merge(routeKey: routeKey,
                         transportCVData: transportCVRoute,
                         transGPSCVData: transGPSCVRoute)
        case let (transportCVRoute?, nil):
            return transportCVRoute.asGenericRoute
        case let (nil, transGPSCVRoute?):
            return transGPSCVRoute.asGenericRoute
        case (nil, nil):
            return nil
        }
    }
    
    private func merge(routeKey: RouteKey,
                       transportCVData: TransportCVRoute,
                       transGPSCVData: TransGPSCVRoute) -> GenericRoute {
        return GenericRoute(key: routeKey,
                            subtitle: transportCVData.description ?? transGPSCVData.priceString,
                            provider: .both)
    }
    
}
