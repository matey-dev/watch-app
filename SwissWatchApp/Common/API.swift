//
//  API.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum API {
    static let baseUrl = "https://api.app.watchvalue.com"
//    static let baseUrl = "http://192.168.1.62:8888"
    
    //static let baseUrl = "https://api.app.watchquote.com"
    //static let baseUrl = "http://api.watch.com.dev11.vintagedev.com.ua"
    private static let currentVersion = "/v1"
    private static let baseWithVersion = baseUrl + currentVersion
    
    static let GetAuthToken = baseWithVersion + "/get-auth-token"
    static let Registration = baseWithVersion + "/registration"
    static let Activation = baseWithVersion + "/activation"
    static let RefreshAuth = baseWithVersion + "/refresh-auth"
    static let fbAuth = baseWithVersion + "/get-social-auth-token"
    static let appleAuth = baseWithVersion + "/get-apple-auth-token"
    static let fbRegistration = baseWithVersion + "/facebook-registration"
    static let appleRegistration = baseWithVersion + "/apple-registration"
    
    static let SetPassword = baseWithVersion + "/set-password"
    static let ResetPassword = baseWithVersion + "/reset-password"
    static let ChangePassword = baseWithVersion + "/change-password"
    static let ResendKey = baseWithVersion + "/resend-key"
    static let ValidateResetKey = baseWithVersion + "/validate-reset-key"
    
    static let ProfileActivation = baseWithVersion + "/activation"
    
    static let sellerCatalog = baseWithVersion + "/seller-catalog"
    static let sellerArchive = baseWithVersion + "/seller-archive"
    static let buyerCatalog = baseWithVersion + "/buyer-catalog"
    static let buyerArchive = baseWithVersion + "/buyer-archive"
    static let buyerAppraisals = baseWithVersion + "/buyer-appraisals"
    
    static let addLot = baseWithVersion + "/add-lot"
    static let addApn = baseWithVersion + "/apn-send"
    static let addBet = baseWithVersion + "/add-bet"
    static let sellerBrands = baseWithVersion + "/seller-brands"
    static let buyerFilters = baseWithVersion + "/buyer-filters"
    static let deleteLot = baseWithVersion + "/delete-lot"
    static let flagLot = baseWithVersion + "/flag-lot"
    static let getSellerLot = baseWithVersion + "/seller-catalog/seller-lot/"
    static let getDealerLot = baseWithVersion + "/buyer-catalog/buyer-lot/"
    static let reactivateLot = baseWithVersion + "/reactivate-lot"
    
    static let chooseBet = baseWithVersion + "/choose-bet"
    
    static let sellerProfile = baseWithVersion + "/seller-profile"
    static let dealerProfile = baseWithVersion + "/buyer-profile"
    static let deleteProfile = baseWithVersion + "/delete-profile"
    static let updatteProfile = baseWithVersion + "/update-profile"
    
    static let privacyPolicy = "https://watchvalue.com/privacy"
    static let accountRecoveryTeam = "https://watchvalue.com"
    static let supportMail = "support@watchvalue.com"
  
    static let profileApn = baseWithVersion + "/profile-apn"
    static let testApn = baseWithVersion + "/apn-test"
    
    enum StatusCode {
        static let Success = 200
        static let Error = 422
    }
    
    enum Status {
        case ok, error
        
        init(code: Int) {
            if code < 300 && code > 199 {
                self = .ok
            } else {
                self = .error
            }
        }
        
        var isOk: Bool {
            return self == .ok ? true : false
        }
    }
}
