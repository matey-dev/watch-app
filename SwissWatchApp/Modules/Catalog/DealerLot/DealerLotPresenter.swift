//
//  DealerLotPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/5/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol IDealerLotPresenter {
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    
    func back()
    func backAndReload()
    
    func flagLot()
    func bid(price: Int)
}

typealias DealerLotPresenterAction = ((DealerLotPresenterActionType) -> Void)
enum DealerLotPresenterActionType {
    case back, backAndReload, bidSuccess
}

class DealerLotPresenter {
    private let catalogLot: Catalog.Lot
    private var lot: DealerLot?
    private let getLotAPIService = DealerLotAPIService()
    private let flagLotAPIService = FlagLotAPIService()
    private let addBetAPIService = AddBetAPIService()
    private var justBid: Bool = false
    
    unowned var view: IDealerLotView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: DealerLotPresenterAction?
    func onAction(_ callback: DealerLotPresenterAction?) {
        self.onAction = callback
    }
    
    init(view: IDealerLotView,
         lot: Catalog.Lot) {
        self.view = view
        self.catalogLot = lot
    }
}

private extension DealerLotPresenter {
    func getLot() {
        self.view.loadIndication(displayed: true)
        self.getLotAPIService.getLot(with: catalogLot.id) { [weak self] result in
            self?.view.loadIndication(displayed: false)
            switch result {
            case .success(let lot):
                guard lot.isValidLot else {
                    self?.backAndReload()
                    return
                }
                self?.lot = lot
                self?.view.fillWithLot(lot)
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
}

extension DealerLotPresenter: IDealerLotPresenter {
    func onViewDidLoad() {
        self.view.onViewDidLoad(self.catalogLot)
        self.getLot()
    }
    
    func onViewWillAppear() {
        self.view.onViewWillAppear()
    }
    
    func onViewDidAppear() {
        self.view.onViewDidAppear()
    }
    
    func onViewWillDisappear() {
        self.view.onViewWillDisappear()
    }
    
    func back() {
        self.justBid ? self.onAction?(.backAndReload) : self.onAction?(.back)
    }
    
    func backAndReload() {
        self.onAction?(.backAndReload)
    }
    
    func flagLot() {
        guard let id = self.lot?.id else { return }
        self.view.loadIndication(displayed: true)
        self.flagLotAPIService.flagLot(with: id) { [weak self] result in
            self?.view.loadIndication(displayed: false)
            switch result {
            case .success:
                self?.getLot()
            case .failure(let failure):
                self?.getLot()
                #warning("TODO: make errors handling when done on be side")
//                self?.vc?.showError(title: "Error",
//                                    message: failure.localizedDescription)
            }
        }
    }
    
    func bid(price: Int) {
        guard let id = self.lot?.id else { return }
        self.view.loadIndication(displayed: true)
        self.addBetAPIService.addBetToLot(with: id, bet: price) { [weak self] result in
            self?.view.loadIndication(displayed: false)
            switch result {
            case .success:
                self?.justBid = true
                self?.onAction?(.bidSuccess)
                self?.getLot()
            case .failure(let failure):
                self?.getLot()
                #warning("TODO: make errors handling when done on be side")
//                self?.vc?.showError(title: "Error",
//                                    message: failure.localizedDescription)
            }
        }
    }
}
