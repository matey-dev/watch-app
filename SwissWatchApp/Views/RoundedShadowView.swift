//
//  RoundedShadowView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/27/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RoundShadowView: UIView {
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 15.0
    private var shadowColor: UIColor = UIColor.black
    private var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0)
    private var shadowOpacity: Float = 0.2
    private var shadowRadius: CGFloat = 31.0
    
    func config(cornerRadius: CGFloat,
                shadowColor: UIColor,
                shadowOffset: CGSize,
                shadowOpacity: Float,
                shadowRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.shadowLayer == nil {
            self.shadowLayer = CAShapeLayer()
            self.shadowLayer.roundedShadow(roundedRect: self.bounds,
                                           cornerRadius: self.cornerRadius)
            self.shadowLayer.shadow(color: self.shadowColor,
                                    opacity: self.shadowOpacity,
                                    offset: self.shadowOffset,
                                    radius: self.shadowRadius)
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
