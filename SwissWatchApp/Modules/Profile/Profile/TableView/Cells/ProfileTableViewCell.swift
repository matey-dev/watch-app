//
//  ProfileTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias ProfileTableViewHandler = ((ProfileTableViewAction) -> Void)

enum ProfileTableViewAction {
    case dataDidChanged
    case confirmButtonAction
    
    case logout
    case contactUs
    case changePassword
    case privacyPolicy
    case deleteMyAccount
    
    case editProfile
}

protocol ProfileTableViewCell: class, Reusable {
    func configure(model: ProfileTableViewCellModel?)
    var actionHandler: ProfileTableViewHandler? { get set }
}

protocol ProfileTableViewCellModel {}
