//
//  Coordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

// MARK: - Application Coordinator -
protocol MainCoordinator: AnyObject {
    typealias MainRootViewCallback = ((UIViewController) -> Void)
    
    var tabBarController: AppTabBarController { get }
    
    func start()
    
    func rootViewListener(_ callback: MainRootViewCallback?)
    func addChildCoordinator(_ coordinator: Coordinator)
    func removeChildCoordinator(_ coordinator: Coordinator)
}

// MARK: - Module Coordinator -
protocol Coordinator: AnyObject {
    var navigationController: AppNavigationController { get }
    
    func start()
    
    func set(rootView: UIViewController, _ completion: (() -> Void)?)
    func push(view: UIViewController, _ completion: (() -> Void)?)
    
    func popView(animated: Bool)
    func popToRootView(animated: Bool)
    
    func present(view: UIViewController, completion: (() -> Void)?)
    func present(fromView: UIViewController, view: UIViewController, completion: (() -> Void)?)
    func dismissView(animated: Bool, completion: (() -> Void)?)
}

extension Coordinator {
    func setTabBarIcon(notificatedState: Bool) {
        guard let tag = self.navigationController.tag else { return }
        let image = notificatedState ? UIImage(named: tag.notificatedIconName) : UIImage(named: tag.activeIconName)
        onMainQueue {
            if image != self.navigationController.tabBarItem.selectedImage {
                self.navigationController.tabBarItem.selectedImage = image
            }
        }
    }
}

extension Coordinator {
    func set(rootView: UIViewController, _ completion: (() -> Void)? = nil) {
        onMainQueue {
            self.navigationController.setViewControllers([rootView], animated: true)
            completion?()
        }
    }
    
    func push(view: UIViewController, _ completion: (() -> Void)? = nil) {
        onMainQueue {
            self.navigationController.pushViewController(view, animated: true)
            completion?()
        }
    }
    
    func present(view: UIViewController, completion: (() -> Void)? = nil) {
        onMainQueue {
            self.navigationController.present(view, animated: true, completion: completion)
        }
    }
    
    func present(fromView: UIViewController, view: UIViewController, completion: (() -> Void)?) {
        onMainQueue {
            fromView.present(view, animated: true, completion: completion)
        }
    }
    
    func popView(animated: Bool) {
        onMainQueue {
            self.navigationController.popViewController(animated: animated)
        }
    }
    
    func popToRootView(animated: Bool) {
        onMainQueue {
            self.navigationController.popToRootViewController(animated: animated)
        }
    }
    
    func dismissView(animated: Bool, completion: (() -> Void)? = nil) {
        onMainQueue {
            self.navigationController.dismiss(animated: animated, completion: completion)
        }
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        onMainQueue {
            self.navigationController.popToViewController(ofClass: ofClass, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        onMainQueue {
            self.navigationController.popViewControllers(viewsToPop: viewsToPop, animated: animated)
        }
    }
}
