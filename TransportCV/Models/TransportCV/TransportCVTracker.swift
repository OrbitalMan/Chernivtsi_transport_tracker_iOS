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
    let routeId: Int?
    let speed: Int
    let startStatusDate: String
    let statusName: String
    
}

extension TransportCVTracker: CLLocationConvertible {
    
    var speedValue: Double {
        Double(speed)
    }
    
    var getCLLocation: CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                      longitude: longitude),
                   altitude: 0,
                   horizontalAccuracy: 0,
                   verticalAccuracy: 0,
                   course: angle,
                   speed: speedValue,
                   timestamp: Date())
    }
    
}

extension TransportCVTracker: GenericTrackerConvertible {
    
    var routeKey: RouteKey? {
        let routes = RouteStore.shared.routes
        let routePair = routes.first(where: { $0.value.transportCVRoute?.id == routeId })
        return routePair?.key
    }
    
    var genericStatus: GenericTracker.Status {
        switch statusName {
        case "move":
            return .moving
        case "stay":
            return .idle
        default:
            return .noConnection
        }
    }
    
    var asGenericTracker: GenericTracker {
        return GenericTracker(routeId: routeId ?? -1,
                              title: number + " desyde",
                              route: RouteStore.shared.findRoute(key: routeKey),
                              location: getCLLocation,
                              status: genericStatus,
                              provider: .desyde)
    }
    
}

