//
//  RecoverPasswordPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/4/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol IRecoverPasswordPresenter {
    func onViewWillAppear()
    func didChange(email: String)
    func nextPressed()
    func backPressed()
}

typealias RecoverPasswordPresenterAction = ((RecoverPasswordPresenterActionType) -> Void)
enum RecoverPasswordPresenterActionType {
    case next(email: String)
    case back
}

class RecoverPasswordPresenter {
    unowned var view: IRecoverPasswordView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    let passwordService = PasswordAPIService()
    
    var email: String
    
    var onAction: RecoverPasswordPresenterAction?
    func onAction(_ callback: RecoverPasswordPresenterAction?) {
        self.onAction = callback
    }
    
    init(view: IRecoverPasswordView, predefinedEmail: String) {
        self.view = view
        self.email = predefinedEmail
    }
}

extension RecoverPasswordPresenter: IRecoverPasswordPresenter {
    func onViewWillAppear() {
        self.view.fillEmail(self.email)
    }
    
    func didChange(email: String) {
        #warning("TODO: check email is valid")
        self.email = email
    }
    
    func nextPressed() {
        self.view.loadIndication(displayed: true)
        
        self.passwordService.resetPassword(email: self.email) { [weak self] response in
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
                } else if success.success != nil {
                    onMainQueue {
                        self.map { self?.onAction?(.next(email: $0.email)) }
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                     message: failure.localizedDescription)
            }
        }
    }
    
    func backPressed() {
        self.onAction?(.back)
    }
}
