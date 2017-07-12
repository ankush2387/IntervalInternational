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
    var pickerBaseView:UIView!
    var pickerView:UIPickerView!
    var hideStatus = false
    var dropDownSelectionRow = -1
    var dropDownSelectionSection = -1
    var holdingTimer:Timer!
    var holdingTime = 17
    var decreaseValue = 1
    
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
    
    
    // Function to dismis current controller on back button pressed.
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: self.view)
        
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
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
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
        self.pickerBaseView.backgroundColor = UIColor.darkGray
        let doneButton = UIButton(frame: CGRect(x: pickerBaseView.frame.size.width - 60, y: 5, width: 50, height: 50))
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: .normal)
        doneButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.pickerDoneButtonPressed(_:)), for: .touchUpInside)
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: pickerBaseView.frame.size.width, height: pickerBaseView.frame.size.height - 60))
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
        
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
        let indexPath = NSIndexPath(row: self.dropDownSelectionRow, section: self.dropDownSelectionSection)
        self.checkingInUserIPadTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //***** Function for proceed to checkout button click. *****//
    @IBAction func proceedToCheckoutPressed(_ sender: AnyObject) {
        let processRequest1 = RentalProcessPrepareContinueToCheckoutRequest()
        
        if(self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count) {
            
            let guest = Guest()
            
            guest.firstName = Constant.GetawaySearchResultGuestFormDetailData.firstName
            guest.lastName = Constant.GetawaySearchResultGuestFormDetailData.lastName
            guest.primaryTraveler = true
            
            
            let guestAddress = Address()
            
            guestAddress.addrLine1 = "11023 SW 40 ST"
            guestAddress.cityName = "MIAMI"
            guestAddress.zipCode = "33176"
            guestAddress.addressType = "Home"
            guestAddress.territoryCode = "FL"
            guestAddress.countryCode = "USA"
            
            var phoneNumbers = [Phone]()
            let homePhoneNo = Phone()
            homePhoneNo.phoneNumber = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
            homePhoneNo.phoneType = "HOME_PRIMARY"
            homePhoneNo.areaCode = "305"
            homePhoneNo.countryCode = "FL"
            phoneNumbers.append(homePhoneNo)
            
            guest.phones = phoneNumbers
            guest.address = guestAddress
            processRequest1.guest = guest
        }
       
        Helper.addServiceCallBackgroundView(view: self.view)
        SVProgressHUD.show()
        let processResort = RentalProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        processResort.processId = Constant.MyClassConstants.processStartResponse.processId
        
        RentalProcessClient.continueToCheckout(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            Constant.MyClassConstants.continueToCheckoutResponse = response
            
            if let promotions = response.view?.fees?.rental?.promotions {
                Constant.MyClassConstants.recapViewPromotionCodeArray = promotions
            }

            Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
            Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            Constant.MyClassConstants.memberCreditCardList = (UserContext.sharedInstance.contact?.creditcards)!
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as! CheckOutIPadViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
            }, onError: {(error) in
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
        })
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
            
            cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
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
            let memberTier = Constant.MyClassConstants.rentalFees[0].memberTier
            
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
            if(indexPath.section == 3) {
                
                if(indexPath.row == 0) {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormFnamePlaceholder
                }
                else {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormLnamePlaceholder
                }
                
            }
            else {
                
                if(indexPath.row == 0) {
                    
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormEmail
                }
                else if(indexPath.row == 1){
                    
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormHomePhoneNumber
                }
                else {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormBusinessPhoneNumber
                    
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
            
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row]
        }
        else {
            
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.dropDownSelectionRow == 0) {
            
            Constant.GetawaySearchResultGuestFormDetailData.country = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row]
        }
        else {
            
            Constant.GetawaySearchResultGuestFormDetailData.state = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row]
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

