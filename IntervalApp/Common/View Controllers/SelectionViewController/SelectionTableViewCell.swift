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
    @IBOutlet private weak var selectionView: UIView!

    // MARK: - Public properties
    static let cellHeight: CGFloat = 70
    static let identifier = String(describing: SelectionTableViewCell.self)
    static let xib = UINib(nibName: identifier, bundle: nil)
    public var tapped: (() -> Void)?

    // MARK: - Public functions
    func setCell(labelText: String?, isSelected: Bool) {
        cellLabel.text = labelText
        cellImageView.image = isSelected ? #imageLiteral(resourceName: "Select-On") : #imageLiteral(resourceName: "Select-Off")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
    }

    // MARK: - Private properties
    @objc private func cellTapped() {
        isSelected = true
        cellImageView.image = #imageLiteral(resourceName: "Select-On")
        tapped?()
    }
}
