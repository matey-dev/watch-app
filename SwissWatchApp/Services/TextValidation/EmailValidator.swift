//
//  EmailValidator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum EmailState {
    case valid
    case invalid
    case empty
}

class EmailValidator {
    func validate(email: String) -> EmailState {
        if email.isEmpty {
            return .empty
        }
        
        let emailRegEx = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email) ? .valid : .invalid
    }
}
