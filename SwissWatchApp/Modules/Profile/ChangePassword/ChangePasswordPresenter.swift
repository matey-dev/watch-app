//
//  ChangePasswordPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol IChangePasswordPresenter {
    func onViewDidLoad()
    func onViewWillAppear()
    
    func didChange(oldPassword: String)
    func didChange(newPassword: String)
    func didChange(newPasswordConfirm: String)
    
    func confirmPressed()
}

typealias ChangePasswordPresenterAction = ((ChangePasswordPresenterActionType) -> Void)
enum ChangePasswordPresenterActionType {
    case successDone
}

class ChangePasswordPresenter {
    private let passwordService = PasswordAPIService()
    private let email: String
    private var oldPassword: String = ""
    private var newPassword: String = ""
    private var newPasswordConfirm: String = ""
    
    unowned var view: IChangePasswordView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: ChangePasswordPresenterAction?
    func onAction(_ callback: ChangePasswordPresenterAction?) {
        self.onAction = callback
    }
    
    init(view: IChangePasswordView,
         email: String) {
        self.view = view
        self.email = email
    }
}

extension ChangePasswordPresenter: IChangePasswordPresenter {
    func onViewDidLoad() {
        self.view.onViewDidLoad(email: self.email)
    }
    
    func onViewWillAppear() {
        self.view.onViewWillAppear()
    }
    func didChange(oldPassword: String) {
        self.oldPassword = oldPassword
        self.view.setLoginButtonDisabled(self.isShouldConfirmButtonBecomeInactive())
    }
    
    func didChange(newPassword: String) {
        self.newPassword = newPassword
        self.view.setLoginButtonDisabled(self.isShouldConfirmButtonBecomeInactive())
    }
    
    func didChange(newPasswordConfirm: String) {
        self.newPasswordConfirm = newPasswordConfirm
        self.view.setLoginButtonDisabled(self.isShouldConfirmButtonBecomeInactive())
    }
    
    func confirmPressed() {
        self.view.loadIndication(displayed: true)
        
        self.passwordService.changePassword(oldPassword: self.oldPassword,
                                            newPassword: self.newPassword,
                                            newPasswordConfirm: self.newPasswordConfirm) { [weak self] response in
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
                        self?.onAction?(.successDone)
                    }
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
}

private extension ChangePasswordPresenter {
    func isShouldConfirmButtonBecomeInactive() -> Bool {
        return self.newPassword.isEmpty || self.newPasswordConfirm.isEmpty
    }
}
