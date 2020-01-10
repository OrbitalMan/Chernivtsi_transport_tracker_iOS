//
//  Request.swift
//  TransportCV
//
//  Created by Stanislav on 26.12.2019.
//  Copyright © 2019 OrbitalMan. All rights reserved.
//

import Alamofire

// MARK: - LocalizedError
extension String: LocalizedError {
    
    public var errorDescription: String? {
        return self
    }
    
}

/// Alamofire request wrapper for convenience.
class Request {
    
    /// Defines request data.
    let target: APITargetType
    
    let dataRequest: DataRequest
    
    func rawResponse(completion: @escaping APIHandler<DataResponse<Data>>) {
        dataRequest.responseData { response in
            completion(.success(response))
        }
    }
    
    init(target: APITargetType, startImmediately: Bool = true) {
        self.target = target
        if !startImmediately {
            SessionManager.default.startRequestsImmediately = false
        }
        self.dataRequest = Alamofire.request(target.url,
                                             method: target.method,
                                             parameters: target.parameters,
                                             encoding: target.encoding,
                                             headers: target.headers)
        SessionManager.default.startRequestsImmediately = true
    }
    
    func responseIsOk(completion: @escaping APIHandler<()>) {
        rawResponse { response in
            switch response {
            case let .success(response):
                if (200..<300).contains(response.response?.statusCode ?? 0) {
                    completion(.success(()))
                    return
                }
                if let error = response.error {
                    completion(.failure(error))
                    return
                }
                completion(.failure("Unknown Error"))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func responseDecoding<T: Decodable>(completion: @escaping APIHandler<T>) {
        rawResponse { response in
            switch response {
            case let .success(response):
                if let data = response.data, !data.isEmpty {
                    do {
                        let decoded = try newJSONDecoder().decode(T.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(response.error ?? error))
                    }
                    return
                }
                if let error = response.error {
                    completion(.failure(error))
                    return
                }
                completion(.failure("Unknown Error"))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}

extension Alamofire.DataResponse where Value == Data {
    
    var stringResponse: String {
        let stringResult = DataRequest.serializeResponseString(encoding: .utf8,
                                                               response: response,
                                                               data: data,
                                                               error: nil)
        let optionalString = try? stringResult.unwrap()
        return optionalString ?? "nil"
    }
    
    var jsonResult: Alamofire.Result<Any> {
        let jsonResult = DataRequest.serializeResponseJSON(options: .allowFragments,
                                                           response: response,
                                                           data: data,
                                                           error: error)
        return jsonResult
    }
    
}
