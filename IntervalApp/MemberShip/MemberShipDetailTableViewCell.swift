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
    
    // MARK: get MembershipCell using informations
    /**
        Configure Cell Components.
        - parameter membershipDetailDictionary : Dictionary with String key and String Value.
        - returns : No value is return
    */
    func getCell(contactInfo: Contact, products: [Product]) {
        setPropertiesTocellElements()
        
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
        
        if contactInfo.isPrimary == true {
            let memberStatus = "Primary Owner"
            status = memberStatus
        }
        
        if let memberSinceDate = contactInfo.lastVerifiedDate {
            dateString = memberSinceDate.stringWithShortFormatForJSON()
        }
        
        if let count = contactInfo.memberships?.count {
            membershipsAmount = count
        }

        updateCell(contactName: "\(firstName) \(lastName)", loginID: loginID, email: emailAddress, status: status, date: dateString, memberships: membershipsAmount, products: products)
        
    }
    // MARK: Update value according to server response
    /**
        Update label text.
    
        - parameter membershipDetailDictionary: Dictionary with String Key and String Value.
        - returns: No return value.
    */
    fileprivate func updateCell(contactName: String, loginID: String, email: String, status: String, date: String, memberships: Int, products: [Product]) {
        
        // Update label text
        contactnameInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.contactnameInfoLabelText
        loginInfoLabel.text = Constant.textFieldTitles.usernamePlaceholder
         emailInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.emailInfoLabelText
        memberNumberInfoLabel.text = Constant.memberShipViewController.membershipDetailTableViewCell.memberNumberInfoLabelText
        switchMembershipButton.setTitle(Constant.memberShipViewController.membershipDetailTableViewCell.switchMembershipButtonTitle, for: .normal)
        activememberOutOfTotalMemberLabel.text = "1 of \(memberships)"
        
        contactNameLabel.text = contactName
         loginIdLabel.text = loginID
         emailLabel.text = email
         memberNumberLabel.text = Constant.MyClassConstants.memberNumber
       let date = Helper.convertStringToDate(dateString: date, format: Constant.MyClassConstants.dateFormat)
        memberSinceDateLabel.text = Helper.getWeekDay(dateString: date, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: date, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: date, getValue: Constant.MyClassConstants.year))
        
        activeLabel.text = status
        
        //setup Products View depending on number of Products
        let size = products.count //amount of products to display
        var yPosition = 5 // yPosition of view
        let height = 80 // height of each view
        ExternalViewHeightConstraint.constant = CGFloat((80 * size) + 10)

        var count = 0
        for prod in products {
            let prodView = nonCoreProductView()
            prodView.initializeView()
            
            if let productCode = prod.productCode {
                prodView.productImageView.image = UIImage(named: productCode)
            }
            if prod.coreProduct {
                prodView.productImageView.isHidden = true
                prodView.triangleView.isHidden = true
                prodView.externalView.backgroundColor = UIColor.white
                prodView.nameLabelLeadingConstraint.constant = 10
                prodView.expiresLabelLeadingConstraint.constant = 10
            }

            if count > 1 {
                prodView.triangleView.isHidden = true
            }
            
            if !prod.billingEntity.unwrappedString.contains("NON") {
                prodView.expirationDateLabel.text = nil
                prodView.expireLabel.isHidden = true
            } else {
                
                if let expDate = prod.expirationDate {
                    prodView.expirationDateLabel.text = Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.year))
                }
                prodView.expirationDateLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
            }
            if let name = prod.productName?.capitalized {
                    prodView.productNameLabel.text = "\(name) Membership".localized()
                     prodView.productNameLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 20)
            }
            prodView.productNameLabel.textColor = UIColor.black
            prodView.frame = CGRect(x:5, y: yPosition, width: Int(productExternalView.frame.width - 10), height: height)
            productExternalView.addSubview(prodView)
            yPosition += height
            count += 1
        }
        productExternalView.layer.cornerRadius = 7
    }
    // MARK: set commonPrperties to cell
    /**
    Set  properties to Cell components
    - parameter No parameter:
    - returns : No return value
    */
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
