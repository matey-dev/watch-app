//
//  Logger.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

enum LogType: String {
    case networking = "NETWORKING"
    case deserialize = "DESERIALIZE"
    case error = "ERROR"
    case other = "OTHER"
}

enum Logger {
    static func log(logType: LogType = .other, message: Any?) {
        guard let message = message else {
            return
        }
        
        let logMessage = "\(Date().description) | [\(logType.rawValue)]: \(message)"
        print(logMessage)
    }
    
    static func logRequest(_ urlString: String, _ parameters: Encodable) {
        self.log(logType: .networking, message: "request started: \(urlString)")
        self.log(logType: .networking, message: "parameters is \(parameters)")
    }
    
    static func logResponse(_ requestDate: Date, _ urlString: String, _ data: Data?, _ statusCode: Int) {
        let timeDifference = Int(Date().timeIntervalSince(requestDate) * 1_000)
        self.log(logType: .networking, message: "request completed (\(timeDifference) ms): \(urlString)")
        self.log(logType: .networking, message: "status code \(statusCode)")
        self.log(logType: .networking, message: data?.toJson())
    }
}
