//
//  DropdownFloatingTextField.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DropdownFloatingTextField: BaseFloatingTextField {
    
    let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
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
        
//        self.titleColor = .clear
//        self.lineColor = Colors.black_40opacity
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
