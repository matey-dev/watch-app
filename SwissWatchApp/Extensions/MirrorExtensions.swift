//
//  MirrorExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

extension Mirror {
    static func reflectProperties<T>(of target: Any,
                                     matchingType type: T.Type = T.self,
                                     using closure: (T) -> Void) {
        let mirror = Mirror(reflecting: target)
        
        for child in mirror.children {
            (child.value as? T).map(closure)
        }
    }
    
    static func reflectProperties<T>(of target: Any,
                                     matchingType type: T.Type = T.self,
                                     recursively: Bool = false,
                                     using closure: (T) -> Void) {
        let mirror = Mirror(reflecting: target)
        
        for child in mirror.children {
            (child.value as? T).map(closure)
            
            if recursively {
                /*To enable recursive reflection, all we have to do
                is to call our own method again, using the value
                of each child, and using the same closure.*/
                Mirror.reflectProperties(
                    of: child.value,
                    recursively: true,
                    using: closure
                )
            }
        }
    }
    
}
