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

class CheckOutViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var checkoutOptionTBLview:UITableView!
    @IBOutlet weak var remainingResortHoldingTimeLable: UILabel!
    fileprivate var tappedButtonDictionary = [Int:Bool]()
    
    //class variables
    var remainingHoldingTime:Int!
    var requiredSectionIntTBLview = 13
    //var isPromotionsEnabled = false
    var isTripProtectionEnabled = false
    //var isGetawayOptionEnabled = false
    var bookingCostRequiredRows = 1
    var promotionSelectedIndex = 0
    var isAgreed:Bool = false
    var isAgreedToFees:Bool = false
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
    //var recapPromotionsArray = [Promotion]()
    var recapSelectedPromotion: String?
    var recapFeesTotal: Float?
    var filterRelinquishments = ExchangeRelinquishment()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.vacationSearchPaymentInformation
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        if(!Constant.MyClassConstants.hasAdditionalCharges){
            isAgreedToFees = true
        }
        Constant.MyClassConstants.additionalAdvisementsArray.removeAll()
        Constant.MyClassConstants.generalAdvisementsArray.removeAll()
        
        if(Constant.MyClassConstants.isFromExchange){
            for advisement in (Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements)!{
                
                if(advisement.title == Constant.MyClassConstants.additionalAdv){
                    Constant.MyClassConstants.additionalAdvisementsArray.append(advisement)
                }else{
                    Constant.MyClassConstants.generalAdvisementsArray.append(advisement)
                }
            }
            
                if(Constant.MyClassConstants.exchangeFees.count > 0){
                    if let _: String? = Constant.MyClassConstants.exchangeFees[0].insurance?.insuranceOfferHTML!{
                        showInsurance = true
                        self.isTripProtectionEnabled = true
                    }else{
                        showInsurance = false
                        self.isTripProtectionEnabled = false
                    }
                
                    if(Constant.MyClassConstants.exchangeFees[0].eplus != nil && (Constant.MyClassConstants.exchangeFees[0].eplus?.selected)!){
                        //let chckBoxButton = IUIKCheckbox()
                       // chckBoxButton.checked = true
                        eplusAdded = true
                        //self.checkBoxClicked(sender: chckBoxButton)

                    }else{
                        eplusAdded = false
                    }
                }
            
        }else{
        for advisement in (Constant.MyClassConstants.viewResponse.resort?.advisements)!{
            
            if(advisement.title == Constant.MyClassConstants.additionalAdv){
                Constant.MyClassConstants.additionalAdvisementsArray.append(advisement)
            }else{
                Constant.MyClassConstants.generalAdvisementsArray.append(advisement)
            }
        }
            
            if let _: String? = Constant.MyClassConstants.rentalFees[0].insurance?.insuranceOfferHTML!{
                showInsurance = true
            }else{
                showInsurance = false
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
        
        // omniture tracking with event 38
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch,
            Constant.omnitureCommonString.products : Constant.MyClassConstants.selectedResort.resortCode!,
            Constant.omnitureEvars.eVar37 : Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex),
            Constant.omnitureEvars.eVar39 : "",
            Constant.omnitureEvars.eVar49 : "",
            Constant.omnitureEvars.eVar52 : "\((UserContext.sharedInstance.contact?.creditcards?.count)! > 0 ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no)",
            Constant.omnitureEvars.eVar72 : "\(self.showInsurance ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no)",
            ]
        ADBMobile.trackAction(Constant.omnitureEvents.event37, data: userInfo)
        
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
    }
    
    //***** Function called when notification for slide to agree button is fired. *****//
    func changeLabelStatus(notification:NSNotification){
        
        let imageSlider = notification.object as! UIImageView
        if (Constant.MyClassConstants.indexSlideButton == 12){
            
            let confirmationDelivery = ConfirmationDelivery()
            confirmationDelivery.emailAddress = self.emailTextToEnter
            confirmationDelivery.updateProfile = false
            
            
            let jsStringAccept = "document.getElementById('WASCInsuranceOfferOption0').checked == true;"
            let jsStringReject = "document.getElementById('WASCInsuranceOfferOption1').checked == true;"
            
            var strAccept:String = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringAccept)!
            var strReject:String = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringReject)!
            
            if(!isTripProtectionEnabled){
                strAccept = "true"
                strReject = "true"
            }
            
            if((isAgreedToFees || !Constant.MyClassConstants.hasAdditionalCharges) && (strAccept == "true" || strReject == "true") && Constant.MyClassConstants.selectedCreditCard.count > 0){
                

                Helper.showProgressBar(senderView: self)

                let continueToPayRequest = RentalProcessRecapContinueToPayRequest.init()
                continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard.last!
                continueToPayRequest.confirmationDelivery = confirmationDelivery
                continueToPayRequest.acceptTermsAndConditions = true
                continueToPayRequest.acknowledgeAndAgreeResortFees = true
                
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()

                imageSlider.isHidden = true
                showLoader = true
                self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                if(Constant.MyClassConstants.isFromExchange){
                    
                    let continueToPayRequest = ExchangeProcessContinueToPayRequest.init()
                    continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard.last!
                    continueToPayRequest.confirmationDelivery = confirmationDelivery
                    continueToPayRequest.acceptTermsAndConditions = true
                    continueToPayRequest.acknowledgeAndAgreeResortFees = true
                    
                    ExchangeProcessClient.continueToPay(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { (response) in
                        
                        Constant.MyClassConstants.exchangeBookingLastStartedProcess = nil
                        Constant.MyClassConstants.exchangeContinueToPayResponse = response
                        let selectedCard = Constant.MyClassConstants.selectedCreditCard
                        if(selectedCard[0].saveCardIndicator == true){
                            UserContext.sharedInstance.contact?.creditcards?.append(selectedCard[0])
                        }
                        Constant.MyClassConstants.selectedCreditCard.removeAll()
                        Helper.removeStoredGuestFormDetials()
                        self.isAgreed = true
                        Helper.hideProgressBar(senderView: self)
                        self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        Constant.MyClassConstants.transactionNumber = (response.view?.fees?.shopExchange?.confirmationNumber)!
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
                        
                    }, onError: { (error) in
                        Helper.hideProgressBar(senderView: self)
                        imageSlider.isHidden = false
                        self.isAgreed = false
                        self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: error.description)
                    })
                }else{
                    
                    let continueToPayRequest = RentalProcessRecapContinueToPayRequest.init()
                    continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard.last!
                    continueToPayRequest.confirmationDelivery = confirmationDelivery
                    continueToPayRequest.acceptTermsAndConditions = true
                    continueToPayRequest.acknowledgeAndAgreeResortFees = true
                    
                RentalProcessClient.continueToPay(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { (response) in
                    
                    Constant.MyClassConstants.getawayBookingLastStartedProcess = nil
                    Constant.MyClassConstants.continueToPayResponse = response
                    let selectedCard = Constant.MyClassConstants.selectedCreditCard
                    if(selectedCard[0].saveCardIndicator == true){
                        UserContext.sharedInstance.contact?.creditcards?.append(selectedCard[0])
                    }
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    Helper.removeStoredGuestFormDetials()
                    self.isAgreed = true
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    Constant.MyClassConstants.transactionNumber = (response.view?.fees?.rental?.confirmationNumber)!
                    self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
                }, onError: { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    imageSlider.isHidden = false
                    self.isAgreed = false
                    self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                    SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: error.description)
                })
            }
            
            }else if(!isAgreedToFees && Constant.MyClassConstants.hasAdditionalCharges){
                let indexPath = NSIndexPath(row: 0, section: 8)
                checkoutOptionTBLview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.feesAlertMessage)
            }else if(strReject == "false" && strAccept == "false"){
                let indexPath = NSIndexPath(row: 0, section: 4)
                checkoutOptionTBLview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.insuranceSelectionMessage)
            }else if((Constant.MyClassConstants.isFromExchange && Constant.MyClassConstants.recapPromotionsArray.count > 0 && Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName == "")){
                imageSlider.isHidden = false
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.promotionsMessage)
            }else if(!Constant.MyClassConstants.isFromExchange && (Constant.MyClassConstants.rentalFees[0].rental!.selectedOfferName == nil || Constant.MyClassConstants.rentalFees[0].rental!.selectedOfferName == "")){
                imageSlider.isHidden = true
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.promotionsMessage)
            }else{
                let indexPath = NSIndexPath(row: 0, section: 6)
                imageSlider.isHidden = true
                checkoutOptionTBLview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.paymentSelectionMessage)
            }
        }else{
            isAgreedToFees = true
            imageSlider.isHidden = true
            self.checkoutOptionTBLview.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
        }
    }
    
     //***** Function called when notification top show trip details is fired. *****//
    func showTripDetails(notification:NSNotification){
        self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

        self.emailTextToEnter = (UserContext.sharedInstance.contact?.emailAddress)!
        self.checkoutOptionTBLview.reloadData()
        if(Constant.MyClassConstants.isFromExchange){
            if let selectedPromotion = Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName {
                self.recapSelectedPromotion = selectedPromotion
                if(selectedPromotion == ""){
                    Constant.MyClassConstants.isPromotionsEnabled = false
                    destinationPromotionSelected = false
                }else{
                    Constant.MyClassConstants.isPromotionsEnabled = true
                    destinationPromotionSelected = true
                }
            }
        }else{
            if let selectedPromotion = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName {
                self.recapSelectedPromotion = selectedPromotion
                if(selectedPromotion == ""){
                    Constant.MyClassConstants.isPromotionsEnabled = false
                    destinationPromotionSelected = false
                }else{
                    Constant.MyClassConstants.isPromotionsEnabled = true
                    destinationPromotionSelected = true
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabelStatus), name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
        
    }
    
    //***** Function called switch state is 'On' so as to update user's email. *****//
    func udpateEmailSwitchPressed(_ sender:UISwitch) {
        
        
        let validEmail =  isValidEmail(testStr: self.emailTextToEnter)
        if(validEmail) {
            
            if(sender.isOn) {
                self.updateEmailSwitchStauts = "on"
            }
            else {
                self.updateEmailSwitchStauts = "off"
            }
        }
        else {
            sender.setOn(false, animated: true)
            SimpleAlert.alert(self, title: Constant.buttonTitles.updateSwitchTitle, message: Constant.AlertErrorMessages.emailAlertMessage)
        }
    }
    
    //***** Function to check if the email entered by user is an valid email address. *****//
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func updateResortHoldingTime() {
        
        if(Constant.holdingTime != 0){
            self.remainingResortHoldingTimeLable.text = Constant.holdingResortForRemainingMinutes
        }else{
            SimpleAlert.alertTodismissController(self, title: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage)
        }
    }
    
    func checkBoxCheckedAtIndex(_ sender:IUIKCheckbox) {
        
        self.promotionSelectedIndex = sender.tag
        Constant.MyClassConstants.isPromotionsEnabled = true
        self.bookingCostRequiredRows = 1
        
        let storyboard = UIStoryboard(name: "VacationSearchIphone", bundle: nil)
        let promotionsNav = storyboard.instantiateViewController(withIdentifier: "DepositPromotionsNav") as! UINavigationController
        let promotionsVC = promotionsNav.viewControllers.first as! PromotionsViewController
        promotionsVC.promotionsArray = Constant.MyClassConstants.recapViewPromotionCodeArray
        promotionsVC.completionHandler = { selected in
            Helper.showProgressBar(senderView: self)
            //Creating Request to recap with Promotion
            
            
            if(Constant.MyClassConstants.isFromExchange){
                let processResort = ExchangeProcess()
                processResort.currentStep = ProcessStep.Recap
                processResort.processId = Constant.MyClassConstants.exchangeProcessStartResponse.processId
                
                let shopExchange = ShopExchange()
                shopExchange.selectedOfferName = Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName!
                
                let fees = ExchangeFees()
                fees.shopExchange = shopExchange
                
                let processRequest = ExchangeProcessRecalculateRequest()
                processRequest.fees = fees
                ExchangeProcessClient.recalculateFees(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: { (response) in
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
                    Helper.hideProgressBar(senderView: self)
                    
                }, onError: { (error) in
                    Helper.hideProgressBar(senderView: self)
                })
            }else{
            let processResort = RentalProcess()
            processResort.currentStep = ProcessStep.Recap
            processResort.processId = Constant.MyClassConstants.processStartResponse.processId
            
            let rental = Rental()
            rental.selectedOfferName = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName!
            
            let fees = RentalFees()
            fees.rental = rental
            
            let processRequest = RentalProcessRecapRecalculateRequest()
            processRequest.fees = fees
            
            RentalProcessClient.addCartPromotion(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: { (response) in
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
                Helper.hideProgressBar(senderView: self)
            }, onError: { (error) in
                Helper.hideProgressBar(senderView: self)
            })
            }
        }
        self.present(promotionsNav, animated: true, completion: nil)
    }
    

    
    //***** Function called when cross button is clicked in email text field. *****//
    func inputClearPressed(_ sender:UIButton) {
        
        self.emailTextToEnter = ""
        self.showUpdateEmail = true
        let indexPath = NSIndexPath(row: 0, section: 10)
        self.checkoutOptionTBLview.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //Used to expand and contract sections
    func toggleButtonIsTapped(_ sender: UIButton) {
        if let tag = tappedButtonDictionary[sender.tag]{
            if tag{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
            else{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
        }
        else{
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.checkoutOptionTBLview.reloadData()
    }
    
    
    //***** Function to calculate dynamic height. ******//
    
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func widthForView(_ text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
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
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        Helper.showProgressBar(senderView: self)
        if(Constant.MyClassConstants.isFromExchange){
            ExchangeProcessClient.backToChooseExchange(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, onSuccess: {(response) in
                Helper.hideProgressBar(senderView: self)
            }, onError: {(error) in
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title: "Checkout", message: error.localizedDescription)
            })

        }else{
            RentalProcessClient.backToWhoIsChecking(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess: {(response) in
            
            Helper.hideProgressBar(senderView: self)
            _ = self.navigationController?.popViewController(animated: true)
            
        }, onError: {(error) in
            
            Helper.hideProgressBar(senderView: self)
            SimpleAlert.alert(self, title: "Checkout", message: "Unable to perform back button operatin due to server error, Try again!")
        })
        }
    }
    
    //***** Function called when radio button is selected in Add Trip Protection. *****//
    func handleTap(_ sender: UITapGestureRecognizer) {
        
        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            let jsString = "document.getElementById('WASCInsuranceOfferOption0').checked == true;"
            
            let str:String = self.cellWebView.stringByEvaluatingJavaScript(from: jsString)!
            
            if(str == "true" && !self.tripRequestInProcess){
                self.tripRequestInProcess = true
                self.isTripProtectionEnabled = true
                Constant.MyClassConstants.checkoutInsurencePurchased = Constant.AlertPromtMessages.yes
                self.addTripProtection(shouldAddTripProtection: true)
                
            }else if(str == "false" && !self.tripRequestInProcess){
                self.tripRequestInProcess = true
                self.isTripProtectionEnabled = false
                Constant.MyClassConstants.checkoutInsurencePurchased = Constant.AlertPromtMessages.no
                self.addTripProtection(shouldAddTripProtection: false)
            }
            self.checkoutOptionTBLview.reloadSections(IndexSet(integer: 6), with:.automatic)
        }
        
    }
    
    //***** Function for adding and removing trip protection *****//
    
    func addTripProtection(shouldAddTripProtection:Bool){
        if(Constant.MyClassConstants.isFromExchange){
          Constant.MyClassConstants.exchangeFees.last!.insurance?.selected = shouldAddTripProtection
            let exchangeRecalculateRequest = ExchangeProcessRecalculateRequest()
            exchangeRecalculateRequest.fees = Constant.MyClassConstants.exchangeFees.last!
            Helper.showProgressBar(senderView: self)
            ExchangeProcessClient.recalculateFees(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: exchangeRecalculateRequest, onSuccess: {
                (response) in
                
                self.tripRequestInProcess = false
                Constant.MyClassConstants.exchangeContinueToCheckoutResponse = response
                DarwinSDK.logger.debug(Constant.MyClassConstants.continueToCheckoutResponse.view?.promoCodes)
                DarwinSDK.logger.debug(Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.insurance?.price)
                Constant.MyClassConstants.exchangeFees[0].total = (response.view?.fees?.total)!
                self.checkoutOptionTBLview.reloadData()
                Helper.hideProgressBar(senderView: self)
    
            }, onError: { (error) in
                Constant.MyClassConstants.exchangeFees.last!.insurance?.selected = !shouldAddTripProtection
                self.tripRequestInProcess = false
                self.isTripProtectionEnabled = false
                self.checkoutOptionTBLview.reloadData()
                DarwinSDK.logger.debug(error.description)
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: error.description)
            })
        }else{
            
            Constant.MyClassConstants.rentalFees.last!.insurance?.selected = shouldAddTripProtection
            let rentalRecalculateRequest = RentalProcessRecapRecalculateRequest.init()
            rentalRecalculateRequest.fees = Constant.MyClassConstants.rentalFees.last!
            Helper.showProgressBar(senderView: self)
            RentalProcessClient.addTripProtection(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: rentalRecalculateRequest, onSuccess: { (response) in
                self.tripRequestInProcess = false
                Constant.MyClassConstants.continueToCheckoutResponse = response
                DarwinSDK.logger.debug(Constant.MyClassConstants.continueToCheckoutResponse.view?.promoCodes)
                DarwinSDK.logger.debug(Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.insurance?.price)
                Constant.MyClassConstants.rentalFees[0].total = (response.view?.fees?.total)!
                self.checkoutOptionTBLview.reloadSections(IndexSet(integer: 8), with:.automatic)
                Helper.hideProgressBar(senderView: self)
            }, onError: { (error) in
                "document.getElementById('WASCInsuranceOfferOption0').checked = false;"
                "document.getElementById('WASCInsuranceOfferOption1').checked = false;"
                self.tripRequestInProcess = false
                self.isTripProtectionEnabled = false
                self.checkoutOptionTBLview.reloadData()
                DarwinSDK.logger.debug(error.description)
                Helper.hideProgressBar(senderView: self)
            })
        }
    }
    
    //***** Function called when detail button is pressed. ******//
    func resortDetailsClicked(_ sender:IUIKButton){
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
    }
    
    //Function to add remove eplus
    @IBAction func checkBoxClicked(sender: IUIKCheckbox){
            let exchangeRecalculateRequest = ExchangeProcessRecalculateRequest()
            exchangeRecalculateRequest.fees = Constant.MyClassConstants.exchangeFees.last!
            exchangeRecalculateRequest.fees?.eplus?.selected = sender.checked
            Helper.showProgressBar(senderView: self)
            ExchangeProcessClient.recalculateFees(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.exchangeBookingLastStartedProcess, request: exchangeRecalculateRequest, onSuccess: { (recapResponse) in
                self.eplusAdded = sender.checked
                Constant.MyClassConstants.exchangeFees = [(recapResponse.view?.fees)!]
                Helper.hideProgressBar(senderView: self)
                self.checkoutOptionTBLview.reloadData()
            }, onError: { (error) in
               self.eplusAdded = !sender.checked
               Constant.MyClassConstants.exchangeFees[0].eplus?.selected = sender.checked
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: error.description)
                self.checkoutOptionTBLview.reloadData()
            })
    }
    

}

//Extension class starts from here

extension CheckOutViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 9) {
            
            SVProgressHUD.show()
            Helper.addServiceCallBackgroundView(view: self.view)
            UserClient.getCreditCards(UserContext.sharedInstance.accessToken!, onSuccess: { (response) in
                
                Constant.MyClassConstants.memberCreditCardList = response
                DispatchQueue.main.async(execute: {
                    
                    if(Constant.MyClassConstants.selectedCreditCard.count == 0) {
                        
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.selectPaymentMethodSegue, sender: nil)
                    }
                    else {
                        
                        let selectedCard = Constant.MyClassConstants.selectedCreditCard[0]
                        if(selectedCard.creditcardId == 0) {
                            Constant.MyClassConstants.memberCreditCardList.append(selectedCard)
                            SVProgressHUD.dismiss()
                            Helper.removeServiceCallBackgroundView(view: self.view)
                            self.performSegue(withIdentifier: Constant.segueIdentifiers.selectPaymentMethodSegue, sender: nil)
                        }else{
                            //Constant.MyClassConstants.memberCreditCardList.append(selectedCard)
                            SVProgressHUD.dismiss()
                            Helper.removeServiceCallBackgroundView(view: self.view)
                            self.performSegue(withIdentifier: Constant.segueIdentifiers.selectPaymentMethodSegue, sender: nil)
                        }
                    }
                    
                })
            }, onError: { (error) in
                
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                print(error)
                
            })
        }
    }
    
}


extension CheckOutViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return self.requiredSectionIntTBLview
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0) {
            

            if(Constant.MyClassConstants.isFromExchange) {

            if(Constant.MyClassConstants.vacationSearchSelectedSegmentIndex == 1) || Constant.MyClassConstants.vacationSearchSelectedSegmentIndex == 0{
                return 1
            }else{

                return 2
                }
            }else{
                return 1
            }
            
        }else if(section == 1) {
            var advisementCount:Int = 0
            if let isOpen = tappedButtonDictionary[section]{
                if(isOpen){
                    advisementCount = Constant.MyClassConstants.additionalAdvisementsArray.count + Constant.MyClassConstants.generalAdvisementsArray.count + 1
                    return advisementCount
                }else{
                    advisementCount = Constant.MyClassConstants.additionalAdvisementsArray.count + Constant.MyClassConstants.generalAdvisementsArray.count
                    return advisementCount
                }
            }else{
                advisementCount = Constant.MyClassConstants.generalAdvisementsArray.count
                return advisementCount
            }
        }else if(section == 2) {
            if Constant.MyClassConstants.recapViewPromotionCodeArray.count > 0 {
                return 1
            }
            return 0
        }else if(section == 3){
            if(Constant.MyClassConstants.isFromExchange){
                return 1
            }else{
                return 0
            }
        }else if(section == 4 && !showInsurance){
            return 0
        }else if((section == 5 && (Constant.MyClassConstants.isFromExchange || !Constant.MyClassConstants.isFromExchange) && Constant.MyClassConstants.enableTaxes) || (section == 6 && Constant.MyClassConstants.enableGuestCertificate && self.isTripProtectionEnabled)){
            if(eplusAdded){
                return 3
            }else{
                return 2
            }
        }else{
            if(section == 5 && eplusAdded){
                return 2
            }else{
                return 1
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if(section == 1 || section == 2 || section == 3 || section == 4 || section == 8 || section == 9) {
            
            if(section == 1) {
                
                if(Constant.MyClassConstants.recapViewPromotionCodeArray.count == 0) {
                    return 0
                }
                else {
                    return 50
                }
            }
            else if(section == 2) {
                
                if(Constant.MyClassConstants.vacationSearchSelectedSegmentIndex == 1) {
                    
                    return 0
                }
                else {
                    if(Constant.MyClassConstants.exchangeFees[0].eplus == nil){
                        return 0
                    }else{
                        return 50
                    }
                }
                
            }else if(section == 3 && !showInsurance){
                return 0
            }else {
                return 50
            }
        }
        else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if(section == 1 || section == 2 || section == 3 || section == 4 || section == 8 || section == 9) {
            
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkoutOptionTBLview.frame.size.width, height: 50))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 10, width: checkoutOptionTBLview.frame.size.width - 40, height: 30)
            headerLabel.text  = Constant.MyClassConstants.checkOutScreenHeaderTextArray[section]
            headerView.addSubview(headerLabel)
            headerView.backgroundColor = IUIKColorPalette.primary1.color
            headerLabel.textColor = UIColor.white
            
            if(section == 1) {
                
                if(Constant.MyClassConstants.recapViewPromotionCodeArray.count == 0) {
                    return nil
                }
                else {
                    return headerView
                }
            }
            else if(section == 2) {
                return headerView
                if(Constant.MyClassConstants.vacationSearchSelectedSegmentIndex == 1) {
                    
                    return headerView
                }
                else {
                    return headerView
                }
                
            }
            else {
                return headerView
            }
        }
        else {
            
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        isHeightZero = false
        //showInsurance = false
        if(indexPath.section == 0) {
            return 50
        }
        else if(indexPath.section == 1) {
            
            if(indexPath.row == (Constant.MyClassConstants.generalAdvisementsArray.count)) {
                return 30
            }else if(indexPath.row != (Constant.MyClassConstants.generalAdvisementsArray.count) + 1){
                let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                let height = heightForView((Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth! - 10)
                return height + 60
            }else{
                let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                let height = heightForView((Constant.MyClassConstants.additionalAdvisementsArray.last?.description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth! - 20)
                return height + 60
            }
            
        }else if(indexPath.section == 2 || indexPath.section == 9) {
            return 60
        }else if(indexPath.section == 4) {
            if(Constant.MyClassConstants.isFromExchange){
                if(Constant.MyClassConstants.exchangeFees.count > 0){
                    let insuranceString: String? = Constant.MyClassConstants.exchangeFees[0].insurance?.insuranceOfferHTML!
                    guard let myString = insuranceString, !myString.isEmpty else {
                        showInsurance = false
                        return 0
                    }
                    showInsurance = true
                    return 420
                }else{
                    return 0
                }
                
            }else{
                let insuranceString: String? = Constant.MyClassConstants.rentalFees[0].insurance?.insuranceOfferHTML!
                guard let myString = insuranceString, !myString.isEmpty else {
                    showInsurance = false
                    return 0
                }
                showInsurance = true
                return 420
            }
            
        }else if ((indexPath.section == 7 && !Constant.MyClassConstants.isPromotionsEnabled) || (indexPath.section == 6 && !self.isTripProtectionEnabled && !Constant.MyClassConstants.enableGuestCertificate) || (indexPath.section == 5 && !Constant.MyClassConstants.isFromExchange && Constant.MyClassConstants.isFromExchange && !Constant.MyClassConstants.enableTaxes && !eplusAdded)) {
            isHeightZero = true
            return 0
        }else if(indexPath.section == 7 && Constant.MyClassConstants.isPromotionsEnabled){
            return 60
        }else if(indexPath.section == 7 && !Constant.MyClassConstants.isPromotionsEnabled){
            return 0
        }else if(indexPath.section == 8){
            return 60
        }else if(indexPath.section == 5 || indexPath.section == 6){
            return 30
        }else if(indexPath.section == 3) {
            if(!Constant.MyClassConstants.isFromExchange) {
                return 0
            }else {
                if(Constant.MyClassConstants.exchangeFees[0].eplus == nil){
                    return 0
                }else{
                    return 130
                }
            }
        }else if(indexPath.section == 4 && Constant.MyClassConstants.isFromExchange){
            return 0
        }else if(indexPath.section == 10){
            if(self.showUpdateEmail){
                return 130
            }else{
                return 90
            }
        }else if(indexPath.section == 11) {
            if(Constant.MyClassConstants.hasAdditionalCharges){
                return 150
            }else{
                return 0
            }
        }else if(indexPath.section == 12){
            return 100
        }else {
            return 130
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Header Cell
        if(indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell
            
            
            if(indexPath.row == 0){
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
                cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.resortImage)
            }else{
                cell.resortDetailsButton.addTarget(self, action: #selector(WhoWillBeCheckingInViewController.resortDetailsClicked(_:)), for: .touchUpInside)
                cell.resortName?.text = Constant.MyClassConstants.selectedResort.resortName
                cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.relinquishmentImage)
                cell.lblHeading.text = Constant.MyClassConstants.relinquishment
                cell.resortName?.text = filterRelinquishments.openWeek?.resort?.resortName
            }
            cell.resortDetailsButton.addTarget(self, action: #selector(self.resortDetailsClicked(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if(indexPath.section == 1) {
            //Advisements Cell
            if(indexPath.row == (Constant.MyClassConstants.generalAdvisementsArray.count)) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.advisementsCellIdentifier, for: indexPath) as! AvailableDestinationCountryOrContinentsTableViewCell
                cell.tooglebutton.addTarget(self, action: #selector(CheckOutViewController.toggleButtonIsTapped(_:)), for: .touchUpInside)
                cell.tooglebutton.tag = indexPath.section
                cell.selectionStyle = .none
                return cell
                
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.advisementsCell, for: indexPath) as! AdvisementsCell
                if(indexPath.row != (Constant.MyClassConstants.generalAdvisementsArray.count) + 1){
                    cell.advisementType.text = (Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].title)?.capitalized
                    cell.advisementTextLabel.text = Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description
                }else{
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
            
        }else if(indexPath.section == 2) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutPromotionCell", for: indexPath) as! CheckoutPromotionCell
            cell.setupCell(selectedPromotion: destinationPromotionSelected)
            cell.promotionSelectionCheckBox.tag = indexPath.row
            if cell.promotionSelectionCheckBox.isHidden {
                 cell.forwardArrowButton.addTarget(self, action: #selector(CheckOutViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            } else {
                cell.promotionSelectionCheckBox.addTarget(self, action: #selector(CheckOutViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            }
           
            cell.selectionStyle = .none
            return cell
        }else if(indexPath.section == 3){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeOptionsCell, for: indexPath) as! ExchangeOptionsCell
            cell.setupCell(selectedEplus:true)
            cell.selectionStyle = .none
            return cell
            
        }else if(indexPath.section == 9) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.additionalAdvisementCell, for: indexPath)
            for subviews in cell.subviews {
                
                subviews.removeFromSuperview()
            }
            cell.backgroundColor = UIColor.white
            let forwardArrowImageView = UIImageView(frame: CGRect(x: cell.contentView.frame.width - 40, y: 15, width: 30, height: 30))
            forwardArrowImageView.image = UIImage(named: Constant.assetImageNames.forwardArrowIcon)
            
            let paymentMethodLabel = UILabel(frame: CGRect(x: 20, y: 10, width: cell.contentView.frame.width - 90, height: 20))
            paymentMethodLabel.text = Constant.MyClassConstants.paymentMethodTitle
            paymentMethodLabel.textColor = IUIKColorPalette.primary1.color
            
            let selectPamentMethodLabel = UILabel(frame: CGRect(x: 20, y: 30, width: cell.contentView.frame.width - 40, height: 20))
            if(Constant.MyClassConstants.selectedCreditCard.count > 0) {
                let creditcard = Constant.MyClassConstants.selectedCreditCard[0]
                let cardNumber = creditcard.cardNumber!
                let last4 = cardNumber.substring(from:(cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
                let cardType = Helper.cardTypeCodeMapping(cardType: (creditcard.typeCode!))
                selectPamentMethodLabel.text = "\(cardType) ending in \(last4)"
            }
            else {
                selectPamentMethodLabel.text = Constant.MyClassConstants.paymentInfo
            }
            
            selectPamentMethodLabel.textColor = UIColor.darkGray
            cell.addSubview(forwardArrowImageView)
            cell.addSubview(paymentMethodLabel)
            cell.addSubview(selectPamentMethodLabel)
            cell.selectionStyle = .none
            return cell
            
        }else if(indexPath.section == 10) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.emailCell, for: indexPath) as! EmailTableViewCell
            cell.emailTextField.text = self.emailTextToEnter
            if(self.showUpdateEmail) {
                cell.updateEmailOnOffSwitch.isHidden = false
                cell.updateProfileTextLabel.isHidden = false
            }
            else {
                cell.updateEmailOnOffSwitch.isHidden = true
                cell.updateProfileTextLabel.isHidden = true
            }
            cell.emailTextField.delegate = self
            cell.inputClearButton.addTarget(self, action: #selector(self.inputClearPressed(_:)), for: .touchUpInside)
            cell.updateEmailOnOffSwitch.addTarget(self, action: #selector(self.udpateEmailSwitchPressed(_:)), for: .valueChanged)
            cell.selectionStyle = .none
            return cell
            
        }else if (indexPath.section == 11){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.agreeToFeesCell, for: indexPath) as! SlideTableViewCell
            cell.agreeButton?.dragPointWidth = 70
            cell.agreeButton?.tag = indexPath.section
            cell.agreeButton?.accessibilityValue = String(indexPath.section)
            cell.feesTitleLabel.text = Constant.AlertMessages.feesPaymentMessage
            
            if(isAgreed){
                cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0)
                cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0).cgColor
                cell.agreeLabel.text = Constant.AlertMessages.agreeToFeesMessage
                cell.agreeLabel.textColor = UIColor.white
            }else{
                cell.agreeLabel.backgroundColor = UIColor.white
                cell.agreeLabel.textColor = UIColor(colorLiteralRed: 248/255, green: 107/255, blue: 63/255, alpha: 1.0)
                cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 248/255, green: 107/255, blue: 63/255, alpha: 1.0).cgColor
                cell.agreeLabel.text = Constant.AlertMessages.feesAlertMessage
            }
            cell.selectionStyle = .none
            return cell
            
        }
        else if(indexPath.section == 12) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.agreeToFeesCell, for: indexPath) as! SlideTableViewCell
            
            cell.feesTitleLabel.text = Constant.AlertMessages.termsConditionMessage
            cell.agreeButton?.dragPointWidth = 70
            cell.agreeButton?.tag = indexPath.section
            if(isAgreed){
                cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0)
                cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0).cgColor
                cell.agreeLabel.text = Constant.MyClassConstants.verifying
                cell.agreeLabel.textColor = UIColor.white
            }else if(showLoader){
                showLoader = false
                cell.activityIndicator.isHidden = false
                cell.agreeLabel.text = Constant.MyClassConstants.verifying
                cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 117/255, blue: 58/255, alpha: 1.0)
                cell.agreeLabel.textColor = UIColor.white
            }else if(isAgreedToFees){
                cell.agreeLabel.backgroundColor = UIColor.white
                cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 255/255, green: 117/255, blue: 58/255, alpha: 1.0).cgColor
                cell.agreeLabel.text = Constant.AlertMessages.agreePayMessage
                cell.agreeLabel.textColor = UIColor(colorLiteralRed: 255/255, green: 117/255, blue: 58/255, alpha: 1.0)
                cell.agreeButton?.imageName = UIImage(named:Constant.assetImageNames.swipeArrowOrgImage)!
            }else{
                cell.agreeLabel.text = Constant.AlertMessages.agreePayMessage
                cell.agreeLabel.backgroundColor = UIColor.white
                cell.agreeLabel.layer.borderColor = UIColor.lightGray.cgColor
                cell.agreeLabel.textColor = UIColor.lightGray
            }
            cell.selectionStyle = .none
            return cell
        }else {
            
            if(indexPath.section == 4) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.additionalAdvisementCell, for: indexPath)
                /* for subviews in cell.subviews {
                 
                 subviews.removeFromSuperview()
                 }*/
                var containsWebView = false
                for subVw in cell.subviews{
                    if(subVw.isKind(of: UIWebView.self)){
                        containsWebView = true
                    }
                }
                if(!containsWebView){
                    cellWebView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400)
                    cellWebView.scrollView.isScrollEnabled = false
                    cellWebView.delegate = self
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                    tapRecognizer.numberOfTapsRequired = 1
                    tapRecognizer.delegate = self
                    
                    cellWebView.addGestureRecognizer(tapRecognizer)
                    
                    if(showInsurance && !Constant.MyClassConstants.isFromExchange){
                        let str = (Constant.MyClassConstants.rentalFees[indexPath.row].insurance?.insuranceOfferHTML!)!
                        cellWebView.loadHTMLString(str, baseURL: nil)
                    }else{
                        let str = (Constant.MyClassConstants.exchangeFees[indexPath.row].insurance?.insuranceOfferHTML!)!
                        cellWebView.loadHTMLString(str, baseURL: nil)
                    }
                    cellWebView.backgroundColor = UIColor.gray
                    cell.addSubview(cellWebView)
                }
                cell.selectionStyle = .none
                
                return cell
            }else if(indexPath.section == 5){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as! ExchangeOrProtectionCell
                
                if(!isHeightZero){
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    if(indexPath.row == 0 && Constant.MyClassConstants.isFromExchange){
                        cell.priceLabel.text = "Exchange Fee"
                        cell.primaryPriceLabel.text = String(Int(Float((Constant.MyClassConstants.exchangeFees[0].shopExchange?.rentalPrice?.price)!)))
                        let priceString = "\(Constant.MyClassConstants.exchangeFees[0].shopExchange!.rentalPrice!.price)"
                        let priceArray = priceString.components(separatedBy: ".")
                        print(priceArray.last!)
                        if((priceArray.last!.characters.count) > 1) {
                            cell.fractionalPriceLabel.text = "\(priceArray.last!)"
                        }else{
                            cell.fractionalPriceLabel.text = "00"
                        }
                    }else if(indexPath.row == 0 && !Constant.MyClassConstants.isFromExchange){
                        cell.priceLabel.text = "Getaway Fee"
                        cell.primaryPriceLabel.text = String(Int(Float((Constant.MyClassConstants.rentalFees[0].rental?.rentalPrice?.price)!)))
                        let priceString = "\(Constant.MyClassConstants.rentalFees[0].rental!.rentalPrice!.price)"
                        let priceArray = priceString.components(separatedBy: ".")
                        print(priceArray.last!)
                        if((priceArray.last!.characters.count) > 1) {
                            cell.fractionalPriceLabel.text = "\(priceArray.last!)"
                        }else{
                            cell.fractionalPriceLabel.text = "00"
                        }
                        
                    }else if(Constant.MyClassConstants.isFromExchange && eplusAdded){
                        cell.priceLabel.text = "EPlus"
                        
                        let priceString = "\(Constant.MyClassConstants.exchangeFees[0].eplus!.price)"
                        let priceArray = priceString.components(separatedBy: ".")
                        cell.primaryPriceLabel.text = priceArray.first
                        if((priceArray.last?.characters.count)! > 1) {
                            cell.fractionalPriceLabel.text = "\(String(describing: priceArray.last!))"
                        }else{
                            cell.fractionalPriceLabel.text = "00"
                        }

                        
                    }else{
                        cell.priceLabel.text = "Taxes"
                        var rentalTax = 0.0
                        if(Constant.MyClassConstants.isFromExchange){
                            rentalTax = Double(Int((Constant.MyClassConstants.exchangeContinueToCheckoutResponse.view?.fees?.total)!))
                        }else{
                            rentalTax = Double(Int((Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.rental?.rentalPrice?.tax)!))
                        }
                        
                        cell.primaryPriceLabel.text = "\(rentalTax)"
                        let priceString = "\(Constant.MyClassConstants.continueToCheckoutResponse.view!.fees!.rental!.rentalPrice!.tax)"
                        let priceArray = priceString.components(separatedBy: ".")
                        cell.primaryPriceLabel.text = priceArray.first
                        if((priceArray.last?.characters.count)! > 1) {
                            cell.fractionalPriceLabel.text = "\(priceArray.last!)"
                        }else{
                            cell.fractionalPriceLabel.text = "00"
                        }
                    }
                    
                    let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16.0)
                    
                    let width = widthForView(cell.primaryPriceLabel.text!, font: font!, height: cell.priceLabel.frame.size.height)
                    cell.primaryPriceLabel.frame.size.width = width + 5
                    
                    let targetString = cell.primaryPriceLabel.text
                    let range = NSMakeRange(0, (targetString?.characters.count)!)
                    
                    cell.primaryPriceLabel.attributedText = Helper.attributedString(from: targetString!, nonBoldRange: range, font: font!)
                    cell.periodLabel.frame.origin.x = cell.primaryPriceLabel.frame.origin.x + width
                    cell.fractionalPriceLabel.frame.origin.x = cell.periodLabel.frame.origin.x + cell.periodLabel.frame.size.width + 5
                    
                }else{
                    isHeightZero = false
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = true
                    }
                }
                cell.selectionStyle = .none
                return cell
                
            }else if(indexPath.section == 6){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as! ExchangeOrProtectionCell
                
                if(!isHeightZero){
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    if(indexPath.row == 0 && self.isTripProtectionEnabled){
                        cell.priceLabel.text = "Insurance"
                        var priceString = ""
                        if(Constant.MyClassConstants.isFromExchange){
                            priceString = "\(Constant.MyClassConstants.exchangeFees[indexPath.row].insurance!.price)"
                        }else{
                            priceString = "\(Constant.MyClassConstants.rentalFees[indexPath.row].insurance!.price)"
                        }
                        let priceArray = priceString.components(separatedBy: ".")
                        
                        cell.primaryPriceLabel.text = priceArray.first!
                        if((priceArray.last?.characters.count)! > 1) {
                            cell.fractionalPriceLabel.text = "\(priceArray.last!)"
                        }else{
                            cell.fractionalPriceLabel.text = "00"
                        }
                    }else{
                        cell.priceLabel.text = "Guest Certificate"
                        let guestPrice = Int(Constant.MyClassConstants.guestCertificatePrice)
                        cell.primaryPriceLabel.text = "\(guestPrice)"
                    }
                    
                    let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16.0)
                    
                    let width = widthForView(cell.primaryPriceLabel.text!, font: font!, height: cell.priceLabel.frame.size.height)
                    cell.primaryPriceLabel.frame.size.width = width + 5
                    
                    let targetString = cell.primaryPriceLabel.text
                    let range = NSMakeRange(0, (targetString?.characters.count)!)
                    
                    cell.primaryPriceLabel.attributedText = Helper.attributedString(from: targetString!, nonBoldRange: range, font: font!)
                    cell.periodLabel.frame.origin.x = cell.primaryPriceLabel.frame.origin.x + width
                    cell.fractionalPriceLabel.frame.origin.x = cell.periodLabel.frame.origin.x + cell.periodLabel.frame.size.width + 5
                    
                }else{
                    isHeightZero = false
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = true
                    }
                }
                cell.selectionStyle = .none
                return cell
                
            }else if(indexPath.section == 7){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.promotionsDiscountCell, for: indexPath) as! PromotionsDiscountCell
                
                if(!isHeightZero){
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    cell.discountLabel.text = recapSelectedPromotion
                    for promotion in Constant.MyClassConstants.recapPromotionsArray {
                        if promotion.offerName == recapSelectedPromotion {
                            let priceStr = "\(promotion.amount)"
                            let priceArray = priceStr.components(separatedBy: ".")
                            cell.amountLabel.text = "\(Int(promotion.amount))"
                            if((priceArray.last?.characters.count)! > 1) {
                                cell.centsLabel.text = "\(priceArray.last!)"
                            }else{
                                cell.centsLabel.text = "\(priceArray.last!)0"
                            }
                        }
                    }
                }else{
                    isHeightZero = false
                    for subviews in cell.subviews {
                        subviews.isHidden = true
                    }
                }
                cell.selectionStyle = .none
                return cell
                
            }else if(indexPath.section == 8){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.totalCostCell, for: indexPath) as! TotalCostCell
                cell.selectionStyle = .none
                if(Constant.MyClassConstants.isFromExchange){
                    cell.priceLabel.text = String(Int(Float(Constant.MyClassConstants.exchangeFees[0].total)))
                }else{
                    cell.priceLabel.text = String(Int(Float(Constant.MyClassConstants.rentalFees[0].total)))
                    var priceString = "\(Constant.MyClassConstants.rentalFees[0].total)"
                    var targetString = String(Int(Float(Constant.MyClassConstants.rentalFees[0].total)))
                    if let total = recapFeesTotal {
                        cell.priceLabel.text = String(Int(Float(total)))
                        priceString = "\(total)"
                        targetString = String(Int(Float(total)))
                    }
                    
                    let priceArray = priceString.components(separatedBy: ".")
                    
                    if((priceArray.last?.characters.count)! > 1) {
                        cell.fractionalPriceLabel.text = "\(priceArray.last!)"
                    }else{
                        cell.fractionalPriceLabel.text = "\(priceArray.last!)0"
                    }
                    
                    let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 25.0)
                    
                    let width = widthForView(cell.priceLabel.text!, font: font!, height: cell.priceLabel.frame.size.height)
                    cell.priceLabel.frame.size.width = width + 5
                    
                    let range = NSMakeRange(0, targetString.characters.count)
                    
                    cell.priceLabel.attributedText = Helper.attributedString(from: targetString, nonBoldRange: range, font: font!)
                    cell.periodLabel.frame.origin.x = cell.priceLabel.frame.origin.x + width
                    cell.fractionalPriceLabel.frame.origin.x = cell.periodLabel.frame.origin.x + cell.periodLabel.frame.size.width + 5
                }
                return cell
                
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.totalCostCell, for: indexPath) as! TotalCostCell
                if(Constant.MyClassConstants.isFromExchange){
                    cell.priceLabel.text = String(Int(Float(Constant.MyClassConstants.exchangeFees[0].total)))
                }else{
                    cell.priceLabel.text = String(Int(Float(Constant.MyClassConstants.rentalFees[0].total)))
                }
                
                if let total = recapFeesTotal {
                    cell.priceLabel.text = String(Int(Float(total)))
                    
                }
                return cell
            }
        }
    }
  }


extension CheckOutViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        return true
    }
    
    @available(iOS 9.0, *)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool{
        return true
    }
}


extension CheckOutViewController:UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        Helper.addServiceCallBackgroundView(view: self.view)
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        SVProgressHUD.dismiss()
        Helper.removeServiceCallBackgroundView(view: self.view)
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        SVProgressHUD.dismiss()
        Helper.removeServiceCallBackgroundView(view: self.view)
    }
}

extension CheckOutViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.emailTextToEnter = "\(textField.text!)\(string)"
        
        if(self.emailTextToEnter.caseInsensitiveCompare((UserContext.sharedInstance.contact?.emailAddress)!) == ComparisonResult.orderedSame){
        }
        if(emailTextToEnter == UserContext.sharedInstance.contact?.emailAddress) {
            self.showUpdateEmail = false
            let indexPath = NSIndexPath(row: 0, section: 10)
            self.checkoutOptionTBLview.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
}
