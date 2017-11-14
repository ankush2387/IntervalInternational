//
//  AppDelegate.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Appsee
import Firebase
import GoogleMaps
import HockeySDK
import UserNotifications

final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Public properties
    var window: UIWindow?
    
    // MARK: - Private properties
    var appCoordinator = AppCoordinator()
    
    // MARK: - Public functions
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setAppseeSDK()
        setXCTLogger()
        setGoogleMapsAPI()
        setHockeyManager()
        setAdobeAnalytics()
        
        // TODO: There might need to be check to see if the iPhone device is jail broken.
        // Otherwise our payloads may be intercepted from third party applications
        
        if let application = application as? IntervalApplication {
            application.callbackDelegate = appCoordinator
        }
        
        setWindow()
        setFirebasePushNotification(for: application)
        return true
    }
    
    // MARK: - Private functions
    private func setAppseeSDK() {
        Appsee.start("4c587be2b8cd474593cd47e88d4ca407")
    }
    
    private func setWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: appCoordinator.initialViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        appCoordinator.startApplication(with: navigationController)
    }
    
    private func setFirebasePushNotification(for application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
    }
    
    private func setGoogleMapsAPI() {
        GMSServices.provideAPIKey("AIzaSyCFg7iWNVVm_0tjKsBb9NFREVjQrExDlhE")
    }
    
    private func setXCTLogger() {
        Logger.sharedInstance.setup(level: Config.sharedInstance.getLogLevel(),
                                    showThreadName: true,
                                    showLevel: true,
                                    showFileNames: true,
                                    showLineNumbers: true)
    }
    
    /// Manager that facilitates app distribution through the HockeyApp service
    private func setHockeyManager() {
        BITHockeyManager.shared().configure(withIdentifier: "bde61378ac204256b1e52748bd34f688")
        BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
    /// Adobe analytics debug logging enabled if built in `debug` mode
    private func setAdobeAnalytics() {

        var enable = false
        
        #if DEBUG
            enable = true
        #endif
        
        ADBMobile.setDebugLogging(enable)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        appCoordinator.applicationEntered(state: .foreground)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        appCoordinator.applicationEntered(state: .background)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) { /* Left blank intentionally */ }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let payload = notification.request.content.userInfo
        appCoordinator.didReceive(payload, in: .foreground)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let payload = response.notification.request.content.userInfo
        appCoordinator.didReceive(payload, in: .background)
    }
}
