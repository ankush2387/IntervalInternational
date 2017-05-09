

//
//  AppDelegate.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit
import XCGLogger
import GoogleMaps


// Global instance of logger
let logger = XCGLogger.default
let userDefaults = UserDefaults.standard


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
        
    {
        
         ADBMobile.setDebugLogging(true)
         Constant.MyClassConstants.runningDeviceWidth = UIScreen.main.bounds.width
        
        // Get config instance
        Constant.MyClassConstants.random = Int(arc4random_uniform(7))
        
        let config = Config.sharedInstance
        
        // setup the logger
        logger.setup( level: config.getLogLevel(), showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true)
        
        // Setup Darwin API
        DarwinSDK.sharedInstance.config( config.getEnvironment(),
            client: config.get( .DarwinClientKey ),
            secret: config.get( .DarwinSecretKey ),
            logger:logger)
        
            //  GetAccess token API call for obtain sys access token
            AuthProviderClient.getClientAccessToken( { (accessToken) in
                // Got an access token!  Save it for later use.
                //UserContext.sharedInstance.accessToken = accessToken
                Constant.MyClassConstants.systemAccessToken = accessToken
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
                },
                onError:{ (error) in
                SimpleAlert.alert((self.window?.rootViewController)!, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
            )
        
        // Apply general appearance rules
        IUIKitManager.updateAppearance()
        GMSServices.provideAPIKey(Constant.MyClassConstants.googleMapKey)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
    }


}

