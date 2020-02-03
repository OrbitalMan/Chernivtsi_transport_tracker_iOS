//
//  GenericTracker.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

protocol CLLocationConvertible {
    var speedValue: Double { get }
    var getCLLocation: CLLocation { get }
}

protocol GenericTrackerConvertible: CLLocationConvertible {
    var asGenericTracker: GenericTracker { get }
}

class GenericTracker {
    
    let routeId: Int
    let title: String
    let provider: Provider
    dynamic var route: Route?
    dynamic var location: CLLocation
    
    init(routeId: Int,
         title: String,
         route: Route?,
         location: CLLocation,
         provider: Provider)
    {
        self.routeId = routeId
        self.title = title
        self.provider = provider
        self.route = route
        self.location = location
    }
    
}

extension GenericTracker: Equatable {
    
    static func == (lhs: GenericTracker,
                    rhs: GenericTracker) -> Bool {
        guard
            lhs.routeId == rhs.routeId,
            lhs.title == rhs.title,
            lhs.provider == rhs.provider else { return false }
        return true
    }
    
}
