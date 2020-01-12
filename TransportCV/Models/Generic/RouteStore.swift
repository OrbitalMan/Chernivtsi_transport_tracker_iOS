//
//  RouteStore.swift
//  TransportCV
//
//  Created by Stanislav on 08.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

class RouteStore {
    
    static let shared = RouteStore()
    private init() { }
    
    private(set) var updatingTasks = 0
    
    var routes: [RouteKey: RouteData] = [:] {
        didSet {
            if routes.isEmpty { return }
            guard let mapVC = MapViewController.shared else {
                print("failed to get map VC")
                return
            }
            for tracker in mapVC.trackers {
                if let gotRoute = RouteStore.shared.findRoute(key: tracker.routeKey) {
                    tracker.route = gotRoute
                } else {
                    if let route = tracker.route {
                        print("tracker \(tracker.title) already has route for id \(tracker.routeId): \(route.key.title)")
                    } else {
                        print("failed to find route \(tracker.routeId) for \(tracker.title) tracker")
                    }
                }
            }
        }
    }
    
    func updateRoutes() {
        if updatingTasks > 0 { return }
        
        routes = [:]
        
        updatingTasks += 1
        TransGPSCVAPI.getRoutes { [weak self] transGPSResult in
            self?.updatingTasks -= 1
            switch transGPSResult {
            case let .success(transGPSRoutes):
                print("trans-gps routes:", transGPSRoutes.count)
                self?.insert(transGPSCVData: transGPSRoutes)
            case let .failure(error):
                print("trans-gps routes error:", error)
            }
        }
        
        updatingTasks += 1
        TransportCVAPI.getRoutes { [weak self] transportRoutesResult in
            self?.updatingTasks -= 1
            switch transportRoutesResult {
            case let .success(transportRoutes):
                print("transport routes:", transportRoutes.count)
                self?.insert(transportCVData: transportRoutes)
            case let .failure(error):
                print("transport routes error:", error)
            }
        }
    }
    
    func findRoute(key: RouteKey?) -> GenericRoute? {
        guard let routeKey = key else {
            return nil }
        guard let route = routes[routeKey] else {
            return nil }
        return route.genericData(routeKey: routeKey)
    }
    
    private func insert(transportCVData: [TransportCVRoute]) {
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
    
    private func insert(transGPSCVData: [TransGPSCVRoute]) {
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
