//
//  MemberShipViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class MemberShipViewController: UIViewController {
    /** Outlets */
    @IBOutlet weak var tableView: UITableView!
    /**
        Show action sheet.
        - parameter sender: sender UIbutton reference.
        - returns : No return value.
    */
    @IBAction func switchMemberShipButtonIsTapped(_ sender: UIButton) {
        CreateActionSheet()
    }
    
    
    
    /** Class variables */
    fileprivate let numberOfSection = 2
    //private let membershipDetailCellIdentifier = "membershipDetailCell"
    //private let ownershipDetailCellIdentifier = "ownershipDetailCell"
    fileprivate let numberOfRowInSection = 1
    var memberDetailDictionary = [String:String]()
    var previousSelectedMembershipCellIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.memberShipViewController
        
        self.displayMenuButton()
        
        UserClient.getCurrentProfile(UserContext.sharedInstance.accessToken, onSuccess: { (membership) in
            
           Constant.MyClassConstants.membershipdetails = membership.memberships!
           
             for memberdetails  in Constant.MyClassConstants.membershipdetails{
                
                 Constant.MyClassConstants.memberNumber =  memberdetails.memberNumber
            }
        
        },
                                     
         onError: {(error) in
            
       
        })
        
       // Update Membership Dictionary
        memberDetailDictionary.updateValue("Alex Redendo", forKey: "contactname")
        memberDetailDictionary.updateValue("ARedendo", forKey: "loginid")
        memberDetailDictionary.updateValue("Ar@test.com", forKey: "email")
        let membership = UserContext.sharedInstance.selectedMembership
        memberDetailDictionary.updateValue((membership?.memberNumber)!, forKey: "membernumber")
        memberDetailDictionary.updateValue("26/02/2013", forKey: "memberdate")
        memberDetailDictionary.updateValue("26/03/2020", forKey: "membershipexpirationdate")
        memberDetailDictionary.updateValue("Interval Platinum", forKey: "cardname")
        memberDetailDictionary.updateValue("26/03/2020", forKey: "cardexpiration")
        memberDetailDictionary.updateValue("Residance le Dimendo", forKey: "placename")
        memberDetailDictionary.updateValue("Residance le Dimendo", forKey: "placeaddress")
        memberDetailDictionary.updateValue("RLD", forKey: "placecode")
        memberDetailDictionary.updateValue("6,Bedroom", forKey: "bedroomdetail")
        memberDetailDictionary.updateValue("29", forKey: "weeknumber")
        
    }
    
    //MARK:Display menu button
    /** 
    Display Hamburger menu
    - parameter  No parameter :
    - returns : No return Value
    */
    fileprivate func displayMenuButton(){
        if let rvc = self.revealViewController() {
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:"ic_menu"), style: .plain, target: rvc, action:#selector(rvc.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            
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
        let context = UserContext.sharedInstance
        
        UserClient.putSessionsUser(context.accessToken, member: context.selectedMembership!,
                                    onSuccess:{
                                        
            //***** Done!  Segue to the Home page *****//
                                        
            self.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            },
        onError:{(error) in
            logger.error("Could not set membership in Darwin API Session: \(error.description)")
            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.loginFailed, message:"Please contact your servicing office.  Could not select membership \(context.selectedMembership?.memberNumber)")
            }
        )
    }

    
   //MARK:create list of membership using action sheet
    
    /** 
    Create membership list using action sheet 
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func CreateActionSheet(){
        
        
        let actionSheet:UIAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        
        let actionsheetViewController = UIViewController()
         let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat((UserContext.sharedInstance.contact?.memberships?.count)! * 70))
//        let rect1 = CGRectMake(0, 0, self.view.bounds.width - 20, CGFloat(self.view.bounds.height/2))
        
        
        
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
            NSForegroundColorAttributeName : UIColor.black
            ])
        
        let action:UIAlertAction = UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: UIAlertActionStyle.cancel, handler: nil)
        
        actionSheet.setValue(attributedString, forKey: "attributedTitle")
        actionSheet.setValue(actionsheetViewController, forKey: "contentViewController")
        actionSheet.addAction(action)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}
/** extension to implement table view datasource methods */
extension MemberShipViewController:UITableViewDataSource{
    /** Implement UITableView DataSource Methods */
     
    //MARK:Number of section in Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    //MARK:Number of Row in a section
    /** This function is used to return number of row in a section */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 3) {
            
            let contact = UserContext.sharedInstance.contact
            return (contact?.memberships?.count)!
            
        }
        else if section == 1
        {
            return numberOfRowInSection
        }
        else
        {
            return numberOfRowInSection
        }
    }
    //MARK:Cell for a row
    /** This function is used to return cell for a row */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var membershipCell:MemberShipDetailTableViewCell?
        var ownershipCell:OwnerShipDetailTableViewCell?
        if(tableView.tag == 3) {
            
            let contact = UserContext.sharedInstance.contact
            let membership = contact?.memberships![indexPath.row]
            
            let cell: ActionSheetTblCell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell, for: indexPath) as! ActionSheetTblCell
            cell.membershipTextLabel.text = "Member No"
            cell.membershipNumber.text = membership?.memberNumber
            let Product = membership?.getProductWithHighestTier()
            let productcode = Product?.productCode
            cell.membershipName.text = Product?.productName
            cell.memberImageView.image = UIImage(named: productcode!)
            if memberDetailDictionary["membernumber"] == cell.membershipNumber.text {
                cell.selectedImageView.image = UIImage(named: "Select-On")
                previousSelectedMembershipCellIndex = indexPath
            } else {
                cell.selectedImageView.image = UIImage(named: "Select-Off")
            }
            
            
            cell.delegate = self

            return cell
            
        }
        else if (indexPath as NSIndexPath).section == 1{
            ownershipCell = tableView.dequeueReusableCell(withIdentifier: Constant.memberShipViewController.ownershipDetailCellIdentifier) as? OwnerShipDetailTableViewCell
            ownershipCell?.getCell(self.memberDetailDictionary)
            return ownershipCell!
        }
        else{
            membershipCell = tableView.dequeueReusableCell(withIdentifier: Constant.memberShipViewController.membershipDetailCellIdentifier) as? MemberShipDetailTableViewCell
            let contact = UserContext.sharedInstance.contact
                if contact!.memberships!.count == 1 {
            membershipCell?.switchMembershipButton.isHidden = true
                }
            membershipCell?.getCell(self.memberDetailDictionary)
            membershipCell?.contactNameLabel.text = Constant.MyClassConstants.memberNumber
            return membershipCell!
        }
        
    }
    
    /** This function is used to return title for header In section */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if section == 1 && tableView.tag != 3{
            title = Constant.memberShipViewController.ownershipHeaderTitletext
        }
        return title
    }
}
/*

extension for tableview delegate
*/
extension MemberShipViewController:UITableViewDelegate{
	/** This function is used to return Height for footer In section */
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1
	}
	
	/** This function is used to return Height for header In section */
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0{
			return 0
		}
		else{
			return 30
		}
	}
	
	/** This function is used to return Height for a row at particular index In section */
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(tableView.tag == 3) {
			
			return 70
		}
		else if (indexPath as NSIndexPath).section == 0{
			return 550
		}
		else{
			return 332
		}
	}
	
	//***** Custom cell delegate methods *****//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 3 {
            guard let cell = tableView.cellForRow(at: indexPath) as? ActionSheetTblCell else { return }
            cell.selectedImageView.image = UIImage(named: "Select-On")
            
            //change previously selected image
            if let previousIndex = previousSelectedMembershipCellIndex {
                if previousIndex != indexPath{
                    let previousCell = tableView.cellForRow(at: previousIndex) as? ActionSheetTblCell
                    previousCell?.selectedImageView.image = UIImage(named: "Select-Off")
                }
            }

            let contact = UserContext.sharedInstance.contact
            let membership = contact?.memberships![indexPath.row]
            
            if memberDetailDictionary["membernumber"] != membership?.memberNumber{
                self.dismiss(animated: true, completion: nil)
                print("Same Membership")
                let alert = UIAlertController(title: Constant.memberShipViewController.switchMembershipAlertTitle, message: Constant.memberShipViewController.switchMembershipAlertMessage, preferredStyle: .actionSheet)
                let actionYes = UIAlertAction(title: "Yes", style: .destructive, handler: { (response) in
                    print("Continue")
                    self.memberDetailDictionary.updateValue((membership?.memberNumber)!, forKey:"membernumber" )
                    UserContext.sharedInstance.selectedMembership = membership
                    self.membershipWasSelected()
                })
                
                let actionCancel = UIAlertAction(title: "No", style: .cancel, handler: { (response) in
                    print("Cancel")
                })
                
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
extension MemberShipViewController:ActionSheetTblDelegate {
    
    func membershipSelectedAtIndex(_ index: Int) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


