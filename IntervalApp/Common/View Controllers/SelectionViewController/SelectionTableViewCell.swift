//
//  SelectionTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

final class SelectionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var cellLabel: UILabel!
    @IBOutlet private weak var cellImageView: UIImageView!
    
    // MARK: - Public properties
    static let cellHeight: CGFloat = 70
    static let identifier = "SelectionTableViewCell"
    static let xib = UINib(nibName: identifier, bundle: nil)

    // MARK: Public functions
    func setCell(labelText: String?) {
        cellLabel.text = labelText
        cellImageView.image = #imageLiteral(resourceName: "Select-Off")
    }

    func selectCell() {
        cellImageView.image = #imageLiteral(resourceName: "Select-On")
    }
}
