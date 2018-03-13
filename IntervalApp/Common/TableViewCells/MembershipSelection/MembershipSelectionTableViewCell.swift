//
//  MembershipSelectionTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

final class MembershipSelectionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet fileprivate weak var membershipImageView: UIImageView!
    @IBOutlet fileprivate weak var membershipNumberLabel: UILabel!
    @IBOutlet fileprivate weak var membershipNameLabel: UILabel!
}

extension MembershipSelectionTableViewCell: SimpleGenericTableViewCell {
    
    var identifier: String { return "MembershipSelectionTableViewCell" }
    var xib: UINib? { return UINib(nibName: "MembershipSelectionTableViewCell", bundle: Bundle(for: MembershipSelectionTableViewCell.self)) }
    private enum Key: String { case membershipImage, membershipName, membershipNumber }
    
    func setCell(membershipImage: UIImage, membershipName: String, membershipNumber: String) {
        write(data: [Key.membershipImage.rawValue: membershipImage,
                     Key.membershipName.rawValue: membershipName,
                     Key.membershipNumber.rawValue: "Member: ".localized() + membershipNumber])
    }
    
    func setUI(for index: Int) {
        let data = readData(at: index)
        membershipNameLabel.text = data[Key.membershipName.rawValue] as? String
        membershipImageView.image = data[Key.membershipImage.rawValue] as? UIImage
        membershipNumberLabel.text = data[Key.membershipNumber.rawValue] as? String
    }
}
