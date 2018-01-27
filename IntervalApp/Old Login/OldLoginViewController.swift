//
//  LoginViewController.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import LocalAuthentication
import SVProgressHUD
import IntervalUIKit

enum LoginType: String {
    case StandardLogin    = "Standard"
    case TouchLogin    = "Touch ID"
   
}

class OldLoginViewController: UIViewController {
    //***** Outlets *****//
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var joinTodayButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    var actionSheetTable: UITableView!
    var activeField: UITextField!
    
    //***** Variables *****//
    var commonUrl: String!
    var webviewControllerTitle: String!
    var userName = ""
    var password = ""
    var touchIdButtonEnabled = false
    let tableViewController = UIViewController()
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            return UIInterfaceOrientation.portrait
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.signIn
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        // omniture tracking with event 68
//        let userInfo: [String: String] = [
////            Constant.omnitureEvars.eVar12 : "\(TouchID.isTouchIDAvailable() ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no)"
//        ]

//        ADBMobile.trackAction(Constant.omnitureEvents.event68, data: userInfo)

        //*** Set localized title for buttons ***//
        self.joinTodayButton.setTitle(Constant.buttonTitles.joinTodayTitle, for: UIControlState())
        self.privacyButton.setTitle(Constant.buttonTitles.privacyTitle, for: UIControlState())
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstTimeRunning = UserDefaults.standard.bool(forKey: Constant.MyClassConstants.firstTimeRunning)

        if !firstTimeRunning {
            presentOnboardingScreen()
        }
        
        // attempt auto touch login
//        if (TouchID.isTouchIDAvailable() && touchID.haveCredentials()) {
//            performAutoTouchLogin()
//        }
    }
    
    fileprivate func presentOnboardingScreen() {
        //blur
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.8
        blurEffectView.tag = 100
        view.addSubview(blurEffectView)
        
        //onboarding
        let storyboard: UIStoryboard = UIStoryboard(name: "LoginIPhone", bundle: nil)
        let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingBaseViewController") as! OnboardingBaseViewController
        addChildViewController(onboardingVC)
        onboardingVC.view.frame = CGRect(x: 30, y: 40, width: self.view.bounds.width - 60, height: self.view.bounds.height - 60)
        onboardingVC.view.tag = 101
        onboardingVC.handler = { result in
            UserDefaults.standard.set(true, forKey: "firstTimeRunnig")
            for v in self.view.subviews {
                if v.tag == 100 || v.tag == 101 {
                    v.removeFromSuperview()
                }
            }
        }
        
        view.addSubview(onboardingVC.view)
        onboardingVC.didMove(toParentViewController: self)

    }
    
    @IBAction func loginHelp(_ sender: AnyObject) {
        
        Constant.MyClassConstants.requestedWebviewURL = ""
        Constant.MyClassConstants.webviewTtile = ""
        
        Constant.MyClassConstants.webviewTtile = Constant.ControllerTitles.loginHelpViewController
        Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.loginHelpURL
        self.performSegue(withIdentifier: Constant.segueIdentifiers.webViewSegue, sender: nil)
        
    }
    @IBAction func privacyPolicyPressed(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.privacyPolicyWebviewSegue, sender: nil)
        
    }
    
    @IBAction func joinTodayPressed(_ sender: AnyObject) {
        
        Constant.MyClassConstants.requestedWebviewURL = ""
        Constant.MyClassConstants.webviewTtile = ""
        
        Constant.MyClassConstants.webviewTtile = Constant.ControllerTitles.JoinTodayViewController
        Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.joinTodayURL
        self.performSegue(withIdentifier: Constant.segueIdentifiers.webViewSegue, sender: nil)
    
    }
    
    func saveUsername(user: String) {
        //save username to UserDefaults
        let uName = user
        UserDefaults.standard.set(uName, forKey: Constant.MyClassConstants.userName)
        UserDefaults.standard.synchronize()
    }
    
    //***** MARK: - Busisness Actions *****//
    //***** function to call service on login button pressed *****//
    func loginButtonPressed(_ sender: AnyObject) {
        if(self.activeField != nil) {
            self.activeField.resignFirstResponder()
        }
        
        // if touch is enabled
        if(self.touchIdButtonEnabled == true) {
            guard self.userName.characters.count > 0 && self.password.characters.count > 0 else {
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyLoginIdMessage)
                return
            }
            
            let trimmedUsername = self.userName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let trimmedPassword = self.password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            performTouchLogin(trimmedUsername, password: trimmedPassword)
        }
            // touch disabled, perform standard login
        else {
            guard self.userName.characters.count > 0 else {
                 SimpleAlert.alert(self, title: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyLoginIdMessage)
                return
            }
            
            guard self.password.characters.count > 0 else {
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyPasswordLoginMessage)
                return
            }
            
            let trimmedUsername = self.userName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let trimmedPassword = self.password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            saveUsername(user: trimmedUsername)
            performStandardLogin(trimmedUsername, password: trimmedPassword)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
    }
    
    //***** function called when user resort directory button pressed *****//
    func resortDirectoryButtonPressed(_ sender: IUIKButton) {
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.resortFunctionalityCheck
        //sender.enabled = false
        if(Constant.MyClassConstants.systemAccessToken?.token != nil) {
            Helper.getResortDirectoryRegionList(viewController: self)
        } else {
//            Helper.getSystemAccessToken()
        }
    }
    // *****function called when user magazines button pressed *****//
    func magazinesButtonPressed(_ sender: AnyObject) {
    
    if(Constant.MyClassConstants.systemAccessToken?.token != nil) {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.magazinesSegue, sender: nil)
        } else {
//            Helper.getSystemAccessToken()
        }
        
    }
    //***** function called when user favorites button pressed *****//
    func favoritesButtonPressed(_ sender: AnyObject) {
        
    }
    //***** function called when user intervalHD button pressed *****//
    func intervalHDButtonPressed(_ sender: AnyObject) {
        if(Constant.MyClassConstants.systemAccessToken?.token != nil) {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.intervalHDSegue, sender: nil)
        } else {
//            Helper.getSystemAccessToken()
        }
        
    }
}

//***** MARK: Extension classes starts from here *****//

// Extension to handler login responsibilities
extension OldLoginViewController {
    fileprivate func performStandardLogin(_ username: String, password: String) {
        // login button pressed, confirm user sign-in
        Helper.loginButtonPressed(sender: self, userName: username, password: password, completionHandler: { (success) in
            if (success) {
                Constant.MyClassConstants.loginOriginationPoint = Constant.omnitureCommonString.signInPage
               ADBMobile.trackAction(Constant.omnitureEvents.event70, data: nil)
                // let the login process continue
                Helper.accessTokenDidChange(sender: self, isForSearch: false)
                
            } else {
                
            }
        })
    }
    
    fileprivate func performTouchLogin(_ username: String, password: String) {
        // login button pressed, confirm user sign-in
//        Helper.loginButtonPressed(sender: self, userName: username, password: password, completionHandler: { (success) in
//            if (success)
//            {
//                // save off credentials and authenticate user
//                self.touchID.saveAuthenticationInfo(username, password: password, completionHandler: { (success) in
//                    if (success) {
//                       Constant.MyClassConstants.loginOriginationPoint = Constant.omnitureCommonString.signInPage
//                       ADBMobile.trackAction(Constant.omnitureEvents.event69, data: nil)
//                        // let the login process continue
//                        Helper.accessTokenDidChange(sender: self)
//                    }
//                    else {
//                        DispatchQueue.main.async(execute: {
//                            SVProgressHUD.dismiss()
//                            self.hideHudAsync()
//                            SimpleAlert.alert(self, title: Constant.enableTouchIdMessages.authenticationFailedTitle, message: Constant.enableTouchIdMessages.onTouchCancelMessage)
//                        })
//                    }
//                })
//            }
//            else {
//                // go through the login and save path
//
//            }
//        })
    }
    
    fileprivate func performAutoTouchLogin() {
        // grab the saved credentials
//        self.touchID.getAuthenticationInfo({ (authInfo) in
//            if (authInfo != nil) {
//                // login button pressed, confirm user sign-in
//                Helper.loginButtonPressed(sender: self, userName: authInfo!.touchIDUser, password: authInfo!.touchIDPass, completionHandler: { (success) in
//                    if (success) {
//                        // let the login process continue
//                        Helper.accessTokenDidChange(sender: self)
//                    }
//                    else {
//
//                    }
//                })
//            }
//                // user canceled touch authentication login
//            else {
//                DispatchQueue.main.async(execute: {
//                    SimpleAlert.alert(self, title: Constant.enableTouchIdMessages.authenticationFailedTitle, message: Constant.enableTouchIdMessages.onTouchCancelMessage)
//                })
//
//                // todo turn off the 'Enable Touch Id' button
//            }
//        })
    }
}

extension OldLoginViewController: UITextFieldDelegate {
    
    func userNameDidChange(_ sender: UITextField) {
        self.activeField = sender
        self.userName = sender.text!
    }
    
    func passwordDidChange(_ sender: UITextField) {
        self.activeField = sender
        self.password = sender.text!
    }
    
}

extension OldLoginViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            return 150
        } else if (indexPath as NSIndexPath).row == 1 {
            return 244
        } else if (indexPath as NSIndexPath).row == 2 {
            return 239
        } else {
            return 80
        }
        
    }
    
}

extension OldLoginViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.headerCell, for: indexPath) as UITableViewCell
            
            return cell
        } else if (indexPath as NSIndexPath).row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.logoFormCell, for: indexPath) as! LoginFormTableViewCell
            
            //***** Setup the username *****//
            cell.delegate = self
            cell.userNameTextField.addTarget(self, action: #selector(OldLoginViewController.userNameDidChange(_:)), for: .editingChanged)
            
            // set the current username if we have credentials and touch is available
//            if TouchID.isTouchIDAvailable() && touchID.haveCredentials()
//            {
//                // set the username field
//                cell.userNameTextField.text = touchID.getAssociatedUsername() ?? ""
//                // pull back the result into the userName var
//                self.userName = cell.userNameTextField.text!
//                cell.touchIDEnabled = true
//            }
//            else
//            {
//                //set username saved on UserDefaults
//                if let savedUserName = UserDefaults.standard.string(forKey: Constant.MyClassConstants.userName) {
//                    cell.userNameTextField.text = savedUserName
//                    self.userName = savedUserName
//                }
//            }

            //***** Setup the password *****//
            cell.passwordTextField.addTarget(self, action: #selector(OldLoginViewController.passwordDidChange(_:)), for: .editingChanged)
            cell.passwordTextField.text = self.password
            
            //***** Setup the sign-in button *****//
            cell.loginButton.addTarget(self, action: #selector(OldLoginViewController.loginButtonPressed(_:)), for: .touchUpInside)
            
            //***** setup touch id action *****//
            
            return cell
        } else if (indexPath as NSIndexPath).row == 2 {
            
            //***** setting resortDirectory and three other buttons touch up action events *****//
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.cell, for: indexPath) as! LoginLowerButtonCell
            
            cell.resortDirectory.addTarget(self, action: #selector(OldLoginViewController.resortDirectoryButtonPressed(_:)), for: .touchUpInside)
            cell.magazines.addTarget(self, action: #selector(OldLoginViewController.magazinesButtonPressed(_:)), for: .touchUpInside)
            cell.intervalHD.addTarget(self, action: #selector(OldLoginViewController.intervalHDButtonPressed(_:)), for: .touchUpInside)
            cell.buildVersion.text = Helper.getBuildVersion()
            cell.buildVersion.textColor = UIColor.white
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.cell, for: indexPath) as UITableViewCell
            return cell
        }
        
    }
}

extension OldLoginViewController: LoginFormTableViewCellDelegate {
    func enableTouchIdButtonAction(_ enable: Bool) {
        //
    }
}
