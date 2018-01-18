//
//  SimpleAvailableRelinquishmentPointsCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/13/18.
//

import Bond
import UIKit

public class SimpleAvailableRelinquishmentPointsCellViewModel {

    // MARK: - Public properties
    open var isEditing = Observable(true)
    open var cigImage: Observable<UIImage>
    open var numberOfPoints: Observable<String?>
    open var actionButtonImage: Observable<UIImage?>
    open var availablePointsButtonText: Observable<String?>
    open var goldPointsHeadingLabelText: Observable<String?>
    open var goldPointsSubHeadingLabel: Observable<String?>
    open var cellHeight: Observable<CGFloat> = Observable(140)

    // MARK: - Lifecycle
    public init(cigImage: UIImage,
                actionButtonImage: UIImage? = nil,
                numberOfPoints: String? = nil,
                availablePointsButtonText: String? = nil,
                goldPointsHeadingLabelText: String? = nil,
                goldPointsSubHeadingLabel: String? = nil) {

        self.cigImage = Observable(cigImage)
        self.numberOfPoints = Observable(numberOfPoints)
        self.actionButtonImage = Observable(actionButtonImage)
        self.availablePointsButtonText = Observable(availablePointsButtonText)
        self.goldPointsHeadingLabelText = Observable(goldPointsHeadingLabelText)
        self.goldPointsSubHeadingLabel = Observable(goldPointsSubHeadingLabel)
    }
}

extension SimpleAvailableRelinquishmentPointsCellViewModel: SimpleCellViewModel {

    public func modelType() -> SimpleViewModelType {
        return .availableRelinquishmentPointsCellViewModel
    }
}
