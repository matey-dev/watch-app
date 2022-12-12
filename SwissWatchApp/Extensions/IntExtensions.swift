//
//  IntExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

extension Int {
    func isInRange(min: Int = .zero, max: Int) -> Bool {
        return self >= min && self <= max
    }
    
    mutating func increment(_ int: Int = 1) {
        self += int
    }
    
    mutating func decrement(_ int: Int = 1) {
        self -= int
    }
}
