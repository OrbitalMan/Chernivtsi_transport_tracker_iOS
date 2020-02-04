//
//  TransGPSCVTracker.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import CoreLocation

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
    
    var vehicleType: VehicleType? {
        return VehicleType(transGPSCVIndex: idBusTypes)
    }
    
}

extension TransGPSCVTracker: GenericTrackerConvertible {
    
    var speedValue: Double { Double(speed) ?? 0 }
    
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
    
    var asGenericTracker: GenericTracker {
        let provider = Provider.transGPS(id: routeId)
        return GenericTracker(routeId: routeId,
                              title: name + " trans",
                              route: RouteStore.shared.findRoute(provider: provider),
                              location: getCLLocation,
                              provider: provider)
    }
    
}

typealias TransGPSCVTrackerContainer = [String: Safe<TransGPSCVTracker>]
