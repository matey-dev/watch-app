//
//  Response.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol ApiResponse {
    var warnings: [String: String]? { get }
    var error: ApiError? { get }
}

struct ApiError {
    var code: Int?
    var description: String?
    var message: String?
}

extension ApiError: Decodable {
    enum CodingKeys: String, CodingKey {
        case code
        case description
        case message
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try cont?.decode(Int.self, forKey: .code)
        self.description = try? cont?.decode(String.self, forKey: .description)
        self.message = try? cont?.decode(String.self, forKey: .message)
    }
}
