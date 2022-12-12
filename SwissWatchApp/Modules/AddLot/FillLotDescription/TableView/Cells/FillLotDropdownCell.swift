//
//  FillLotDropdownCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

private let lineColor = Colors.black_40opacity
private let selectedLineColor = Colors.darkBlueOpacity50

class FillLotDropdownCell: UITableViewCell, FillLotTableViewCell {
    private var model: FillLotDropdownCellModel?
    var actionHandler: FillLotTableViewHandler?
    
    @IBOutlet weak var textField: DropdownFloatingTextField!
    
    private func setup() {}
    
    private func clear() {
        self.textField.text = .none
        self.textField.pickerDelegate = nil
        self.textField.pickerDataSource = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    func configure(model: FillLotTableViewCellModel?) {
        (model as? FillLotDropdownCellModel).map { model in
            self.model = model
            
            self.textField.pickerDelegate = self
            self.textField.pickerDataSource = self
            
            onMainQueue {
                self.textField.text = model.cell.text
            }
            
            self.textField.addTarget(self, action: #selector(textFieldDidBeginChange(textField:)), for: .editingDidBegin)
            self.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//            self.textField.addTarget(self, action: #selector(textFieldDidEndChange(textField:)), for: .editingDidEnd)
        }
    }
    
    @objc private func textFieldDidBeginChange(textField: UITextField) {
        guard textField == self.textField else { return }
        textField.text.map { self.model?.cell.text = $0 }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        guard textField == self.textField else { return }
        textField.text.map { self.model?.cell.text = $0 }
    }
    
//    @objc private func textFieldDidEndChange(textField: UITextField) {
//        guard textField == self.textField else { return }
//        self.actionHandler?(.modelIsChanged)
//    }
}

class FillLotDropdownCellModel: FillLotTableViewCellModel {
    var fields: [FillLotModel.Field] {
        return [self.cell]
    }
    
    var checks: [FillLotModel.CheckBox] {
        return []
    }
    
    var brands: [Brand]
    
    let cell: FillLotModel.Field
    
    init(cell: FillLotModel.Field, brands: [Brand]) {
        self.brands = brands
        self.cell = cell
    }
}

extension FillLotDropdownCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.model?.brands.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.model?.brands[safe: row]?.label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard pickerView == self.textField.pickerView,
            let selected = self.model?.brands[safe: row] else { return }
        //self.textField.hidePicker()
        self.model?.cell.text = selected.label
        self.model?.cell.id = selected.id
        self.textField.text = selected.label
        self.actionHandler?(.modelIsChanged)
    }
}
