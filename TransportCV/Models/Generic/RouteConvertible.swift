//
//  RouteConvertible.swift
//  TransportCV
//
//  Created by Stanislav on 03.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

protocol ProviderDataSource {
    func getProvider() -> Provider
}

protocol RouteConvertible: ProviderDataSource {
    func getVehicleType() -> VehicleType
    func getRouteName() -> String
}

extension RouteConvertible {
    
    func getRouteKey() -> RouteKey {
        return RouteKey(type: getVehicleType(),
                        name: getRouteName())
    }
    
    func getRoute(updating routes: [Route]) -> Route? {
        let provider = getProvider()
        if  provider == .transGPS(id: 20) || // A
            provider == .transGPS(id: 37)    // T
        {
            return nil
        }
        let key = getRouteKey()
        if let route = routes.first(where: { $0.key == key }) {
            route.update(provider: provider)
            return route
        }
        return Route(key: key,
                     provider: provider)
    }
    
}
