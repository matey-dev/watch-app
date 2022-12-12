//
//  ReactivationService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/22/19.
//  Copyright © 2020 m1c0. All rights reserved.
//

import Foundation

typealias GetReactivationCompletion = (Result<GeneralResponse, Error>) -> Void

class ReactivationAPIService {
    private struct Parameters: Encodable {}
    
    let networking = NetworkingService<GeneralResponse>()
    
    func reactivate(completion: GetReactivationCompletion?) {
        let parameters = Parameters()
        let urlString = AРI.Endpoints.reactivation
        
        self.networking.request(type: .GET,
                                urlString: urlString,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: GetReactivationCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
