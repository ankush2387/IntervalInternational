//
//  SimpleViewModelBinder.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/7/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

// swiftlint:disable multiline_parameters
public protocol SimpleViewModelBinder {
    
    // Will bind ALL Simple ViewModels and Cells(views) to the tableview
    func registerSimpleCellViews(withTableView tableView: UITableView)
    
    // Returns the Cell(view) from the table at the index path.  The type is required for retrieving the
    // reuse identifier.  If the client wants to use their own View with a particular ViewModel they are free
    // to not use this fuction
    func cellView(_ tableView: UITableView, forIndexPath indexPath: IndexPath,
                  forViewModelType type: SimpleViewModelType) -> UITableViewCell
    
    // Takes care of setting the correct SimpleCellViewModel concrete type onto the SimpleViewCell views
    // served up by 'cellView' function
    func bindSimpleCellView(_ view: UITableViewCell, withSimpleViewModel viewModel: SimpleCellViewModel)
}

// Default implementation should work for most scenarios
public extension SimpleViewModelBinder {
    
    func registerSimpleCellViews(withTableView tableView: UITableView) {
        // Associate a View with the ViewModels
        SimpleViewModelType.allValues.forEach {
            // Load the nib from this frameworks bundle, not the conforming class bundle!
            let bundle = Bundle(for: SimpleTableViewCell.self)
            tableView.register(UINib(nibName: $0.defaultNibName(), bundle: bundle),
                               forCellReuseIdentifier: $0.defaultReuseIdentifier())
        }
    }
    
    func cellView(_ tableView: UITableView, forIndexPath indexPath: IndexPath, forViewModelType type: SimpleViewModelType) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: type.defaultReuseIdentifier(), for: indexPath)
    }
    
    func bindSimpleCellView(_ view: UITableViewCell, withSimpleViewModel viewModel: SimpleCellViewModel) {
        switch (viewModel, view) {
        case (let viewModel as SimpleLabelSwitchCellViewModel, let view as SimpleLabelSwitchCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleLabelLabelCellViewModel, let view as SimpleLabelLabelCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleButtonCellViewModel, let view as SimpleButtonCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleLabelTextLabelTextCellViewModel, let view as SimpleLabelTextLabelTextCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleTextFieldCellViewModel, let view as SimpleTextFieldCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleSeperatorCellViewModel, let view as SimpleSeperatorCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleResortDetailViewModel, let view as SimpleResortDetailViewCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleAvailableRelinquishmentPointsCellViewModel, let view as SimpleAvailableRelinquishmentPointsCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleOwnershipCellViewModel, let view as SimpleOwnershipCell):
            view.viewModel = viewModel
        case (let viewModel as SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel, let view as SimpleLabelTextFieldLabelTextFieldButtonButtonCell):
            view.viewModel = viewModel
            
        default:
            fatalError("Could not match SimpleViewModel with SimpleCellView!")
        }
    }
}

