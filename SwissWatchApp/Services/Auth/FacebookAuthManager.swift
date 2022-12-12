//
//  FacebookAuthManager.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/26/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import FacebookLogin
import FBSDKCoreKit

protocol FacebookUIDelegate where Self: UIViewController {}

struct SocialTokenCallbackResponse {
    var facebookID: String?
    var email: String?
    var token: String?
    var expiredAt: Int?
    var expiredAtString: String? {
        guard let expiredAt = self.expiredAt else { return nil }
        return String(expiredAt)
    }
    var confirmed: Int?
}

final class FacebookAuthManager: NSObject {
    var socialTokenCallback: ((Result<SocialTokenCallbackResponse, Error>) -> Void)?
    let facebookAuthInstance = LoginManager()
}

extension FacebookAuthManager: SocialAuthService {
    func signIn(delegateForUI delegate: SocialNetworksUIDelegate) {
        
        self.facebookAuthInstance.logIn(permissions: [.publicProfile, .email], viewController: delegate) { [weak self] loginResult in
            
            switch loginResult {
            case .failed(let error):
                self?.socialTokenCallback?(.failure(error))
            case .cancelled:
                self?.socialTokenCallback?(.failure(InternalError.cancelled))
            case .success(let permissions):
                
                var fbResponse = SocialTokenCallbackResponse()
                fbResponse.expiredAt = Int(permissions.token.expirationDate.timeIntervalSince1970)
                fbResponse.token = permissions.token.tokenString
                
                self?.fetchUser { (userID, email) in
                    fbResponse.facebookID = userID
                    fbResponse.email = email
                    
                    self?.socialTokenCallback?(.success(fbResponse)) // permissions.token.authenticationToken
                }
            }
        }
    }
    
    func signOut() {
        self.facebookAuthInstance.logOut()
    }
}

private extension FacebookAuthManager {
    func fetchUser(_ completion: ((_ id: String?, _ email: String?) -> Void)?) {
        let connection = GraphRequestConnection()
        let request = GraphRequest(graphPath: "/me", parameters: ["fields": "id,email,name"])
        connection.add(request) { (graphRequestConnection, result, error) in
            if let dic = result as? [AnyHashable: AnyObject] {
                let userID = dic["id"] as? String
                let email = dic["email"] as? String
                completion?(userID, email)
            }
        }
        connection.start()
    }
}
