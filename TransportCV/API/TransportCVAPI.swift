//
//  TransportCVAPI.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Alamofire

enum TransportCVAPI: TransportTargetType {
    case getRoutes(token: String)
    case getTrackers(token: String)
    case auth(username: String, password: String)
    
    var baseURL: URL {
        return URL(string: "http://www.transport.cv.ua:8080")!
    }
    
    var apiComponent: String? {
        switch self {
        case .getRoutes, .getTrackers:
            return "DTM/routescheme"
        case .auth:
            return "DTM"
        }
    }
    
    var path: String {
        switch self {
        case .getRoutes:
            return "findAllShort.action"
        case .getTrackers:
            return "findPositionExtsByUser.action"
        case .auth:
            return "j_spring_security_check"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getRoutes, .getTrackers:
            return nil
        case let .auth(username, password):
            var parameters: Parameters = [:]
            parameters["j_username"] = username
            parameters["j_password"] = password
            return parameters
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getRoutes(let token),
             .getTrackers(let token):
            var headers: HTTPHeaders = [:]
            headers["cookie"] = token
            return headers
        case .auth:
            return nil
        }
    }
    
}

// MARK: -

extension TransportCVAPI {
    
    private static var sessionDelegate: SessionDelegate {
        Alamofire.SessionManager.default.delegate
    }
    
    private static func startCatchingCookie(caught: @escaping (String) -> ()) {
        sessionDelegate.taskWillPerformHTTPRedirection = { (_, _, response, request) -> URLRequest? in
            if let cookie = response.allHeaderFields["Set-Cookie"] as? String {
                Storage.transportCVCookie = cookie
                caught(cookie)
                if request.url?.absoluteString.contains("start") ?? false {
                    return nil
                }
            }
            return request
        }
    }
    
    private static func declineRedirects() {
        sessionDelegate.taskWillPerformHTTPRedirection = { _, _, _, _ in
            return nil
        }
    }
    
    private static func stopCatchingRedirects() {
        sessionDelegate.taskWillPerformHTTPRedirection =  nil
    }
    
    // MARK: -
    
    private static func getToken(completion: @escaping (String?) -> ()) {
        var token: String? = nil
        let authRequest = TransportCVAPI.auth(username: "ChernivtsyPublicUser",
                                              password: "peopleoF4e").request
        startCatchingCookie { token = $0 }
        authRequest.rawResponse { result in
            stopCatchingRedirects()
            completion(token)
        }
    }
    
    private static func getRoutes(token: String?,
                                  completion: @escaping APIHandler<[TransportCVRoute]>) {
        guard let token = token else {
            completion(.failure("getRoutes failure - missing token"))
            return
        }
        let routesRequest = TransportCVAPI.getRoutes(token: token).request
        declineRedirects()
        routesRequest.responseDecoding { (result: APIResult<TransportCVRoutes>) in
            stopCatchingRedirects()
            switch result {
            case let .success(routes):
                completion(.success(routes.routes.elements))
            case .failure:
                getToken {
                    getRoutes(token: $0, completion: completion)
                }
            }
        }
    }
    
    private static func getTrackers(token: String?,
                                    completion: @escaping APIHandler<[TransportCVTracker]>) {
        guard let token = token else {
            completion(.failure("getTrackers failure - missing token"))
            return
        }
        let trackersRequest = TransportCVAPI.getTrackers(token: token).request
        declineRedirects()
        trackersRequest.responseDecoding { (result: APIResult<SafeCodableArray<TransportCVTracker>>) in
            stopCatchingRedirects()
            switch result {
            case let .success(trackers):
                completion(.success(trackers.elements))
            case .failure:
                getToken {
                    getTrackers(token: $0, completion: completion)
                }
            }
        }
    }
    
    // MARK: -
    
    static func getRoutes(completion: @escaping APIHandler<[TransportCVRoute]>) {
        guard let token = Storage.transportCVCookie else {
            getToken {
                getRoutes(token: $0, completion: completion)
            }
            return
        }
        getRoutes(token: token, completion: completion)
    }
    
    static func getTrackers(completion: @escaping APIHandler<[TransportCVTracker]>) {
        guard let token = Storage.transportCVCookie else {
            getToken {
                getTrackers(token: $0, completion: completion)
            }
            return
        }
        getTrackers(token: token, completion: completion)
    }
    
}
