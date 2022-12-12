//
//  SendCodePresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/4/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum SendCodeType {
    case activation, reset, back
    
    var apiKeyString: String {
        switch self {
        case .activation:
            return "1"
        case .reset:
            return "2"
        case .back:
            return ""
        }
    }
}

protocol ISendCodePresenter {
    func nextPressed(key: String)
    func resendPressed()
    func backPressed()
    func onViewDidLoad()
}

typealias SendCodePresenterAction = ((SendCodePresenterActionType) -> Void)
enum SendCodePresenterActionType {
    case next(email: String, code: String)
    case finish(userType: UserType)
    case back
}

class SendCodePresenter {
    unowned var view: ISendCodeView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    let activationService = ActivationAPIService()
    let passwordService = PasswordAPIService()
    
    private var email: String
    private var sendCodeType: SendCodeType
    private var userType: UserType
    
    var onAction: SendCodePresenterAction?
    func onAction(_ callback: SendCodePresenterAction?) {
        self.onAction = callback
    }
    
    init(view: ISendCodeView,
         email: String,
         sendCodeType: SendCodeType,
         userType: UserType) {
        self.view = view
        self.email = email
        self.sendCodeType = sendCodeType
        self.userType = userType
    }
}

extension SendCodePresenter {
    enum TopMessageLabel {
        case sendCode, resendCode
        var string: String {
            switch self {
            case .sendCode:
                return "Check you email for the\nvalidation code"
            case .resendCode:
                return "We have sent you\nthe new validation code."
            }
        }
    }
}

extension SendCodePresenter: ISendCodePresenter {
    func backPressed() {
        self.onAction?(.back)
    }
    
    func nextPressed(key: String) {
//        guard key.count == 5 else {
//            self.vc?.showError(title: "Warning",
//                               message: "Code should be 5 digits")
//            return
//        }
        
        switch self.sendCodeType {
        case .activation:
            self.activateAccount(key: key)
        case .reset:
            self.resetPassword(key: key)
        case .back:
            break
        }
    }
    
    private func activateAccount(key: String) {
        self.view.loadIndication(displayed: true)
        
        self.activationService.activate(email: self.email, key: key) { [weak self] response in
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
                        self.map { $0.onAction?(.finish(userType: $0.userType)) }
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                     message: failure.localizedDescription)
            }
        }
    }
    
    private func resetPassword(key: String) {
        self.view.loadIndication(displayed: true)
        
        self.passwordService.validateResetKey(email: self.email, key: key) { [weak self] response in
            self?.view.loadIndication(displayed: false)
            
            switch response {
            case .success(let success):
                if let error = success.error {
                    self?.vc?.showError(title: error.message ?? "Error",
                                        message: error.description ?? "")
                } else if let warnings = success.warnings {
                    let cantFindWarnings = self?.view.updateErrorsWithKeyValues(warnings)
                    cantFindWarnings.map {
                        $0.first.map { warning in
                            self?.vc?.showError(title: warning.key,
                                                message: warning.value)
                        }
                    }
                } else {
                    onMainQueue {
                        self.map { $0.onAction?(.next(email: $0.email, code: key)) }
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func resendPressed() {
        self.view.loadIndication(displayed: true)
        
        self.passwordService.reSendKey(email: self.email, type: self.sendCodeType) { [weak self] response in
            self?.view.loadIndication(displayed: false)
            self?.view.setResendButton(active: false)
            
            switch response {
            case .success(let success):
                if let error = success.error {
                    self?.vc?.showError(title: error.message ?? "Error",
                                        message: error.description ?? "")
                } else if let warning = success.warnings?.first {
                    self?.vc?.showError(title: warning.key,
                                        message: warning.value)
                } else {
                    self?.view.setTopMessage(SendCodePresenter.TopMessageLabel.resendCode.string)
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func onViewDidLoad() {
        self.view.setTopMessage(SendCodePresenter.TopMessageLabel.sendCode.string)
    }
}
