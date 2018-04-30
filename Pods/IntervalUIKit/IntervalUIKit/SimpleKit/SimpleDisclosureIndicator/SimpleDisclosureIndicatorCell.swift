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
    @IBOutlet private weak var cellImageView: UIImageView!
    
    // MARK: - Public properties
    public var cellTapped: (() -> Void)?

    public weak var viewModel: SimpleDisclosureIndicatorCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                viewModel.headerLabelText.bind(to: headerLabel.reactive.attributedText).dispose(in: onReuseBag)
                viewModel.image.bind(to: cellImageView.reactive.image).dispose(in: onReuseBag)
                viewModel.headerLabelText.observeNext(with: hideImageView).dispose(in: onReuseBag)
                viewModel.image.observeNext(with: hideImageView).dispose(in: onReuseBag)
            }
        }
    }
    
    private func hideImageView(_: Any?) {
        cellImageView.isHidden = viewModel?.headerLabelText.value == nil
            || viewModel?.image.value == nil
            || viewModel?.cellHeight.value == 0
    }
    
    // MARK: - IBActions
    @IBAction func cellTapped(_ sender: Any) {
        if viewModel?.isEditing.value == true {
            isSelected = true
            cellTapped?()
            isSelected = false
        }
    }
}
