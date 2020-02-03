//
//  Route.swift
//  TransportCV
//
//  Created by Stanislav on 03.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

final class Route {
    
    let key: RouteKey
    var provider: Provider
    
    init(key: RouteKey, provider: Provider) {
        self.key = key
        self.provider = provider
    }
    
    static func from(convertible: RouteConvertible) -> Route {
        return convertible.getRoute(updating: RouteStore.shared.routes)
    }
    
}

extension Route: Equatable {
    
    static func == (lhs: Route,
                    rhs: Route) -> Bool {
        return lhs.key == rhs.key
    }
    
    func update(provider: Provider) {
        self.provider = self.provider.updated(with: provider)
    }
    
    func update(with new: Route?) {
        guard let new = new else { return }
        update(provider: new.provider)
    }
    
}
