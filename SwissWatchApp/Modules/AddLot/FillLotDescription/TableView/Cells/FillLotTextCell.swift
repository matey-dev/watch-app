//
//  FillLotTextCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class FillLotTextCell: UITableViewCell, FillLotTableViewCell {
    private var model: FillLotTextCellModel?
    var actionHandler: FillLotTableViewHandler?
    
    @IBOutlet weak var textField: BaseFloatingTextField!
    
    private func setup() {}
    
    private func clear() { self.textField.text = .none }
    
    func configure(model: FillLotTableViewCellModel?) {
        (model as? FillLotTextCellModel).map { model in
            self.model = model
            
            onMainQueue {
                self.textField.setupAs(type: model.cell.baseFloatingTextFieldType,
                                       placeholder: model.cell.key.placeHolder)
                self.textField.text = model.cell.text
//                self.textField.error = model.cell.errorText
                
                if model.cell.key == .model_year {
                    self.textField.keyboardType = .numberPad
                }
            }
            
            self.textField.tag = model.cell.priority
            
            self.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            self.textField.addTarget(self, action: #selector(textFieldDidEndChange(textField:)), for: .editingDidEnd)
        }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        guard textField == self.textField else { return }
        textField.text.map { self.model?.cell.text = $0 }
    }
    
    @objc private func textFieldDidEndChange(textField: UITextField) {
        self.actionHandler?(.modelIsChanged)
    }
}

class FillLotTextCellModel: FillLotTableViewCellModel {
    var fields: [FillLotModel.Field] {
        return [self.cell]
    }
    
    var checks: [FillLotModel.CheckBox] {
        return []
    }
    
    let cell: FillLotModel.Field
    
    init(cell: FillLotModel.Field) {
        self.cell = cell
    }
}
