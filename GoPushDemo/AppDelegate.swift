//
//  AppDelegate.swift
//  GoPushDemo
//
//  Created by Nenad Ljubik on 23.11.21.
//

import UIKit
import GoPushSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        
        GoPushManager.init(accountNumber: "4321", token: "991baa3c-565c-41fc-af4b-913a7c5b71c6", deviceCountry: "Macedonia", userTags: nil, userPhone: nil, userEmail: nil, webSocketToken: "16b4817c-5646-499d-a449-655507b603e0")

        //        GoPushManager.sendSessionAnalytic(for: .sessionStarted, duration: 0, dateTime: Date())
        //        GoPushManager.sendNotificationAnalytic(for: .openedInForeground)
        //                GoPushManager.sendEventAnalytic(action: "NEW_EVENT", type: "NEW_PURCHASE", data: nil)
        //        GoPushManager.sendEventAnalytic(action: "NEW_EVENT", type: "NEW_PURCHASE", data: ["purchasedItem": "itemName2", "amountSpent": 555, "currency": "Macedonian Denar"])
        //        GoPushManager.sendEngagementAnalytic(action: "ENGAGEMENT", messageID: "test1412test", type: "CLICK", dateTime: Date())
        
        
//        GoPushManager.presentInAppMessage(type: .center)
        GoPushManager.delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - UNUserNotificationCenter Delegate Methods
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        print("device token \(token)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Opened the notification from background/inactive state")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Opened the notification from foreground")
    }
}

extension AppDelegate: GoPushManagerDelegate {
    func showLocationPrompt() {
        print("Ask For Locations Permissions")
    }
}
