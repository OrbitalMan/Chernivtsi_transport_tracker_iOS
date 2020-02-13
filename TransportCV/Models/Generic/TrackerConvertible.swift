//
//  TrackerConvertible.swift
//  TransportCV
//
//  Created by Stanislav on 04.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import CoreLocation

typealias Coordinate = CLLocationCoordinate2D

protocol CLLocationConvertible {
    func getCoordinate() -> Coordinate
    func getCourse() -> Double
    func getSpeed() -> Double
    func getTimestamp() -> Date
}

extension CLLocationConvertible {
    
    func getLocation() -> CLLocation {
        CLLocation(coordinate: getCoordinate(),
                   altitude: 0,
                   horizontalAccuracy: 0,
                   verticalAccuracy: 0,
                   course: getCourse(),
                   speed: getSpeed(),
                   timestamp: getTimestamp())
    }
    
}

protocol TrackerConvertible: ProviderDataSource, CLLocationConvertible {
    func getVehicleType() -> VehicleType?
    func getBusNumber() -> Int
}

extension TrackerConvertible {
    
    func getTracker(updating trackers: [Tracker]?) -> Tracker {
        let vehicle = Vehicle(type: getVehicleType(),
                              number: getBusNumber())
        let provider = getProvider()
        var findRoute: Route? { Route.store.findRoute(provider: provider) }
        let location = getLocation()
        if let tracker = trackers?.first(where: { $0.vehicle == vehicle }) {
            tracker.update(route: tracker.route ?? findRoute,
                           routeProvider: provider,
                           location: location)
            return tracker
        }
        return Tracker(vehicle: vehicle,
                       route: findRoute,
                       routeProvider: provider,
                       location: location)
    }
    
}

