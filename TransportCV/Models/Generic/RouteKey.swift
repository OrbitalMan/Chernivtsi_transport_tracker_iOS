//
//  RouteKey.swift
//  TransportCV
//
//  Created by Stanislav on 08.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

struct RouteKey: Hashable, Codable {
    
    let type: VehicleType
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
        return routeLetter ?? "invalid \(type.emojiValue)"
    }
    
}

extension RouteKey {
    
    init(type: VehicleType, name: String) {
        let numberString = name.filter("0123456789".contains)
        let routeNumber = Int(numberString)
        
        var routeLetter: String? = nil
        if  type == .bus,
            let letter = name.components(separatedBy: .decimalDigits).last,
            !letter.isEmpty
        {
            routeLetter = letter
        } else if routeNumber == nil {
            routeLetter = name
        }
        routeLetter = routeLetter?.trimmingCharacters(in: .whitespacesAndNewlines)
        routeLetter = routeLetter?.applyingTransform(.latinToCyrillic, reverse: false)
        routeLetter = routeLetter?.capitalized
        
        self.init(type: type,
                  routeNumber: routeNumber,
                  routeLetter: routeLetter)
    }
    
}

extension RouteKey: Comparable {
    
    static func < (lhs: RouteKey, rhs: RouteKey) -> Bool {
        return lhs.compare(with: rhs)
    }
    
    func compare(with another: RouteKey) -> Bool {
        switch (self.routeNumber, another.routeNumber) {
        case let (leftNumber?, rightNumber?):
            if leftNumber == rightNumber {
                return compareLetters(with: another)
            }
            return leftNumber < rightNumber
        case (nil, .some):
            return false
        case (.some, nil):
            return true
        case (nil, nil):
            return compareLetters(with: another)
        }
    }
    
    private func compareLetters(with another: RouteKey) -> Bool {
        switch (self.routeLetter, another.routeLetter) {
        case let (leftLetter?, rightLetter?):
            if leftLetter.count == 1, rightLetter.count > 1 {
                return false
            }
            if rightLetter.count == 1, leftLetter.count > 1 {
                return true
            }
            return leftLetter < rightLetter
        case (.some, nil):
            return false
        default:
            return true
        }
    }
    
}
