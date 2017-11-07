//
//  SignInPreLoginViewController.swift
//  IntervalApp
//
//  Created by Chetu on 13/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import LocalAuthentication
import IntervalUIKit
import LocalAuthentication
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



//***** custom delegate method declaration *****//
protocol SignInPreLoginViewControllerDelegate {
    func loginHelpClicked()
}


class SignInPreLoginViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var userIdTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var enableTouchIdTextLabel: UILabel!
    @IBOutlet weak var enableTouchIdButton: UIButton!
    @IBOutlet weak var touchIdImageView: UIImageView!
    @IBOutlet weak var viewActionSheet: UIView!
    @IBOutlet weak var tableActionSheet: UITableView!
    
    //***** Class variables *****//
    var actionSheetTable : UITableView!
    let tableViewController = UIViewController()
    var delegate:SignInPreLoginViewControllerDelegate?
    var touchIdEnabled = false
    var activeTF:UITextField!
    var scrollView = UIScrollView()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //Omniture tracking call
        
        ADBMobile.trackAction(Constant.omnitureEvents.event81, data: nil)
        
        // omniture tracking with event 68
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar81 : Constant.omnitureCommonString.signInModal,
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event68, data: userInfo)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInPreLoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInPreLoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        
        let authenticationContext = LAContext()
        
        //***** Checking touch id sensor feature on running device *****//
        var hasTouchID:Bool = false
        var error:NSError?
        hasTouchID =  authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if(!(hasTouchID)) {
            
           /* self.touchIdImageView.isHidden = true
            self.enableTouchIdTextLabel.isHidden = true
            self.enableTouchIdButton.isHidden = true*/
        }
        self.userIdTF.delegate = self
        self.passwordTF.delegate = self
        if(self.viewActionSheet != nil){
            self.viewActionSheet.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
        var fontSize:CGFloat
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            fontSize = 25
        }
        else {
            fontSize = 15
        }
        
        //***** Creating and adding custom font with font size on placeholders fir textfield *****//
        let userNamePlaceholder = NSAttributedString(string:Constant.textFieldTitles.usernamePlaceholder, attributes: [NSForegroundColorAttributeName : UIColor.darkGray, NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeue, size: fontSize)!])
        self.userIdTF.attributedPlaceholder = userNamePlaceholder
        self.userIdTF.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        let passwordPlaceholder = NSAttributedString(string:Constant.textFieldTitles.passwordPlaceholder, attributes: [NSForegroundColorAttributeName : UIColor.darkGray, NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeue, size: fontSize)!])
        self.passwordTF.attributedPlaceholder = passwordPlaceholder
        self.passwordTF.contentVerticalAlignment = UIControlContentVerticalAlignment.center
    }
    //***** Check for frame orientation *****//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func reloadView(){
        /*let vc = ResortDirectoryViewController()
        let favoritesVC = FevoritesResortController()
        self.dismiss(animated: true) { 
            favoritesVC.viewWillAppear(true)
        }*/
    }
    
    
    func keyboardWillShow(_ sender: Notification) {
        
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            
            let userInfo: [AnyHashable: Any] = (sender as NSNotification).userInfo!
            
            let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
            let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
            if keyboardSize.height == offset.height {
                if self.view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.view.frame.origin.y -= keyboardSize.height - 200
                    })
                }
            } else {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y += keyboardSize.height - offset.height
                })
            }
        }
        
    }
    func keyboardWillHide(_ sender: Notification) {
        
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            
            let userInfo: [AnyHashable: Any] = (sender as NSNotification).userInfo!
            let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
            self.view.frame.origin.y += keyboardSize.height - 200
            
        }
    }
    //***** Method called when close button pressed to dismis the current controller from stack *****//
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    //***** Method called when sign in button pressed from prelogin screen *****//
    @IBAction func signInButtonPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        if(userIdTF.text!.characters.count > 0 && passwordTF.text?.characters.count > 0 ) {
            Helper.loginButtonPressed(sender: self, userName: userIdTF.text!, password: passwordTF.text!, completionHandler: { (success) in
                Constant.MyClassConstants.loginOriginationPoint = "Resort Directory - Sign In Modal"
                Helper.accessTokenDidChange(sender: self)
            })
        }
        else {
            guard userIdTF.text?.characters.count > 0 else {
                presentAlert(with: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyLoginIdMessage)
                return
            }
            
            guard passwordTF.text?.characters.count > 0 else {
                presentAlert(with: Constant.AlertPromtMessages.loginTitle, message: Constant.AlertMessages.emptyPasswordLoginMessage)
                return
            }
        }
        
    }
    
    //***** Method to create action sheet for to show membership for ipad screen *****//
    func createActionSheet(_ viewController:UIViewController) {
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            tableActionSheet.register(UINib(nibName: Constant.customCellNibNames.actionSheetTblCell, bundle: nil), forCellReuseIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell)
            self.view.addSubview(self.viewActionSheet)
            self.viewActionSheet.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            self.viewActionSheet.isHidden = false
        }
        
    }
    
    //***** Method to create action sheet to show membership for ipad screen *****//
    @IBAction func helpButtonClicked() {
        
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.notificationNames.showHelp), object: nil)
        //self.delegate?.loginHelpClicked()
    }
    
    //***** method to select and deselect enable touchID option *****//
    @IBAction func enableTouchIdButtonAction(_ sender: UIButton) {
        
        if(sender.isSelected == false) {
            
            sender.isSelected = true
            enableTouchIdTextLabel.textColor = IUIKColorPalette.primary1.color
            self.touchIdImageView.image = UIImage(named: Constant.assetImageNames.TouchIdOn)
            enableTouchIdButtonAction()
            touchIdEnabled = true
        }
        else {
            
            sender.isSelected = false
            self.touchIdImageView.image = UIImage(named: Constant.assetImageNames.TouchIdOff)
            enableTouchIdTextLabel.textColor = UIColor.lightGray
            enableTouchIdButtonAction()
        }
        
        
    }
    
    func  enableTouchIdButtonAction() {
        
        if(self.touchIdEnabled == false) {
            
            let userInfo: [String: String] = [
                Constant.omnitureEvars.eVar81 : Constant.omnitureCommonString.signInModal
            ]
            
            ADBMobile.trackAction(Constant.omnitureEvents.event81, data: userInfo)
            self.touchIdEnabled = true
            presentAlert(with: Constant.enableTouchIdMessages.authenticationFailedTitle, message: Constant.enableTouchIdMessages.onSuccessMessage)
        }
        else {
            self.touchIdEnabled = false
        }
    }
    
}

//***** extension class for uitextfield delegate methods definition *****//
extension SignInPreLoginViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeTF.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTF = textField
        
    }
    
}

//***** UITableview delegate methods definition here *****//
extension SignInPreLoginViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            return 44
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = Session.sharedSession.contact
        let membership = contact?.memberships![indexPath.row]
        Session.sharedSession.selectedMembership = membership
        CreateActionSheet().membershipWasSelected()
        
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

//***** UITableview datasource methods definition here *****//
extension SignInPreLoginViewController:UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let contact = Session.sharedSession.contact
        return (contact?.memberships?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let contact = Session.sharedSession.contact
        let membership = contact?.memberships![indexPath.row]
        let cell: ActionSheetTblCell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell, for: indexPath) as! ActionSheetTblCell
        cell.membershipTextLabel.text = Constant.CommonLocalisedString.memberNumber
        cell.membershipNumber.text = membership?.memberNumber
        let Product = membership?.getProductWithHighestTier()
        let productcode = Product?.productCode
        cell.membershipName.text = Product?.productName
        cell.memberImageView.image = UIImage(named: productcode!)
        return cell
        
    }
}


