//
//  LegalInfoVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 20.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit

typealias LegalInfoVCAction = ((LegalInfoVCActionType) -> ())

enum LegalInfoVCActionType {
    case back
}

class LegalInfoVC: UIViewController {
    
    var onAction: LegalInfoVCAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapBack(sender: UIButton) {
        onAction?(.back)
    }
    
    @IBAction func didTapSupport(sender: UIButton) {
        self.contactWatchTeamWithEmail()
    }
    
    @IBAction func didTapTerms(sender: UIButton) {
        self.showPrivacyPolicy()
    }
    
    @IBAction func didTapPrivacy(sender: UIButton) {
        self.showPrivacyPolicy()
    }
    
    func contactWatchTeamWithEmail() {
        let email = API.supportMail
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func showPrivacyPolicy() {
        let urlString = API.privacyPolicy
        if let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
