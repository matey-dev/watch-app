//
//  StartLoginPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import AuthenticationServices

protocol IStartLoginPresenter {
    func onViewDidAppear()
    
    func signUpWithEmailButtonPressed()
    func signUpAsDealerButtonPressed()
    func signInButtonPressed()
    func signUpWithFacebookButtonPressed(socialServiceUIDelegate: SocialNetworksUIDelegate)
    func appleLogin(appleIDCredential: ASAuthorizationAppleIDCredential)
}

typealias StartLoginAction = ((StartLoginActionType) -> Void)
enum StartLoginActionType {
    case signIn
    case signUp
    case signUpAsDealer
    case fbSuccess
    case fbFailure
    case appleFailure
    case userInSuspendedMode(email: String)
}

class StartLoginPresenter {
    unowned var view: IStartLoginView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    let authManager = AuthManager()
    
    var onAction: StartLoginAction?
    func onAction(_ callback: StartLoginAction?) {
        self.onAction = callback
    }
    
    init(view: IStartLoginView) {
        self.view = view
    }
}

extension StartLoginPresenter: IStartLoginPresenter {
    func onViewDidAppear() {
        
    }
    
    func signUpWithEmailButtonPressed() {
        onMainQueue {
            self.onAction?(.signUp)
        }
    }
    
    func signUpAsDealerButtonPressed() {
        onMainQueue {
            self.onAction?(.signUpAsDealer)
        }
    }
    
    func signInButtonPressed() {
        onMainQueue {
            self.onAction?(.signIn)
        }
    }
    
    func signUpWithFacebookButtonPressed(socialServiceUIDelegate: SocialNetworksUIDelegate) {
        self.view.loadIndication(displayed: true)
        
        self.authManager.auth(socialService: .facebook, delegateForUI: socialServiceUIDelegate) { [weak self] response in
            self?.view.loadIndication(displayed: false)
            
            switch response {
            case .success(let success):
                if let error = success.error {
                    self?.vc?.showError(title: error.message ?? "Error",
                                        message: error.description ?? "Unrecognized error")
                } else if let warning = success.warnings?.first {
                    self?.vc?.showError(title: warning.key,
                                        message: warning.value)
                } else {
                    onMainQueue {
                        self?.onAction?(.fbSuccess)
                    }
                }
            case .failure(let failure):
                (failure as? InternalError).map { internalError in
                    switch internalError {
                    case .cantGetEmailFromFB:
                        self?.onAction?(.fbFailure)
                    case .userInSuspendedMode:
                        self?.authManager.getSavedEmail().map { self?.onAction?(.userInSuspendedMode(email: $0)) }
                    default: ()
//                        self?.vc?.showError(title: "Error",
//                                            message: failure.localizedDescription)
                    }
                }
            }
        }
    }
    
    func appleLogin(appleIDCredential: ASAuthorizationAppleIDCredential) {
        self.view.loadIndication(displayed: true)
        self.authManager.signInWithApple(appleIDCredential: appleIDCredential){ [weak self] response in
            self?.view.loadIndication(displayed: false)
            
            switch response {
            case .success(let success):
                if let error = success.error {
                    self?.vc?.showError(title: error.message ?? "Error",
                                        message: error.description ?? "Unrecognized error")
                } else if let warning = success.warnings?.first {
                    self?.vc?.showError(title: warning.key,
                                        message: warning.value)
                } else {
                    onMainQueue {
                        self?.onAction?(.fbSuccess)
                    }
                }
            case .failure(let failure):
                (failure as? InternalError).map { internalError in
                    switch internalError {
                    case .cantGetInfoFromApple:
//                        self?.onAction?(.appleFailure)
                        self?.vc?.showError(title: "Unable to get your email", message: "Please remove app from your apple ID, and after doing that please try again.")
                    case .userInSuspendedMode:
                        self?.authManager.getSavedEmail().map { self?.onAction?(.userInSuspendedMode(email: $0)) }
                    default: ()
                        self?.vc?.showError(title: "Error",
                                            message: failure.localizedDescription)
                    }
                }
            }
        }
    }
    
}
