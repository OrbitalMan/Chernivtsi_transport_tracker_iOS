//
//  DesydeAPI.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Alamofire

enum DesydeAPI: ProviderTargetType {
    case getRoutes(token: String?)
    case getTrackers(token: String?)
    
    static let baseURL = URL(string: "http://www.transport.cv.ua:8080")!
    
    var apiComponent: String? {
        switch self {
        case .getRoutes, .getTrackers:
            return "DTM/routescheme"
        }
    }
    
    var path: String {
        switch self {
        case .getRoutes:
            return "findAllShort.action"
        case .getTrackers:
            return "findPositionExtsByUser.action"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getRoutes, .getTrackers:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getRoutes(let token),
             .getTrackers(let token):
            guard let token = token else { return nil }
            var headers: HTTPHeaders = [:]
            headers["cookie"] = token
            return headers
        }
    }
    
}

// MARK: -

extension DesydeAPI {
    
    static func catchCookies() {
        Alamofire.SessionManager.default.delegate.taskWillPerformHTTPRedirection = { _, task, response, request in
            guard task.originalRequest?.url?.absoluteString.localizedCaseInsensitiveContains(DesydeAPI.baseURL.absoluteString) ?? false else {
                return request
            }
            var request = request
            let cookie = response.allHeaderFields["Set-Cookie"] as? String
            print("""
                
                catchCookie - taskWillPerformHTTPRedirection:
                From: \(response.url?.absoluteString ?? "nil")
                Cookie: \(cookie ?? "nope")
                """)
            if let cookie = cookie {
                Storage.desydeCookie = cookie
                request.allHTTPHeaderFields?["Cookie"] = cookie
            }
            let redirectCookie = cookie ?? request.allHTTPHeaderFields?["Cookie"]
            if  request.url?.absoluteString.localizedCaseInsensitiveContains("start") ?? false,
                let newCookie = redirectCookie,
                var retryRequest = task.originalRequest
            {
                retryRequest.allHTTPHeaderFields?["Cookie"] = newCookie
                print("Override redirect to \(retryRequest) with \(newCookie)\n")
                return retryRequest
            }
            print("Continue redirect to \(request) with \(redirectCookie ?? "no cookie")\n")
            return request
        }
    }
    
    // MARK: -
    
    private static func getRoutes(token: String?,
                                  completion: @escaping APIHandler<[DesydeRoute]>) {
        let routesRequest = DesydeAPI.getRoutes(token: token).request()
        routesRequest.responseDecoding { (result: APIResult<DesydeRouteContainer>) in
            switch result {
            case let .success(container):
                let unwrapped = unwrap(safeArray: container.routes)
                completion(unwrapped)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private static func getTrackers(token: String?,
                                    completion: @escaping APIHandler<[DesydeTracker]>) {
        let trackersRequest = DesydeAPI.getTrackers(token: token).request()
        trackersRequest.responseDecoding { (result: APIResult<[Safe<DesydeTracker>]>) in
            switch result {
            case let .success(trackers):
                let unwrapped = unwrap(safeArray: trackers)
                completion(unwrapped)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: -
    
    static func getRoutes(completion: @escaping APIHandler<[DesydeRoute]>) {
        getRoutes(token: Storage.desydeCookie, completion: completion)
    }
    
    static func getTrackers(completion: @escaping APIHandler<[DesydeTracker]>) {
        getTrackers(token: Storage.desydeCookie, completion: completion)
    }
    
}
