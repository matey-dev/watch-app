//
//  DeeplinkManager.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 15.01.2021.
//  Copyright © 2021 m1c0. All rights reserved.
//

import Foundation
import UserNotifications

class DeepLinkManager {
    
    static let shared = DeepLinkManager()
    
    fileprivate init() { }
    
    var deeplinkType: DeeplinkType?
    
//    func checkDeepLink() {
//        guard let deeplinkType = deeplinkType else { return }
//
//    }
    
    func handleRemoteNotification(_ notification: UNNotificationContent) -> DeeplinkType? {
        deeplinkType = NotificationParser.shared.handleNotification(notification)
        return deeplinkType
    }
}
