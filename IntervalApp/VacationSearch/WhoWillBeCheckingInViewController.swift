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
    @IBOutlet weak var checkingInUserTBLview: UITableView!
    @IBOutlet private weak var proceedToCheckoutButton: IUIKButton!
    
    @IBOutlet private var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var filterRelinquishments = ExchangeRelinquishment()
    
    //Class variables
    var isKeyBoardOpen = false
    var moved: Bool = false
    var activeField: UITextField?
    var cellUsedFor = ""
    var proceedStatus = false
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
    var renewalsArray = [Renewal()]
    var noThanksSelected = false
    var isFromRenewals = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Constant.GetawaySearchResultGuestFormDetailData.firstName = ""
        Constant.GetawaySearchResultGuestFormDetailData.lastName = ""
        Constant.GetawaySearchResultGuestFormDetailData.country = ""
        Constant.GetawaySearchResultGuestFormDetailData.address1 = ""
        Constant.GetawaySearchResultGuestFormDetailData.address2 = ""
        Constant.GetawaySearchResultGuestFormDetailData.city = ""
        Constant.GetawaySearchResultGuestFormDetailData.state = ""
        Constant.GetawaySearchResultGuestFormDetailData.pinCode = ""
        Constant.GetawaySearchResultGuestFormDetailData.email = ""
        Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber = ""
        Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableGuestFormCheckout), name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call country api
        Helper.getCountry(viewController: self)
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.vacationSearchCheckingIn
            ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        // omniture tracking with event 37
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products: Constant.MyClassConstants.selectedResort.resortCode!,
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
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
    
    func validateUsername(str: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z\\_]{1,18}$", options: .caseInsensitive)
            if regex.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count)).count > 0 { return true }
        } catch {}
        return false
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
    
    func guestFormCheckForDetails() -> Bool {
        
        if Constant.GetawaySearchResultGuestFormDetailData.firstName != "" && Constant.GetawaySearchResultGuestFormDetailData.lastName != "" && Constant.GetawaySearchResultGuestFormDetailData.country != "" && Constant.GetawaySearchResultGuestFormDetailData.address1 != "" && Constant.GetawaySearchResultGuestFormDetailData.address2 != "" && Constant.GetawaySearchResultGuestFormDetailData.city != "" && Constant.GetawaySearchResultGuestFormDetailData.state != "" && Constant.GetawaySearchResultGuestFormDetailData.pinCode != "" && Constant.GetawaySearchResultGuestFormDetailData.email != "" && Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber != "" && Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber != "" {
            proceedStatus = true
        } else {
            proceedStatus = false
        }
        
        return proceedStatus
    }
    
    // MARK: - NO THANKS from alert
    func noThanksPressed() {
        let button = UIButton()
        self.proceedToCheckoutPressed(button)
    }
    
    //***** Checkout using guest. *****//
    func enableGuestFormCheckout() {
        
        self.proceedToCheckoutButton.isEnabled = true
        self.proceedToCheckoutButton.alpha = 1.0
    }
    
    //***** Notification for update timer.*****//
    func updateResortHoldingTime() {
        if Constant.holdingTime != 0 {
            self.resortHoldingTimeLabel.text = Constant.holdingResortForRemainingMinutes
        } else {
            Constant.holdingTimer?.invalidate()
            self.presentAlert(with: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage, hideCancelButton: false, cancelButtonTitle: "Cancel".localized(), acceptButtonTitle: "Ok".localized(), acceptButtonStyle: .default, cancelHandler: nil, acceptHandler: {
                self.navigationController?.popViewController(animated: true)
            })
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
                self?.presentErrorAlert(UserFacingCommonError.generic)
            })
        } else {
            Constant.holdingTimer?.invalidate()
        
        RentalProcessClient.backToChooseRental(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess: {(_) in
            
                Constant.MyClassConstants.selectedCreditCard.removeAll()
                Helper.removeStoredGuestFormDetials()
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
                self?.presentAlert(with: Constant.ControllerTitles.whoWillBeCheckingInControllerTitle, message: Constant.AlertMessages.operationFailedMessage)
                
        })
        
        }
    }
    
    //***** Select member who will be checking in? *****//
    func checkBoxCheckedAtIndex(_ sender: IUIKCheckbox) {
        
        self.whoWillBeCheckingInSelectedIndex = sender.tag
        if sender.tag == Constant.MyClassConstants.membershipContactArray.count {
            
            self.requiredSectionIntTBLview = 6
            checkingInUserTBLview.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 2)
            checkingInUserTBLview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
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
            checkingInUserTBLview.reloadData()
            self.proceedToCheckoutButton.isEnabled = true
            self.proceedToCheckoutButton.alpha = 1.0
            
        }
        
    }
    
    //***** Drop down button pressed method *****//
    func dropDownButtonPressed(_ sender: IUIKButton) {
        
        if isKeyBoardOpen {
            
            self.activeField?.resignFirstResponder()
        }
        self.dropDownSelectionRow = sender.tag
        self.dropDownSelectionSection = Int(sender.accessibilityValue!)!
        if !self.hideStatus {
            
            self.hideStatus = true
            showPickerView()
            self.pickerView.reloadAllComponents()
        } else {
            
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
        
        if self.pickerBaseView == nil {
            self.hideStatus = true
            self.createPickerView()
        } else {
            
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
    func pickerDoneButtonPressed(_ sender: UIButton) {
        if dropDownSelectionRow == 0 {
            if let countryIndex = selectedCountryIndex {
                if let countryCode = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[countryIndex].countryCode {
                    LookupClient.getStates(Constant.MyClassConstants.systemAccessToken!, countryCode: countryCode, onSuccess: { (response) in
                        Constant.GetawaySearchResultGuestFormDetailData.stateListArray = response
                    }, onError: { (error) in
                        intervalPrint(error)

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
    
    func resortDetailsClicked(_ sender: IUIKCheckbox) {
        
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)

        } else {

            if let openWeek = filterRelinquishments.openWeek {
                if let resortCode = openWeek.resort?.resortCode {
                    Helper.getRelinquishmentDetails(resortCode: resortCode, viewController: self)
                }
            }
            
            if let deposits = filterRelinquishments.deposit {
                if let resortCode = deposits.resort?.resortCode {
                    Helper.getRelinquishmentDetails(resortCode: resortCode, viewController: self)
                }
            }
            
            if let clubPoints = filterRelinquishments.clubPoints {
                if let resortCode = clubPoints.resort?.resortCode {
                    Helper.getRelinquishmentDetails(resortCode: resortCode, viewController: self)
                }
            }
        }
        
    }
    
    //***** Function to perform checkout *****//
@IBAction func proceedToCheckoutPressed(_ sender: AnyObject) {
    
    if Constant.MyClassConstants.noThanksForNonCore && self.whoWillBeCheckingInSelectedIndex == Constant.MyClassConstants.membershipContactArray.count {
        Constant.MyClassConstants.enableGuestCertificate = false
        Constant.MyClassConstants.isNoThanksFromRenewalAgain = true
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
        //Constant.MyClassConstants.noThanksForNonCore = false
        viewController.delegate = self
        
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
                exchangeProcessRequest.guest = guest
                
                Constant.MyClassConstants.enableGuestCertificate = true
            } else {
                Constant.MyClassConstants.enableGuestCertificate = false
            }
            if !renewalsArray.isEmpty {
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
                
                DarwinSDK.logger.debug("Promo codes are : \(String(describing: response.view?.promoCodes))")
                DarwinSDK.logger.debug("Response is : \(String(describing: response.view?.fees)) , -------->\(response)")
                Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
                Constant.MyClassConstants.exchangeFees = [(response.view?.fees)!]
                if Int((Constant.MyClassConstants.exchangeFees[0].shopExchange?.rentalPrice?.tax)!) != 0 {
                    Constant.MyClassConstants.enableTaxes = true
                } else {
                    Constant.MyClassConstants.enableTaxes = false
                }
                
                if let creditCardInfo = Session.sharedSession.contact?.creditcards {
                    Constant.MyClassConstants.memberCreditCardList = creditCardInfo
                }
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as! CheckOutViewController
                viewController.filterRelinquishments = self.filterRelinquishments
                
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController!.pushViewController(viewController, animated: true)
            }, onError: { [weak self] _ in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.generic)
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
            
            if renewalsArray.isEmpty == false {
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
                
                DarwinSDK.logger.debug("Promo codes are : \(String(describing: response.view?.promoCodes))")
                DarwinSDK.logger.debug("Response is : \(String(describing: response.view?.fees)) , -------->\(response)")
                Constant.MyClassConstants.allowedCreditCardType = (response.view?.allowedCreditCardTypes)!
                Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
                if Int((response.view?.fees?.rental?.rentalPrice?.tax)!) != 0 {
                    Constant.MyClassConstants.enableTaxes = true
                } else {
                    Constant.MyClassConstants.enableTaxes = false
                }
                
                if let creditCardInfo = Session.sharedSession.contact?.creditcards {
                    Constant.MyClassConstants.memberCreditCardList = creditCardInfo
                }
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.checkOutViewController) as? CheckOutViewController else { return }
                
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController?.pushViewController(viewController, animated: true)
            }, onError: { [weak self] error in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.serverError(error))
            })
        }
    }
}
    
    func showCertificateInfo() {
        let storyboard = UIStoryboard(name: "VacationSearchIphone", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "GestCertificateInfo") as! UINavigationController
        
        self.present(nav, animated: true, completion: nil)
    }
}

//Extension class starts from here
extension WhoWillBeCheckingInViewController: UITableViewDelegate {
    
}

extension WhoWillBeCheckingInViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.requiredSectionIntTBLview
        
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
        case 2, 3, 4 :
            return 30
        default :
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0 :
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.checkingInUserTBLview.frame.size.width, height: 80))
            
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 10, width: checkingInUserTBLview.frame.size.width - 40, height: 60)
            headerLabel.text = Constant.MyClassConstants.whoWillBeCheckingInHeaderTextArray[section]
            headerLabel.numberOfLines = 2
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 15)
            headerView.addSubview(headerLabel)
            
            return headerView
            
        case 2, 3, 4 :
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkingInUserTBLview.frame.size.width, height: 30))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 5, width: checkingInUserTBLview.frame.size.width - 40, height: 20)
            headerLabel.text = Constant.MyClassConstants.whoWillBeCheckingInHeaderTextArray[section]
            headerView.addSubview(headerLabel)
            
            return headerView
            
        default :
            
            return nil
            
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0 :
            return 50
        case 3, 4, 5 :
            return 50
        default :
            return 80
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell
            if indexPath.row == 0 {
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortDetailsButton.tag = indexPath.row
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
                cell.resortImageView?.image = #imageLiteral(resourceName: "RST_CO")
                
            } else {
                cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                if let clubPoint = filterRelinquishments.clubPoints {
                    cell.resortName?.text = clubPoint.resort?.resortName
                } else if let openWeek = filterRelinquishments.openWeek {
                    cell.resortName?.text = openWeek.resort?.resortName
                } else if let deposits = filterRelinquishments.deposit {
                    cell.resortName?.text = deposits.resort?.resortName
                } else if filterRelinquishments.pointsProgram != nil {
                    if Constant.MyClassConstants.isCIGAvailable {
                        cell.resortDetailsButton.isHidden = true
                        cell.lblHeading.text = "CIG Points"
                        if let availablePoints = Constant.MyClassConstants.exchangeViewResponse.relinquishment?.pointsProgram?.availablePoints {
                            cell.resortName?.text = "\(availablePoints)"
                        }
                    }
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
                
                let contacts = Constant.MyClassConstants.membershipContactArray[indexPath.row]
                cell.nameLabel.text = contacts.firstName?.capitalized
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
            cell.checkBox.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
            
        case 2 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestCertificatePriceCell, for: indexPath) as! GuestCertificatePriceCell
            guard let guestPrices = Constant.MyClassConstants.guestCertificate?.prices else { return cell }
               
            var memberTier = ""
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                if !Constant.MyClassConstants.exchangeFees.isEmpty {
                    for renewal in renewalsArray {
                        for price in guestPrices {
                            if price.productCode == renewal.productCode {
                                memberTier = price.productCode!
                                break
                            } else {
                                memberTier = Constant.MyClassConstants.exchangeFees[0].memberTier!
                            }
                        }
                    }
                    
                } else {
                    memberTier = ""
                }
                
            } else {
                
                for renewal in renewalsArray {
                    for price in guestPrices {
                        if price.productCode == renewal.productCode {
                            memberTier = price.productCode!
                            break
                        } else {
                            memberTier = Constant.MyClassConstants.rentalFees[0].memberTier!
                        }
                    }
                }
            }
            
            for price in guestPrices where price.productCode == memberTier {
                let floatPriceString = "\(price.price)"
                let priceArray = floatPriceString.components(separatedBy: ".")
                Constant.MyClassConstants.guestCertificatePrice = Double(price.price)
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
                
                switch indexPath.row {
                case 0 :
                    if Constant.GetawaySearchResultGuestFormDetailData.email == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormEmail
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.email
                    }
                    
                case 1:
                    if Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormHomePhoneNumber
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber
                    }
                default :
                    if Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber == "" {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormBusinessPhoneNumber
                        
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber
                    }
                }
            }
            self.cellUsedFor = Constant.MyClassConstants.guestString
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
                    
                        if Constant.GetawaySearchResultGuestFormDetailData.address1 == "" {
                            cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.address1
                        }
                    
                case 2 :
                    
                        if Constant.GetawaySearchResultGuestFormDetailData.address2 == "" {
                            cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.address2
                        }
                case 3:
                    
                        if Constant.GetawaySearchResultGuestFormDetailData.city == "" {
                            cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.city
                        }
                    
                default :
                    
                        if Constant.GetawaySearchResultGuestFormDetailData.pinCode == "" {
                            cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultGuestFormDetailData.pinCode
                        }
                        
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

// Extension for picker.
extension WhoWillBeCheckingInViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self.dropDownSelectionRow == 0 {
            
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName

        } else {
            
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name

        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.dropDownSelectionRow == 0 {
            Constant.GetawaySearchResultGuestFormDetailData.country = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName!
            Constant.GetawaySearchResultCardFormDetailData.countryCode = Constant.GetawaySearchResultGuestFormDetailData.countryCodeArray[row]
            Helper.getStates(country: Constant.GetawaySearchResultCardFormDetailData.countryCode, viewController: self)
        } else {
            if !Constant.GetawaySearchResultGuestFormDetailData.stateListArray.isEmpty {
                guard let stateName = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name else { return }
                
                Constant.GetawaySearchResultGuestFormDetailData.state = stateName
                Constant.GetawaySearchResultCardFormDetailData.stateCode = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].code!
                
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
            
            return Constant.GetawaySearchResultGuestFormDetailData.countryListArray.count
        } else {
            
            return Constant.GetawaySearchResultGuestFormDetailData.stateListArray.count
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
        
        if range.length == 1 && string.characters.count == 0 {
            intervalPrint("backspace tapped")
        }
        
        guard let accessibilityValue = textField.accessibilityValue else { return false }
        guard let textFieldText = textField.text else { return false }
        
        if self.cellUsedFor == Constant.MyClassConstants.guestString {
            switch (Int(accessibilityValue)) ?? 0 {
            case 3 :
                
                if textField.tag == 0 {
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.firstName.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.firstName = "\(textFieldText)\(string)"
                    }
                    
                    let vfnm = self.validateUsername(str: Constant.GetawaySearchResultGuestFormDetailData.firstName)
                    if vfnm || Constant.GetawaySearchResultGuestFormDetailData.firstName.characters.count == 0 {
                        
                        proceedStatus = true
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                    } else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                } else {
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.lastName.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.lastName = "\(textFieldText)\(string)"
                    }
                    
                    let vfnm = self.validateUsername(str: Constant.GetawaySearchResultGuestFormDetailData.lastName)
                    if vfnm || Constant.GetawaySearchResultGuestFormDetailData.lastName.characters.count == 0 {
                        proceedStatus = true
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                    } else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                    
                }
            case 4 :
                
                switch textField.tag {
                case 0, 4 :
                    break
                    
                case 1 :
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.address1.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.address1 = "\(textFieldText)\(string)"
                    }
                    
                case 2 :
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.address2.characters.removeLast()
                    } else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.address2 = "\(textFieldText)\(string)"
                    }
                case 3 :
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.city.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.city = "\(textField.text!)\(string)"
                    }
                    
                default :
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.pinCode.characters.removeLast()
                    } else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.pinCode = "\(textFieldText)\(string)"
                    }
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.pinCode.characters.count > 6 {
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    } else {
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                        proceedStatus = true
                    }
                }
                
            default :
                
                switch textField.tag {
                case 0 :
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.email.characters.removeLast()
                    } else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.email = "\(textFieldText)\(string)"
                    }
                    
                    let eml = self.isValidEmail(testStr: Constant.GetawaySearchResultGuestFormDetailData.email)
                    
                    if eml || Constant.GetawaySearchResultGuestFormDetailData.email.characters.count == 0 {
                        
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                        proceedStatus = true
                    } else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                    
                case 1 :
                        if range.length == 1 && string.characters.count == 0 {
                            Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber.characters.removeLast()
                        } else {
                            Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber = "\(textFieldText)\(string)"
                            
                            if Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber.characters.count > 9 {
                                
                                textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                                proceedStatus = true
                                
                            } else {
                                
                                textField.superview?.layer.borderColor = UIColor.red.cgColor
                                proceedStatus = false
                                
                            }
                        }
                default :
                        if range.length == 1 && string.characters.count == 0 {
                            Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber.characters.removeLast()
                        } else {
                            Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber = "\(textFieldText)\(string)"
                            
                            if Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber.characters.count > 9 {
                                
                                textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                                proceedStatus = true
                                
                            } else {
                                
                                textField.superview?.layer.borderColor = UIColor.red.cgColor
                                proceedStatus = false
                                
                            }
                            
                        }
                    
                }
            }
            if Int(accessibilityValue) == 3 {
                
                if textField.tag == 0 {
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.firstName.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.firstName = "\(textFieldText)\(string)"
                    }
                    
                    let vfnm = self.validateUsername(str: Constant.GetawaySearchResultGuestFormDetailData.firstName)
                    if vfnm || Constant.GetawaySearchResultGuestFormDetailData.firstName.characters.count == 0 {
                        
                        proceedStatus = true
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                    } else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                } else {
                    
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.lastName.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.lastName = "\(textFieldText)\(string)"
                    }
                    
                    let vfnm = self.validateUsername(str: Constant.GetawaySearchResultGuestFormDetailData.lastName)
                    if vfnm || Constant.GetawaySearchResultGuestFormDetailData.lastName.characters.count == 0 {
                        proceedStatus = true
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                    } else {
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                }
            } else if Int(accessibilityValue) == 4 {
                
                switch textField.tag {
                case 0, 4 :
                    break
                case 1 :
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.address1.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultGuestFormDetailData.address1 = "\(textFieldText)\(string)"
                    }
                case 2 :
                if range.length == 1 && string.characters.count == 0 {
                    Constant.GetawaySearchResultGuestFormDetailData.address2.characters.removeLast()
                } else {
                    
                    Constant.GetawaySearchResultGuestFormDetailData.address2 = "\(textFieldText)\(string)"
                }
                case 3:
                if range.length == 1 && string.characters.count == 0 {
                    Constant.GetawaySearchResultGuestFormDetailData.city.characters.removeLast()
                } else {
                    Constant.GetawaySearchResultGuestFormDetailData.city = "\(textFieldText)\(string)"
                }
                default :
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.pinCode.characters.removeLast()
                    } else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.pinCode = "\(textFieldText)\(string)"
                    }
                    
                    if Constant.GetawaySearchResultGuestFormDetailData.pinCode.characters.count > 6 {
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    } else {
                        
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                        proceedStatus = true
                        
                    }
                }
                
            } else {
                
                switch textField.tag {
                case 0 :
                    if range.length == 1 && string.characters.count == 0 {
                        Constant.GetawaySearchResultGuestFormDetailData.email.characters.removeLast()
                    } else {
                        
                        Constant.GetawaySearchResultGuestFormDetailData.email = "\(textFieldText)\(string)"
                    }
                    
                    let eml = self.isValidEmail(testStr: Constant.GetawaySearchResultGuestFormDetailData.email)
                    
                    if eml || Constant.GetawaySearchResultGuestFormDetailData.email.characters.count == 0 {
                        
                        textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                        proceedStatus = true
                    } else {
                        
                        textField.superview?.layer.borderColor = UIColor.red.cgColor
                        proceedStatus = false
                    }
                case 1 :
                    
                        if range.length == 1 && string.characters.count == 0 {
                            Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber.characters.removeLast()
                        } else {
                            Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber = "\(textFieldText)\(string)"
                            
                            if Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber.characters.count > 9 {
                                
                                textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                                proceedStatus = true
                                
                            } else {
                                
                                textField.superview?.layer.borderColor = UIColor.red.cgColor
                                proceedStatus = false
                                
                            }
                        }
                    
                default :
                 
                        if range.length == 1 && string.characters.count == 0 {
                            Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber.characters.removeLast()
                        } else {
                            Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber = "\(textFieldText)\(string)"
                            
                            if Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber.characters.count > 9 {
                                
                                textField.superview?.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1).cgColor
                                proceedStatus = true
                                
                            } else {
                                
                                textField.superview?.layer.borderColor = UIColor.red.cgColor
                                proceedStatus = false
                                
                            }
                        }
                }
            }
            let detailStatus = guestFormCheckForDetails()
            if detailStatus {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.enableGuestFormCheckout), object: nil)
            }
            return  true
            
        } else {
   
            if Int(accessibilityValue) == 0 {
                
                switch textField.tag {
                case 0 :
                     Constant.GetawaySearchResultCardFormDetailData.nameOnCard = "\(textFieldText)\(string)"
                case 1 :
                    Constant.GetawaySearchResultCardFormDetailData.cardNumber = "\(textFieldText)\(string)"
                default :
                    Constant.GetawaySearchResultCardFormDetailData.cvv = "\(textFieldText)\(string)"
                }
                
            } else {
                
                switch textField.tag {
                case 1 :
                    Constant.GetawaySearchResultCardFormDetailData.address1 = "\(textFieldText)\(string)"
                case 2 :
                    Constant.GetawaySearchResultCardFormDetailData.address2 = "\(textFieldText)\(string)"
                case 3 :
                    Constant.GetawaySearchResultCardFormDetailData.city = "\(textFieldText)\(string)"
                default :
                    Constant.GetawaySearchResultCardFormDetailData.pinCode = "\(textFieldText)\(string)"
                }
                
            }
            return  true
        }
       
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
                self.addDoneButtonOnNumpad(textField: textField)
            }
        default :
            
            switch textField.tag {
            case 0 :
                self.moved = true
                textField.keyboardType = .default
            case 1 :
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            default :
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
        }
    }
    
}

// MARK: - Extension for renewals
extension WhoWillBeCheckingInViewController: RenewelViewControllerDelegate {
    func dismissWhatToUse(renewalArray: [Renewal]) {
        
    }

    func selectedRenewalFromWhoWillBeCheckingIn(renewalArray: [Renewal]) {
        self.renewalsArray = renewalArray
        Constant.MyClassConstants.noThanksForNonCore = false
        let button = UIButton()
        self.proceedToCheckoutPressed(button)
    }
    
    func noThanks() {
        let messageString = "Guest Certificate Fee will be charged. To proceed further please click on OK button else click on cancel to select the renewal of membership.".localized()
        self.presentAlert(with: "Alert".localized(), message: messageString)
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        let button = UIButton()
        self.proceedToCheckoutPressed(button)
    }
}
