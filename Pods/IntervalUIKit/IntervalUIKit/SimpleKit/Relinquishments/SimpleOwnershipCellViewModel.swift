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
    public var cellHeight: Observable<CGFloat> = Observable(130)
    public var ownershipStateLabelText: Observable<String?>
    public var exchangeNumberLabelText: Observable<String?>
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
                exchangeNumberLabelText: String? = nil,
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
        self.exchangeNumberLabelText = Observable(exchangeNumberLabelText)
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

        if case .some = ownershipStateLabelText {
            cellHeight.value += 40
        }
        
        if case .some = relinquishmentPromotionLabelText {
            cellHeight.value += 40
        }

        if case .some = statusLabelText {
            cellHeight.value += 20
        }

        if case .some = expirationDateLabelText {
            cellHeight.value += 20
        }

        if let monthText = monthLabelText {
            let newLines = monthText.filter { $0 == "\n" }
            let newHeightAdjustment = newLines.count * 20
            cellHeight.value += CGFloat(newHeightAdjustment)
        }
        
        if let messages = extraInformationLabelText {
            let newLines = messages.filter { $0 == "\n" }
            let newHeightAdjustment = newLines.count * 60
            cellHeight.value += CGFloat(newHeightAdjustment)
        }
        
        if let flags = flagsLabelText {
            let newLines = flags.filter { $0 == "\n" }.count
            if newLines > 1 {
                let newHeightAdjustment = newLines * 20
                cellHeight.value += CGFloat(newHeightAdjustment)
            }
        }
    }
}

extension SimpleOwnershipCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .ownershipTableViewCellViewModel
    }
}

