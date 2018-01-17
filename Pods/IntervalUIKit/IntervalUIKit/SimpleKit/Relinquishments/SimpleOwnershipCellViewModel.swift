//
//  SimpleOwnershipCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/15/18.
//

import Bond
import UIKit

final public class SimpleOwnershipCellViewModel {
    
    public var isEditing = Observable(true)
    public var cellHeight: Observable<CGFloat> = Observable(60)
    public var ownershipStateLabelText: Observable<String?>
    public var extraInformationLabelText: Observable<String?>
    public var monthLabelText: Observable<String?>
    public var yearLabelText: Observable<String?>
    public var weekLabelText: Observable<String?>
    public var resortNameLabelText: Observable<String?>
    public var unitDetailsLabelText: Observable<String?>
    public var unitCapacityLabelText: Observable<String?>
    public var statusLabelText: Observable<String?>
    public var expirationDateLabelText: Observable<String?>
    public var flagsLabelText: Observable<String?>
    public var relinquishmentPromotionImage: Observable<UIImage?>
    public var relinquishmentPromotionLabelText: Observable<String?>
    public var actionButton: Observable<UIImage?>
    
    public init(ownershipStateLabelText: String? = nil,
                extraInformationLabelText: String? = nil,
                monthLabelText: String? = nil,
                yearLabelText: String? = nil,
                weekLabelText: String? = nil,
                resortNameLabelText: String? = nil,
                unitDetailsLabelText: String? = nil,
                unitCapacityLabelText: String? = nil,
                statusLabelText: String? = nil,
                expirationDateLabelText: String? = nil,
                flagsLabelText: String? = nil,
                relinquishmentPromotionImage: UIImage? = nil,
                relinquishmentPromotionLabelText: String? = nil,
                actionButton: UIImage? = nil) {
        
        self.ownershipStateLabelText = Observable(ownershipStateLabelText)
        self.extraInformationLabelText = Observable(extraInformationLabelText)
        self.monthLabelText = Observable(monthLabelText)
        self.yearLabelText = Observable(yearLabelText)
        self.weekLabelText = Observable(weekLabelText)
        self.resortNameLabelText = Observable(resortNameLabelText)
        self.unitDetailsLabelText = Observable(unitDetailsLabelText)
        self.unitCapacityLabelText = Observable(unitCapacityLabelText)
        self.statusLabelText = Observable(statusLabelText)
        self.expirationDateLabelText = Observable(expirationDateLabelText)
        self.flagsLabelText = Observable(flagsLabelText)
        self.relinquishmentPromotionImage = Observable(relinquishmentPromotionImage)
        self.relinquishmentPromotionLabelText = Observable(relinquishmentPromotionLabelText)
        self.actionButton = Observable(actionButton)
    }
}

extension SimpleOwnershipCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .ownershipTableViewCellViewModel
    }
}

