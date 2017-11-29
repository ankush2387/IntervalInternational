//
//  SimpleOnboardingViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final public class SimpleOnboardingViewModel {

    // MARK: - Public properties
    public let doneButtonTitle: String
    public let allowsOnboardingSkip: Bool
    public let skipIntroButtonTitle: String
    public let onboardingPageEntities: [SimpleOnboardingPageEntity]

    // MARK: - Lifecycle
    public init(onboardingPageEntities: [SimpleOnboardingPageEntity],
                doneButtonTitle: String,
                skipIntroButtonTitle: String,
                allowsOnboardingSkip: Bool = true) {

        self.doneButtonTitle = doneButtonTitle
        self.skipIntroButtonTitle = skipIntroButtonTitle
        self.allowsOnboardingSkip = allowsOnboardingSkip
        self.onboardingPageEntities = onboardingPageEntities
    }
}
