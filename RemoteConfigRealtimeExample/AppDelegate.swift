//
//  AppDelegate.swift
//  RemoteConfigRealtimeExample
//
//  Created by Daiki Matsudate on 2018/11/14.
//  Copyright © 2018 Daiki Matsudate. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: {_, _ in })

    application.registerForRemoteNotifications()
    return true
  }

  // Silent push notification
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("Entire message \(userInfo)")

    if let _ = userInfo["CONFIG_STATE"] as? String {
      UserDefaults.standard.set(true, forKey: "CONFIG_STALE")
    }

    NotificationCenter.default.post(name: .init("stale"), object: nil, userInfo: userInfo)

    completionHandler(.newData)
  }
}

extension AppDelegate : MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    Messaging.messaging().subscribe(toTopic: "PUSH_RC") { error in
      print("Subscribed to PUSH_RC topic")
    }
  }

  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Received data message: \(remoteMessage.appData)")
  }
}
