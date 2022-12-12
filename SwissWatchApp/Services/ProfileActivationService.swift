//
//  ProfileActivationService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/16/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias ProfileActivationCompletion = (Result<GeneralResponse, Error>) -> Void

class ProfileActivationAPIService {
    private struct Parameters: Encodable {
        var email: String
        var key: String
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func activateProfile(email: String,
                         key: String,
                         completion: ProfileActivationCompletion?) {
        let parameters = Parameters(email: email,
                                    key: key)
        
        self.networking.request(type: .POST,
                                urlString: API.SetPassword,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: ProfileActivationCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
