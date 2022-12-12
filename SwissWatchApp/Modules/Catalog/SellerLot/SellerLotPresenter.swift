//
//  LotPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol ISellerLotPresenter {
    func onViewDidLoad()
    func onViewWillAppear()
    
    func doneButtonOnSoldState()
    func approveAppraisal(_ appraisal: Appraisal)
    func deleteCurrentLot()
}

typealias SellerLotPresenterAction = ((SellerLotPresenterActionType) -> Void)
enum SellerLotPresenterActionType {
    case back, backAndReload
}

class SellerLotPresenter {
    private let catalogLot: Catalog.Lot
    private var lot: SellerLot?
    private let lotAPIService = SellerLotAPIService()
    private let deleteLotAPIService = DeleteLotAPIService()
    
    unowned var view: ISellerLotView
    private var vc: IBaseViewController? {
        return self.view as? IBaseViewController
    }
    
    var onAction: SellerLotPresenterAction?
    func onAction(_ callback: SellerLotPresenterAction?) {
        self.onAction = callback
    }
    
    init(view: ISellerLotView,
         lot: Catalog.Lot) {
        self.view = view
        self.catalogLot = lot
    }
}

private extension SellerLotPresenter {
    func getLot() {
        let id = catalogLot.id
        self.lotAPIService.getLot(with: id) { [weak self] result in
            switch result {
            case .success(let lot): ()
                self?.lot = lot
                self?.view.fillWithLot(lot)
            case .failure(let failure):
                self?.vc?.showError(title: "Error", message: failure.localizedDescription)
            }
        }
    }
    
    func choose(betId: Int) {
        guard let lotId = self.lot?.id else { return }
        self.view.loadIndication(displayed: true)
        
        self.lotAPIService.chooseBet(betId: betId, lotId: lotId) { [weak self] result in
            self?.view.loadIndication(displayed: false)
            
            switch result {
            case .success:
                self?.view.betSuccessfullyChosen()
                self?.getLot()
            case .failure(let failure):
                (failure as? InternalError)
                    .map { error in
                        switch error {
                        case .serverError(let statusCode):
                            if statusCode == 200 {
                                self?.view.betSuccessfullyChosen()
                                self?.view.setShouldReload(true)
                                self?.getLot()
                            } else {
                                self?.vc?.showError(title: "Error", message: failure.localizedDescription)
                            }
                        default:
                            self?.vc?.showError(title: "Error", message: failure.localizedDescription)
                        }
                        
                }
            }
        }
    }
}

extension SellerLotPresenter: ISellerLotPresenter {
    func onViewDidLoad() {
        self.view.onViewDidLoad(self.catalogLot)
        self.getLot()
    }
    
    func onViewWillAppear() {
        self.view.onViewWillAppear()
    }
    
    func doneButtonOnSoldState() {
        self.onAction?(.back)
    }
    
    func approveAppraisal(_ appraisal: Appraisal) {
        appraisal.id.map { self.choose(betId: $0) }
    }
    
    func deleteCurrentLot() {
        self.deleteLotAPIService.deleteLot(with: self.catalogLot.id) { [weak self] result in
            switch result {
            case .success(_):
                self?.onAction?(.backAndReload)
            case .failure(let failure):
                self?.vc?.showError(title: "Error",
                                    message: failure.localizedDescription)
            }
        }
    }
}
