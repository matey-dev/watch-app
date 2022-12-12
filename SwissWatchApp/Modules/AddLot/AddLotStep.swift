//
//  AddLotStep.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum AddLotStep: Int {
    case front = 1
    case sideRight = 2
    case sideLeft = 3
    case general = 4
    case description = 5
    
    static var allCases: [AddLotStep] {
        return [.front,
                .sideRight,
                .sideLeft,
                .general,
                .description]
    }
    
    static var numberOfAllCases: Int {
        return AddLotStep.allCases.count
    }
    
    static var firstStep = AddLotStep.allCases.first
    static var lastStep = AddLotStep.allCases.last
    
    var nextStep: AddLotStep? {
        guard self != .description else { return nil }
        return AddLotStep(rawValue: self.rawValue + 1)
    }
    
    var prevStep: AddLotStep? {
        guard self != .front else { return nil }
        return AddLotStep(rawValue: self.rawValue - 1)
    }
    
    var progressDescription: String {
        let raw = self.rawValue
        let total = AddLotStep.numberOfAllCases
        return "Step \(String(raw)) out of \(String(total))"
    }
    
    var progressDescriptionAttributedString: NSAttributedString {
        let raw = self.rawValue
        let total = AddLotStep.numberOfAllCases
        let string = "Step \(String(raw)) out of \(String(total))"
        
        let font = Fonts.Avenir.medium(size: 14.0)
        let generalColor = Colors.black_50opacity
        let highlightedColor = Colors.black
        let range = NSRange(location: 6, length: 1)
        
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: font,
                                                                      .foregroundColor: generalColor])
        attributedString.addAttribute(.foregroundColor,
                                      value: highlightedColor,
                                      range: range)
        return attributedString
    }
    
    var progress: Float {
        let raw = self.rawValue
        let total = AddLotStep.numberOfAllCases
        return Float(raw)/Float(total)
    }
    
    var imageName: String? {
        switch self {
        case .front:
            return ImageNames.AddLot.front
        case .sideLeft:
            return ImageNames.AddLot.sideLeft
        case .sideRight:
            return ImageNames.AddLot.sideRight
        case .general:
            return ImageNames.AddLot.general
        default:
            return nil
        }
    }
    
    var overlayImage: UIImage {
        switch self {
        case .front:
            return #imageLiteral(resourceName: "add_lot_front")
        case .sideLeft:
            return #imageLiteral(resourceName: "add_lot_side")
        case .sideRight:
            return #imageLiteral(resourceName: "add_lot_otherside")
        case .general:
            return #imageLiteral(resourceName: "add_lot_back")
        default:
            return #imageLiteral(resourceName: "add_lot_box")
        }
    }
}
