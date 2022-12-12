//
//  UIViewExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

private let defaultDuration: TimeInterval = 0.3

extension UIView {
    
    func getSubviews<T: UIView>(ofType: T.Type) -> [T]? {
        return self.subviews.filter { $0 is T } as? [T]
    }
    
    func isContains(touch: UITouch) -> Bool {
        return self.bounds.contains(touch.location(in: self))
    }
    
    // MARK: - Round corners
    func rounded(cornerRadius: CGFloat) {
        self.layer.rounded(cornerRadius: cornerRadius)
    }
    
    func maskByRoundingCorners(_ masks: UIRectCorner, withRadii radii: CGSize = CGSize(width: 10, height: 10)) {
        let rounded = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: masks, cornerRadii: radii)
        
        let shape = CAShapeLayer()
        shape.path = rounded.cgPath
        
        self.layer.mask = shape
    }
    
    // MARK: - Border
    func border(width: CGFloat, color: UIColor) {
        self.layer.addBorders([(width, color)])
    }
    
    func borders(_ borders: [(width: CGFloat, color: UIColor)]) {
        self.layer.addBorders(borders)
    }
    
    // MARK: - Shadow
    func addDefaultShadow(color: UIColor) {
        self.layer.shadow(color: color)
    }
    
    func addShadow(color: UIColor,
                   opacity: Float,
                   offset: CGSize,
                   radius: CGFloat) {
        
        self.layer.shadow(color: color,
                          opacity: opacity,
                          offset: offset,
                          radius: radius)
    }
    
    // MARK: - Animations
    
    enum AnimationValue {
        case alpha(CGFloat)
        case color(UIColor)
    }
    
    func animate(value: AnimationValue,
                 animationOptions: AnimationOptions = [.curveEaseInOut],
                 duration: TimeInterval = defaultDuration,
                 completion: ((Bool) -> Void)? = nil) {
        self.transitionAnimation(animationOptions: animationOptions,
                                 duration: duration,
                                 animations: { [weak self] in
                                    
                                    switch value {
                                    case .alpha(let alpha):
                                        self?.alpha = alpha
                                    case .color(let color):
                                        self?.backgroundColor = color
                                    }
            }, completion)
    }
    
    func animate(hidden: Bool, inStackView stackView: UIStackView) {
        self.transitionAnimation(animationOptions: [.curveEaseOut],
                                 animations: { [weak self] in
                                    
                                    self?.isHidden = hidden
                                    stackView.layoutIfNeeded()
        })
    }
    
    private func transitionAnimation(animationOptions: AnimationOptions,
                                     duration: TimeInterval = defaultDuration,
                                     animations: (() -> Void)?,
                                     _ completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self,
                          duration: duration,
                          options: animationOptions,
                          animations: animations,
                          completion: completion)
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = defaultDuration) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        self.layer.add(animation, forKey: nil)
    }
}

extension UIView {
    @discardableResult
    func setHeightConstraint(constant: CGFloat) -> Self {
        self.setConstraint(value: constant, attribute: .height)
        return self
    }
    
    @discardableResult
    func setWidthConstraint(constant: CGFloat) -> Self {
        self.setConstraint(value: constant, attribute: .width)
        return self
    }
    
    private func removeConstraints(attribute: NSLayoutConstraint.Attribute) {
        constraints.lazy.filter { $0.firstAttribute == attribute }.forEach { self.removeConstraint($0) }
    }
    
    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        self.removeConstraints(attribute: attribute)
        let constraint =
            NSLayoutConstraint(item: self,
                               attribute: attribute,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: value)
        self.addConstraint(constraint)
    }
}

extension UIView {
    func applyGradient(colours: [UIColor]) {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradientLayerName = "gradientLayer"
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.name = gradientLayerName
        self.layer.removeLayers(named: gradientLayerName)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UILabel {
    func setText(_ text: String?) {
        self.text = text
        self.isHidden = text.isNil
    }
}

extension UIButton {
    func setNormalStateTitle(_ text: String?) {
        self.setTitle(text, for: .normal)
        self.isHidden = text.isNil
    }
}

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

extension UIView {
    class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
        return parenView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }

    class func getAllSubviews(from parenView: UIView, types: [UIView.Type]) -> [UIView] {
        return parenView.subviews.flatMap { subView -> [UIView] in
            var result = getAllSubviews(from: subView) as [UIView]
            for type in types {
                if subView.classForCoder == type {
                    result.append(subView)
                    return result
                }
            }
            return result
        }
    }

    func getAllSubviews<T: UIView>() -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get<T: UIView>(all type: T.Type) -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get(all types: [UIView.Type]) -> [UIView] { return UIView.getAllSubviews(from: self, types: types) }
}
