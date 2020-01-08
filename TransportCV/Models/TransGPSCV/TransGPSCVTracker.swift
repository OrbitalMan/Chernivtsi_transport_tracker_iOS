//
//  TransGPSCVTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

protocol CLLocationConvertible {
    var speedValue: Double { get }
    var getCLLocation: CLLocation { get }
}

struct TransGPSCVTracker: Codable {
    
    let id: Int
    let name: String
    var lat: Double
    var lng: Double
    var speed: String
    var orientation: String
    var gpstime: String
    let routeId: Int
    let routeName: String
    var inDepo: Bool
    let busNumber: String
    let perevId: Int?
    let perevName: String
    let remark: String
    let idBusTypes: Int
    
    var busType: BusType? {
        return BusType(rawValue: idBusTypes)
    }
    
}

extension TransGPSCVTracker: CLLocationConvertible {
    
    var speedValue: Double {
        Double(speed) ?? 0
    }
    
    var getCLLocation: CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat,
                                                      longitude: lng),
                   altitude: 0,
                   horizontalAccuracy: 0,
                   verticalAccuracy: 0,
                   course: Double(orientation) ?? 0,
                   speed: speedValue,
                   timestamp: Date())
    }
    
}

extension TransGPSCVTracker: GenericTrackerConvertible {
    
    var routeKey: RouteKey? {
        let routes = RouteStore.shared.routes
        return routes.first(where: { $0.value.transGPSCVRoute?.id == routeId })?.key
    }
    
    var genericStatus: GenericTracker.Status {
        if inDepo {
            return .noConnection
        }
        if speedValue > 0 {
            return .moving
        }
        return .idle
    }
    
    var asGenericTracker: GenericTracker {
        return GenericTracker(routeId: routeId,
                              title: name + " trans",
                              route: RouteStore.shared.findRoute(key: routeKey),
                              location: getCLLocation,
                              status: genericStatus,
                              provider: .transGPS)
    }
    
}

typealias TransGPSCVTrackerContainer = [String: TransGPSCVTracker]
