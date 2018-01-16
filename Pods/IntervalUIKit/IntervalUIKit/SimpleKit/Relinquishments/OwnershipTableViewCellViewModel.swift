//
//  OwnershipTableViewCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/15/18.
//

import Bond
import UIKit

public enum OwnershipState: String {

    case saved = "Saved"
    case deposited = "Deposited"

    var localizedValue: String {
        return NSLocalizedString(self.rawValue, comment: "Ownership State Status")
    }
}

final public class OwnershipTableViewCellViewModel {

    public var isEditing = Observable(true)
    public var cellHeight: Observable<CGFloat> = Observable(60)
    public var ownershipState: Observable<OwnershipState?>

    public init(ownershipState: OwnershipState? = nil) {
        self.ownershipState = Observable(ownershipState)
    }
}

extension OwnershipTableViewCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .ownershipTableViewCellViewModel
    }
}
