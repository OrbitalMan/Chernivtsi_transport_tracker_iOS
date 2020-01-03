//
//  TransGPSCVAPI.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Alamofire

enum TransGPSCVAPI: TransportTargetType {
    case getBusRoutes
    case getTrolleyRoutes
    case getTrackers
    
    var baseURL: URL {
        return URL(string: "http://www.trans-gps.cv.ua")!
    }
    
    var apiComponent: String? {
        return "map"
    }
    
    var path: String {
        switch self {
        case .getBusRoutes:
            return "routes/1"
        case .getTrolleyRoutes:
            return "routes/2"
        case .getTrackers:
            return "tracker/"
        }
    }
    
    var parameters: Alamofire.Parameters? {
        switch self {
        case .getBusRoutes, .getTrolleyRoutes:
            return nil
        case .getTrackers:
            return ["selectedRoutesStr": ""]
        }
    }
    
}

extension TransGPSCVAPI {
    
    static func getTrackers(completion: @escaping APIHandler<[TransGPSCVTracker]>) {
        let transGPSTrackersRequest = Request(target: TransGPSCVAPI.getTrackers)
        transGPSTrackersRequest.responseDecoding { (result: APIResult<TransGPSCVTrackerContainer>) in
            switch result {
            case let .success(container):
                let trackers = Array(container.values)
                completion(.success(trackers))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func getRoutes(completion: @escaping APIHandler<[TransGPSCVRoute]>) {
        var routes: [TransGPSCVRoute] = []
        var errors: [Error] = []
        let routesFetchGroup = DispatchGroup()
        
        let transGPSBusRoutesRequest = Request(target: TransGPSCVAPI.getBusRoutes)
        routesFetchGroup.enter()
        transGPSBusRoutesRequest.responseDecoding { (result: APIResult<TransGPSCVRouteContainer>) in
            switch result {
            case let .success(container):
                routes.append(contentsOf: container.values)
            case let .failure(error):
                errors.append(error)
            }
            routesFetchGroup.leave()
        }
        
        let transGPSTrolleyRoutesRequest = Request(target: TransGPSCVAPI.getTrolleyRoutes)
        routesFetchGroup.enter()
        transGPSTrolleyRoutesRequest.responseDecoding { (result: APIResult<TransGPSCVRouteContainer>) in
            switch result {
            case let .success(container):
                routes.append(contentsOf: container.values)
            case let .failure(error):
                errors.append(error)
            }
            routesFetchGroup.leave()
        }
        
        routesFetchGroup.notify(queue: .main) {
            if routes.isEmpty, let error = errors.first {
                completion(.failure(error))
            } else {
                completion(.success(routes))
            }
        }
    }
    
}
