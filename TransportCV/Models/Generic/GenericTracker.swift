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

struct GenericTracker {
    
    let routeId: Int
    let title: String
    var route: GenericRoute?
    let location: CLLocation
    let status: Status
    let provider: TrackerProvider
    
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
