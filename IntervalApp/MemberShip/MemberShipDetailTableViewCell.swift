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
    @IBOutlet private weak var contactnameInfoLabel: UILabel!
    @IBOutlet private weak var contactNameLabel: UILabel!
    @IBOutlet private weak var activeLabel: UILabel!
    @IBOutlet private weak var loginInfoLabel: UILabel!
    @IBOutlet private weak var loginIdLabel: UILabel!
    @IBOutlet private weak var emailInfoLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var memberNumberInfoLabel: UILabel!
    @IBOutlet private weak var memberNumberLabel: UILabel!
    @IBOutlet private weak var memberSinceInfoLabel: UILabel!
    @IBOutlet private weak var memberSinceDateLabel: UILabel!
    @IBOutlet private weak var contactInfoMainView: UIView!
    @IBOutlet private weak var memberInfoMainView: UIView!
    @IBOutlet weak var switchMembershipButton: IUIKButton!
    @IBOutlet weak var activememberOutOfTotalMemberLabel: UILabel!
    @IBOutlet private weak var productExternalView: UIView!
    @IBOutlet private weak var ExternalViewHeightConstraint: NSLayoutConstraint!

    func setupCell(profile: Contact, membership: Membership) {
        setPropertiesTocellElements()
        
        let fullName = [profile.firstName, profile.lastName].flatMap { $0 }.joined(separator: " ")

        var loginId = ""
        if let login = profile.userName {
            loginId = login
        }
        
        var emailAddress = ""
        if let email = profile.emailAddress {
            emailAddress = email
        }
        
        var status = ""
        if profile.isPrimary == true {
            status = "Primary Contact"
        }
        
        var dateString = ""
        if let sinceDate = membership.sinceDate {
            dateString = sinceDate.stringWithShortFormatForJSON()
        }
        
        // Update label text
        contactnameInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.contactnameInfoLabelText
        loginInfoLabel.text = Constant.textFieldTitles.usernamePlaceholder
        emailInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.emailInfoLabelText
        memberNumberInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.memberNumberInfoLabelText
        switchMembershipButton.setTitle(Constant.memberShipViewController.membershipDetailTableViewCell.switchMembershipButtonTitle, for: .normal)
        
        if let memberships = profile.memberships, !memberships.isEmpty {
            activememberOutOfTotalMemberLabel.text = "1 of \(memberships.count)"
        }

        contactNameLabel.text = fullName
        loginIdLabel.text = loginId
        emailLabel.text = emailAddress
        memberNumberLabel.text = membership.memberNumber
        
        if let expDate = dateString.dateFromString(for: Constant.MyClassConstants.dateFormat) {
            memberSinceDateLabel.text = Helper.getWeekDay(dateString: expDate , getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.year))
        }
        activeLabel.text = status
    }

    fileprivate func setPropertiesTocellElements() {
        
        switchMembershipButton.layer.cornerRadius = 4
        
        //ContactInfo Main View Properties
        
        Helper.applyShadowOnUIView(view: contactInfoMainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1)
        
        // memberInfoMainView Properties
        
        memberInfoMainView.layer.cornerRadius = 4
        contactInfoMainView.layer.cornerRadius = 4
        //cardInfoMainView Properties
        contactnameInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        contactNameLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        activeLabel.textColor = UIColor(rgb: IUIKColorPalette.active.rawValue)
        loginInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        loginIdLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        emailInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        emailLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        memberNumberInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        memberNumberLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        memberSinceInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        memberSinceDateLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        switchMembershipButton.backgroundColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
    }
    
}
