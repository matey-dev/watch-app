//
//  EmptyCoordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 18.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import Foundation
import UIKit

final class EmptyCoordinator {
    let navigationController: AppNavigationController
    var rootCoordinator: AnyObject?
    
    init(navigationController: AppNavigationController) {
        self.navigationController = navigationController
    }
}

extension EmptyCoordinator: Coordinator {
    func start() {
        self.showEmptyVC()
    }
}

private extension EmptyCoordinator {
    func showEmptyVC() {
        let view = UIViewController()
        self.set(rootView: view)
    }
}
