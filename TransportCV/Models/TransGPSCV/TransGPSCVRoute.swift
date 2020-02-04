//
//  TransGPSCVRoute.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

struct TransGPSCVRoute: Codable {
    
    let id: Int
    let name: String
    let idBusTypes: Int
    
}

extension TransGPSCVRoute: RouteConvertible {
    
    func getVehicleType() -> VehicleType {
        return VehicleType(transGPSCVIndex: idBusTypes) ?? .bus
    }
    
    func getProvider() -> Provider {
        return .transGPS(id: id)
    }
    
    func getRouteName() -> String {
        return name.components(separatedBy: "/").first ?? ""
    }
    
}

typealias TransGPSCVRouteContainer = [String: Safe<TransGPSCVRoute>]
