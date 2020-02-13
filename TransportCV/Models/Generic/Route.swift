//
//  Route.swift
//  TransportCV
//
//  Created by Stanislav on 03.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

final class Route {
    
    static let store = RouteStore.shared
    
    let key: RouteKey
    var provider: Provider
    
    init(key: RouteKey, provider: Provider) {
        self.key = key
        self.provider = provider
    }
    
    static func from(convertible: RouteConvertible) -> Route? {
        return convertible.getRoute(updating: store.routes)
    }
    
}

extension Route: Updatable {
    
    static func == (lhs: Route,
                    rhs: Route) -> Bool {
        return lhs.key == rhs.key
    }
    
    func update(with new: Route) {
        update(provider: new.provider)
    }
    
    func mayBeObsolete(with another: Route) -> Bool {
        return provider.mayBeObsolete(with: another.provider)
    }
    
    func update(provider: Provider) {
        self.provider = self.provider.updated(with: provider)
    }
    
}
