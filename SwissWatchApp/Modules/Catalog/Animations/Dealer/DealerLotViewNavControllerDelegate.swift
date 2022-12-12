//
//  LotViewNavControllerDelegate.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotViewNavControllerDelegate: NSObject {
    
    var isPresenting: Bool = true
    
    private var presentingDuration: Double = 1.0
    private var dismissDuration: Double = 0.75
    
    private var duration: Double {
        return self.isPresenting ? self.presentingDuration : self.dismissDuration
    }
    
    private var animator: DealerLotViewAnimator {
        return DealerLotViewAnimator(duration: self.duration)
    }
}

extension DealerLotViewNavControllerDelegate: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            guard self.isCatalogAndDealerLotView(one: fromVC, two: toVC) else {
                return nil
            }
            
            switch operation {
            case .push:
                return self.doPushOperation()
            case .pop:
                return self.doPopOperation()
            default:
                return nil
            }
    }
    
    private func isCatalogAndDealerLotView(one: UIViewController, two: UIViewController) -> Bool {
        return (one is CatalogView && two is DealerLotView) || (two is CatalogView && one is DealerLotView)
    }

    // MARK: - private
    
    private func doPushOperation() -> DealerLotViewAnimator {
        self.isPresenting = true
        return self.animator
    }
    
    private func doPopOperation() -> DealerLotViewAnimator {
        self.isPresenting = false
        return self.animator
    }
}
