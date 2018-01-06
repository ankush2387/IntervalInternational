//
//  SimpleLabelTextLabelTextCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

import Bond

open class SimpleLabelTextLabelTextCellViewModel {

    // From SimpleViewModelProtocol
    open var isEditing = Observable(false)

    open var label1:Observable<String?>
    open var value1:Observable<String?>
    open var label2:Observable<String?>
    open var value2:Observable<String?>
    open var value1LengthValidator: TextValidator?
    open var value2LengthValidator: TextValidator?

    public init(label1: String?, value1: String?, label2: String?, value2: String?) {
        self.label1 = Observable(label1)
        self.value1 = Observable(value1)
        self.label2 = Observable(label2)
        self.value2 = Observable(value2)
    }
}

extension SimpleLabelTextLabelTextCellViewModel : SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .labelTextLabelText
    }
}

