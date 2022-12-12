//
//  DealerLotService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/9/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias GetDealerLotCompletion = (Result<DealerLot, Error>) -> Void

class DealerLotAPIService {
    private struct LotParameters: Encodable {}
    
    let networking = NetworkingService<DealerLot>()
    
    func getLot(with id: Int, completion: GetDealerLotCompletion?) {
        let parameters = LotParameters()
        
        var urlString = API.getDealerLot
        urlString.append(String(id))
        
        self.networking.request(type: .GET,
                                urlString: urlString,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<DealerLot, Error>,
                        completion: GetDealerLotCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
