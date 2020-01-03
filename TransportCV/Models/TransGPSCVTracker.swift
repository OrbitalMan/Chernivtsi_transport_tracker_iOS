//
//  TransGPSCVTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

protocol CLLocationConvertible {
    var getCLLocation: CLLocation { get }
}

struct TransGPSCVTracker: Codable {
    
    let id: Int
    let name: String
    let lat: Double
    let lng: Double
    let speed: String
    let orientation: String
    let gpstime: String
    let routeId: Int
    let routeName: String
    let inDepo: Bool
    let busNumber: String
    let perevId: Int?
    let perevName: String
    let remark: String
    let idBusTypes: Int
    
    var busType: BusType? {
        return BusType(rawValue: idBusTypes)
    }
    
}

extension TransGPSCVTracker: GenericTrackerConvertible {
    
    var asGenericTracker: GenericTracker {
        let speedValue = Double(speed) ?? 0
        let status: GenericTracker.Status
        if inDepo {
            status = .noConnection
        } else {
            if speedValue > 0 {
                status = .moving
            } else {
                status = .idle
            }
        }
        let route: GenericRoute
        if let gotRoute = RouteStore.shared.findRoute(routeId: routeId) {
            route = gotRoute
        } else {
            route = GenericRoute(id: routeId,
                                 title: routeName,
                                 subtitle: nil,
                                 busType: busType,
                                 provider: .transGPS)
        }
        return GenericTracker(id: id,
                              title: name,
                              route: route,
                              location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat,
                                                                                      longitude: lng),
                                                   altitude: 0,
                                                   horizontalAccuracy: 0,
                                                   verticalAccuracy: 0,
                                                   course: Double(orientation) ?? 0,
                                                   speed: speedValue,
                                                   timestamp: Date()),
                              status: status,
                              provider: route.provider)
    }
    
}

typealias TransGPSCVTrackerContainer = [String: TransGPSCVTracker]
