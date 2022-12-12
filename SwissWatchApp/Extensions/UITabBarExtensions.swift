//
//  UITabBarExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

extension UITabBar {
    func setBadge(value: String?,
                  at index: Int,
                  withConfiguration configuration: TabBarBadgeStyle = TabBarBadgeStyle()) {
        let existedBadge = self.subviews.first { ($0 as? TabBarBadge)?.hasIdentifier(for: index) == true }
        
        guard let value = value else {
            existedBadge?.removeFromSuperview()
            return
        }
        
        let badge = (existedBadge as? TabBarBadge) ?? self.badgeForIndex(index, withConfiguration: configuration)
        
        badge?.text = value
    }
    
    private func badgeForIndex(_ index: Int, withConfiguration configuration: TabBarBadgeStyle = TabBarBadgeStyle()) -> TabBarBadge? {
        guard let tabBarItems = self.items else { return nil }
        
        let itemPosition = CGFloat(index + 1)
        let itemWidth = self.frame.width / CGFloat(tabBarItems.count)
        let itemHeight = self.frame.height
        let safeAreaBottomInset = self.safeAreaInsets.bottom
        
        let badge = TabBarBadge(for: index)
        badge.frame.size = configuration.size
        badge.center = CGPoint(x: (itemWidth * itemPosition) - (0.5 * itemWidth) + configuration.centerOffset.x,
                               y: (0.5 * (itemHeight - safeAreaBottomInset)) + configuration.centerOffset.y)
        badge.layer.cornerRadius = 0.5 * configuration.size.height
        badge.clipsToBounds = true
        badge.textAlignment = .center
        badge.backgroundColor = configuration.backgroundColor
        badge.font = configuration.font
        badge.textColor = configuration.textColor
        badge.border(width: configuration.borderWidth, color: configuration.borderColor)
        
        self.addSubview(badge)
        
        return badge
    }
}
