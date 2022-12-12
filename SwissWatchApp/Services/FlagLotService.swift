//
//  FlagLotService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias FlagLotCompletion = (Result<GeneralResponse, Error>) -> Void

class FlagLotAPIService {
  private struct Parameters: Encodable {
    var lot_id: Int
  }
  
  let networking = NetworkingService<GeneralResponse>()
  
  func flagLot(with id: Int, completion: FlagLotCompletion?) {
    let parameters = Parameters(lot_id: id)
    
    self.networking.request(type: .POST,
                            urlString: API.flagLot,
                            parameters: parameters) { [weak self] (result) in
                              self?.handle(result: result,
                                           completion: completion)
                              
    }
  }
  
  private func handle(result: Result<GeneralResponse, Error>,
                      completion: FlagLotCompletion?) {
    switch result {
    case .failure(let error):
      Logger.log(logType: .error, message: error.localizedDescription)
    default:
      break
    }
    
    completion?(result)
  }
}
