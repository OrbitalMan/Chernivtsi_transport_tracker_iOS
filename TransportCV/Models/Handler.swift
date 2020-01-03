//
//  Handler.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Foundation

typealias Handler<Value, AnyError: Error> = (Result<Value, AnyError>) -> ()

typealias APIResult<Value> = Result<Value, Error>

typealias APIHandler<Value> = (APIResult<Value>) -> ()

extension Result where Success == () {
    
    var error: Error? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }
    
}
