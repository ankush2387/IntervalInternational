//
//  SimpleResortDetailViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/20/18.
//

import Bond
import UIKit
import Foundation

final public class SimpleResortDetailViewModel {

    public var isEditing = Observable(true)
    public var cellHeight: Observable<CGFloat> = Observable(250)
    public var resortNameLabelText: Observable<String?>
    public var resortLocationLabelText: Observable<String?>
    public var resortCodeLabelText: Observable<String?>
    public var resortImage: Observable<UIImage?>

    public init(resortNameLabelText: String? = nil,
                resortLocationLabelText: String? = nil,
                resortCodeLabelText: String? = nil,
                resortImage: UIImage? = nil) {

        self.resortNameLabelText = Observable(resortNameLabelText)
        self.resortLocationLabelText = Observable(resortLocationLabelText)
        self.resortCodeLabelText = Observable(resortCodeLabelText)
        self.resortImage = Observable(resortImage)
    }
}

extension SimpleResortDetailViewModel: SimpleCellViewModel {

    public func modelType() -> SimpleViewModelType {
        return .simpleResortDetailViewModel
    }
}
