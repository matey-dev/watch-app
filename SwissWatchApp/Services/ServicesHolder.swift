//
//  ServicesHolder.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum ServiceMaker {
    static func compose(userType: UserType) -> Services {
        let authManager = AuthManager()
        let profileApiService = ProfileAPIService(userType: userType)
        let catalogAPIService = CatalogAPIService(type: CatalogAPIType.catalog(userType))
        let archiveAPIService = CatalogAPIService(type: CatalogAPIType.archive(userType))
        let apraisalsAPIService = CatalogAPIService(type: CatalogAPIType.appraisals)
        let addLotService = AddLotAPIService()
      
        return Services(authManager: authManager,
                        profileApiService: profileApiService,
                        catalogAPIService: catalogAPIService,
                        archiveAPIService: archiveAPIService,
                        apraisalsAPIService: apraisalsAPIService,
                        addLotService: addLotService)
    }
}

final class Services {
    init(authManager: IAuthManager,
         profileApiService: ProfileAPIService,
         catalogAPIService: CatalogAPIService,
         archiveAPIService: CatalogAPIService,
         apraisalsAPIService: CatalogAPIService,
         addLotService: AddLotAPIService) {
        self.authManager = authManager
        self.profileApiService = profileApiService
        self.catalogAPIService = catalogAPIService
        self.archiveAPIService = archiveAPIService
        self.apraisalsAPIService = apraisalsAPIService
        self.addLotService = addLotService
    }
  
    let authManager: IAuthManager
    let profileApiService: ProfileAPIService
    let catalogAPIService: CatalogAPIService
    let archiveAPIService: CatalogAPIService
    let apraisalsAPIService: CatalogAPIService
    let addLotService: AddLotAPIService
}
