//
//  UIStyles.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Hue

struct Colors {
    static let whiteSnow = UIColor.white
    static let white = UIColor(red: 255, green: 255, blue: 255)
    static let white_89opacity = UIColor(red: 255, green: 255, blue: 255).withAlphaComponent(0.89)
    static let white_80opacity = UIColor(red: 255, green: 255, blue: 255).withAlphaComponent(0.8)
    static let white_90opacity = UIColor(red: 255, green: 255, blue: 255).withAlphaComponent(0.9)
    static let white_95opacity = UIColor(red: 255, green: 255, blue: 255).withAlphaComponent(0.95)
    static let white_33opacity = UIColor.white.withAlphaComponent(0.33)
    static let white_45opacity = UIColor.white.withAlphaComponent(0.45)
    static let white_65opacity = UIColor.white.withAlphaComponent(0.65)
    
    static let blackLight = UIColor(red: 34, green: 34, blue: 34)
    static let blackLight_25opacity = UIColor(red: 34, green: 34, blue: 34).withAlphaComponent(0.25)
    static let blackLight_40opacity = UIColor(red: 34, green: 34, blue: 34).withAlphaComponent(0.4)
    static let blackLight_60opacity = UIColor(red: 34, green: 34, blue: 34).withAlphaComponent(0.6)
    static let blackLight_80opacity = UIColor(red: 34, green: 34, blue: 34).withAlphaComponent(0.8)
  static let blackLight_90opacity = UIColor(red: 34, green: 34, blue: 34).withAlphaComponent(0.9)
    static let black = UIColor.black
    static let black_5opacity = UIColor.black.withAlphaComponent(0.05)
    static let black_8opacity = UIColor.black.withAlphaComponent(0.08)
    static let black_10opacity = UIColor.black.withAlphaComponent(0.1)
    static let black_13opacity = UIColor.black.withAlphaComponent(0.13)
    static let black_30opacity = UIColor.black.withAlphaComponent(0.3)
    static let black_40opacity = UIColor.black.withAlphaComponent(0.4)
    static let black_45opacity = UIColor.black.withAlphaComponent(0.45)
    static let black_50opacity = UIColor.black.withAlphaComponent(0.5)
    static let black_60opacity = UIColor.black.withAlphaComponent(0.6)
    static let black_90opacity = UIColor.black.withAlphaComponent(0.9)
    
    static let grayLight = UIColor(red: 206, green: 206, blue: 210) //   206/206/210   #CECED2
    static let grayMiddle = UIColor(red: 196, green: 196, blue: 196) //   196/196/196   #C4C4C4
    static let grayDark = UIColor(red: 128, green: 128, blue: 128) //   128/128/128   #808080
    
    static let redDark = UIColor(red: 245, green: 55, blue: 72)
    
    static let green = UIColor(red: 40, green: 212, blue: 0) //   33/150/183   #219653
    static let orange = UIColor(red: 255, green: 138, blue: 58) // 255 138 58
    static let blue = UIColor(red: 1, green: 128, blue: 255)
    static let blue_20opacity = UIColor(red: 1, green: 128, blue: 255).withAlphaComponent(0.2)
    static let darkBlue = UIColor(red: 32, green: 112, blue: 184) //   32/112/184   #2070B8
    static let darkBlueOpacity50 = UIColor(red: 32, green: 112, blue: 184).withAlphaComponent(0.5)
    
    static let green1 = UIColor(red: 112, green: 227, blue: 41)
    static let green2 = UIColor(red: 101, green: 205, blue: 37)
    static let green3 = UIColor(red: 17, green: 160, blue: 78)
    
    static let cyanColor = UIColor(hex: "#51B7A4")
    
    static let grayLightColor = #colorLiteral(red: 0.9764705882, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
    static let grayDarkColor = #colorLiteral(red: 0.6235294118, green: 0.6470588235, blue: 0.662745098, alpha: 1)
    static let grayTextColor = UIColor(hex: "#8F9599")
    
    static let blackTextColor = UIColor(hex: "#101E29")
    static let mainBackGround = UIColor(hex: "#FFFFFF")
}

struct Fonts {
    struct Avenir {
        static func black(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Avenir.black, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func bold(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Avenir.bold, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Avenir.semibold, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Avenir.regular, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func medium(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Avenir.medium, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func demi(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Avenir.demi, size: size) ?? .systemFont(ofSize: size)
        }
    }
    
    struct Gilroy {
        static func black(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Gilroy.black, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func bold(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Gilroy.bold, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Gilroy.semibold, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Gilroy.regular, size: size) ?? .systemFont(ofSize: size)
        }
    }
    
    struct Raleway {
        
        static func semibold(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Raleway.semibold, size: size) ?? .systemFont(ofSize: size)
        }
        
        static func extrabold(size: CGFloat) -> UIFont {
            return UIFont(name: FontNames.Raleway.extrabold, size: size) ?? .systemFont(ofSize: size)
        }
    }
    
    struct System {
        static func bold(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        
        static func medium(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .medium)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
}
