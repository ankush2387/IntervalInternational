//
//  MemberShipDetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
class MemberShipDetailTableViewCell: UITableViewCell {
    //Outlets
    @IBOutlet weak var contactnameInfoLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var loginInfoLabel: UILabel!
    @IBOutlet weak var loginIdLabel: UILabel!
    @IBOutlet weak var emailInfoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var memberNumberInfoLabel: UILabel!
    @IBOutlet weak var memberNumberLabel: UILabel!
    @IBOutlet weak var memberSinceInfoLabel: UILabel!
    @IBOutlet weak var memberSinceDateLabel: UILabel!
    @IBOutlet weak var contactInfoMainView: UIView!
    @IBOutlet weak var memberInfoMainView: UIView!
    @IBOutlet weak var switchMembershipButton: IUIKButton!
    @IBOutlet weak var activememberOutOfTotalMemberLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    //MARK:get MembershipCell using informations
    /**
        Configure Cell Components.
        - parameter membershipDetailDictionary : Dictionary with String key and String Value.
        - returns : No value is return
    */
    func getCell(contactInfo: Contact){
        self.setPropertiesTocellElements()
        
        var firstName = ""
        var lastName = ""
        var loginID = ""
        var emailAddress = ""
        var status = ""
        var dateString = ""
        var membershipsAmount = 0
        
        if let name = contactInfo.firstName {
            firstName = name
        }
        
        if let lastname = contactInfo.lastName {
            lastName = lastname
        }
        
        if let login = contactInfo.userName {
            loginID = login
        }
        
        if let email = contactInfo.emailAddress {
            emailAddress = email
        }
        
        if let memberStatus = contactInfo.status {
            status = memberStatus
        }
        
        if let memberSinceDate = contactInfo.lastVerifiedDate {
            dateString = Helper.convertDateToString(date: memberSinceDate, format: "dd/MM/YYYY")
        }
        
        if let count = contactInfo.memberships?.count {
            membershipsAmount = count
        }
        
        
        self.updateCell(contactName: "\(firstName) \(lastName)", loginID: loginID, email: emailAddress, status: status, date: dateString, memberships: membershipsAmount)
        
        
    }
    //MARK:Update value according to server response
    /**
        Update label text.
    
        - parameter membershipDetailDictionary: Dictionary with String Key and String Value.
        - returns: No return value.
    */
    fileprivate func updateCell(contactName: String, loginID: String, email: String, status: String, date: String, memberships: Int){
        
        // Update label text
        contactnameInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.contactnameInfoLabelText
//        activeLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.activeLabelText
        loginInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.loginInfoLabelText
         emailInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.emailInfoLabelText
        memberNumberInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.memberNumberInfoLabelText
        switchMembershipButton.setTitle(Constant.memberShipViewController.membershipDetailTableViewCell.switchMembershipButtonTitle, for: .normal)
        activememberOutOfTotalMemberLabel.text = "1 of \(memberships)"
        
        contactNameLabel.text = contactName
         loginIdLabel.text = loginID
         emailLabel.text = email
         memberNumberLabel.text = Constant.MyClassConstants.memberNumber
         memberSinceDateLabel.text = date
        activeLabel.text = status
        
    }
    //MARK:set commonPrperties to cell
    /**
    Set  properties to Cell components
    - parameter No parameter:
    - returns : No return value
    */
    fileprivate func setPropertiesTocellElements(){
        
        self.switchMembershipButton.layer.cornerRadius = 4
        
        //ContactInfo Main View Properties
        
        Helper.applyShadowOnUIView(view: contactInfoMainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1)
        
        // memberInfoMainView Properties
        
        memberInfoMainView.layer.cornerRadius = 4
        contactInfoMainView.layer.cornerRadius = 4
        //cardInfoMainView Properties
        contactnameInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        contactNameLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        activeLabel.textColor = UIColor(rgb:IUIKColorPalette.active.rawValue)
        loginInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        loginIdLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        emailInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        emailLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        memberNumberInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        memberNumberLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        memberSinceInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        memberSinceDateLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)

        switchMembershipButton.backgroundColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
