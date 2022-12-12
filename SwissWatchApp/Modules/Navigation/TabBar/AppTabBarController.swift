//
//  AppTabBarController.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
//swiftlint:disable all
enum TabBarMessage: Int {
    case showFirstWithDealyAndRefresh = 0
    case showFirstImmediately = 1
}

// MARK: - AppTabBarController -

private let kBarHeight: CGFloat = 52.0
private let kBarCornerRadius: CGFloat = 15.0

class AppTabBarController: UITabBarController, UITabBarControllerDelegate {
    var userType: UserType?
//    private var roundShadowView: RoundShadowView?
//    private var roundShadowViewVerticalOffset: CGFloat = 0.0
    var coordinatorObservables: CoordinatorObservables?
    override func viewDidLoad() {
        super.viewDidLoad()
//        if #available(iOS 13.0, *) { self.roundShadowViewVerticalOffset = 3.0 }
//        self.initShadowView()
        self.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureAppearance()
//        self.makeCornered()
        self.configureTabBarItems()
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        let safeAreaBottomInset = self.tabBar.safeAreaInsets.bottom
//        tabBar.frame.size.height = kBarHeight + safeAreaBottomInset
//        tabBar.frame.origin.y = view.frame.height - (kBarHeight + safeAreaBottomInset)
//
//        self.setFrameOfShadowView()
//    }
    
    var addLotNavigationVC: UINavigationController = UINavigationController()
    
    func set(rootViews: [UIViewController]) {
//        addLotNavigationVC = rootViews[1] as! UINavigationController
//        rootViews[1] = UINavigationController(rootViewController: UIViewController())
        self.setViewControllers(rootViews, animated: true)
//        self.tabBar.items?[1].image = UIImage(named: ImageNames.InactiveBarIconNames.lotAddind)
//        self.tabBar.items?[1].selectedImage = UIImage(named: ImageNames.ActiveBarIconNames.lotAddind)
//        self.tabBar.items?[1].title = TabBarTags.addLot.title
        self.tabBar.items?.forEach({ (item) in
            item.setTitleTextAttributes([.foregroundColor: UIColor(hex: "#101E29"),
                                         .font: UIFont(name: FontNames.Inter.regular, size: 11)!], for: .selected)
            item.setTitleTextAttributes([.foregroundColor: UIColor(hex: "#8F9599"),
                                         .font: UIFont(name: FontNames.Inter.regular, size: 11)!], for: .normal)
            
        })
        self.tabBar.tintColor = UIColor(hex: "#101E29")
        self.tabBar.unselectedItemTintColor = UIColor(hex: "#8F9599")
        
    }
    
    // MARK: - selected index actions
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let userType = self.userType,
            userType == .seller else { return }
//        if item == tabBar.items?[safe: 1] {
//            self.roundShadowView?.isHidden = true
//        } else {
//            self.roundShadowView?.isHidden = false
//        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let userType = self.userType,
            userType == .seller else { return true}
        if let index = viewControllers?.firstIndex(of: viewController), index == 1 {
            let services = ServiceMaker.compose(userType: .seller)
            let addLot = AddLotCoordinator(navigationController: AppNavigationController(tabBarTag: .addLot,
                                                                                         large: false),
                                           addLotService: services.addLotService,
                                           coordinatorObservables: coordinatorObservables ?? CoordinatorObservables())
            
            
            addLotNavigationVC = addLot.navigationController as UINavigationController
            addLotNavigationVC.modalPresentationStyle = .overFullScreen
            
            addLot.start()
            self.present(addLotNavigationVC, animated: true, completion: nil)
//            addLotNavigationVC.modalPresentationStyle = .overFullScreen
//            self.present(addLotNavigationVC, animated: true, completion: nil)
            return false
        } else {
            return true
        }
        
    }
    
    override var selectedIndex: Int {
        didSet {
            guard let userType = self.userType,
                userType == .seller else { return }
//            if self.selectedIndex == 1 {
//                self.roundShadowView?.isHidden = true
//            } else {
//                self.roundShadowView?.isHidden = false
//            }
        }
    }
}

// MARK: - private -

private let itemIconInset: CGFloat = 7.0

private extension AppTabBarController {
    func configureTabBarItems() {
        guard userType == .dealer else {
            return
        }
        self.viewControllers?.forEach {
            $0.tabBarItem.selectedImage = $0.tabBarItem.selectedImage?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: itemIconInset, left: 0, bottom: -itemIconInset, right: 0)
        }
    }
    
    func configureAppearance() {
        let appearance = UITabBar.appearance()
        appearance.shadowImage = UIImage()
//        appearance.backgroundImage = UIImage()
//        appearance.backgroundColor = Colors.white_95opacity
        appearance.isTranslucent = false
        
//        let blurredView = UIToolbar(frame: self.tabBar.bounds)
//        blurredView.alpha = 0.3
//        blurredView.barStyle = .blackTranslucent
//        self.tabBar.insertSubview(blurredView, at: 0)
        
//        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
//        let blurView = UIVisualEffectView(effect: blur)
//        self.tabBar.insertSubview(blurView, at: 0)
    }
    
//    func makeCornered() {
//        self.tabBar.layer.masksToBounds = true
//        self.tabBar.isTranslucent = false
//        self.tabBar.barStyle = .default
//        self.tabBar.layer.cornerRadius = kBarCornerRadius
//        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//    }
//
//    func initShadowView() {
//        let shadowView = RoundShadowView(frame: self.tabBar.frame)
//        shadowView.backgroundColor = .clear
//        self.roundShadowView = shadowView
//        self.view.insertSubview(shadowView, belowSubview: self.tabBar)
//        shadowView.config(cornerRadius: kBarCornerRadius + 1,
//                          shadowColor: Colors.black,
//                          shadowOffset: CGSize(width: 0.0, height: 0.0),
//                          shadowOpacity: 0.1,
//                          shadowRadius: 4.0)
//    }
//
//    func setFrameOfShadowView() {
//        var frame = self.tabBar.frame
//        frame.origin.y += self.roundShadowViewVerticalOffset
//        self.roundShadowView?.frame = frame
//    }
}

// MARK: - Observer -

extension AppTabBarController: Observer {
    func onChanged<Item>(_ item: Item) {
//        switch item {
//        case let cartActionObject as CartActionObject:
//            switch cartActionObject {
//            case .cartItemsCounterDidChanged(let itemsCounter):
//                self.showBadgeWithItemsCounter(itemsCounter)
//            case .cartProductDidUpdated, .currentCheckoutInfo, .cartUpdatingState:
//                break
//            }
//        default:
//            break
//        }
    }
    
    func showBadgeWithItemsCounter(_ itemsCounter: Int) {
//        guard let index = self.viewControllers?
//            .firstIndex(where: { ($0 as? AppNavigationController)?.tag == .cart }) else { return }
//        onMainQueue {
//            self.tabBar.setBadge(value: String(itemsCounter), at: index)
//        }
    }
}
//swiftlint:disable all
