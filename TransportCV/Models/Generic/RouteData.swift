//
//  RouteData.swift
//  TransportCV
//
//  Created by Stanislav on 10.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

class RouteData {
    
    var transportCVRoute: TransportCVRoute?
    var transGPSCVRoute: TransGPSCVRoute?
    var transportCVTrackers: [TransportCVTracker] = []
    var transGPSCVTrackers: [TransGPSCVTracker] = []
    
    func genericData(routeKey: RouteKey) -> GenericRoute? {
        switch (transportCVRoute, transGPSCVRoute) {
        case let (transportCVRoute?, transGPSCVRoute?):
            return merge(routeKey: routeKey,
                         transportCVData: transportCVRoute,
                         transGPSCVData: transGPSCVRoute)
        case let (transportCVRoute?, nil):
            return transportCVRoute.asGenericRoute
        case let (nil, transGPSCVRoute?):
            return transGPSCVRoute.asGenericRoute
        case (nil, nil):
            return nil
        }
    }
    
    private func merge(routeKey: RouteKey,
                       transportCVData: TransportCVRoute,
                       transGPSCVData: TransGPSCVRoute) -> GenericRoute {
        return GenericRoute(key: routeKey,
                            subtitle: transportCVData.description ?? transGPSCVData.priceString,
                            provider: .both)
    }
    
}
