//
//  SimpleSeperatorCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/14/18.
//

import UIKit
import Bond

public class SimpleSeperatorCellViewModel {

    public var isEditing = Observable(true)
    public var cellHeight: Observable<CGFloat>
    public var dividerColor: Observable<UIColor?>

    public init(dividerColor: UIColor? = IntervalThemeFactory.deviceTheme.backgroundColorGray,
                dividerHeight: CGFloat = 4) {
        self.dividerColor = Observable(dividerColor)
        self.cellHeight = Observable(dividerHeight)
    }
}

extension SimpleSeperatorCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .simpleSeperatorCellViewModel
    }
}
