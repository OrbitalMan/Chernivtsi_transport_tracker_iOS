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
    
}

extension VehicleType {
    
    init?(transGPSCVIndex: Int) {
        switch transGPSCVIndex {
        case 2:
            self = .trolley
        case 1:
            self = .bus
        default:
            return nil
        }
    }
    
    var transGPSCVIndex: Int {
        switch self {
        case .trolley: return 2
        case .bus: return 1
        }
    }
    
}
