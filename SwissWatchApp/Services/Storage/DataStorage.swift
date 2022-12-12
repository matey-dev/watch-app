//
//  DataStorage.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/31/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias DataStorageServiceUpdateCompletionHandler = ((DataStorageServiceUpdateType) -> Void)
enum DataStorageServiceUpdateType {
    case success
    case onWaitingList
}

protocol IDataStorageService {
    func updateLots(_ completion: DataStorageServiceUpdateCompletionHandler?)
    func updateLotsArchive(_ completion: DataStorageServiceUpdateCompletionHandler?)
}

class DataStorageService {
    private var userHavePermissions: Bool = true
    private var userType: UserType
    
    private var catalogAPIService: CatalogAPIService
    private var catalogAPIServiceArchive: CatalogAPIService
    
    var lots: [Catalog.Lot] = []
    var lotsArchive: [Catalog.Lot] = []
    
    init(userType: UserType) {
        self.userType = userType
        self.catalogAPIService = CatalogAPIService(userType: self.userType, isArchive: false)
        self.catalogAPIServiceArchive = CatalogAPIService(userType: self.userType, isArchive: true)
    }
}

extension DataStorageService: IDataStorageService {
    func updateLots(_ completion: DataStorageServiceUpdateCompletionHandler?) {
        guard self.userHavePermissions else {
            completion?(.onWaitingList)
            return
        }
        self.catalogAPIService.getList { [weak self] listResult in
            switch listResult {
            case .success(let listSuccess):
                #warning("TODO: process received data")
                completion?(.success)
            case .failure(let listFailure):
                (listFailure as? InternalError)
                    .map { error in
                        if error == .userOnWaitingList {
                            self?.userHavePermissions = false
                            completion?(.onWaitingList)
                        }
                }
            }
        }
    }
    
    func updateLotsArchive(_ completion: DataStorageServiceUpdateCompletionHandler?) {
        guard self.userHavePermissions else {
            completion?(.onWaitingList)
            return
        }
        self.catalogAPIServiceArchive.getList { [weak self] listResult in
            switch listResult {
            case .success(let listSuccess):
                #warning("TODO: process received data")
                completion?(.success)
            case .failure(let listFailure):
                (listFailure as? InternalError)
                    .map { error in
                        if error == .userOnWaitingList {
                            self?.userHavePermissions = false
                            completion?(.onWaitingList)
                        }
                    }
            }
        }
    }
}

private extension DataStorageService {
    
}
