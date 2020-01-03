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

private struct DummyCodable: Codable { }

struct SafeCodableArray<Element: Codable>: Codable {
    
    var elements: [Element]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        var errors = [Error]()
        while !container.isAtEnd {
            do {
                let element = try container.decode(Element.self)
                elements.append(element)
            } catch {
                _ = try? container.decode(DummyCodable.self)
                errors.append(error)
            }
        }
        if elements.isEmpty, let error = errors.first {
            throw error
        }
        self.elements = elements
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
    
}
