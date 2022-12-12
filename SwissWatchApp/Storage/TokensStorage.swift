//
//  TokensStorage.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

private let KeyForAuth = "k_Auth"
private let KeyForRefresh = "k_Refresh"
private let KeyForExpiresOn = "k_ExpiresOn"
private let KeyForRole = "k_Role"

protocol ITokensStorage {
    func getToken(_ token: ((String?) -> Void)?)
    func currentToken() -> String?
    func clear()
}

class TokensStorage {
    static let shared = TokensStorage()
    
    var authManager = AuthManager()
    let userDefaults = UserDefaults.standard
    
    var userType: UserType? {
        return UserType.init(rawValue: self.role)
    }
    
    var role: Int {
        didSet {
            self.userDefaults.set(self.role, forKey: KeyForRole)
        }
    }
    
    var auth: String {
        didSet {
            self.userDefaults.set(self.auth, forKey: KeyForAuth)
        }
    }
    
    var refresh: String {
        didSet {
            self.userDefaults.set(self.refresh, forKey: KeyForRefresh)
        }
    }
    
    var expiresOn: Int {
        didSet {
            self.userDefaults.set(self.expiresOn, forKey: KeyForExpiresOn)
        }
    }
    
    var expirationDate: Date {
        let date = Date(timeIntervalSince1970: Double(self.expiresOn))
        return date
    }
    
    private init() {
        self.auth = self.userDefaults.string(forKey: KeyForAuth) ?? ""
        self.refresh = self.userDefaults.string(forKey: KeyForRefresh) ?? ""
        self.expiresOn = self.userDefaults.integer(forKey: KeyForExpiresOn)
        self.role = self.userDefaults.integer(forKey: KeyForRole)
    }
}

extension TokensStorage: ITokensStorage {
    func currentToken() -> String? {
        guard !self.auth.isEmpty else { return nil }
        return self.auth
    }
    
    func getToken(_ token: ((String?) -> Void)?) {
        guard self.expirationDate > Date() else {
            if self.refresh.isEmpty {
                token?(nil)
                return
            } else {
                self.refreshToken { success in
                    if success && !self.auth.isEmpty {
                        token?(self.auth)
                    } else {
                        token?(nil)
                    }
                }
                return
            }
        }
        
        if !self.auth.isEmpty {
            token?(self.auth)
        } else {
            token?(nil)
        }
    }
    
    func clear() {
        self.auth = ""
        self.refresh = ""
        self.expiresOn = 0
        self.role = 0
    }
}

private extension TokensStorage {
    func refreshToken(_ completion: ((Bool) -> Void)?) {
        let refreshToken = self.refresh
        
        self.authManager.refreshAuth(refreshToken: refreshToken) { result in
            switch result {
            case .success:
                completion?(true)
            case .failure:
                completion?(false)
            }
        }
    }
}
