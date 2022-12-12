//
//  OnWaitingListPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias OnWaitingListPresenterAction = ((OnWaitingListPresenterActionType) -> Void)
enum OnWaitingListPresenterActionType {
    case onSignIn
}

protocol IOnWaitingListPresenter {
    func onSignInAction()
}

class OnWaitingListPresenter {
    var onAction: OnWaitingListPresenterAction?
    func onAction(_ callback: OnWaitingListPresenterAction?) {
        self.onAction = callback
    }
}

extension OnWaitingListPresenter: IOnWaitingListPresenter {
    func onSignInAction() {
        self.onAction?(.onSignIn)
    }
}
