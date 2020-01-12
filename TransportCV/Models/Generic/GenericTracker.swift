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
    var routeKey: RouteKey? { get }
    var asGenericTracker: GenericTracker { get }
}

class GenericTracker {
    
    let routeId: Int
    let title: String
    let provider: TrackerProvider
    dynamic var route: GenericRoute?
    dynamic var location: CLLocation
    
    init(routeId: Int,
         title: String,
         route: GenericRoute?,
         location: CLLocation,
         provider: TrackerProvider)
    {
        self.routeId = routeId
        self.title = title
        self.provider = provider
        self.route = route
        self.location = location
    }
    
    var routeKey: RouteKey? {
        let routes = RouteStore.shared.routes
        switch provider {
        case .transGPS:
            return routes.first(where: { $0.value.transGPSCVRoute?.id == routeId })?.key
        case .desyde:
            return routes.first(where: { $0.value.transportCVRoute?.id == routeId })?.key
        case .both:
            return routes.first(where: { ($0.value.transGPSCVRoute?.id ?? $0.value.transportCVRoute?.id) == routeId })?.key
        }
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
