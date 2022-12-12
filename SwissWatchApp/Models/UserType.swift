//
//  UserType.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum UserType: Int {
    case dealer = 1
    case seller = 2
    
    var request_role: String {
        switch self {
        case .seller:
            return "2"
        case .dealer:
            return "1"
        }
    }
}
