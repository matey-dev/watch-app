//
//  AppScenesFactory.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum AppScenesFactory {
    static func makeIntroSplashScene(_ onViewDidAppearAction: (() -> Void)? = nil) -> UIViewController {
        let view = SplashView.storyboardInstance()
        let presenter = SplashPresenter(view: view)
        presenter.onViewDidAppearAction = onViewDidAppearAction
        view.bind(presenter: presenter)
        return view
    }
}
