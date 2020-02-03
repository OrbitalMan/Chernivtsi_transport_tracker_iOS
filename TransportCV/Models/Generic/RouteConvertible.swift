//
//  RouteConvertible.swift
//  TransportCV
//
//  Created by Stanislav on 03.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

protocol RouteDataSource {
    func getVehicleType() -> VehicleType
    func getProvider() -> Provider
}

protocol RouteConvertible: RouteDataSource {
    func getRouteName() -> String
}

extension RouteConvertible {
    
    func getRouteKey() -> RouteKey {
        return RouteKey(type: getVehicleType(),
                        name: getRouteName())
    }
    
    func getRoute(updating routes: [Route]) -> Route {
        let key = getRouteKey()
        let provider = getProvider()
        if let route = routes.first(where: { $0.key == key }) {
            route.update(provider: provider)
            return route
        }
        return Route(key: key,
                     provider: provider)
    }
    
}
