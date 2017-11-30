//
//  MembershipIPadViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/20/16.
//  Copyright © 2016 Interval International. All rights reserved.r
//

import UIKit
import DarwinSDK

class MembershipIPadViewController: UIViewController {
    /** Outlets */
    @IBOutlet weak var tableView: UITableView!
    /** Class variables */
    fileprivate let numberOfSection = 2
    fileprivate let numberOfRowInSection = 1
    fileprivate var previousSelectedMembershipCellIndex: IndexPath?
    fileprivate var ownershipArray = [Ownership]()
    fileprivate var membershipProductsArray = [Product]()
    fileprivate var contactInfo = Contact()
    
    /**
     Show action sheet.
     - parameter sender: sender UIbutton reference.
     - returns : No return value.
     */
    @IBAction func switchMemberShipButtonIsTapped(_ sender: UIButton) {
        let actionSheet: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let actionsheetViewController = UIViewController()
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 300)
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
            NSFontAttributeName : UIFont.systemFont(ofSize: 20),
            NSForegroundColorAttributeName :UIColor.black
            ])
        
        let action: UIAlertAction = UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: UIAlertActionStyle.cancel, handler: nil)
        
        actionSheet.setValue(attributedString, forKey: "attributedTitle")
        actionSheet.setValue(actionsheetViewController, forKey: "contentViewController")
        actionSheet.addAction(action)
        
        actionSheet.popoverPresentationController?.sourceView = self.tableView
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2 + sender.bounds.width, y: sender.bounds.origin.y + sender.bounds.height, width: sender.bounds.width, height: 100)
        // this is the center of the screen currently but it can be any point in the view
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayMenuButton()
        title = Constant.ControllerTitles.memberShipViewController
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
        UserClient.getCurrentMembership(Session.sharedSession.userAccessToken, onSuccess: { (membership) in
            if let ownerships = membership.ownerships {
                self.ownershipArray = ownerships
            }
            if let products = membership.products {
                self.membershipProductsArray = products
            }
            self.hideHudAsync()
            self.membershipProductsArray.sort { $0.coreProduct && !$1.coreProduct }
            self.tableView.reloadData()
        }) {[unowned self] _ in
            self.hideHudAsync()
             self.presentAlert(with: "Membership Error".localized(), message:"Unable to get membership from server. Please try again!".localized())
        }
    }
    
    // MARK: Display menu button
    /**
     Display Hamburger menu
     - parameter  No parameter :
     - returns : No return Value
     */
    fileprivate func displayMenuButton() {
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:"ic_menu"), style: .plain, target: rvc, action:#selector(rvc.revealToggle(_:)))
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
        
        UserClient.putSessionsUser(context.userAccessToken, member: context.selectedMembership!,
           onSuccess: {
            //***** Done!  Segue to the Home page *****//
            self.dismiss(animated: true, completion: nil)
            self.getContactMembershipInfo()
            //***** Getaway Alerts API call after successfull login *****//
            Helper.getAllAlerts {[unowned self] error in
                if case .some = error {
                    self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                    }
                }
        },
       onError: {[unowned self] _ in
        self.hideHudAsync()
        self.presentAlert(with: Constant.AlertErrorMessages.loginFailed, message: "Please contact your servicing office.  Could not select membership \(String(describing: context.selectedMembership?.memberNumber))")

            }
        )
    }
}
/** extension to implement table view datasource methods */
extension MembershipIPadViewController: UITableViewDataSource {
    /** Implement UITableView DataSource Methods */
    
    // MARK: Number of section in Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 3:
            return 1
        default:
            return numberOfSection
        }
    }
    // MARK: Number of Row in a section
    /** This function is used to return number of row in a section */
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
            var membership: Membership?
            if let memberShips = Session.sharedSession.contact?.memberships {
                membership = memberShips[indexPath.row]
            }
            
            cell.memberImageView.image = UIImage(named: "")
            cell.membershipTextLabel.text = "Member No"
            cell.membershipNumber.text = membership?.memberNumber
            let Product = membership?.getProductWithHighestTier()
            let productcode = Product?.productCode
            cell.membershipName.text = Product?.productName
            cell.memberImageView.image = UIImage(named: productcode!)
            if Constant.MyClassConstants.memberNumber == cell.membershipNumber.text {
                cell.selectedImageView.image = UIImage(named: "Select-On")
                previousSelectedMembershipCellIndex = indexPath
            } else {
                cell.selectedImageView.image = UIImage(named: "Select-Off")
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
                if let memberShips = Session.sharedSession.contact?.memberships {
                    if memberShips.count == 1 {
                        membershipCell.switchMembershipButton.isHidden = true
                        membershipCell.activememberOutOfTotalMemberLabel.isHidden = true
                    }
                }
            
            membershipCell.getCell(contactInfo: self.contactInfo, products: membershipProductsArray)
            return membershipCell
        }
    }
}
    
    /** This function is used to return  header In section */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 && tableView.tag != 3 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            let seprator = UIView(frame:CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 1))
            seprator.backgroundColor = .lightGray
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
extension MembershipIPadViewController: UITableViewDelegate {
    /** This function is used to return Height for footer In section */
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    /** This function is used to return Height for a row at particular index In section */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 3:
            return 70
        default:
            if indexPath.section == 0 {
                let extraViews = membershipProductsArray.count - 1
                return CGFloat((80 * extraViews) + 240)
            } else {
                return 427
            }
        }
    }
    
    /** This function is used to return Height for header In section */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    //***** Custom cell delegate methods *****//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 3 {
            guard let cell = tableView.cellForRow(at: indexPath) as? ActionSheetTblCell else { return }
            cell.selectedImageView.image = UIImage(named: "Select-On")
            
            //change previously selected image
            if let previousIndex = previousSelectedMembershipCellIndex {
                if previousIndex != indexPath {
                    let previousCell = tableView.cellForRow(at: previousIndex) as? ActionSheetTblCell
                    previousCell?.selectedImageView.image = UIImage(named: "Select-Off")
                }
            }
            var membership: Membership?
            if let memberShips = Session.sharedSession.contact?.memberships {
                membership = memberShips[indexPath.row]
            }
            if Constant.MyClassConstants.memberNumber != membership?.memberNumber {
                self.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: Constant.memberShipViewController.switchMembershipAlertTitle, message: Constant.memberShipViewController.switchMembershipAlertMessage, preferredStyle: .actionSheet)
                let actionYes = UIAlertAction(title: "Yes", style: .destructive, handler: { (response) in
                    self.showHudAsync()
                    Session.sharedSession.selectedMembership = membership
                    self.membershipWasSelected()
                })
                
                let actionCancel = UIAlertAction(title: "No", style: .default, handler:nil)
                
                alert.addAction(actionYes)
                alert.addAction(actionCancel)
                alert.modalPresentationStyle = .popover
                alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

/*
 extension for actionsheet table delegate
 */
extension MembershipIPadViewController: ActionSheetTblDelegate {
    
    func membershipSelectedAtIndex(_ index: Int) {
        dismiss(animated: true)
    }
}
