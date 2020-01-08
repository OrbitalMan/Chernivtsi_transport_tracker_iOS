//
//  RouteKey.swift
//  TransportCV
//
//  Created by Stanislav on 08.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

struct RouteKey: Hashable {
    
    let type: BusType
    let routeNumber: Int?
    let routeLetter: String?
    
    var title: String {
        if let number = routeNumber {
            var letter = routeLetter ?? ""
            if letter.count > 1 {
                letter = " \(letter)"
            }
            return "\(type.titleValue)\(number)\(letter)"
        }
        return routeLetter ?? "invalid \(type.stringValue)"
    }
    
}

extension RouteKey {
    
    init(busType: BusType, name: String) {
        let numberString = name.filter("0123456789".contains)
        let routeNumber = Int(numberString)
        
        var routeLetter: String? = nil
        if busType == .bus {
            routeLetter = name.components(separatedBy: .decimalDigits).last
        } else if routeNumber == nil {
            routeLetter = name
        }
        routeLetter = routeLetter?.trimmingCharacters(in: .whitespacesAndNewlines)
        routeLetter = routeLetter?.applyingTransform(.latinToCyrillic, reverse: false)
        routeLetter = routeLetter?.capitalized
        
        self.init(type: busType,
                  routeNumber: routeNumber,
                  routeLetter: routeLetter)
    }
    
}

enum BusType: Int {
    case bus = 1
    case trolley = 2
    
    var stringValue: String {
        return "\(self)"
    }
    
    var titleValue: String {
        switch self {
        case .bus: return ""
        case .trolley: return "Т"
        }
    }
    
}

