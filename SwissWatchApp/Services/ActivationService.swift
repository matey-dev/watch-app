//
//  ActivationService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias ActivationCompletion = (Result<AuthTokenResponse, Error>) -> Void

struct ActivationParameters: Encodable {
    var email: String
    var key: String
}

class ActivationAPIService {
    let activationNetworking = NetworkingService<AuthTokenResponse>()
    
    func activate(email: String, key: String, completion: ActivationCompletion?) {
        let parameters = ActivationParameters(email: email, key: key)
        
        self.activationNetworking.request(type: .POST,
                                          urlString: API.Activation,
                                          parameters: parameters) { [weak self] (activationResult) in
                                            self?.handle(activationResult: activationResult,
                                                         completion: completion)
        }
    }
    
    private func handle(activationResult: Result<AuthTokenResponse, Error>, completion: GetTokensCompletion?) {
        switch activationResult {
        case .success(let authTokenResponse):
            self.handle(activationResult: authTokenResponse)
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        }
        
        completion?(activationResult)
    }
    
    @discardableResult private func handle(activationResult: AuthTokenResponse) -> Bool {
        #warning("TODO: - maybe auth and refresh validators needed")
        guard let auth = activationResult.auth, !auth.isEmpty,
            let refresh = activationResult.refresh, !refresh.isEmpty,
        let expiresOn = activationResult.expiresOn, expiresOn != 0 else {
                return false
        }
        
        TokensStorage.shared.auth = auth
        TokensStorage.shared.refresh = refresh
        TokensStorage.shared.expiresOn = expiresOn
        return true
    }
}
