//
//  PickerTextField.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/14/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class PickerTextField: UITextField {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.setup()
    }
    
    private func setup() {
        self.tintColor = .clear
        self.inputView = self.pickerView
        self.inputAccessoryView = self.pickerInputAccessoryView
    }
    
    // MARK: - Public
    
    var pickerDelegate: UIPickerViewDelegate? {
        didSet {
            pickerView.delegate = pickerDelegate
        }
    }
    
    var pickerDataSource: UIPickerViewDataSource? {
        didSet {
            pickerView.dataSource = pickerDataSource
        }
    }
    
    var currentlySelectedRow: Int {
        return self.pickerView.selectedRow(inComponent: 0)
    }
    
    func selectRowAtIndex(index: Int) {
        self.pickerView.selectRow(index, inComponent: 0, animated: false)
    }
    
    func showPicker() {
        self.becomeFirstResponder()
    }
    
    func hidePicker() {
        self.resignFirstResponder()
    }
    
    // MARK: - Views
    
    let pickerView = UIPickerView(frame: CGRect.zero)
    
    private lazy var pickerInputAccessoryView: UIView = {
        let frame = CGRect(x: .zero,
                           y: .zero,
                           width: .zero,
                           height: 48.0)
        let pickerInputAccessoryView = UIView(frame: frame)
        
        // Customize the view here
        
        return pickerInputAccessoryView
    }()
    
}
