//
//  ArchivePresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/7/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol IArchivePresenter {
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewWillDisappear()
    func refreshData()
    
    func preload(after: Int)
    func filterDidSelect(_ filter: Catalog.Filter)
    func reactivateLot(id: Int, completion: (() -> Void)?)
}

typealias ArchivePresenterAction = ((ArchivePresenterActionType) -> Void)
enum ArchivePresenterActionType {
    case backAndReload
}

class ArchivePresenter {
    private let archiveAPIService: CatalogAPIService
    private let reactivateLotAPIService: ReactivateLotAPIService
    private let userType: UserType
    
    unowned var view: IArchiveView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: ArchivePresenterAction?
    func onAction(_ callback: ArchivePresenterAction?) {
        self.onAction = callback
    }
    
    let filter: Catalog.Filter
    
    init(view: IArchiveView,
         userType: UserType,
         filter: Catalog.Filter,
         archiveAPIService: CatalogAPIService,
         reactivateLotAPIService: ReactivateLotAPIService = ReactivateLotAPIService()) {
        self.archiveAPIService = archiveAPIService
        self.reactivateLotAPIService = reactivateLotAPIService
        self.userType = userType
        self.view = view
        self.filter = filter
    }
}

private extension ArchivePresenter {
    func getList(isRefresh: Bool = false, after: Int? = nil) {
        let perPage = 50
        var page: Int?
        after.map { after in
            let lastPage = after/perPage
            page = lastPage + 1
        }
        
        if isRefresh {
            page = 1
        }
        
        self.archiveAPIService.getList(filterId: self.filter.id,
                                       perPage: perPage,
                                       page: page) { [weak self] result in
            switch result {
            case .success(let success):
                if isRefresh {
                    self?.view.set(lots: success.lots)
                } else {
                    self?.view.append(lots: success.lots)
                }
            case .failure(let failure):
                self?.vc?.showError(title: "Error", message: failure.localizedDescription)
            }
        }
    }
}

extension ArchivePresenter: IArchivePresenter {
    func onViewDidLoad() {
        self.view.onViewDidLoad()
        self.getList()
    }
    
    func onViewWillAppear() {
        self.view.onViewWillAppear()
    }
    
    func onViewWillDisappear() {
        self.view.onViewWillDisappear()
    }
    
    func refreshData() {
        self.getList(isRefresh: true)
    }
    
    func preload(after: Int) {
        self.getList(after: after)
    }
    
    func filterDidSelect(_ filter: Catalog.Filter) {
        self.getList(isRefresh: true)
    }
    
    func reactivateLot(id: Int, completion: (() -> Void)?) {
        self.reactivateLotAPIService.reactivateLot(with: id) { [weak self] result in
            switch result {
            case .success(let success):
                completion?()
                //self?.onAction?(.backAndReload)
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
}
