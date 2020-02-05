//
//  DesydeRoute.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

struct DesydeRoute: Codable {
    let rteId: Int?
    let id: Int
    let name: String
}

extension DesydeRoute: RouteConvertible {
    
    func getVehicleType() -> VehicleType {
        if name.contains(where: "TtТт".contains) {
            return .trolley
        }
        return VehicleType(desydeRteId: rteId) ?? .bus
    }
    
    func getProvider() -> Provider {
        return .desyde(id: id)
    }
    
    func getRouteName() -> String {
        return name
    }
    
}

struct DesydeRouteContainer: Codable {
    let routes: [Safe<DesydeRoute>]
}
