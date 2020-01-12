//
//  GenericTracker.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

protocol GenericTrackerConvertible {
    var routeKey: RouteKey? { get }
    var genericStatus: GenericTracker.Status { get }
    var asGenericTracker: GenericTracker { get }
}

class GenericTracker {
    
    let routeId: Int
    let title: String
    let status: Status
    let provider: TrackerProvider
    dynamic var route: GenericRoute?
    dynamic var location: CLLocation
    
    init(routeId: Int,
         title: String,
         route: GenericRoute?,
         location: CLLocation,
         status: GenericTracker.Status,
         provider: TrackerProvider)
    {
        self.routeId = routeId
        self.title = title
        self.status = status
        self.provider = provider
        self.route = route
        self.location = location
    }
    
    enum Status {
        case idle
        case moving
        case noConnection
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
        return lhs.title == rhs.title
    }
    
}
