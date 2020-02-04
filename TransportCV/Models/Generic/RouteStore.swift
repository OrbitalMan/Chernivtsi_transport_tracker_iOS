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
    
    private(set) var getRouteTasks = 0
    
    private(set) var routes: [Route] = [] {
        didSet {
            if routes.isEmpty { return }
            guard let mapVC = MapViewController.shared else {
                print("failed to get map VC")
                return
            }
            for tracker in mapVC.trackers {
                if tracker.route == nil {
                    if let gotRoute = findRoute(provider: tracker.routeProvider) {
                        tracker.route = gotRoute
                    }
                }
            }
            mapVC.updateVisibleTrackers()
        }
    }
    
    func findRoute(provider: Provider) -> Route? {
        return routes.first { $0.provider.hasIntersection(with: provider) }
    }
    
    func updateRoutes() {
        if getRouteTasks > 0 { return }
        routes = []
        
        getRouteTasks += 1
        TransGPSCVAPI.getRoutes { [weak self] transGPSResult in
            self?.getRouteTasks -= 1
            switch transGPSResult {
            case let .success(transGPSRoutes):
                print("trans-gps routes:", transGPSRoutes.count)
                self?.insert(convertibles: transGPSRoutes)
            case let .failure(error):
                print("trans-gps routes error:", error)
            }
        }
        
        getRouteTasks += 1
        TransportCVAPI.getRoutes { [weak self] transportRoutesResult in
            self?.getRouteTasks -= 1
            switch transportRoutesResult {
            case let .success(transportRoutes):
                print("transport routes:", transportRoutes.count)
                self?.insert(convertibles: transportRoutes)
            case let .failure(error):
                print("transport routes error:", error)
            }
        }
    }
    
    private func insert(convertibles: [RouteConvertible]) {
        var newRoutes = convertibles.map(Route.from)
        newRoutes.removeAll(where: routes.contains)
        routes.append(contentsOf: newRoutes)
    }
    
}
