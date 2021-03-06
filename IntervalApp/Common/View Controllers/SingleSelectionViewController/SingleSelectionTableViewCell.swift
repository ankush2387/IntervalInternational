//
//  SingleSelectionTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

final class SingleSelectionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var cellTitleLabel: UILabel!
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var cellBackgroundView: UIView!

    // MARK: - Public properties
    static let identifier = String(describing: SingleSelectionTableViewCell.self)
    static let xib = UINib(nibName: identifier, bundle: nil)
    public var tapped: (() -> Void)?

    // MARK: - Private properties
    private var cellType: SingleSelectionCellUIType = .checkMark

    // MARK: - Public functions
    func setCell(cellTitle: String,
                 cellSubtitle: String? = nil,
                 isSelected: Bool,
                 cellType: SingleSelectionCellUIType) {

        self.cellType = cellType
        let titleAttributes = [NSForegroundColorAttributeName: IntervalThemeFactory.deviceTheme.textColorBlack]
        let attributedText = NSMutableAttributedString(string: cellTitle, attributes: titleAttributes)

        if let cellSubtitle = cellSubtitle {
            let subtitleAttributes = [NSForegroundColorAttributeName: IntervalThemeFactory.deviceTheme.textColorGray]
            let attributedSubtitle = NSMutableAttributedString(string: "\n" + cellSubtitle, attributes: subtitleAttributes)
            attributedText.append(attributedSubtitle)
        }

        cellTitleLabel.attributedText = attributedText
        setImage(for: cellType)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
    }

    // MARK: - Public functions
    func deselectCell() {
        cellBackgroundView.layer.borderColor = IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor
    }
    
    // MARK: - Private properties
    @objc private func cellTapped() {
        
        switch cellType {
        case .checkMark:
            isSelected = true
            cellImageView.image = #imageLiteral(resourceName: "Select-On")
            
        case .disclosure:
            cellBackgroundView.layer.borderColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange.cgColor
        }
    
        tapped?()
    }
    
    private func setImage(for cellType: SingleSelectionCellUIType) {
        switch cellType {
        case .checkMark:
            cellImageView.image = isSelected ? #imageLiteral(resourceName: "Select-On") : #imageLiteral(resourceName: "Select-Off")
            
        case .disclosure:
            cellImageView.image = #imageLiteral(resourceName: "ForwardArrowIcon")
            cellBackgroundView.layer.borderWidth = 2
            cellBackgroundView.layer.cornerRadius = 5
            cellBackgroundView.layer.borderColor = isSelected ?
                IntervalThemeFactory.deviceTheme.textColorDarkOrange.cgColor : IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor
        }
    }
}
