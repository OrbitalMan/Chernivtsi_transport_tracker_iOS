//
//  Provider.swift
//  TransportCV
//
//  Created by Stanislav on 03.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

enum Provider: Equatable {
    case desyde(id: Int)
    case transGPS(id: Int)
    case both(desydeId: Int, transGPSId: Int)
    
    func updated(with another: Provider) -> Provider {
        switch (self, another) {
        case (.desyde(let desydeId), .transGPS(let transGPSId)),
             (.transGPS(let transGPSId), .desyde(let desydeId)):
            return .both(desydeId: desydeId, transGPSId: transGPSId)
        case (.both(_, let transGPSId), .desyde(let desydeId)),
             (.both(let desydeId, _), .transGPS(let transGPSId)):
            return .both(desydeId: desydeId, transGPSId: transGPSId)
        default:
            return another
        }
    }
    
    func contains(another: Provider) -> Bool {
        if self == another {
            return true
        }
        switch (self, another) {
        case (let .both(desydeId, _), let .desyde(anotherDesydeId)):
            return desydeId == anotherDesydeId
        case (let .both(_, transGPSId), let .transGPS(anotherTransGPSId)):
            return transGPSId == anotherTransGPSId
        case (let .desyde(desydeId), let .both(anotherDesydeId, anotherTransGPSId)):
            if anotherTransGPSId < 0 {
                return desydeId == anotherDesydeId
            }
            return false
        case (let .transGPS(transGPSId), let .both(anotherDesydeId, anotherTransGPSId)):
            if anotherDesydeId < 0 {
                return transGPSId == anotherTransGPSId
            }
            return false
        case (let .both(desydeId, transGPSId), let .both(anotherDesydeId, anotherTransGPSId)):
            if anotherDesydeId < 0 {
                return transGPSId == anotherTransGPSId
            }
            if anotherTransGPSId < 0 {
                return desydeId == anotherDesydeId
            }
            return false
        default: return false
        }
    }
    
    func mayBeObsolete(with another: Provider) -> Bool {
        switch (self, another) {
        case (.desyde, .desyde),
             (.transGPS, .transGPS): return true
        default: return false
        }
    }
    
}
