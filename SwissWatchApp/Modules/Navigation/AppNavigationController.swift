//
//  AppNavigationController.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

private let fontSize: CGFloat = 17.0
private let fontSizePlus: CGFloat = 19.0
private let largeFontSize: CGFloat = 34.0
private let horizontalOffset: CGFloat = 4.0
private let verticalOffset: CGFloat = 1.0

class AppNavigationController: UINavigationController {
    private var userType: UserType?
    var navBarAnimationInProgress = false
    private var navigationControllerDelegate: UINavigationControllerDelegate?
    
    private var _tag: TabBarTags?
    var tag: TabBarTags? { return self._tag }
    
    convenience init(tabBarTag: TabBarTags, userType: UserType? = nil, large: Bool = true) {
        self.init()
        isNavigationBarHidden = true
        self._tag = tabBarTag
        self.setTabBarItem(tag: tabBarTag)
//        self.configureAppearance(large: large)
        self.userType = userType
        self.configAnimationDelegate()
    }
    
    func setNavigationBar(hidden: Bool, animated: Bool = true) {
//        CATransaction.begin()
//        self.navBarAnimationInProgress = true
//        CATransaction.setCompletionBlock { [weak self] in
//            self?.navBarAnimationInProgress = false
//        }
//        self.setNavigationBarHidden(hidden, animated: animated)
//        CATransaction.commit()
    }
    
    func setNavigationBar(translucent: Bool) {
//        self.navigationBar.isTranslucent = translucent
    }
    
    func configureAppearance(large: Bool) {
        let font = self.getFont(large: large)
        let fontPlus = self.getFontPlus()
        let color = Colors.blackLight
        
        self.configureBarButtonItem(font: font)
        
        let appearance = UINavigationBar.appearance()
//        let image = UIImage(color: Colors.white_80opacity)
//        appearance.setBackgroundImage(image, for: .default)
        appearance.shadowImage = UIImage()
//        appearance.isTranslucent = true
        appearance.tintColor = color
//        //appearance.backgroundColor = Colors.white_80opacity
        appearance.titleTextAttributes = [.foregroundColor: color, .font: fontPlus]
//
        let imgBackArrow = UIImage(named: ImageNames.navBarBackButton)?.withRenderingMode(.alwaysOriginal)
        appearance.backIndicatorImage = imgBackArrow
        appearance.backIndicatorTransitionMaskImage = imgBackArrow
        
        if large {
            self.setNavBar(largeFont: font.withSize(largeFontSize), color: color)
        }
    }
    
    func configAnimationDelegate() {
        guard let userType = self.userType else { return }
        switch userType {
        case .seller:
            self.navigationControllerDelegate = SellerLotViewNavControllerDelegate()
        case .dealer:
            self.navigationControllerDelegate = DealerLotViewNavControllerDelegate()
        }
        self.delegate = self.navigationControllerDelegate
    }
}

private extension AppNavigationController {
    func configureBarButtonItem(font: UIFont) {
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: horizontalOffset, vertical: verticalOffset), for: .default)
        barButtonAppearance.setTitleTextAttributes([.font: font], for: .normal)
    }
    
    func setNavBar(largeFont: UIFont, color: UIColor) {
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.largeTitleTextAttributes = [.foregroundColor: color, .font: largeFont]
    }
    
    func setTabBarItem(tag: TabBarTags) {
        self.tabBarItem = UITabBarItem(title: tag.title,
                                       image: UIImage(named: tag.inactiveIconName),
                                       tag: tag.rawValue)
        self.tabBarItem.selectedImage = UIImage(named: tag.activeIconName)
        self.tabBarItem.setTitleTextAttributes([.foregroundColor: Colors.grayDark,
                                                .font: self.getFont(large: false)], for: .selected)
    }
    
    func getFont(large: Bool) -> UIFont {
        return large ? Fonts.Raleway.extrabold(size: fontSize) : Fonts.System.bold(size: fontSize)
    }
    
    func getFontPlus() -> UIFont {
        return Fonts.System.regular(size: fontSizePlus)
    }
}
