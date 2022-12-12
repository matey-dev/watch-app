//
//  AuthTokenService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import AuthenticationServices
import JWTDecode

typealias GetTokensCompletion = (Result<AuthTokenResponse, Error>) -> Void

struct AuthTokenParameters: Encodable {
    var email: String
    var password: String
    var request_role: String
}

struct RefreshAuthParameters: Encodable {
    var refresh_token: String
}

struct FbAuthParameters: Encodable {
    var facebook_id: String
    var access_token: String
}

struct AppleAuthParameters: Encodable {
    var apple_id: String
    var access_token: String
}

struct FbRegistrationParameters: Encodable {
    var email: String
    var facebook_id: String
    var access_token: String
    var expired_at: String
    var confirmed: String
}

struct AppleRegistrationParameters: Encodable {
    var email: String
    var apple_id: String
    var access_token: String
    var expired_at: Int
    var confirmed: String
}

protocol IAuthManager {
    var isLoggedIn: Bool { get }
    
    func getTokens(email: String,
                   password: String,
                   userType: UserType,
                   completion: GetTokensCompletion?)
    func refreshAuth(refreshToken: String, completion: GetTokensCompletion?)
    func getSavedEmail() -> String?
    func signOut()
}

final class AuthObservables {
    let stateObservable: Observable
    init(stateObservable: Observable = Observable()) {
        self.stateObservable = stateObservable
    }
}

final class AuthManager {
    let authTokenNetworking = NetworkingService<AuthTokenResponse>()
    let emailStorage: IEmailStorage = EmailStorage()
    let socialRepository: ISocialAuthRepository = SocialAuthRepository()
    let observables: AuthObservables = AuthObservables()
}

extension AuthManager: IAuthManager {
    var isLoggedIn: Bool {
        return TokensStorage.shared.currentToken().isNotNil
    }
    
    func getTokens(email: String,
                   password: String,
                   userType: UserType,
                   completion: GetTokensCompletion?) {
        let parameters = AuthTokenParameters(email: email,
                                             password: password,
                                             request_role: userType.request_role)
        self.emailStorage.save(email: email)
        self.authTokenNetworking.request(type: .POST,
                                         urlString: API.GetAuthToken,
                                         parameters: parameters) { [weak self] (authTokenResult) in
                                            self?.handle(authTokenResult: authTokenResult, completion: completion)
                                            
        }
    }
    
    func refreshAuth(refreshToken: String, completion: GetTokensCompletion?) {
        let parameters = RefreshAuthParameters(refresh_token: refreshToken)
        
        self.authTokenNetworking.request(type: .POST,
                                         urlString: API.RefreshAuth,
                                         parameters: parameters,
                                         auth: false) { [weak self] (authTokenResult) in
                                            self?.handle(authTokenResult: authTokenResult, completion: completion)
        }
    }
    
    func auth(socialService: SocialService, delegateForUI: SocialNetworksUIDelegate, completion: GetTokensCompletion?) {
        #warning("TODO: implement auth by social services")
        self.socialRepository.auth(inService: socialService, delegateForUI: delegateForUI) { [weak self] result in
            switch result {
            case .success(let fbSuccess):
                
                guard let facebookID = fbSuccess.facebookID,
                    let token = fbSuccess.token else {
                        completion?(.failure(InternalError.cantGetAuthToken))
                        return
                }
                
                self?.fbAuth(facebookId: facebookID, accessToken: token) { authTokenResult in
                    switch authTokenResult {
                    case .success(let success):
                        if let error = success.error {
                            if error.code == 404 {
                                if let email = fbSuccess.email, let expiredAt = fbSuccess.expiredAtString {
                                    self?.fbRegistration(email: email, facebookId: facebookID, accessToken: token, expiredAt: expiredAt, confirmed: "1", completion: completion)
                                } else {
                                    completion?(.failure(InternalError.cantGetEmailFromFB))
                                }
                            } else {
                                self?.handle(authTokenResult: authTokenResult, completion: completion)
                            }
                        } else if let warnings = success.warnings {
                            self?.handle(authTokenResult: authTokenResult, completion: completion)
                        } else {
                            self?.handle(authTokenResult: authTokenResult, completion: completion)
                        }
                    case .failure:
                        self?.handle(authTokenResult: authTokenResult, completion: completion)
                    }
                }
                
            case .failure(let failure):
                completion?(.failure(failure))
            }
        }
    }
    
    func signInWithApple(appleIDCredential: ASAuthorizationAppleIDCredential, completion: GetTokensCompletion?) {
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        guard let jwt = try? decode(jwt: idTokenString), let sub = jwt.subject else {
            return
        }
        
        self.appleAuth(appleId: sub, accessToken: sub) { [weak self] (authTokenResult) in
            switch authTokenResult {
            case .success(let success):
                if let error = success.error {
                    if error.code == 404 {
                        if let email = appleIDCredential.email, !email.isEmpty, let expiredAt = jwt.expiresAt?.timeIntervalSince1970 {
                            self?.appleRegistration(email: email, appleId: sub, accessToken: sub, expiredAt: Int(expiredAt), confirmed: "1", completion: completion)
                        } else {
                            completion?(.failure(InternalError.cantGetInfoFromApple))
                        }
                    } else {
                        self?.handle(authTokenResult: authTokenResult, completion: completion)
                    }
                } else if let warnings = success.warnings {
                    self?.handle(authTokenResult: authTokenResult, completion: completion)
                } else {
                    self?.handle(authTokenResult: authTokenResult, completion: completion)
                }
            case .failure:
                self?.handle(authTokenResult: authTokenResult, completion: completion)
            }
        }
    }
    
    func getSavedEmail() -> String? {
        return self.emailStorage.getEmail()
    }
    
    func signOut() {
        TokensStorage.shared.clear()
        self.socialRepository.signOut()
        self.notifyStateObservables()
    }
}

private extension AuthManager {
    func fbAuth(facebookId: String,
                accessToken: String,
                completion: GetTokensCompletion?) {
        let parameters = FbAuthParameters(facebook_id: facebookId,
                                          access_token: accessToken)
        self.authTokenNetworking.request(type: .POST,
                                         urlString: API.fbAuth,
                                         parameters: parameters) { [weak self] (authTokenResult) in
                                            self?.handle(authTokenResult: authTokenResult, completion: completion)
        }
    }
    
    func fbRegistration(email: String,
                        facebookId: String,
                        accessToken: String,
                        expiredAt: String,
                        confirmed: String,
                        completion: GetTokensCompletion?) {
        self.emailStorage.save(email: email)
        let parameters = FbRegistrationParameters(email: email,
                                                  facebook_id: facebookId,
                                                  access_token: accessToken,
                                                  expired_at: expiredAt,
                                                  confirmed: confirmed)
        self.authTokenNetworking.request(type: .POST,
                                         urlString: API.fbRegistration,
                                         parameters: parameters) { [weak self] (authTokenResult) in
                                            self?.handle(authTokenResult: authTokenResult, completion: completion)
        }
    }
    
    func appleRegistration(email: String,
                           appleId: String,
                           accessToken: String,
                           expiredAt: Int,
                           confirmed: String,
                           completion: GetTokensCompletion?) {
        self.emailStorage.save(email: email)
        let parameters = AppleRegistrationParameters(email: email,
                                                     apple_id: appleId,
                                                     access_token: accessToken,
                                                     expired_at: expiredAt,
                                                     confirmed: confirmed)
        self.authTokenNetworking.request(type: .POST,
                                         urlString: API.appleRegistration,
                                         parameters: parameters) { [weak self] (authTokenResult) in
            self?.handle(authTokenResult: authTokenResult, completion: completion)
        }
    }
    
    func appleAuth(appleId: String,
                   accessToken: String,
                   completion: GetTokensCompletion?) {
        let parameters = AppleAuthParameters(apple_id: appleId,
                                             access_token: accessToken)
        self.authTokenNetworking.request(type: .POST,
                                                     urlString: API.appleAuth,
                                                     parameters: parameters) { [weak self] (authTokenResult) in
            self?.handle(authTokenResult: authTokenResult, completion: completion)
        }
    }
    
}

extension AuthManager {
    func notifyStateObservables() {
        self.observables.stateObservable.notify(self.isLoggedIn)
    }
    
    func handle(authTokenResult: Result<AuthTokenResponse, Error>, completion: GetTokensCompletion?) {
        switch authTokenResult {
        case .success(let authTokenResponse):
            self.handle(authTokenResponse: authTokenResponse)
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        }
        self.notifyStateObservables()
        completion?(authTokenResult)
    }
    
    func handle(authTokenResponse: AuthTokenResponse) {
        authTokenResponse.auth.map { TokensStorage.shared.auth = $0 }
        authTokenResponse.refresh.map { TokensStorage.shared.refresh = $0 }
        authTokenResponse.expiresOn.map { TokensStorage.shared.expiresOn = $0 }
        authTokenResponse.role.map { TokensStorage.shared.role = $0 }
    }
}
