//
//  BaseFloatingTextField.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/20/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum BaseFloatingTextFieldType {
    case text, email, password, confirmPassword, confirmCode
}

class BaseFloatingTextField: UITextField {
    private var type: BaseFloatingTextFieldType = .text
    
    var textDidChangeAction: ((String) -> Void)?
    @objc func editDidChange() {
        self.text.map {
            self.textDidChangeAction?($0)
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.baseSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.baseSetup()
    }
    
    func setupAs(type: BaseFloatingTextFieldType,
                 placeholder: String? = nil) {
        self.type = type
        self.placeholder = nil
        
        switch type {
        case .text:
            self.textContentType = .name
            self.autocapitalizationType = .sentences
            self.keyboardType = .default
            self.isSecureTextEntry = false
        case .email:
            self.textContentType = .emailAddress
            self.autocapitalizationType = .none
            self.keyboardType = .emailAddress
            self.isSecureTextEntry = false
        case .password, .confirmPassword:
            self.textContentType = .password
            self.autocapitalizationType = .none
            self.keyboardType = .default
            self.isSecureTextEntry = true
        case .confirmCode:
            self.textContentType = .name
            self.autocapitalizationType = .none
            self.keyboardType = .numberPad
            self.isSecureTextEntry = false
        }
        let tfbackColor = UIColor(hex: "#F9FAFA")
        let tfborderColor = UIColor(hex: "#F4F4F4").cgColor
        let leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 12, height: 20)))
        self.leftView = leftView
        self.leftViewMode = .always
        let rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 12, height: 20)))
        self.rightView = rightView
        self.rightViewMode = .always
        self.backgroundColor = tfbackColor
        self.layer.borderColor = tfborderColor
        self.layer.cornerRadius = 6
    }
}

private extension BaseFloatingTextField {
    func baseSetup() {
        self.addTarget(self, action: #selector(self.editDidChange), for: .editingChanged)
        
//        self.lineHeight = 1.0
//        self.selectedLineHeight = 2.0
//
//        self.titleLabel.font = Fonts.System.regular(size: 13)
//        self.titleColor = Colors.blackLight_40opacity
//        self.selectedTitleColor = Colors.blackLight_40opacity
//
//        self.placeholderFont = Fonts.System.regular(size: 17)
//        self.placeholderColor = Colors.blackLight_40opacity
//
//        self.lineColor = Colors.black_10opacity
//        self.selectedLineColor = Colors.blue
//
//        self.errorLabel.font = Fonts.System.regular(size: 13)
//        self.errorLineColor = Colors.redDark
//        self.errorColor = Colors.redDark
        
        self.addTarget(self, action: #selector(updateError), for: .editingChanged)
    }
    
    @objc private func updateError(textField: BaseFloatingTextField) {
//        self.error = nil
        //self.validate()
    }
    
    /*func validate() {
        switch self.type {
        case .text:
            guard let text = self.text, !text.isEmpty else { self.error = "Empty"; return }
            self.error = nil
        case .email:
            guard let text = self.text, !text.isEmpty else { self.error = "Empty"; return }
            let isValidEmail = EmailValidator().validate(email: text)
            switch isValidEmail {
            case .empty:
                self.error = "Empty"
            case .valid:
                self.error = nil
            case .invalid:
                self.error = "Invalid email"
            }
        case .password:
            guard let text = self.text, !text.isEmpty else { self.error = "Empty"; return }
            if text.count < 8 {
                self.error = "Password should be at least 8 characters"
            } else {
                self.error = nil
            }
        case .confirmPassword:
            guard let text = self.text, !text.isEmpty else { self.error = "Empty"; return }
            if text.count < 8 {
                self.error = "Password should be at least 8 characters"
            } else {
                self.error = nil
            }
        case .confirmCode:
            guard let text = self.text, !text.isEmpty else { self.error = "Empty"; return }
            if text.count < 5 {
                self.error = "Code must be 5 digits"
            } else {
                self.error = nil
            }
        }
    }*/
}
