//
//  RegistrationTableViewModels.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

class RegistrationModel {
    
    class Header {
        let title: String
        
        init(title: String) {
            self.title = title
        }
    }
    
    class CheckBox {
        var checked: Bool
        let attributedText: NSAttributedString?
        
        init(attributedText: NSAttributedString? = nil, checked: Bool? = false) {
            self.attributedText = attributedText
            self.checked = checked ?? false
        }
    }
    
    class Button {
        let title: String
        var active: Bool
        
        init(title: String, active: Bool? = false) {
            self.title = title
            self.active = active ?? false
        }
    }
    
    class Field {
        
        enum Key: String {
            case first_name, last_name, email, role, password, password_confirm, agree, zip, address, company_name, company_phone, city, state
            
            var placeHolder: String {
                switch self {
                case .first_name:
                    return "First Name"
                case .last_name:
                    return "Last Name"
                case .email:
                    return "Email"
                case .role:
                    return "Role"
                case .password:
                    return "Password"
                case .password_confirm:
                    return "Confirm Password"
                case .agree:
                    return "Agree"
                case .zip:
                    return "ZIP"
                case .address:
                    return "Address"
                case .company_name:
                    return "Company Name"
                case .company_phone:
                    return "Company Phone"
                case .city:
                    return "City"
                case .state:
                    return "State"
                }
            }
        }
        
        let key: Key
        var text: String
        
        var baseFloatingTextFieldType: BaseFloatingTextFieldType {
            switch self.key {
            case .first_name, .last_name, .role, .agree, .zip, .address, .company_name, .company_phone, .city, .state :
                return .text
            case .email:
                return .email
            case .password:
                return .password
            case .password_confirm:
                return .confirmPassword
            }
        }
        
        var registrationPriority: Int {
            switch self.key {
            case .first_name:
                return 1
            case .last_name:
                return 2
            case .email:
                return 5
            case .role:
                return 0
            case .password:
                return 6
            case .password_confirm:
                return 7
            case .agree:
                return 0
            case .zip:
                return 11
            case .address:
                return 8
            case .company_name:
                return 3
            case .company_phone:
                return 4
            case .city:
                return 9
            case .state:
                return 10
            }
        }
        
        var placeHolder: String {
            return self.key.placeHolder
        }
        
        var errorText: String?
        
        init(key: Key, text: String? = nil) {
            self.key = key
            self.text = text ?? ""
        }
    }
}
