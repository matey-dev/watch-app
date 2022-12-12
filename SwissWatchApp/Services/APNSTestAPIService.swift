//
//  APNSTestAPIService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/26/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias ApnsTestCompletion = (Result<GeneralResponse, Error>) -> Void

class ApnsTestAPIService {
    private struct Parameters: Encodable {
        var token: String
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func test(_ completion: ApnsTestCompletion?) {
        guard let token = PushService.shared.currentToken else { return }
        let parameters = Parameters(token: token)
        
        self.networking.request(type: .POST,
                                urlString: API.testApn,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: ApnsTestCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
