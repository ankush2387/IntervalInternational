//
//  CheckOutIPadViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 11/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD

class CheckOutIPadViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var checkoutTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var remainingResortHoldingTimeLabel: UILabel!
    var isPromotionApplied = false
    
    fileprivate var tappedButtonDictionary = [Int: Bool]()
    
    //Class variables
    var isPromotionsEnabled = true
    var isTripProtectionEnabled = false
    var isGuestCertificateEnabled = false
    var bookingCostRequiredRows = 1
    var promotionSelectedIndex = 0
    var isAgreed: Bool = false
    var eplusAdded = false
    var isAgreedToFees: Bool = false
    var cellWebView = UIWebView()
    var showUpdateEmail = false
    var updateEmailSwitchStauts = "off"
    var emailTextToEnter = ""
    var tripRequestInProcess = false
    var isHeightZero = false
    //FIXME(Frank) - what is this?
    var promotionsArray = ["20% OFF", "10% OFF", "No Thanks"]
    var showLoader = false
    var showInsurance = false
    var destinationPromotionSelected = false
    var recapPromotionsArray = [Promotion]()
    var recapSelectedPromotion: String?
    var recapFeesTotal: Float?
    var isDepositPromotionAvailable = false
    var totalFeesArray = NSMutableArray()
    var filterRelinquishments: ExchangeRelinquishment?
    var totalRowsInCost = 0
    var renewalCoreProduct: Renewal?
    var renewalNonCoreProduct: Renewal?
    var currencyCode: String = "USA"
    var countryCode: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
        remainingResortHoldingTimeLabel.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideHudAsync()
        
        self.emailTextToEnter = Session.sharedSession.contact?.emailAddress ?? ""
        self.checkoutTableView.reloadData()
        self.isGuestCertificateEnabled = Constant.MyClassConstants.exchangeFees?.guestCertificate != nil || Constant.MyClassConstants.rentalFees?.guestCertificate != nil
        
        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
            
            if let exchangeFees = Constant.MyClassConstants.exchangeFees, !exchangeFees.renewals.isEmpty {
                
                if let shopExchangeFee = exchangeFees.shopExchange, let selectedPromotion = shopExchangeFee.selectedOfferName {
                    self.recapSelectedPromotion = selectedPromotion
                    if selectedPromotion == "" {
                        Constant.MyClassConstants.isPromotionsEnabled = false
                        destinationPromotionSelected = false
                    } else {
                        Constant.MyClassConstants.isPromotionsEnabled = true
                        destinationPromotionSelected = true
                    }
                }
                
                for renewal in exchangeFees.renewals {
                    if renewal.isCoreProduct {
                        renewalCoreProduct = Renewal()
                        renewalCoreProduct?.id = renewal.id
                        renewalCoreProduct?.productCode = renewal.productCode
                    } else if !renewal.isCoreProduct {
                        renewalNonCoreProduct = Renewal()
                        renewalNonCoreProduct?.id = renewal.id
                        renewalNonCoreProduct?.productCode = renewal.productCode
                    }
                }
            }
            
        } else {
            
            if let rentalFees = Constant.MyClassConstants.rentalFees, !rentalFees.renewals.isEmpty {
                
                if let rentalFee = rentalFees.rental, let selectedPromotion = rentalFee.selectedOfferName {
                    self.recapSelectedPromotion = selectedPromotion
                    if selectedPromotion == "" {
                        Constant.MyClassConstants.isPromotionsEnabled = false
                        destinationPromotionSelected = false
                    } else {
                        Constant.MyClassConstants.isPromotionsEnabled = true
                        destinationPromotionSelected = true
                    }
                }
                
                for renewal in rentalFees.renewals {
                    if renewal.isCoreProduct {
                        renewalCoreProduct = Renewal()
                        renewalCoreProduct?.id = renewal.id
                        renewalCoreProduct?.productCode = renewal.productCode
                    } else if !renewal.isCoreProduct {
                        renewalNonCoreProduct = Renewal()
                        renewalNonCoreProduct?.id = renewal.id
                        renewalNonCoreProduct?.productCode = renewal.productCode
                    }
                }
            }
        }
        
        //FIXME(Frank): - what is this?
        //NotificationCenter.default.addObserver(self, selector: #selector(changeLabelStatus), name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPromotionsAvailable()
        checkSectionsForFees()

        // get country listCompletionBlock
        Helper.getCountry { [weak self] error in
            if let Error = error {
                self?.presentErrorAlert(UserFacingCommonError.handleError(Error))
            }
        }
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.vacationSearchPaymentInformation
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        if !Constant.MyClassConstants.hasAdditionalCharges {
            isAgreedToFees = true
        }
        
        if let currentProfile = Session.sharedSession.contact, let countryCodeValue = currentProfile.getCountryCode() {
            countryCode = countryCodeValue
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
            
            if let exchangeFees = Constant.MyClassConstants.exchangeFees {
                
                if let insuranceFee = exchangeFees.insurance, let insuranceOfferHTML = insuranceFee.insuranceOfferHTML {
                    showInsurance = true
                } else {
                    showInsurance = false
                }
                
                if let eplusFee = exchangeFees.eplus, let eplusSelected = eplusFee.selected, eplusSelected == true {
                    eplusAdded = true
                } else {
                    eplusAdded = false
                }
                
                guard let curCode = exchangeFees.currencyCode else { return }
                currencyCode = curCode
                
            } else {
                
                for advisement in (Constant.MyClassConstants.viewResponse.destination?.resort?.advisements)! {
                    
                    if advisement.title == Constant.MyClassConstants.additionalAdv {
                        Constant.MyClassConstants.additionalAdvisementsArray.append(advisement)
                    } else {
                        Constant.MyClassConstants.generalAdvisementsArray.append(advisement)
                    }
                }
                
                if let _: String? = Constant.MyClassConstants.rentalFees?.insurance?.insuranceOfferHTML! {
                    showInsurance = true
                } else {
                    showInsurance = false
                }
            
                guard let curCode = Constant.MyClassConstants.rentalFees?.currencyCode else { return }
                currencyCode = curCode
            }
            
        }
        
        //Register custom cell xib with tableview
        self.bookingTableView.register(UINib(nibName: Constant.customCellNibNames.totalCostCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.totalCostCell)
        self.bookingTableView.register(UINib(nibName: Constant.customCellNibNames.promotionsDiscountCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.promotionsDiscountCell)
        
        self.bookingTableView.register(UINib(nibName: Constant.customCellNibNames.exchangeOrProtectionCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell)
        self.title = Constant.ControllerTitles.checkOutControllerTitle
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(CheckOutIPadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        var resortCode = ""
        var creditCardsCount = 0
        
        if let count = Session.sharedSession.contact?.creditcards?.count {
            creditCardsCount = count
        }
        if let selectedResort = Constant.MyClassConstants.selectedAvailabilityResort {
            resortCode = selectedResort.code
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
    
    func checkPromotionsAvailable() {
        if Constant.MyClassConstants.filterRelinquishments.count > 0 {
            if let  _ = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.promotion {
                isDepositPromotionAvailable = true
            }
        }
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        showHudAsync()
        
        if Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            ExchangeProcessClient.backToWhoIsChecking(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, onSuccess: { _ in
                _ = self.navigationController?.popViewController(animated: true)
                self.hideHudAsync()
            }, onError: {[weak self] error in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
            
        } else {
            
            RentalProcessClient.backToWhoIsChecking(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess: { _ in
                
                self.hideHudAsync()
                _ = self.navigationController?.popViewController(animated: true)
                
            }, onError: {(_) in
                
                self.hideHudAsync()
                self.presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.operationFailedMessage)
            })
        }
    }
    override func viewDidLayoutSubviews() {
        
    }
    
    //FIXME(Frank) - what is this?
    func changeLabelStatus(notification: NSNotification) {
        
        guard let imageSlider = notification.object as? UIImageView else { return }
        if Constant.MyClassConstants.indexSlideButton == 8 {
            
            let confirmationDelivery = ConfirmationDelivery()
            confirmationDelivery.emailAddress = self.emailTextToEnter
            confirmationDelivery.updateProfile = false
            
            let jsStringAccept = Constant.MyClassConstants.webViewGetElementById
            let jsStringReject = Constant.MyClassConstants.webViewGetElementById1
            
            let strAccept = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringAccept)
            let strReject = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringReject)
            
            if (isAgreedToFees || !Constant.MyClassConstants.hasAdditionalCharges) && (strAccept == Constant.MyClassConstants.status || strReject == Constant.MyClassConstants.status || !showInsurance) && Constant.MyClassConstants.selectedCreditCard != nil && (isPromotionApplied || Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty) {
                
                let continueToPayRequest = RentalProcessRecapContinueToPayRequest()
                continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard
                continueToPayRequest.confirmationDelivery = confirmationDelivery
                
                showHudAsync()
                imageSlider.isHidden = true
                showLoader = true
                self.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with: .automatic)
                if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                    
                    let continueToPayRequest = ExchangeProcessContinueToPayRequest()
                    continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard
                    continueToPayRequest.confirmationDelivery = confirmationDelivery
                    continueToPayRequest.acceptTermsAndConditions = true
                    continueToPayRequest.acknowledgeAndAgreeResortFees = true
                    
                    ExchangeProcessClient.continueToPay(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { response in
                        
                        Constant.MyClassConstants.exchangeBookingLastStartedProcess = nil
                        Constant.MyClassConstants.exchangeContinueToPayResponse = response
                        
                        let selectedCard = Constant.MyClassConstants.selectedCreditCard
                                                
                        self.isAgreed = true
                        self.hideHudAsync()
                        self.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with: .automatic)
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
                        
                    }, onError: { [weak self] error in
                        self?.hideHudAsync()
                        imageSlider.isHidden = false
                        self?.isAgreed = false
                        self?.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with: .automatic)
                        self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    })
                    
                } else {
                    
                    let continueToPayRequest = RentalProcessRecapContinueToPayRequest()
                    continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard
                    continueToPayRequest.confirmationDelivery = confirmationDelivery
                    continueToPayRequest.acceptTermsAndConditions = true
                    continueToPayRequest.acknowledgeAndAgreeResortFees = true
                    
                    RentalProcessClient.continueToPay(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { response in
                        Constant.MyClassConstants.getawayBookingLastStartedProcess = nil
                        Constant.MyClassConstants.continueToPayResponse = response
                        let selectedCard = Constant.MyClassConstants.selectedCreditCard
                        Constant.MyClassConstants.selectedCreditCard = nil
                        self.isAgreed = true
                        self.hideHudAsync()
                        self.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with: .automatic)
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
                        
                    }, onError: { [weak self] error in
                        self?.hideHudAsync()
                        imageSlider.isHidden = false
                        self?.isAgreed = false
                        self?.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with: .automatic)
                        self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    })
                }
                
            } else if !isAgreedToFees && Constant.MyClassConstants.hasAdditionalCharges {
                let indexPath = NSIndexPath(row: 0, section: 7)
                checkoutTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.feesAlertMessage)
            } else if strReject == Constant.MyClassConstants.isFalse && strAccept == Constant.MyClassConstants.isFalse {
                let indexPath = NSIndexPath(row: 0, section: 4)
                checkoutTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.insuranceSelectionMessage)
            } else if !isPromotionApplied && !Constant.MyClassConstants.recapViewPromotionCodeArray.isEmpty {
                imageSlider.isHidden = false
                checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                self.presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.promotionsMessage)
            } else {
                let indexPath = NSIndexPath(row: 0, section: 6)
                checkoutTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = true
                presentAlert(with: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.paymentSelectionMessage)
            }
        } else {
            isAgreedToFees = true
            imageSlider.isHidden = true
            checkoutTableView.reloadSections([7, 8], with:.automatic)
        }
        
    }
    
    //***** Function to update holding time for resort. *****//
    func updateResortHoldingTime() {
        
        if Constant.holdingTime != 0 {
            remainingResortHoldingTimeLabel.text = "We are holding this unit for \(Constant.holdingTime) minutes".localized()
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
    
    //***** Function called when radio button is selected in Add Trip Protection. *****//
    func handleTap(_ sender: UITapGestureRecognizer) {
        
        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
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
            self.bookingTableView.reloadData()
        }
        
    }
    
    //***** Function for adding and removing trip protection *****//
    func addTripProtection(shouldAddTripProtection: Bool) {
        
        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
            Constant.MyClassConstants.exchangeFees?.insurance?.selected = shouldAddTripProtection
            let exchangeRecalculateRequest = ExchangeProcessRecalculateRequest()
            exchangeRecalculateRequest.fees = Constant.MyClassConstants.exchangeFees
            showHudAsync()
            ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: exchangeRecalculateRequest, onSuccess: {
                response in
                
                self.tripRequestInProcess = false
                Constant.MyClassConstants.exchangeContinueToCheckoutResponse = response
                
                Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                if let taxBreakdown = response.view?.fees?.shopExchange?.inventoryPrice?.taxBreakdown {
                    Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
                }
                
                if let totalFees = response.view?.fees?.total {
                    Constant.MyClassConstants.exchangeFees?.total = totalFees
                }
                self.bookingTableView.reloadSections(IndexSet(integer: 0), with:.automatic)
                self.bookingTableView.reloadData()
                self.hideHudAsync()
                
            }, onError: { [weak self] error in
                Constant.MyClassConstants.exchangeFees?.insurance?.selected = !shouldAddTripProtection
                self?.tripRequestInProcess = false
                self?.isTripProtectionEnabled = false
                self?.bookingTableView.reloadData()
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
        } else {
            Constant.MyClassConstants.rentalFees?.insurance?.selected = shouldAddTripProtection
            let rentalRecalculateRequest = RentalProcessRecapRecalculateRequest()
            rentalRecalculateRequest.fees = Constant.MyClassConstants.rentalFees
            
            showHudAsync()
            RentalProcessClient.addTripProtection(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: rentalRecalculateRequest, onSuccess: { response in
                self.tripRequestInProcess = false
                Constant.MyClassConstants.continueToCheckoutResponse = response
                
                Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                if let taxBreakdown = response.view?.fees?.rental?.rentalPrice?.taxBreakdown {
                    Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
                }
                
                if let totalFees = response.view?.fees?.total {
                    Constant.MyClassConstants.rentalFees?.total = totalFees
                }
                self.bookingTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.hideHudAsync()
            }, onError: { error in
                self.tripRequestInProcess = false
                self.hideHudAsync()
            })
        }
    }
    
    //***** Function called when detail button is pressed. ******//
    func resortDetailsClicked(_ sender: IUIKButton) {
        if sender.tag == 0 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
        } else {
            if let clubPointResortCode = filterRelinquishments?.clubPoints?.resort?.resortCode {
                getRelinquishmentDetails(resortCode: clubPointResortCode)
            } else if let openWeekResortCode = filterRelinquishments?.openWeek?.resort?.resortCode {
                getRelinquishmentDetails(resortCode: openWeekResortCode)
            } else if let depositResortCode = filterRelinquishments?.deposit?.resort?.resortCode {
                getRelinquishmentDetails(resortCode: depositResortCode)
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
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
        let exchangeRecalculateRequest = ExchangeProcessRecalculateRequest()
        exchangeRecalculateRequest.fees = Constant.MyClassConstants.exchangeFees
        exchangeRecalculateRequest.fees?.eplus?.selected = sender.checked
        showHudAsync()
        ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: exchangeRecalculateRequest, onSuccess: { recapResponse in
            
            self.eplusAdded = sender.checked
            if let fees = recapResponse.view?.fees {
                Constant.MyClassConstants.exchangeFees = fees
            }
            
            Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
            if let taxBreakdown = recapResponse.view?.fees?.shopExchange?.inventoryPrice?.taxBreakdown {
                Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
            }
            
            self.checkSectionsForFees()
            self.bookingTableView.reloadData()
            
            self.hideHudAsync()
        }, onError: { [weak self] error in
            self?.eplusAdded = !sender.checked
            Constant.MyClassConstants.exchangeFees?.eplus?.selected = sender.checked
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            self?.checkSectionsForFees()
            self?.bookingTableView.reloadData()
            self?.checkoutTableView.reloadData()
            
        })
        /*}else{
         
         }*/
        
    }
    
    // MARK: - Check Fees applied for user
    func checkSectionsForFees () {
        totalFeesArray.removeAllObjects()
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.searchBothExchange {
            
            totalFeesArray.add(Constant.MyClassConstants.exchangeFeeTitle)
            
            if Constant.MyClassConstants.enableTaxes {
                totalFeesArray.add(Constant.MyClassConstants.taxesTitle)
            }
            
            if let ePlusSelect = Constant.MyClassConstants.exchangeFees?.eplus?.selected {
                if ePlusSelect {
                    totalFeesArray.add(Constant.MyClassConstants.eplus)
                }
            }
            
            if Constant.MyClassConstants.exchangeFees?.unitSizeUpgrade != nil {
                totalFeesArray.add(Constant.MyClassConstants.upgradeCost)
            }
            
            if !(Constant.MyClassConstants.exchangeFees?.renewals.isEmpty)! {
                totalFeesArray.add(Constant.MyClassConstants.renewals)
            }
            
        } else {
            
            totalFeesArray.add(Constant.MyClassConstants.getawayFee)
            
            if Constant.MyClassConstants.enableTaxes {
                totalFeesArray.add(Constant.MyClassConstants.taxesTitle)
            }
            
            if !(Constant.MyClassConstants.rentalFees?.renewals.isEmpty)! {
                totalFeesArray.add(Constant.MyClassConstants.renewals)
            }
        }
        intervalPrint(totalFeesArray)
    }
    
    //***** Function to calculate dynamic height. ******//
    func heightForView(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //***** Function to calculate dynamic width. *****//
    func widthForView(_ text: String, font: UIFont, height: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.width
    }
    
    //***** Function called when cross button is clicked in email text field. *****//
    func inputClearPressed(_ sender: UIButton) {
        self.emailTextToEnter = ""
        self.showUpdateEmail = true
        let indexPath = NSIndexPath(row: 0, section: 6)
        self.checkoutTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //***** Function used to expand and contract sections.*****//
    func toggleButtonIsTapped(_ sender: UIButton) {
        
        if let tag = tappedButtonDictionary[sender.tag] {
            if tag {
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            } else {
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
        } else {
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.checkoutTableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
        self.checkoutTableView.reloadData()
    }
    
    //***** Function called switch state is 'On' so as to update user's email. *****//
    func udpateEmailSwitchPressed(_ sender: UISwitch) {
        
        let validEmail = isValidEmail(testStr: self.emailTextToEnter)
        if validEmail {
            
            if sender.isOn {
                self.updateEmailSwitchStauts = Constant.MyClassConstants.isOn
            } else {
                self.updateEmailSwitchStauts = Constant.MyClassConstants.isOff
            }
        } else {
            sender.setOn(false, animated: true)
            self.presentAlert(with: Constant.buttonTitles.updateSwitchTitle, message: Constant.AlertErrorMessages.emailAlertMessage)
        }
    }
    
    //***** Function to check if the email entered by user is an valid email address. *****//
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = Constant.MyClassConstants.emailRegex
        
        let emailTest = NSPredicate(format: Constant.MyClassConstants.selfMatches, emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPromotions(_ index: Int) {
        
        self.promotionSelectedIndex = index
        Constant.MyClassConstants.isPromotionsEnabled = true
        self.bookingCostRequiredRows = 1
        bookingTableView.reloadData()
        
        let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let promotionsNav = storyboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.depositPromotionNav) as? UINavigationController else { return }
        guard let promotionsVC = promotionsNav.viewControllers.first as? PromotionsViewController else { return }
        promotionsVC.promotionsArray = Constant.MyClassConstants.recapViewPromotionCodeArray
        promotionsVC.completionHandler = { selected in
            self.showHudAsync()
            //Creating Request to recap with Promotion
            let processResort = RentalProcess()
            processResort.currentStep = ProcessStep.Recap
            processResort.processId = Constant.MyClassConstants.processStartResponse.processId
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                let processResort = ExchangeProcess()
                processResort.currentStep = ProcessStep.Recap
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                
                let processRequest = ExchangeProcessRecalculateRequest()
                processRequest.fees = Constant.MyClassConstants.exchangeFees
                
                ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                    
                    Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                    if let taxBreakdown = response.view?.fees?.shopExchange?.inventoryPrice?.taxBreakdown {
                        Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
                    }
                    
                    if let promotions = response.view?.fees?.shopExchange?.promotions {
                        self.recapPromotionsArray = promotions
                    }
                    
                    if let selectedPromotion = response.view?.fees?.shopExchange?.selectedOfferName {
                        self.recapSelectedPromotion = selectedPromotion
                    }
                    
                    if let total = response.view?.fees?.total {
                        Constant.MyClassConstants.exchangeFees?.total = total
                        self.recapFeesTotal = total
                    }
                    
                    self.destinationPromotionSelected = true
                    self.checkoutTableView.reloadData()
                    self.bookingTableView.reloadData()
                    self.hideHudAsync()
                    
                }, onError: { (_) in
                    self.hideHudAsync()
                })
            } else {
                
                let rental = Rental()
                if let offerName = Constant.MyClassConstants.rentalFees?.rental?.selectedOfferName {
                    rental.selectedOfferName = offerName
                }
                
                let fees = RentalFees()
                fees.rental = rental
                
                let processRequest = RentalProcessRecapRecalculateRequest()
                processRequest.fees = fees
                
                RentalProcessClient.addCartPromotion(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                    
                    
                    Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                    if let taxBreakdown = response.view?.fees?.rental?.rentalPrice?.taxBreakdown {
                        Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
                    }
                    
                    if let promotions = response.view?.fees?.rental?.promotions {
                        self.recapPromotionsArray = promotions
                    }
                    
                    if let selectedPromotion = response.view?.fees?.rental?.selectedOfferName {
                        self.recapSelectedPromotion = selectedPromotion
                    }
                    
                    if let total = response.view?.fees?.total {
                        self.recapFeesTotal = total
                    }
                    self.destinationPromotionSelected = true
                    self.checkoutTableView.reloadData()
                    self.bookingTableView.reloadData()
                    self.hideHudAsync()
                    
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
            }
            
        }
        self.present(promotionsNav, animated: true, completion: nil)
    }
    
    //FIXME(Frank): Deprecated
    func checkBoxCheckedAtIndex(_ sender: IUIKCheckbox) {
        
        self.promotionSelectedIndex = sender.tag
        Constant.MyClassConstants.isPromotionsEnabled = true
        self.bookingCostRequiredRows = 1
        bookingTableView.reloadData()
        
        let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let promotionsNav = storyboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.depositPromotionNav) as? UINavigationController else { return }
        guard let promotionsVC = promotionsNav.viewControllers.first as? PromotionsViewController else { return }
        promotionsVC.promotionsArray = Constant.MyClassConstants.recapViewPromotionCodeArray
        promotionsVC.completionHandler = { selected in
            self.showHudAsync()
            //Creating Request to recap with Promotion
            let processResort = RentalProcess()
            processResort.currentStep = ProcessStep.Recap
            processResort.processId = Constant.MyClassConstants.processStartResponse.processId
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                let processResort = ExchangeProcess()
                processResort.currentStep = ProcessStep.Recap
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                
                let processRequest = ExchangeProcessRecalculateRequest()
                processRequest.fees = Constant.MyClassConstants.exchangeFees
                
                ExchangeProcessClient.recalculateFees(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                    
                    Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                    if let taxBreakdown = response.view?.fees?.shopExchange?.inventoryPrice?.taxBreakdown {
                        Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
                    }
                    
                    if let promotions = response.view?.fees?.shopExchange?.promotions {
                        self.recapPromotionsArray = promotions
                    }
                    
                    if let selectedPromotion = response.view?.fees?.shopExchange?.selectedOfferName {
                        self.recapSelectedPromotion = selectedPromotion
                    }
                    
                    if let total = response.view?.fees?.total {
                        Constant.MyClassConstants.exchangeFees?.total = total
                        self.recapFeesTotal = total
                    }
                    
                    self.destinationPromotionSelected = true
                    self.checkoutTableView.reloadData()
                    self.bookingTableView.reloadData()
                    self.hideHudAsync()
                    
                }, onError: { (_) in
                    self.hideHudAsync()
                })
            } else {
                
                let rental = Rental()
                if let offerName = Constant.MyClassConstants.rentalFees?.rental?.selectedOfferName {
                    rental.selectedOfferName = offerName
                }
                
                let fees = RentalFees()
                fees.rental = rental
                
                let processRequest = RentalProcessRecapRecalculateRequest()
                processRequest.fees = fees
                
                RentalProcessClient.addCartPromotion(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                    
                    
                    Constant.MyClassConstants.inventoryPriceTaxBreakdown = nil
                    if let taxBreakdown = response.view?.fees?.rental?.rentalPrice?.taxBreakdown {
                        Constant.MyClassConstants.inventoryPriceTaxBreakdown = taxBreakdown
                    }
                    
                    if let promotions = response.view?.fees?.rental?.promotions {
                        self.recapPromotionsArray = promotions
                    }
                    
                    if let selectedPromotion = response.view?.fees?.rental?.selectedOfferName {
                        self.recapSelectedPromotion = selectedPromotion
                    }
                    
                    if let total = response.view?.fees?.total {
                        self.recapFeesTotal = total
                    }
                    self.destinationPromotionSelected = true
                    self.checkoutTableView.reloadData()
                    self.bookingTableView.reloadData()
                    self.hideHudAsync()
                    
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
            }
            
        }
        self.present(promotionsNav, animated: true, completion: nil)
    }

}

// MARK: - Table View Delegate

extension CheckOutIPadViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 5 && tableView.tag == 3 {
            self.performSegue(withIdentifier: Constant.segueIdentifiers.selectPaymentMethodSegue, sender: nil)
        }
    }
}

// MARK: - Table View Datasource
extension CheckOutIPadViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 2:
            return 5
        case 3:
            return 9
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView.tag {
        case 2:
            switch section {
            case 1:
                totalRowsInCost = totalFeesArray.count
                return totalRowsInCost
                
            case 2:
                if self.isTripProtectionEnabled && self.isGuestCertificateEnabled {
                    return 2
                    
                } else if !self.isTripProtectionEnabled && !self.isGuestCertificateEnabled {
                    return 0
                } else {
                    return 1
                }
            case 3:
                if destinationPromotionSelected {
                    return 1
                } else {
                    return 0
                }
                
            default:
                return 1
            }
        case 3:
            switch section {
            case 0:
                if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                    return 2
                } else {
                    return 1
                }
            case 1:
                var advisementCount: Int = 0
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
            case 2:
                
                var numberOfCells = 0
                if isDepositPromotionAvailable {
                    numberOfCells += 1
                }
                
                if Constant.MyClassConstants.recapViewPromotionCodeArray.count > 0 {
                    numberOfCells += 1
                }
                return numberOfCells
            case 3:
                if eplusAdded {
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
                
            default:
                return 1
            }
        default:
            return 0
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        isHeightZero = false
        switch tableView.tag {
        case 2:
            switch indexPath.section {
            case 2 :
                if !self.isTripProtectionEnabled && !self.isGuestCertificateEnabled {
                    isHeightZero = true
                    return 0
                } else {
                    return UITableViewAutomaticDimension
                }
            case 3 :
                if !self.isPromotionsEnabled {
                    isHeightZero = true
                    return 0
                } else if self.isPromotionsEnabled && destinationPromotionSelected {
                    return 60
                } else {
                    return 80
                }
            case 4:
                return 60
                
            default :
                 return 80
            }
        case 3:
            switch indexPath.section {
            case 0:
                return 80
            case 1:
                if indexPath.row == Constant.MyClassConstants.generalAdvisementsArray.count {
                    return 30
                } else if indexPath.row != (Constant.MyClassConstants.generalAdvisementsArray.count) + 1 {
                    guard let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0) else { return 0 }
                    var height: CGFloat
                    if Constant.RunningDevice.deviceIdiom == .pad {
                        height = heightForView(Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description.joined(separator: "") ?? "", font: font, width: (view.frame.size.width / 2) - 10)
                        return height + 50
                    } else {
                        height = heightForView(Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description.joined(separator: "") ?? "", font: font, width: view.frame.size.width - 10)
                        return height + 50
                    }
                } else {
                    guard let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0) else { return 50 }
                    guard let description = Constant.MyClassConstants.additionalAdvisementsArray.last?.description else { return 50 }
                    let height = heightForView(description.joined(separator: ""), font: font, width: view.frame.size.width - 20)
                    return height + 50
                }
            case 2:
                if self.isPromotionsEnabled {
                    return 80
                } else {
                    return 0
                }
            case 3:
                if !Constant.MyClassConstants.isFromExchange {
                    return 0
                } else {
                    if Constant.MyClassConstants.exchangeFees?.eplus == nil {
                        return 0
                    } else {
                        return 130
                    }
                }
            case 4:
                if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                    
                    if let exchangeFees = Constant.MyClassConstants.exchangeFees {
                        guard let myString = exchangeFees.insurance?.insuranceOfferHTML, !myString.isEmpty else {
                            showInsurance = false
                            return 0
                        }
                        showInsurance = true
                        return 420
                    } else {
                        return 0
                    }
                } else {
                    guard let myString = Constant.MyClassConstants.rentalFees?.insurance?.insuranceOfferHTML, !myString.isEmpty else {
                        showInsurance = false
                        return 0
                    }
                    showInsurance = true
                    return 420
                    
                }
                
            case 5:
                return 50
            case 6:
                if self.showUpdateEmail {
                    return 120
                } else {
                    return 150
                }
            case 7:
                if Constant.MyClassConstants.hasAdditionalCharges {
                    return 150
                } else {
                    return 0
                }
            case 8:
                return 150
            default:
                return 180
            }
        default:
            return 80
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 2 {
            switch indexPath.section {
                
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.bookingCell, for: indexPath) as? ViewDetailsTBLcell else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
            case 1:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as? ExchangeOrProtectionCell else { return UITableViewCell() }
                
                if !isHeightZero {
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    
                    switch totalFeesArray[indexPath.row] as? String ?? "" {
                        
                    case Constant.MyClassConstants.exchangeFeeTitle:
                        
                        //FIXME(Frank): - all UIViewController for iPad should be removed
                        if let exchangeFees = Constant.MyClassConstants.exchangeFees?.shopExchange?.inventoryPrice?.price {
                            cell.setTotalPrice(with: currencyCode, and: exchangeFees, and: nil)
                        }
                        cell.priceLabel.text = Constant.MyClassConstants.exchangeFeeTitle
                        
                    case Constant.MyClassConstants.getawayFee:
                        
                        if let rentalPrice = Constant.MyClassConstants.rentalFees?.rental?.rentalPrice?.price {
                            cell.setTotalPrice(with: currencyCode, and: rentalPrice, and: nil)
                        }
                        cell.priceLabel.text = Constant.MyClassConstants.getawayFee
                        
                    case Constant.MyClassConstants.eplus:
                        
                        if let ePlusPrice = Constant.MyClassConstants.exchangeFees?.eplus?.price {
                            cell.setTotalPrice(with: currencyCode, and: ePlusPrice, and: nil)
                        }
                        cell.priceLabel.text = Constant.MyClassConstants.eplus
                        
                    case Constant.MyClassConstants.taxesTitle:
                        var tax: Float = 0.0
                        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                            if let taxAmount = Constant.MyClassConstants.exchangeContinueToCheckoutResponse.view?.fees?.shopExchange?.inventoryPrice?.tax {
                                tax = taxAmount
                            }
                        } else {
                            if let taxAmount = Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.rental?.rentalPrice?.tax {
                                tax = taxAmount
                            }
                        }
        
                        let cellTapped: CallBack = { [unowned self] in
                            if let taxBreakdown = Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.rental?.rentalPrice?.taxBreakdown {
                                
                                let dataSet = taxBreakdown.flatMap { taxBreakdownInstance -> (String, Float)? in
                                    if taxBreakdownInstance.description != nil {
                                        return (taxBreakdownInstance.description.unwrappedString, taxBreakdownInstance.amount)
                                    }
                                    
                                    return nil
                                }
                                
                                let currencyCodeOfFee = Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.currencyCode ?? ""
                                let currencyDescription = CurrencyHelper().getCurrency(currencyCode: currencyCodeOfFee).description
                                if currencyDescription.isEmpty {
                                    return self.presentErrorAlert(UserFacingCommonError.generic)
                                }
                                let viewModel = ChargeSummaryViewModel(charge: dataSet,
                                                                       headerTitle: "Detailed Tax Information".localized(),
                                                                       descriptionTitle: "Tax Description".localized(),
                                                                       totalTitle: "Total Tax Amount".localized(),
                                                                       currencyCode: currencyDescription.localized(),
                                                                       countryCode: nil)
                     
                                let chargeSummaryViewController = ChargeSummaryViewController(viewModel: viewModel)
                                chargeSummaryViewController.doneButtonPressed = { chargeSummaryViewController.dismiss(animated: true) }
                                self.navigationController?.present(chargeSummaryViewController, animated: true)
                            }
                        }
                        
                        cell.setTotalPrice(with: currencyCode, and: tax, and: nil)
                        cell.priceLabel.text = Constant.MyClassConstants.taxesTitle
                        cell.setCell(callBack: cellTapped, and: tax)
                        
                    case Constant.MyClassConstants.upgradeCost:
                        if let upgradeCost = Constant.MyClassConstants.exchangeFees?.unitSizeUpgrade?.price {
                            cell.setTotalPrice(with: currencyCode, and: upgradeCost, and: nil)
                        }
                        cell.priceLabel.text = Constant.MyClassConstants.upgradeCost
                        
                    default:
                        
                        cell.priceLabel.numberOfLines = 0
                        
                        if let coreProduct = renewalCoreProduct, let nonCoreProduct = renewalNonCoreProduct {
                            // TODO: Combo or Both Products by individuals
                            let comboPrice = coreProduct.price + nonCoreProduct.price
                            cell.setTotalPrice(with: currencyCode, and: comboPrice, and: countryCode)
                            
                            if let nonCoreProductDisplayName = nonCoreProduct.displayName {
                                cell.priceLabel.text = "\(nonCoreProductDisplayName) Package".localized()
                            } else {
                                cell.priceLabel.text = "Combo Package".localized()
                            }
                            
                        } else if let coreProduct = renewalCoreProduct {
                            // TODO: Core Product (BSC|CIG)
                            cell.setTotalPrice(with: currencyCode, and: coreProduct.price, and: countryCode)
                            
                            if let coreProductDisplayName = coreProduct.displayName {
                                if coreProductDisplayName.caseInsensitiveCompare("INTERVAL") == ComparisonResult.orderedSame {
                                    cell.priceLabel.text = "\(coreProductDisplayName) Membership".capitalized.localized()
                                } else {
                                    cell.priceLabel.text = "\(coreProductDisplayName)".localized()
                                }
                            }
                            
                        } else if let nonCoreProduct = renewalNonCoreProduct {
                            // TODO: Non-Core Product (GLD|PLT)
                            cell.setTotalPrice(with: currencyCode, and: nonCoreProduct.price, and: countryCode)
                            
                            if let nonCoreProductDisplayName = nonCoreProduct.displayName {
                                cell.priceLabel.text = "\(nonCoreProductDisplayName)".localized()
                            }
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

            case 2:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as? ExchangeOrProtectionCell else { return UITableViewCell() }
                
                if !isHeightZero {
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    if indexPath.row == 0 && self.isTripProtectionEnabled {
                        cell.priceLabel.text = Constant.MyClassConstants.insurance
                        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                            if let insurancePrice = Constant.MyClassConstants.exchangeFees?.insurance?.price {
                                cell.setTotalPrice(with: currencyCode, and: insurancePrice, and: nil)
                            }
                        } else {
                            if let insurancePrice = Constant.MyClassConstants.rentalFees?.insurance?.price {
                                cell.setTotalPrice(with: currencyCode, and: insurancePrice, and: nil)
                            }
                        }
                    } else {
                        cell.priceLabel.text = Constant.MyClassConstants.guestCertificateTitle
                        if let guestPrice = Constant.MyClassConstants.rentalFees?.guestCertificate?.guestCertificatePrice?.price {
                            cell.setTotalPrice(with: currencyCode, and: guestPrice, and: nil)
                        }
                    }
                } else {
                    isHeightZero = false
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = true
                    }
                }
                
                return cell
                
            case 3:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.promotionsDiscountCell, for: indexPath) as? PromotionsDiscountCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                if !isHeightZero {
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    cell.discountLabel.text = recapSelectedPromotion
                    for promotion in Constant.MyClassConstants.recapPromotionsArray where promotion.offerName == recapSelectedPromotion {
                        cell.setPromotionPrice(with: currencyCode, and: promotion.amount, and: nil)
                    }
                } else {
                    isHeightZero = false
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = true
                    }
                }
                return cell
                
            case 4:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.totalCostCell, for: indexPath) as? TotalCostCell else { return UITableViewCell() }
                if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                    
                    cell.setTotalPrice(with: currencyCode, and: (Constant.MyClassConstants.exchangeFees?.total)!, and: nil)
                    if let total = recapFeesTotal {
                        cell.setTotalPrice(with: currencyCode, and: total, and: nil)
                    }
                } else {
                    cell.setTotalPrice(with: currencyCode, and: (Constant.MyClassConstants.rentalFees?.total)!, and: nil)
                    if let total = recapFeesTotal {
                        cell.setTotalPrice(with: currencyCode, and: total, and: nil)
                    }
                }
                
                return cell
            case 5:
               guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.termsConditionsCell, for: indexPath) as? ViewDetailsTBLcell else { return UITableViewCell() }
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.bookingCell, for: indexPath) as? ViewDetailsTBLcell else { return UITableViewCell() }
                return cell
                
            }
            
        } else {
            switch indexPath.section {
                
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.headerCell, for: indexPath) as? ViewDetailsTBLcell else { return  UITableViewCell() }
                cell.resortDetailsButton.addTarget(self, action: #selector(self.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortDetailsButton.tag = indexPath.row
                if indexPath.row == 0 {
                    cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.resortImage)
                    if let selectedResort = Constant.MyClassConstants.selectedAvailabilityResort {
                        cell.resortName?.text = selectedResort.name
                    } else {
                        cell.resortName?.text = ""
                    }
                } else {
                    
                    if let openWeek = filterRelinquishments?.openWeek {
                        cell.resortName?.text = openWeek.resort?.resortName
                        cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                        cell.resortDetailsButton.isHidden = false
                        cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                    } else if let deposits = filterRelinquishments?.deposit {
                        cell.resortName?.text = deposits.resort?.resortName
                        cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                        cell.resortDetailsButton.isHidden = false
                        cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                    } else if let selectedBucket = Constant.MyClassConstants.selectedAvailabilityInventoryBucket, let pointsCost = selectedBucket.exchangePointsCost {
                        
                        switch Constant.exchangePointType {
                        case ExchangePointType.CIGPOINTS:
                            cell.resortDetailsButton.isHidden = true
                            cell.lblHeading.text = ExchangePointType.CIGPOINTS.name.localized()
                            cell.resortName?.text = "\(pointsCost)".localized()
                        case ExchangePointType.CLUBPOINTS:
                            cell.resortDetailsButton.isHidden = true
                            cell.lblHeading.text = ExchangePointType.CLUBPOINTS.name.localized()
                            cell.resortName?.text = "\(pointsCost)".localized()
                        case .UNKNOWN:
                            break
                        }
                    }
                    cell.resortImageView?.image = #imageLiteral(resourceName: "EXG_CO")
                    
                }
                
                return cell
            case 1:
                
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
                        cell.advisementTextLabel.text = Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description.joined(separator: "")
                    } else {
                        cell.advisementType.text = ""
                        cell.advisementTextLabel.text = Constant.MyClassConstants.additionalAdvisementsArray.last?.description.joined(separator: "")
                    }
                    cell.advisementType.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
                    cell.advisementTextLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
                    cell.advisementTextLabel.numberOfLines = 0
                    cell.advisementTextLabel.sizeToFit()
                    cell.selectionStyle = .none
                    return cell
                    
                }
                
            case 2:
                if isDepositPromotionAvailable && indexPath.row == 0 {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutPromotionCell", for: indexPath) as? CheckoutPromotionCell else { return UITableViewCell() }
                    cell.setupDepositPromotion()
                    cell.promotionSelectionCheckBox.tag = indexPath.row
                    
                    cell.selectionStyle = .none
                    return cell
                    
                } else {
                    
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cellIdentifiers.checkoutPromotionCell, for: indexPath) as? CheckoutPromotionCell else { return UITableViewCell() }
                    
                    let cellTapped: CallBack = { [weak self] in
                        self?.showPromotions(indexPath.row)
                    }
                    
                    cell.setupCell(selectedPromotion: destinationPromotionSelected, callBack: cellTapped)
                    //cell.promotionSelectionCheckBox.tag = indexPath.row
 
                    if cell.promotionSelectionCheckBox.isHidden {
                        cell.forwardArrowButton.addTarget(self, action: #selector(CheckOutIPadViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
                    } else {
                        isPromotionApplied = true
                        //cell.promotionSelectionCheckBox.addTarget(self, action: #selector(CheckOutIPadViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
                    }
                    cell.selectionStyle = .none
                    return cell
                }
                
            case 3:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeOptionsCell, for: indexPath) as? ExchangeOptionsCell else { return UITableViewCell() }
                cell.setupCell(selectedEplus: true)
                cell.selectionStyle = .none
                return cell
                
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.tripProtectionCell, for: indexPath)
                var containsWebView = false
                for subviews in cell.subviews {
                    if subviews.isKind(of: UIWebView.self) {
                        containsWebView = true
                    }
                    
                }
                if !containsWebView {
                    cellWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 420))
                    cellWebView.scrollView.isScrollEnabled = false
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                    tapRecognizer.numberOfTapsRequired = 1
                    tapRecognizer.delegate = self
                    cellWebView.addGestureRecognizer(tapRecognizer)
                    if showInsurance, let exchangeFees = Constant.MyClassConstants.exchangeFees {
                        if let str = exchangeFees.insurance?.insuranceOfferHTML {
                            cellWebView.loadHTMLString(str, baseURL: nil)
                        }
                    } else {
                        if let str = Constant.MyClassConstants.rentalFees?.insurance?.insuranceOfferHTML {
                            cellWebView.loadHTMLString(str, baseURL: nil)
                        }
                    }
                    cellWebView.delegate = self
                    cellWebView.backgroundColor = UIColor.gray
                    cell.addSubview(cellWebView)
                    
                }
                return cell
                
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.selectPaymentMethodCell, for: indexPath)
                
                for subviews in cell.subviews {
                    
                    subviews.removeFromSuperview()
                }
                cell.backgroundColor = UIColor.white
                let forwardArrowImageView = UIImageView(frame: CGRect(x: cell.contentView.frame.width - 60, y: 5, width: 40, height: 40))
                forwardArrowImageView.image = UIImage(named: Constant.assetImageNames.forwardArrowIcon)
                
                let paymentMethodLabel = UILabel(frame: CGRect(x: 20, y: 5, width: cell.contentView.frame.width - 90, height: 20))
                paymentMethodLabel.text = Constant.MyClassConstants.paymentMethodTitle
                paymentMethodLabel.textColor = IUIKColorPalette.primary1.color
                
                let selectPamentMethodLabel = UILabel(frame: CGRect(x: 20, y: 25, width: cell.contentView.frame.width - 90, height: 20))
                if let selectedCreditCard = Constant.MyClassConstants.selectedCreditCard {
                    let creditcard = selectedCreditCard
                    if let cardNumber = creditcard.cardNumber, let code = creditcard.typeCode {
                        let last4 = cardNumber.substring(from: (cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
                        let cardType = Helper.cardTypeCodeMapping(cardType: code)
                        selectPamentMethodLabel.text = "\(cardType) \(Constant.MyClassConstants.endingIn) \(last4)"
                    }
                } else {
                    selectPamentMethodLabel.text = Constant.MyClassConstants.paymentInfo
                }
                selectPamentMethodLabel.textColor = UIColor.darkGray
                cell.addSubview(forwardArrowImageView)
                cell.addSubview(paymentMethodLabel)
                cell.addSubview(selectPamentMethodLabel)
                cell.selectionStyle = .none
                return cell
                
            case 6:
                
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
                return cell
                
            case 7:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreeToFeesCell, for: indexPath) as? SlideTableViewCell else { return UITableViewCell() }
                //cell.agreeButton?.imageName = #imageLiteral(resourceName: "SwipeArrow_ORG")
                cell.agreeButton?.tag = indexPath.section
                cell.feesTitleLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.acknowledgeAndAgreeString
                if isAgreedToFees {
                    cell.agreeLabel.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1)
                    cell.agreeLabel.layer.borderColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1).cgColor
                    cell.agreeLabel.text = Constant.AlertMessages.agreeToFeesMessage
                    cell.agreeLabel.textColor = UIColor.white
                    //cell.allInclusiveSelectedCheckBox.isHidden = false
                } else {
                    if let image = UIImage(named: Constant.assetImageNames.swipeArrowOrgImage) {
                        cell.agreeButton?.imageName = image
                    }
                    cell.allInclusiveSelectedCheckBox.isHidden = true
                    cell.agreeLabel.backgroundColor = UIColor.white
                    cell.agreeLabel.textColor = #colorLiteral(red: 0.9725490196, green: 0.4196078431, blue: 0.2470588235, alpha: 1)
                    cell.agreeLabel.layer.borderColor = #colorLiteral(red: 0.9725490196, green: 0.4196078431, blue: 0.2470588235, alpha: 1).cgColor
                    cell.agreeLabel.text = Constant.AlertMessages.feesAlertMessage
                }
                cell.selectionStyle = .none
                return cell
                
            case 8:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreeToFeesCell, for: indexPath) as? SlideTableViewCell else { return UITableViewCell() }
                cell.agreeButton?.tag = indexPath.section
                cell.feesTitleLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.acceptedTermAndConditionString
                cell.isUserInteractionEnabled = true
                //cell.allInclusiveSelectedCheckBox.isHidden = true
                
                if isAgreed {
                    cell.agreeLabel.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1)
                    cell.agreeLabel.layer.borderColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1).cgColor
                    cell.agreeLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreedToFeesString
                    cell.agreeLabel.textColor = UIColor.white
                    cell.agreeButton?.imageName = #imageLiteral(resourceName: "SwipeArrow_ORG")
                } else if showLoader {
                    showLoader = false
                    cell.activityIndicator.isHidden = false
                    cell.agreeLabel.text = Constant.MyClassConstants.verifying
                    cell.agreeLabel.backgroundColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2274509804, alpha: 1)
                    cell.agreeLabel.textColor = UIColor.white
                } else if isAgreedToFees {
                    cell.agreeLabel.backgroundColor = UIColor.white
                    cell.agreeLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2274509804, alpha: 1).cgColor
                    cell.agreeLabel.text = Constant.AlertMessages.agreePayMessage
                    cell.agreeLabel.textColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2274509804, alpha: 1)
                    cell.agreeButton?.imageName = #imageLiteral(resourceName: "SwipeArrow_ORG")
                } else {
                    if let image = UIImage(named: Constant.assetImageNames.swipeArrowGryImage) {
                        cell.agreeButton?.imageName = image
                    }
                    cell.agreeLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.slideToAgreeAndPayString
                    cell.agreeLabel.backgroundColor = UIColor.white
                    cell.agreeLabel.layer.borderColor = UIColor.lightGray.cgColor
                    cell.agreeLabel.textColor = UIColor.lightGray
                    cell.isUserInteractionEnabled = false
                }
                cell.selectionStyle = .none
                return cell
                
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreeToFeesCell, for: indexPath) as? SlideTableViewCell else { return UITableViewCell() }
                if isAgreed {
                    cell.agreeLabel.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.7921568627, blue: 0.3607843137, alpha: 1)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section != 0 && section < 8 && tableView.tag == 3 {
            
            switch section {
            case 1 :
                if !self.isPromotionsEnabled {
                    return 0
                } else {
                    return 50
                }
            case 2 :
                if !Constant.MyClassConstants.isFromExchange || !Constant.MyClassConstants.searchBothExchange {
                    return 0
                } else {
                    if Constant.MyClassConstants.exchangeFees?.eplus == nil {
                        return 0
                    } else {
                        return 50
                    }
                }
            case 3 :
                if !showInsurance {
                    return 0
                } else {
                    return 50
                }
            case 6, 7 :
                return 10
            default :
                return 50
            }
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section != 0 && section < 8 && tableView.tag == 3 {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkoutTableView.frame.size.width, height: 50))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 10, width: checkoutTableView.frame.size.width - 40, height: 30)
            headerLabel.text = Constant.MyClassConstants.checkOutScreenHeaderIPadTextArray[section]
            
            headerView.addSubview(headerLabel)
            if section == 6 || section == 7 {
                headerView.backgroundColor = #colorLiteral(red: 0.8039215686, green: 0.8, blue: 0.8156862745, alpha: 1)
            } else {
                headerView.backgroundColor = IUIKColorPalette.primary1.color
            }
            headerLabel.textColor = UIColor.white
            return headerView
            
        } else {
            return nil
        }
    }
}

// MARK: - Gesture Recognizer Delegate
extension CheckOutIPadViewController: UIGestureRecognizerDelegate {
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

// MARK: - WebView Delegate
extension CheckOutIPadViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        showHudAsync()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideHudAsync()
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.hideHudAsync()
    }
}

// MARK: - Text Field Delegate
extension CheckOutIPadViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.emailTextToEnter = "\(String(describing: textField.text))\(string)"
    
        if emailTextToEnter == Session.sharedSession.contact?.emailAddress {
            self.showUpdateEmail = false
            let indexPath = NSIndexPath(row: 0, section: 7)
            self.checkoutTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
