//
//  RegistrationTwoTextsCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationTwoTextsCell: UITableViewCell, RegistrationTableViewCell {
    private var model: RegistrationTwoTextsCellModel?
    var actionHandler: RegistrationTableViewHandler?
    
    @IBOutlet weak var textField1: BaseFloatingTextField!
    @IBOutlet weak var textField2: BaseFloatingTextField!
    @IBOutlet weak var secondFieldWidthConstraint: NSLayoutConstraint!
    
    private func setup() {}
    
    private func clear() {
        [self.textField1, self.textField2].forEach { $0.text = .none }
    }
    
    func configure(model: RegistrationTableViewCellModel?) {
        (model as? RegistrationTwoTextsCellModel).map { model in
            self.model = model
            
            onMainQueue {
                self.textField1.text = model.cell1.text
                self.textField1.placeholder = model.cell1.key.placeHolder
                self.textField2.text = model.cell2.text
                self.textField2.placeholder = model.cell2.key.placeHolder
                
                let secondKey = model.cell2.key
                switch secondKey {
                case .state:
                    self.secondFieldWidthConstraint.constant = 135.0
                default:
                    self.secondFieldWidthConstraint.constant = 85.0
                }
            }
            
            self.textField1.tag = model.cell1.registrationPriority
            self.textField2.tag = model.cell2.registrationPriority
            
            self.textField1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            self.textField2.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        if textField == self.textField1 {
            textField.text.map { self.model?.cell1.text = $0 }
        } else if textField == self.textField2 {
            textField.text.map { self.model?.cell2.text = $0 }
        }
    }
}

class RegistrationTwoTextsCellModel: RegistrationTableViewCellModel {
    var cells: [RegistrationModel.Field] {
        return [self.cell1, self.cell2]
    }
    
    let cell1: RegistrationModel.Field
    let cell2: RegistrationModel.Field
    
    init(cell1: RegistrationModel.Field,
         cell2: RegistrationModel.Field) {
        self.cell1 = cell1
        self.cell2 = cell2
    }
}
