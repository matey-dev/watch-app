//
//  OptionalExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    var nilIfEmpty: Optional {
        switch self {
        case .some(let collection):
            return collection.isEmpty ? nil : collection
        default:
            return nil
        }
    }
}

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? .empty
    }
}

extension Optional {
    var isNil: Bool {
        return self == nil
    }
    
    var isNotNil: Bool {
        return self != nil
    }
}
