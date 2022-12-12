//
//  SocialAuthService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/26/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias SocialNetworksUIDelegate = FacebookUIDelegate // & GoogleUIDelegate

protocol SocialAuthService: AnyObject {
    var socialTokenCallback: ((Result<SocialTokenCallbackResponse, Error>) -> Void)? { get set }
    
    func signIn(delegateForUI delegate: SocialNetworksUIDelegate)
    func signOut()
}
