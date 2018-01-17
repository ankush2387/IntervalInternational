//
//  SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel.swift
//  Alamofire
//
//  Created by Aylwing Olivas on 1/6/18.
//

import Bond
import Foundation

open class SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel {
    
    open var isEditing = Observable(true)
    
    open var label1:Observable<String?>
    open var label2:Observable<String?>
    
    open var button1Title: Observable<String?>
    open var button2Title: Observable<String?>
    
    open var textFieldValue1: Observable<String?>
    open var textFieldValue2: Observable<String?>
    
    // The placeholder text assigned to the textfield
    
    open var placeholderText1: String?
    open var placeholderText2: String?
    
    open var cellHeight: Observable<CGFloat> = Observable(180)
    
    // To allow optional configuration of keyboard types.
    
    open var keyboardType1: UIKeyboardType?
    open var keyboardType2: UIKeyboardType?
    
    public init(label1: String? = nil,
                textFieldValue1: String? = nil,
                placeholderText1: String? = nil,
                label2: String? = nil,
                textFieldValue2: String? = nil,
                placeholderText2: String? = nil,
                button1Title: String? = nil,
                button2Title: String? = nil,
                keyboardType1: UIKeyboardType? = nil,
                keyboardType2: UIKeyboardType? = nil) {
        
        self.button1Title = Observable(button1Title)
        self.button2Title = Observable(button2Title)
        self.label1 = Observable(label1)
        self.textFieldValue1 = Observable(textFieldValue1)
        self.label2 = Observable(label2)
        self.textFieldValue2 = Observable(textFieldValue2)
        self.placeholderText1 = placeholderText1
        self.placeholderText2 = placeholderText2
        self.keyboardType1 = keyboardType1
        self.keyboardType2 = keyboardType2
    }
}

extension SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel : SimpleCellViewModel {
    
    public func modelType() -> SimpleViewModelType {
        return .labelTextFieldLabelTextFieldButtonButton
    }
}
