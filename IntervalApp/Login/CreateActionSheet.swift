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
    var alertsDictionary = NSMutableDictionary()
    var activeAlertCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat((UserContext.sharedInstance.contact?.memberships?.count)! * 100))
        self.tableView.frame = rect
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.bounds = rect
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat((UserContext.sharedInstance.contact?.memberships?.count)! * 100))
        self.tableView.frame = rect
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat((UserContext.sharedInstance.contact?.memberships?.count)! * 70))
        tableView.addConstraint(height);
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    // ***** Function called when we have found multiple membership and display all membership in list *****//
    
    func createActionSheet(_ viewController:UIViewController){
        
        tableViewController = viewController
        Constant.MyClassConstants.signInRequestedController = viewController
        if(Constant.MyClassConstants.signInRequestedController .isKind(of: LoginViewController.self)){
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.isUserInteractionEnabled = true
        self.tableView.allowsSelection = true
        if(viewController.isKind(of:GetawayAlertsIPhoneViewController.self)){
            self.tableView.tag = 100
            let height:NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat((UserContext.sharedInstance.contact?.memberships?.count)! * 100))
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
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: Constant.MyClassConstants.signInRequestedController .view)
        
        //***** Update the API session for the current access token *****//
        let context = UserContext.sharedInstance
        UserClient.putSessionsUser(context.accessToken, member: context.selectedMembership!,
        onSuccess:{
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: Constant.MyClassConstants.signInRequestedController .view)
            Constant.MyClassConstants.isLoginSuccessfull = true
            
            let Product = UserContext.sharedInstance.selectedMembership?.getProductWithHighestTier()
            
            // omniture tracking with event 2
            let userInfo: [String: String] = [
                Constant.omnitureEvars.eVar1 : (UserContext.sharedInstance.selectedMembership?.memberNumber!)!,
                Constant.omnitureEvars.eVar3 : "\(String(describing: Product?.productCode!))-\(String(describing: UserContext.sharedInstance.selectedMembership?.membershipTypeCode))",
                Constant.omnitureEvars.eVar4 : "",
                Constant.omnitureEvars.eVar5 : Constant.MyClassConstants.loginOriginationPoint,
                Constant.omnitureEvars.eVar6 : "",
                Constant.omnitureEvars.eVar7 : ""
            ]
            ADBMobile.trackAction(Constant.omnitureEvents.event2, data: userInfo)
            
            
    //***** Done!  Segue to the Home page *****//
    let contact = UserContext.sharedInstance.contact
        if(contact!.memberships!.count > 1) {
            Constant.MyClassConstants.signInRequestedController.dismiss(animated: true, completion: nil)
        }
            
        if(Constant.MyClassConstants.signInRequestedController.isKind(of:SignInPreLoginViewController.self)) {
         
       //  Constant.MyClassConstants.signInRequestedController.dismiss(animated: true, completion: nil)
            
           
       
        _ = self.navigationController!.navigationController!.popViewController(animated: true)
    

            
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
    }
    else {
         Constant.MyClassConstants.signInRequestedController.performSegue(withIdentifier: Constant.segueIdentifiers.dashboradSegueIdentifier, sender: nil)
    }

    //***** Getaway Alerts API call after successfull login *****//
    RentalClient.getAlerts(UserContext.sharedInstance.accessToken, onSuccess: { (response) in
        Constant.MyClassConstants.getawayAlertsArray = response
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        self.getStatusForAllAlerts()
                                        
        }) { (error) in
                                        
    }
    //Get user favorites.
    Helper.getUserFavorites()
      
    //***** Get upcoming trips for user *****//
    Helper.getUpcomingTripsForUser()
},
    onError:{(error) in
        SVProgressHUD.dismiss()
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
        RentalClient.getAlert(UserContext.sharedInstance.accessToken, alertId: alert.alertId!, onSuccess: { (response) in
            
            var alertVacationInfo = RentalAlert()
            alertVacationInfo = response
            self.alertsDictionary .setValue(alertVacationInfo, forKey: String(describing: alert.alertId!))
            //if(alert.enabled)!{
                self.searchVacationPressed(alert)
            //}else{
             //   print("Alert is inactive",alert.latestCheckInDate!,alert.earliestCheckInDate!)
            //}
            
        }) { (error) in
            
        }
        
    }
    
    func searchVacationPressed(_ alert : RentalAlert){
        var getawayAlert = RentalAlert()
        getawayAlert = self.alertsDictionary.value(forKey: String(describing: alert.alertId!)) as! RentalAlert
        
        let searchResortRequest = RentalSearchDatesRequest()
        searchResortRequest.checkInToDate = Helper.convertStringToDate(dateString:getawayAlert.latestCheckInDate!,format:Constant.MyClassConstants.dateFormat)
        searchResortRequest.checkInFromDate = Helper.convertStringToDate(dateString:getawayAlert.earliestCheckInDate!,format:Constant.MyClassConstants.dateFormat)
        searchResortRequest.resorts = getawayAlert.resorts
        searchResortRequest.destinations = getawayAlert.destinations
        
        if Reachability.isConnectedToNetwork() == true {
            if(UserContext.sharedInstance.accessToken != nil){

            RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess:{ (searchDates) in
                
                Constant.MyClassConstants.resortCodesArray = searchDates.resortCodes
                Constant.MyClassConstants.alertsResortCodeDictionary.setValue(searchDates.resortCodes, forKey: String(describing: alert.alertId!))
                Constant.MyClassConstants.alertsSearchDatesDictionary.setValue(searchDates.checkInDates, forKey: String(describing: alert.alertId!))
                
                if(searchDates.checkInDates.count == 0 || alert.alertId == 123456) {
                    
                }
                else {
                    Constant.MyClassConstants.activeAlertsArray.add(alert)
                }
                if(self.activeAlertCount < Constant.MyClassConstants.getawayAlertsArray.count - 1){
                    self.activeAlertCount = self.activeAlertCount + 1
                    self.getStatusForAllAlerts()
                }else{
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
                }
                }){ (error) in
                
            }
           }
        }else {
            
        }
    }
}


