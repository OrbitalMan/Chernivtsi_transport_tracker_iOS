//
//  Vehicle.swift
//  TransportCV
//
//  Created by Stanislav on 05.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

struct Vehicle: Codable {
    
    let type: VehicleType?
    let number: Int
    
    var title: String {
        return "\(type?.titleValue.lowercased() ?? "?")#\(number)"
    }
    
}

extension Vehicle: Equatable {
    
    static func == (lhs: Vehicle,
                    rhs: Vehicle) -> Bool {
        if lhs.number == rhs.number {
            switch (lhs.type, rhs.type) {
            case let (lhsType?, rhsType?):
                return lhsType == rhsType
            default:
                return true
            }
        }
        return false
    }
    
}
