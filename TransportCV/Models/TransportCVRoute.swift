//
//  TransportCVRoute.swift
//  TransportCV
//
//  Created by Stanislav on 30.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

struct TransportCVRoute: Codable {
    
    let description: String?
    let id: Int
    let lineColor: String
    let maxDuration: Int?
    let name: String
    
}

struct TransportCVRoutes: Codable {
    
    let routes: [TransportCVRoute]
    
}

extension TransportCVRoute: GenericRouteConvertible {
    
    var asGenericRoute: GenericRoute {
        let busType: BusType
        if name.localizedCaseInsensitiveContains("T") {
            busType = .trolley
        } else {
            busType = .bus
        }
        
        return GenericRoute(id: id,
                            title: name,
                            subtitle: description,
                            busType: busType,
                            provider: .desyde)
    }
    
}
