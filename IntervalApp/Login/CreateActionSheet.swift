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
    
    var actionSheetTable: UITableView!
    var tableViewController = UIViewController()
    let dataSource = CommonMembership()
    var activeAlertCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let memberShipCount = Session.sharedSession.contact?.memberships?.count {
            
            let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat(memberShipCount * 100))
            self.tableView.frame = rect
            self.automaticallyAdjustsScrollViewInsets = false
            self.view.bounds = rect
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let membership = Session.sharedSession.contact?.memberships?.count {
            let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat(membership * 100))
            self.tableView.frame = rect
            let height: NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(membership * 70))
            tableView.addConstraint(height)
        }
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    // ***** Function called when we have found multiple membership and display all membership in list *****//
    
    func createActionSheet(_ viewController: UIViewController) {
        
        tableViewController = viewController
        Constant.MyClassConstants.signInRequestedController = viewController
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.isUserInteractionEnabled = true
        self.tableView.allowsSelection = true
        if viewController.isKind(of:GetawayAlertsIPhoneViewController.self) {
            self.tableView.tag = 100
            if let memberShipCount = Session.sharedSession.contact?.memberships?.count {
                
                let height: NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(memberShipCount * 100))
                self.tableView.addConstraint(height)
            }
        }
        let actionSheet: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 500)
        
        var attributedString = NSAttributedString(string: Constant.actionSheetAttributedString.selectMembership, attributes: [
            NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeue, size: 18) ?? 0
            ,
            NSForegroundColorAttributeName: UIColor.black
            ])
        
        if self.tableView.tag == 100 {
            attributedString = NSAttributedString(string: Constant.actionSheetAttributedString.noMatches, attributes: [
                NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeue, size: 18) ?? 0
                ,
                NSForegroundColorAttributeName: UIColor.black
                ])
        }
        
        let action: UIAlertAction = UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: UIAlertActionStyle.cancel, handler: nil)
        
        actionSheet.view.addSubview(self.tableView)
        actionSheet.setValue(attributedString, forKey: Constant.actionSheetAttributedString.attributedTitle)
        actionSheet.setValue(self, forKey: Constant.actionSheetAttributedString.contentViewController)
        actionSheet.addAction(action)
        if Constant.RunningDevice.deviceIdiom == .pad {
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
        if let selectedMemberShip = context.selectedMembership {
            
            //if let selectedMemberShip = context.selectedMemberShip
            UserClient.putSessionsUser(context.userAccessToken, member: selectedMemberShip,
                                       onSuccess: {[unowned self] in
                                        self.hideHudAsync()
                                        Constant.MyClassConstants.isLoginSuccessfull = true
                                        
                                        let Product = Session.sharedSession.selectedMembership?.getProductWithHighestTier()
                                        
                                        // omniture tracking with event 2
                                        if let memberNumber = Session.sharedSession.selectedMembership?.memberNumber {
       
                                            let userInfo: [String: String] = [
                                                Constant.omnitureEvars.eVar1: memberNumber,
                                                Constant.omnitureEvars.eVar3: "\(Product?.productCode ?? "")-\(Session.sharedSession.selectedMembership?.membershipTypeCode ?? "")",
                                                Constant.omnitureEvars.eVar4: "",
                                                Constant.omnitureEvars.eVar5: Constant.MyClassConstants.loginOriginationPoint,
                                                Constant.omnitureEvars.eVar6: "",
                                                Constant.omnitureEvars.eVar7: ""
                                            ]
                                            ADBMobile.trackAction(Constant.omnitureEvents.event2, data: userInfo)
                                        }
                                        
                                        //***** Done!  Segue to the Home page *****//
                                        
                                        if let memberships = Session.sharedSession.contact?.memberships {
                                            if !memberships.isEmpty {
                                                if let controller = Constant.MyClassConstants.signInRequestedController {
                                                    controller.dismiss(animated: true, completion: nil)
                                                }
                                            }
                                        }
                                        if let controller = Constant.MyClassConstants.signInRequestedController {
                                            if  controller.isKind(of:SignInPreLoginViewController.self) {
                                                controller.navigationController?.popViewController(animated: true)
                                                NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
                                            } else {
                                                NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
                                            }
                                        }
                                        
                                        //***** Favorites resort API call after successfull call *****//
                                        Helper.getUserFavorites {[weak self] error in
                                            if case .some = error {
                                                self?.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                                            }
                                        }
                                        //***** Get upcoming trips for user API call after successfull call *****//
                                        Helper.getUpcomingTripsForUser {[weak self] error in
                                            if case .some = error {
                                                self?.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                                            }
                                        }
                                        
                },
                                       onError: {_ in
                                        self.hideHudAsync()
                                        if let controller = Constant.MyClassConstants.signInRequestedController {
                                            controller.dismiss(animated: true, completion: nil)
                                        }
                                        
                                        self.presentAlert(with: Constant.AlertErrorMessages.loginFailed, message: "\(Constant.AlertPromtMessages.membershipFailureMessage) \(context.selectedMembership?.memberNumber ?? ""))")
               }
            )
        }

    }

}

// function to send omniture tracking event2
func sendOmnitureTrackCallForEvent2() {
    
    let product = Session.sharedSession.selectedMembership?.getProductWithHighestTier()
    
    // omniture tracking with event 2
    let userInfo = NSMutableDictionary()

    userInfo.addEntries(from: [Constant.omnitureEvars.eVar1 : Session.sharedSession.selectedMembership?.memberNumber ?? ""])
    
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar3 : "\(String(describing: product?.productCode))-\(String(describing: Session.sharedSession.selectedMembership?.membershipTypeCode))"])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar4 : ""])

    userInfo.addEntries(from: [Constant.omnitureEvars.eVar5: Constant.MyClassConstants.loginOriginationPoint])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar6: ""])
    
    if let expirationDate = product?.expirationDate {
        switch product?.productCode {
        case Constant.productCodeImageNames.basic?:
            userInfo.addEntries(from: [Constant.omnitureEvars.eVar7 :Helper.getUpcommingcheckinDatesDiffrence(date: expirationDate)])
            
        case Constant.productCodeImageNames.cig?:
            userInfo.addEntries(from: [Constant.omnitureEvars.eVar8 :Helper.getUpcommingcheckinDatesDiffrence(date: expirationDate)])
            
        case Constant.productCodeImageNames.gold?:
            userInfo.addEntries(from: [Constant.omnitureEvars.eVar9 :Helper.getUpcommingcheckinDatesDiffrence(date: expirationDate)])
            
        case Constant.productCodeImageNames.platinum?:
            userInfo.addEntries(from: [Constant.omnitureEvars.eVar10 :Helper.getUpcommingcheckinDatesDiffrence(date: expirationDate)])
            
        default:
            break
        }
        
    }

    userInfo.addEntries(from: [Constant.omnitureEvars.eVar11: Constant.MyClassConstants.activeAlertsArray.count])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar14: ""])
    if let _ = Session.sharedSession.contact?.memberships, let memberShipCount = Session.sharedSession.contact?.memberships?.count {
        userInfo.addEntries(from: [Constant.omnitureEvars.eVar16: memberShipCount > 0 ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no])
    } else {
        userInfo.addEntries(from:
            [Constant.omnitureEvars.eVar16: Constant.AlertPromtMessages.no])
    }
    
    var tripTypeString = [String]()
    if Constant.MyClassConstants.exchangeCounter > 0 {
        tripTypeString.append("\(Constant.omnitureCommonString.exchage)-\(Constant.MyClassConstants.exchangeCounter)")
    } else {
        tripTypeString.append("\(Constant.omnitureCommonString.exchage)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if Constant.MyClassConstants.getawayCounter > 0 {
        tripTypeString.append("\(Constant.omnitureCommonString.getaway)-\(Constant.MyClassConstants.getawayCounter)")
    } else {
        tripTypeString.append("\(Constant.omnitureCommonString.getaway)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if Constant.MyClassConstants.shortStayCounter > 0 {
         tripTypeString.append("\(Constant.omnitureCommonString.shortStay)-\(Constant.MyClassConstants.shortStayCounter)")
    } else {
        tripTypeString.append("\(Constant.omnitureCommonString.shortStay)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if Constant.MyClassConstants.acomodationCertificateCounter > 0 {
        tripTypeString.append("\(Constant.omnitureCommonString.acomodationCertificate)-\(Constant.MyClassConstants.acomodationCertificateCounter)")
    } else {
       tripTypeString.append("\(Constant.omnitureCommonString.acomodationCertificate)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if Constant.MyClassConstants.flightCounter > 0 {
        tripTypeString.append("\(Constant.omnitureCommonString.flightBooking)-\(Constant.MyClassConstants.flightCounter)")
    } else {
        tripTypeString.append("\(Constant.omnitureCommonString.flightBooking)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    if Constant.MyClassConstants.carRentalCounter > 0 {
        tripTypeString.append("\(Constant.omnitureCommonString.carRental)-\(Constant.MyClassConstants.carRentalCounter)")
    } else {
        tripTypeString.append("\(Constant.omnitureCommonString.carRental)-\(Constant.omnitureCommonString.notAvailable)")
    }
    
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar17 : tripTypeString.joined(separator: ", ")])
    userInfo.addEntries(from: [Constant.omnitureEvars.eVar27 : Session.sharedSession.contact?.contactId ?? 0])
    
    ADBMobile.trackAction(Constant.omnitureEvents.event2, data: userInfo as? [AnyHashable: Any])
}
