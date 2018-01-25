//
//  SimpleDisclosureIndicatorCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/23/18.
//

import UIKit

final public class SimpleDisclosureIndicatorCell: SimpleTableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var headerLabel: UILabel!

    // MARK: - Public properties
    public var cellTapped: (() -> Void)?

    public weak var viewModel: SimpleDisclosureIndicatorCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                viewModel.headerLabelText.bind(to: headerLabel.reactive.attributedText).dispose(in: onReuseBag)
            }
        }
    }

    // MARK: - IBActions
    @IBAction func cellTapped(_ sender: Any) {
        self.isSelected = true
        cellTapped?()
        self.isSelected = false
    }
}
