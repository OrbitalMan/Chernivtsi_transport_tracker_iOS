//
//  TransportCVRoute.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

struct TransportCVRoute: Codable {
    
    let description: String?
    let id: Int
    let lineColor: String
    let maxDuration: Int?
    let name: String
    
}

struct TransportCVRoutes: Codable {
    
    let routes: SafeCodableArray<TransportCVRoute>
    
}

extension TransportCVRoute: GenericRouteConvertible {
    
    var routeKey: RouteKey {
        let vehicleType: VehicleType
        if name.contains(where: "TtТт".contains) {
            vehicleType = .trolley
        } else {
            vehicleType = .bus
        }
        return RouteKey(type: vehicleType,
                        name: name)
    }
    
    var asGenericRoute: GenericRoute {
        return GenericRoute(key: routeKey,
                            subtitle: description,
                            provider: .desyde)
    }
    
}
