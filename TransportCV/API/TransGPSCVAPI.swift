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
    
    static let baseURL = URL(string: "http://www.trans-gps.cv.ua")!
    
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
    
    static func getRoutes(completion: @escaping APIHandler<[TransGPSCVRoute]>) {
        var results: [APIResult<TransGPSCVRoute>] = []
        let routesFetchGroup = DispatchGroup()
        
        let transGPSBusRoutesRequest = Request(target: TransGPSCVAPI.getBusRoutes)
        routesFetchGroup.enter()
        transGPSBusRoutesRequest.responseDecoding { (result: APIResult<TransGPSCVRouteContainer>) in
            switch result {
            case let .success(busContainer):
                let busResults = busContainer.values.map { $0.result }
                results.append(contentsOf: busResults)
            case let .failure(error):
                results.append(.failure(error))
            }
            routesFetchGroup.leave()
        }
        
        let transGPSTrolleyRoutesRequest = Request(target: TransGPSCVAPI.getTrolleyRoutes)
        routesFetchGroup.enter()
        transGPSTrolleyRoutesRequest.responseDecoding { (result: APIResult<TransGPSCVRouteContainer>) in
            switch result {
            case let .success(trolleyContainer):
                let trolleyResults = trolleyContainer.values.map { $0.result }
                results.append(contentsOf: trolleyResults)
            case let .failure(error):
                results.append(.failure(error))
            }
            routesFetchGroup.leave()
        }
        
        routesFetchGroup.notify(queue: .main) {
            let unwrapped = unwrap(results: results)
            completion(unwrapped)
        }
    }
    
    static func getTrackers(completion: @escaping APIHandler<[TransGPSCVTracker]>) {
        let transGPSTrackersRequest = Request(target: TransGPSCVAPI.getTrackers)
        transGPSTrackersRequest.responseDecoding { (result: APIResult<TransGPSCVTrackerContainer>) in
            switch result {
            case let .success(container):
                let unwrapped = unwrap(safeArray: Array(container.values))
                completion(unwrapped)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}
