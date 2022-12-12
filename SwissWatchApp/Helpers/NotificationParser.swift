//
//  NotificationParser.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 15.01.2021.
//  Copyright © 2021 m1c0. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationParser {
    static let shared = NotificationParser()
    
    private init() {}
    
    func handleNotification(_ content: UNNotificationContent) -> DeeplinkType? {
        if let id = content.userInfo["lot_id"] as? Int {
            if content.categoryIdentifier == "Lot" {
                return .lot(id: id)
            }
            return .bid(id: id)
        }
        return nil
    }
}
