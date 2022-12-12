//
//  DealerLotViewAnimator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotViewAnimator: NSObject {
    var duration: TimeInterval
    private var transitionContext: UIViewControllerContextTransitioning?
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
}

extension DealerLotViewAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: .from) as? CatalogView,
            let toVC = transitionContext.viewController(forKey: .to) as? DealerLotView {
            self.animateTransitionFromView(fromVC: fromVC, toVC: toVC, using: transitionContext)
        } else if let fromVC = transitionContext.viewController(forKey: .from) as? DealerLotView,
            let toVC = transitionContext.viewController(forKey: .to) as? CatalogView {
            self.animateTransitionFromView(fromVC: fromVC, toVC: toVC, using: transitionContext)
        }
    }
    
    private func animateTransitionFromView(fromVC: CatalogView,
                                           toVC: DealerLotView,
                                           using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = fromVC.view,
            let toView = toVC.view,
            let logoImage = AnimationStorage.shared.logoImage,
            let firstImage = AnimationStorage.shared.firstImage,
            let firstCell = AnimationStorage.shared.firstCell,
            let secondImage = AnimationStorage.shared.secondImage,
            let image = AnimationStorage.shared.image else { return }
        let imageAlpha = AnimationStorage.shared.imageAlpha
        
        transitionContext.containerView.addSubview(toView)
        toView.frame = CGRect(x: 0, y: fromView.frame.height, width: toView.frame.width, height: toView.frame.height)
        toView.layoutIfNeeded()
        
        let transitionCell = UIView(frame: firstCell)
        transitionCell.backgroundColor = Colors.white
        transitionCell.alpha = 0
        transitionCell.clipsToBounds = true
        transitionCell.layer.cornerRadius = 12
        transitionContext.containerView.addSubview(transitionCell)
        
        let transitionImageViewBackground = UIView()
        transitionImageViewBackground.backgroundColor = .white
        transitionImageViewBackground.contentMode = .scaleAspectFill
        transitionImageViewBackground.clipsToBounds = true
        transitionContext.containerView.addSubview(transitionImageViewBackground)
        
        let transitionImageView = UIImageView(frame: firstImage)
        transitionImageView.image = image
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.clipsToBounds = true
        transitionImageView.layer.cornerRadius = 12
        transitionImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        transitionContext.containerView.addSubview(transitionImageView)
        transitionImageView.alpha = imageAlpha
        
        let transitionLogoImageView = UIImageView(frame: logoImage)
        transitionLogoImageView.image = UIImage(named: "watchQuote-halfSize")
        transitionLogoImageView.contentMode = .scaleAspectFill
        transitionContext.containerView.addSubview(transitionLogoImageView)
        
        transitionContext.containerView.bringSubviewToFront(fromView)
        
        toVC.navigationController?.navigationBar.alpha = 0
        toView.frame = fromView.frame
        toView.alpha = 0
        fromView.alpha = 1
        
        UIView.animate(withDuration: self.duration*0.2, delay: 0, options: .curveEaseInOut, animations: {
            fromView.alpha = 0
            transitionCell.alpha = 1
        }) { _ in
            
        }
        
        UIView.animate(withDuration: self.duration*0.5, delay: self.duration*0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            transitionImageViewBackground.frame = secondImage
            transitionImageViewBackground.layer.cornerRadius = 0
            transitionImageView.frame = secondImage
            transitionImageView.layer.cornerRadius = 0
        }) { _ in
            
        }
        
        UIView.animate(withDuration: self.duration*0.3, delay: self.duration*0.2, options: .curveEaseInOut, animations: {
            let toViewFrameDouble = CGRect(x: toView.frame.origin.x - toView.frame.size.width/2,
                                           y: toView.frame.origin.y - toView.frame.size.height/2,
                                           width: toView.frame.size.width*2,
                                           height: toView.frame.size.height*2)
            transitionCell.frame = toViewFrameDouble
            transitionCell.layer.cornerRadius = 0
            transitionImageView.alpha = 1.0
        }) { _ in
            
        }
        
        UIView.animate(withDuration: self.duration*0.1, delay: self.duration*0.9, options: .curveEaseInOut, animations: {
            toVC.navigationController?.navigationBar.alpha = 1
        }) { _ in
            
        }
        
        UIView.animate(withDuration: self.duration*0.5, delay: self.duration*0.5, options: .curveEaseInOut, animations: {
            toView.alpha = 1
            transitionCell.alpha = 0
        }) { _ in
            transitionLogoImageView.removeFromSuperview()
            transitionImageViewBackground.removeFromSuperview()
            transitionImageView.removeFromSuperview()
            transitionCell.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
    private func animateTransitionFromView(fromVC: DealerLotView,
                                           toVC: CatalogView,
                                           using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = fromVC.view,
            let toView = toVC.view,
            let logoImage = AnimationStorage.shared.logoImage,
            let firstImage = AnimationStorage.shared.firstImage,
            let secondImage = AnimationStorage.shared.secondImage,
            let image = AnimationStorage.shared.image else { return }
        let imageAlpha = AnimationStorage.shared.imageAlpha
        
        let transitionImageViewBackground = UIView()
        transitionImageViewBackground.backgroundColor = .white
        transitionImageViewBackground.contentMode = .scaleAspectFill
        transitionImageViewBackground.clipsToBounds = true
        transitionContext.containerView.addSubview(transitionImageViewBackground)
        
        let transitionImageView = UIImageView(frame: secondImage)
        transitionImageView.image = image
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.clipsToBounds = true
        transitionImageView.layer.cornerRadius = 0
        transitionImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        transitionContext.containerView.addSubview(transitionImageView)
        
        let transitionLogoImageView = UIImageView(frame: logoImage)
        transitionLogoImageView.image = UIImage(named: "watchQuote-halfSize")
        transitionLogoImageView.contentMode = .scaleAspectFill
        transitionContext.containerView.addSubview(transitionLogoImageView)
        
        transitionContext.containerView.addSubview(toView)
        toView.frame = CGRect(x: 0, y: fromView.frame.height, width: toView.frame.width, height: toView.frame.height)
        toView.layoutIfNeeded()
        
        toView.frame = fromView.frame
        toView.alpha = 0
        fromView.alpha = 1
        transitionImageViewBackground.alpha = 1
        transitionImageView.alpha = 1
        
        UIView.animate(withDuration: self.duration*0.1, delay: 0, options: .curveEaseInOut, animations: {
            fromView.alpha = 0
        }) { _ in
            
        }
        
        UIView.animate(withDuration: self.duration*0.2, delay: self.duration*0.8, options: .curveEaseInOut, animations: {
            toView.alpha = 1
        }) { _ in
            transitionImageViewBackground.removeFromSuperview()
            transitionImageView.removeFromSuperview()
            transitionLogoImageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        UIView.animate(withDuration: self.duration*0.3, delay: self.duration*0.1, options: .curveEaseInOut, animations: {
            transitionImageViewBackground.frame = firstImage
            transitionImageViewBackground.layer.cornerRadius = 12
            transitionImageView.frame = firstImage
            transitionImageView.layer.cornerRadius = 12
            transitionImageView.alpha = imageAlpha
        }) { _ in
            
        }
    }
}
