//
//  UITableView+Diff.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 2/23/20.
//  Copyright © 2020 m1c0. All rights reserved.
//

//import UIKit
//import DeepDiff
//
//extension UITableView {
//    func updateWithDiff<T: Identifiable>(oldArray: [T],
//                                         newArray: [T],
//                                         updateData: () -> Void,
//                                         completion: ((Bool) -> Void)? = nil) {
//        
//        self.reload(changes: diff(old: oldArray, new: newArray),
//                    updateData: updateData,
//                    completion: completion)
//    }
//}
//
//// MARK: - Identifiable for Data models
//protocol Identifiable: Hashable, DiffAware {
//    var id: Int { get }
//}
//
//extension Identifiable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    var diffId: Int {
//        return self.hashValue
//    }
//    
//    static func compareContent(_ a: Self, _ b: Self) -> Bool {
//        return a == b
//    }
//}
