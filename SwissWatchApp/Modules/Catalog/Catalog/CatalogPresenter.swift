//
//  CatalogPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol ICatalogPresenter {
    var catalogType: CatalogType { get }
    func archiveButtonPressed()
    func filterButtonPressed()
    
    func onViewDidLoad()
    func onViewWillAppear()
    
    func preload(after: Int)
    func refreshData(andShowFirst showForst: Bool)
    
    func deleteLot(id: Int, completion: (() -> Void)?)
    func selectedLot(_ lot: Catalog.Lot)
    
    func apply(filter: DealerFilter?)
  
    func setArchiveNotification(active: Bool)
}

// seller - yourCatalogue
// dealer - newSubmissions, appraisals
enum CatalogType {
    case yourCatalogue, newSubmissions, appraisals
    var title: String {
        let title: String
        switch self {
        case .appraisals:
            title = "Appraisals"
        case .newSubmissions:
            title = "New Submissions"
        case .yourCatalogue:
            title = "Your Posts"
        }
        return title
    }
}

typealias CatalogPresenterAction = ((CatalogPresenterActionType) -> Void)
enum CatalogPresenterActionType {
    case didSelectLot(_ lot: Catalog.Lot)
    case archiveButtonPressed
    case filterButtonPressed(DealerFilter?)
}

class CatalogPresenter {
    let catalogType: CatalogType
    private let catalogAPIService: CatalogAPIService
    private let deleteLotAPIService = DeleteLotAPIService()
    private let archiveAPIService: CatalogAPIService
    private let userType: UserType
    private let catalogViewMode: CatalogViewMode
    unowned var view: ICatalogView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: CatalogPresenterAction?
    func onAction(_ callback: CatalogPresenterAction?) {
        self.onAction = callback
    }

    let archivefilter: Catalog.Filter = Catalog.Filter(id: 5, label: "Expired")
    
    init(view: ICatalogView,
         userType: UserType,
         catalogType: CatalogType,
         catalogAPIService: CatalogAPIService,
         archiveAPIService: CatalogAPIService, viewMode: CatalogViewMode) {
        self.catalogType = catalogType
        self.catalogAPIService = catalogAPIService
        self.archiveAPIService = archiveAPIService
        self.view = view
        self.userType = userType
        self.view.catalogType = catalogType
        self.catalogViewMode = viewMode
    }
    
    private var filter: DealerFilter?
}

private extension CatalogPresenter {
    func getList(isRefresh: Bool = false,
                 after: Int? = nil,
                 dealerFilter: DealerFilter.Selected? = nil) {
        let perPage = 50
        var page: Int?
        after.map { after in
            let lastPage = after/perPage
            page = lastPage + 1
        }
        
        if isRefresh {
            page = 1
        }
        if catalogViewMode == .home {
            self.catalogAPIService.getList(perPage: perPage,
                                           page: page,
                                           dealerFilter: dealerFilter) { [weak self] result in
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
        } else {
            
            self.archiveAPIService.getList(filterId: self.archivefilter.id,
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
}

extension CatalogPresenter: ICatalogPresenter {
    func archiveButtonPressed() {
        self.onAction?(.archiveButtonPressed)
    }
    
    func filterButtonPressed() {
        self.onAction?(.filterButtonPressed(self.filter))
    }
    
    func onViewDidLoad() {
        self.view.onViewDidLoad()
        self.getList()
    }
    
    func onViewWillAppear() {
        self.view.onViewWillAppear()
    }
    
    func refreshData(andShowFirst showForst: Bool) {
        self.getList(isRefresh: true)
        if showForst {
            self.view.scrollToTop()
        }
    }
    
    func preload(after: Int) {
        self.getList(after: after)
    }
    
    func deleteLot(id: Int, completion: (() -> Void)?) {
        self.deleteLotAPIService.deleteLot(with: id) { [weak self] result in
            switch result {
            case .success(let success):
                completion?()
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
    
    func selectedLot(_ lot: Catalog.Lot) {
        self.onAction?(.didSelectLot(lot))
    }
    
    func apply(filter: DealerFilter?) {
        self.filter = filter
        self.getList(isRefresh: true, dealerFilter: filter?.selected)
    }
  
    func setArchiveNotification(active: Bool) {
        self.view.setArchiveButton(notificated: active)
    }
}
