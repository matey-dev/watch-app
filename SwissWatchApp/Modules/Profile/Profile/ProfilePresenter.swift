//
//  ProfilePresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import UIKit

protocol IProfilePresenter {
    func logout()
    func sendProfile(profile: Profile)
    func sendProfile(profile: Profile, image: UIImage?, onSuccess: (()->())?)
    func changePassword()
    func deleteAccount()
    func onViewDidLoad()
    func onViewWillAppear()
    func back()
    func showLegalInfo()
    func showArchiveList()
    func showNotification()
    func editProfile()
}

typealias ProfilePresenterAction = ((ProfilePresenterActionType) -> Void)
enum ProfilePresenterActionType {
    case logout
    case accountDeleted
    case changePassword(email: String)
    case back
    case legalInfo
    case archive
    case notification
    case edit
}

class ProfilePresenter {
    let profileApi: ProfileAPIService
    private var profile: Profile?
    private var profileOnviewDidLoadUpdated: Bool = false
    private var viewLoaded: Bool = false
    
    unowned var view: IProfileView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: ProfilePresenterAction?
    func onAction(_ callback: ProfilePresenterAction?) {
        self.onAction = callback
    }
    
    init(view: IProfileView,
         profileApi: ProfileAPIService) {
        self.view = view
        self.profileApi = profileApi
//        self.getProfile()
    }
}

extension ProfilePresenter: IProfilePresenter {
    
    func logout() {
        self.onAction?(.logout)
    }
    
    func sendProfile(profile: Profile) {
        self.view.loadIndication(displayed: true)
        
        self.profileApi.updateProfile(profile: profile) { [weak self] response in
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
                } else if success.success != nil {
//                    self?.view.removeConfirmButton()
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func sendProfile(profile: Profile, image: UIImage? = nil, onSuccess: (() ->())? = nil) {
        self.view.loadIndication(displayed: true)
        
        self.profileApi.updateProfile(profile: profile, image: image) { [weak self] response in
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
                } else if success.success != nil {
                    onSuccess?()
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func changePassword() {
        guard let email = self.profile?.email else {
            return
        }
        self.onAction?(.changePassword(email: email))
    }
    
    func deleteAccount() {
        self.deleteProfile()
    }
    
    func showLegalInfo() {
        self.onAction?(.legalInfo)
    }
    
    func showArchiveList() {
        self.onAction?(.archive)
    }
    
    func showNotification() {
        self.onAction?(.notification)
    }
    
    func editProfile() {
        self.onAction?(.edit)
    }
    
    func back() {
        self.onAction?(.back)
    }
    
    func onViewDidLoad() {
        self.viewLoaded = true
    }
    
    func onViewWillAppear() {
        getProfile()
//        self.profile.map {
//            self.view.updateWith(profile: $0)
//            self.profileOnviewDidLoadUpdated = true
//        }
    }
}

private extension ProfilePresenter {
    func getProfile() {
        self.profileApi.getProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                let profile = Profile(firstName: success.firstName, lastName: success.lastName, email: success.email, city: success.city, state: success.state, address: success.address, zip: success.zip, companyName: success.companyName
                                      , companyPhone: success.companyPhone, avatar: success.avatar.first?.src)
                self.profile = profile
                if self.viewLoaded {
                    self.view.updateWith(profile: profile)
                }
            case .failure(let failure):
                self.vc?.showError(title: "Error", message: failure.localizedDescription)
            }
        }
    }
    
    func deleteProfile() {
        self.profileApi.deleteProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.onAction?(.accountDeleted)
            case .failure(let failure):
                (failure as? InternalError)
                    .map { error in
                        switch error {
                        case .serverError(let statusCode):
                            if statusCode == 200 {
                                self.onAction?(.accountDeleted)
                            } else {
                                self.vc?.showError(title: "Error", message: failure.localizedDescription)
                            }
                        default:
                            self.vc?.showError(title: "Error", message: failure.localizedDescription)
                        }
                        
                }
            }
        }
    }
}
