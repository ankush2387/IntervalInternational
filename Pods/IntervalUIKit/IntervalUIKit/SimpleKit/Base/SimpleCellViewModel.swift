//
//  SimpleCellViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond

public protocol SimpleCellViewModel {
    
    /// Indicates that this should be in an "editable" state whatever that is
    var isEditing: Observable<Bool> { get set }
    
    /// Indicates that this is the viewModel of a cell who's height can vary
    var cellHeight: Observable<CGFloat> { get set }
    
    /// Can be used by clients to bind a concrete instance to something like a tableview cell
    func modelType() -> SimpleViewModelType
}

public enum SimpleViewModelType {
    
    case labelSwitch
    case labelLabel
    case buttonCell
    case textField
    case labelTextLabelText
    case simpleResortDetailViewModel
    case simpleSeperatorCellViewModel
    case ownershipTableViewCellViewModel
    case availableRelinquishmentPointsCellViewModel
    case labelTextFieldLabelTextFieldButtonButton
    
    // Careful all future additions must be kept in sync with the enumeration!
    static let allValues = [labelSwitch, labelLabel, buttonCell, labelTextLabelText, simpleResortDetailViewModel,
                            textField, simpleSeperatorCellViewModel, ownershipTableViewCellViewModel, availableRelinquishmentPointsCellViewModel,
                            labelTextFieldLabelTextFieldButtonButton]
    
    
    func defaultReuseIdentifier() -> String {
        switch self {
            
        case .labelSwitch:
            return String(describing: SimpleLabelSwitchCell.self)
            
        case .labelLabel:
            return String(describing: SimpleLabelLabelCell.self)
            
        case .buttonCell:
            return String(describing: SimpleButtonCell.self)
            
        case .textField:
            return String(describing: SimpleTextFieldCell.self)
            
        case .simpleSeperatorCellViewModel:
            return String(describing: SimpleSeperatorCell.self)
            
        case .ownershipTableViewCellViewModel:
            return String(describing: SimpleOwnershipCell.self)

        case .simpleResortDetailViewModel:
            return String(describing: SimpleResortDetailViewCell.self)

        case .labelTextLabelText:
            return String(describing: SimpleLabelTextLabelTextCell.self)

        case .availableRelinquishmentPointsCellViewModel:
            return String(describing: SimpleAvailableRelinquishmentPointsCell.self)
            
        case .labelTextFieldLabelTextFieldButtonButton:
            return String(describing: SimpleLabelTextFieldLabelTextFieldButtonButtonCell.self)
        }
    }
    
    func defaultNibName() -> String {
        return defaultReuseIdentifier()
    }
}
