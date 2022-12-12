//
//  FillLotModel.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

class FillLotModel {
    
    class CheckBox {
        enum Key: String {
            case documents, box
        }
        
        var checked: Bool
        let text: String
        let key: Key
        
        var errorText: String?
        
        init(text: String, checked: Bool? = false, key: Key) {
            self.text = text
            self.checked = checked ?? false
            self.key = key
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
        
        enum `Type` {
            case text, dropdown, textView
        }
        
        enum Key: String {
            case watch_name, watch_model, reference_no, model_year, description
            
            var placeHolder: String {
                switch self {
                case .watch_name:
                    return "Watch Brand"
                case .watch_model:
                    return "Model"
                case .reference_no:
                    return "Reference No"
                case .model_year:
                    return "Year Purchased"
                case .description:
                    return "Description"
                }
            }
        }
        
        let key: Key
        var text: String
        var id: Int?
        
        var type: Type {
            switch self.key {
            case .watch_name, .reference_no, .model_year:
                return .text
            case .watch_model:
                return .dropdown
            case .description:
                return .textView
            }
        }
        
        var baseFloatingTextFieldType: BaseFloatingTextFieldType {
            switch self.key {
            case .watch_model, .watch_name, .reference_no, .model_year, .description:
                return .text
            }
        }
        
        var priority: Int {
            switch self.key {
            case .watch_name:
                return 1
            case .watch_model:
                return 2
            case .reference_no:
                return 3
            case .model_year:
                return 4
            case .description:
                return 5
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
