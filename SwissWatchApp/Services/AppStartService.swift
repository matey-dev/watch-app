//
//  AppStartService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

class AppStartService {
    enum LoggedState {
        case unathorized
        case authorized(UserType)
    }
    
    func getLoggedState(_ loggedState: ((LoggedState) -> Void)?) {
        let tokenStorage = TokensStorage.shared
        let userType = tokenStorage.userType
        tokenStorage.getToken { token in
            onMainQueue {
                if token != nil, let type = userType {
                    loggedState?(.authorized(type))
                } else {
                    loggedState?(.unathorized)
                }
            }
        }
    }
}
