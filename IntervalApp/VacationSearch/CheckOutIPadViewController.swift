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
    @IBOutlet weak var checkoutScrollView:UIScrollView!
    @IBOutlet weak var headerTableView:UITableView!
    @IBOutlet weak var bookingTableView:UITableView!
    @IBOutlet weak var checkoutTableView:UITableView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var remainingResortHoldingTimeLabel: UILabel!
    
    fileprivate var tappedButtonDictionary = [Int:Bool]()
    
    @IBOutlet weak var scrollVwTop: NSLayoutConstraint!
    @IBOutlet weak var tableVwHeight: NSLayoutConstraint!
    
    //Class variables
    var remainingHoldingTime:Int!
    var requiredSectionIntTBLview = 10
    var isPromotionsEnabled = true
    var isTripProtectionEnabled = false
    var isExchangeOptionEnabled = false
    var isGetawayOptionEnabled = true
    var bookingCostRequiredRows = 1
    var promotionSelectedIndex = 0
    var isAgreed:Bool = false
    var isAgreedToFees:Bool = false
    var cellWebView = UIWebView()
    var showUpdateEmail = false
    var updateEmailSwitchStauts = "off"
    var emailTextToEnter = ""
    var tripRequestInProcess = false
    var isHeightZero = false
    var promotionsArray = ["20% OFF","10% OFF","No Thanks"]
    var showLoader = false
    var showInsurance = false
    var destinationPromotionSelected = false
    var recapPromotionsArray = [Promotion]()
    var recapSelectedPromotion: String?
    var recapFeesTotal: Float?
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabelStatus), name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        self.emailTextToEnter = (UserContext.sharedInstance.contact?.emailAddress)!
        self.checkoutTableView.reloadData()
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.changeSliderStatus), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
        Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.vacationSearchPaymentInformation
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        //Register custom cell xib with tableview
        self.remainingResortHoldingTimeLabel.text = Constant.holdingResortForRemainingMinutes
        
        self.bookingTableView.register(UINib(nibName: Constant.customCellNibNames.totalCostCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.totalCostCell)
        self.bookingTableView.register(UINib(nibName: Constant.customCellNibNames.promotionsDiscountCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.promotionsDiscountCell)
        
        self.bookingTableView.register(UINib(nibName: Constant.customCellNibNames.exchangeOrProtectionCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell)
        
        if(!Constant.MyClassConstants.hasAdditionalCharges){
            isAgreedToFees = true
        }
        Constant.MyClassConstants.additionalAdvisementsArray.removeAll()
        Constant.MyClassConstants.generalAdvisementsArray.removeAll()
        for advisement in (Constant.MyClassConstants.viewResponse.resort?.advisements)!{
            
            if(advisement.title == Constant.MyClassConstants.additionalAdv){
                Constant.MyClassConstants.additionalAdvisementsArray.append(advisement)
            }else{
                Constant.MyClassConstants.generalAdvisementsArray.append(advisement)
            }
        }
    
        self.title = Constant.ControllerTitles.checkOutControllerTitle
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(CheckOutIPadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        let insuranceString: String? = Constant.MyClassConstants.rentalFees[0].insurance?.insuranceOfferHTML!
        guard let myString = insuranceString, !myString.isEmpty else {
            showInsurance = false
            return
        }
        showInsurance = true
        
        
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
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: self.view)
        RentalProcessClient.backToWhoIsChecking(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, onSuccess: {(response) in
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            _ = self.navigationController?.popViewController(animated: true)
            
        }, onError: {(error) in
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.operationFailedMessage)
        })
    }
    override func viewDidLayoutSubviews() {
        
    }
    
    func changeLabelStatus(notification:NSNotification){

        let imageSlider = notification.object as! UIImageView
        if (Constant.MyClassConstants.indexSlideButton == 8){
            
            let confirmationDelivery = ConfirmationDelivery()
            confirmationDelivery.emailAddress = self.emailTextToEnter
            confirmationDelivery.updateProfile = false
            
            let jsStringAccept = Constant.MyClassConstants.webViewGetElementById
            let jsStringReject = Constant.MyClassConstants.webViewGetElementById1
            
            var strAccept:String = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringAccept)!
            var strReject:String = self.cellWebView.stringByEvaluatingJavaScript(from: jsStringReject)!
            
            if(!isTripProtectionEnabled){
                strAccept = Constant.MyClassConstants.status
                strReject = Constant.MyClassConstants.status
            }

            
            if((isAgreedToFees || !Constant.MyClassConstants.hasAdditionalCharges) && (strAccept == Constant.MyClassConstants.status || strReject == Constant.MyClassConstants.status) && Constant.MyClassConstants.selectedCreditCard.count > 0){
                
                let continueToPayRequest = RentalProcessRecapContinueToPayRequest.init()
                continueToPayRequest.creditCard = Constant.MyClassConstants.selectedCreditCard.last!
                continueToPayRequest.confirmationDelivery = confirmationDelivery
                
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()
                imageSlider.isHidden = true
                showLoader = true
                self.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                
                
                RentalProcessClient.continueToPay(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: continueToPayRequest, onSuccess: { (response) in
                    Constant.MyClassConstants.getawayBookingLastStartedProcess = nil
                    Constant.MyClassConstants.continueToPayResponse = response
                    let selectedCard = Constant.MyClassConstants.selectedCreditCard
                    if(selectedCard[0].saveCardIndicator == true){
                        UserContext.sharedInstance.contact?.creditcards?.append(selectedCard[0])
                    }
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    self.isAgreed = true
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    self.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationScreenSegue, sender: nil)
                    
                    }, onError: { (error) in
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        imageSlider.isHidden = false
                        self.isAgreed = false
                    self.checkoutTableView.reloadSections(IndexSet(integer: Constant.MyClassConstants.indexSlideButton), with:.automatic)
                        SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: error.description)
                })
            }else if(!isAgreedToFees && Constant.MyClassConstants.hasAdditionalCharges){
                let indexPath = NSIndexPath(row: 0, section: 7)
                checkoutTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.feesAlertMessage)
            }else if(strReject == Constant.MyClassConstants.isFalse && strAccept == Constant.MyClassConstants.isFalse){
                let indexPath = NSIndexPath(row: 0, section: 4)
                checkoutTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = false
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.insuranceSelectionMessage)
            }else{
                let indexPath = NSIndexPath(row: 0, section: 6)
                checkoutTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                imageSlider.isHidden = true
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.failureTitle, message: Constant.AlertMessages.paymentSelectionMessage)
            }
        }else{
            isAgreedToFees = true
            imageSlider.isHidden = true
            self.checkoutTableView.reloadSections(IndexSet(integer: 8), with:.automatic)
        }
        
    }
    
    //***** Function to update holding time for resort. *****//
    func updateResortHoldingTime() {
        
        if(Constant.holdingTime != 0){
            self.remainingResortHoldingTimeLabel.text = Constant.holdingResortForRemainingMinutes
        }else{
            SimpleAlert.alertTodismissController(self, title: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage)
        }
    }
    
    //***** Function called when radio button is selected in Add Trip Protection. *****//
    func handleTap(_ sender: UITapGestureRecognizer) {
        
        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            let jsString = Constant.MyClassConstants.webViewGetElementById
            
            let str:String = self.cellWebView.stringByEvaluatingJavaScript(from: jsString)!
            
            if(str == Constant.MyClassConstants.isTrue && !self.tripRequestInProcess){
                
                self.tripRequestInProcess = true
                self.isTripProtectionEnabled = true
                self.addTripProtection(shouldAddTripProtection: true)
                
            }else if(str == Constant.MyClassConstants.isFalse && !self.tripRequestInProcess){
                
                self.tripRequestInProcess = true
                self.isTripProtectionEnabled = false
                self.addTripProtection(shouldAddTripProtection: false)
            }
            self.bookingTableView.reloadData()
            //self.bookingTableView.reloadSections(IndexSet(integer: 4), with:.automatic)
        }
        
    }
    
    //***** Function for adding and removing trip protection *****//
    func addTripProtection(shouldAddTripProtection:Bool){
        
        Constant.MyClassConstants.rentalFees.last!.insurance?.selected = shouldAddTripProtection
        let rentalRecalculateRequest = RentalProcessRecapRecalculateRequest.init()
        rentalRecalculateRequest.fees = Constant.MyClassConstants.rentalFees.last!
        Helper.addServiceCallBackgroundView(view: self.view)
        SVProgressHUD.show()
        RentalProcessClient.addTripProtection(UserContext.sharedInstance.accessToken, process: Constant.MyClassConstants.getawayBookingLastStartedProcess, request: rentalRecalculateRequest, onSuccess: { (response) in
            self.tripRequestInProcess = false
            Constant.MyClassConstants.continueToCheckoutResponse = response
            Constant.MyClassConstants.rentalFees[0].total = (response.view?.fees?.total)!
            self.bookingTableView.reloadSections(IndexSet(integer: 0), with:.automatic)
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
            }, onError: { (error) in
                self.tripRequestInProcess = false
                DarwinSDK.logger.debug(error.description)
                Helper.removeServiceCallBackgroundView(view: self.view)
                SVProgressHUD.dismiss()
        })
        
    }
    
    //***** Function called when detail button is pressed. ******//
    func resortDetailsClicked(_ sender:IUIKButton){
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
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
    
    //***** Function to calculate dynamic width. *****//
    func widthForView(_ text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.width
    }
    
    //***** Function called when cross button is clicked in email text field. *****//
    func inputClearPressed(_ sender:UIButton) {
        self.emailTextToEnter = ""
        self.showUpdateEmail = true
        let indexPath = NSIndexPath(row: 0, section: 6)
        self.checkoutTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //***** Function used to expand and contract sections.*****//
    func toggleButtonIsTapped(_ sender: UIButton) {
        
        if let tag = tappedButtonDictionary[sender.tag]{
            if tag{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }else{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
        }else{
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.checkoutTableView.reloadSections(IndexSet(integer: sender.tag), with:.automatic)
        self.checkoutTableView.reloadData()
    }
    
    //***** Function called switch state is 'On' so as to update user's email. *****//
    func udpateEmailSwitchPressed(_ sender:UISwitch) {
        
        let validEmail =  isValidEmail(testStr: self.emailTextToEnter)
        if(validEmail) {
            
            if(sender.isOn) {
                self.updateEmailSwitchStauts = Constant.MyClassConstants.isOn
            }
            else {
                self.updateEmailSwitchStauts = Constant.MyClassConstants.isOff
            }
        }
        else {
            sender.setOn(false, animated: true)
            SimpleAlert.alert(self, title: Constant.buttonTitles.updateSwitchTitle, message: Constant.AlertErrorMessages.emailAlertMessage)
        }
    }
    
    //***** Function to check if the email entered by user is an valid email address. *****//
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = Constant.MyClassConstants.emailRegex
        
        let emailTest = NSPredicate(format:Constant.MyClassConstants.selfMatches, emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkBoxCheckedAtIndex(_ sender:IUIKCheckbox) {
        
        self.promotionSelectedIndex = sender.tag
        self.isPromotionsEnabled = true
        self.bookingCostRequiredRows = 1
        checkoutTableView.reloadData()
        
        let storyboard = UIStoryboard(name: "VacationSearchIphone", bundle: nil)
        let promotionsNav = storyboard.instantiateViewController(withIdentifier: "DepositPromotionsNav") as! UINavigationController
        let promotionsVC = promotionsNav.viewControllers.first as! PromotionsViewController
        promotionsVC.promotionsArray = Constant.MyClassConstants.recapViewPromotionCodeArray
        promotionsVC.completionHandler = { selected in
            SVProgressHUD.show()
            //Creating Request to recap with Promotion
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
                print("succes")
                print(response)
                
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
                SVProgressHUD.dismiss()
            
            }, onError: { (error) in
                print("Error")
                print(error)
                SVProgressHUD.dismiss()
            })
        }
        self.present(promotionsNav, animated: true, completion: nil)
    }

}

//Extension class starts from here

extension CheckOutIPadViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 5 && tableView.tag == 3) {
            
            SVProgressHUD.show()
            Helper.addServiceCallBackgroundView(view: self.view)
            UserClient.getCreditCards(UserContext.sharedInstance.accessToken!, onSuccess: { (response) in
    
                Constant.MyClassConstants.memberCreditCardList = response
                
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
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.selectPaymentMethodSegue, sender: nil)
                    }
                }
                
               
                }, onError: { (error) in
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
            })
        }
    }
}


extension CheckOutIPadViewController:UITableViewDataSource {
    
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
            switch section{
            case 1:
                if((self.isExchangeOptionEnabled || self.isGetawayOptionEnabled) && Constant.MyClassConstants.enableTaxes){
                    return 2
                }else if(!self.isTripProtectionEnabled && !Constant.MyClassConstants.enableTaxes){
                    return 0
                }else{
                    return 1
                }
            case 2:
                if(self.isTripProtectionEnabled && Constant.MyClassConstants.enableGuestCertificate){
                    return 2
                }else if(!self.isTripProtectionEnabled && !Constant.MyClassConstants.enableGuestCertificate){
                    return 0
                }else{
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
            case 1:
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
            case 2:
                return 1
            default:
                return 1
            }
        default:
            return 0
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        isHeightZero = false
        //showInsurance = false
        switch tableView.tag {
        case 2:
            if ((indexPath.section == 3 && !self.isPromotionsEnabled) || (indexPath.section == 2 && !self.isTripProtectionEnabled && !Constant.MyClassConstants.enableGuestCertificate) || (indexPath.section == 1 && !self.isExchangeOptionEnabled && !Constant.MyClassConstants.enableTaxes)) {
                isHeightZero = true
                return 0
            }else if(indexPath.section == 3 && self.isPromotionsEnabled && destinationPromotionSelected){
                return 60
            }else if(indexPath.section == 3 && !self.isPromotionsEnabled){
                return 0
            }else if(indexPath.section == 4){
                return 60
            }else if(indexPath.section == 1 || indexPath.section == 2){
                return 30
            }else{
                return 80
            }
        case 3:
            switch indexPath.section {
            case 0:
                return 80
            case 1:
                if(indexPath.row == (Constant.MyClassConstants.generalAdvisementsArray.count)) {
                    return 30
                }
                else if(indexPath.row != (Constant.MyClassConstants.generalAdvisementsArray.count) + 1){
                    let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                    var height:CGFloat
                    if(Constant.RunningDevice.deviceIdiom == .pad){
                        height = heightForView((Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description)!, font: font!, width: (Constant.MyClassConstants.runningDeviceWidth!/2) - 10)
                        return height + 50
                    }else{
                        height = heightForView((Constant.MyClassConstants.generalAdvisementsArray[indexPath.row].description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth! - 10)
                        return height + 50
                    }
                }else{
                    let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                    var height:CGFloat
                    height = heightForView((Constant.MyClassConstants.additionalAdvisementsArray.last?.description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth! - 20)
                    return height + 50
                }
            case 2:
                if(self.isPromotionsEnabled){
                    return 80
                }else{
                    return 0
                }
            case 3:
                if(self.isExchangeOptionEnabled){
                    return 200
                }else{
                    return 0
                }
            case 4:
                let insuranceString: String? = Constant.MyClassConstants.rentalFees[0].insurance?.insuranceOfferHTML!
                guard let myString = insuranceString, !myString.isEmpty else {
                    showInsurance = false
                    return 0
                }
                showInsurance = true
                return 420
            case 5:
                return 50
            case 6:
                if(self.showUpdateEmail){
                    return 120
                }else{
                    return 150
                }
            case 7:
                if(Constant.MyClassConstants.hasAdditionalCharges){
                    return 150
                }else{
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
        
        if(tableView.tag == 2){
            switch indexPath.section{
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.bookingCell, for: indexPath) as! ViewDetailsTBLcell
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as! ExchangeOrProtectionCell
                
                if(!isHeightZero){
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    if(indexPath.row == 0 && self.isExchangeOptionEnabled){
                        cell.priceLabel.text = Constant.MyClassConstants.exchangeFeeTitle
                        cell.primaryPriceLabel.text = ""
                    }else if(indexPath.row == 0 && self.isGetawayOptionEnabled){
                        cell.priceLabel.text = Constant.MyClassConstants.getawayFee
                        cell.primaryPriceLabel.text = String(Int(Float(Constant.MyClassConstants.inventoryPrice[0].price)))
                    }else{
                        cell.priceLabel.text = Constant.MyClassConstants.taxesTitle
                        let rentalTax = Int((Constant.MyClassConstants.continueToCheckoutResponse.view?.fees?.rental?.rentalPrice?.tax)!)
                        cell.primaryPriceLabel.text = "\(rentalTax)"
                    }
                    
                    let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16.0)
                    
                    let width = widthForView(cell.primaryPriceLabel.text!, font: font!, height: cell.priceLabel.frame.size.height)
                    cell.primaryPriceLabel.frame.size.width = width + 5
                    
                    let targetString = cell.primaryPriceLabel.text
                    let range = NSMakeRange(0, (targetString?.characters.count)!)
                    
                    cell.primaryPriceLabel.attributedText = Helper.attributedString(from: targetString!, nonBoldRange: range, font: font!)
                    cell.periodLabel.frame.origin.x = cell.primaryPriceLabel.frame.origin.x + width
                    cell.fractionalPriceLabel.frame.origin.x = cell.periodLabel.frame.origin.x + cell.periodLabel.frame.size.width
                    
                }else{
                    isHeightZero = false
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = true
                    }
                }
                return cell
            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.exchangeOrProtectionCell, for: indexPath) as! ExchangeOrProtectionCell
                
                if(!isHeightZero){
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    if(indexPath.row == 0 && self.isTripProtectionEnabled){
                        cell.priceLabel.text = Constant.MyClassConstants.insurance
                        let priceString = "\(Constant.MyClassConstants.rentalFees[indexPath.row].insurance!.price)"
                        let priceArray = priceString.components(separatedBy: ".")
                        
                        cell.primaryPriceLabel.text = priceArray.first!
                        if((priceArray.last?.characters.count)! > 1) {
                            cell.fractionalPriceLabel.text = "\(priceArray.last!)"
                        }else{
                            cell.fractionalPriceLabel.text = "\(priceArray.last!)0"
                        }
                    }else{
                        cell.priceLabel.text = Constant.MyClassConstants.guestCertificateTitle
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
                    cell.fractionalPriceLabel.frame.origin.x = cell.periodLabel.frame.origin.x + cell.periodLabel.frame.size.width
                    
                }else{
                    isHeightZero = false
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = true
                    }
                }
                return cell
                
            case 3:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.promotionsDiscountCell, for: indexPath) as! PromotionsDiscountCell
                
                if(!isHeightZero){
                    for subviews in cell.subviews {
                        
                        subviews.isHidden = false
                    }
                    cell.discountLabel.text = recapSelectedPromotion
                    for promotion in recapPromotionsArray {
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
                return cell
                
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.totalCostCell, for: indexPath) as! TotalCostCell
                cell.priceLabel.text = String(Int(Float(Constant.MyClassConstants.rentalFees[0].total)))
                var targetString = String(Int(Float(Constant.MyClassConstants.rentalFees[0].total)))
                var priceString = "\(Constant.MyClassConstants.rentalFees[0].total)"
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
                cell.fractionalPriceLabel.frame.origin.x = cell.periodLabel.frame.origin.x + cell.periodLabel.frame.size.width
                
                

                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.termsConditionsCell, for: indexPath) as! ViewDetailsTBLcell
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.bookingCell, for: indexPath) as! ViewDetailsTBLcell
                return cell
                
            }
            
        }else{
            switch indexPath.section {
                
            case 0:
                switch indexPath.row{
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.headerCell, for: indexPath) as! ViewDetailsTBLcell
                    cell.resortDetailsButton.addTarget(self, action: #selector(self.resortDetailsClicked(_:)), for: .touchUpInside)
                    cell.resortImageView?.image = UIImage(named: Constant.assetImageNames.resortImage)
                    cell.resortName?.text = Constant.MyClassConstants.viewResponse.resort?.resortName
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.headerCell, for: indexPath) as! ViewDetailsTBLcell
                    return cell
                }
                
            case 1:
                
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
                    
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutPromotionCell", for: indexPath) as! CheckoutPromotionCell
                cell.setupCell(selectedPromotion: destinationPromotionSelected)
                cell.promotionSelectionCheckBox.tag = indexPath.row
                if cell.promotionSelectionCheckBox.isHidden {
                    cell.forwardArrowButton.addTarget(self, action: #selector(CheckOutIPadViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
                } else {
                    cell.promotionSelectionCheckBox.addTarget(self, action: #selector(CheckOutIPadViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
                }
                cell.selectionStyle = .none
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeOptionsCell, for: indexPath) as! ExchangeOptionsCell
                
                cell.selectionStyle = .none
                return cell
                
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.tripProtectionCell, for: indexPath)
                for subviews in cell.subviews {
                    subviews.removeFromSuperview()
                }
                
                cellWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 400))
                cellWebView.scrollView.isScrollEnabled = false
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                tapRecognizer.numberOfTapsRequired = 1
                tapRecognizer.delegate = self
                cellWebView.addGestureRecognizer(tapRecognizer)
                if(showInsurance){
                    let str = (Constant.MyClassConstants.rentalFees[indexPath.row].insurance?.insuranceOfferHTML!)!
                    cellWebView.loadHTMLString(str, baseURL: nil)
                }
                cellWebView.delegate = self
                cellWebView.backgroundColor = UIColor.gray
                cell.addSubview(cellWebView)
                
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
                if(Constant.MyClassConstants.selectedCreditCard.count > 0) {
                    let creditcard = Constant.MyClassConstants.selectedCreditCard[0]
                    let cardNumber = creditcard.cardNumber!
                    let last4 = cardNumber.substring(from:(cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
                    let cardType = Helper.cardTypeCodeMapping(cardType: (creditcard.typeCode!))
                    selectPamentMethodLabel.text = "\(cardType) \(Constant.MyClassConstants.endingIn) \(last4)"
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
                
            case 6:
                
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
                return cell
                
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreeToFeesCell, for: indexPath) as! SlideTableViewCell
                cell.agreeButton?.imageName = UIImage(named:Constant.assetImageNames.swipeArrowOrgImage)!
                cell.agreeButton?.tag = indexPath.section
                cell.feesTitleLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.acknowledgeAndAgreeString
                if(isAgreedToFees){
                    cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0)
                    cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0).cgColor
                    cell.agreeLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreedToFeesString
                    cell.agreeLabel.textColor = UIColor.white
                }else{
                    cell.agreeLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.slideToAgreeToFeesString
                }
                return cell
                
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreeToFeesCell, for: indexPath) as! SlideTableViewCell
                cell.agreeButton?.tag = indexPath.section
                cell.feesTitleLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.acceptedTermAndConditionString
                
                if(isAgreed){
                    cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0)
                    cell.agreeLabel.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0).cgColor
                    cell.agreeLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreedToFeesString
                    cell.agreeLabel.textColor = UIColor.white
                    cell.agreeButton?.imageName = UIImage(named:Constant.assetImageNames.checkMarkOn)!
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
                    cell.agreeLabel.text = Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.slideToAgreeAndPayString
                    cell.agreeLabel.backgroundColor = UIColor.white
                    cell.agreeLabel.layer.borderColor = UIColor.lightGray.cgColor
                    cell.agreeLabel.textColor = UIColor.lightGray
                }
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier:Constant.CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings.agreeToFeesCell, for: indexPath) as! SlideTableViewCell
                if(isAgreed){
                    cell.agreeLabel.backgroundColor = UIColor(colorLiteralRed: 170/255, green: 202/255, blue: 92/255, alpha: 1.0)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if(section != 0 && section < 8 && tableView.tag == 3) {
            
            if(section == 1 && !self.isPromotionsEnabled){
                return 0
            }else if(section == 2 && !self.isExchangeOptionEnabled){
                return 0
            }else if(section == 3 && !showInsurance){
                return 0
            }else if(section == 6 || section == 7){
                return 10
            }else{
                return 50
            }
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if(section != 0 && section < 8 && tableView.tag == 3) {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: checkoutTableView.frame.size.width, height: 50))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 10, width: checkoutTableView.frame.size.width - 40, height: 30)
            headerLabel.text  = Constant.MyClassConstants.checkOutScreenHeaderIPadTextArray[section]
            
            headerView.addSubview(headerLabel)
            if(section == 6 || section == 7){
                headerView.backgroundColor = UIColor(colorLiteralRed: 205/255, green: 204/255, blue: 208/255, alpha: 1.0)
            }else{
                headerView.backgroundColor = IUIKColorPalette.primary1.color
            }
            headerLabel.textColor = UIColor.white
            return headerView
            
        }
        else {
            
            return nil
        }
        
    }
}

extension CheckOutIPadViewController:UIGestureRecognizerDelegate{
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

extension CheckOutIPadViewController:UIWebViewDelegate {
    
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

extension CheckOutIPadViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.emailTextToEnter = "\(textField.text!)\(string)"
        
        if(self.emailTextToEnter.caseInsensitiveCompare((UserContext.sharedInstance.contact?.emailAddress)!) == ComparisonResult.orderedSame){
        }
        if(emailTextToEnter == UserContext.sharedInstance.contact?.emailAddress) {
            self.showUpdateEmail = false
            let indexPath = NSIndexPath(row: 0, section: 7)
            self.checkoutTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
}



