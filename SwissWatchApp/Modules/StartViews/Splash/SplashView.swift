//
//  SplashView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol ISplashView: AnyObject {
    
}

class SplashView: BaseViewController {
    var presenter: ISplashPresenter!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.appNavigationController?.setNavigationBar(hidden: true)
        self.presenter.onViewDidAppear()
    }
    
    func bind(presenter: ISplashPresenter) {
        self.presenter = presenter
    }
}

extension SplashView: ISplashView {
    
}
