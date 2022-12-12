//
//  AnimationStorages.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class AnimationStorage {
    static let shared = AnimationStorage()
    private init() {}
    private var userType: UserType?
    func set(userType: UserType) {
        self.userType = userType
    }
    
    var logoImage: CGRect?
    
    var firstImage: CGRect?
    var firstCell: CGRect?
    var secondImage: CGRect? {
        return self.computedSecond
    }
    
    var imageAlpha: CGFloat = 1.0
    var image: UIImage?
    
    private var computedSecond: CGRect? {
        guard let userType = self.userType else { return nil }
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let safeAreaTopHeight = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
        let navBarHeight: CGFloat = 44.0
        let topHeight = ((safeAreaTopHeight == 0) ? statusBarHeight : safeAreaTopHeight) + navBarHeight
        
        switch userType {
        case .seller:
            return CGRect(x: 11, y: topHeight + 12, width: 130, height: 130)
        case .dealer:
            guard let screenWidth = UIApplication.shared.keyWindow?.frame.size.width else { return nil }
            return CGRect(x: 0, y: topHeight, width: screenWidth, height: screenWidth)
        }
    }
}

/*
 DEALER
 po self.collectionView.convert(self.collectionView.frame, to: self.collectionView.window)
▿ (0.0, 88.0, 414.0, 414.0)
  ▿ origin : (0.0, 88.0)
    - x : 0.0
    - y : 88.0
  ▿ size : (414.0, 414.0)
    - width : 414.0
    - height : 414.0
 */
