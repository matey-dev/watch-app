//
//  AuthTokenResponse.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

struct AuthTokenResponse: ApiResponse {
    var refresh: String?
    var auth: String?
    var expiresOn: Int?
    var role: Int?
    var warnings: [String: String]?
    var error: ApiError?
}

extension AuthTokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case refresh, auth, errors, role, expires_on
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.refresh = try? cont?.decode(String.self, forKey: .refresh)
        self.auth = try? cont?.decode(String.self, forKey: .auth)
        self.warnings = try? cont?.decode([String: String].self, forKey: .errors)
        self.error = try? cont?.decode(ApiError.self, forKey: .errors)
        
        self.role = try? cont?.decode(Int.self, forKey: .role)
        self.expiresOn = try? cont?.decode(Int.self, forKey: .expires_on)
        
        if self.refresh == nil &&
        self.auth == nil &&
        self.warnings == nil &&
        self.error == nil {
            throw InternalError.empty
        }
    }
}
