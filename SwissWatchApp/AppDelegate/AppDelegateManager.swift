//
//  AppDelegateManager.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Kingfisher

private let cacheSize = 52_428_800 // 50 MB
private let cachePeriod: TimeInterval = 1_209_600.00 // 2 week
private let imagesCountLimit = 50

class AppDelegateManager {
    private var reachabilityManager: ReachabilityManager?
    private let reactivationService = ReactivationAPIService()
    var appCoordinator: AppCoordinator?
    let window: UIWindow
    
    init?(window: UIWindow?) {
        guard let window = window else {
            return nil
        }
        self.window = window
        self.window.backgroundColor = .white
    }
    
    func configure() {
        self.appCoordinator = AppCoordinator()
        self.appCoordinator?.rootViewListener({ [weak self] rootView in
            self?.window.rootViewController = rootView
        })
        
        self.appCoordinator?.start()
        self.window.makeKeyAndVisible()
        
        self.configureKingfisher()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.configureReachabilityManager()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 10...30)) {
            self.runInitReactivationService()
        }
    }
    
    private func configureKingfisher() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = cacheSize
        cache.memoryStorage.config.countLimit = imagesCountLimit
        cache.diskStorage.config.expiration = .seconds(cachePeriod)
    }
    
    private func configureReachabilityManager() {
        self.reachabilityManager = ReachabilityManager()
        self.reachabilityManager?.onChange = { [weak self] connected in
            if !connected {
                self?.showNoInternetConnectionScreen()
            }
        }
    }
    
    private func runInitReactivationService() {
        self.reactivationService.reactivate { [weak self] result in
            switch result {
            case .success(let obj): ()
            obj.success?.message.map { message in
                (UIApplication.shared.delegate as? AppDelegate)?.showAlert(message: message, okTitle: nil)
                }
            case .failure: ()
            }
        }
    }
    
    private func showNoInternetConnectionScreen() {
        self.window.rootViewController.map { vc in
            let view = NoConnectionView.storyboardInstance()
            view.modalPresentationStyle = .overCurrentContext
            view.modalTransitionStyle = .crossDissolve
            if let imagePickerVC = vc.presentedViewController as? UIImagePickerController {
                imagePickerVC.dismiss(animated: true) {
                    vc.present(view, animated: true, completion: nil)
                }
            } else {
                vc.present(view, animated: true, completion: nil)
            }
        }
    }
    
    @discardableResult
    func showNoInternetConnectionScreenIfNeed() -> Bool {
        if !(self.reachabilityManager?.isReachable ?? false) {
            self.showNoInternetConnectionScreen()
            return false
        } else {
            return true
        }
    }
}
