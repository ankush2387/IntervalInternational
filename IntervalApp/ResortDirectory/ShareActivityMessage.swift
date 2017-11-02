//
//  ShareActivityMessage.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class ShareActivityMessage: NSObject, UIActivityItemSource {
    var message: NSMutableAttributedString?
    var messageStr: String?
    var subjectMessage: String?
    var isConfirmationDetails: Bool = false
    
    
    func resortInformationMessage(resortName: String, address: String, description: String, resortCode: String) {
        //Resort Name Attributes
        let resortURL = URL(string: "https://www.intrvl.com/resort/\(resortCode)")
        let attributedLink = [NSLinkAttributeName: resortURL]
        let fontAttribute = [NSFontAttributeName: UIFont(name: "Helvetica", size: 18.0)]
        let attributedName = NSMutableAttributedString(string: resortName)
        attributedName.addAttributes(attributedLink, range: NSRange(location: 0, length: resortName.characters.count))
        attributedName.addAttributes(fontAttribute, range: NSRange(location: 0, length: resortName.characters.count))
        
        //address Attributes
        let addressFont = [NSFontAttributeName: UIFont(name: "Helvetica", size: 12.0)]
        let addressForeground = [NSForegroundColorAttributeName: UIColor.gray]
        let addressAttributed = NSMutableAttributedString(string: "\n\(address)\n\n")
        addressAttributed.addAttributes(addressFont, range: NSRange(location: 0, length: address.characters.count))
        addressAttributed.addAttributes(addressForeground, range: NSRange(location: 0, length: address.characters.count + 1))
        
        //description Attributes
        let descFont = [NSFontAttributeName: UIFont(name: "Helvetica", size: 14.0)]
        let descForegroud = [NSForegroundColorAttributeName: UIColor.black]
        let desc = NSMutableAttributedString(string: "\(description)\n\n")
        desc.addAttributes(descFont, range: NSRange(location: 0, length: description.characters.count))
        desc.addAttributes(descForegroud, range: NSRange(location: 0, length: description.characters.count))
        
        //url attributtes
        let urlStr = "Download the Interval App to see more.\n"
        let appURL = URL(string: "https://goo.gl/vGKvD6")
        let linkAttribute = [NSLinkAttributeName: appURL]
        let urlFont = [NSFontAttributeName: UIFont(name: "Helvetica", size: 12.0)]
        let urlAttributed = NSMutableAttributedString(string: urlStr)
        urlAttributed.addAttributes(urlFont ?? "", range: NSRange(location: 0, length: urlStr.characters.count))
        urlAttributed.addAttributes(linkAttribute ?? "", range: NSRange(location: 0, length: urlStr.characters.count))
        self.message = attributedName
        self.message?.append(addressAttributed)
        self.message?.append(desc)
        self.message?.append(urlAttributed)
        self.subjectMessage = "Look at this Resort I found Using Interval International's app."
    }
    
    func upcomingTripDetailsMessage() {
        //format message to be sent for text and Email
        self.isConfirmationDetails = true
        var message = ""
        var location = ""
        //confirmation Number
        if let confirmationNum = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber {
            message.append("Confirmation #: \(confirmationNum)\n")
        }
        //transaction Type
    
        if var transactionType =  Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType{
            transactionType = ExchangeTransactionType.fromName(name: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType!).friendlyNameForUpcomingTrip()
            message.append("TransactionType: \(transactionType)\n")
        }
        //transactionType = ExchangeTransactionType.fromName(name: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType!).friendlyNameForUpcomingTrip
        
        //Resort Name
        if let name = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName {
            message.append("Resort: \(name)\n")
        }
        //city Name
        if let cityName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.cityName {
            location = "\(cityName), "
        }
        //Country Code
        if let countryCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.countryCode {
            location.append("\(countryCode)")
        }
        message.append("Location: \(location)\n")
        
        //format checkIn Date
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.checkInDate) != nil{
            let checkInDate = Helper.convertStringToDate(dateString:(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.checkInDate)!, format: Constant.MyClassConstants.dateFormat)
            let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
            let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0))/\(myComponents.day ?? 0)/\(myComponents.year ?? 0)"
            message.append("CheckIn: \(formatedCheckInDate)\n")
        }
       
        
        
        
        //format CheckOut Date
        if (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.checkOutDate) != nil{
        let checkOutDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.checkOutDate ?? "", format: Constant.MyClassConstants.dateFormat1)
        let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
        let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month ?? 0))/\(myComponents1.day ?? 0)/\(myComponents1.year ?? 0)"
        message.append("CheckOut: \(formatedCheckOutDate)\n")
        }

        self.messageStr = message
        let attributedMessage = NSMutableAttributedString(string: message)
        self.message = attributedMessage
        self.subjectMessage = "Upcoming Trip Details"
        
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        //Message for UpcomingTrip Details
        if isConfirmationDetails {
            if activityType == UIActivityType.mail {
                return self.message
            }
            
            if activityType == UIActivityType.postToFacebook || activityType == UIActivityType.postToTwitter {
                return "Vacations with #intervalinternational"
            }
                        
            return self.messageStr
        }
        
        
        //Message for Resort Directory Details
        if activityType == UIActivityType.mail {
            return self.message
        }
        
        if activityType == UIActivityType.message {
            return "Look at this Resort I found Using Interval International's app."
        }
        
        return "Check out this #intervalinternational resort."
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {

        if let subject = self.subjectMessage {
            if activityType == UIActivityType.mail {
                return subject
            }
            
            return subject
        }
        
        return "Look at this Resort I found Using Interval International's app."
        
    }

}
