//
//  UIViewController.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    private static func storyboardInstancePrivate<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        // swiftlint:disable force_cast
        return storyboard.instantiateInitialViewController() as! T
        // swiftlint:enable force_cast
    }
    
    private static func tabBarInstancePrivate() -> UITabBarController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        // swiftlint:disable force_cast
        return storyboard.instantiateInitialViewController() as! UITabBarController
        // swiftlint:enable force_cast
    }
    
    private static func navInstancePrivate() -> UINavigationController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        // swiftlint:disable force_cast
        return storyboard.instantiateInitialViewController() as! UINavigationController
        // swiftlint:enable force_cast
    }
    
    static func storyboardInstance() -> Self {
        return self.storyboardInstancePrivate()
    }
    
    static func tabBarInstance() -> UITabBarController {
        return self.tabBarInstancePrivate()
    }
    
    static func navigationInstance() -> UINavigationController {
        return self.navInstancePrivate()
    }
    
    // MARK: - Child VC
    func add(childViewController: UIViewController,
             toContainerView containerView: UIView? = nil) {
        
        let parentView = containerView ?? self.view
        parentView.map { childViewController.view.frame = $0.bounds }
        
        self.addChild(childViewController)
        parentView?.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
    
    func remove() {
        guard self.parent != nil else {
            return
        }
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

// MARK: - Show Alert View
extension UIViewController {
    func showTextEntryAlert(message: String,
                            title: String,
                            buttonTitle: String,
                            style: UIAlertController.Style = .alert,
                            textPlaceholder: String? = nil,
                            completion: ((String) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.addTextField { $0.placeholder = textPlaceholder }
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default) { [weak alertController] _ in
            alertController?.textFields?.first?.text.map { completion?($0) }
        })
        
        onMainQueue {
            self.present(alertController, animated: true)
        }
    }
    
    func showAlert(message: String,
                   title: String,
                   defaultButtonTitle: String,
                   cancelButtonTitle: String? = nil,
                   completion: ((Bool) -> Void)? = nil) {
        
        onMainQueue {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: defaultButtonTitle,
                                                    style: .default,
                                                    handler: { _ in
                                                        completion?(true)
            }))
            
            if cancelButtonTitle.isNotNil {
                alertController.addAction(UIAlertAction(title: cancelButtonTitle,
                                                        style: .cancel,
                                                        handler: { _ in
                                                            completion?(false)
                }))
            }
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - Show Custom Bottom Sheet View
//extension UIViewController {
//    func showBottomActionSheet(model: ActionSheetModel,
//                               selectedItemHandler: ActionSheetDidSelectAction? = nil) {
//        let view = ActionSheetView.storyboardInstance()
//        let presenter = ActionSheetPresenter(view: view, model: model, selectedItemHandler)
//        view.bind(presenter: presenter)
//        
//        view.modalPresentationStyle = .overFullScreen
//        self.present(view, animated: true, completion: nil)
//    }
//}

// MARK: - Navigation & TabBar
extension UIViewController {
    var appNavigationController: AppNavigationController? {
        return self.navigationController as? AppNavigationController
    }
    
    func addRightBarButton(title: String, textColor: UIColor, action: Selector) {
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        button.tintColor = textColor
        self.navigationItem.rightBarButtonItem = button
    }
}
