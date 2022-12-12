//
//  AppCoordinatorsFactory.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum AppCoordinatorsFactory {
    static func makeSellerItems(services: Services,
                                listenersHolder: AppCoordinatorListenersHolder,
                                tabBarController: AppTabBarController,
                                coordinatorObservables: CoordinatorObservables) -> [Coordinator] {
        
        let yourCatalogue = CatalogCoordinator(catalogType: .yourCatalogue,
                                               userType: .seller,
                                               navigationController: AppNavigationController(tabBarTag: .yourCatalogue,
                                                                                             userType: .seller,
                                                                                             large: false),
                                               tabBarController: tabBarController,
                                               catalogAPIService: services.catalogAPIService,
                                               archiveAPIService: services.archiveAPIService,
                                               appraisalsAPIService: services.apraisalsAPIService,
                                               authManager: services.authManager,
                                               profileApiService: services.profileApiService,
                                               listenersHolder: listenersHolder)
        
        let archive = ArchiveCoordinator(catalogType: .yourCatalogue,
                                       userType: .seller,
                                       navigationController: AppNavigationController(tabBarTag: .archive,
                                                                                     userType: .seller,
                                                                                     large: false),
                                       tabBarController: tabBarController,
                                       catalogAPIService: services.catalogAPIService,
                                       archiveAPIService: services.archiveAPIService,
                                       appraisalsAPIService: services.apraisalsAPIService,
                                       authManager: services.authManager,
                                       profileApiService: services.profileApiService,
                                       listenersHolder: listenersHolder)
        
//        let addLot = AddLotCoordinator(navigationController: AppNavigationController(tabBarTag: .addLot,
//                                                                                     large: false),
//                                       addLotService: services.addLotService,
//                                       coordinatorObservables: coordinatorObservables)
        
        let empty = EmptyCoordinator(navigationController: AppNavigationController(tabBarTag: .addLot))
//        let profile = ProfileCoordinator(state: .seller,
//                                         navigationController: AppNavigationController(tabBarTag: .profile,
//                                                                                       large: false),
//                                         authManager: services.authManager,
//                                         profileApiService: services.profileApiService,
//                                         listenersHolder: listenersHolder)
        
        return [yourCatalogue, empty, archive]
    }
    
    static func makeDealerItems(services: Services,
                                listenersHolder: AppCoordinatorListenersHolder,
                                tabBarController: AppTabBarController,
                                coordinatorObservables: CoordinatorObservables) -> [Coordinator] {
        
        let newSubmissions = CatalogCoordinator(catalogType: .newSubmissions,
                                                userType: .dealer,
                                                navigationController: AppNavigationController(tabBarTag: .newSubmissions,
                                                                                              userType: .dealer,
                                                                                              large: false),
                                                tabBarController: tabBarController,
                                                catalogAPIService: services.catalogAPIService,
                                                archiveAPIService: services.archiveAPIService,
                                                appraisalsAPIService: services.apraisalsAPIService,
                                                authManager: services.authManager,
                                                profileApiService: services.profileApiService,
                                                listenersHolder: listenersHolder)
        
        let appraisals = CatalogCoordinator(catalogType: .appraisals,
                                            userType: .dealer,
                                            navigationController: AppNavigationController(tabBarTag: .appraisals,
                                                                                               large: false),
                                            tabBarController: tabBarController,
                                            catalogAPIService: services.catalogAPIService,
                                            archiveAPIService: services.archiveAPIService,
                                            appraisalsAPIService: services.apraisalsAPIService,
                                            authManager: services.authManager,
                                            profileApiService: services.profileApiService,
                                            listenersHolder: listenersHolder)
        
        let profile = ProfileCoordinator(state: .dealer,
                                         navigationController: AppNavigationController(tabBarTag: .profile, large: false),
                                         authManager: services.authManager,
                                         profileApiService: services.profileApiService, archiveAPIService: services.archiveAPIService,
                                         listenersHolder: listenersHolder)
        
        return [newSubmissions, appraisals, profile]
    }
}
