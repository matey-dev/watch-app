//
//  ReactivateLotService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/19/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias ReactivateLotCompletion = (Result<GeneralResponse, Error>) -> Void

class ReactivateLotAPIService {
    private struct ReactivateLotParameters: Encodable {
        var lot_id: Int
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func reactivateLot(with id: Int, completion: ReactivateLotCompletion?) {
        let parameters = ReactivateLotParameters(lot_id: id)
        
        self.networking.request(type: .POST,
                                urlString: API.reactivateLot,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: ReactivateLotCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
