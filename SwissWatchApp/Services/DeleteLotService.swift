//
//  DeleteLotService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias DeleteLotCompletion = (Result<GeneralResponse, Error>) -> Void

class DeleteLotAPIService {
    private struct DeleteLotParameters: Encodable {
        var lot_id: Int
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func deleteLot(with id: Int, completion: DeleteLotCompletion?) {
        let parameters = DeleteLotParameters(lot_id: id)
        
        self.networking.request(type: .POST,
                                urlString: API.deleteLot,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: DeleteLotCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
