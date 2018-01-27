//
//  LoginIPadViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/18/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import LocalAuthentication
import SVProgressHUD
import IntervalUIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class LoginIPadViewController: UIViewController {
    //*****IBOutlets for controls*****//
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var viewSignIn: UIView!
    @IBOutlet weak var viewLower: UIView!
    @IBOutlet weak var viewActionSheet: UIView!
    @IBOutlet weak var tableActionSheet: UITableView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var enableTouchIdTextLabel: UILabel!
    @IBOutlet weak var touchIdImageView: UIImageView!
    @IBOutlet weak var enableTouchIdButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var joinTodayButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    @IBOutlet var resortDirectory: UIButton!
    @IBOutlet var favorites: UIButton!
    @IBOutlet var intervalHD: UIButton!
    @IBOutlet var magazines: UIButton!
    
    //*****IBOutlets for constraints*****//
    @IBOutlet weak var viewSignInTrailing: NSLayoutConstraint!
    @IBOutlet weak var viewSignInTop: NSLayoutConstraint!
    @IBOutlet weak var viewLowerLeading: NSLayoutConstraint!
    @IBOutlet weak var viewLowerTop: NSLayoutConstraint!
    @IBOutlet weak var viewLowerHeight: NSLayoutConstraint!
    @IBOutlet weak var resortTop: NSLayoutConstraint!
    @IBOutlet weak var favoritesTop: NSLayoutConstraint!
    @IBOutlet weak var legalTrailing: NSLayoutConstraint!
    
    //***** Variables *****//
    var userName: String?
    var password: String?
    var activeAlertCount = 0
    var alertsDictionary = NSMutableDictionary()
    
    // computed property for touchIDEnabled, will turn on/off the checkbox
    var touchIDEnabled: Bool = false {
        didSet {
            enableTouchIdButton.isSelected = touchIDEnabled
            enableTouchIdButton(touchIDEnabled)
        }
    }
    
    //*****Called to check the screen orientation*****//
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            if(self.view.bounds.size.width > self.view.bounds.size.height) {
                getScreenInLandscape()
            } else {
                getScreenInPotrait()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //**** Set UI Elements ****//
        
        buildLabel.text = Helper.getBuildVersion()
        self.viewSignIn.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.viewLower.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.viewActionSheet.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        //**** Set Localised Title ****//
        self.userNameTextField.placeholder = Constant.CommonLocalisedString.user_id
        self.passwordTextField.placeholder = Constant.CommonLocalisedString.user_password
        self.helpButton.setTitle(Constant.buttonTitles.help, for: UIControlState())
        self.joinTodayButton.setTitle(Constant.buttonTitles.joinTodayTitle, for: UIControlState())
        self.signInButton.setTitle(Constant.CommonLocalisedString.sign_in, for: UIControlState())
        resortDirectory .setTitle(Constant.buttonTitles.resortTitle, for: UIControlState())
        intervalHD.setTitle(Constant.buttonTitles.intervalHDTitle, for: UIControlState())
        magazines.setTitle(Constant.buttonTitles.magazineTitle, for: UIControlState())
        
        //set UserName if previously saved
        if let userName = UserDefaults.standard.string(forKey: Constant.MyClassConstants.userName) {
            self.userNameTextField.text = userName
        }
        
        //***** Setting font size according to the running device width *****//
        
        enableTouchIdTextLabel.textColor = IUIKColorPalette.primary1.color
        
        //***** checking touch id sensor feature on running device *****//
        
        var hasTouchID: Bool = false
        //        hasTouchID =  TouchID.isTouchIDAvailable()
        //        if(!(hasTouchID)){
        //            self.touchIdImageView.isHidden = true
        //            self.enableTouchIdTextLabel.isHidden = true
        //            self.enableTouchIdButton.isHidden = true
        //        }
        
        tableActionSheet.register(UINib(nibName: Constant.customCellNibNames.actionSheetTblCell, bundle: nil), forCellReuseIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell)
        tableActionSheet.tag = 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstTimeRunning = UserDefaults.standard.bool(forKey: Constant.MyClassConstants.firstTimeRunning)
        
        if !firstTimeRunning {
            presentOnboardingScreen()
        }
        
        // attemp to auto-login the user if touch is enabled and credentails were saved
        //        if (TouchID.isTouchIDAvailable() && touchID.haveCredentials()) {
        //            userNameTextField.text = touchID.getAssociatedUsername() ?? ""
        //            enableTouchIdButton(true)
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
        let viewWidth = (self.view.bounds.width / 2) + 100
        let viewHeight = (self.view.bounds.height / 2) + 100
        onboardingVC.view.frame = CGRect(x: (self.view.bounds.midX) - (viewWidth / 2), y: self.view.bounds.midY - (viewHeight / 2), width: viewWidth, height: viewHeight)
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
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
            getScreenInLandscape()
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
            getScreenInPotrait()
        }
    }
    
    func saveUsername(user: String) {
        //save username to UserDefaults
        let uName = user
        UserDefaults.standard.set(uName, forKey: Constant.MyClassConstants.userName)
        UserDefaults.standard.synchronize()
    }
    
    func getScreenInLandscape() {
        legalTrailing.constant = 350
        viewSignInTrailing.constant = 500
        viewLowerLeading.constant = 500
        
        viewLowerTop.constant = 250
        if (viewActionSheet.isHidden == false) {
            viewActionSheet.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        }
        //UIView.animateWithDuration(0.3) {
        self.view.layoutIfNeeded()
        //}
    }
    
    func getScreenInPotrait() {
        legalTrailing.constant = 30
        viewSignInTrailing.constant = 184
        viewLowerLeading.constant = 184
        viewLowerTop.constant = 478
        if (viewActionSheet.isHidden == false) {
            viewActionSheet.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        }
        //UIView.animateWithDuration(0.3) {
        self.view.layoutIfNeeded()
        //}
    }
    
    //***** MARK: - Business Actions *****//
    //***** function to call service on login button pressed *****//
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        guard (self.userNameTextField.text?.characters.count > 0) else {
            SimpleAlert.alert(self, title: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyLoginIdMessage)
            return
            
        }
        guard (self.passwordTextField.text?.characters.count > 0) else {
            SimpleAlert.alert(self, title: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyPasswordLoginMessage)
            return
        }
        
        let trimmedUsername = self.userNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let trimmedPassword = self.passwordTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // make sure we have valid text to send along
        guard trimmedUsername != nil && trimmedPassword != nil else {
            return
        }
        
        // if touch is enabled
        if(self.touchIDEnabled == true) {
            performTouchLogin(trimmedUsername!, password: trimmedPassword!)
        }
            // touch disabled, perform standard login
        else {
            saveUsername(user: trimmedUsername!)
            performStandardLogin(trimmedUsername!, password: trimmedPassword!)
        }
    }
    
    //**** function for Login Help ****//
    @IBAction func loginHelp(_ sender: AnyObject) {
        
        Constant.MyClassConstants.requestedWebviewURL = ""
        Constant.MyClassConstants.webviewTtile = ""
        
        Constant.MyClassConstants.webviewTtile = Constant.ControllerTitles.loginHelpViewController
        Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.loginHelpURL
        self.performSegue(withIdentifier: Constant.segueIdentifiers.webViewSegue, sender: nil)
        
    }
    
    //***** function called when user resort directory button pressed *****//
    @IBAction func resortDirectoryButtonPressed(_ sender: AnyObject) {
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        Constant.MyClassConstants.runningFunctionality = Constant.sideMenuTitles.resortDirectory
        Helper.getResortDirectoryRegionList(viewController: self)
    }
    
    //***** function called when IntervalHD button pressed *****//
    
    @IBAction func intervalHDButtonPressed(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.intervalHDIpadSegue, sender: nil)
    }
    
    //**** Function called when magazines button is pressed *****//
    
    @IBAction func magazinesButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.magazinesSegue, sender: nil)
    }
    
    //**** function for Join Today ****//
    @IBAction func joinTodayPressed(_ sender: AnyObject) {
        
        Constant.MyClassConstants.requestedWebviewURL = ""
        Constant.MyClassConstants.webviewTtile = ""
        
        Constant.MyClassConstants.webviewTtile = Constant.ControllerTitles.JoinTodayViewController
        Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.joinTodayURL
        self.performSegue(withIdentifier: Constant.segueIdentifiers.webViewSegue, sender: nil)
        
    }
    
    //**** function for privacy button ****//
    @IBAction func openPrivacyPolicy() {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.privacyPolicyWebviewSegue, sender: nil)
    }
    
    //***** function to create an action sheet for iPad*****//
    func createActionSheet(_ viewController: UIViewController) {
        self.view.addSubview(self.viewActionSheet)
        self.viewActionSheet.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.viewActionSheet.isHidden = false
    }
    //***** function to get profile when we have found valid access token from server *****//
    func accessTokenDidChange() {
        
        //***** Try to do the OAuth Request to obtain an access token *****//
        UserClient.getCurrentProfile(Session.sharedSession.userAccessToken,
                                     onSuccess: {(contact) in
                                        // Got an access token!  Save it for later use.
                                        SVProgressHUD.dismiss()
                                        self.hideHudAsync()
                                        Session.sharedSession.contact = contact
                                        
                                        //***** Next, get the contact information.  See how many memberships this user has. *****//
                                        self.perform(#selector(LoginIPadViewController.contactDidChange), with: nil, afterDelay: 0.5)
        },
                                     onError: {(error) in
                                        SVProgressHUD.dismiss()
                                        self.hideHudAsync()
                                        Logger.sharedInstance.warning(error.description)
                                        SimpleAlert.alert(self, title: Constant.AlertErrorMessages.loginFailed, message: error.localizedDescription)
        }
        )
        
    }
    
    //***** functin called when we have found valid profileCurrent for user *****//
    func contactDidChange() {
        
        //***** If this contact has more than one membership, then show the Choose Member form.Otherwise, select the default (only) membership and continue.  There must always be at lease one membership. *****//
        if let contact = Session.sharedSession.contact {
            
            if contact.hasMembership() {
                
                if contact.memberships!.count == 1 {
                    
                    Session.sharedSession.selectedMembership = contact.memberships![0]
                    //self.membershipWasSelected()
                    
                    CreateActionSheet().membershipWasSelected(isForSearchVacation: false)
                    
                } else {
                    
                    //self.createActionSheet(self)
                    //***** TODO: Display Modal to allow the user to select a membership! *****//
                    //self.CreateActionSheet(self)
                    membershipWasSelected()
                }
            } else {
                
                Logger.sharedInstance.error("The contact \(contact.contactId) has no membership information!")
                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.loginFailed, message: Constant.AlertMessages.noMembershipMessage)
            }
        }
        
    }
    
    fileprivate func enableTouchIdButton(_ enable: Bool) {
        if (enable) {
            enableTouchIdTextLabel.textColor = IUIKColorPalette.primary1.color
            self.touchIdImageView.image = UIImage(named: Constant.assetImageNames.TouchIdOn)
            OldLoginViewController().touchIdButtonEnabled = true
        } else {
            self.touchIdImageView.image = UIImage(named: Constant.assetImageNames.TouchIdOff)
            enableTouchIdTextLabel.textColor = IUIKColorPalette.primary1.color
        }
    }
    
    @IBAction func enableTouchIdButtonAction(_ sender: UIButton) {
        
        //***** selecting and deselecting enable touchID option *****//
        sender.isSelected = !sender.isSelected
        
        // only display the alert when the button is pressed by the user
        if (sender.isSelected) {
            SimpleAlert.alert(self, title: Constant.enableTouchIdMessages.authenticationFailedTitle, message: Constant.enableTouchIdMessages.onSuccessMessage)
        } else {
            // clear the user's credentials when they turn off the toggle
            //            touchID.deactivateTouchID()
        }
        
        // call the computed property to trigger the setting of touchid
        self.touchIDEnabled = sender.isSelected
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.view.endEditing(true)
        self.viewActionSheet.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func membershipWasSelected() {
        
        //***** Update the API session for the current access token *****//
        let context = Session.sharedSession
        
        UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
            Session.sharedSession.selectedMembership = membership
                                    //***** Favorites resort API call after successfull call *****//
                                    Helper.getUserFavorites {[unowned self] error in
                                        if case .some = error {
                                            self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                                        }
                                    }
                                    //***** Get upcoming trips for user API call after successfull call *****//
                                    Helper.getUpcomingTripsForUser {[unowned self] error in
                                        if case .some = error {
                                            self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                                        }
                                    }
                                    Constant.MyClassConstants.isLoginSuccessfull = true
                                    self.performSegue(withIdentifier: Constant.segueIdentifiers.dashboradSegueIdentifier, sender: nil)
        },
                                   onError: {[unowned self](_) in
                                    self.presentErrorAlert(UserFacingCommonError.generic)
            }
        )
    }
    func callForIndividualAlert(_ alert: RentalAlert) {
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        RentalClient.getAlert(Session.sharedSession.userAccessToken, alertId: alert.alertId!, onSuccess: { (response) in
            
            var alertVacationInfo = RentalAlert()
            alertVacationInfo = response
            self.alertsDictionary .setValue(alertVacationInfo, forKey: String(describing: alert.alertId!))
            self.searchVacationPressed(alert)
        }) { (_) in
            
        }
        
    }
    
    func searchVacationPressed(_ alert: RentalAlert) {
        var getawayAlert = RentalAlert()
        getawayAlert = self.alertsDictionary.value(forKey: String(describing: alert.alertId!)) as! RentalAlert
        
        let searchResortRequest = RentalSearchDatesRequest()
        searchResortRequest.checkInToDate = Helper.convertStringToDate(dateString: getawayAlert.latestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
        searchResortRequest.checkInFromDate = Helper.convertStringToDate(dateString: getawayAlert.earliestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
        searchResortRequest.resorts = getawayAlert.resorts
        searchResortRequest.destinations = getawayAlert.destinations
        
        if Reachability.isConnectedToNetwork() == true {
            
            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: searchResortRequest, onSuccess: { (searchDates) in
                Constant.MyClassConstants.resortCodesArray = searchDates.resortCodes
                Constant.MyClassConstants.alertsResortCodeDictionary.setValue(searchDates.resortCodes, forKey: String(describing: alert.alertId!))
                Constant.MyClassConstants.alertsSearchDatesDictionary.setValue(searchDates.checkInDates, forKey: String(describing: alert.alertId!))
                
                if(searchDates.checkInDates.count == 0 || alert.alertId == 123456) {
                    
                } else {
                    if Constant.MyClassConstants.activeAlertsArray.count < 1 { //TODO - JHON: forcing alerts count to be one. fix when push notifications is working.
                        Constant.MyClassConstants.activeAlertsArray.add(alert)
                    }
                }
                if(self.activeAlertCount < Constant.MyClassConstants.getawayAlertsArray.count - 1) {
                    self.activeAlertCount = self.activeAlertCount + 1
                    self.getStatusForAllAlerts()
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
                }
            }) { (_) in
                
            }
        } else {
            
        }
    }
    
    func getStatusForAllAlerts() {
        if(Constant.MyClassConstants.getawayAlertsArray.count > 0) {
            self.callForIndividualAlert(Constant.MyClassConstants.getawayAlertsArray[activeAlertCount])
        }
    }
}
//***** MARK: Extension classes starts from here *****//

// extension to handle login responsibilities
extension LoginIPadViewController {
    fileprivate func performStandardLogin(_ username: String, password: String) {
        // login button pressed, confirm user sign-in
        Constant.MyClassConstants.loginOriginationPoint = Constant.omnitureCommonString.signInPage
        Helper.loginButtonPressed(sender: self, userName: username, password: password, completionHandler: { (success) in
            if (success) {
                // let the login process continue
                Helper.accessTokenDidChange(sender: self, isForSearch: false)
            } else {
                
            }
        })
    }
    
    fileprivate func performTouchLogin(_ username: String, password: String) {
        // login button pressed, confirm user sign-in
        //        Helper.loginButtonPressed(sender: self, userName: username, password: password, completionHandler: { (success) in
        ////            if (success)
        ////            {
        ////                // save off credentials and authenticate user
        ////                Constant.MyClassConstants.loginOriginationPoint = Constant.omnitureCommonString.signInPage
        ////                self.touchID.saveAuthenticationInfo(username, password: password, completionHandler: { (success) in
        ////                    if (success) {
        ////
        ////                        // let the login process continue
        ////                        Helper.accessTokenDidChange(sender: self)
        ////                    }
        ////                    else {
        ////                        DispatchQueue.main.async(execute: {
        ////                            SVProgressHUD.dismiss()
        ////                            self.hideHudAsync()
        ////                            SimpleAlert.alert(self, title: Constant.enableTouchIdMessages.authenticationFailedTitle, message: Constant.enableTouchIdMessages.onTouchCancelMessage)
        ////                        })
        ////                    }
        ////                })
        ////            }
        ////            else {
        ////                // go through the login and save path
        ////                self.touchIDEnabled = false;
        ////            }
        ////        })
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
        // user canceled touch authentication login
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

extension LoginIPadViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == 1) {
            self.userName = textField.text
        } else {
            self.password = textField.text
        }
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginIPadViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = Session.sharedSession.contact
        let membership = contact?.memberships![indexPath.row]
        Session.sharedSession.selectedMembership = membership
        membershipWasSelected()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableActionSheet.bounds.size.width, height: 44))
        
        let labelHeader = UILabel(frame: CGRect(x: 0, y: 0, width: tableActionSheet.bounds.size.width, height: 44))
        labelHeader.text = Constant.actionSheetAttributedString.selectMembership
        labelHeader.textColor = UIColor.black
        labelHeader.textAlignment = NSTextAlignment.center
        
        viewHeader.addSubview(labelHeader)
        
        viewHeader.backgroundColor = IUIKColorPalette.titleBackdrop.color
        return viewHeader
    }
}

extension LoginIPadViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let contact = Session.sharedSession.contact
        return (contact?.memberships?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = Session.sharedSession.contact
        let membership = contact?.memberships![indexPath.row]
        let cell: ActionSheetTblCell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell, for: indexPath) as! ActionSheetTblCell
        
        cell.membershipTextLabel.text = Constant.CommonLocalisedString.memberNumber
        cell.membershipNumber.text = membership?.memberNumber
        let Product = membership?.getProductWithHighestTier()
        let productcode = Product?.productCode
        cell.membershipName.text = Product?.productName
        if(Product != nil) {
            cell.memberImageView.image = UIImage(named: productcode!)
        }
        return cell
        
    }
}
