//
//  DealerFilterDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/5/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerFilterDataAdapter: NSObject {
    private var filter: DealerFilter
    func dealerFilter() -> DealerFilter {
        return self.filter
    }
    func clearFilter() {
        self.filter.clearSelected()
    }
    
    var onDidSelect: (() -> Void)?
    
    private var brandTextField: DropdownFloatingTextField
    private var modelTextField: DropdownFloatingTextField
    private var yearTextField: DropdownFloatingTextField
    private var textFields: [DropdownFloatingTextField] {
        return [self.brandTextField,
                self.modelTextField,
                self.yearTextField]
    }
    
    init(filter: DealerFilter,
         brandTextField: DropdownFloatingTextField,
         modelTextField: DropdownFloatingTextField,
         yearTextField: DropdownFloatingTextField) {
        self.filter = filter
        self.brandTextField = brandTextField
        self.modelTextField = modelTextField
        self.yearTextField = yearTextField
        
        self.brandTextField.text = self.filter.selected.brand?.label
        self.modelTextField.text = self.filter.selected.model
        self.yearTextField.text = self.filter.selected.year
        
        super.init()
        self.textFields.forEach {
            $0.pickerDelegate = self
            $0.pickerDataSource = self
        }
    }
}

extension DealerFilterDataAdapter: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.brandTextField.pickerView:
            return self.filter.brands.count
        case self.modelTextField.pickerView:
            return self.filter.models.count
        case self.yearTextField.pickerView:
            return self.filter.years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.brandTextField.pickerView:
            return self.filter.brands[safe: row]?.label
        case self.modelTextField.pickerView:
            return self.filter.models[safe: row]
        case self.yearTextField.pickerView:
            return self.filter.years[safe: row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.brandTextField.pickerView:
            //self.brandTextField.hidePicker()
            let selected = self.filter.brands[safe: row]
            self.filter.selected.brand = selected
            self.brandTextField.text = selected?.label
        case self.modelTextField.pickerView:
            //self.modelTextField.hidePicker()
            let selected = self.filter.models[safe: row]
            if self.filter.selected.setModel(selected) {
                self.modelTextField.text = selected
            }
        case self.yearTextField.pickerView:
            //self.yearTextField.hidePicker()
            let selected = self.filter.years[safe: row]
            if self.filter.selected.setYear(selected) {
                self.yearTextField.text = selected
            }
        default: ()
        }
        self.onDidSelect?()
        
//        guard pickerView == self.textField.pickerView,
//            let selected = self.model?.brands[safe: row] else { return }
//        self.textField.hidePicker()
//        self.model?.cell.text = selected.label
//        self.model?.cell.id = selected.id
//        self.textField.text = selected.label
//        self.actionHandler?(.modelIsChanged)
    }
}
