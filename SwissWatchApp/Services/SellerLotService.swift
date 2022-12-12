//
//  LotService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/29/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias GetSellerLotCompletion = (Result<SellerLot, Error>) -> Void
typealias ChooseBetCompletion = (Result<GeneralResponse, Error>) -> Void

class SellerLotAPIService {
    private struct LotParameters: Encodable {}
    private struct BetParameters: Encodable {
        var lot_id: Int
        var bet_id: Int
    }
    
    let networking = NetworkingService<SellerLot>()
    let generalNetworking = NetworkingService<GeneralResponse>()
    
    func getLot(with id: Int, completion: GetSellerLotCompletion?) {
        let parameters = LotParameters()
        
        var urlString = API.getSellerLot
        urlString.append(String(id))
        
        self.networking.request(type: .GET,
                                urlString: urlString,
                                parameters: parameters) { (result) in
                                    self.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    func chooseBet(betId: Int, lotId: Int, completion: ChooseBetCompletion?) {
        let parameters = BetParameters(lot_id: lotId,
                                       bet_id: betId)
        let urlString = API.chooseBet
        
        self.generalNetworking.request(type: .POST,
                                urlString: urlString,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<SellerLot, Error>,
                        completion: GetSellerLotCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: ChooseBetCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        case .success(let response):
            print(response)
        default:
            break
        }
        
        completion?(result)
    }
}
