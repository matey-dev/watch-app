//
//  AppDelegate.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 3/14/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import IQKeyboardManagerSwift
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appDelegateManager: AppDelegateManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.appDelegateManager = AppDelegateManager(window: self.window)
        self.appDelegateManager?.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().delegate = self
        
        //        IQKeyboardManager.shared.enable = false
        //        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enabledToolbarClasses = [FillLotDescriptionVC.self, EditProfileVC.self, ChangePasswordView.self, LoginView.self, RegistrationView.self]
        IQKeyboardManager.shared.enabledTouchResignedClasses = [FillLotDescriptionVC.self, EditProfileVC.self, ChangePasswordView.self, LoginView.self, RegistrationView.self]
        IQKeyboardManager.shared.enabledDistanceHandlingClasses = [FillLotDescriptionVC.self, EditProfileVC.self, ChangePasswordView.self, LoginView.self, RegistrationView.self]
        DropDown.startListeningToKeyboard()
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SwissWatchApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNS Device Token: \(token)")
        PushService.shared.currentToken = token
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS Failed to register: \(error)")
        PushService.shared.failureToRegister = error
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler:
                        @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        (aps["alert"] as? String).map { message in
            if message.lowercased().contains(APNSMessages.wins.lowercased()) {
                PushNotificationService.shared.sendMessage(.bidWins)
            }
            //self.showAlert(message: message, okTitle: "...")
        }
    }
    
    func showAlert(message: String, okTitle: String? = "OK") {
        self.window?.rootViewController.map { vc in
            let view = DialogView.storyboardInstance()
            view.modalPresentationStyle = .overCurrentContext
            view.modalTransitionStyle = .crossDissolve
            view.setup(title: message,
                       button1Title: okTitle,
                       dismissButtonIsHidden: true)
            if let imagePickerVC = vc.presentedViewController as? UIImagePickerController {
                imagePickerVC.dismiss(animated: true) {
                    vc.present(view, animated: true, completion: nil)
                }
            } else {
                vc.present(view, animated: true, completion: nil)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        self.appDelegateManager?.appCoordinator?.coordinatorObservables.switchTabObservable.notify(TabBarMessage.showFirstWithDealyAndRefresh)
        
        if let deeplinkType = DeepLinkManager.shared.handleRemoteNotification(response.notification.request.content) {
            self.appDelegateManager?.appCoordinator?.handleDeeplink(deeplinkType)
        }
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint(notification.request.content)
        completionHandler([.alert, .sound, .badge])
    }
    
}
