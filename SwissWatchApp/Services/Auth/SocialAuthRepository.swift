//
//  SocialAuthRepository.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/26/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum SocialService: String, CaseIterable {
    case facebook = "facebook_ios"
    case apple
    case none
    
    var serviceManager: SocialAuthService? {
        switch self {
        case .facebook:
            return FacebookAuthManager()
        case .apple:
            #warning("TODO: add apple sign in")
            return nil
        case .none:
            return nil
        }
    }
}

protocol ISocialAuthRepository {
    func auth(inService service: SocialService, delegateForUI: SocialNetworksUIDelegate, tokenCompletion: ((Result<SocialTokenCallbackResponse, Error>) -> Void)?)
    func signOut()
}

final class SocialAuthRepository {
    var socialAuthService: SocialAuthService?
    
    var currentService: SocialService = .none {
        didSet {
            self.socialAuthService = self.currentService.serviceManager
        }
    }
}

extension SocialAuthRepository: ISocialAuthRepository {
    func auth(inService service: SocialService, delegateForUI: SocialNetworksUIDelegate, tokenCompletion: ((Result<SocialTokenCallbackResponse, Error>) -> Void)?) {
        if self.currentService != service { self.currentService = service }
        
        self.socialAuthService
            .map { self.socialAuth(service: $0, delegateForUI: delegateForUI, completion: tokenCompletion) }
    }
    
    func signOut() {
        SocialService.allCases.forEach { $0.serviceManager?.signOut() }
    }
}

private extension SocialAuthRepository {
    func socialAuth(service: SocialAuthService, delegateForUI: SocialNetworksUIDelegate, completion: ((Result<SocialTokenCallbackResponse, Error>) -> Void)?) {
        service.signIn(delegateForUI: delegateForUI)
        service.socialTokenCallback = completion
    }
}
