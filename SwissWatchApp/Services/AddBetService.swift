//
//  AddBetService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias AddBetCompletion = (Result<GeneralResponse, Error>) -> Void

class AddBetAPIService {
  private struct Parameters: Encodable {
    var lot_id: Int
    var price: Int
  }
  
  let networking = NetworkingService<GeneralResponse>()
  
  func addBetToLot(with id: Int, bet: Int, completion: AddBetCompletion?) {
    let parameters = Parameters(lot_id: id, price: bet)
    
    self.networking.request(type: .POST,
                            urlString: API.addBet,
                            parameters: parameters) { [weak self] (result) in
                              self?.handle(result: result,
                                           completion: completion)
                              
    }
  }
  
  private func handle(result: Result<GeneralResponse, Error>,
                      completion: AddBetCompletion?) {
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
