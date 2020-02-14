//
//  Tracker.swift
//  TransportCV
//
//  Created by Stanislav on 04.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import CoreLocation

final class Tracker {
    
    static let store = TrackerStore.shared
    
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
        return convertible.getTracker(updating: Tracker.store.trackers)
    }
    
    var title: String {
        if let routeTitle = route?.key.title {
            return routeTitle
        }
        return subtitle
    }
    
    var subtitle: String {
        "\(vehicle.title) \(routeProvider.shortDescription)"
    }
    
    var routeKey: RouteKey {
        return route?.key ?? (vehicle.type ?? .bus).defaultRouteKey
    }
    
}

extension Tracker: Updatable {
    
    static func == (lhs: Tracker,
                    rhs: Tracker) -> Bool {
        return lhs.vehicle == rhs.vehicle
    }
    
    func update(with new: Tracker) {
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
    
    func mayBeObsolete(with another: Tracker) -> Bool {
        return routeProvider.mayBeObsolete(with: another.routeProvider)
    }
    
}

extension Tracker: TrackerAnnotationConvertible {
    
    func getAnnotation(updating annotations: [TrackerAnnotation]?) -> TrackerAnnotation {
        if let found = annotations?.first(where: { $0.tracker == self }) {
            if !(found.tracker === self) {
                found.tracker.update(with: self)
            }
            found.update()
            return found
        }
        return TrackerAnnotation(tracker: self)
    }
    
}
