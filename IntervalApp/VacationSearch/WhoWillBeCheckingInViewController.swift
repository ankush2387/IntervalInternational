//
//  WhoWillBeCheckingInViewController.swift
//  IntervalApp
//
//  Created by Chetu on 03/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD
import SDWebImage
import RealmSwift

class WhoWillBeCheckingInViewController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var resortHoldingTimeLabel: UILabel!
    @IBOutlet weak var checkingInUserTBLview: UITableView!
    @IBOutlet weak var proceedToCheckoutButton: IUIKButton!
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var filterRelinquishments = ExchangeRelinquishment()
    
    //Class variables
    var isKeyBoardOpen = false
    var moved: Bool = false
    var activeField:UITextField?
    var cellUsedFor = ""
    var proceedStatus = false
    var requiredSectionIntTBLview = 2
    var whoWillBeCheckingInSelectedIndex = -1
    var pickerBaseView:UIView!
    var pickerView:UIPickerView!
    var hideStatus = false
    var dropDownSelectionRow = -1
    var dropDownSelectionSection = -1
    var holdingTimer:Timer!
    var holdingTime = 2
    var decreaseValue = 1
    var selectedCountryIndex: Int?

    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableGuestFormCheckout), name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call country api
        Helper.getCountry(viewController: self)
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.vacationSearchCheckingIn,
            ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)

        
        // omniture tracking with event 37
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products : Constant.MyClassConstants.selectedResort.resortCode!,
            Constant.omnitureEvars.eVar37 : Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex),
            Constant.omnitureEvars.eVar39 : "",
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event37, data: userInfo)

        
        self.proceedToCheckoutButton.isEnabled = false
        self.proceedToCheckoutButton.alpha = 0.5
        Constant.startTimer()
        self.title = Constant.ControllerTitles.whoWillBeCheckingInControllerTitle
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(WhoWillBeCheckingInViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
    }
    
    
    func keyboardWasShown(aNotification: NSNotification) {
        
        isKeyBoardOpen = true
    
        if(self.moved) {
            let info = aNotification.userInfo as! [String: AnyObject],
            kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
            contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        
            self.checkingInUserTBLview.contentInset = contentInsets
            self.checkingInUserTBLview.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= kbSize.height
        
        
            if !aRect.contains(activeField!.frame.origin) {
           
                self.checkingInUserTBLview.scrollRectToVisible(activeField!.frame, animated: true)
           
            }
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        isKeyBoardOpen = false
        
        if(self.moved) {
            self.moved = false
            let contentInsets = UIEdgeInsets.zero
            self.checkingInUserTBLview.contentInset = contentInsets
            self.checkingInUserTBLview.scrollIndicatorInsets = contentInsets
        }
    }
    
    
    func validateUsername(str: String) -> Bool
    {
        do
        {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z\\_]{1,18}$", options: .caseInsensitive)
            if regex.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count)).count > 0 {return true}
        }
        catch {}
        return false
    }
    //***** Function to check if the email entered by user is an valid email address. *****//
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func validatePhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "[^0-9]"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
        
        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        // add a toolbar with a done button above the number pad
        textField.inputAccessoryView = keypadToolbar
    }
    
    func guestFormCheckForDetails() ->Bool {
        
        if(Constant.GetawaySearchResultGuestFormDetailData.firstName != "" && Constant.GetawaySearchResultGuestFormDetailData.lastName != "" && Constant.GetawaySearchResultGuestFormDetailData.country != "" && Constant.GetawaySearchResultGuestFormDetailData.address1 != "" && Constant.GetawaySearchResultGuestFormDetailData.address2 != "" && Constant.GetawaySearchResultGuestFormDetailData.city != "" && Constant.GetawaySearchResultGuestFormDetailData.state != "" && Constant.GetawaySearchResultGuestFormDetailData.pinCode != "" && Constant.GetawaySearchResultGuestFormDetailData.email != "" && Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber != "" && Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber != "") {
            
            if(proceedStatus) {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
                proceedStatus = true
            }
            else {
                
                
            }
            
            
        }
        else {
            proceedStatus = false
        }
        
        return proceedStatus
    }
 
    
    //***** Checkout using guest. *****//
    func enableGuestFormCheckout() {
        
        self.proceedToCheckoutButton.isEnabled = true
        self.proceedToCheckoutButton.alpha = 1.0
    }
    
    //***** Notification for update timer.*****//
    func updateResortHoldingTime() {
        if(Constant.holdingTime != 0){
            self.resortHoldingTimeLabel.text = Constant.holdingResortForRemainingMinutes
        }else{
            SimpleAlert.alertTodismissController(self, title: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Back button pressed.*****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: self.view)
        if(Constant.MyClassConstants.isFromExchange){
            Constant.holdingTimer.invalidate()
            
            ExchangeProcessClient.backToChooseExchange(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, onSuccess:{(response) in
                
                Constant.MyClassConstants.selectedCreditCard.removeAll()
                Helper.hideProgressBar(senderView: self)
                _ = self.navigationController?.popViewController(animated: true)
                
            }, onError: {(error) in
                
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title: "Who will be checking in", message: error.localizedDescription)
            })
        }else{
        Constant.holdingTimer.invalidate()
        
        RentalProcessClient.backToChooseRental(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess:{(response) in
            
                Constant.MyClassConstants.selectedCreditCard.removeAll()
                Helper.removeStoredGuestFormDetials()
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                 _ = self.navigationController?.popViewController(animated: true)
            
            }, onError: {(error) in
              
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                SimpleAlert.alert(self, title: Constant.ControllerTitles.whoWillBeCheckingInControllerTitle, message: Constant.AlertMessages.operationFailedMessage)
        })
        
        }
    }
    
    //***** Select member who will be checking in? *****//
    func checkBoxCheckedAtIndex(_ sender:IUIKCheckbox) {
        
        self.whoWillBeCheckingInSelectedIndex = sender.tag
        if(sender.tag == Constant.MyClassConstants.membershipContactArray.count) {
            
            self.requiredSectionIntTBLview = 6
            checkingInUserTBLview.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 2)
            checkingInUserTBLview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            self.proceedToCheckoutButton.isEnabled = false
            self.proceedToCheckoutButton.alpha = 0.5
            
            LookupClient.getCountries(Constant.MyClassConstants.systemAccessToken!, onSuccess: { (response) in
                Constant.GetawaySearchResultGuestFormDetailData.countryListArray = response

            }, onError: { (error) in
                print(error)
            })

        }
        else {
            
            self.requiredSectionIntTBLview = 2
            checkingInUserTBLview.reloadData()
            self.proceedToCheckoutButton.isEnabled = true
            self.proceedToCheckoutButton.alpha = 1.0
            
        }
        
        
    }
    
    //***** Drop down button pressed method *****//
    func dropDownButtonPressed(_ sender:IUIKButton) {
        
        if(isKeyBoardOpen) {
            
            self.activeField?.resignFirstResponder()
        }
        self.dropDownSelectionRow = sender.tag
        self.dropDownSelectionSection = Int(sender.accessibilityValue!)!
        if(self.hideStatus == false) {
            
            self.hideStatus = true
            showPickerView()
            self.pickerView.reloadAllComponents()
        }
        else {
            
            self.hideStatus = false
            hidePickerView()
        }
    }
    
    //***** Picker View for credit card type, country and city selection. *****//
    func createPickerView() {
        
        pickerBaseView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200))
        self.pickerBaseView.backgroundColor = IUIKColorPalette.primary1.color
        let doneButton = UIButton(frame: CGRect(x: pickerBaseView.frame.size.width - 60, y: 5, width: 50, height: 50))
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: .normal)
        doneButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.pickerDoneButtonPressed(_:)), for: .touchUpInside)
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: pickerBaseView.frame.size.width, height: pickerBaseView.frame.size.height - 60))
        pickerView.setValue(UIColor.white, forKeyPath: Constant.MyClassConstants.keyTextColor)
        self.pickerBaseView.addSubview(doneButton)
        self.pickerBaseView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.view.addSubview(pickerBaseView)
    }
    
    //***** Function to display picker. *****//
    func showPickerView() {
        
        if(self.pickerBaseView == nil) {
            self.hideStatus = true
            self.createPickerView()
        }
        else {
            
            self.hideStatus = true
            self.pickerBaseView.isHidden = false
        }
    }
    
    //***** Function to hide picker. *****//
    func hidePickerView() {
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
    }
    
    //***** Function to select value from picker. *****//
    func pickerDoneButtonPressed(_ sender:UIButton) {
        if dropDownSelectionRow == 0 {
            if let countryIndex = selectedCountryIndex {
                if let countryCode = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[countryIndex].countryCode {
                    LookupClient.getStates(Constant.MyClassConstants.systemAccessToken!, countryCode: countryCode, onSuccess: { (response) in
                        Constant.GetawaySearchResultGuestFormDetailData.stateListArray = response
                    }, onError: { (error) in
                        print(error)
                    })
                }
            }
        }
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
        let indexPath = NSIndexPath(row: self.dropDownSelectionRow, section: self.dropDownSelectionSection)
        self.checkingInUserTBLview.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //***** Function called when detail button is pressed. ******//
    
    func resortDetailsClicked(_ sender:IUIKCheckbox){
        
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)

        } else {
            Helper.getRelinquishmentDetails(resortCode: ((filterRelinquishments.openWeek?.resort?.resortCode)!!), viewController: self)
            /*self.performSegue(withIdentifier: Constant.segueIdentifiers.showRelinguishmentsDetailsSegue, sender: nil)*/

        }
        
    }
    
    //***** Function to perform checkout *****//
    @IBAction func proceedToCheckoutPressed(_ sender: AnyObject) {
        
        if(Constant.MyClassConstants.isFromExchange){
            let exchangeProcessRequest = ExchangeProcessContinueToCheckoutRequest()
                
                if(self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count) {
                    
                    let guest = Guest()
                    
                    guest.firstName = Constant.GetawaySearchResultGuestFormDetailData.firstName
                    guest.lastName = Constant.GetawaySearchResultGuestFormDetailData.lastName
                    guest.primaryTraveler = true
                    
                    
                    let guestAddress = Address()
                    var address = [String]()
                    address.append(Constant.GetawaySearchResultCardFormDetailData.address1)
                    address.append(Constant.GetawaySearchResultCardFormDetailData.address2)
                    guestAddress.addressLines = address
                    
                    guestAddress.cityName = Constant.GetawaySearchResultGuestFormDetailData.city
                    guestAddress.postalCode = Constant.GetawaySearchResultGuestFormDetailData.pinCode
                    guestAddress.addressType = "Home"
                    guestAddress.territoryCode = "FL"
                    guestAddress.countryCode = "USA"
                    
                    var phoneNumbers = [Phone]()
                    let homePhoneNo = Phone()
                    homePhoneNo.phoneNumber = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
                    homePhoneNo.countryPhoneCode = "1"
                    homePhoneNo.phoneType = "HOME_PRIMARY"
                    homePhoneNo.areaCode = "305"
                    homePhoneNo.countryCode = "FL"
                    phoneNumbers.append(homePhoneNo)
                    
                    guest.phones = phoneNumbers
                    guest.address = guestAddress
                    exchangeProcessRequest.guest = guest
                    
                    Constant.MyClassConstants.enableGuestCertificate = true
                }else{
                    /*let guest = Guest()
                    guest.firstName = ""
                    guest.lastName = ""
                    var phoneNumbers = [Phone]()
                    guest.phones = phoneNumbers
                    let guestAddress = Address()
                    guest.address = guestAddress
                    exchangeProcessRequest.guest = guest*/
                }
                let processResort = ExchangeProcess()
                processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                Helper.showProgressBar(senderView: self)
                
                ExchangeProcessClient.continueToCheckout(UserContext.sharedInstance.accessToken, process: processResort, request: exchangeProcessRequest, onSuccess: {(response) in
                    DarwinSDK.logger.debug(response)
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    Constant.MyClassConstants.exchangeContinueToCheckoutResponse = response
                    
                    if let promotions = response.view?.fees?.shopExchange?.promotions {
                        Constant.MyClassConstants.recapViewPromotionCodeArray = promotions
                    }
                    
                    DarwinSDK.logger.debug("Promo codes are : \(String(describing: response.view?.promoCodes))")
                    DarwinSDK.logger.debug("Response is : \(String(describing: response.view?.fees)) , -------->\(response)")
                    Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
                    Constant.MyClassConstants.exchangeFees = [(response.view?.fees)!]
                    if(Int((Constant.MyClassConstants.exchangeFees[0].shopExchange?.rentalPrice?.tax)!) != 0){
                        Constant.MyClassConstants.enableTaxes = true
                    }else{
                        Constant.MyClassConstants.enableTaxes = false
                    }
                    Constant.MyClassConstants.memberCreditCardList = (UserContext.sharedInstance.contact?.creditcards)!
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as! CheckOutViewController
                    viewController.filterRelinquishments = self.filterRelinquishments
                    
                    let transitionManager = TransitionManager()
                    self.navigationController?.transitioningDelegate = transitionManager
                    self.navigationController!.pushViewController(viewController, animated: true)
                }, onError: {(error) in
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SimpleAlert.alert(self, title: Constant.AlertErrorMessages.noResultError, message: error.localizedDescription)
                })
        }else{
        let processRequest1 = RentalProcessPrepareContinueToCheckoutRequest()
        
        if(self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count) {
            
            let guest = Guest()
            
            guest.firstName = Constant.GetawaySearchResultGuestFormDetailData.firstName
            guest.lastName = Constant.GetawaySearchResultGuestFormDetailData.lastName
            guest.primaryTraveler = true
            
            
            let guestAddress = Address()
            var address = [String]()
            address.append(Constant.GetawaySearchResultCardFormDetailData.address1)
            address.append(Constant.GetawaySearchResultCardFormDetailData.address2)
            guestAddress.addressLines = address
            
            
            guestAddress.cityName = Constant.GetawaySearchResultGuestFormDetailData.city
            guestAddress.postalCode = Constant.GetawaySearchResultGuestFormDetailData.pinCode
            guestAddress.addressType = "Home"
            guestAddress.territoryCode = "FL"
            guestAddress.countryCode = "USA"
            
            var phoneNumbers = [Phone]()
            let homePhoneNo = Phone()
            homePhoneNo.phoneNumber = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
            homePhoneNo.countryPhoneCode = "1"
            homePhoneNo.phoneType = "HOME_PRIMARY"
            homePhoneNo.areaCode = "305"
            homePhoneNo.countryCode = "FL"
            phoneNumbers.append(homePhoneNo)
            
            guest.phones = phoneNumbers
            guest.address = guestAddress
            processRequest1.guest = guest
            
            Constant.MyClassConstants.enableGuestCertificate = true
        }
        Helper.showProgressBar(senderView: self)
        let processResort = RentalProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        processResort.processId = Constant.MyClassConstants.processStartResponse.processId
        
        RentalProcessClient.continueToCheckout(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
            DarwinSDK.logger.debug(response)
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            Constant.MyClassConstants.continueToCheckoutResponse = response
            
            if let promotions = response.view?.fees?.rental?.promotions {
                Constant.MyClassConstants.recapViewPromotionCodeArray = promotions
            }
            
            DarwinSDK.logger.debug("Promo codes are : \(String(describing: response.view?.promoCodes))")
            DarwinSDK.logger.debug("Response is : \(String(describing: response.view?.fees)) , -------->\(response)")
            Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
            Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            if(Int((response.view?.fees?.rental?.rentalPrice?.tax)!) != 0){
                Constant.MyClassConstants.enableTaxes = true
            }else{
                Constant.MyClassConstants.enableTaxes = false
            }
            Constant.MyClassConstants.memberCreditCardList = (UserContext.sharedInstance.contact?.creditcards)!
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as! CheckOutViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
            }, onError: {(error) in
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                
        })
    }
}
}

//Extension class starts from here
extension WhoWillBeCheckingInViewController:UITableViewDelegate {
    
    
}


extension WhoWillBeCheckingInViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.requiredSectionIntTBLview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0) {
            
            if(Constant.MyClassConstants.vacationSearchSelectedSegmentIndex == 1) || Constant.MyClassConstants.vacationSearchSelectedSegmentIndex == 0 {
                
                return 1
            }
            else {
                return 2
            }
        }
        else if(section == 1) {
            return Constant.MyClassConstants.membershipContactArray.count + 1
        }
        else if(section == 2) {
            
            return 1
        }
        else if(section == 3) {
            return 2
        }
        else if(section == 4) {
            return 6
        }
        else {
            
            return 3
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if(section == 0) {
            
            return 80
        }
        else if(section == 2 || section == 3 || section == 4) {
            
            return 30
        }
        else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if(section == 0) {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkingInUserTBLview.frame.size.width, height: 80))
            
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 10, width: checkingInUserTBLview.frame.size.width - 40, height: 60)
            headerLabel.text = Constant.MyClassConstants.whoWillBeCheckingInHeaderTextArray[section]
            headerLabel.numberOfLines = 2
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 15)
            headerView.addSubview(headerLabel)
            
            return headerView
        }
        else if(section == 2 || section == 3 || section == 4) {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkingInUserTBLview.frame.size.width, height: 30))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 5, width: checkingInUserTBLview.frame.size.width - 40, height: 20)
            headerLabel.text  = Constant.MyClassConstants.whoWillBeCheckingInHeaderTextArray[section]
            headerView.addSubview(headerLabel)
            
            return headerView
            
        }
        else {
            
            return nil
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0) {
            
            return 50
        }
        else if(indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5) {
            
            return 50
        }
        else {
            
            return 80
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell
            if(indexPath.row == 0){
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortDetailsButton.tag = indexPath.row
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
                cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.resortImage)
            }else{
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortDetailsButton.tag = indexPath.row
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
                cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.relinquishmentImage)
                cell.lblHeading.text = "Relinquishment"
                cell.resortName?.text = filterRelinquishments.openWeek?.resort?.resortName
            }
            
            cell.selectionStyle = .none
            
            return cell
        }
        else if(indexPath.section == 1) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.checkingInUserListTBLcell, for: indexPath) as! CheckingInUserListTBLcell
            
            if(indexPath.row == Constant.MyClassConstants.membershipContactArray.count) {
                
                cell.nameLabel.text = Constant.WhoWillBeCheckingInViewControllerCellIdentifiersAndHardCodedStrings.noneOfAboveContactString
            }
            else {
                
                
                let contacts = Constant.MyClassConstants.membershipContactArray[indexPath.row]
                cell.nameLabel.text = contacts.firstName?.capitalized
            }
            if(indexPath.row == whoWillBeCheckingInSelectedIndex) {
                
                cell.checkBox.checked = true
                cell.contentBorderView.layer.borderColor = UIColor(red: 224.0/255.0, green: 118.0/255.0, blue: 69.0/255.0, alpha: 1.0).cgColor
            }
            else {
                cell.checkBox.checked = false
                cell.contentBorderView.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
            }
            cell.contentBorderView.layer.borderWidth = 2
            cell.contentBorderView.layer.cornerRadius = 7
            cell.checkBox.tag = indexPath.row
            cell.checkBox.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        else if(indexPath.section == 2) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestCertificatePriceCell, for: indexPath) as! GuestCertificatePriceCell
            
       
            
            let guestPrices = Constant.MyClassConstants.guestCertificate.prices
            var memberTier = ""
            if(Constant.MyClassConstants.isFromExchange){
                if(Constant.MyClassConstants.exchangeFees.count > 0){
                memberTier = Constant.MyClassConstants.exchangeFees[0].memberTier!
                }else{
                  memberTier = ""
                }
                
            }else{
                memberTier = Constant.MyClassConstants.rentalFees[0].memberTier!
            }
            
            for price in guestPrices {
                
                if(price.productCode == memberTier) {
                    
                    let floatPriceString = "\(price.price)"
                    let priceArray = floatPriceString.components(separatedBy: ".")
                    Constant.MyClassConstants.guestCertificatePrice = Double(price.price)
                    cell.certificatePriceLabel.text = "\(priceArray.first!)."
                    if((priceArray.last?.characters.count)! > 1) {
                        
                        cell.fractionValue.text = "\(priceArray.last!)"
                    }
                    else {
                        
                        cell.fractionValue.text = "\(priceArray.last!)0"
                    }
                }
            }
            return cell
        }
        else if(indexPath.section == 3 || indexPath.section == 5) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
            
            cell.nameTF.text = ""
            cell.nameTF.delegate = self
            if(indexPath.section == 3) {
                
                if(indexPath.row == 0) {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.firstName == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormFnamePlaceholder
                       
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.firstName
                    }
                    
                }
                else {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.lastName == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormLnamePlaceholder
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.lastName
                    }
                    
                }
                
            }
            else {
                
                if(indexPath.row == 0) {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.email == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormEmail
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.email
                    }
                }
                else if(indexPath.row == 1){
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormHomePhoneNumber
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
                    }
                }
                else {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormBusinessPhoneNumber
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber
                    }
                }
                
            }
            self.cellUsedFor = Constant.MyClassConstants.guestString
            cell.nameTF.tag = indexPath.row
            cell.nameTF.accessibilityValue = "\(indexPath.section)"
            cell.borderView.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
            cell.borderView.layer.borderWidth = 2
            cell.borderView.layer.cornerRadius = 5
            cell.selectionStyle = .none
            return cell
            
            
        }
        else {
            
            if (indexPath.row == 0 || indexPath.row == 4) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.dropDownListCell, for: indexPath) as! DropDownListCell
                if(indexPath.row == 0) {
                    
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.country != "") {
                        
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultGuestFormDetailData.country
                    }
                    else {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectCountryPlaceholder
                    }
                    
                }
                else {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.state != "") {
                        
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultGuestFormDetailData.state
                    }
                    else {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectState
                    }
                    
                    
                }
                cell.dropDownButton.tag = indexPath.row
                cell.dropDownButton.accessibilityValue = "\(indexPath.section)"
                cell.dropDownButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.dropDownButtonPressed(_:)), for: .touchUpInside)
                cell.borderView.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                return cell
                
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
                cell.nameTF.text = ""
                cell.nameTF.delegate = self
                if(indexPath.row == 1) {
                    if(Constant.GetawaySearchResultGuestFormDetailData.address1 == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.address1
                    }
                }
                else if(indexPath.row == 2) {
                    if(Constant.GetawaySearchResultGuestFormDetailData.address2 == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.address2
                    }
                    
                }
                else if(indexPath.row == 3) {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.city == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.city
                    }
                }
                else {
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.pinCode == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                        
                    }
                    else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.pinCode
                    }
                    
                }
                self.cellUsedFor = Constant.MyClassConstants.guestString
                cell.nameTF.tag = indexPath.row
                cell.nameTF.accessibilityValue = "\(indexPath.section)"
                cell.borderView.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                return cell
                
            }
        }
    }
}

// Extension for picker.
extension WhoWillBeCheckingInViewController:UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if(self.dropDownSelectionRow == 0) {
            
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName

        }
        else {
            
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name

        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.dropDownSelectionRow == 0) {
            Constant.GetawaySearchResultGuestFormDetailData.country = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName!
            Constant.GetawaySearchResultCardFormDetailData.countryCode = Constant.GetawaySearchResultGuestFormDetailData.countryCodeArray[row]
            Helper.getStates(country: Constant.GetawaySearchResultCardFormDetailData.countryCode, viewController: self)
        }else {
            guard let stateName = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name else { return }

            Constant.GetawaySearchResultGuestFormDetailData.state = stateName
        }
    }
}

extension WhoWillBeCheckingInViewController:UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        if(dropDownSelectionRow == 0) {
            
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray.count
        }
        else {
            
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray.count
        }
        
    }
}


//***** extension class for uitextfield delegate methods definition *****//
extension WhoWillBeCheckingInViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeField?.resignFirstResponder()
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField?.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(string)
        if (range.length == 1 && string.characters.count == 0) {
            print("backspace tapped")
        }
        
        if(self.cellUsedFor == Constant.MyClassConstants.guestString) {
            
            if(Int(textField.accessibilityValue!) == 3) {
                
                if(textField.tag == 0) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.firstName.characters.removeLast()
                    }
                    else {
                        Constant.GetawaySearchResultGuestFormDetailData.firstName = "\(textField.text!)\(string)"
                    }
                    
                    let vfnm =  self.validateUsername(str: Constant.GetawaySearchResultGuestFormDetailData.firstName)
                    if(vfnm || Constant.GetawaySearchResultGuestFormDetailData.firstName.characters.count == 0) {
                        
                        proceedStatus = true
                        textField.superview?.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                    }
                    else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                }
                else {
                    
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.lastName.characters.removeLast()
                    }
                    else {
                        Constant.GetawaySearchResultGuestFormDetailData.lastName = "\(textField.text!)\(string)"
                    }
                    
                    let vfnm =  self.validateUsername(str: Constant.GetawaySearchResultGuestFormDetailData.lastName)
                    if(vfnm || Constant.GetawaySearchResultGuestFormDetailData.lastName.characters.count == 0) {
                        proceedStatus = true
                        textField.superview?.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                    }
                    else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                    
                }
            }
            else if(Int(textField.accessibilityValue!) == 4) {
                
                if(textField.tag == 0) {
                    
                    
                }
                else if(textField.tag == 1) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.address1.characters.removeLast()
                    }
                    else {
                        Constant.GetawaySearchResultGuestFormDetailData.address1 = "\(textField.text!)\(string)"
                    }
                }
                else if(textField.tag == 2) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.address2.characters.removeLast()
                    }
                    else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.address2 = "\(textField.text!)\(string)"
                    }
                    
                }
                else if(textField.tag == 3) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.city.characters.removeLast()
                    }
                    else {
                        Constant.GetawaySearchResultGuestFormDetailData.city = "\(textField.text!)\(string)"
                    }
                }
                else if(textField.tag == 4) {
                    
                }
                else {
                    
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.pinCode.characters.removeLast()
                    }
                    else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.pinCode = "\(textField.text!)\(string)"
                    }
                    
                    if(Constant.GetawaySearchResultGuestFormDetailData.pinCode.characters.count > 6) {
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                    else {
                        
                        textField.superview?.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                        proceedStatus = true
                        
                    }
                    
                }
            }
            else {
                
                if(textField.tag == 0) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.email.characters.removeLast()
                    }
                    else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.email = "\(textField.text!)\(string)"
                    }
                    
                    let eml = self.isValidEmail(testStr: Constant.GetawaySearchResultGuestFormDetailData.email)
                    
                    if(eml || Constant.GetawaySearchResultGuestFormDetailData.email.characters.count == 0) {
                        
                        textField.superview?.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                        proceedStatus = true
                    }
                    else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                    
                }
                else if(textField.tag == 1) {
                    
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber.characters.removeLast()
                    }
                    else {
                        Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber = "\(textField.text!)\(string)"
                        
                        if(Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber.characters.count > 9) {
                            
                            textField.superview?.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                            proceedStatus = true

                        }
                        else {
                            
                            textField.superview?.layer.borderColor = UIColor.red.cgColor
                            proceedStatus = false

                        }
                    }
                    
                }
                else {
                    
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber.characters.removeLast()
                    }
                    else {
                        Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber = "\(textField.text!)\(string)"
                        
                        if(Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber.characters.count > 9) {
                            
                            textField.superview?.layer.borderColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
                            proceedStatus = true
                            
                        }
                        else {
                            
                            textField.superview?.layer.borderColor = UIColor.red.cgColor
                            proceedStatus = false
                            
                        }

                    }
                    
                }
            }
            let detailStatus = guestFormCheckForDetails()
            if(detailStatus) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
            }
            return  true
        }
        else {
            if(Int(textField.accessibilityValue!) == 0) {
                
                if(textField.tag == 0) {
                    
                    Constant.GetawaySearchResultCardFormDetailData.nameOnCard = "\(textField.text!)\(string)"
                }
                else if(textField.tag == 1) {
                    
                    Constant.GetawaySearchResultCardFormDetailData.cardNumber = "\(textField.text!)\(string)"
                }
                else {
                    
                    Constant.GetawaySearchResultCardFormDetailData.cvv = "\(textField.text!)\(string)"
                }
            }
            else {
                
                if(textField.tag == 1) {
                    
                    Constant.GetawaySearchResultCardFormDetailData.address1 = "\(textField.text!)\(string)"
                }
                else if(textField.tag == 2) {
                    
                    Constant.GetawaySearchResultCardFormDetailData.address2 = "\(textField.text!)\(string)"
                }
                else if(textField.tag == 3) {
                    Constant.GetawaySearchResultCardFormDetailData.city = "\(textField.text!)\(string)"
                }
                else {
                    
                    Constant.GetawaySearchResultCardFormDetailData.pinCode = "\(textField.text!)\(string)"
                }
            }
            return  true
        }
        
       
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeField = textField
        
        
        if(Int(textField.accessibilityValue!) == 3) {
            
             textField.keyboardType = .default
        }
        else if(Int(textField.accessibilityValue!) == 4) {
            
            if(textField.tag != 0 && textField.tag != 1 && textField.tag != 2 && textField.tag != 3 && textField.tag != 4) {
                
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
            
        }
        else {
            
            if(textField.tag == 0 ) {
                
                self.moved = true
                textField.keyboardType = .default
            }
            else if(textField.tag == 1) {
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
            else {
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
        }
    }
    
}






