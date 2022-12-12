//
//  SplashPresenter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol ISplashPresenter {
    func onViewDidAppear()
}

class SplashPresenter {
    unowned var view: ISplashView
    
    var onViewDidAppearAction: (() -> Void)?
    
    init(view: ISplashView) {
        self.view = view
    }
}
#warning("TODO: call from this point try is auth is valid and refresh auth if need")
extension SplashPresenter: ISplashPresenter {
    func onViewDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.onViewDidAppearAction?()
        }
    }
}
