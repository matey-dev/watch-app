//
//  ForgotPasswordService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/16/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias PasswordCompletion = (Result<GeneralResponse, Error>) -> Void

class PasswordAPIService {
    private struct ResetPasswordParameters: Encodable {
        var email: String
    }
    
    private struct SetPasswordParameters: Encodable {
        var email: String
        var password: String
        var password_confirm: String
        var key: String
    }
    
    private struct ReSendKeyParameters: Encodable {
        var email: String
        var type: String
    }
    
    private struct ValidateResetKeyParameters: Encodable {
        var email: String
        var key: String
    }
    
    private struct ChangePasswordParameters: Encodable {
        var old_password: String
        var new_password: String
        var new_password_confirm: String
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func validateResetKey(email: String,
                          key: String,
                          completion: PasswordCompletion?) {
        let parameters = ValidateResetKeyParameters(email: email,
                                                    key: key)
        
        self.networking.request(type: .POST,
                                urlString: API.ValidateResetKey,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    func reSendKey(email: String,
                   type: SendCodeType,
                   completion: PasswordCompletion?) {
        let parameters = ReSendKeyParameters(email: email,
                                             type: type.apiKeyString)
        
        self.networking.request(type: .POST,
                                urlString: API.ResendKey,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    func resetPassword(email: String,
                       completion: PasswordCompletion?) {
        let parameters = ResetPasswordParameters(email: email)
        
        self.networking.request(type: .POST,
                                urlString: API.ResetPassword,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    func setPassword(email: String,
                     password: String,
                     password_confirm: String,
                     key: String,
                     completion: PasswordCompletion?) {
        let parameters = SetPasswordParameters(email: email,
                                               password: password,
                                               password_confirm: password_confirm,
                                               key: key)
        
        self.networking.request(type: .POST,
                                urlString: API.SetPassword,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    func changePassword(oldPassword: String,
                        newPassword: String,
                        newPasswordConfirm: String,
                        completion: PasswordCompletion?) {
        let parameters = ChangePasswordParameters(old_password: oldPassword,
                                                  new_password: newPassword,
                                                  new_password_confirm: newPasswordConfirm)
        
        self.networking.request(type: .POST,
                                urlString: API.ChangePassword,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: PasswordCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
