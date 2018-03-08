//
//  CheckOutViewController.swift
//  IntervalApp
//
//  Created by Chetu on 11/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD
import TPKeyboardAvoiding
import TPKeyboardAvoiding.UIScrollView_TPKeyboardAvoidingAdditions

class CheckOutViewController: UIViewController {
    
    //Outlets
    @IBOutlet fileprivate weak var checkoutOptionTBLview: UITableView!
    @IBOutlet private weak var remainingResortHoldingTimeLable: UILabel!
    fileprivate var tappedButtonDictionary = [Int:Bool]()
    
    //class variables
    var requiredSectionIntTBLview = 13
    var isTripProtectionEnabled = false
    var bookingCostRequiredRows = 1
    var promotionSelectedIndex = 0
    var isAgreed = false
    var isAgreedToFees = false
    let cellWebView = UIWebView()
    var showUpdateEmail = false
    var updateEmailSwitchStauts = "off"
    var emailTextToEnter = ""
    var tripRequestInProcess = false
    var isHeightZero = false
    var showLoader = false
    var showInsurance = false
    var eplusAdded = false
    var destinationPromotionSelected = false
    var recapSelectedPromotion: String?
    var recapFeesTotal: Float?
    var filterRelinquishments = ExchangeRelinquishment()
    var isDepositPromotionAvailable = false
    var renewalsArray: [Renewal] = []
    var totalRowsInCost = 0
    var totalFeesArray = NSMutableArray()
    var currencySymbol: String = ""
    static let checkoutPromotionCell = "CheckoutPromotionCell"
    var isPromotionApplied = false
    
    private let entityStore: EntityDataStore = EntityDataSource.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPromotionsAvailable()
        checkSectionsForFees()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.vacationSearchPaymentInformation
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        if !Constant.MyClassConstants.hasAdditionalCharges {
            isAgreedToFees = true
        }
        Constant.MyClassConstants.additionalAdvisementsArray.removeAll()
        Constant.MyClassConstants.generalAdvisementsArray.removeAll()
        
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.searchBothExchange {
            if let advisementsArray = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements {
                for advisement in advisementsArray {
                    
                    if advisement.title == Constant.MyClassConstants.additionalAdv {
                        Constant.MyClassConstants.additionalAdvisementsArray.append(advisement)
                    } else {
                        Constant.MyClassConstants.generalAdvisementsArray.append(advisement)
                    }
                }
            }
            
            if !Constant.MyClassConstants.exchangeFees.isEmpty {
                
                if let insurance = Constant.MyClassConstants.exchangeFees[0].insurance {
                    if let isInsuranceSelected = insurance.selected {
                        if isInsuranceSelected {
                            showInsurance = true
                            self.isTripProtectionEnabled = true
                        } else {
                            showInsurance = false
                            self.isTripProtectionEnabled = false
                        }
                    }
                } else {
                    showInsurance = false
                    self.isTripProtectionEnabled = false
                }
                if let curencyCode = Constant.MyClassConstants.exchangeFees[0].currencyCode {
                    let currencyHelper = CurrencyHelper()
                    currencySymbol = currencyHelper.getCurrencyFriendlySymbol(currencyCode: curencyCode)
                }
            }
        } else {
            if let advisementsArray = Constant.MyClassConstants.viewResponse.resort?.advisements {
                for advisement in advisementsArray {
                    
                    if advisement.title == Constant.MyClassConstants.additionalAdv {
                        Constant.MyClassConstants.additionalAdvisementsArray.append(advisement)
                    } else {
                        Constant.MyClassConstants.generalAdvisementsArray.append(advisement)
                    }
                }
            }
            
            if let insurance = Constant.MyClassConstants.rentalFees[0].insurance?.insuranceOfferHTML {
                showInsurance = true
                if let isInsuranceSelected = Constant.MyClassConstants.rentalFees[0].insurance?.selected {
                    if isInsuranceSelected {
                        showInsurance = true
                        self.isTripProtectionEnabled = true
                    } else {
                        showInsurance = false
                        self.isTripProtectionEnabled = false
                    }
                }
            } else {
                showInsurance = false
            }
            if let currencyCode = Constant.MyClassConstants.rentalFees[0].currencyCode {
                let currencyHelper = CurrencyHelper()
                currencySymbol = currencyHelper.getCurrencyFriendlySymbol(currencyCode: currencyCode)
            }
        }
        
        //Register custom cell xib with tableview
        
        checkoutOptionTBLview.register(UINib(nibName: Constant.customCellNibNames.totalCostCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.totalCostCell)
        
        checkoutOptionTBLview.register(UINib(nibName: Constant.customCellNibNames.promotionsDiscountCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.promotionsDiscountCell)
        
        checkoutOptionTBLview.register(UINib(nibName: Constant.customCellNibNames.exchangeOrProtectionCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell)
        
        checkoutOptionTBLview.register(UINib(nibName: Constant.customCellNibNames.slideAgreeButtonCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.slideAgreeButtonCell)
        
        self.title = Constant.ControllerTitles.checkOutControllerTitle
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(CheckOutViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        self.updateResortHoldingTime()
        
        var resortCode = ""
        var creditCardsCount = 0
        
        if let count = Session.sharedSession.contact?.creditcards?.count {
            creditCardsCount = count
        }
        if let code = Constant.MyClassConstants.selectedResort.resortCode {
            resortCode = code
        }
        
        // omniture tracking with event 38
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products: resortCode,
            Constant.omnitureEvars.eVar37: Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex),
            Constant.omnitureEvars.eVar39: "",
            Constant.omnitureEvars.eVar49: "",
            Constant.omnitureEvars.eVar52: "\(creditCardsCount > 0 ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no)",
            Constant.omnitureEvars.eVar72: "\(self.showInsurance ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no)"
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event37, data: userInfo)
    }
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
    }
    
     @IBAction func unwindToCheckout(_ segue: UIStoryboardSegue) {}
    
    //***** Function called when notification for slide to agree button is fired. *****//
    func changeLabelStatus(notification: NSNotification) {
        
        guard let imageSlider = notification.object as? UIImageView else { return }
        if Constant.MyClassConstants.indexSlideButton == 12 {
            
            let confirmationDelivery = ConfirmationDelivery()
            confirmationDelivery.emailAddress = self.emailTextToEnter
            confirmationDelivery.updateProfile = false
            
            let jsStringAccept = "document.getElementById('WASCInsuranceOfferOption0').checked == true;"
            let jsStringReject = "document.getElementById('WASCInsuranceOfferOption1').checked == true;"
            
            let strAccept = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringAccept)
            let strReject = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringReject)
            
            if (isAgreedToFees || !Constant.MyClassConstants.hasAdditionalCharges) && !Constant.MyClassConstants.selectedCreditCard.isEmpty && (strAccept == Constant.MyClassConstants.status || strReject == Constant.MyClassConstants.status || !showInsurance) && (isPromotionApplied || Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty) {
                
                showHudAsync()
                imageSlider.isHidden = true
                showLoader = true
                
                if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                    self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                    
                    let continueToPayRequest = ExchangeProcessContinueToPayRequest()
                    continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard.last
                    continueToPayRequest.confirmationDelivery = confirmationDelivery
                    continueToPayRequest.acceptTermsAndConditions = true
                    continueToPayRequest.acknowledgeAndAgreeResortFees = true
                    
                    ExchangeProcessClient.continueToPay(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { [weak self] response in
                        guard let strongSelf = self else { return }
                        Constant.MyClassConstants.exchangeBookingLastStartedProcess = nil
                        Constant.MyClassConstants.exchangeContinueToPayResponse = response
                        let selectedCard = Constant.MyClassConstants.selectedCreditCard
                        if selectedCard[0].saveCardIndicator == true {
                            Session.sharedSession.contact?.creditcards?.append(selectedCard[0])
                        }
                        Constant.MyClassConstants.selectedCreditCard.removeAll()
                        Helper.removeStoredGuestFormDetials()
                        strongSelf.isAgreed = true
                        strongSelf.hideHudAsync()
                        strongSelf.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        if let confirmationNumber = response.view?.fees?.shopExchange?.confirmationNumber {
                            Constant.MyClassConstants.transactionNumber = confirmationNumber
                        }
                        strongSelf.navigationController?.navigationBar.isHidden = true
                        strongSelf.entityStore.delete(type: OpenWeeksStorage.self, for: .decrypted)
                            .then { strongSelf.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil) }
                            .onViewError(strongSelf.presentErrorAlert)
                    
                    }, onError: { [weak self] error in
                        guard let strongSelf = self else { return }
                        strongSelf.hideHudAsync()
                        imageSlider.isHidden = false
                        strongSelf.isAgreed = false
                        strongSelf.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        strongSelf.presentErrorAlert(UserFacingCommonError.handleError(error))
                    })
                    
                } else {
                    self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                    
                    let continueToPayRequest = RentalProcessRecapContinueToPayRequest()
                    continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard.last
                    continueToPayRequest.confirmationDelivery = confirmationDelivery
                    continueToPayRequest.acceptTermsAndConditions = true
                    continueToPayRequest.acknowledgeAndAgreeResortFees = true

                    RentalProcessClient.continueToPay(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { [weak self] response in
                        guard let strongSelf = self else { return }
                        Constant.MyClassConstants.getawayBookingLastStartedProcess = nil
                        Constant.MyClassConstants.continueToPayResponse = response
                        let selectedCard = Constant.MyClassConstants.selectedCreditCard
                        if selectedCard[0].saveCardIndicator == true {
                            Session.sharedSession.contact?.creditcards?.append(selectedCard[0])
                        }
                        Constant.MyClassConstants.selectedCreditCard.removeAll()
                        Helper.removeStoredGuestFormDetials()
                        strongSelf.isAgreed = true
                        strongSelf.hideHudAsync()
                        Constant.MyClassConstants.transactionNumber = response.view?.fees?.rental?.confirmationNumber ?? ""
                        strongSelf.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        strongSelf.navigationController?.navigationBar.isHidden = true
                        strongSelf.entityStore.delete(type: OpenWeeksStorage.self, for: .decrypted)
                            .then { strongSelf.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil) }
                            .onViewError(strongSelf.presentErrorAlert)

                        }, onError: { [weak self] error in
                        guard let strongSelf = self else { return }
                        strongSelf.hideHudAsync()
                        
                        imageSlider.isHidden = false
                        strongSelf.isAgreed = false
                        strongSelf.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        strongSelf.presentErrorAlert(UserFacingCommonError.handleError(error))
                    })
                    
                }
            } else if !isAgreedToFees && Constant.MyClassConstants.hasAdditionalCharges {
                let indexPath = IndexPath(row: 0, section: 8)
                checkoutOptionTBLview.scrollToRow(at: indexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                self.presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.feesAlertMessage)
            } else if strReject == "false" && strAccept == "false" {
                let indexPath = IndexPath(row: 0, section: 4)
                checkoutOptionTBLview.scrollToRow(at: indexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                self.presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.insuranceSelectionMessage)
                
            } else if !isPromotionApplied && !Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty {
                imageSlider.isHidden = false
                checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                self.presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.promotionsMessage)
            } else {
                imageSlider.isHidden = true
                self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                self.presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.paymentSelectionMessage)
            }
        } else {
            isAgreedToFees = true
            imageSlider.isHidden = true
            self.checkoutOptionTBLview.reloadSections([11, 12], with:.automatic)
        }
    }
    //***** Function called when notification top show trip details is fired. *****//
    func showTripDetails(notification: NSNotification) {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
        remainingResortHoldingTimeLable.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        remainingResortHoldingTimeLable.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        navigationController?.navigationBar.isHidden = false
        emailTextToEnter = Session.sharedSession.contact?.emailAddress ?? ""
        
        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
            if let selectedPromotion = Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName {
                self.recapSelectedPromotion = selectedPromotion
                if selectedPromotion == "" {
                    Constant.MyClassConstants.isPromotionsEnabled = false
                    destinationPromotionSelected = false
                } else {
                    Constant.MyClassConstants.isPromotionsEnabled = true
                    destinationPromotionSelected = true
                }
                renewalsArray.removeAll()
                renewalsArray = Constant.MyClassConstants.exchangeFees[0].renewals
            }
            
            renewalsArray.removeAll()
            renewalsArray = Constant.MyClassConstants.exchangeFees[0].renewals
        } else {
            if let selectedPromotion = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName {
                self.recapSelectedPromotion = selectedPromotion
                if selectedPromotion == "" {
                    Constant.MyClassConstants.isPromotionsEnabled = false
                    destinationPromotionSelected = false
                } else {
                    Constant.MyClassConstants.isPromotionsEnabled = true
                    destinationPromotionSelected = true
                }
            }
            
            renewalsArray.removeAll()
            renewalsArray = Constant.MyClassConstants.rentalFees[0].renewals
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabelStatus), name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
        checkoutOptionTBLview.reloadData()
        
    }
    
    func updateResortHoldingTime() {
        
        if Constant.holdingTime != 0 {
            remainingResortHoldingTimeLable.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
        } else {
            Constant.holdingTimer?.invalidate()
            let alertController = UIAlertController(title: "".localized(), message: Constant.AlertMessages.holdingTimeLostMessage, preferredStyle: .alert)
            let Ok = UIAlertAction(title: "OK".localized(), style: .default) { (_:UIAlertAction)  in
                
                self.performSegue(withIdentifier: "unwindToAvailabiity", sender: self)
            }
            alertController.addAction(Ok)
            present(alertController, animated: true, completion:nil)
        }
    }
    
    func checkPromotionsAvailable() {
        if !Constant.MyClassConstants.filterRelinquishments.isEmpty {
            if let  _ = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.promotion {
                isDepositPromotionAvailable = true
            }
        }
    }
    
    // MARK: - Check Fees applied for user
    func checkSectionsForFees () {
        totalFeesArray.removeAllObjects()
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.searchBothExchange {
            
            totalFeesArray.add(Constant.MyClassConstants.exchangeFeeTitle)
            
            if Constant.MyClassConstants.enableTaxes {
                totalFeesArray.add(Constant.MyClassConstants.taxesTitle)
            }
            
            if let ePlus = Constant.MyClassConstants.exchangeFees[0].eplus {
                if ePlus.selected == true {
                    totalFeesArray.add(Constant.MyClassConstants.eplus)
                }
            }
            
            if let _ = Constant.MyClassConstants.exchangeFees[0].unitSizeUpgrade {
                totalFeesArray.add(Constant.MyClassConstants.upgradeCost)
            }
            
            if !Constant.MyClassConstants.exchangeFees[0].renewals.isEmpty {
                totalFeesArray.add(Constant.MyClassConstants.renewals)
            }
            
        } else {
            
            totalFeesArray.add(Constant.MyClassConstants.getawayFee)
            
            if Constant.MyClassConstants.enableTaxes {
                totalFeesArray.add(Constant.MyClassConstants.taxesTitle)
            }
            if !Constant.MyClassConstants.rentalFees[0].renewals.isEmpty {
                totalFeesArray.add(Constant.MyClassConstants.renewals)
            }
        }
        intervalPrint(totalFeesArray)
        
    }
    
    //***** Function called switch state is 'On' so as to update user's email. *****//
    func udpateEmailSwitchPressed(_ sender: UISwitch) {
        
        let validEmail = isValidEmail(testStr: self.emailTextToEnter)
        if validEmail {
            if sender.isOn {
                self.updateEmailSwitchStauts = "on"
            } else {
                self.updateEmailSwitchStauts = "off"
            }
        } else {
            sender.setOn(false, animated: true)
            self.presentAlert(with: Constant.buttonTitles.updateSwitchTitle, message: Constant.AlertErrorMessages.emailAlertMessage)
        }
    }
    
    //***** Function to check if the email entered by user is an valid email address. *****//
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func checkBoxCheckedAtIndex(_ sender: IUIKCheckbox) {
        
        self.promotionSelectedIndex = sender.tag
        Constant.MyClassConstants.isPromotionsEnabled = true
        self.bookingCostRequiredRows = 1
        
        let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let promotionsNav = storyboard.instantiateViewController(withIdentifier: "DepositPromotionsNav") as? UINavigationController else { return }
        guard let promotionsVC = promotionsNav.viewControllers.first as? PromotionsViewController else { return }
        promotionsVC.promotionsArray = Constant.MyClassConstants.recapViewPromotionCodeArray
        promotionsVC.completionHandler = { selected in
            self.showHudAsync()
            //Creating Request to recap with Promotion
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                let processResort = ExchangeProcess()
                processResort.currentStep = ProcessStep.Recap
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                
                let shopExchange = ShopExchange()
                if let offerSelected = Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName {
                    shopExchange.selectedOfferName = offerSelected
                }
                
                let fees = ExchangeFees()
                fees.shopExchange = shopExchange
                
                let processRequest = ExchangeProcessRecalculateRequest()
                processRequest.fees = fees
                ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                    Constant.MyClassConstants.recapPromotionsArray.removeAll()
                    
                    if let promotions = response.view?.fees?.shopExchange?.promotions {
                        Constant.MyClassConstants.recapPromotionsArray = promotions
                    }
                    
                    if let selectedPromotion = response.view?.fees?.shopExchange?.selectedOfferName {
                        self.recapSelectedPromotion = selectedPromotion
                    }
                    
                    if let total = response.view?.fees?.total {
                        Constant.MyClassConstants.exchangeFees[0].total = total
                        self.recapFeesTotal = total
                    }
                    
                    self.destinationPromotionSelected = true
                    self.checkoutOptionTBLview.reloadData()
                    self.hideHudAsync()
                    
                }, onError: { [weak self] error in
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    self?.hideHudAsync()
                })
            } else {
                let processResort = RentalProcess()
                processResort.currentStep = ProcessStep.Recap
                processResort.processId = Constant.MyClassConstants.processStartResponse.processId
                
                let rental = Rental()
                if let offerName = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName {
                    rental.selectedOfferName = offerName
                }
                
                let fees = RentalFees()
                if let offerName = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName {
                    fees.rental?.selectedOfferName = offerName
                }
                let tripProtection = Insurance()
                tripProtection.selected = Constant.MyClassConstants.rentalFees[0].insurance?.selected
                fees.insurance = tripProtection
                fees.rental = rental
                
                let processRequest = RentalProcessRecapRecalculateRequest()
                processRequest.fees = fees
                RentalProcessClient.addCartPromotion(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                    if let updatedFees = response.view?.fees {
                        Constant.MyClassConstants.rentalFees[0] = updatedFees
                    }
                    Constant.MyClassConstants.recapPromotionsArray.removeAll()
                    if let promotions = response.view?.fees?.rental?.promotions {
                        Constant.MyClassConstants.recapPromotionsArray = promotions
                    }
                    
                    if let selectedPromotion = response.view?.fees?.rental?.selectedOfferName {
                        self.recapSelectedPromotion = selectedPromotion
                    }
                    
                    if let total = response.view?.fees?.total {
                        self.recapFeesTotal = total
                    }
                    
                    self.destinationPromotionSelected = true
                    self.checkoutOptionTBLview.reloadData()
                    self.hideHudAsync()
                }, onError: { [weak self] error in
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    self?.hideHudAsync()
                })
            }
        }
        present(promotionsNav, animated: true)
    }
    
    //***** Function called when cross button is clicked in email text field. *****//
    func inputClearPressed(_ sender: UIButton) {
        
        self.emailTextToEnter = ""
        self.showUpdateEmail = true
        let indexPath = IndexPath(row: 0, section: 10)
        self.checkoutOptionTBLview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //Used to expand and contract sections
    func toggleButtonIsTapped(_ sender: UIButton) {
        if let tag = tappedButtonDictionary[sender.tag] {
            tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
        } else {
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.checkoutOptionTBLview.reloadData()
    }
    
    //***** Function to calculate dynamic height. ******//
    
    func heightForView(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func widthForView(_ text: String, font: UIFont, height: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.width
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        showHudAsync()
        
        let accessToken = Session.sharedSession.userAccessToken
        let lastRentalProcess = Constant.MyClassConstants.getawayBookingLastStartedProcess
        let lastProcessStarted = Constant.MyClassConstants.exchangeBookingLastStartedProcess
        
        let onSuccess = { [weak self] (_: Any) in
            self?.hideHudAsync()
            self?.navigationController?.popViewController(animated: true)
        }
        
        let onError = { [weak self] (_: Any) in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.generic)
        }
        
        if Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            
            ExchangeProcessClient.backToChooseExchange(accessToken,
                                                       process: lastProcessStarted,
                                                       onSuccess: onSuccess,
                                                       onError: onError)
            
        } else {
            let fees = Constant.MyClassConstants.rentalFees[0]
            intervalPrint(fees)
            
            RentalProcessClient.backToWhoIsChecking(accessToken,
                                                    process: lastRentalProcess,
                                                    onSuccess: onSuccess,
                                                    onError: onError)
        }
    }
    
    //***** Function called when radio button is selected in Add Trip Protection. *****//
    func handleTap(_ sender: UITapGestureRecognizer) {
        
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            let yesRadioValue = "document.getElementById('WASCInsuranceOfferOption0').checked == true;"
            let noRadioValue = "document.getElementById('WASCInsuranceOfferOption1').checked == true;"
            
            let strYesRadioValue = self.cellWebView.stringByEvaluatingJavaScript(from: yesRadioValue)
            let strNoRadioValue = self.cellWebView.stringByEvaluatingJavaScript(from: noRadioValue)
            
            if strYesRadioValue == "true" && !self.tripRequestInProcess && !self.isTripProtectionEnabled {
                self.tripRequestInProcess = true
                self.isTripProtectionEnabled = true
                Constant.MyClassConstants.checkoutInsurencePurchased = Constant.AlertPromtMessages.yes
                self.addTripProtection(shouldAddTripProtection: true)
                
            } else if strNoRadioValue == "true" && !self.tripRequestInProcess && self.isTripProtectionEnabled {
                self.tripRequestInProcess = true
                self.isTripProtectionEnabled = false
                Constant.MyClassConstants.checkoutInsurencePurchased = Constant.AlertPromtMessages.no
                self.addTripProtection(shouldAddTripProtection: false)
            }
        }
        
    }
    
    //***** Function for adding and removing trip protection *****//
    
    func addTripProtection( shouldAddTripProtection: Bool) {
        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
            guard let exchangeFees = Constant.MyClassConstants.exchangeFees.last else { return }
            exchangeFees.insurance?.selected = shouldAddTripProtection
            let exchangeRecalculateRequest = ExchangeProcessRecalculateRequest()
            exchangeRecalculateRequest.fees = exchangeFees
            showHudAsync()
            ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: exchangeRecalculateRequest, onSuccess: { response in
                
                self.tripRequestInProcess = false
                Constant.MyClassConstants.exchangeContinueToCheckoutResponse = response
                if let exchangeTotalFees = response.view?.fees?.total {
                    Constant.MyClassConstants.exchangeFees[0].total = exchangeTotalFees
                    self.recapFeesTotal = exchangeTotalFees
                }
                self.checkoutOptionTBLview.reloadData()
                self.hideHudAsync()
                
            }, onError: { [weak self] error in
                Constant.MyClassConstants.exchangeFees.last?.insurance?.selected = !shouldAddTripProtection
                self?.tripRequestInProcess = false
                self?.isTripProtectionEnabled = false
                self?.checkoutOptionTBLview.reloadData()
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
        } else {
            
            guard let rentalFees = Constant.MyClassConstants.rentalFees.last else { return }
            let addTripProtection = Insurance()
            addTripProtection.selected = shouldAddTripProtection
            rentalFees.insurance = addTripProtection
            
            let rental = Rental()
            rental.selectedOfferName = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName
            rentalFees.rental = rental
            let rentalRecalculateRequest = RentalProcessRecapRecalculateRequest()
            rentalRecalculateRequest.fees = rentalFees
            showHudAsync()
            RentalProcessClient.addTripProtection(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: rentalRecalculateRequest, onSuccess: { response in
                if let updatedFees = response.view?.fees {
                    Constant.MyClassConstants.rentalFees[0] = updatedFees
                }
                self.tripRequestInProcess = false
                Constant.MyClassConstants.continueToCheckoutResponse = response
                if let rentalFeesTotal = response.view?.fees?.total {
                    Constant.MyClassConstants.rentalFees[0].total = rentalFeesTotal
                    self.recapFeesTotal = rentalFeesTotal
                }
                self.checkoutOptionTBLview.reloadSections([6, 8], with:.automatic)
                self.hideHudAsync()
            }, onError: { [weak self] error in
                "document.getElementById('WASCInsuranceOfferOption0').checked = false;"
                "document.getElementById('WASCInsuranceOfferOption1').checked = false;"
                self?.tripRequestInProcess = false
                self?.isTripProtectionEnabled = false
                self?.checkoutOptionTBLview.reloadData()
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
        }
    }
    
    //***** Function called when detail button is pressed. ******//
    func resortDetailsClicked(_ sender: IUIKButton) {
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
            
        } else {
            if let clubPointResort = filterRelinquishments.clubPoints?.resort {
                if let resortCode = clubPointResort.resortCode {
                    getRelinquishmentDetails(resortCode: resortCode)
                }
            } else if let openWeekResort = filterRelinquishments.openWeek?.resort {
                if let resortCode = openWeekResort.resortCode {
                    getRelinquishmentDetails(resortCode: resortCode)
                }
            } else if let depositResort = filterRelinquishments.deposit?.resort {
                if let resortCode = depositResort.resortCode {
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
    
    //Function to add remove eplus
    @IBAction func checkBoxClicked(sender: IUIKCheckbox) {
        guard let exchangeFees = Constant.MyClassConstants.exchangeFees.last else { return }
        let exchangeRecalculateRequest = ExchangeProcessRecalculateRequest()
        exchangeRecalculateRequest.fees = exchangeFees
        exchangeRecalculateRequest.fees?.eplus?.selected = sender.checked
        showHudAsync()
        ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: exchangeRecalculateRequest, onSuccess: { recapResponse in
            self.eplusAdded = sender.checked
            if let totalExchangeFees = recapResponse.view?.fees {
                Constant.MyClassConstants.exchangeFees = [totalExchangeFees]
            }
            self.hideHudAsync()
            self.checkSectionsForFees()
            self.checkoutOptionTBLview.reloadData()
        }, onError: { [weak self] error in
            self?.eplusAdded = !sender.checked
            Constant.MyClassConstants.exchangeFees[0].eplus?.selected = sender.checked
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            self?.checkSectionsForFees()
            self?.checkoutOptionTBLview.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let relinquishmentDetails = segue.destination as? RelinquishmentDetailsViewController else { return }
        relinquishmentDetails.filterRelinquishment = filterRelinquishments
    }
}

// MARK: - Table View Delegate
extension CheckOutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 9 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.selectPaymentMethodSegue, sender: nil)
        }
    }
    
}

// MARK: - Table View Data Source
extension CheckOutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.requiredSectionIntTBLview
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0 :
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                return 2
            } else {
                return 1
            }
        case 1:
            var advisementCount = 0
            if let isOpen = tappedButtonDictionary[section] {
                if isOpen {
                    advisementCount = Constant.MyClassConstants.additionalAdvisementsArray.count + Constant.MyClassConstants.generalAdvisementsArray.count + 1
                    return advisementCount
                } else {
                    advisementCount = Constant.MyClassConstants.additionalAdvisementsArray.count + Constant.MyClassConstants.generalAdvisementsArray.count
                    return advisementCount
                }
            } else {
                advisementCount = Constant.MyClassConstants.generalAdvisementsArray.count
                return advisementCount
            }
            
        case 2 :
            var numberOfCells = 0
            if isDepositPromotionAvailable {
                numberOfCells += 1
            }
            if !Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty {
                numberOfCells += 1
            }
            
            return numberOfCells
        case 3 :
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                return 1
            } else {
                return 0
            }
        case 4 :
            if !showInsurance {
                return 0
            } else {
                return 1
            }
        case 5 :
            totalRowsInCost = totalFeesArray.count
            return totalRowsInCost
        case 6 :
            if Constant.MyClassConstants.enableGuestCertificate && self.isTripProtectionEnabled {
                return 2
            } else if Constant.MyClassConstants.enableGuestCertificate || self.isTripProtectionEnabled {
                return 1
            } else {
                return 0
            }
        case 7 :
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                if Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName == "No Thanks" || Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName?.isEmpty ?? false {
                    return 0
                } else {
                    return 1
                }
            } else {
                if Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName == "No Thanks" || Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName?.isEmpty ?? false {
                    return 0
                } else {
                    return 1
                }
            }
            
        default :
            if section == 5 && eplusAdded {
                return 2
            } else {
                return 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        switch section {
        case 1 :
            if Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty {
                return 0
            } else {
                return 50
            }
        case 2 :
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                
                return 0
            } else {
                if !Constant.MyClassConstants.exchangeFees.isEmpty {
                    if Constant.MyClassConstants.exchangeFees[0].eplus == nil {
                        return 0
                    } else {
                        return 50
                    }
                }
                return 0
                
            }
        case 3 :
            if !showInsurance {
                return 0
            } else {
                return 50
            }
        case 4, 8, 9 :
            return 50
        default :
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        switch section {
        case  1, 2, 3, 4, 8, 9 :
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkoutOptionTBLview.frame.size.width, height: 50))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 10, width: checkoutOptionTBLview.frame.size.width - 40, height: 30)
            headerLabel.text = Constant.MyClassConstants.checkOutScreenHeaderTextArray[section]
            headerView.addSubview(headerLabel)
            headerView.backgroundColor = IUIKColorPalette.primary1.color
            headerLabel.textColor = UIColor.white
            
            if section == 1 {
                if Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty {
                    return nil
                } else {
                    return headerView
                }
            } else {
                return headerView
            }
            
        default :
            return nil
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        isHeightZero = false
        
        switch indexPath.section {
        case 0 :
            return 50
        case 1 :
            guard let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0) else { return 0 }
            
            if indexPath.row == (Constant.MyClassConstants.generalAdvisementsArray.count) {
                return 30
            } else if indexPath.row != (Constant.MyClassConstants.generalAdvisementsArray.count) + 1 {
                guard let text = (Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].title)?.capitalized else { return 0 }
                guard let description = Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description else { return 0 }
                let height1 = heightForView(description, font: font, width: view.frame.size.width - 40)
                let height2 = heightForView(text, font: font, width: view.frame.size.width - 40)
                return height1 + height2 + 40
            } else {
                guard let description = Constant.MyClassConstants.additionalAdvisementsArray.last?.description else { return 0 }
                let height = heightForView(description, font: font, width: view.frame.size.width - 40)
                return height + 80
            }
            
        case 2, 9 :
            if isDepositPromotionAvailable && indexPath.row == 0 {
                return 80
            }
            return 60
        case 3 :
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                guard Constant.MyClassConstants.exchangeFees[0].eplus != nil else { return 0 }
                return 130
            } else {
                return 0
            }
        case 4 :
            if showInsurance {
                return cellWebView.scrollView.contentSize.height
            } else {
                return 0
            }
        case 5 :
            if !Constant.MyClassConstants.isFromExchange && Constant.MyClassConstants.isFromExchange && !Constant.MyClassConstants.enableTaxes && !eplusAdded {
                isHeightZero = true
                return 0
            } else {
                return UITableViewAutomaticDimension
            }
            
        case 6 :
            if !self.isTripProtectionEnabled && !Constant.MyClassConstants.enableGuestCertificate {
                isHeightZero = true
                return 0
            } else {
                return UITableViewAutomaticDimension
            }
        case 7 :
            if !Constant.MyClassConstants.isPromotionsEnabled {
                isHeightZero = true
                return 0
            } else {
                return 60
            }
            
        case 8 :
            return 60
            
        case 10 :
            if self.showUpdateEmail {
                return 130
            } else {
                return 90
            }
            
        case 11 :
            if Constant.MyClassConstants.hasAdditionalCharges {
                return 150
            } else {
                return 0
            }
            
        case 12 :
            return 100
            
        default :
            return 130
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Header Cell
        
        switch indexPath.section {
        case 0 :
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as? ViewDetailsTBLcell else { return UITableViewCell() }
            cell.resortDetailsButton.tag = indexPath.row
            
            if indexPath.row == 0 {
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
                cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.resortImage)
            } else {
                if Constant.MyClassConstants.isCIGAvailable {
                    cell.resortDetailsButton.isHidden = true
                    cell.lblHeading.text = "CIG Points".localized()
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    if let pointsCost = Constant.MyClassConstants.selectedExchangePointsCost, let availablePoints = numberFormatter.string(from: pointsCost) {
                        cell.resortName?.text = "\(availablePoints)".localized()
                    } else {
                        cell.resortName?.text = "\(0)".localized()
                    }
                } else {
                    cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                    if let clubPoint = filterRelinquishments.clubPoints {
                        cell.resortName?.text = clubPoint.resort?.resortName
                    } else if let openWeek = filterRelinquishments.openWeek {
                        cell.resortName?.text = openWeek.resort?.resortName
                    } else if let deposits = filterRelinquishments.deposit {
                        cell.resortName?.text = deposits.resort?.resortName
                    }
                    cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                }
                cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.relinquishmentImage)
            }
            cell.selectionStyle = .none
            return cell
            
        case 1:
            //Advisements Cell
            if indexPath.row == Constant.MyClassConstants.generalAdvisementsArray.count {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.advisementsCellIdentifier, for: indexPath) as? AvailableDestinationCountryOrContinentsTableViewCell else { return UITableViewCell() }
                cell.tooglebutton.addTarget(self, action: #selector(CheckOutViewController.toggleButtonIsTapped(_:)), for: .touchUpInside)
                cell.tooglebutton.tag = indexPath.section
                cell.selectionStyle = .none
                return cell
                
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.advisementsCell, for: indexPath) as? AdvisementsCell else { return UITableViewCell() }
                if indexPath.row != (Constant.MyClassConstants.generalAdvisementsArray.count) + 1 {
                    cell.advisementType.text = (Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].title)?.capitalized
                    cell.advisementTextLabel.text = Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description
                } else {
                    cell.advisementType.text = ""
                    cell.advisementTextLabel.text = Constant.MyClassConstants.additionalAdvisementsArray.last?.description
                }
                cell.advisementType.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
                cell.advisementTextLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
                cell.advisementTextLabel.numberOfLines = 0
                cell.advisementTextLabel.sizeToFit()
                cell.selectionStyle = .none
                return cell
                
            }
        case 2 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckOutViewController.checkoutPromotionCell, for: indexPath) as? CheckoutPromotionCell else { return UITableViewCell() }
            if isDepositPromotionAvailable && indexPath.row == 0 {
                cell.setupDepositPromotion()
                cell.promotionSelectionCheckBox.tag = indexPath.row
                cell.selectionStyle = .none
                return cell
            } else {
                cell.setupCell(selectedPromotion: destinationPromotionSelected)
                cell.promotionSelectionCheckBox.tag = indexPath.row
                if cell.promotionSelectionCheckBox.isHidden {
                    cell.forwardArrowButton.addTarget(self, action: #selector(CheckOutViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
                } else {
                    isPromotionApplied = true
                    cell.promotionSelectionCheckBox.addTarget(self, action: #selector(CheckOutViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
                }
                
                cell.selectionStyle = .none
                return cell
            }
        case 3 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeOptionsCell, for: indexPath) as? ExchangeOptionsCell else { return UITableViewCell() }
            cell.setupCell(selectedEplus:true)
            cell.selectionStyle = .none
            return cell
            
        case 4 :
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.additionalAdvisementCell, for: indexPath)
            var containsWebView = false
            for subVw in cell.subviews {
                if subVw.isKind(of: UIWebView.self) {
                    containsWebView = true
                }
            }
            if !containsWebView {
                cellWebView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400)
                cellWebView.scrollView.isScrollEnabled = false
                cellWebView.delegate = self
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                tapRecognizer.numberOfTapsRequired = 1
                tapRecognizer.delegate = self
                
                cellWebView.addGestureRecognizer(tapRecognizer)
                
                if showInsurance && !Constant.MyClassConstants.isFromExchange {
                    guard let str = Constant.MyClassConstants.rentalFees[indexPath.row].insurance?.insuranceOfferHTML else { return cell }
                    cellWebView.loadHTMLString(str, baseURL: nil)
                    let noRadioValue = "document.getElementById('WASCInsuranceOfferOption1').checked  = true;"
                    checkoutOptionTBLview.beginUpdates()
                    checkoutOptionTBLview.endUpdates()
                } else {
                    guard let str = Constant.MyClassConstants.exchangeFees[indexPath.row].insurance?.insuranceOfferHTML else { return cell }
                    cellWebView.loadHTMLString(str, baseURL: nil)
                }
                cellWebView.backgroundColor = UIColor.gray
                cell.addSubview(cellWebView)
            }
            cell.selectionStyle = .none
            return cell
            
        case 5 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as? ExchangeOrProtectionCell else { return UITableViewCell() }
            
            if !isHeightZero {
                for subviews in cell.subviews {
                    subviews.isHidden = false
                }
                
                switch totalFeesArray[indexPath.row] as? String ?? "" {
                case Constant.MyClassConstants.exchangeFeeTitle:
                    if let exchangeFees = Constant.MyClassConstants.exchangeFees[0].shopExchange?.rentalPrice?.price {
                        cell.setTotalPrice(with: currencySymbol, and: exchangeFees)
                    }
                    cell.priceLabel.text = Constant.MyClassConstants.exchangeFeeTitle
                    
                case Constant.MyClassConstants.getawayFee:
                    
                    if let rentalPrice = Constant.MyClassConstants.rentalFees[0].rental?.rentalPrice?.price {
                        cell.setTotalPrice(with: currencySymbol, and: rentalPrice)
                    }
                    cell.priceLabel.text = Constant.MyClassConstants.getawayFee
                    
                case Constant.MyClassConstants.eplus:
                    
                    if let ePlusPrice = Constant.MyClassConstants.exchangeFees[0].eplus?.price {
                        cell.setTotalPrice(with: currencySymbol, and: ePlusPrice)
                    }
                    cell.priceLabel.text = Constant.MyClassConstants.eplus
                    
                case Constant.MyClassConstants.taxesTitle:
                    
                    cell.priceLabel.text = Constant.MyClassConstants.taxesTitle
                    if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                        if let tax = Constant.MyClassConstants.exchangeContinueToCheckoutResponse.view?.fees?.shopExchange?.prices[0].tax {
                            cell.setTotalPrice(with: currencySymbol, and: tax)
                        }
                    } else {
                        
                        if let tax = Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.rental?.rentalPrice?.tax {
                            cell.setTotalPrice(with: currencySymbol, and: tax)
                        }
                    }
                    
                    let cellTapped: CallBack = { [unowned self] in
                        if let taxBreakdown = Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.rental?.rentalPrice?.taxBreakdown {
                            
                            let dataSet = taxBreakdown
                                .filter { !$0.description.unwrappedString.isEmpty }
                                .map { ($0.description.unwrappedString, $0.amount) }
                            
                            let currencyCodeOfFee = Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.currencyCode ?? ""
                            let currencyDescription = CurrencyHelper().getCurrency(currencyCode: currencyCodeOfFee).description
                            if currencyDescription.isEmpty {
                                return self.presentErrorAlert(UserFacingCommonError.generic)
                            }
                            let viewModel = ChargeSummaryViewModel(charge: dataSet,
                                                                   headerTitle: "Detailed Tax Information".localized(),
                                                                   descriptionTitle: "Tax Description".localized(),
                                                                   currency: currencyDescription.localized(),
                                                                   totalTitle: "Total Tax Amount".localized(),
                                                                   currencySymbol: self.currencySymbol)
                            
                            let chargeSummaryViewController = ChargeSummaryViewController(viewModel: viewModel)
                            chargeSummaryViewController.doneButtonPressed = { chargeSummaryViewController.dismiss(animated: true) }
                            self.navigationController?.present(chargeSummaryViewController, animated: true)
                        }
                    }
                    
                    cell.setCell(callBack: cellTapped)
                    
                case Constant.MyClassConstants.upgradeCost:
                    if let upgradeCost = Constant.MyClassConstants.exchangeFees[0].unitSizeUpgrade?.price {
                        cell.setTotalPrice(with: currencySymbol, and: upgradeCost)
                    }
                    cell.priceLabel.text = Constant.MyClassConstants.upgradeCost
                    
                default:
                    
                    var renewalIndex = 0
                    cell.priceLabel.numberOfLines = 0
                    if renewalsArray.count > 1 {
                        renewalIndex = 1
                        cell.priceLabel.text = "\(String(describing: renewalsArray[renewalIndex].displayName?.capitalized ?? "")) Package".localized()
                        let packagePrice = renewalsArray[renewalIndex].price + renewalsArray[0].price
                        cell.setTotalPrice(with: currencySymbol, and: packagePrice)
                    } else if renewalsArray.count == 1 {
                        if let displayName = renewalsArray[renewalIndex].displayName {
                            
                            if displayName.caseInsensitiveCompare("INTERVAL") == ComparisonResult.orderedSame {
                                cell.priceLabel.text = "\(displayName) Membership".capitalized.localized()
                            } else {
                                cell.priceLabel.text = "\(String(describing: renewalsArray[renewalIndex].displayName?.capitalized ?? ""))".localized()
                            }
                            
                        }
                        cell.setTotalPrice(with: currencySymbol, and: renewalsArray[renewalIndex].price)
                    }
                    
                }
            } else {
                
                isHeightZero = false
                for subviews in cell.subviews {
                    subviews.isHidden = true
                }
                
            }
            cell.selectionStyle = .none
            cell.primaryPriceLabel.sizeToFit()
            
            return cell
            
        case 6 :
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as? ExchangeOrProtectionCell else { return UITableViewCell() }
            
            if !isHeightZero {
                for subviews in cell.subviews {
                    subviews.isHidden = false
                }
                if indexPath.row == 0 && self.isTripProtectionEnabled {
                    cell.priceLabel.text = Constant.MyClassConstants.insurance
                    if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                        if let insurancePrice = Constant.MyClassConstants.exchangeFees[0].insurance?.price {
                            cell.setTotalPrice(with: currencySymbol, and: insurancePrice)
                        }
                    } else {
                        if let insurancePrice = Constant.MyClassConstants.rentalFees[indexPath.row].insurance?.price {
                            cell.setTotalPrice(with: currencySymbol, and: insurancePrice)
                        }
                    }
                } else {
                    cell.priceLabel.text = Constant.MyClassConstants.guestCertificateTitle
                    if let guestCertPrice = Constant.MyClassConstants.rentalFees[indexPath.row].guestCertificate?.guestCertificatePrice?.price {
                        cell.setTotalPrice(with: currencySymbol, and: guestCertPrice)
                    }
                }
            } else {
                isHeightZero = false
                for subviews in cell.subviews {
                    
                    subviews.isHidden = true
                }
            }
            cell.selectionStyle = .none
            return cell
            
        case 7 :
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.promotionsDiscountCell, for: indexPath) as? PromotionsDiscountCell else { return UITableViewCell() }
            
            if !isHeightZero {
                for subviews in cell.subviews {
                    subviews.isHidden = false
                }
                cell.discountLabel.text = recapSelectedPromotion
                for promotion in Constant.MyClassConstants.recapPromotionsArray where promotion.offerName == recapSelectedPromotion {
                    cell.setPromotionPrice(with: currencySymbol, and: promotion.amount)
                }
            } else {
                isHeightZero = false
                for subviews in cell.subviews {
                    subviews.isHidden = true
                }
            }
            cell.selectionStyle = .none
            return cell
            
        case 8 :
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.totalCostCell, for: indexPath) as? TotalCostCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                
                cell.setTotalPrice(with: currencySymbol, and: (Constant.MyClassConstants.exchangeFees[0].total))
                if let total = recapFeesTotal {
                    cell.setTotalPrice(with: currencySymbol, and: total)
                }
            } else {
                cell.setTotalPrice(with: currencySymbol, and: (Constant.MyClassConstants.rentalFees[0].total))
                if let total = recapFeesTotal {
                    cell.setTotalPrice(with: currencySymbol, and: total)
                }
            }
            return cell
            
        case 9 :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.additionalAdvisementCell, for: indexPath)
            for subviews in cell.subviews {
                subviews.removeFromSuperview()
            }
            cell.backgroundColor = UIColor.white
            let forwardArrowImageView = UIImageView(frame: CGRect(x: cell.contentView.frame.width - 40, y: 15, width: 30, height: 30))
            forwardArrowImageView.image = #imageLiteral(resourceName: "ForwardArrowIcon")
            
            let paymentMethodLabel = UILabel(frame: CGRect(x: 20, y: 10, width: cell.contentView.frame.width - 90, height: 20))
            paymentMethodLabel.text = Constant.MyClassConstants.paymentMethodTitle
            paymentMethodLabel.textColor = IUIKColorPalette.primary1.color
            
            let selectPamentMethodLabel = UILabel(frame: CGRect(x: 20, y: 30, width: cell.contentView.frame.width - 40, height: 20))
            if !Constant.MyClassConstants.selectedCreditCard.isEmpty {
                let creditcard = Constant.MyClassConstants.selectedCreditCard[0]
                guard let cardNumber = creditcard.cardNumber else { return cell }
                let last4 = cardNumber.substring(from:(cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
                guard let cardType = creditcard.typeCode else { return cell }
                let ccType = Helper.cardTypeCodeMapping(cardType: cardType)
                selectPamentMethodLabel.text = "\(ccType) ending in \(last4)"
            } else {
                selectPamentMethodLabel.text = Constant.MyClassConstants.paymentInfo
            }
            
            selectPamentMethodLabel.textColor = UIColor.darkGray
            cell.addSubview(forwardArrowImageView)
            cell.addSubview(paymentMethodLabel)
            cell.addSubview(selectPamentMethodLabel)
            cell.selectionStyle = .none
            return cell
            
        case 10 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.emailCell, for: indexPath) as? EmailTableViewCell else { return UITableViewCell() }
            cell.emailTextField.text = self.emailTextToEnter
            if self.showUpdateEmail {
                cell.updateEmailOnOffSwitch.isHidden = false
                cell.updateProfileTextLabel.isHidden = false
            } else {
                cell.updateEmailOnOffSwitch.isHidden = true
                cell.updateProfileTextLabel.isHidden = true
            }
            cell.emailTextField.delegate = self
            cell.inputClearButton.addTarget(self, action: #selector(self.inputClearPressed(_:)), for: .touchUpInside)
            cell.updateEmailOnOffSwitch.addTarget(self, action: #selector(self.udpateEmailSwitchPressed(_:)), for: .valueChanged)
            cell.selectionStyle = .none
            return cell
            
        case 11 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.agreeToFeesCell, for: indexPath) as? SlideTableViewCell else { return UITableViewCell() }
            cell.agreeButton?.dragPointWidth = 70
            cell.agreeButton?.tag = indexPath.section
            cell.agreeButton?.accessibilityValue = String(indexPath.section)
            cell.feesTitleLabel.text = Constant.AlertMessages.feesPaymentMessage
            
            if isAgreedToFees {
                cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 170 / 255, green: 202 / 255, blue: 92 / 255, alpha: 1.0)
                cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 170 / 255, green: 202 / 255, blue: 92 / 255, alpha: 1.0).cgColor
                cell.agreeLabel.text = Constant.AlertMessages.agreeToFeesMessage
                cell.agreeLabel.textColor = UIColor.white
                cell.allInclusiveSelectedCheckBox.isHidden = false
            } else {
                if let image = UIImage(named: Constant.assetImageNames.swipeArrowOrgImage) {
                    cell.agreeButton?.imageName = image
                }
                cell.allInclusiveSelectedCheckBox.isHidden = true
                cell.agreeLabel.backgroundColor = UIColor.white
                cell.agreeLabel.textColor = UIColor(colorLiteralRed: 248 / 255, green: 107 / 255, blue: 63 / 255, alpha: 1.0)
                cell.agreeLabel.layer.borderColor = #colorLiteral(red: 0.9725490196, green: 0.4196078431, blue: 0.2470588235, alpha: 1).cgColor
                cell.agreeLabel.text = Constant.AlertMessages.feesAlertMessage
            }
            cell.selectionStyle = .none
            return cell
            
        case 12 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.agreeToFeesCell, for: indexPath) as? SlideTableViewCell else { return UITableViewCell() }
            
            cell.feesTitleLabel.text = Constant.AlertMessages.termsConditionMessage
            cell.agreeButton?.dragPointWidth = 70
            cell.agreeButton?.tag = indexPath.section
            cell.allInclusiveSelectedCheckBox.isHidden = true
            cell.isUserInteractionEnabled = true
            cell.callback = { [weak self] in
                guard let strongSelf = self else { return }
                let optionMenu = UIAlertController(title: nil, message: "View Legal Information".localized(), preferredStyle: .actionSheet)
                
                let tcAction = UIAlertAction(title: "Terms & Conditions".localized(), style: .default) { _ in
                    let webView = SimpleFileViewController(load: "https://www.intervalworld.com/web/iicontent/ii/mobile-terms-getaways.html")
                    strongSelf.navigationController?.isNavigationBarHidden = false
                    strongSelf.navigationController?.pushViewController(webView, animated: true)
                    
                }
                let ppAction = UIAlertAction(title: "Privacy Policy".localized(), style: .default) { _ in
                    let webView = SimpleFileViewController(load: "https://www.intervalworld.com/web/cs?a=60&p=privacy-policy")
                    strongSelf.navigationController?.isNavigationBarHidden = false
                    strongSelf.navigationController?.pushViewController(webView, animated: true)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
                
                optionMenu.addAction(tcAction)
                optionMenu.addAction(ppAction)
                optionMenu.addAction(cancelAction)
                
                strongSelf.present(optionMenu, animated: true, completion: nil)
            }
            if isAgreed {
                cell.agreeLabel.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1)
                cell.agreeLabel.layer.borderColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1).cgColor
                cell.agreeLabel.text = Constant.MyClassConstants.verifying
                cell.agreeLabel.textColor = UIColor.white
            } else if showLoader {
                showLoader = false
                cell.activityIndicator.isHidden = false
                cell.agreeLabel.text = Constant.MyClassConstants.verifying
                cell.agreeLabel.backgroundColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2274509804, alpha: 1)
                cell.agreeLabel.textColor = UIColor.white
            } else if isAgreedToFees {
                if let image = UIImage(named: Constant.assetImageNames.swipeArrowOrgImage) {
                    cell.agreeButton?.imageName = image
                }
                cell.agreeLabel.backgroundColor = UIColor.white
                cell.agreeLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2274509804, alpha: 1).cgColor
                cell.agreeLabel.text = Constant.AlertMessages.agreePayMessage
                cell.agreeLabel.textColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2274509804, alpha: 1)
                cell.agreeButton?.imageName = #imageLiteral(resourceName: "SwipeArrow_ORG")
            } else {
                if let image = UIImage(named: Constant.assetImageNames.swipeArrowGryImage) {
                    cell.agreeButton?.imageName = image
                }
                cell.agreeLabel.text = Constant.AlertMessages.agreePayMessage
                cell.agreeLabel.backgroundColor = UIColor.white
                cell.agreeLabel.layer.borderColor = UIColor.lightGray.cgColor
                cell.agreeLabel.textColor = UIColor.lightGray
                cell.isUserInteractionEnabled = false
            }
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - Gesture Recognizer Delegate
extension CheckOutViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    @available(iOS 9.0, *)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
}

// MARK: - Web View Delegate
extension CheckOutViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        showHudAsync()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(.zero)
        self.hideHudAsync()
        checkoutOptionTBLview.beginUpdates()
        checkoutOptionTBLview.endUpdates()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.hideHudAsync()
    }
}

// MARK: - Text Field Delegate
extension CheckOutViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        emailTextToEnter = "\(textField.text ?? "")\(string)"
        
        if emailTextToEnter == Session.sharedSession.contact?.emailAddress {
            showUpdateEmail = false
            let indexPath = IndexPath(row: 0, section: 10)
            checkoutOptionTBLview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        
        return true
    }
}
