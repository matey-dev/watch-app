//
//  URLRequestExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

extension URLRequest {
    static let jsonEncoder = JSONEncoder()

    init?<RequestParameters: Encodable>(type: RequestType,
                                        urlString: String,
                                        parameters: RequestParameters) {
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        self.init(url: url)
        self.httpMethod = type.rawValue
        if type == .POST {
            self.httpBody = try? URLRequest.jsonEncoder.encode(parameters)
            self.addValue("application/json", forHTTPHeaderField: "Content-Type")
            self.addValue("application/json", forHTTPHeaderField: "Accept")
        }
    }
}
