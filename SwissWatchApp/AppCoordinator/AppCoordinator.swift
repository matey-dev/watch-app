//
//  AppCoordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinatorListenersHolder {
    static let shared = AppCoordinatorListenersHolder()
    private init() {}
    var loginListener: (() -> Void)?
    var logOutListener: (() -> Void)?
}

final class AppCoordinator {
    private var rootViewCallback: MainRootViewCallback?
    var childCoordinators = [Coordinator]()
    var startSceneCoordinator: AppStartCoordinator?
    
    let tabBarController: AppTabBarController
    let listenersHolder = AppCoordinatorListenersHolder.shared
    
    var services: Services?
    let coordinatorObservables: CoordinatorObservables
    
    init(tabBarController: AppTabBarController = AppTabBarController(),
         coordinatorObservables: CoordinatorObservables = CoordinatorObservables()) {
        
        self.tabBarController = tabBarController
        self.coordinatorObservables = coordinatorObservables
        
        self.coordinatorObservables.switchTabObservable.add(observer: self)
        self.initListenersHolder()
//        self.tabBarController.set(cart: self.services.cart)
    }
    
    func configureSellerCoordinators() {
        let services = ServiceMaker.compose(userType: .seller)
        self.services = services
        self.childCoordinators = AppCoordinatorsFactory.makeSellerItems(services: services,
                                                                        listenersHolder: self.listenersHolder,
                                                                        tabBarController: self.tabBarController,
                                                                        coordinatorObservables: coordinatorObservables)
        self.tabBarController.set(rootViews: self.childCoordinators.map { $0.navigationController })
        self.tabBarController.userType = .seller
        self.tabBarController.coordinatorObservables = coordinatorObservables
        AnimationStorage.shared.set(userType: .seller)
    }
    
    func configureDealerCoordinators() {
        let services = ServiceMaker.compose(userType: .dealer)
        self.services = services
        self.childCoordinators = AppCoordinatorsFactory.makeDealerItems(services: services,
                                                                        listenersHolder: self.listenersHolder,
                                                                        tabBarController: self.tabBarController,
                                                                        coordinatorObservables: coordinatorObservables)
        self.tabBarController.set(rootViews: self.childCoordinators.map { $0.navigationController })
        self.tabBarController.userType = .dealer
        AnimationStorage.shared.set(userType: .dealer)
    }
    
    func didFinishLaunchingStartScene(userType: UserType) {
        self.startSceneCoordinator = nil
        switch userType {
        case .seller:
            self.configureSellerCoordinators()
        case .dealer:
            self.configureDealerCoordinators()
        }
        self.childCoordinators.forEach { $0.start() }
        self.rootViewCallback?(self.tabBarController)
        
//        PushService.shared.registerForPushNotifications()
        PushService.shared.handlePushRegister()
        //Note:-- Needs to send test push
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            PushService.shared.sendCurrentTokenToBack()
//        }
    }
    
    private func switchNavigationTab(index: Int) {
        onMainQueue {
            self.tabBarController.selectedIndex = index
        }
    }
    
    private func initListenersHolder() {
        self.listenersHolder.loginListener = { [weak self] in
            onMainQueue {
                self.map {
                    $0.switchNavigationTab(index: 0)
                }
            }
        }
        
        self.listenersHolder.logOutListener = { [weak self] in
            onMainQueue {
                self.map {
                    $0.switchNavigationTab(index: 0)
                }
                self?.services.map {
                    $0.authManager.signOut()
                }
                self?.childCoordinators.forEach { coordinator in
                    self?.removeChildCoordinator(coordinator)
                }
                self?.start(withSplashScreen: false)
            }
        }
    }
    
    func handleDeeplink(_ deeplinkType: DeeplinkType) {
        switch deeplinkType {
        case .lot(let lotId):
            showBuyerLot(lotId: lotId)
        case .bid(let lotId):
            showSellerLot(lotId: lotId)
        }
    }
    
    func showSellerLot(lotId: Int) {
        if let yourPostsCoordinator = self.childCoordinators
            .first(where: {
                guard let catalogCoordinator = ($0 as? CatalogCoordinator) else { return false }
                return catalogCoordinator.catalogType == .yourCatalogue
            }) as? CatalogCoordinator {
            yourPostsCoordinator.showSellerLotApn(lotId)
            DeepLinkManager.shared.deeplinkType = nil
        }
    }
    
    func showBuyerLot(lotId: Int) {
        if let yourPostsCoordinator = self.childCoordinators
            .first(where: {
                guard let catalogCoordinator = ($0 as? CatalogCoordinator) else { return false }
                return catalogCoordinator.catalogType == .newSubmissions
            }) as? CatalogCoordinator {
            yourPostsCoordinator.showDealerLotApn(lotId)
            DeepLinkManager.shared.deeplinkType = nil
        }
    }
}

extension AppCoordinator: MainCoordinator {
    func rootViewListener(_ callback: MainRootViewCallback?) {
        self.rootViewCallback = callback
    }
    
    func start() {
        self.start(withSplashScreen: true)
    }
    
    func start(withSplashScreen: Bool) {
        let startCoordinator = AppStartCoordinator(navigationController: AppNavigationController(),
                                                   withSplashScreen: withSplashScreen)
        self.rootViewCallback?(startCoordinator.navigationController)
        startCoordinator.start()
        startCoordinator.onStartSceneDidFinishAction = { [weak self] userType in
            self?.didFinishLaunchingStartScene(userType: userType)
        }
        
        self.startSceneCoordinator = startCoordinator
    }
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        guard
            !self.childCoordinators
                .contains(where: { $0 === coordinator })
            else { return }
        
        self.childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        guard
            !self.childCoordinators.isEmpty
            else { return }
        
        self.childCoordinators.removeAll(where: { $0 === coordinator })
    }
}

extension AppCoordinator: Observer {
    func onChanged<Item>(_ item: Item) {
        (item as? TabBarMessage)
            .map { message in
                switch message {
                case .showFirstWithDealyAndRefresh:
                    onMainQueue {
                        // if scrolToTop is true, crash!!! Need to research
                        self.updateYourPosts(scrollToTop: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.switchNavigationTab(index: 0)
                        }
                    }
                case .showFirstImmediately:
                    onMainQueue {
                        self.switchNavigationTab(index: 0)
                    }
                }
        }
        
        (item as? TabBarTags)
            .map {
                self.switchNavigationTab(index: $0.rawValue)
        }
    }
}

private extension AppCoordinator {
    func updateYourPosts(scrollToTop: Bool = false) { // seller only, update when back from add post flow
        let yourPostsCoordinator = self.childCoordinators
            .first(where: {
                guard let catalogCoordinator = ($0 as? CatalogCoordinator) else { return false }
                return catalogCoordinator.catalogType == .yourCatalogue
            })
        let catalogView = yourPostsCoordinator?.navigationController.viewControllers.first(where: { $0 is CatalogView }) as? ICatalogView
        catalogView?.presenter.refreshData(andShowFirst: scrollToTop)
    }
}
