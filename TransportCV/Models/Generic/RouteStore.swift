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
            let trackers = Tracker.store.trackers
            if trackers.isEmpty { return }
            for tracker in trackers {
                if tracker.route == nil {
                    if let gotRoute = findRoute(provider: tracker.routeProvider) {
                        tracker.route = gotRoute
                    }
                }
            }
            MapViewController.shared?.updateVisibleTrackers()
        }
    }
    
    func findRoute(provider: Provider) -> Route? {
        return routes.first { $0.provider.hasIntersection(with: provider) }
    }
    
    func updateRoutes() {
        if getRouteTasks > 0 { return }
        
        getRouteTasks += 1
        TransGPSAPI.getRoutes { [weak self] transGPSResult in
            self?.getRouteTasks -= 1
            switch transGPSResult {
            case let .success(transGPSRoutes):
                print("trans-gps routes:", transGPSRoutes.count)
                self?.updateRoutes(with: transGPSRoutes)
            case let .failure(error):
                print("trans-gps routes error:", error)
            }
        }
        
        getRouteTasks += 1
        DesydeAPI.getRoutes { [weak self] desydeRoutesResult in
            self?.getRouteTasks -= 1
            switch desydeRoutesResult {
            case let .success(desydeRoutes):
                print("desyde routes:", desydeRoutes.count)
                self?.updateRoutes(with: desydeRoutes)
            case let .failure(error):
                print("desyde routes error:", error)
            }
        }
    }
    
    private func updateRoutes(with convertibles: [RouteConvertible]) {
        let newRoutes = convertibles.compactMap(Route.from)
        routes.update(newElements: newRoutes)
    }
    
}
