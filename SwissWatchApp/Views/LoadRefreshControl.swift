//
//  LoadRefreshControl.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/7/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

private let animationDuration: TimeInterval = 0.25

class LoadRefreshControl: UIRefreshControl {
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.tintColor = Colors.darkBlueOpacity50
    }
    
    func refreshingManually() {
        guard let scrollView = self.superview as? UIScrollView else {
            return
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - self.frame.height)
        }, completion: { _ in
            self.beginRefreshing()
        })
    }
}
