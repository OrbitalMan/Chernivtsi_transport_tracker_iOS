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
    let speed: Double
    let startStatusDate: String
    
}

extension TransportCVTracker: GenericTrackerConvertible {
    
    var speedValue: Double { speed }
    
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
    
    var asGenericTracker: GenericTracker {
        let provider = Provider.desyde(id: routeId ?? -1)
        return GenericTracker(routeId: routeId ?? -1,
                              title: number + " desyde",
                              route: RouteStore.shared.findRoute(provider: provider),
                              location: getCLLocation,
                              provider: provider)
    }
    
}

