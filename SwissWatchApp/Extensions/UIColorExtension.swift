//
//  UIColorExtension.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

private let maxColorComponentValue: CGFloat = 255.0

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / maxColorComponentValue,
                  green: CGFloat(green) / maxColorComponentValue,
                  blue: CGFloat(blue) / maxColorComponentValue,
                  alpha: alpha)
    }
    
    convenience init?(hexString: String) {
        var trimmedString = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        if trimmedString.hasPrefix("#") {
            trimmedString.remove(at: trimmedString.startIndex)
        }
        
        if trimmedString.count != 6 {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: trimmedString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / maxColorComponentValue,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / maxColorComponentValue,
            blue: CGFloat(rgbValue & 0x0000FF) / maxColorComponentValue,
            alpha: CGFloat(1.0)
        )
    }
    
    var inversed: UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        
        return self
    }
}
