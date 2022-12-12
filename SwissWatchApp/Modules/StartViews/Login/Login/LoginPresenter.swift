//
//  LoginPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol ILoginPresenter {
    func loginPressed(email: String?,
                      password: String?,
                      userType: UserType)
    func forgotPasswordPressed()
    func dealerLoginPressed()
    func backPressed()
}

typealias LoginPresenterAction = ((LoginPresenterActionType) -> Void)
enum LoginPresenterActionType {
    case dealerLogin
    case forgotPassword(email: String)
    case loginSuccess
    case userInSuspendedMode(email: String)
    case back
}

class LoginPresenter {
    unowned var view: ILoginView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: LoginPresenterAction?
    func onAction(_ callback: LoginPresenterAction?) {
        self.onAction = callback
    }
    
    let authManager = AuthManager()
    
    init(view: ILoginView) {
        self.view = view
    }
}

extension LoginPresenter: ILoginPresenter {
    func loginPressed(email: String?,
                      password: String?,
                      userType: UserType) {
        let email = email ?? ""
        let password = password ?? ""
        
        self.view.loadIndication(displayed: true)
        
        self.authManager.getTokens(email: email,
                                   password: password,
                                   userType: userType) { [weak self] response in
                                    
                                    self?.view.loadIndication(displayed: false)
                                    
                                    switch response {
                                    case .success(let success):
                                        if let error = success.error {
                                            self?.vc?.showError(title: error.message ?? "Error",
                                                                message: error.description ?? "Unrecognized error")
                                        } else if let warnings = success.warnings {
//                                            let cantFindWarnings = self?.view.updateErrorsWithKeyValues(warnings)
//                                            cantFindWarnings.map {
//                                                $0.first.map { warning in
//                                                    self?.vc?.showError(title: warning.key,
//                                                                        message: warning.value)
//                                                }
//                                            }
                                            warnings.first.map {
                                                self?.vc?.showError(title: $0.key, message: $0.value)
                                            }
                                        } else {
                                            onMainQueue {
                                                self?.onAction?(.loginSuccess)
                                            }
                                        }
                                    case .failure(let failure):
                                        (failure as? InternalError).map { networkingError in
                                            switch networkingError {
                                            case .userInSuspendedMode:
                                                onMainQueue {
                                                    self?.onAction?(.userInSuspendedMode(email: email))
                                                }
                                            default:
                                                self?.vc?.showError(title: "Error",
                                                                    message: failure.localizedDescription)
                                            }
                                        }
                                    }
        }
    }
    
    func backPressed() {
        onMainQueue {
            self.onAction?(.back)
        }
    }
    
    func forgotPasswordPressed() {
        onMainQueue {
            self.onAction?(.forgotPassword(email: self.view.email))
        }
    }
    
    func dealerLoginPressed() {
        onMainQueue {
            self.onAction?(.dealerLogin)
        }
    }
}

private extension LoginPresenter {
    
}
