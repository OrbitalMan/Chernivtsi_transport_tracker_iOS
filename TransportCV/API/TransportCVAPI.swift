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
        case .getRoutes(let token), .getTrackers(let token):
            var headers: HTTPHeaders = [:]
            headers["cookie"] = token
            return headers
        case .auth:
            return nil
        }
    }
    
}

extension TransportCVAPI {
    
    private static var sessionDelegate: SessionDelegate {
        Alamofire.SessionManager.default.delegate
    }
    
    private static func catchCookies() {
        sessionDelegate.taskWillPerformHTTPRedirection = { (_, _, response, request) -> URLRequest? in
            if tryUpdatingCookies(in: response) {
                return nil
            }
            return request
        }
    }
    
    @discardableResult
    private static func tryUpdatingCookies(in response: HTTPURLResponse?) -> Bool {
        if let token = response?.allHeaderFields["Set-Cookie"] as? String {
            Storage.transportCVCookie = token
            return true
        }
        return false
    }
    
    static func getToken(completion: @escaping APIHandler<String>) {
        catchCookies()
        let transportCVAuthRequest = Request(target: TransportCVAPI.auth(username: "ChernivtsyPublicUser",
                                                                         password: "peopleoF4e"))
        transportCVAuthRequest.rawResponse { result in
            sessionDelegate.taskWillPerformHTTPRedirection = nil
            switch result {
            case let .success(dataResponse):
                let headers = dataResponse.response?.allHeaderFields
                if let token = headers?["Set-Cookie"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure("Failed to get token from \(dataResponse.stringResponse ?? dataResponse.description)"))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private static func getTrackers(token: String,
                                    completion: @escaping APIHandler<[TransportCVTracker]>) {
        catchCookies()
        let transportCVTrackersRequest = Request(target: TransportCVAPI.getTrackers(token: token))
        transportCVTrackersRequest.responseDecoding { (result: APIResult<SafeCodableArray<TransportCVTracker>>) in
            sessionDelegate.taskWillPerformHTTPRedirection = nil
            switch result {
            case let .success(trackers):
                completion(.success(trackers.elements))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        transportCVTrackersRequest.rawResponse { result in
            switch result {
            case let .success(dataResponse):
                tryUpdatingCookies(in: dataResponse.response)
            case .failure:
                break
            }
        }
    }
    
    private static func getRoutes(token: String,
                                  completion: @escaping APIHandler<[TransportCVRoute]>) {
        catchCookies()
        let transportCVRoutesRequest = Request(target: TransportCVAPI.getRoutes(token: token))
        transportCVRoutesRequest.responseDecoding { (result: APIResult<TransportCVRoutes>) in
            sessionDelegate.taskWillPerformHTTPRedirection = nil
            switch result {
            case let .success(routes):
                completion(.success(routes.routes))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        transportCVRoutesRequest.rawResponse { result in
            switch result {
            case let .success(dataResponse):
                tryUpdatingCookies(in: dataResponse.response)
            case .failure:
                break
            }
        }
    }
    
    static func getTrackers(completion: @escaping APIHandler<[TransportCVTracker]>) {
        getToken { result in
            switch result {
            case let .success(token):
                Storage.transportCVCookie = token
                getTrackers(token: token, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func getRoutes(completion: @escaping APIHandler<[TransportCVRoute]>) {
        getToken { result in
            switch result {
            case let .success(token):
                Storage.transportCVCookie = token
                getRoutes(token: token, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
        return
    }
    
}
