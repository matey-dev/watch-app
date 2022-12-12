//
//  RegistrationService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/12/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias RegistrationCompletion = (Result<GeneralResponse, Error>) -> Void

private let BuyerRole: Int = 1
private let SellerRole: Int = 2

struct SellerRegistrationParameters: Encodable {
    var email: String
    var password: String
    var password_confirm: String
    var role: Int
    var agree: Int
}

struct BuyerRegistrationParameters: Encodable {
    var first_name: String
    var last_name: String
    var company_name: String
    var company_phone: String
    var email: String
    var password: String
    var password_confirm: String
    var address: String
    var city: String
    var state: String
    var zip: String
    var role: Int
    var agree: Int
}

class RegistrationAPIService {
    //swiftlint:disable function_parameter_count
    let registrationNetworking = NetworkingService<GeneralResponse>()
    
    func sellerRegistration(email: String,
                            password: String,
                            confirmPassword: String,
                            completion: RegistrationCompletion?) {
        
        let parameters = SellerRegistrationParameters(email: email,
                                                      password: password,
                                                      password_confirm: confirmPassword,
                                                      role: SellerRole,
                                                      agree: 1)
        
        self.registrationNetworking.request(type: .POST,
                                            urlString: API.Registration,
                                            parameters: parameters) { [weak self] (result) in
                                                self?.handle(result: result, completion: completion)
        }
    }
    
    func buyerRegistration(firstName: String,
                           lastName: String,
                           companyName: String,
                           companyPhone: String,
                           email: String,
                           password: String,
                           confirmPassword: String,
                           address: String,
                           city: String,
                           state: String,
                           zipCode: String,
                           completion: RegistrationCompletion?) {
        let parameters = BuyerRegistrationParameters(first_name: firstName,
                                                     last_name: lastName,
                                                     company_name: companyName,
                                                     company_phone: companyPhone,
                                                     email: email,
                                                     password: password,
                                                     password_confirm: confirmPassword,
                                                     address: address,
                                                     city: city,
                                                     state: state,
                                                     zip: zipCode,
                                                     role: BuyerRole,
                                                     agree: 1)
        
        self.registrationNetworking.request(type: .POST,
                                            urlString: API.Registration,
                                            parameters: parameters) { [weak self] (result) in
                                                self?.handle(result: result, completion: completion)
        }
    }
    
    //swiftlint:enable function_parameter_count
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: RegistrationCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
