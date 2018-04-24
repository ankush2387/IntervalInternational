//
//  GuestCertificateCell.swift
//  IntervalApp
//
//  Created by Chetu on 03/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class GuestCertificateCell: UITableViewCell {
    
    @IBOutlet private var fullName: UILabel!
    @IBOutlet private var addressLine1: UILabel!
    @IBOutlet private var addressLine2: UILabel!
    static let identifier = "GuestCertificateCell"
    
    func setGuestInfo(with guestInfo: Guest) {
        if let firstName = guestInfo.firstName, let lastName = guestInfo.lastName {
            fullName.text = "\(firstName.capitalized) \(lastName.capitalized)"
        }
        if let address = guestInfo.address {
            addressLine1.text = address.addressLines.joined(separator: ", ")
            addressLine2.text = [address.postalAddresAsString(), guestInfo.phones[0].phoneNumber].flatMap { $0 }.joined(separator: " ")
        }
    }
}
