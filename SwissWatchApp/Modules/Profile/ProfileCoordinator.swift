//
//  ProfileCoordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

final class ProfileCoordinator {
    private let state: UserType
    
    let navigationController: AppNavigationController
    let authManager: IAuthManager
    let profileApi: ProfileAPIService
    let archiveAPIService: CatalogAPIService
    
    let logOutListener: (() -> Void)?
    
    var filters: [Catalog.Filter] = [Catalog.Filter(id: 5, label: "Expired")]
    
    init(state: UserType,
         navigationController: AppNavigationController,
         authManager: IAuthManager,
         profileApiService: ProfileAPIService,
         archiveAPIService: CatalogAPIService,
         listenersHolder: AppCoordinatorListenersHolder) {
        self.state = state
        
        self.navigationController = navigationController
        self.authManager = authManager
        self.profileApi = profileApiService
        self.archiveAPIService = archiveAPIService
        self.logOutListener = listenersHolder.logOutListener
        
        self.navigationController.setNavigationBar(hidden: true)
    }
}

extension ProfileCoordinator: Coordinator {
    func start() {
        self.showProfileMenuView()
    }
}

private extension ProfileCoordinator {
    func showProfileMenuView() {
        let view = ProfileView.storyboardInstance()
        let presenter = ProfilePresenter(view: view,
                                         profileApi: self.profileApi)
        view.bind(presenter: presenter)
        view.state = self.state
        
        presenter.onAction { [weak self] actionType in
            switch actionType {
            case .logout, .accountDeleted:
                self?.logOutListener?()
            case .changePassword(let email):
                self?.showChangePassword(email: email)
            case .back:
                self?.popView(animated: true)
            case .legalInfo:
                self?.showLegalInfo()
            case .archive:
                self?.showArchiveList()
            case .notification:
                self?.showNotificationSetting()
            case .edit:
                self?.showEditProfile()
            }
        }
        
        self.set(rootView: view)
    }
    
    func showNotificationSetting() {
        let view = NotificationVC.storyboardInstance()
        view.hidesBottomBarWhenPushed = true
        self.push(view: view)
    }
    
    func showEditProfile() {
        let view = EditProfileVC.storyboardInstance()
        view.hidesBottomBarWhenPushed = true
        let presenter = ProfilePresenter(view: view,
                                         profileApi: self.profileApi)
        
        view.bind(presenter: presenter)
        presenter.onAction = { action in
            switch action {
            case .changePassword(let email):
                self.showChangePassword(email: email)
            default:
                break
            }
        }
        view.state = self.state
        self.push(view: view)
    }
    
    func showLegalInfo() {
        let view = LegalInfoVC.storyboardInstance()
        view.hidesBottomBarWhenPushed = true
        view.onAction = { action in
            switch action {
            case .back:
                self.popView(animated: true)
            }
        }
        self.push(view: view)
    }
    
    func showArchiveList() {
        let view = ArchiveListVC.storyboardInstance()
        view.hidesBottomBarWhenPushed = true
        view.filters = self.filters
        view.archiveAPIService = self.archiveAPIService
        view.onAction = { action in
            switch action {
            case .back:
                self.popView(animated: true)
            }
        }
        self.push(view: view)
    }
    
    func showChangePassword(email: String, _ completion: (() -> Void)? = nil) {
        let view = ChangePasswordView.storyboardInstance()
        view.hidesBottomBarWhenPushed = true
        let presenter = ChangePasswordPresenter(view: view,
                                                email: email)
        view.bind(presenter: presenter)
        
        presenter.onAction { actionType in
            switch actionType {
            case .successDone:
                self.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
}
