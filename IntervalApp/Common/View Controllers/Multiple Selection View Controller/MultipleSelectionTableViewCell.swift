//
//  MultipleSelectionTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/2/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

final class MultipleSelectionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var selectionView: UIView!
    
    // MARK: - Public properties
    static let identifier = String(describing: MultipleSelectionTableViewCell.self)
    static let xib = UINib(nibName: identifier, bundle: nil)
    public var didSelect: ((Bool) -> Void)?

    // MARK: - Public functions
    func setCell(element: MultipleSelectionElement, isSelected: Bool) {
        headerLabel.text = element.cellTitle
        subtitleLabel.text = element.cellSubtitle
        cellImageView.image = isSelected ? #imageLiteral(resourceName: "Checkmark-On") : #imageLiteral(resourceName: "Checkmark-Off")
        headerLabel.textColor = IntervalThemeFactory.deviceTheme.textColorBlack
        subtitleLabel.textColor = IntervalThemeFactory.deviceTheme.textColorGray
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
    }
    
    // MARK: - Private properties
    @objc private func cellTapped() {
        cellImageView.image = cellImageView.image == #imageLiteral(resourceName: "Checkmark-On") ? #imageLiteral(resourceName: "Checkmark-Off") : #imageLiteral(resourceName: "Checkmark-On")
        isSelected = cellImageView.image == #imageLiteral(resourceName: "Checkmark-On")
        didSelect?(isSelected)
    }
}
