//
//  DataExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

extension Data {
    private static let jsonDecoder = JSONDecoder()
    
    func deserialize<T: Decodable>() -> T? {
        Logger.log(logType: .deserialize, message: self.toJson())
        return try? Data.jsonDecoder.decode(T.self, from: self)
    }
    
    func toJson() -> [String: AnyObject]? {
        let jsonObject = try? JSONSerialization.jsonObject(with: self, options: [])
        return jsonObject as? [String: AnyObject]
    }
}
