//
//  Membership.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/16/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class CommonMembership: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 100) {
            if((indexPath as NSIndexPath).row == 0) {
                return 150
            } else {
                return 50
            }
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contact = Session.sharedSession.contact
        return (contact?.memberships?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = Session.sharedSession.contact
        let membership = contact?.memberships![indexPath.row]
        let nib: [Any]? = Bundle.main.loadNibNamed(Constant.customCellNibNames.actionSheetTblCell, owner: nil, options: nil)
        let cell = nib![0] as! ActionSheetTblCell
        cell.membershipTextLabel.text = Constant.CommonLocalisedString.memberNumber
        cell.membershipNumber.text = membership?.memberNumber
        let Product = membership?.getProductWithHighestTier()
        let productcode = Product?.productCode
        cell.membershipName.text = Product?.productName
        cell.membershipName?.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
        if (Product != nil) {
            cell.memberImageView.image = UIImage(named: productcode!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        let contact = Session.sharedSession.contact
        let membership = contact?.memberships![indexPath.row]
        Session.sharedSession.selectedMembership = membership
        CreateActionSheet().membershipWasSelected(isForSearchVacation: false)
    }
}
