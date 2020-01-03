//
//  TransportCVTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

struct TransportCVTracker: Codable {
    
    let angle: Double
    let datetime: String
    let duration: String
    let id: Int
    let latitude: Double
    let longitude: Double
    let number: String
    let routeId: Int
    let speed: Int
    let startStatusDate: String
    let statusName: String
    
}

extension TransportCVTracker: GenericTrackerConvertible {
    
    var asGenericTracker: GenericTracker {
        let status: GenericTracker.Status
        switch statusName {
        case "move":
            status = .moving
        case "stay":
            status = .idle
        default:
            status = .noConnection
        }
        
        let route: GenericRoute
        
        if let gotRoute = RouteStore.shared.findRoute(routeId: routeId) {
            route = gotRoute
        } else {
            route = GenericRoute(id: routeId,
                                 title: "\(routeId)",
                                 subtitle: nil,
                                 busType: nil,
                                 provider: .desyde)
        }
        
        return GenericTracker(id: id,
                              title: number,
                              route: route,
                              location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                                      longitude: longitude),
                                                   altitude: 0,
                                                   horizontalAccuracy: 0,
                                                   verticalAccuracy: 0,
                                                   course: angle,
                                                   speed: Double(speed),
                                                   timestamp: Date()),
                              status: status,
                              provider: route.provider)
    }
    
}

