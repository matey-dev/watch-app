//
//  DotsNotificationService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/28/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

class DotNotificationService {
    enum Message {
        case catalog(Bool)
        case archive(Bool)
        case appraisal(Bool)
    }
    
    static let shared = DotNotificationService()
    private init() {}
    
    let observable = Observable()
    
    func sendMessage(_ message: Message) {
        self.observable.notify(message)
    }
    
    func sendMessages(_ messages: [Message]) {
        messages.forEach {
            self.observable.notify($0)
        }
    }
}

class PushNotificationService {
    enum Message {
        case bidWins
    }
    
    static let shared = PushNotificationService()
    private init() {}
    
    let observable = Observable()
    
    func sendMessage(_ message: Message) {
        self.observable.notify(message)
    }
    
    func sendMessages(_ messages: [Message]) {
        messages.forEach {
            self.observable.notify($0)
        }
    }
}
