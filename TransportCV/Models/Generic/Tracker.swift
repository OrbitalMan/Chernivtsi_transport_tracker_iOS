//
//  Tracker.swift
//  TransportCV
//
//  Created by Stanislav on 04.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import CoreLocation

final class Tracker {
    
    let busNumber: Int
    dynamic weak var route: Route?
    dynamic var routeProvider: Provider
    dynamic var location: CLLocation
    
    init(busNumber: Int,
         route: Route?,
         routeProvider: Provider,
         location: CLLocation)
    {
        self.busNumber = busNumber
        self.route = route
        self.routeProvider = routeProvider
        self.location = location
    }
    
    static func from(convertible: TrackerConvertible) -> Tracker {
        return convertible.getTracker(updating: MapViewController.shared?.trackers)
    }
    
    var subtitle: String {
        "\(busNumber) \(routeProvider)"
    }
    
}

extension Tracker: Equatable {
    
    static func == (lhs: Tracker,
                    rhs: Tracker) -> Bool {
        return lhs.busNumber == rhs.busNumber
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
