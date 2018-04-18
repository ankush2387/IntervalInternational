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
    @IBOutlet private weak var resortHoldingTimeLabel: UILabel!
    @IBOutlet fileprivate weak var checkingInUserTBLview: UITableView!
    @IBOutlet fileprivate weak var proceedToCheckoutButton: IUIKButton!
    @IBOutlet private var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    //Class variables
    var isKeyBoardOpen = false
    var moved: Bool = false
    var activeField: UITextField?
    var cellUsedFor = ""
    var requiredSectionIntTBLview = 2
    var whoWillBeCheckingInSelectedIndex = -1
    var pickerBaseView: UIView!
    var pickerView: UIPickerView!
    var hideStatus = false
    var dropDownSelectionRow = -1
    var dropDownSelectionSection = -1
    var holdingTimer: Timer!
    var holdingTime = 2
    var decreaseValue = 1
    var selectedCountryIndex: Int?
    var noThanksSelected = false
    var isFromRenewals = false
    var selectedRelinquishment = ExchangeRelinquishment()
    var renewalCoreProduct: Renewal?
    var renewalNonCoreProduct: Renewal?
    var guestCertFormDetail: Constant.GuestCertificateFormData?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkingInUserTBLview.estimatedRowHeight = 80
        view.backgroundColor = IntervalThemeFactory.deviceTheme.textColorGray
        resortHoldingTimeLabel.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        navigationController?.navigationBar.isHidden = false
        
        //FIXME(Frank) - what is this?
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        checkingInUserTBLview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call country api
        
        //FIXME(Frank) - what is this?
        Helper.getCountry { [weak self] error in
            self?.hideHudAsync()
            if let Error = error {
                self?.presentErrorAlert(UserFacingCommonError.handleError(Error))
            }
        }
        
        var resortCode = ""
        if let selectedResort = Constant.MyClassConstants.selectedAvailabilityResort {
            resortCode = selectedResort.code
        }
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.vacationSearchCheckingIn
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        // omniture tracking with event 37
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products: resortCode,
            Constant.omnitureEvars.eVar37: Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex),
            Constant.omnitureEvars.eVar39: ""
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event37, data: userInfo)
        
        self.proceedToCheckoutButton.isEnabled = false
        self.proceedToCheckoutButton.alpha = 0.5
        Constant.startTimer()
        self.title = Constant.ControllerTitles.whoWillBeCheckingInControllerTitle
        
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(WhoWillBeCheckingInViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        
        isKeyBoardOpen = true
        
        if self.moved {
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
        
        if self.moved {
            self.moved = false
            let contentInsets = UIEdgeInsets.zero
            self.checkingInUserTBLview.contentInset = contentInsets
            self.checkingInUserTBLview.scrollIndicatorInsets = contentInsets
        }
    }

    //***** Function to check if the email entered by user is an valid email address. *****//
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func validatePhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "[^0-9]"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: value)
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
    
    
    // MARK: - NO THANKS from alert
    func noThanksPressed() {
        let button = UIButton()
        proceedToCheckoutPressed(button)
    }
    
    //***** Checkout using guest. *****//
    func enableGuestFormCheckout() {
        proceedToCheckoutButton.isEnabled = true
        proceedToCheckoutButton.alpha = 1.0
    }
    
    func enableGuestButton(status: Bool) {
        if status {
            proceedToCheckoutButton.isEnabled = true
            proceedToCheckoutButton.alpha = 1.0
        } else {
            proceedToCheckoutButton.isEnabled = false
            proceedToCheckoutButton.alpha = 0.5
        }
    }
    
    //***** Notification for update timer.*****//
    func updateResortHoldingTime() {
        if Constant.holdingTime != 0 {
            resortHoldingTimeLabel.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        } else {
            Constant.holdingTimer?.invalidate()
            let alertController = UIAlertController(title: "", message: Constant.AlertMessages.holdingTimeLostMessage, preferredStyle: .alert)
            let Ok = UIAlertAction(title: "OK".localized(), style: .default) {[weak self] (_:UIAlertAction)  in
                
                self?.performSegue(withIdentifier: "unwindToAvailabiity", sender: self)
            }
            alertController.addAction(Ok)
            present(alertController, animated: true, completion:nil)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Back button pressed.*****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        showHudAsync()
        
        if Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            Constant.holdingTimer?.invalidate()
            
            ExchangeProcessClient.backToChooseExchange(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, onSuccess: {(_) in
                
                Constant.MyClassConstants.selectedCreditCard = nil
                self.hideHudAsync()
                
                // pop and dismiss view according to conditions
                if Constant.MyClassConstants.isDismissWhoWillBeCheckin {
                    Constant.MyClassConstants.isDismissWhoWillBeCheckin = false
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
            }, onError: { [weak self] _ in
                
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.generic)
            })
        } else {
            Constant.holdingTimer?.invalidate()
            
            RentalProcessClient.backToChooseRental(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess: {[weak self](_) in
                
                Constant.MyClassConstants.selectedCreditCard = nil
                self?.guestCertFormDetail = nil
                self?.hideHudAsync()
                
                // pop and dismiss view according to conditions
                if Constant.MyClassConstants.isDismissWhoWillBeCheckin {
                    Constant.MyClassConstants.isDismissWhoWillBeCheckin = false
                    self?.dismiss(animated: true, completion: nil)
                    
                } else {
                    _ = self?.navigationController?.popViewController(animated: true)
                }
                
            }, onError: { [weak self] _ in
                self?.hideHudAsync()
                self?.presentAlert(with: Constant.ControllerTitles.whoWillBeCheckingInControllerTitle, message: Constant.AlertMessages.operationFailedMessage)
                
            })
        }
    }
    
    //***** Drop down button pressed method *****//
    func dropDownButtonPressed(_ sender: IUIKButton) {
        
        if isKeyBoardOpen {
            activeField?.resignFirstResponder()
        }
        dropDownSelectionRow = sender.tag
        dropDownSelectionSection = Int(sender.accessibilityValue ?? "0") ?? 0
        if dropDownSelectionRow == 4 && Constant.stateListArray.isEmpty {
            let state = State()
            state.name = "N/A"
            state.code = ""
            Constant.stateListArray.append(state)
        }
        if !self.hideStatus {
            if dropDownSelectionRow == 0 {
                guestCertFormDetail?.state.removeAll()
                let indexPath = IndexPath(row: 4, section: dropDownSelectionSection)
                checkingInUserTBLview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            self.hideStatus = true
            showPickerView()
            pickerView.reloadAllComponents()
        } else {
            
            hideStatus = false
            hidePickerView()
        }
    }
    
    //***** Picker View for credit card type, country and city selection. *****//
    func createPickerView() {
        
        pickerBaseView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200))
        pickerBaseView.backgroundColor = IUIKColorPalette.primary1.color
        let doneButton = UIButton(frame: CGRect(x: pickerBaseView.frame.size.width - 60, y: 5, width: 50, height: 50))
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: .normal)
        doneButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.pickerDoneButtonPressed(_:)), for: .touchUpInside)
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: pickerBaseView.frame.size.width, height: pickerBaseView.frame.size.height - 60))
        pickerView.setValue(UIColor.white, forKeyPath: Constant.MyClassConstants.keyTextColor)
        pickerBaseView.addSubview(doneButton)
        pickerBaseView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.view.addSubview(pickerBaseView)
    }
    
    //***** Function to display picker. *****//
    func showPickerView() {
        
        if pickerBaseView == nil {
            hideStatus = true
            createPickerView()
        } else {
            
            hideStatus = true
            pickerBaseView.isHidden = false
        }
    }
    
    //***** Function to hide picker. *****//
    func hidePickerView() {
        hideStatus = false
        pickerBaseView.isHidden = true
    }
    
    //***** Function to select value from picker. *****//
    func pickerDoneButtonPressed(_ sender: UIButton) {
        if dropDownSelectionRow == 0 {
            if let countryIndex = selectedCountryIndex {
                if let countryCode = Constant.countryListArray[countryIndex].countryCode {
                    LookupClient.getStates(Constant.MyClassConstants.systemAccessToken!, countryCode: countryCode, onSuccess: { (response) in
                        Constant.stateListArray = response
                    }, onError: { (error) in
                        intervalPrint(error)
                        
                    })
                }
            }
        }
        hideStatus = false
        pickerBaseView.isHidden = true
        let indexPath = NSIndexPath(row: self.dropDownSelectionRow, section: self.dropDownSelectionSection)
        checkingInUserTBLview.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //***** Function called when detail button is pressed. ******//
    
    func resortDetailsClicked(_ sender: IUIKCheckbox) {
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
        } else {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showRelinguishmentsDetailsSegue, sender: self)
        }
    }
    
    // MARK: - Function to perform checkout
    @IBAction func proceedToCheckoutPressed(_ sender: AnyObject) {
        
        if Constant.MyClassConstants.noThanksForNonCore && whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
            
            Constant.MyClassConstants.isNoThanksFromRenewalAgain = true
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
            viewController.delegate = self
            
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            let navController = UINavigationController(rootViewController: viewController)
            present(navController, animated: true, completion: nil)
            
        } else {
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.searchBothExchange {
                
                let exchangeProcessRequest = ExchangeProcessContinueToCheckoutRequest()
                
                if self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
                    
                    let guest = guestCertFormDetail?.toGuest()
                    
                    exchangeProcessRequest.guest = guest
                }
                
                // Add selected renewals to the ExchangeProcessContinueToCheckoutRequest
                var selectedRenewals = [Renewal]()
                if let coreProduct = renewalCoreProduct {
                    let renewal = Renewal()
                    renewal.id = coreProduct.id
                    selectedRenewals.append(renewal)
                }
                if let nonCoreProduct = renewalNonCoreProduct {
                    let renewal = Renewal()
                    renewal.id = nonCoreProduct.id
                    selectedRenewals.append(renewal)
                }
                if !selectedRenewals.isEmpty {
                    exchangeProcessRequest.renewals = selectedRenewals
                }
                
                let processResort = ExchangeProcess()
                processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                showHudAsync()
                
                ExchangeProcessClient.continueToCheckout(Session.sharedSession.userAccessToken, process: processResort, request: exchangeProcessRequest, onSuccess: { [unowned self] (response) in
                    DarwinSDK.logger.debug(response)
                    self.hideHudAsync()
                    Constant.MyClassConstants.exchangeContinueToCheckoutResponse = response
                    
                    if let view = response.view, let exchangeFees = view.fees, let shopExchangeFee = exchangeFees.shopExchange, let shopExchangePrice = shopExchangeFee.inventoryPrice {
                        Constant.MyClassConstants.exchangeFeeOriginalPrice = shopExchangePrice.price
                        
                        Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                        if !shopExchangePrice.taxBreakdown.isEmpty {
                            Constant.MyClassConstants.inventoryPriceTaxBreakdown = shopExchangePrice.taxBreakdown
                        }
                    }
                    
                    Constant.MyClassConstants.selectedDestinationPromotionOfferName = nil
                    Constant.MyClassConstants.selectedDestinationPromotionDisplayName = nil
                    
                    //FIXME(Frank) - If we already have exchangeContinueToCheckoutResponse as global then why the next block of code?
                    if let view = response.view {
                        Constant.MyClassConstants.allowedCreditCardType = view.allowedCreditCardTypes
                        
                        if let fees = view.fees {
                            //FIXME(Frank) - why an array? - what is this?
                            Constant.MyClassConstants.exchangeFees = fees
                   
                            if let shopExchangeFee = fees.shopExchange {
                                Constant.MyClassConstants.recapViewPromotionCodeArray.removeAll()
                                if !shopExchangeFee.promotions.isEmpty {
                                    //FIXME(Frank): recapViewPromotionCodeArray is confuse - these are "destinationPromotions"
                                    Constant.MyClassConstants.recapViewPromotionCodeArray = shopExchangeFee.promotions
                                }
                                
                                if let shopExchangePrice = shopExchangeFee.inventoryPrice, shopExchangePrice.tax != 0 {
                                    Constant.MyClassConstants.enableTaxes = true
                                } else {
                                    Constant.MyClassConstants.enableTaxes = false
                                }
                            }
                        }
                    }

                    if let checkOutViewController = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil).instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as? CheckOutViewController {
                        checkOutViewController.selectedRelinquishment = self.selectedRelinquishment
                        checkOutViewController.renewalCoreProduct = self.renewalCoreProduct
                        checkOutViewController.renewalNonCoreProduct = self.renewalNonCoreProduct
                        self.navigationController?.pushViewController(checkOutViewController, animated: true)
                    }
                    
                }, onError: { [weak self] _ in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.generic)
                })
            } else {
                
                let processRequest1 = RentalProcessPrepareContinueToCheckoutRequest()
                
                if whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
                    
                    let guest = guestCertFormDetail?.toGuest()
                    processRequest1.guest = guest
                    
                   
                }

                // Add selected renewals to the RentalProcessPrepareContinueToCheckoutRequest
                var selectedRenewals = [Renewal]()
                if let coreProduct = renewalCoreProduct {
                    let renewal = Renewal()
                    renewal.id = coreProduct.id
                    selectedRenewals.append(renewal)
                }
                if let nonCoreProduct = renewalNonCoreProduct {
                    let renewal = Renewal()
                    renewal.id = nonCoreProduct.id
                    selectedRenewals.append(renewal)
                }
                if !selectedRenewals.isEmpty {
                    processRequest1.renewals = selectedRenewals
                }
       
                showHudAsync()
                let processResort = RentalProcess()
                processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                processResort.processId = Constant.MyClassConstants.processStartResponse.processId
                
                RentalProcessClient.continueToCheckout(Session.sharedSession.userAccessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
                    DarwinSDK.logger.debug(response)
                    self.hideHudAsync()
                    Constant.MyClassConstants.continueToCheckoutResponse = response
                    
                    if let view = response.view, let rentalFees = view.fees, let rentalFee = rentalFees.rental, let rentalPrice = rentalFee.rentalPrice {
                        Constant.MyClassConstants.rentalFeeOriginalPrice = rentalPrice.price
                        
                        Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                        if !rentalPrice.taxBreakdown.isEmpty {
                            Constant.MyClassConstants.inventoryPriceTaxBreakdown = rentalPrice.taxBreakdown
                        }
                    }
                    
                    Constant.MyClassConstants.selectedDestinationPromotionOfferName = nil
                    Constant.MyClassConstants.selectedDestinationPromotionDisplayName = nil
                    
                    Constant.MyClassConstants.recapViewPromotionCodeArray.removeAll()
                    if let promotions = response.view?.fees?.rental?.promotions {
                        Constant.MyClassConstants.recapViewPromotionCodeArray = promotions
                    }

                    Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
                    Constant.MyClassConstants.rentalFees = response.view?.fees
                    
                    if Int((response.view?.fees?.rental?.rentalPrice?.tax)!) != 0 {
                        Constant.MyClassConstants.enableTaxes = true
                    } else {
                        Constant.MyClassConstants.enableTaxes = false
                    }
                   
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as? CheckOutViewController else { return }
                    viewController.renewalCoreProduct = self.renewalCoreProduct
                    viewController.renewalNonCoreProduct = self.renewalNonCoreProduct
                    
                    let transitionManager = TransitionManager()
                    self.navigationController?.transitioningDelegate = transitionManager
                    self.navigationController?.pushViewController(viewController, animated: true)
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
            }
        }
    }
    
    func showCertificateInfo() {
        let storyboard = UIStoryboard(name: "VacationSearchIphone", bundle: nil)
        guard let nav = storyboard.instantiateViewController(withIdentifier: "GestCertificateInfo") as? UINavigationController else { return }
        
        present(nav, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let relinquishmentDetails = segue.destination as? RelinquishmentDetailsViewController else { return }
        relinquishmentDetails.selectedRelinquishment = selectedRelinquishment
     }
}

//Extension class starts from here
extension WhoWillBeCheckingInViewController: UITableViewDelegate {
    
}

extension WhoWillBeCheckingInViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return requiredSectionIntTBLview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0 :
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.searchBothExchange {
                
                return 2
            } else {
                return 1
            }
        case 1 :
            return Constant.MyClassConstants.membershipContactArray.count + 1
        case 2 :
            return 1
        case 3 :
            return 2
        case 4 :
            return 6
        default :
            return 3
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        switch section {
        case 0 :
            return 80
        default :
            return 30
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactHeaderCell")
            return cell
            
        case 2, 3, 4 :
            
            let headerView = UIView(frame: CGRect(x: 20, y: 0, width: checkingInUserTBLview.frame.size.width - 40, height: 30))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 5, width: checkingInUserTBLview.frame.size.width - 40, height: 20)
            headerLabel.text = Constant.MyClassConstants.whoWillBeCheckingInHeaderTextArray[section]
            headerLabel.textColor = IntervalThemeFactory.deviceTheme.textColorGray
            headerView.addSubview(headerLabel)
            
            return headerView
            
        default :
            
            return UIView()
            
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0 :
            return 50
        case 3, 4, 5 :
            return 60
        default :
            return 90
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell
            if indexPath.row == 0 {
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortDetailsButton.tag = indexPath.row
                if let selectedResort = Constant.MyClassConstants.selectedAvailabilityResort {
                    cell.resortName?.text = selectedResort.name
                } else {
                    cell.resortName?.text = ""
                }
                cell.resortImageView?.image = #imageLiteral(resourceName: "RST_CO")
                
            } else {
                
                if let openWeek = selectedRelinquishment.openWeek {
                    cell.resortName?.text = openWeek.resort?.resortName
                    cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                } else if let deposits = selectedRelinquishment.deposit {
                    cell.resortName?.text = deposits.resort?.resortName
                    cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                } else if let selectedBucket = Constant.MyClassConstants.selectedAvailabilityInventoryBucket, let pointsCost = selectedBucket.exchangePointsCost {
                    switch Constant.exchangePointType {
                    case ExchangePointType.CIGPOINTS:
                        cell.resortName?.text = "\(pointsCost)".localized()
                        cell.lblHeading.text = ExchangePointType.CIGPOINTS.name.localized()
                        cell.resortDetailsButton.isHidden = true
                    case ExchangePointType.CLUBPOINTS:
                        cell.resortName?.text = "\(pointsCost)".localized()
                        cell.lblHeading.text = ExchangePointType.CLUBPOINTS.name.localized()
                        cell.resortDetailsButton.isHidden = true
                    case ExchangePointType.UNKNOWN:
                        break
                    }
                } else {
                    cell.resortName?.text = ""
                    cell.lblHeading.text = ""
                }
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortDetailsButton.tag = indexPath.row
                cell.resortImageView?.image = #imageLiteral(resourceName: "EXG_CO")
            }
            cell.selectionStyle = .none
            
            return cell
        case 1 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.checkingInUserListTBLcell, for: indexPath) as! CheckingInUserListTBLcell
            
            if indexPath.row == Constant.MyClassConstants.membershipContactArray.count {
                
                cell.nameLabel.text = Constant.WhoWillBeCheckingInViewControllerCellIdentifiersAndHardCodedStrings.noneOfAboveContactString
            } else {
                
                if let firstName = Constant.MyClassConstants.membershipContactArray[indexPath.row].firstName, let lastName = Constant.MyClassConstants.membershipContactArray[indexPath.row].lastName {
                    cell.nameLabel.text = "\(firstName.capitalized) \(lastName.capitalized)"
                }
            }
            if indexPath.row == whoWillBeCheckingInSelectedIndex {
                
                cell.checkBox.checked = true
                cell.contentBorderView.layer.borderColor = #colorLiteral(red: 0.8784313725, green: 0.462745098, blue: 0.2705882353, alpha: 1).cgColor
            } else {
                cell.checkBox.checked = false
                cell.contentBorderView.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
            }
            cell.contentBorderView.layer.borderWidth = 2
            cell.contentBorderView.layer.cornerRadius = 7
            cell.checkBox.tag = indexPath.row
            cell.checkBox.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            return cell
            
        case 2 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestCertificatePriceCell, for: indexPath) as! GuestCertificatePriceCell
            guard let guestPrices = Constant.MyClassConstants.guestCertificate?.prices else { return cell }
            
            var memberTier = Session.sharedSession.selectedMembership?.getProductWithHighestTier()?.productCode ?? ""
            
            //FIXME(Frank) - what is this?
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                
                var foundMemberTier = false
                
                if let exchangeFees = Constant.MyClassConstants.exchangeFees {
                    if let renewal = renewalNonCoreProduct {
                        for price in guestPrices {
                            if let priceProductCode = price.productCode, let renewalProductCode = renewal.productCode, priceProductCode == renewalProductCode {
                                memberTier = priceProductCode
                                foundMemberTier = true
                                break
                            }
                        }
                    } else if foundMemberTier == false, let renewal = renewalCoreProduct {
                        for price in guestPrices {
                            if let priceProductCode = price.productCode, let renewalProductCode = renewal.productCode, priceProductCode == renewalProductCode {
                                memberTier = priceProductCode
                                foundMemberTier = true
                                break
                            }
                        }
                    } else if foundMemberTier == false, let memberTierValue = exchangeFees.memberTier {
                        memberTier = memberTierValue
                    }
                }
     
            } else {
                    
                var foundMemberTier = false
                
                if let rentalFees = Constant.MyClassConstants.rentalFees {
                    if let renewal = renewalNonCoreProduct {
                        for price in guestPrices {
                            if let priceProductCode = price.productCode, let renewalProductCode = renewal.productCode, priceProductCode == renewalProductCode {
                                memberTier = priceProductCode
                                foundMemberTier = true
                                break
                            }
                        }
                    } else if foundMemberTier == false, let renewal = renewalCoreProduct {
                        for price in guestPrices {
                            if let priceProductCode = price.productCode, let renewalProductCode = renewal.productCode, priceProductCode == renewalProductCode {
                                memberTier = priceProductCode
                                foundMemberTier = true
                                break
                            }
                        }
                    } else if foundMemberTier == false, let memberTierValue = rentalFees.memberTier {
                        memberTier = memberTierValue
                    }
                }
            }
            
            //FIXME(Frank): - review with Business if we can take USD as the default Currency Code
            var currencyCode = "USD"
            if let selectedBucket = Constant.MyClassConstants.selectedAvailabilityInventoryBucket, let currencyCodeValue = selectedBucket.currencyCode {
                currencyCode = currencyCodeValue
            }
            
            var countryCode: String?
            if let currentProfile = Session.sharedSession.contact {
                countryCode = currentProfile.getCountryCode()
            }

            for price in guestPrices where price.productCode == memberTier {
                cell.setPrice(with: currencyCode, and: price.price, and: countryCode)
            }
            
            cell.infoButton.addTarget(self, action: #selector(showCertificateInfo), for: .touchUpInside)
            return cell
            
        case 3, 5 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
            
            cell.nameTF.text = ""
            cell.nameTF.delegate = self
            cell.nameTF.textColor = IntervalThemeFactory.deviceTheme.textColorGray
            if indexPath.section == 3 {
                
                if indexPath.row == 0 {
                    
                    if guestCertFormDetail?.firstName == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormFnamePlaceholder
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.firstName
                    }
                    
                } else {
                    
                    if guestCertFormDetail?.lastName == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormLnamePlaceholder
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.lastName
                    }
                    
                }
                
            } else {
                
                switch indexPath.row {
                case 0 :
                    if guestCertFormDetail?.email == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormEmail
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.email
                    }
                    
                case 1:
                    if guestCertFormDetail?.homePhoneNumber == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormHomePhoneNumber
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.homePhoneNumber
                    }
                default :
                    if guestCertFormDetail?.businessPhoneNumber == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormBusinessPhoneNumber
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.businessPhoneNumber
                    }
                }
            }
            cell.nameTF.tag = indexPath.row
            cell.nameTF.accessibilityValue = "\(indexPath.section)"
            cell.borderView.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
            cell.borderView.layer.borderWidth = 2
            cell.borderView.layer.cornerRadius = 5
            cell.selectionStyle = .none
            return cell
            
        default :
            
            if indexPath.row == 0 || indexPath.row == 4 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.dropDownListCell, for: indexPath) as! DropDownListCell
                if indexPath.row == 0 {
                    
                    if guestCertFormDetail?.country != "" {
                        
                        cell.selectedTextLabel.text = guestCertFormDetail?.country
                    } else {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectCountryPlaceholder
                    }
                    
                } else {
                    
                    if guestCertFormDetail?.state != "" {
                        cell.selectedTextLabel.text = guestCertFormDetail?.state
                    } else {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectState
                    }
                    
                }
                cell.dropDownButton.tag = indexPath.row
                cell.dropDownButton.accessibilityValue = "\(indexPath.section)"
                cell.dropDownButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.dropDownButtonPressed(_:)), for: .touchUpInside)
                cell.borderView.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
                cell.nameTF.text = ""
                cell.nameTF.delegate = self
                
                switch indexPath.row {
                case 1 :
                    
                    if guestCertFormDetail?.address1 == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.address1
                    }
                    
                case 2 :
                    
                    if guestCertFormDetail?.address2 == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.address2
                    }
                case 3:
                    
                    if guestCertFormDetail?.city == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.city
                    }
                    
                default :
                    
                    if guestCertFormDetail?.pinCode == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                        
                    } else {
                        cell.nameTF.text = guestCertFormDetail?.pinCode
                    }
                    
                }
                cell.nameTF.tag = indexPath.row
                cell.nameTF.accessibilityValue = "\(indexPath.section)"
                cell.borderView.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
        self.whoWillBeCheckingInSelectedIndex = indexPath.row
        if indexPath.row == Constant.MyClassConstants.membershipContactArray.count {
            guestCertFormDetail = Constant.GuestCertificateFormData()
            requiredSectionIntTBLview = 6
            checkingInUserTBLview.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 2)
            checkingInUserTBLview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            proceedToCheckoutButton.isEnabled = false
            proceedToCheckoutButton.alpha = 0.5
            guard let systemAccessToken = Constant.MyClassConstants.systemAccessToken else { return }
            LookupClient.getCountries(systemAccessToken, onSuccess: { (response) in
                Constant.countryListArray = response
                
            }, onError: { [weak self] _ in
                self?.presentErrorAlert(UserFacingCommonError.generic)
            })
            
        } else {
            guestCertFormDetail = nil
            requiredSectionIntTBLview = 2
            checkingInUserTBLview.reloadData()
            self.proceedToCheckoutButton.isEnabled = true
            self.proceedToCheckoutButton.alpha = 1.0
        }
      }
    }
}

// Extension for picker.
extension WhoWillBeCheckingInViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self.dropDownSelectionRow == 0 {
            
            return Constant.countryListArray[row].countryName
            
        } else {
            
            return Constant.stateListArray[row].name
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.dropDownSelectionRow == 0 {
            guestCertFormDetail?.country = Constant.countryListArray[row].countryName ?? ""
            guestCertFormDetail?.countryCode = Constant.countryListArray[row].countryCode ?? ""
            
            if let countryCode = guestCertFormDetail?.countryCode {
                Helper.getStates(countryCode: countryCode, CompletionBlock: { [weak self] error in
                    if let Error = error {
                        self?.presentErrorAlert(UserFacingCommonError.handleError(Error))
                    }
                })
            }
        } else {
            if !Constant.stateListArray.isEmpty {
                guard let stateName = Constant.stateListArray[row].name, let code = Constant.stateListArray[row].code else { return }
                
                guestCertFormDetail?.state = stateName
                guestCertFormDetail?.stateCode = code
                
            }
            
        }
    }
}

extension WhoWillBeCheckingInViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if dropDownSelectionRow == 0 {
            
            return Constant.countryListArray.count
        } else {
            
            return Constant.stateListArray.count
        }
        
    }
}

//***** extension class for uitextfield delegate methods definition *****//
extension WhoWillBeCheckingInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeField?.resignFirstResponder()
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField?.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = textField.text as NSString? ?? ""
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        guard let accessibilityValue = textField.accessibilityValue else { return false }
        
            switch (Int(accessibilityValue)) ?? 0 {
            case 3 :
                if !textAfterUpdate.isEmpty {
                    textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                } else {
                    textField.superview?.layer.borderColor = UIColor.red.cgColor
                }
                
                if textField.tag == 0 {
                    guestCertFormDetail?.firstName = textAfterUpdate
                } else {
                    guestCertFormDetail?.lastName = textAfterUpdate
                }
            case 4 :
                
                switch textField.tag {
                case 0, 4 :
                    break
                    
                case 1 :
                    guestCertFormDetail?.address1 = textAfterUpdate
                case 2 :
                    guestCertFormDetail?.address2 = textAfterUpdate
                case 3 :
                    guestCertFormDetail?.city = textAfterUpdate
                default :
                    guestCertFormDetail?.pinCode = textAfterUpdate
                }
                
            default :
                
                switch textField.tag {
                case 0 :
                    guestCertFormDetail?.email = textAfterUpdate
                    
                    let eml = self.isValidEmail(testStr: guestCertFormDetail?.email ?? "")
                    
                    if eml || !textAfterUpdate.isEmpty {
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                    } else {
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                    }
                    
                case 1 :
                    guestCertFormDetail?.homePhoneNumber = textAfterUpdate
                default :
                    guestCertFormDetail?.businessPhoneNumber = textAfterUpdate
                }
            }
            let detailStatus = guestCertFormDetail?.isFilledOut() ?? false
            enableGuestButton(status: detailStatus)
            return  true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeField = textField
        guard let accessibilityValue = textField.accessibilityValue else { return }
        switch Int(accessibilityValue) ?? 0 {
        case 3 :
            textField.keyboardType = .default
        case 4 :
            if textField.tag != 0 && textField.tag != 1 && textField.tag != 2 && textField.tag != 3 && textField.tag != 4 {
                
                textField.keyboardType = .numberPad
                addDoneButtonOnNumpad(textField: textField)
            }
        default :
            
            switch textField.tag {
            case 0 :
                moved = true
                textField.keyboardType = .default
            case 1 :
                moved = true
                textField.keyboardType = .numberPad
                addDoneButtonOnNumpad(textField: textField)
            default :
                self.moved = true
                textField.keyboardType = .numberPad
                addDoneButtonOnNumpad(textField: textField)
            }
        }
    }
    
}

// MARK: - Extension for renewals
extension WhoWillBeCheckingInViewController: RenewelViewControllerDelegate {
    func dismissWhatToUse(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?) {
        
    }
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?, selectedRelinquishment: ExchangeRelinquishment) {
        self.renewalCoreProduct = renewalCoreProduct
        self.renewalNonCoreProduct = renewalNonCoreProduct
        Constant.MyClassConstants.noThanksForNonCore = false
        let button = UIButton()
        proceedToCheckoutPressed(button)
    }
    
    func noThanks(selectedRelinquishment: ExchangeRelinquishment) {
        let messageString = "Guest Certificate Fee will be charged. To proceed further please click on OK button else click on cancel to select the renewal of membership.".localized()
        presentAlert(with: "Alert".localized(), message: messageString)
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        let button = UIButton()
        proceedToCheckoutPressed(button)
    }
}
