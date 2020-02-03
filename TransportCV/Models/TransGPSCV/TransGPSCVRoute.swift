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
    let price: Int
    
    var vehicleType: VehicleType? {
        return VehicleType(transGPSCVIndex: idBusTypes)
    }
    
    var priceString: String {
        return "Price: \(price) UAH"
    }
    
}

typealias TransGPSCVRouteContainer = [String: TransGPSCVRoute]

extension TransGPSCVRoute: GenericRouteConvertible {
    
    var routeKey: RouteKey {
        let refinedName = name.components(separatedBy: "/").first ?? ""
        return RouteKey(type: vehicleType ?? .bus,
                        name: refinedName)
    }
    
    var asGenericRoute: GenericRoute {
        return GenericRoute(key: routeKey,
                            subtitle: priceString,
                            provider: .transGPS)
    }
    
}
