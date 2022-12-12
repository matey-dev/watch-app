//
//  RegistrationPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

//swiftlint:disable function_parameter_count

protocol IRegistrationPresenter {
    func onViewDidAppear()
    func goToSignUpAsDealerButtonPressed()
    func signUpSellerButtonPressed(email: String,
                                   password: String,
                                   confirmPassword: String)
    func signUpDealerButtonPressed(firstName: String,
                                   lastName: String,
                                   companyName: String,
                                   companyPhone: String,
                                   email: String,
                                   password: String,
                                   confirmPassword: String,
                                   address: String,
                                   city: String,
                                   state: String,
                                   zipCode: String)
    func backToSignIn()
}

typealias RegistrationAction = ((RegistrationActionType) -> Void)
enum RegistrationActionType {
    case signUpSuccess(email: String), dealerSignUp, back
}

class RegistrationPresenter {
    unowned var view: IRegistrationView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    private var email: String = ""
    
    let registrationService = RegistrationAPIService()
    
    var onAction: RegistrationAction?
    func onAction(_ callback: RegistrationAction?) {
        self.onAction = callback
    }
    
    init(view: IRegistrationView) {
        self.view = view
    }
}

extension RegistrationPresenter: IRegistrationPresenter {
    func onViewDidAppear() {}
    
    func goToSignUpAsDealerButtonPressed() {
        self.onAction?(.dealerSignUp)
    }
    
    func signUpSellerButtonPressed(email: String, password: String, confirmPassword: String) {
        self.email = email
        
        self.view.loadIndication(displayed: true)
        
        self.registrationService.sellerRegistration(email: email, password: password, confirmPassword: confirmPassword) { [weak self] response in
            
            self?.view.loadIndication(displayed: false)
            
            switch response {
            case .success(let success):
                if let error = success.error {
                    self?.vc?.showError(title: error.message ?? "Error",
                                        message: error.description ?? "")
                } else if let warnings = success.warnings {
                    warnings.first.map { warning in
                        let title = warning.key.lowercased().capitalizingFirstLetter().replacingOccurrences(of: "_", with: " ")
                        let message = warning.value.lowercased().capitalizingFirstLetter().replacingOccurrences(of: "_", with: " ")
                        self?.vc?.showError(title: title,
                                            message: message)
                    }
                } else {
                    onMainQueue {
                        self.map { $0.onAction?(.signUpSuccess(email: $0.email)) }
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func signUpDealerButtonPressed(firstName: String, lastName: String, companyName: String, companyPhone: String, email: String, password: String, confirmPassword: String, address: String, city: String, state: String, zipCode: String) {
        self.email = email
        
        self.view.loadIndication(displayed: true)
        
        self.registrationService.buyerRegistration(firstName: firstName, lastName: lastName, companyName: companyName, companyPhone: companyPhone, email: email, password: password, confirmPassword: confirmPassword, address: address, city: city, state: state, zipCode: zipCode) { [weak self] response in
            
            self?.view.loadIndication(displayed: false)
            
            switch response {
            case .success(let success):
                if let error = success.error {
                    self?.vc?.showError(title: error.message ?? "Error",
                                        message: error.description ?? "")
                } else if let warnings = success.warnings {
//                    let cantFindWarnings = self?.view.updateErrorsWithKeyValues(warnings)
//                    cantFindWarnings.map {
//                        $0.first.map { warning in
//                            self?.vc?.showError(title: warning.key,
//                                                message: warning.value)
//                        }
//                    }
                    warnings.first.map { warning in
                        let title = warning.key.lowercased().capitalizingFirstLetter().replacingOccurrences(of: "_", with: " ")
                        let message = warning.value.lowercased().capitalizingFirstLetter().replacingOccurrences(of: "_", with: " ")
                        self?.vc?.showError(title: title,
                                            message: message)
                    }
                } else {
                    onMainQueue {
                        self.map { $0.onAction?(.signUpSuccess(email: $0.email)) }
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func backToSignIn() {
        self.onAction?(.back)
    }
}

//swiftlint:enable function_parameter_count
