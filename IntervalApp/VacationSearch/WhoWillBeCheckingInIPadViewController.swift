//
//  WhoWillBeCheckingInIPadViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 11/5/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD

class WhoWillBeCheckingInIPadViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var resortHoldingTimeLabel: UILabel!
    @IBOutlet weak var checkingInUserIPadTableView: UITableView!
    @IBOutlet weak var proceedToCheckoutButton: IUIKButton!
    
    //Class variables
    var requiredSectionIntTBLview = 2
    var whoWillBeCheckingInSelectedIndex = -1
    var activeField:UITextField?
    var moved: Bool = false
    var cellUsedFor = ""
    var proceedStatus = false
    var pickerBaseView:UIView!
    var pickerView:UIPickerView!
    var hideStatus = false
    var dropDownSelectionRow = -1
    var dropDownSelectionSection = -1
    var holdingTimer:Timer!
    var holdingTime = 17
    var decreaseValue = 1
    var selectedCountryIndex: Int?
    
    var filterRelinquishments = ExchangeRelinquishment()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertForTimer), name: NSNotification.Name(rawValue: "showAlert"), object: nil)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.vacationSearchCheckingIn,
            ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableGuestFormCheckout), name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
        
        self.proceedToCheckoutButton.isEnabled = false
        self.proceedToCheckoutButton.alpha = 0.5
        Constant.startTimer()
        self.title = Constant.ControllerTitles.whoWillBeCheckingInControllerTitle
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(WhoWillBeCheckingInIPadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        
        
        // omniture tracking with event 37
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products : Constant.MyClassConstants.selectedResort.resortCode!,
            Constant.omnitureEvars.eVar37 : Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex),
            Constant.omnitureEvars.eVar39 : "",
            ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event37, data: userInfo)
        
    }
    
    //Function to display alert on timer time over
    
    func showAlertForTimer(){
        SimpleAlert.alertTodismissController(self, title: "Holding time lost", message: "Oops You have lost your holding time for this resort!. Please try again")
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
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
    
    
    // Function to dismis current controller on back button pressed.
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        Helper.showProgressBar(senderView: self)
        if(Constant.MyClassConstants.isFromExchange){
            Constant.holdingTimer.invalidate()
            
            ExchangeProcessClient.backToChooseExchange(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, onSuccess:{(response) in
                
                Constant.MyClassConstants.selectedCreditCard.removeAll()
                Helper.hideProgressBar(senderView: self)
                _ = self.navigationController?.popViewController(animated: true)
                
            }, onError: {(error) in
                
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title: "Who will be checking in", message: Constant.AlertMessages.operationFailedMessage)
            })
        }else{
        Constant.holdingTimer.invalidate()
        
        RentalProcessClient.backToChooseRental(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess:{(response) in
            
            Constant.MyClassConstants.selectedCreditCard.removeAll()
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            _ = self.navigationController?.popViewController(animated: true)
            
        }, onError: {(error) in
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            SimpleAlert.alert(self, title: "Who will be checking in", message: Constant.AlertMessages.operationFailedMessage)
        })
    }

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
    
    // Function to identify selected contact from membership contact list with checkbox selection.
    func checkBoxCheckedAtIndex(_ sender:IUIKCheckbox) {
        self.whoWillBeCheckingInSelectedIndex = sender.tag
        if(sender.tag == Constant.MyClassConstants.membershipContactArray.count) {
            self.requiredSectionIntTBLview = 6
            checkingInUserIPadTableView.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 2)
            checkingInUserIPadTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
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
            checkingInUserIPadTableView.reloadData()
            self.proceedToCheckoutButton.isEnabled = true
            self.proceedToCheckoutButton.alpha = 1.0

        }
    }
    
    //***** Function called when detail button is pressed. ******//
    func resortDetailsClicked(_ sender:IUIKButton){
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
        } else {
            Helper.getRelinquishmentDetails(resortCode: ((filterRelinquishments.openWeek?.resort?.resortCode)!!), viewController: self)

            /*self.performSegue(withIdentifier: Constant.segueIdentifiers.showRelinguishmentsDetailsSegue, sender: nil)*/
        }
        
    }
    
    //***** Function called when drop down is pressed. *****//
    func dropDownButtonPressed(_ sender:IUIKButton) {
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
    
    // Function to create date picker view for date selection.
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
    
    //Function to show picker view
    func showPickerView() {
        if(self.pickerBaseView == nil) {
            self.hideStatus = true
            self.createPickerView()
        }else {
            self.hideStatus = true
            self.pickerBaseView.isHidden = false
        }
    }
    
    //Function to hide picker view.
    func hidePickerView() {
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
    }
    
    // Function to remove picker view on done button pressed.
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
        self.checkingInUserIPadTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //***** Function for proceed to checkout button click. *****//
    @IBAction func proceedToCheckoutPressed(_ sender: AnyObject) {
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
            guestAddress.addressType = "HADDR"
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
        }
        else{
            
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
            if(Int((response.view?.fees?.shopExchange?.rentalPrice?.tax)!) != 0){
                Constant.MyClassConstants.enableTaxes = true
            }else{
                Constant.MyClassConstants.enableTaxes = false
            }
            Constant.MyClassConstants.memberCreditCardList = (UserContext.sharedInstance.contact?.creditcards)!
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as! CheckOutIPadViewController
            viewController.filterRelinquishments = self.filterRelinquishments
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
        }, onError: {(error) in
            print(error.localizedDescription)
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            
        })
     }
    
    func showCertificateInfo() {
        let storyboard = UIStoryboard(name: "VacationSearchIphone", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "GestCertificateInfo") as! UINavigationController
        
        self.present(nav, animated: true, completion: nil)
    }

}

//Extension class starts from here
//Implementation of tableview delegate methods
extension WhoWillBeCheckingInIPadViewController:UITableViewDelegate {
    
    
    
}

//Implementation of tableview data source methods
extension WhoWillBeCheckingInIPadViewController:UITableViewDataSource {
    
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
        else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if(section == 0) {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkingInUserIPadTableView.frame.size.width, height: 100))
            
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 20, width: checkingInUserIPadTableView.frame.size.width - 40, height: 60)
            headerLabel.text = Constant.WhoWillBeCheckingInViewControllerCellIdentifiersAndHardCodedStrings.contactListHeaderString
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 15)
            headerLabel.numberOfLines = 2
            
            headerView.addSubview(headerLabel)
            
            return headerView
        }
        else {
            
            return nil
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0) {
            return 80
        }else if(indexPath.section >= 3) {
            return 80
        }else {
            return 120
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell
            cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInIPadViewController.resortDetailsClicked(_:)), for: .touchUpInside)
            if (indexPath.row == 0) {
                cell.resortDetailsButton.tag = indexPath.row
                cell.lblHeading.text = "Resort Detail"
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
            } else {
                cell.resortDetailsButton.tag = indexPath.row
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
            cell.checkBox.addTarget(self, action: #selector(WhoWillBeCheckingInIPadViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
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
            
            cell.infoButton.addTarget(self, action: #selector(showCertificateInfo), for: .touchUpInside)
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
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                }
                else if(indexPath.row == 2) {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                }
                else if(indexPath.row == 3) {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                }
                else {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                }
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


// Extension class for implementing picker view delegate methods

extension WhoWillBeCheckingInIPadViewController:UIPickerViewDelegate {
    
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
            guard let countryName = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName else { return }
            Constant.GetawaySearchResultGuestFormDetailData.country = countryName
            selectedCountryIndex = row
        }
        else {
            guard let stateName = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name else { return }
            Constant.GetawaySearchResultGuestFormDetailData.state = stateName
        }
    }
}

// Extension class for implementing picker view data source methods
extension WhoWillBeCheckingInIPadViewController:UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if(self.dropDownSelectionRow == 0) {
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray.count
        }
        else {
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray.count
        }
    }
}


extension WhoWillBeCheckingInIPadViewController:UITextFieldDelegate{
    
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

