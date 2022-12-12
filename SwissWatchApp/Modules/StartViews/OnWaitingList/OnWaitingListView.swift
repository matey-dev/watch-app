//
//  OnWaitingListView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol IOnWaitingListView {
    
}

class OnWaitingListView: BaseViewController {
    var presenter: IOnWaitingListPresenter!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.appNavigationController?.setNavigationBar(hidden: true)
    }
    
    @IBAction func SignInButtonAction(_ sender: Any) {
        self.presenter.onSignInAction()
    }
}

extension OnWaitingListView: IOnWaitingListView {
    
}
