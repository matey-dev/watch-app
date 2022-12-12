//
//  ProfileResponse.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

struct ProfileResponse: ApiResponse, Decodable {
    struct Message: Decodable {
        var message: String?
    }
    
    struct Notifications: Decodable {
        var catalog_message: Int
        var archive_message: Int
        var appraisal_message: Int
    }
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var city: String?
    var state: String?
    var address: String?
    var zip: String?
    var companyName: String?
    var companyPhone: String?
    
    var success: Message?
    var notifications: Notifications?
    var warnings: [String: String]?
    var error: ApiError?
    struct Image: Decodable {
        var src: String?
    }
    
    var avatar: [Image]
    
    enum CodingKeys: String, CodingKey {
        case success, errors, messages, first_name, last_name, email, city, state, address, zip, company_name, company_phone, avatar
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.firstName = try? cont?.decode(String.self, forKey: .first_name)
        self.lastName = try? cont?.decode(String.self, forKey: .last_name)
        self.email = try? cont?.decode(String.self, forKey: .email)
        self.city = try? cont?.decode(String.self, forKey: .city)
        self.state = try? cont?.decode(String.self, forKey: .state)
        self.address = try? cont?.decode(String.self, forKey: .address)
        self.zip = try? cont?.decode(String.self, forKey: .zip)
        self.companyName = try? cont?.decode(String.self, forKey: .company_name)
        self.companyPhone = try? cont?.decode(String.self, forKey: .company_phone)
        
//        let dataCont = try? cont?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        let images = try? cont?.decode([Image].self, forKey: .avatar)
        self.avatar = images ?? []
        
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
