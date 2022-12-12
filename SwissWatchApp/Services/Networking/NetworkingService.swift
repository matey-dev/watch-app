//
//  NetworkingService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum RequestType: String {
    case POST
    case GET
}

enum InternalError: Equatable, Error {
    case serverError(statusCode: Int)
    case empty
    case wrongRequest
    case cancelled
    case cantGetAuthToken
    case cantGetEmailFromFB
    case cantGetInfoFromApple
    case userInSuspendedMode
    case userOnWaitingList
    case unauthorized
}

class NetworkingService<Response: Decodable> {
    typealias ResponseCompletion = (Result<Response, Error>) -> Void
    
    let urlSession = URLSession.shared
    
    func request<RequestParameters: Encodable>(type: RequestType,
                                               urlString: String,
                                               parameters: RequestParameters,
                                               auth: Bool = true,
                                               completion: ResponseCompletion?) {
        onGlobalUserInitiatedQueue {
            guard var request = URLRequest(type: type, urlString: urlString, parameters: parameters) else {
                onMainQueue {
                    completion?(.failure(InternalError.wrongRequest))
                }
                return
            }
            
            if auth {
                TokensStorage.shared.getToken { authToken in
                    authToken.map { authToken in
                        let authValue: String = "Bearer \(authToken)"
                        print(authValue)
                        request.addValue(authValue, forHTTPHeaderField: "Authorization")
                    }
                    
                    Logger.logRequest(urlString, parameters)
                    let requestDate = Date()
                    self.serverRequest(request) { (data, response, _) in
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? .zero
                        Logger.logResponse(requestDate, urlString, data, statusCode)
                        
                        if statusCode == 401 {
                            //completion?(.failure(InternalError.unauthorized))
                            AppCoordinatorListenersHolder.shared.logOutListener?()
                        } else if statusCode == 418 {
                            completion?(.failure(InternalError.userInSuspendedMode))
                        } else if statusCode == 403 {
                            completion?(.failure(InternalError.userOnWaitingList))
                        } else {
                            let result: Result<Response, Error>
                            if let deserializedData: Response = data?.deserialize() {
                                result = .success(deserializedData)
                            } else {
                                result = .failure(InternalError.serverError(statusCode: statusCode))
                            }
                            onMainQueue {
                                completion?(result)
                            }
                        }
                    }
                }
            } else {
                Logger.logRequest(urlString, parameters)
                let requestDate = Date()
                self.serverRequest(request) { (data, response, _) in
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? .zero
                    Logger.logResponse(requestDate, urlString, data, statusCode)
                    
                    if statusCode == 401 {
                        //completion?(.failure(InternalError.unauthorized))
                        AppCoordinatorListenersHolder.shared.logOutListener?()
                    } else if statusCode == 418 {
                        completion?(.failure(InternalError.userInSuspendedMode))
                    } else if statusCode == 403 {
                        completion?(.failure(InternalError.userOnWaitingList))
                    } else {
                        let result: Result<Response, Error>
                        if let deserializedData: Response = data?.deserialize() {
                            result = .success(deserializedData)
                        } else {
                            result = .failure(InternalError.serverError(statusCode: statusCode))
                        }
                        onMainQueue {
                            completion?(result)
                        }
                    }
                }
            }
        }
    }
    
    private func serverRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.urlSession
            .dataTask(with: request, completionHandler: completion)
            .resume()
    }
}
