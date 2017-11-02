//
//  CreateActionSheer.swift
//  IntervalApp
//
//  Created by Chetu on 15/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import SVProgressHUD


class CreateActionSheet: UITableViewController {
    
    var actionSheetTable : UITableView!
    var tableViewController = UIViewController()
    let dataSource = CommonMembership()
    var activeAlertCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat((Session.sharedSession.contact?.memberships?.count)! * 100))
        self.tableView.frame = rect
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.bounds = rect
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat((Session.sharedSession.contact?.memberships?.count)! * 100))
        self.tableView.frame = rect
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat((Session.sharedSession.contact?.memberships?.count)! * 70))
        tableView.addConstraint(height);
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    // ***** Function called when we have found multiple membership and display all membership in list *****//
    
    func createActionSheet(_ viewController:UIViewController){
        
        tableViewController = viewController
        Constant.MyClassConstants.signInRequestedController = viewController
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.isUserInteractionEnabled = true
        self.tableView.allowsSelection = true
        if(viewController.isKind(of:GetawayAlertsIPhoneViewController.self)){
            self.tableView.tag = 100
            let height:NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat((Session.sharedSession.contact?.memberships?.count)! * 100))
            self.tableView.addConstraint(height);
        }
        let actionSheet:UIAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 500)
        
        var attributedString = NSAttributedString(string: Constant.actionSheetAttributedString.selectMembership, attributes: [
            NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeue, size: 18)!
            ,
            NSForegroundColorAttributeName : UIColor.black
            ])
        
        if(self.tableView.tag == 100){
            attributedString = NSAttributedString(string: Constant.actionSheetAttributedString.noMatches, attributes: [
                NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeue, size: 18)!
                ,
                NSForegroundColorAttributeName : UIColor.black
                ])
        }
        
        let action:UIAlertAction = UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: UIAlertActionStyle.cancel, handler: nil)
        
        actionSheet.view.addSubview(self.tableView)
        actionSheet.setValue(attributedString, forKey: Constant.actionSheetAttributedString.attributedTitle)
        actionSheet.setValue(self, forKey: Constant.actionSheetAttributedString.contentViewController)
        actionSheet.addAction(action)
        if(Constant.RunningDevice.deviceIdiom == .pad){
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = self.view.bounds
        }
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    //***** Function called when we have found that user selected one of membership from list *****//
    func membershipWasSelected() {
        
        showHudAsync()
        
        //***** Update the API session for the current access token *****//
        let context = Session.sharedSession
        UserClient.putSessionsUser(context.userAccessToken, member: context.selectedMembership!,
        onSuccess:{
            self.hideHudAsync()
            Constant.MyClassConstants.isLoginSuccessfull = true
            
            let Product = Session.sharedSession.selectedMembership?.getProductWithHighestTier()
            
            // omniture tracking with event 2
            let userInfo: [String: String] = [
                Constant.omnitureEvars.eVar1 : (Session.sharedSession.selectedMembership?.memberNumber!)!,
                Constant.omnitureEvars.eVar3 : "\(String(describing: Product?.productCode!))-\(String(describing: Session.sharedSession.selectedMembership?.membershipTypeCode))",
                Constant.omnitureEvars.eVar4 : "",
                Constant.omnitureEvars.eVar5 : Constant.MyClassConstants.loginOriginationPoint,
                Constant.omnitureEvars.eVar6 : "",
                Constant.omnitureEvars.eVar7 : ""
            ]
            ADBMobile.trackAction(Constant.omnitureEvents.event2, data: userInfo)
            
            
    //***** Done!  Segue to the Home page *****//
    let contact = Session.sharedSession.contact
        if(contact!.memberships!.count > 1) {
            Constant.MyClassConstants.signInRequestedController.dismiss(animated: true, completion: nil)
        }
          if(Constant.MyClassConstants.signInRequestedController.isKind(of:SignInPreLoginViewController.self)) {
         Constant.MyClassConstants.signInRequestedController.navigationController?.popViewController(animated: true)
           // Constant.MyClassConstants.signInRequestedController.dismiss(animated: true, completion: {
            
           // })
            
         NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
    }
    else {
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
    }
            
    //***** Get upcoming trips for user *****//
    Helper.getUpcomingTripsForUser()


    //***** Getaway Alerts API call after successfull login *****//
    RentalClient.getAlerts(Session.sharedSession.userAccessToken, onSuccess: { (response) in
        Constant.MyClassConstants.getawayAlertsArray = response
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        self.getStatusForAllAlerts()
                                        
        }) { (error) in
                                        
    }
    //Get user favorites.
    Helper.getUserFavorites()
      
  },
    onError:{(error) in
        self.hideHudAsync()
        Constant.MyClassConstants.signInRequestedController.dismiss(animated: true, completion: nil)
        SimpleAlert.alert(Constant.MyClassConstants.signInRequestedController, title:Constant.AlertErrorMessages.loginFailed, message: "\(Constant.AlertPromtMessages.membershipFailureMessage) \(String(describing: context.selectedMembership?.memberNumber))")
            }
        )
    }
    
    func getStatusForAllAlerts(){
        if(Constant.MyClassConstants.getawayAlertsArray.count > 0){
            self.callForIndividualAlert(Constant.MyClassConstants.getawayAlertsArray[activeAlertCount])
        }
    }
    
    func callForIndividualAlert(_ alert:RentalAlert){
        RentalClient.getAlert(Session.sharedSession.userAccessToken, alertId: alert.alertId!, onSuccess: { (response) in
            
            var alertVacationInfo = RentalAlert()
            alertVacationInfo = response
            Constant.MyClassConstants.alertsDictionary.setValue(alertVacationInfo, forKey: String(describing: alert.alertId!))
            self.searchVacationPressed(alert)
        }) { (error) in
            intervalPrint(alert.alertId)
            if(self.activeAlertCount < Constant.MyClassConstants.getawayAlertsArray.count - 1){
            self.activeAlertCount = self.activeAlertCount + 1
                self.getStatusForAllAlerts()
            }
        }
        
    }
    
    func searchVacationPressed(_ alert : RentalAlert){
        var getawayAlert = RentalAlert()
        getawayAlert = Constant.MyClassConstants.alertsDictionary.value(forKey: String(describing: alert.alertId!)) as! RentalAlert
        
        let searchResortRequest = RentalSearchDatesRequest()
        searchResortRequest.checkInToDate = Helper.convertStringToDate(dateString:getawayAlert.latestCheckInDate!,format:Constant.MyClassConstants.dateFormat)
        searchResortRequest.checkInFromDate = Helper.convertStringToDate(dateString:getawayAlert.earliestCheckInDate!,format:Constant.MyClassConstants.dateFormat)
        searchResortRequest.resorts = getawayAlert.resorts
        searchResortRequest.destinations = getawayAlert.destinations
        Constant.MyClassConstants.dashBoardAlertsArray = Constant.MyClassConstants.getawayAlertsArray
        
        if Reachability.isConnectedToNetwork() == true {
            if(Session.sharedSession.userAccessToken != nil){

            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: searchResortRequest, onSuccess:{ (searchDates) in
                
                Constant.MyClassConstants.resortCodesArray = searchDates.resortCodes
                Constant.MyClassConstants.alertsResortCodeDictionary.setValue(searchDates.resortCodes, forKey: String(describing: alert.alertId!))
                Constant.MyClassConstants.alertsSearchDatesDictionary.setValue(searchDates.checkInDates, forKey: String(describing: alert.alertId!))
                
                if(searchDates.checkInDates.count == 0 || alert.alertId == 123456) {
                    for (index,selectedAlert) in Constant.MyClassConstants.getawayAlertsArray.enumerated(){
                        if(alert.alertId == selectedAlert.alertId){
                            Constant.MyClassConstants.dashBoardAlertsArray.remove(at: index)
                        }
                    }
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
                }
                else {
                    if Constant.MyClassConstants.activeAlertsArray.count < 1 { //TODO - JHON: forcing alerts count to be one. fix when push notifications is working. 
                        Constant.MyClassConstants.activeAlertsArray.add(alert)
                    }
                }
                if(self.activeAlertCount < Constant.MyClassConstants.getawayAlertsArray.count - 1){
                    self.activeAlertCount = self.activeAlertCount + 1
                    self.getStatusForAllAlerts()
                }else{
                    intervalPrint(Constant.MyClassConstants.activeAlertsArray, Constant.MyClassConstants.alertsSearchDatesDictionary, Constant.MyClassConstants.alertsResortCodeDictionary)
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
                    
                    Constant.MyClassConstants.isEvent2Ready = Constant.MyClassConstants.isEvent2Ready + 1
                    if(Constant.MyClassConstants.isEvent2Ready > 1) {
                        
                        sendOmnitureTrackCallForEvent2()
                    }
                }
                }){ (error) in
                    
                    Constant.MyClassConstants.isEvent2Ready = Constant.MyClassConstants.isEvent2Ready + 1
                    if(Constant.MyClassConstants.isEvent2Ready > 1) {
                        
                        sendOmnitureTrackCallForEvent2()
                    }
            }
           }
        }else {
            
        }
    }
}

// function to send omniture tracking event2
func sendOmnitureTrackCallForEvent2() {
    
    let Product = Session.sharedSession.selectedMembership?.getProductWithHighestTier()
    
    // omniture tracking with event 2
    let userInfo = NSMutableDictionary()
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar1 : (Session.sharedSession.selectedMembership?.memberNumber) as Any])
    
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar3 : "\(Product?.productCode)-\(Session.sharedSession.selectedMembership?.membershipTypeCode)"])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar4 : ""])
    
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar5 : Constant.MyClassConstants.loginOriginationPoint])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar6 :""])
    
    switch Product?.productCode {
        
    case Constant.productCodeImageNames.basic?:
        userInfo.addEntries(from: [Constant.omnitureEvars.eVar7 :Helper.getUpcommingcheckinDatesDiffrence(date: (Product?.expirationDate!)!)])
        
        
    case Constant.productCodeImageNames.cig?:
        userInfo.addEntries(from: [Constant.omnitureEvars.eVar8 :Helper.getUpcommingcheckinDatesDiffrence(date: (Product?.expirationDate!)!)])
        
    case Constant.productCodeImageNames.gold?:
        userInfo.addEntries(from: [Constant.omnitureEvars.eVar9 :Helper.getUpcommingcheckinDatesDiffrence(date: (Product?.expirationDate!)!)])
        
    case Constant.productCodeImageNames.platinum?:
        userInfo.addEntries(from: [Constant.omnitureEvars.eVar10 :Helper.getUpcommingcheckinDatesDiffrence(date: (Product?.expirationDate!)!)])
        
    default:
        break
    }
    
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar11 :Constant.MyClassConstants.activeAlertsArray.count])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar14 :""])
    if let meberships = Session.sharedSession.contact?.memberships{
         userInfo.addEntries(from: [Constant.omnitureEvars.eVar16 :(Session.sharedSession.contact?.memberships?.count)! > 0 ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no])
    }else{
        userInfo.addEntries(from:
            [Constant.omnitureEvars.eVar16 : Constant.AlertPromtMessages.no])
    }
   
    var tripTypeString = ""
    if(Constant.MyClassConstants.exchangeCounter > 0) {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.exchage)-\(Constant.MyClassConstants.exchangeCounter)")
    }
    else {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.exchage)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if(Constant.MyClassConstants.getawayCounter > 0) {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.getaway)-\(Constant.MyClassConstants.getawayCounter)")
    }
    else {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.getaway)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if(Constant.MyClassConstants.shortStayCounter > 0) {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.shortStay)-\(Constant.MyClassConstants.shortStayCounter)")
    }
    else {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.shortStay)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if(Constant.MyClassConstants.acomodationCertificateCounter > 0) {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.acomodationCertificate)-\(Constant.MyClassConstants.acomodationCertificateCounter)")
    }
    else {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.acomodationCertificate)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if(Constant.MyClassConstants.flightCounter > 0) {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.flightBooking)-\(Constant.MyClassConstants.flightCounter)")
    }
    else {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.flightBooking)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if(Constant.MyClassConstants.carRentalCounter > 0) {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.carRental)-\(Constant.MyClassConstants.carRentalCounter)")
    }
    else {
        tripTypeString = tripTypeString.appending("\(Constant.omnitureCommonString.carRental)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar17 :tripTypeString])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar27 :Session.sharedSession.contact?.contactId as Any])
    
    intervalPrint(userInfo)
    
    
    ADBMobile.trackAction(Constant.omnitureEvents.event2, data: userInfo as! [AnyHashable : Any])

}

