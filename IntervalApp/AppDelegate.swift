

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
import HockeySDK


// Global instance of logger
let logger = XCGLogger.default
let userDefaults = UserDefaults.standard


//@UIApplicationMain
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
                if(accessToken.token != nil){
                SupportClient.getSettings(accessToken, onSuccess: { (settings) in
                    UserContext.sharedInstance.appSettings = settings
                    if(settings.vacationSearch == nil){
                        let vacationSearchSettings = VacationSearchSettings()
                        vacationSearchSettings.vacationSearchTypes = [VacationSearchType.Combined.rawValue, VacationSearchType.Exchange.rawValue, VacationSearchType.Rental.rawValue]
                        
                        UserContext.sharedInstance.appSettings?.vacationSearch = vacationSearchSettings
                    }
                }, onError: { (error) in
                    print(error)
                    let settings = Settings()
                    UserContext.sharedInstance.appSettings = settings
                    let vacationSearchSettings = VacationSearchSettings()
                    vacationSearchSettings.vacationSearchTypes = [VacationSearchType.Combined.rawValue, VacationSearchType.Exchange.rawValue, VacationSearchType.Rental.rawValue]
                    
                    UserContext.sharedInstance.appSettings?.vacationSearch = vacationSearchSettings
                })
                }
                },
                onError:{ (error) in
                SimpleAlert.alert((self.window?.rootViewController)!, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
            )
        
        // Apply general appearance rules
        IUIKitManager.updateAppearance()
        GMSServices.provideAPIKey(Constant.MyClassConstants.googleMapKey)
        
        //Distribution through HockeyApp
        BITHockeyManager.shared().configure(withIdentifier: "bde61378ac204256b1e52748bd34f688")
        BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
         NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.applicationDidTimout), name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationDidTimoutNotification), object: nil)
        return true
    }
    
    // The callback for when the timeout was fired.
    func applicationDidTimout(notification: NSNotification) {
        if Constant.MyClassConstants.isLoginSuccessfull == true {
            UserContext.sharedInstance.signOut()
            //Remove all favorites for a user.
            Constant.MyClassConstants.favoritesResortArray.removeAll()
            Constant.MyClassConstants.favoritesResortCodeArray.removeAllObjects()
            
            //Remove available points for relinquishment program
            Constant.MyClassConstants.relinquishmentProgram = PointsProgram()
            
            //Remove all saved alerts for a user.
            Constant.MyClassConstants.getawayAlertsArray.removeAll()
            Constant.MyClassConstants.isLoginSuccessfull = false
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
            TouchID().deactivateTouchID()
            
            
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromBottom
            
            // Alert to the user
            let alertMessage = UIAlertController(title: "", message: "You have been automatically logged out due to inactivity.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (response) in
                //callback
                
            }
            alertMessage.addAction(alertAction)
            
            //Present LoginViewController
            if UIDevice.current.userInterfaceIdiom == .pad{
                let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.loginIPad, bundle: nil)
                let NavController = UINavigationController()
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.loginViewControllerIPad) as! LoginIPadViewController
                NavController.viewControllers = [viewController]
                viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
                UIApplication.shared.keyWindow?.rootViewController = NavController
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
                
                //present Alert
                viewController.present(alertMessage, animated: true, completion: nil)
            } else {
                let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.loginIPhone, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.loginViewController) as! LoginViewController
                viewController.view.layer.add(transition, forKey:Constant.MyClassConstants.switchToView)
                UIApplication.shared.keyWindow?.rootViewController = viewController
                
                //present Alert
                viewController.present(alertMessage, animated: true, completion: nil)
            }
        } 
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
    func createAppSetting()-> AppSettings{
        let appSettings = AppSettings()
//        appSettings.searchByBothEnable = false
//        appSettings.collapseBookingIntervalEnable = true
//        appSettings.checkInSelectorStrategy = CheckInSelectorStrategy.First.rawValue
        return appSettings
    }


}

