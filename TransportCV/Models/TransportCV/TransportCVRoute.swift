//
//  TransportCVRoute.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

struct TransportCVRoute: Codable {
    let id: Int
    let name: String
}

extension TransportCVRoute: RouteConvertible {
    
    func getVehicleType() -> VehicleType {
        if name.contains(where: "TtТт".contains) {
            return .trolley
        } else {
            return .bus
        }
    }
    
    func getProvider() -> Provider {
        return .desyde(id: id)
    }
    
    func getRouteName() -> String {
        return name
    }
    
}

struct TransportCVRoutes: Codable {
    let routes: [Safe<TransportCVRoute>]
}
