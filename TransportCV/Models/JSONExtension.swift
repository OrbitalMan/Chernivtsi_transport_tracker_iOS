//
//  JSONExtension.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Alamofire

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

func printJSON(_ json: Any) -> String {
    let options: JSONSerialization.WritingOptions
    if #available(iOS 11.0, *) {
        options = [.sortedKeys, .prettyPrinted]
    } else {
        options = [.prettyPrinted]
    }
    guard let data = try? JSONSerialization.data(withJSONObject: json,
                                                 options: options) else { return String(describing: json) }
    let string = String(data: data, encoding: .utf8)
    return string ?? data.description
}

struct Safe<Base: Codable>: Codable {
    
    let result: APIResult<Base>
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            let decoded = try container.decode(Base.self)
            result = .success(decoded)
        } catch {
            result = .failure(error)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch result {
        case let .success(value):
            try container.encode(value)
        case let .failure(error):
            print("\(type(of: self)) won't encode - error \(error)")
        }
    }
    
    static func unwrap1(safeArray: [Self]) -> APIResult<[Base]> {
        let values = safeArray.compactMap { $0.result.value }
        if values.isEmpty, let error = safeArray.first(where: { $0.result.error != nil })?.result.error {
            return .failure(error)
        }
        return .success(values)
    }
    
}

func unwrap<T>(safeArray: [Safe<T>]) -> APIResult<[T]> {
    let results = safeArray.map { $0.result }
    return unwrap(results: results)
}

func unwrap<T>(results: [APIResult<T>]) -> APIResult<[T]> {
    let values = results.compactMap { $0.value }
    if values.isEmpty, let error = results.first(where: { $0.error != nil })?.error {
        return .failure(error)
    }
    return .success(values)
}
