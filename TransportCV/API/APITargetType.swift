//
//  APITargetType.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Alamofire

protocol APITargetType {
    
    /// The target's base `URL`.
    static var baseURL: URL { get }
    
    /// The target's API path component.
    var apiComponent: String? { get }
    
    /// The path to API endpoint.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: Alamofire.HTTPMethod { get }
    
    /// The target's parameters.
    var parameters: Alamofire.Parameters? { get }
    
    /// The target's request parameters encoding.
    var encoding: Alamofire.ParameterEncoding { get }
    
    /// The headers to be used in the request.
    var headers: Alamofire.HTTPHeaders? { get }
    
}

extension APITargetType {
    
    /// The target's `URL` to perform requests on.
    /// The path to be appended to `baseURL` with `apiComponent` to form the full `URL`.
    var url: Alamofire.URLConvertible {
        var url = Self.baseURL
        if let apiComponent = apiComponent {
            url.appendPathComponent(apiComponent)
        }
        url.appendPathComponent(path)
        return url
    }
    
    func request(startImmediately: Bool = true) -> Request {
        return Request(target: self, startImmediately: startImmediately)
    }
    
}

protocol TransportTargetType: APITargetType {
    
}

extension TransportTargetType {
    
    var method: Alamofire.HTTPMethod { .get }
    
    var parameters: Alamofire.Parameters? { nil }
    
    var encoding: Alamofire.ParameterEncoding { URLEncoding.default }
    
    var headers: Alamofire.HTTPHeaders? { nil }
    
}
