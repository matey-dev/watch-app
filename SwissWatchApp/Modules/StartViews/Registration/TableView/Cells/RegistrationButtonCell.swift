//
//  RegistrationButtonCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationButtonCell: UITableViewCell, RegistrationTableViewCell {
    private var model: RegistrationButtonCellModel?
    var actionHandler: RegistrationTableViewHandler?
    
    @IBOutlet weak var button: UIButton!
    
    private func setup() {}
    
    private func clear() {}
    
    func configure(model: RegistrationTableViewCellModel?) {
        (model as? RegistrationButtonCellModel).map { model in
            self.model = model
            
            self.button.titleLabel?.text = model.cell.title
            self.setButton(active: model.cell.active)
        }
    }
    
    private func setButton(active: Bool) {
        self.button.isEnabled = active
        
        let backColor = active ? Colors.black_90opacity : Colors.black_8opacity
        self.button.backgroundColor = backColor
        let titleColor = active ? Colors.white : Colors.black_40opacity
        self.button.setTitleColor(titleColor, for: .normal)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        self.actionHandler?(.signUp)
    }
}

class RegistrationButtonCellModel: RegistrationTableViewCellModel {
    var cells: [RegistrationModel.Field] {
        return []
    }
    
    let cell: RegistrationModel.Button
    
    init(cell: RegistrationModel.Button) {
        self.cell = cell
    }
}
