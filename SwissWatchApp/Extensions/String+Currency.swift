//
//  String+Currency.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 21.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import Foundation

extension String {
    var priceValue: Float? {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let decimalFilter    = CharacterSet(charactersIn:"-0123456789" + decimalSeparator)
        let number           = Float(self.components(separatedBy:decimalFilter.inverted)
            .joined(separator:""))
        return number
    }
}
