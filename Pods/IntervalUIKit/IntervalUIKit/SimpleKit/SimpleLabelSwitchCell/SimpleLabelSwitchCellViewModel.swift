//
//  SimpleLabelSwitchCellViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import ReactiveKit

public class SimpleLabelSwitchCellViewModel {
    
    // From SimpleViewModelProtocol
    public var isEditing = Observable(false)
    
    public var label: Observable<String?>
    private(set) var secondaryLabel: Observable<String?> = Observable("")
    private var secondaryLabelsText: (onText: String, offText: String)?
    
    public var switchOn = Observable<Bool>(false)
    public var displaySecondaryLabel = Observable<Bool>(false)
    open var cellHeight: Observable<CGFloat> = Observable(60)
    
    private let disposableBag = DisposeBag()
    
    public init(label: String,
                switchOn: Bool,
                displaySecondaryLabel: Bool = false,
                secondaryLabelTexts: (onText: String, offText: String)? = nil) {
        
        self.label = Observable(label)
        self.switchOn = Observable(switchOn)
        self.displaySecondaryLabel = Observable(displaySecondaryLabel)
        secondaryLabelsText = secondaryLabelTexts
        
        self.switchOn
            .observeNext { [weak self] onState in
                self?.secondaryLabel.value = onState ? self?.secondaryLabelsText?.onText : self?.secondaryLabelsText?.offText
            }
            .dispose(in: disposableBag)
    }
}

extension SimpleLabelSwitchCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .labelSwitch
    }
}

