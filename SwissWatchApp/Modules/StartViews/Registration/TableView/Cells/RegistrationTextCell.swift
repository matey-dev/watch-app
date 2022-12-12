//
//  RegistrationTextCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationTextCell: UITableViewCell, RegistrationTableViewCell {
    private var model: RegistrationTextCellModel?
    var actionHandler: RegistrationTableViewHandler?
    
    @IBOutlet weak var textField: BaseFloatingTextField!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    private func setup() {}
    
    private func clear() { self.textField.text = .none }
    
    func configure(model: RegistrationTableViewCellModel?) {
        (model as? RegistrationTextCellModel).map { model in
            self.model = model
            
            onMainQueue {
                self.textField.setupAs(type: model.cell.baseFloatingTextFieldType,
                                       placeholder: model.cell.key.placeHolder)
                self.textField.text = model.cell.text
                self.titleLbl.text = model.cell.key.placeHolder
            }
            
            self.textField.tag = model.cell.registrationPriority
            self.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        guard textField == self.textField else { return }
        textField.text.map { self.model?.cell.text = $0 }
    }
}

class RegistrationTextCellModel: RegistrationTableViewCellModel {
    var cells: [RegistrationModel.Field] {
        return [self.cell]
    }
    
    let cell: RegistrationModel.Field
    
    init(cell: RegistrationModel.Field) {
        self.cell = cell
    }
}
