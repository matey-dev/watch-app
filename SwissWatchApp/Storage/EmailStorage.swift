//
//  EmailStorage.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/26/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

private let EmailKey = "k_Email"

// sourcery: AutoMockable
protocol IEmailStorage {
    func save(email: String)
    func getEmail() -> String?
}

class EmailStorage {
    var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}

extension EmailStorage: IEmailStorage {
    func save(email: String) {
        self.userDefaults.set(email, forKey: EmailKey)
    }
    
    func getEmail() -> String? {
        return self.userDefaults.object(forKey: EmailKey) as? String
    }
}
