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
    var activeField: UITextField?
    var moved: Bool = false
    var cellUsedFor = ""
    var proceedStatus = false
    var pickerBaseView: UIView!
    var pickerView: UIPickerView!
    var hideStatus = false
    var dropDownSelectionRow = -1
    var dropDownSelectionSection = -1
    var holdingTimer: Timer!
    var decreaseValue = 1
    var selectedCountryIndex: Int?
    var isFromRenewals = false
    var renewalsArray = [Renewal()]
    
    var filterRelinquishments = ExchangeRelinquishment()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
         resortHoldingTimeLabel.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.vacationSearchCheckingIn
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        self.proceedToCheckoutButton.isEnabled = false
        self.proceedToCheckoutButton.alpha = 0.5
        Constant.startTimer()
        self.title = Constant.ControllerTitles.whoWillBeCheckingInControllerTitle
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(WhoWillBeCheckingInIPadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        // omniture tracking with event 37
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products: Constant.MyClassConstants.selectedResort.resortCode!,
            Constant.omnitureEvars.eVar37: Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex),
            Constant.omnitureEvars.eVar39: ""
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event37, data: userInfo)
        
    }

    //***** Notification for update timer.*****//
    func updateResortHoldingTime() {
        if Constant.holdingTime != 0 {
            resortHoldingTimeLabel.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        } else {
            Constant.holdingTimer?.invalidate()
            let alertController = UIAlertController(title: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage, preferredStyle: .alert)
            let Ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default) { (_:UIAlertAction)  in
                
                self.performSegue(withIdentifier: "unwindToAvailabiity", sender: self)
            }
            alertController.addAction(Ok)
            present(alertController, animated: true, completion:nil)
        }
        
    }

    
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func guestFormCheckForDetails() -> Bool {
        
        if Constant.GetawaySearchResultGuestFormDetailData.firstName != "" && Constant.GetawaySearchResultGuestFormDetailData.lastName != "" && Constant.GetawaySearchResultGuestFormDetailData.country != "" && Constant.GetawaySearchResultGuestFormDetailData.address1 != "" && Constant.GetawaySearchResultGuestFormDetailData.address2 != "" && Constant.GetawaySearchResultGuestFormDetailData.city != "" && Constant.GetawaySearchResultGuestFormDetailData.state != "" && Constant.GetawaySearchResultGuestFormDetailData.pinCode != "" && Constant.GetawaySearchResultGuestFormDetailData.email != "" && Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber != "" && Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber != "" {
            proceedStatus = true
        } else {
            proceedStatus = false
        }
        
        return proceedStatus
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {

        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
            UIBarButtonItem(title: Constant.AlertPromtMessages.done, style: UIBarButtonItemStyle.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        // add a toolbar with a done button above the number pad
        textField.inputAccessoryView = keypadToolbar
    }
    
    // Function to dismis current controller on back button pressed.
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        showHudAsync()
        if Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            Constant.holdingTimer?.invalidate()
            
            ExchangeProcessClient.backToChooseExchange(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, onSuccess: {(_) in
                
                Constant.MyClassConstants.selectedCreditCard.removeAll()
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
                self?.presentAlert(with: "Who will be checking in".localized(), message: Constant.AlertMessages.operationFailedMessage)
            })
        } else {
            
            Constant.holdingTimer?.invalidate()
            RentalProcessClient.backToChooseRental(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess: {(_) in
                
                Constant.MyClassConstants.selectedCreditCard.removeAll()
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
                self?.presentAlert(with: "Who will be checking in".localized(), message: Constant.AlertMessages.operationFailedMessage)
            })
        }
        
    }
    
    //***** Checkout using guest. *****//
    func enableGuestFormCheckout() {
        
        self.proceedToCheckoutButton.isEnabled = true
        self.proceedToCheckoutButton.alpha = 1.0
    }
    
    func enableGuestButton(status :Bool) {
        if status {
            proceedToCheckoutButton.isEnabled = true
            proceedToCheckoutButton.alpha = 1.0
        } else {
            proceedToCheckoutButton.isEnabled = false
            proceedToCheckoutButton.alpha = 0.5
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to identify selected contact from membership contact list with checkbox selection.
    func checkBoxCheckedAtIndex(_ sender: IUIKCheckbox) {
        self.whoWillBeCheckingInSelectedIndex = sender.tag
        if sender.tag == Constant.MyClassConstants.membershipContactArray.count {
            self.requiredSectionIntTBLview = 6
            checkingInUserIPadTableView.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 2)
            checkingInUserIPadTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            self.proceedToCheckoutButton.isEnabled = false
            self.proceedToCheckoutButton.alpha = 0.5
            guard let systemAccessToken = Constant.MyClassConstants.systemAccessToken else { return }
            LookupClient.getCountries(systemAccessToken, onSuccess: { (response) in
                Constant.GetawaySearchResultGuestFormDetailData.countryListArray = response
                
            }, onError: { [weak self] _ in
                self?.presentErrorAlert(UserFacingCommonError.generic)
            })
            
        } else {
            self.requiredSectionIntTBLview = 2
            checkingInUserIPadTableView.reloadData()
            self.proceedToCheckoutButton.isEnabled = true
            self.proceedToCheckoutButton.alpha = 1.0
            
        }
    }
    
    //***** Function called when detail button is pressed. ******//
    @IBAction func resortDetailsClicked(_ sender: IUIKButton) {
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
        } else {
            
            if let openWeek = filterRelinquishments.openWeek {
                if let resortCode = openWeek.resort?.resortCode {
                    getRelinquishmentDetails(resortCode: resortCode)
                }
            }
            
            if let deposits = filterRelinquishments.deposit {
                if let resortCode = deposits.resort?.resortCode {
                    getRelinquishmentDetails(resortCode: resortCode)
                }
            }
            
            if let clubPoints = filterRelinquishments.clubPoints {
                if let resortCode = clubPoints.resort?.resortCode {
                    getRelinquishmentDetails(resortCode: resortCode)
                }
            }
        }
    }
    
    // MARK: - Function to get relinquishment details
    
    func getRelinquishmentDetails(resortCode: String) {
        self.showHudAsync()
        Helper.getRelinquishmentDetails(resortCode: resortCode, successCompletionBlock: {
            self.hideHudAsync()
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showRelinguishmentsDetailsSegue, sender: self)
        }, errorCompletionBlock: { [unowned self] error  in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
    }
    
    //***** Function called when drop down is pressed. *****//
    func dropDownButtonPressed(_ sender: IUIKButton) {
        self.dropDownSelectionRow = sender.tag
        self.dropDownSelectionSection = Int(sender.accessibilityValue!)!
        if dropDownSelectionRow == 4 && Constant.GetawaySearchResultGuestFormDetailData.stateListArray.isEmpty {
            let state = State()
            state.name = "N/A"
            state.code = ""
            Constant.GetawaySearchResultGuestFormDetailData.stateListArray.append(state)
        }
        if self.hideStatus == false {
            self.hideStatus = true
            showPickerView()
            self.pickerView.reloadAllComponents()
        } else {
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
        if self.pickerBaseView == nil {
            self.hideStatus = true
            self.createPickerView()
        } else {
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
    func pickerDoneButtonPressed(_ sender: UIButton) {
        if dropDownSelectionRow == 0 {
            if let countryIndex = selectedCountryIndex {
                if let countryCode = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[countryIndex].countryCode {
                    LookupClient.getStates(Constant.MyClassConstants.systemAccessToken!, countryCode: countryCode, onSuccess: { (response) in
                        Constant.GetawaySearchResultGuestFormDetailData.stateListArray = response
                    }, onError: { [weak self] _ in
                        self?.presentErrorAlert(UserFacingCommonError.generic)
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
        
        if Constant.MyClassConstants.noThanksForNonCore && self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
            viewController.delegate = self
            Constant.MyClassConstants.enableGuestCertificate = false
            Constant.MyClassConstants.noThanksForNonCore = false
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            let navController = UINavigationController(rootViewController: viewController)
            self.present(navController, animated: true, completion: nil)
        } else {
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.searchBothExchange {
                let exchangeProcessRequest = ExchangeProcessContinueToCheckoutRequest()
                
                if self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
                    
                    let guest = Guest()
                    
                    guest.firstName = Constant.GetawaySearchResultGuestFormDetailData.firstName
                    guest.lastName = Constant.GetawaySearchResultGuestFormDetailData.lastName
                    guest.primaryTraveler = true
                    
                    let guestAddress = Address()
                    var address = [String]()
                    address.append(Constant.GetawaySearchResultGuestFormDetailData.address1)
                    address.append(Constant.GetawaySearchResultGuestFormDetailData.address2)
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
                } else {
                    Constant.MyClassConstants.enableGuestCertificate = false
                    
                    /*let guest = Guest()
                     guest.firstName = ""
                     guest.lastName = ""
                     var phoneNumbers = [Phone]()
                     guest.phones = phoneNumbers
                     let guestAddress = Address()
                     guest.address = guestAddress
                     exchangeProcessRequest.guest = guest*/
                }
                
                if renewalsArray.count > 0 {
                    exchangeProcessRequest.renewals = renewalsArray
                }
                
                let processResort = ExchangeProcess()
                processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                showHudAsync()
                
                ExchangeProcessClient.continueToCheckout(Session.sharedSession.userAccessToken, process: processResort, request: exchangeProcessRequest, onSuccess: {(response) in
                    DarwinSDK.logger.debug(response)
                    self.hideHudAsync()
                    Constant.MyClassConstants.exchangeContinueToCheckoutResponse = response
                    
                    if let promotions = response.view?.fees?.shopExchange?.promotions {
                        Constant.MyClassConstants.recapViewPromotionCodeArray = promotions
                    }
                    
                    if let allowedCreditTypes = response.view?.allowedCreditCardTypes {
                        Constant.MyClassConstants.allowedCreditCardType = allowedCreditTypes
                    }
   
                    if let exchangeFees = response.view?.fees {
                        Constant.MyClassConstants.exchangeFees = [exchangeFees]
                    }
                    
                    if Int((response.view?.fees?.shopExchange?.rentalPrice?.tax) ?? 0) != 0 {
                        Constant.MyClassConstants.enableTaxes = true
                    } else {
                        Constant.MyClassConstants.enableTaxes = false
                    }
                    if let creditCards = Session.sharedSession.contact?.creditcards {
                        Constant.MyClassConstants.memberCreditCardList = creditCards
                    }
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as? CheckOutIPadViewController else { return }
                    viewController.filterRelinquishments = self.filterRelinquishments
                    
                    let transitionManager = TransitionManager()
                    self.navigationController?.transitioningDelegate = transitionManager
                    self.navigationController!.pushViewController(viewController, animated: true)
                }, onError: { [weak self] error in
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    self?.hideHudAsync()
                })
            } else {
                let processRequest1 = RentalProcessPrepareContinueToCheckoutRequest()
                
                if self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
                    
                    let guest = Guest()
                    
                    guest.firstName = Constant.GetawaySearchResultGuestFormDetailData.firstName
                    guest.lastName = Constant.GetawaySearchResultGuestFormDetailData.lastName
                    guest.primaryTraveler = true
                    
                    let guestAddress = Address()
                    var address = [String]()
                    address.append(Constant.GetawaySearchResultGuestFormDetailData.address1)
                    address.append(Constant.GetawaySearchResultGuestFormDetailData.address2)
                    guestAddress.addressLines = address
                    
                    guestAddress.cityName = Constant.GetawaySearchResultGuestFormDetailData.city
                    guestAddress.postalCode = Constant.GetawaySearchResultGuestFormDetailData.pinCode
                    guestAddress.addressType = "HADDR"
                    guestAddress.territoryCode = Constant.GetawaySearchResultCardFormDetailData.stateCode
                    guestAddress.countryCode = Constant.GetawaySearchResultCardFormDetailData.countryCode
                    
                    var phoneNumbers = [Phone]()
                    let homePhoneNo = Phone()
                    homePhoneNo.phoneNumber = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
                    homePhoneNo.countryPhoneCode = "1"
                    homePhoneNo.phoneType = "HOME_PRIMARY"
                    homePhoneNo.areaCode = "305"
                    homePhoneNo.countryCode = Constant.GetawaySearchResultCardFormDetailData.countryCode
                    phoneNumbers.append(homePhoneNo)
                    
                    guest.phones = phoneNumbers
                    guest.address = guestAddress
                    processRequest1.guest = guest
                    
                    Constant.MyClassConstants.enableGuestCertificate = true
                }
                
                if renewalsArray.count > 0 {
                    processRequest1.renewals = renewalsArray
                }
                showHudAsync()
                let processResort = RentalProcess()
                processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                processResort.processId = Constant.MyClassConstants.processStartResponse.processId
                
                RentalProcessClient.continueToCheckout(Session.sharedSession.userAccessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
                    DarwinSDK.logger.debug(response)
                    self.hideHudAsync()
                    Constant.MyClassConstants.continueToCheckoutResponse = response
                    
                    if let promotions = response.view?.fees?.rental?.promotions {
                        Constant.MyClassConstants.recapViewPromotionCodeArray = promotions
                    }
                    Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
                    Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
                    if Int((response.view?.fees?.rental?.rentalPrice?.tax)!) != 0 {
                        Constant.MyClassConstants.enableTaxes = true
                    } else {
                        Constant.MyClassConstants.enableTaxes = false
                    }
                    Constant.MyClassConstants.memberCreditCardList = Session.sharedSession.contact?.creditcards ?? []
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as? CheckOutIPadViewController else { return }
                    
                    let transitionManager = TransitionManager()
                    self.navigationController?.transitioningDelegate = transitionManager
                    self.navigationController!.pushViewController(viewController, animated: true)
                }, onError: {[weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    
                })
            }
        }
    }
    
    func showCertificateInfo() {
        let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "GestCertificateInfo") as! UINavigationController
        
        self.present(nav, animated: true, completion: nil)
    }
    
}

//Extension class starts from here
//Implementation of tableview delegate methods
extension WhoWillBeCheckingInIPadViewController: UITableViewDelegate {
    
}

//Implementation of tableview data source methods
extension WhoWillBeCheckingInIPadViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.requiredSectionIntTBLview
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                return 2
            } else {
                return 1
            }
        } else if section == 1 {
            return Constant.MyClassConstants.membershipContactArray.count + 1
        } else if section == 2 {
            
            return 1
        } else if section == 3 {
            return 2
        } else if section == 4 {
            return 6
        } else {
            
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 80
        } else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkingInUserIPadTableView.frame.size.width, height: 100))
            
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 20, width: checkingInUserIPadTableView.frame.size.width - 40, height: 60)
            headerLabel.text = Constant.WhoWillBeCheckingInViewControllerCellIdentifiersAndHardCodedStrings.contactListHeaderString
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 15)
            headerLabel.numberOfLines = 2
            
            headerView.addSubview(headerLabel)
            
            return headerView
        } else {
            
            return nil
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 80
        } else if indexPath.section >= 3 {
            return 80
        } else {
            return 120
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0 :
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as? ViewDetailsTBLcell else { return UITableViewCell() }
            cell.setUpDetailsCell(indexPath: indexPath, filterRelinquishments: filterRelinquishments)
            
            return cell
        case 1 :
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.checkingInUserListTBLcell, for: indexPath) as? CheckingInUserListTBLcell else { return UITableViewCell() }
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
                cell.contentBorderView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
            }
            cell.contentBorderView.layer.borderWidth = 2
            cell.contentBorderView.layer.cornerRadius = 7
            cell.checkBox.tag = indexPath.row
            cell.checkBox.addTarget(self, action: #selector(WhoWillBeCheckingInIPadViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        case 2 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestCertificatePriceCell, for: indexPath) as! GuestCertificatePriceCell
            guard let guestPrices = Constant.MyClassConstants.guestCertificate?.prices else { return cell }
            
            var memberTier = ""
            if Constant.MyClassConstants.isFromExchange {
                if Constant.MyClassConstants.exchangeFees.count > 0 {
                    memberTier = Constant.MyClassConstants.exchangeFees[0].memberTier!
                } else {
                    memberTier = ""
                }
                
            } else {
                memberTier = Constant.MyClassConstants.rentalFees[0].memberTier!
            }
            
            for price in guestPrices where price.productCode == memberTier {
                
                let floatPriceString = "\(price.price)"
                let priceArray = floatPriceString.components(separatedBy: ".")
                cell.certificatePriceLabel.text = "\(priceArray.first!)."
                if (priceArray.last?.characters.count)! > 1 {
                    cell.fractionValue.text = "\(priceArray.last!)"
                } else {
                    cell.fractionValue.text = "\(priceArray.last!)0"
                }
            }
            
            cell.infoButton.addTarget(self, action: #selector(showCertificateInfo), for: .touchUpInside)
            return cell
            
        case 3, 5 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
            cell.nameTF.text = ""
            cell.nameTF.delegate = self
            if indexPath.section == 3 {
                
                if indexPath.row == 0 {
                    if Constant.GetawaySearchResultGuestFormDetailData.firstName == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormFnamePlaceholder
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.firstName
                    }
                } else {
                    if Constant.GetawaySearchResultGuestFormDetailData.lastName == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormLnamePlaceholder
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.lastName
                    }
                }
                
            } else {
                
                if indexPath.row == 0 {
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.email == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormEmail
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.email
                    }
                } else if indexPath.row == 1 {
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormHomePhoneNumber
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
                    }
                } else {
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormBusinessPhoneNumber
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber
                    }
                }
                
            }
            cell.nameTF.tag = indexPath.row
            self.cellUsedFor = Constant.MyClassConstants.guestString
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
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.country != "" {
                        
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultGuestFormDetailData.country
                    } else {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectCountryPlaceholder
                    }
                    
                } else {
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.state != "" {
                        
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultGuestFormDetailData.state
                    } else {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectState
                    }
                    
                }
                cell.dropDownButton.tag = indexPath.row
                cell.dropDownButton.accessibilityValue = "\(indexPath.section)"
                cell.dropDownButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.dropDownButtonPressed(_:)), for: .touchUpInside)
                cell.borderView.layer.borderColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
                cell.nameTF.text = ""
                cell.nameTF.delegate = self
                if indexPath.row == 1 {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                } else if indexPath.row == 2 {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                } else if indexPath.row == 3 {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                } else {
                    cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                }
                
                self.cellUsedFor = Constant.MyClassConstants.guestString
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
}

// Extension class for implementing picker view delegate methods

extension WhoWillBeCheckingInIPadViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.dropDownSelectionRow == 0 {
            
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName
        } else {
            
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.dropDownSelectionRow == 0 {
            guard let countryName = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName else { return }
            Constant.GetawaySearchResultGuestFormDetailData.country = countryName
            selectedCountryIndex = row
        } else {
            guard let stateName = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name else { return }
            Constant.GetawaySearchResultGuestFormDetailData.state = stateName
        }
    }
}

// Extension class for implementing picker view data source methods
extension WhoWillBeCheckingInIPadViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if self.dropDownSelectionRow == 0 {
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray.count
        } else {
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray.count
        }
    }
}

extension WhoWillBeCheckingInIPadViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeField?.resignFirstResponder()
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField?.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText1: NSString = textField.text as NSString? ?? ""
        let txtAfterUpdate = textFieldText1.replacingCharacters(in: range, with: string)
        
        guard let accessibilityValue = textField.accessibilityValue else { return false }
        guard let textFieldText = textField.text else { return false }
        
        switch (Int(accessibilityValue)) ?? 0 {
        case 3 :
            if !txtAfterUpdate.isEmpty {
                textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
            } else {
                textField.superview?.layer.borderColor = UIColor.red.cgColor
            }
            
            if textField.tag == 0 {
                Constant.GetawaySearchResultGuestFormDetailData.firstName = txtAfterUpdate
            } else {
                Constant.GetawaySearchResultGuestFormDetailData.lastName = txtAfterUpdate
            }
        case 4 :
            
            switch textField.tag {
            case 0, 4 :
                break
                
            case 1 : Constant.GetawaySearchResultGuestFormDetailData.address1 = txtAfterUpdate
            case 2 :
                Constant.GetawaySearchResultGuestFormDetailData.address2 = txtAfterUpdate
            case 3 :
                Constant.GetawaySearchResultGuestFormDetailData.city = txtAfterUpdate
            default :
                Constant.GetawaySearchResultGuestFormDetailData.pinCode = txtAfterUpdate
            }
            
        default :
            
            switch textField.tag {
            case 0 :
                Constant.GetawaySearchResultGuestFormDetailData.email = txtAfterUpdate
                
                let eml = self.isValidEmail(testStr: Constant.GetawaySearchResultGuestFormDetailData.email)
                
                if eml || !txtAfterUpdate.isEmpty {
                    textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                } else {
                    textField.superview?.layer.borderColor = UIColor.red.cgColor
                }
                
            case 1 : Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber = txtAfterUpdate
            default : Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber = txtAfterUpdate
            }
        }
        let detailStatus = guestFormCheckForDetails()
        enableGuestButton(status: detailStatus)
        return  true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeField = textField
        
        if Int(textField.accessibilityValue!) == 3 {
            
            textField.keyboardType = .default
        } else if Int(textField.accessibilityValue!) == 4 {
            
            if textField.tag != 0 && textField.tag != 1 && textField.tag != 2 && textField.tag != 3 && textField.tag != 4 {
                
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
            
        } else {
            
            if textField.tag == 0 {
                
                self.moved = true
                textField.keyboardType = .default
            } else if textField.tag == 1 {
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            } else {
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
        }
    }
    
}
// MARK: - Extension for renewals
extension WhoWillBeCheckingInIPadViewController: RenewelViewControllerDelegate {
    
    func otherOptions(forceRenewals: ForceRenewals) {
        let button = UIButton()
        self.proceedToCheckoutPressed(button)
        
    }
    
    func dismissWhatToUse(renewalArray: [Renewal]) {
        
    }
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalArray: [Renewal]) {
        self.renewalsArray = renewalArray
        Constant.MyClassConstants.noThanksForNonCore = false
        let button = UIButton()
        self.proceedToCheckoutPressed(button)
    }
    
    func noThanks() {
        self.dismiss(animated: true, completion: nil)
        let button = UIButton()
        Constant.MyClassConstants.isDismissWhoWillBeCheckin = true
        self.proceedToCheckoutPressed(button)
    }
}
