//
//  FirstStart.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/18/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

private let KeyForFirstStart = "k_FirstStart"

class FirstStart {
    static let shared = FirstStart()
    
    let userDefaults = UserDefaults.standard
    
    var isNotFirst: Bool {
        didSet {
            self.userDefaults.set(self.isNotFirst, forKey: KeyForFirstStart)
        }
    }
    
    private init() {
        let bool = self.userDefaults.bool(forKey: KeyForFirstStart)
        self.isNotFirst = bool
    }
}
