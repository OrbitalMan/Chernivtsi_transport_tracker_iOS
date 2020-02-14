//
//  VehicleType.swift
//  TransportCV
//
//  Created by Stanislav on 03.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

enum VehicleType: Int, CaseIterable, Codable {
    case trolley = 0
    case bus = 1
    
    var titleValue: String {
        switch self {
        case .trolley: return "Т"
        case .bus: return ""
        }
    }
    
    var emojiValue: String {
        switch self {
        case .trolley: return "🚎"
        case .bus: return "🚌"
        }
    }
    
    var segmentedControlTitle: String {
        switch self {
        case .trolley: return "Trolleys"
        case .bus: return "Buses"
        }
    }
    
    var defaultRouteKey: RouteKey {
        return RouteKey(type: self,
                        routeNumber: nil,
                        routeLetter: nil)
    }
    
}

extension VehicleType {
    
    init?(transGPSIdBusTypes: Int?) {
        switch transGPSIdBusTypes {
        case 2:
            self = .trolley
        case 1:
            self = .bus
        default:
            return nil
        }
    }
    
    init?(desydeTteId: Int?) {
        switch desydeTteId {
        case 141, 242:
            self = .trolley
        case 1, 2, 41, 81:
            self = .bus
        default:
            return nil
        }
    }
    
    init?(desydeRteId: Int?) {
        switch desydeRteId {
        case 1:
            self = .trolley
        case 4:
            self = .bus
        default:
            return nil
        }
    }
    
}
