

//
//  AppDelegate.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import GoogleMaps
import HockeySDK

final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Public properties
    var window: UIWindow?
    
    // MARK: - Private properties
    var appCoordinator = AppCoordinator()
    
    // MARK: - Public functions
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
        return true
    }
    
    // MARK: - Private functions
    
    private func setWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: appCoordinator.initialViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        appCoordinator.startApplication(with: navigationController)
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
        appCoordinator.applicationEnteredForeground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        appCoordinator.applicationDidEnterBackground()
    }
}

