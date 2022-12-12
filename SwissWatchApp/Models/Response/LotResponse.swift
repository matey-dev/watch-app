//
//  LotResponse.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/29/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

struct SellerLotResponce: ApiResponse, Decodable {
    struct Message: Decodable {
        var message: String?
    }
    
    struct Notifications: Decodable {
        var catalog_message: Int
        var archive_message: Int
        var appraisal_message: Int
    }
    
    var success: Message?
    var notifications: Notifications?
    var warnings: [String: String]?
    var error: ApiError?
    
    enum CodingKeys: String, CodingKey {
        case success, errors, messages, filters, items, data, _meta
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try? cont?.decode(Message.self, forKey: .success)
        self.warnings = try? cont?.decode([String: String].self, forKey: .errors)
        self.error = try? cont?.decode(ApiError.self, forKey: .errors)
        self.notifications = try? cont?.decode(Notifications.self, forKey: .messages)
        
        self.notifications.map { notifications in
            let s = DotNotificationService.shared
            let appraisal = notifications.appraisal_message == 0 ? false : true
            let archive = notifications.archive_message == 0 ? false : true
            let catalog = notifications.catalog_message == 0 ? false : true
            s.sendMessages([DotNotificationService.Message.appraisal(appraisal),
                            DotNotificationService.Message.archive(archive),
                            DotNotificationService.Message.catalog(catalog)])
            
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.archive_message + notifications.appraisal_message + notifications.catalog_message
            }
        }
    }
}
