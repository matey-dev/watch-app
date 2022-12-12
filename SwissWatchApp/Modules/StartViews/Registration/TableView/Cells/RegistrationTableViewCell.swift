//
//  RegistrationTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias RegistrationTableViewHandler = ((RegistrationTableViewAction) -> Void)

enum RegistrationTableViewAction {
    case signUp
    case checkBoxIsChanged(isChecked: Bool)
    case showPrivacyPolicy
}

protocol RegistrationTableViewCell: class, Reusable {
    func configure(model: RegistrationTableViewCellModel?)
    var actionHandler: RegistrationTableViewHandler? { get set }
}

protocol RegistrationTableViewCellModel {
    var cells: [RegistrationModel.Field] { get }
}
