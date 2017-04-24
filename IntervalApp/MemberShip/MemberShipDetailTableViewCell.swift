//
//  MemberShipDetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
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
    @IBOutlet weak var membershipInfoLabel: UILabel!
    @IBOutlet weak var memberShipExpirationdateLabel: UILabel!
    @IBOutlet weak var memberCardImageView: UIImageView!
    @IBOutlet weak var memberCardInfoLabel: UILabel!
    @IBOutlet weak var memberCardExpirationDateLabel: UILabel!
    @IBOutlet weak var contactInfoMainView: UIView!
    @IBOutlet weak var memberInfoMainView: UIView!
    @IBOutlet weak var membershipInfoMainView: UIView!
    @IBOutlet weak var cardInfoMainView: UIView!
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
    func getCell(_ membershipDetailDictionary:[String:String]){
        self.setPropertiesTocellElements()
        self.updateCell(membershipDetailDictionary)
    }
    //MARK:Update value according to server response
    /**
        Update label text.
    
        - parameter membershipDetailDictionary: Dictionary with String Key and String Value.
        - returns: No return value.
    */
    fileprivate func updateCell(_ membershipDetailDictionary:[String:String]){
        
        // Update label text
        contactnameInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.contactnameInfoLabelText
        activeLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.activeLabelText
        loginInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.loginInfoLabelText
         emailInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.emailInfoLabelText
        memberNumberInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.memberNumberInfoLabelText
        memberSinceInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.memberSinceInfoLabelText
        membershipInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.membershipInfoLabelText
        memberCardInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.memberCardInfoLabelText
        switchMembershipButton.setTitle(Constant.memberShipViewController.membershipDetailTableViewCell.switchMembershipButtonTitle, for: .normal)
        
        
        contactNameLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.contactName] ?? ""
         memberCardInfoLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.cardName] ?? ""
         loginIdLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.loginID] ?? ""
         emailLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.email] ?? ""
         memberNumberLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.memberNum] ?? ""
         memberSinceDateLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.memberDate] ?? ""
         memberShipExpirationdateLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.membershipExpirationDate] ?? ""
         memberCardExpirationDateLabel.text = membershipDetailDictionary[Constant.CommonLocalisedString.cardExpirationDate] ?? ""
         
    }
    //MARK:set commonPrperties to cell
    /**
    Set  properties to Cell components
    - parameter No parameter:
    - returns : No return value
    */
    fileprivate func setPropertiesTocellElements(){
        
        //ContactInfo Main View Properties
        
        Helper.applyShadowOnUIView(view: contactInfoMainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1)
        
        // memberInfoMainView Properties
        
        memberInfoMainView.layer.cornerRadius = 4
        //cardInfoMainView Properties
        cardInfoMainView.layer.cornerRadius = 4
        
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
        
        membershipInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        memberShipExpirationdateLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        
        memberCardInfoLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        memberCardExpirationDateLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        switchMembershipButton.backgroundColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
