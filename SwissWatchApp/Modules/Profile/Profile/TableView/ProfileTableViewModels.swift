//
//  ProfileTableViewModels.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

class ProfileModel {
    class TableView {
        class Body {
            enum Key {
                case firstName, lastName, email, company, phone, city, state, address, zip
            }
            
            let key: Key
            var text: String
            
            init(key: Key, text: String? = nil) {
                self.key = key
                self.text = text ?? ""
            }
            
            var label: String {
                switch self.key {
                case .firstName:
                    return "First Name:"
                case .lastName:
                    return "Last Name:"
                case .email:
                    return "Email:"
                case .company:
                    return "Company:"
                case .phone:
                    return "Com.phone:"
                case .city:
                    return "City:"
                case .state:
                    return "State:"
                case .address:
                    return "Address:"
                case .zip:
                    return "ZIP:"
                }
            }
            
            var priority: Int {
                switch self.key {
                case .firstName:
                    return 1
                case .lastName:
                    return 2
                case .email:
                    return 3
                case .address:
                    return 4
                case .city:
                    return 5
                case .state:
                    return 6
                case .zip:
                    return 7
                case .company:
                    return 8
                case .phone:
                    return 9
                }
            }
        }
        
        class Buttons {
            enum State { case `default`, editProfile }
            
            var state: State = .default
        }
        class Main {
            enum Key {
                case firstName, lastName, email, company, phone, city, state, address, zip
            }
            
            let key: Key
            var text: String
            
            init(key: Key, text: String? = nil) {
                self.key = key
                self.text = text ?? ""
            }
            
            var label: String {
                switch self.key {
                case .firstName:
                    return "First Name:"
                case .lastName:
                    return "Last Name:"
                case .email:
                    return "Email:"
                case .company:
                    return "Company:"
                case .phone:
                    return "Com.phone:"
                case .city:
                    return "City:"
                case .state:
                    return "State:"
                case .address:
                    return "Address:"
                case .zip:
                    return "ZIP:"
                }
            }
            
            var priority: Int {
                switch self.key {
                case .firstName:
                    return 1
                case .lastName:
                    return 2
                case .email:
                    return 3
                case .address:
                    return 4
                case .city:
                    return 5
                case .state:
                    return 6
                case .zip:
                    return 7
                case .company:
                    return 8
                case .phone:
                    return 9
                }
            }
        }
        
    }
}
