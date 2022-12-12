//
//  PushService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/23/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import UserNotifications

enum PushServiceActionType {
    case updateCurrentToken(String)
    case failureToRegister(Error)
}

class PushServiceObservables {
    let stateObservable = Observable()
}

class PushService {
    static let shared = PushService()
    private init() {}
    private let networking = PushAPIService()
    
    let observables = PushServiceObservables()
    
    var currentToken: String? {
        didSet {
            self.currentToken.map { self.observables.stateObservable.notify(PushServiceActionType.updateCurrentToken($0)) }
            sendCurrentTokenToBack()
        }
    }
    var failureToRegister: Error? {
        didSet {
            self.failureToRegister.map { self.observables.stateObservable.notify(PushServiceActionType.failureToRegister($0)) }
        }
    }
    
    func handlePushRegister() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("APNS Notification settings: \(settings)")
            
            guard settings.authorizationStatus != .authorized else {
                self.getNotificationSettings()
                return
            }
            
            if AppStateStorage.shared.apnAsked || AppStateStorage.shared.apnAskedSubmit {
                self.getNotificationSettings()
                return
            }
            DispatchQueue.main.async {
                let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    self.registerForPushNotifications()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                AlertService.showAlert(style: .alert, title: "Enable Notifications", message: "Get notified about activities with your watches and bids.", actions: [okAction, cancelAction], completion: {
                    AppStateStorage.shared.apnAsked = true
                })
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                print("APNS Permission granted: \(granted)")
                
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("APNS Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func sendCurrentTokenToBack() {
        guard let token = self.currentToken else { return }
        self.networking.sendApnsToken(token: token) { [weak self] result in
            switch result {
            case .success: ()
//                let service = ApnsTestAPIService()
//                service.test { (result) in
//                    debugPrint(result)
//                }
            case .failure: ()
            }
        }
    }
}

// MARK: -

typealias PushAPIServiceCompletion = (Result<GeneralResponse, Error>) -> Void

class PushAPIService {
    private struct Parameters: Encodable {
        let token: String
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func sendApnsToken(token: String, _ completion: PushAPIServiceCompletion?) {
        let urlString = API.profileApn
        let parameters = Parameters(token: token)
        
        self.networking.request(type: .POST,
                                urlString: urlString,
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    private func handle(result: Result<GeneralResponse, Error>,
                        completion: PushAPIServiceCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        case .success:
            Logger.log(logType: .networking, message: "APNS token was successfully sent")
        }
        
        completion?(result)
    }
}
