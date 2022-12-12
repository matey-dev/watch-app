//
//  CALayerExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

private let defaultShadowOpacity: Float = 0.5
private let defaultShadowRadius: CGFloat = 3.0
private let borderLayerName = "BorderLayer"
private let shadowLayerName = "ShadowLayer"
private let lineLayerName = "LineLayer"
private let crossLineLayerName = "CrossLineLayerName"
private let crossLineDefaultIndent: CGFloat = 3.0

extension CALayer {
    
    // MARK: - Round corners
    func rounded(cornerRadius: CGFloat) {
        let roundedMaskLayer = CAShapeLayer()
        roundedMaskLayer.path = UIBezierPath(roundedRect: self.bounds,
                                             cornerRadius: cornerRadius).cgPath
        self.mask = roundedMaskLayer
    }
    
    // MARK: - Borders
    func addBorders(_ borders: [(width: CGFloat, color: UIColor)]) {
        self.removeBorders()
        
        borders.forEach { (width, color) in
            let borderLayer = CAShapeLayer()
            borderLayer.name = borderLayerName
            borderLayer.path = UIBezierPath(roundedRect: self.bounds,
                                            cornerRadius: self.cornerRadius).cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = color.cgColor
            borderLayer.lineWidth = width
            borderLayer.frame = self.bounds
            self.add(borderLayer)
        }
    }
    
    func removeBorders() {
        self.removeLayers(named: borderLayerName)
    }
    
    func addCrossLine(width: CGFloat, color: UIColor, indent: CGFloat = crossLineDefaultIndent) {
        self.removeCrossLine()
        
        let layer = CAShapeLayer()
        layer.name = crossLineLayerName
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: indent, y: indent))
        path.addLine(to: CGPoint(x: self.bounds.width - indent, y: self.bounds.height - indent))
        layer.path = path.cgPath
        
        layer.strokeColor = color.cgColor
        layer.lineWidth = width
        self.add(layer)
    }
    
    func removeCrossLine() {
        self.removeLayers(named: crossLineLayerName)
    }
    
    func underline(width: CGFloat, color: UIColor) {
        self.removeLayers(named: lineLayerName)
        
        self.masksToBounds = true
        
        let lineLayer = CALayer()
        lineLayer.name = lineLayerName
        lineLayer.frame = CGRect(x: 0,
                                 y: self.bounds.size.height - width,
                                 width: self.bounds.size.width,
                                 height: self.bounds.size.height)
        lineLayer.borderColor = color.cgColor
        lineLayer.borderWidth = width
        self.add(lineLayer)
    }
    
    // MARK: - Shadow
    func shadow(color: UIColor,
                opacity: Float = defaultShadowOpacity,
                offset: CGSize = .zero,
                radius: CGFloat = defaultShadowRadius) {
        
        self.removeLayers(named: shadowLayerName)
        
        self.name = shadowLayerName
        self.masksToBounds = false
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        self.shadowOffset = offset
        self.shadowRadius = radius
    }
    
    // MARK: - Add few layers
    func add(_ layers: CALayer...) {
        layers.forEach(self.addSublayer)
    }
    
    // MARK: - Remove layers by name
    func removeLayers(named: String...) {
        named.forEach { layerName in
            self.sublayers?.removeAll { $0.name == layerName }
        }
    }
}

extension CAShapeLayer {
    
    // MARK: - Round shadow
    func roundedShadow(roundedRect: CGRect, cornerRadius: CGFloat) {
        self.path = UIBezierPath(roundedRect: roundedRect,
                                 cornerRadius: cornerRadius).cgPath
        self.shadowPath = self.path
    }
    
}
