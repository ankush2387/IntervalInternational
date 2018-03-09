//
//  MemberShipViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import SVProgressHUD

class MemberShipViewController: UIViewController {
    
    //** Outlets
    @IBOutlet weak var tableView: UITableView!

    @IBAction func switchMemberShipButtonIsTapped(_ sender: UIButton) {
        CreateActionSheet()
    }
    
    /** Class variables */
    fileprivate let numberOfSection = 2
    fileprivate let numberOfRowInSection = 1
    var previousSelectedMembershipCellIndex: IndexPath?
    var ownershipArray = [Ownership]()
    var membershipProductsArray = [Product]()
    var contactInfo = Contact()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = Constant.ControllerTitles.memberShipViewController
        displayMenuButton()
        getContactMembershipInfo()
    }
    
    fileprivate func getContactMembershipInfo() {
        showHudAsync()
        if let contact = Session.sharedSession.contact {
            self.contactInfo = contact
        }
        
        if let memberships = contactInfo.memberships {
            Constant.MyClassConstants.membershipdetails = memberships
        }
        if let memberNo = Session.sharedSession.selectedMembership?.memberNumber {
            Constant.MyClassConstants.memberNumber = memberNo
        }
        guard let accessToken = Session.sharedSession.userAccessToken else { return }
        
        ClientAPI.sharedInstance.readMembership(for: accessToken, and: Session.sharedSession.selectedMembership?.memberNumber ?? "")
            .then { newMembership in
                Session.sharedSession.selectedMembership = newMembership
                if let membershipContacts = newMembership.contacts {
                    let contact = membershipContacts.filter {
                        $0.firstName == self.contactInfo.firstName && $0.lastName == self.contactInfo.lastName }.last
                    Session.sharedSession.contact?.isPrimary = contact?.isPrimary
                }
                if let contact = Session.sharedSession.contact {
                    self.contactInfo = contact
                }
                if let ownerships = newMembership.ownerships {
                    self.ownershipArray = ownerships
                }
                
                if let products = newMembership.products {
                    self.membershipProductsArray = products
                }
                
                self.membershipProductsArray.sort { $0.coreProduct && !$1.coreProduct } //sort Array coreProduct First Element
                //arrange array elements highestTier in second position
                if self.membershipProductsArray.count > 2 {
                    for (index, prod) in self.membershipProductsArray.enumerated()  where prod.highestTier == true {
                        self.membershipProductsArray.remove(at: index)
                        self.membershipProductsArray.insert(prod, at: 1)
                    }
                }
                self.tableView.reloadData()
                self.hideHudAsync()
            }
            .onError { [unowned self] error in
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
    }
    // MARK: Display menu button
    fileprivate func displayMenuButton() {
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named: "ic_menu"), style: .plain, target: rvc, action: #selector(rvc.revealToggle(_:)))
            menuButton.tintColor = .white
            
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func membershipWasSelected() {
        
        //***** Update the API session for the current access token *****//
        let context = Session.sharedSession
        UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
            Session.sharedSession.selectedMembership = membership
            if let membershipContacts = membership.contacts {
                Constant.MyClassConstants.membershipContactArray = membershipContacts
            } else { Constant.MyClassConstants.membershipContactArray.removeAll() }
            //***** Done!  Segue to the Home page *****//
            self.dismiss(animated: true, completion: nil)
            self.getContactMembershipInfo()
            },
        onError: {_ in
            self.presentAlert(with: Constant.AlertErrorMessages.loginFailed, message: "Please contact your servicing office.  Could not select membership \(String(describing: context.selectedMembership?.memberNumber))")
            }
        )
    }
   // MARK: create list of membership using action sheet
    fileprivate func CreateActionSheet() {
        
        let actionSheet: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let actionsheetViewController = UIViewController()
        let Height = CGFloat((Session.sharedSession.contact?.memberships?.count ?? 0) * 70)
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: Height)
    
        actionsheetViewController.preferredContentSize = rect.size
        let actionSheetTable = UITableView(frame: rect)
        actionSheetTable.register(UINib(nibName: Constant.customCellNibNames.actionSheetTblCell, bundle: nil), forCellReuseIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell)
        actionSheetTable.delegate = self
        actionSheetTable.dataSource = self
        actionSheetTable.tag = 3
        actionSheetTable.separatorStyle = UITableViewCellSeparatorStyle.none
        actionSheetTable.isUserInteractionEnabled = true
        actionSheetTable.allowsSelection = true
        
        actionsheetViewController.view.addSubview(actionSheetTable)
        actionsheetViewController.view.bringSubview(toFront: actionSheetTable)
        actionsheetViewController.view.isUserInteractionEnabled = true
        
        let attributedString = NSAttributedString(string: "Select Membership", attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 20),
            NSForegroundColorAttributeName: UIColor.black
            ])
        
        let action: UIAlertAction = UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: UIAlertActionStyle.cancel, handler: nil)
        actionSheet.setValue(attributedString, forKey: "attributedTitle")
        actionSheet.setValue(actionsheetViewController, forKey: "contentViewController")
        actionSheet.addAction(action)
        actionSheetTable.reloadData()
        self.present(actionSheet, animated: true, completion: nil)
    }
}
/** extension to implement table view datasource methods */
extension MemberShipViewController: UITableViewDataSource {
    /** Implement UITableView DataSource Methods */
 
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 3:
            return 1
        default:
            return numberOfSection
        }
    }
    // MARK: Number of Row in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 3:
            return Session.sharedSession.contact?.memberships?.count ?? 0
        default:
            if section == 1 {
                return ownershipArray.count
            } else {
                return numberOfRowInSection
            }
            
        }
    }
    // MARK: Cell for a row
    /** This function is used to return cell for a row */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.tag {
        case 3:
            guard let cell: ActionSheetTblCell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell, for: indexPath) as? ActionSheetTblCell else { return UITableViewCell() }
            
            if let memberships = Session.sharedSession.contact?.memberships {
                cell.membershipTextLabel.text = "Member No".localized()
                cell.membershipNumber.text = memberships[indexPath.row].memberNumber
                let product = memberships[indexPath.row].getProductWithHighestTier()
                if let productcode = product?.productCode {
                    cell.memberImageView.image = UIImage(named: productcode)
                }
                cell.membershipName.text = product?.productName
            }
            if Constant.MyClassConstants.memberNumber == cell.membershipNumber.text {
                cell.selectedImageView.image = #imageLiteral(resourceName: "Select-On")
                previousSelectedMembershipCellIndex = indexPath
            } else {
                cell.selectedImageView.image = #imageLiteral(resourceName: "Select-Off")
            }
            cell.delegate = self
            return cell
        default:
            if indexPath.section == 1 {
                guard let ownershipCell = tableView.dequeueReusableCell(withIdentifier: Constant.memberShipViewController.ownershipDetailCellIdentifier) as? OwnerShipDetailTableViewCell else { return UITableViewCell() }
                let ownership = ownershipArray[indexPath.row]
                ownershipCell.getCell(ownership: ownership)
                return ownershipCell
            } else {
                guard let membershipCell = tableView.dequeueReusableCell(withIdentifier: Constant.memberShipViewController.membershipDetailCellIdentifier) as? MemberShipDetailTableViewCell else { return UITableViewCell() }
                guard let contact = Session.sharedSession.contact else { return UITableViewCell() }
                if contact.memberships?.count == 1 {
                    membershipCell.switchMembershipButton.isHidden = true
                    membershipCell.activememberOutOfTotalMemberLabel.isHidden = true
                }
                membershipCell.getCell(contactInfo: self.contactInfo, products: membershipProductsArray)
                return membershipCell
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 && tableView.tag != 3 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            let seprator = Seprator(x: 0, y: 0, width: headerView.frame.size.width, height: 1)
                headerView.addSubview(seprator)
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 10, width: headerView.frame.size.width - 40, height: 20))
            titleLabel.text = "Ownerships".localized()
            titleLabel.textColor = .darkGray
            titleLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 18)
            headerView.addSubview(titleLabel)
            headerView.backgroundColor = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
            return headerView
        }
        return nil
    }
}
/*

extension for tableview delegate
*/
extension MemberShipViewController: UITableViewDelegate {
	/** This function is used to return Height for footer In section */
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return 0
	}
	
	/** This function is used to return Height for header In section */
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch section {
        case 0 :
            return 0
        case 1 :
            return 40
        default :
            return 0
        }

	}
	
	/** This function is used to return Height for a row at particular index In section */
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 3:
            return 70
            
        default:
            if indexPath.section == 0 {
                let extraViews = membershipProductsArray.count - 1
                return CGFloat((80 * extraViews) + 440)
            } else {
               return 332
            }
        }
	}
	
	//***** Custom cell delegate methods *****//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 3 {
            guard let cell = tableView.cellForRow(at: indexPath) as? ActionSheetTblCell else { return }
            cell.selectedImageView.image = #imageLiteral(resourceName: "Select-On")
            
            //change previously selected image
            if let previousIndex = previousSelectedMembershipCellIndex {
                if previousIndex != indexPath {
                    let previousCell = tableView.cellForRow(at: previousIndex) as? ActionSheetTblCell
                    previousCell?.selectedImageView.image = #imageLiteral(resourceName: "Select-Off")
                }
            }
            var membership: Membership?
            if let memberShips = Session.sharedSession.contact?.memberships {
                membership = memberShips[indexPath.row]
            }
            
            if Constant.MyClassConstants.memberNumber != membership?.memberNumber {
                self.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: Constant.memberShipViewController.switchMembershipAlertTitle, message: Constant.memberShipViewController.switchMembershipAlertMessage, preferredStyle: .actionSheet)
                let actionYes = UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                    self.showHudAsync()
                    Session.sharedSession.selectedMembership = membership
                    Constant.MyClassConstants.upcomingTripsArray.removeAll()
                    self.membershipWasSelected()
                })
                
                let actionCancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                
                alert.addAction(actionYes)
                alert.addAction(actionCancel)

                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
}
/*
extension for actionsheet table delegate
*/

extension MemberShipViewController: ActionSheetTblDelegate {
    
    func membershipSelectedAtIndex(_ index: Int) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
