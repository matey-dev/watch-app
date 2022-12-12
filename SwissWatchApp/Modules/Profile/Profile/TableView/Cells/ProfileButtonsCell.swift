//
//  ProfileButtonsCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class ProfileButtonsCell: UITableViewCell, ProfileTableViewCell {
    private var model: ProfileButtonsCellModel?
    var actionHandler: ProfileTableViewHandler?
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    private var apnsNetw = ApnsTestAPIService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    private func setup() {}
    
    private func clear() {}
    
    func configure(model: ProfileTableViewCellModel?) {
        (model as? ProfileButtonsCellModel).map { model in
            self.model = model
            
            switch model.buttons.state {
            case .default:
                self.editProfileButton.isHidden = false
                self.logOutButton.isHidden = false
                self.changePasswordButton.isHidden = true
                self.contactUsButton.isHidden = false
                self.privacyPolicyButton.isHidden = false
                self.deleteAccountButton.isHidden = true
            case .editProfile:
                self.editProfileButton.isHidden = true
                self.logOutButton.isHidden = false
                self.changePasswordButton.isHidden = false
                self.contactUsButton.isHidden = false
                self.privacyPolicyButton.isHidden = false
                self.deleteAccountButton.isHidden = false
            }
        }
    }
    
    @IBAction func editProfileButtonAction(_ sender: Any) {
        self.actionHandler?(.editProfile)
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        self.actionHandler?(.logout)
    }
    
    @IBAction func contactUsButtonAction(_ sender: Any) {
        self.actionHandler?(.contactUs)
        //self.apnsNetw.test(nil)
    }
    
    @IBAction func changePasswordButtonAction(_ sender: Any) {
        self.actionHandler?(.changePassword)
    }
    
    @IBAction func privacyPolicyButtonAction(_ sender: Any) {
        self.actionHandler?(.privacyPolicy)
    }
    
    @IBAction func deleteMyAccountButtonAction(_ sender: Any) {
        self.actionHandler?(.deleteMyAccount)
    }
}

class ProfileButtonsCellModel: ProfileTableViewCellModel {
    let buttons: ProfileModel.TableView.Buttons
    
    init(buttons: ProfileModel.TableView.Buttons) {
        self.buttons = buttons
    }
}
