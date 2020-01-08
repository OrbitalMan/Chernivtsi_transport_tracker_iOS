//
//  GenericRoute.swift
//  TransportCV
//
//  Created by Stanislav on 08.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

protocol GenericRouteConvertible {
    var routeKey: RouteKey { get }
    var asGenericRoute: GenericRoute { get }
}

struct GenericRoute {
    let key: RouteKey
    let subtitle: String?
    let provider: TrackerProvider
}

enum TrackerProvider {
    case desyde
    case transGPS
    case both
}

