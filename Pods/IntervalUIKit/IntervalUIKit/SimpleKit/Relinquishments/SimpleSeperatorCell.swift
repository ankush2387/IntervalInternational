//
//  SimpleSeperatorCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/14/18.
//

import UIKit

public class SimpleSeperatorCell: SimpleTableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var dividerColor: UIView!

    // MARK: - Public properties
    public weak var viewModel: SimpleSeperatorCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                dividerColor.backgroundColor = viewModel.dividerColor.value
            }
        }
    }
}
