//
//  Tracker.swift
//  TransportCV
//
//  Created by Stanislav on 04.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import CoreLocation

final class Tracker {
    
    let vehicle: Vehicle
    dynamic weak var route: Route?
    dynamic var routeProvider: Provider
    dynamic var location: CLLocation
    
    init(vehicle: Vehicle,
         route: Route?,
         routeProvider: Provider,
         location: CLLocation)
    {
        self.vehicle = vehicle
        self.route = route
        self.routeProvider = routeProvider
        self.location = location
    }
    
    static func from(convertible: TrackerConvertible) -> Tracker {
        return convertible.getTracker(updating: MapViewController.shared?.trackers)
    }
    
    var subtitle: String {
        "\(vehicle.title) \(routeProvider.shortDescription)"
    }
    
}

extension Tracker: Equatable {
    
    static func == (lhs: Tracker,
                    rhs: Tracker) -> Bool {
        return lhs.vehicle == rhs.vehicle
    }
    
    func update(with new: Tracker?) {
        guard let new = new else { return }
        update(route: new.route,
               routeProvider: new.routeProvider,
               location: new.location)
    }
    
    func update(route: Route?,
                routeProvider: Provider,
                location: CLLocation) {
        if self.route != route {
            if let route = self.route {
                route.update(with: route)
            } else {
                self.route = route
            }
        }
        self.routeProvider = self.routeProvider.updated(with: routeProvider)
        if location.timestamp > self.location.timestamp  {
            self.location = location
        }
    }
    
}
