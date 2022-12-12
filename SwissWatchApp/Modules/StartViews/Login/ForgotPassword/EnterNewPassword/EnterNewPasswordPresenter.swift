//
//  EnterNewPasswordPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/4/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol IEnterNewPasswordPresenter {
    func didChange(password: String)
    func didChange(confirmPassword: String)
    func backPressed()
    func nextPressed()
}

typealias EnterNewPasswordPresenterAction = ((EnterNewPasswordPresenterActionType) -> Void)
enum EnterNewPasswordPresenterActionType {
    case next
    case back
}

class EnterNewPasswordPresenter {
    unowned var view: IEnterNewPasswordView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    let passwordService = PasswordAPIService()
    
    private var email: String
    private var key: String
    private var password: String?
    private var confirmPassword: String?
    
    var onAction: EnterNewPasswordPresenterAction?
    func onAction(_ callback: EnterNewPasswordPresenterAction?) {
        self.onAction = callback
    }
    
    init(view: IEnterNewPasswordView,
         email: String,
         key: String) {
        self.view = view
        self.email = email
        self.key = key
    }
}

extension EnterNewPasswordPresenter: IEnterNewPasswordPresenter {
    func backPressed() {
        self.onAction?(.back)
    }
    
    func didChange(password: String) {
        self.password = password
    }
    
    func didChange(confirmPassword: String) {
        self.confirmPassword = confirmPassword
    }
    
    func nextPressed() {
        guard let password = self.password,
            let confirmPassword = self.confirmPassword else { return }
        
        self.view.loadIndication(displayed: true)
        
        self.passwordService.setPassword(email: self.email, password: password, password_confirm: confirmPassword, key: self.key) { [weak self] response in
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
                        self?.onAction?(.next)
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
}
