//
//  CatalogCoordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

final class CatalogCoordinator {
    let navigationController: AppNavigationController
    let tabBarController: AppTabBarController
    var rootCoordinator: AnyObject?
    let catalogAPIService: CatalogAPIService
    let getDealerLotService = DealerLotAPIService()
    let getSellerLotService = SellerLotAPIService()
    let archiveAPIService: CatalogAPIService
    let appraisalsAPIService: CatalogAPIService
    let catalogType: CatalogType
    let userType: UserType
    let authManager: IAuthManager
    let profileApi: ProfileAPIService
    let logOutListener: (() -> Void)?
    
    var filters: [Catalog.Filter] = [Catalog.Filter(id: 5, label: "Expired")]
    
    init(catalogType: CatalogType,
         userType: UserType,
         navigationController: AppNavigationController,
         tabBarController: AppTabBarController,
         catalogAPIService: CatalogAPIService,
         archiveAPIService: CatalogAPIService,
         appraisalsAPIService: CatalogAPIService,
         authManager: IAuthManager,
         profileApiService: ProfileAPIService,
         listenersHolder: AppCoordinatorListenersHolder) {
        
        self.catalogType = catalogType
        self.userType = userType
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.catalogAPIService = catalogAPIService
        self.archiveAPIService = archiveAPIService
        self.appraisalsAPIService = appraisalsAPIService
        self.authManager = authManager
        self.profileApi = profileApiService
        self.logOutListener = listenersHolder.logOutListener
        
        self.subscribeToNotifications()
    }
    
    func subscribeToNotifications() {
        DotNotificationService.shared.observable.add(observer: self)
        PushNotificationService.shared.observable.add(observer: self)
    }
}

extension CatalogCoordinator: Coordinator {
    func start() {
        self.startCatalog()
        if case let .lot(id: lotId) = DeepLinkManager.shared.deeplinkType {
            showDealerLotApn(lotId)
            DeepLinkManager.shared.deeplinkType = nil
        }
        
        if case let .bid(id: lotId) = DeepLinkManager.shared.deeplinkType {
            showSellerLotApn(lotId)
            DeepLinkManager.shared.deeplinkType = nil
        }
    }
    
    func showSellerLotApn(_ lotId: Int, _ completion: (() -> Void)? = nil) {
        self.popToRootView(animated: false)
        getSellerLotService.getLot(with: lotId) { (result) in
            switch result {
            case .success(let sellerLot):
                let lot = Catalog.Lot(sellerLot: sellerLot)
                let view = SellerLotInfoVC(catalogLot: lot)
                view.lot = sellerLot
                view.hidesBottomBarWhenPushed = true
                let presenter = SellerLotPresenter(view: view,
                                                   lot: lot)
                view.bind(presenter: presenter)
                view.onAction { actionType in
                    switch actionType {
                    case .back:
                        self.popView(animated: true)
                    case .backAndReload:
                        self.popView(animated: true)
                        (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
                    }
                }
                
                self.push(view: view, completion)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func showDealerLotApn(_ lotId: Int, _ completion: (() -> Void)? = nil) {
        self.popToRootView(animated: false)
        getDealerLotService.getLot(with: lotId) { (result) in
            switch result {
            case .success(let dealerLot):
                let lot = Catalog.Lot(dealerLot: dealerLot)
                let view = DealerLotView.storyboardInstance()
                let presenter = DealerLotPresenter(view: view,
                                                   lot: lot)
                view.bind(presenter: presenter)
                
                presenter.onAction { actionType in
                    switch actionType {
                    case .bidSuccess: ()
                        (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
                    case .backAndReload:
                        self.popView(animated: true)
                        (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
                    case .back:
                        self.popView(animated: true)
                    }
                }
                
                self.push(view: view, completion)
            case .failure(let error):
                print(error)
            }
        }
        
    }
}

private extension CatalogCoordinator {
    func startCatalog(_ completion: (() -> Void)? = nil) {
        let view = CatalogView.storyboardInstance()
        view.catalogType = self.catalogType
        view.viewMode = .home
        var apiService = self.catalogAPIService
        if self.catalogType == .appraisals {
            apiService = self.appraisalsAPIService
        }
        
        let presenter = CatalogPresenter(view: view,
                                         userType: self.userType,
                                         catalogType: self.catalogType,
                                         catalogAPIService: apiService, archiveAPIService: self.archiveAPIService, viewMode: .home)
        self.rootCoordinator = presenter
        view.bind(presenter: presenter)
        view.userType = self.userType
        
        presenter.onAction { [weak self] actionType in
            guard let self = self else { return }
            switch actionType {
            case .didSelectLot(let lot):
                switch self.userType {
                case .seller:
                    self.showSellerLot(lot)
                case .dealer:
                    self.showDealerLot(lot)
                }
            case .archiveButtonPressed:
                self.showProfileMenuView()
            case .filterButtonPressed(let filter):
                self.showFilter(filter)
            }
        }
        
        self.set(rootView: view, completion)
    }
    
    func showArchive(filter: Catalog.Filter, _ completion: (() -> Void)? = nil) {
        let view = ArchiveView.storyboardInstance()
        let presenter = ArchivePresenter(view: view,
                                         userType: self.userType,
                                         filter: filter,
                                         archiveAPIService: self.archiveAPIService)
        view.bind(presenter: presenter)
        view.filter = filter
        view.userType = userType
        
        presenter.onAction { [weak self] actionType in
            switch actionType {
            case .backAndReload:
                self?.popToRootView(animated: true)
                (self?.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
            }
        }
        
        self.push(view: view, completion)
    }
    
    
    func showSellerLot(_ lot: Catalog.Lot, _ completion: (() -> Void)? = nil) {
//        let view = SellerLotView.storyboardInstance()
        
        let service = SellerLotAPIService()
        service.getLot(with: lot.id) { (result) in
            switch result {
            case .success(let sellerLot):
                let view = SellerLotInfoVC(catalogLot: lot)
                view.lot = (lot.id < 0) ? tempLot : sellerLot
                view.hidesBottomBarWhenPushed = true
                let presenter = SellerLotPresenter(view: view,
                                                   lot: lot)
                view.bind(presenter: presenter)
                view.onAction { actionType in
                    switch actionType {
                    case .back:
                        self.popView(animated: true)
                    case .backAndReload:
                        self.popView(animated: true)
                        (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
                    }
                }
                
                self.push(view: view, completion)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func showDealerLot(_ lot: Catalog.Lot, _ completion: (() -> Void)? = nil) {
        let view = DealerLotView.storyboardInstance()
        let presenter = DealerLotPresenter(view: view,
                                           lot: lot)
        view.bind(presenter: presenter)
        
        presenter.onAction { actionType in
            switch actionType {
            case .bidSuccess: ()
                (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
            case .backAndReload:
                self.popView(animated: true)
                (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
            case .back:
                self.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    func showFilter(_ filter: DealerFilter?, _ completion: (() -> Void)? = nil) {
        let view = FilterView.storyboardInstance()
        view.filter = filter
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.onAction { actionType in
            switch actionType {
            case .willDismiss: ()
            case .clear:
                (self.rootCoordinator as? CatalogPresenter)?.apply(filter: nil)
            case .applyFilter(let filter):
                (self.rootCoordinator as? CatalogPresenter)?.apply(filter: filter)
            }
        }
        self.tabBarController.present(view, animated: true, completion: nil)
    }
    
    func showProfileMenuView() {
        let view = ProfileView.storyboardInstance()
        view.hidesBottomBarWhenPushed = true
        let presenter = ProfilePresenter(view: view,
                                         profileApi: self.profileApi)
        
        view.bind(presenter: presenter)
        view.state = self.userType
        
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
        
        self.push(view: view, nil)
    }
    
    func showNotificationSetting() {
        let view = NotificationVC.storyboardInstance()
        self.push(view: view)
    }
    
    func showEditProfile() {
        let view = EditProfileVC.storyboardInstance()
        let presenter = ProfilePresenter(view: view,
                                         profileApi: self.profileApi)
        
        view.bind(presenter: presenter)
        presenter.onAction = { action in
            switch action {
            case .changePassword(let email):
                self.showChangePassword(email: email)
            case .back:
                self.popView(animated: true)
            default:
                break
            }
        }
        view.state = self.userType
        self.push(view: view)
    }
    
    func showChangePassword(email: String, _ completion: (() -> Void)? = nil) {
        let view = ChangePasswordView.storyboardInstance()
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
    
    func showLegalInfo() {
        let view = LegalInfoVC.storyboardInstance()
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
}

extension CatalogCoordinator: Observer {
    func onChanged<Item>(_ item: Item) {
        if let message = item as? DotNotificationService.Message {
            switch message {
            case .archive(let active):
                (self.rootCoordinator as? CatalogPresenter)?.setArchiveNotification(active: active)
            case .appraisal(let active):
                self.setTabBarIcon(notificatedState: active)
            case .catalog(let active):
                self.setTabBarIcon(notificatedState: active)
            }
        } else if let message = item as? PushNotificationService.Message {
            switch message {
            case .bidWins:
//                if self.catalogType == .appraisals {
                    (self.rootCoordinator as? CatalogPresenter)?.refreshData(andShowFirst: false)
//                }
            }
        }
    }
}

var tempLot: SellerLot?
