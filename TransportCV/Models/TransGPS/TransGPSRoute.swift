//
//  TransGPSRoute.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

struct TransGPSRoute: Codable {
    let idBusTypes: Int
    let id: Int
    let name: String?
}

extension TransGPSRoute: RouteConvertible {
    
    func getVehicleType() -> VehicleType {
        return VehicleType(transGPSIdBusTypes: idBusTypes) ?? .bus
    }
    
    func getProvider() -> Provider {
        return .transGPS(id: id)
    }
    
    func getRouteName() -> String {
        return name?.components(separatedBy: "/").first ?? ""
    }
    
}

typealias TransGPSRouteContainer = [String: Safe<TransGPSRoute>]
