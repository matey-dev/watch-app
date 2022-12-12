//
//  GeneralResponse.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

struct GeneralResponse: ApiResponse, Decodable {
    struct Message: Decodable {
        var message: String?
    }
    var success: Message?
    var warnings: [String: String]?
    var error: ApiError?
    
    enum CodingKeys: String, CodingKey {
        case success
        case errors
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try? cont?.decode(Message.self, forKey: .success)
        self.warnings = try? cont?.decode([String: String].self, forKey: .errors)
        self.error = try? cont?.decode(ApiError.self, forKey: .errors)
        
        if self.success == nil &&
            self.warnings == nil &&
            self.error == nil {
            throw InternalError.empty
        }
    }
}
