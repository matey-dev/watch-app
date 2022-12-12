//
//  Constants.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

struct APNSMessages {
    static let wins = "wins"
}

struct FontNames {
    struct Avenir {
        static let semibold = "AvenirNextCyr-Semibold"
        static let bold = "AvenirNextCyr-Bold"
        static let black = "AvenirNextCyr-Black"
        static let regular = "AvenirNextCyr-Regular"
        static let medium = "AvenirNextCyr-Medium"
        static let demi = "AvenirNextCyr-Demi"
    }
    
    struct Gilroy {
        static let semibold = "Gilroy-Semibold"
        static let bold = "Gilroy-Bold"
        static let black = "Gilroy-Black"
        static let regular = "Gilroy-Regular"
    }
    
    struct Raleway {
        static let semibold = "Raleway-SemiBold"
        static let medium = "Raleway-Medium"
        static let extrabold = "Raleway-ExtraBold"
        static let bold = "Raleway-Bold"
    }
    
    struct SFProText {
        static let semibold = "SFProText-Semibold"
        static let medium = "SFProText-Medium"
        static let regular = "SFProText-Regular"
    }
    
    struct SFProDisplay {
        static let medium = "SFProDisplay-Medium"
        static let regular = "SFProDisplay-Regular"
    }
    
    struct Inter {
        static let regular = "Inter-Regular"
    }
}

struct ImageNames {
    static let navBarBackButton = "back"
    
    struct InactiveBarIconNames {
        static let newSubmissions = "iconCatalogueInactive"//"InactiveNewSubmissions"
        static let appraisals = "iconAppraisalsInactive"//"InactiveAppraisals"
        static let archive = "archive_inactive"//"InactiveProfile"
        
        static let yourCatalogue = "home_inactive"//"InactiveYourCatalogue"
        static let lotAddind = "add_lot_inactive"//"InactiveLotAdding"
        static let profile = "iconProfileInactive"//"InactiveProfile"
        
    }
    
    struct NotificatedIconNames {
        static let newSubmissions = "iconCatalogueInactiveDot"//"InactiveNewSubmissions"
        static let appraisals = "iconAppraisalsInactiveDot"//"InactiveAppraisals"
        
        static let yourCatalogue = "iconCatalogueInactiveDot"//"InactiveYourCatalogue"
        static let lotAddind = "iconNewLotGray"//"InactiveLotAdding"
        
        static let profile = "iconProfileInactive"//"InactiveProfile"
    }
    
    struct ActiveBarIconNames {
        static let newSubmissions = "iconCatalogueActive"//"SelectedNewSubmissions"
        static let appraisals = "iconAppraisalsActive"//"SelectedAppraisals"
        static let archive = "archive_active"//"SelectedProfile"
        
        static let yourCatalogue = "home_active"//"SelectedYourCatalogue"
        static let lotAddind = "add_lot_active"//"SelectedLotAdding"
        static let profile = "iconProfileActive"//"SelectedProfile"
        
    }
    
    struct AddLot {
        static let front = "addLotFront"
        static let sideRight = "addLotSideRight"
        static let sideLeft = "addLotSideLeft"
//        static let back = "addLotBack"
//        static let backFull = "addLotBackFull"
        static let general = "addLotGeneral"
    }
}

struct ScreenTitles {
    static let newSubmissions = "New Submissions"
    static let appraisals = "Appraisals"
    
    static let yourCatalogue = "Your Catalogue"
    static let lotAddind = "Post adding"
    
    static let profile = "SelectedProfile"
    
    static let dealerLogin = "Dealer Login"
    static let sellerLogin = "Seller Login"
}

struct AРI {
    struct URL {
        static let host = "http://109.108.64.148"
        static let root = "/watchValue"
        static let version = "/v1"
        static let base = host + root + version
    }
    
    struct Endpoints {
        static let reactivation = URL.base + "/reactivation"
    }
}

struct SignUp {
    static let buttonTitle = "Sign up"
    
    var checkBoxText: NSAttributedString {
        let attrString = NSMutableAttributedString()
        let style = NSMutableParagraphStyle()
        //style.lineSpacing = 5
        let head = "I agree to the Privacy Policy."
        //let head = "I confirm that my personal data can be processed by Watch Value"
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: UIFont(name: FontNames.SFProText.medium, size: 16)!,
                                                       .paragraphStyle: style,
                                                       .foregroundColor: Colors.grayTextColor])
        attrString.append(headAttr)
        attrString.setAsLink(textToFind: "Privacy Policy", linkURL: API.privacyPolicy)
        return attrString
    }
}

struct OTP {
    var bottomText: NSAttributedString {
        let attrString = NSMutableAttributedString()
        let style = NSMutableParagraphStyle()
        let head = "If you didn’t recive code after a few moments, please contact our Account recovery team."
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 15.0),
                                                       .paragraphStyle: style,
                                                       .foregroundColor: Colors.blackLight_40opacity])
        attrString.append(headAttr)
        attrString.setAsLink(textToFind: "Account recovery", linkURL: API.accountRecoveryTeam)
        return attrString
    }
}

struct Tags {
    struct Animation {
        struct Images {
            static let catalog = 789
            static let lot = 789
        }
    }
}
