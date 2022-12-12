//
//  AppStateStorage.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

private let KeyForUserType = "k_UserType"
private let KeyForAppState = "k_AppState"

private let KeyForApnAsk = "k_ApnAsk"
private let KeyForApnAskSubmit = "k_ApnAskSubmit"

enum AppState: Int {
    case authorized = 0
    case notAuthorized = -1
    case onWaitingList = -2
}

class AppStateStorage {
    static let shared = AppStateStorage()
    
    let userDefaults = UserDefaults.standard
    
    var userType: UserType {
        didSet {
            self.userDefaults.set(self.userType.rawValue, forKey: KeyForUserType)
        }
    }
    
    var appState: AppState {
        didSet {
            self.userDefaults.set(self.appState.rawValue, forKey: KeyForAppState)
        }
    }
    
    var apnAsked: Bool {
        get {
            self.userDefaults.bool(forKey: KeyForApnAsk)
        }
        set {
            self.userDefaults.setValue(newValue, forKey: KeyForApnAskSubmit)
        }
    }
    
    var apnAskedSubmit: Bool {
        get {
            self.userDefaults.bool(forKey: KeyForApnAskSubmit)
        }
        set {
            self.userDefaults.setValue(newValue, forKey: KeyForApnAskSubmit)
        }
    }
    
    private init() {
        self.userType = UserType(rawValue: self.userDefaults.integer(forKey: KeyForUserType)) ?? UserType.seller
        self.appState = AppState(rawValue: self.userDefaults.integer(forKey: KeyForAppState)) ?? AppState.notAuthorized
    }
}
