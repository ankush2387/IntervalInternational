//
//  SimpleOnboardingPageEntity.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

public struct SimpleOnboardingPageEntity {

    // MARK: - Internal module properties
    let title: String
    let titleFont: UIFont
    let mainImage: UIImage
    let description: String
    let screenColor: UIColor
    let iconNavigator: UIImage
    let descriptionFont: UIFont
    let titleTextColor: UIColor
    let descriptionTextColor: UIColor

    // MARK: - Lifecycle
    public init(mainImage: UIImage,
                title: String,
                titleTextColor: UIColor,
                description: String,
                descriptionTextColor: UIColor,
                iconNavigator: UIImage,
                screenColor: UIColor,
                titleFont: UIFont = UIFont.boldSystemFont(ofSize: 36.0),
                descriptionFont: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        
        self.title = title
        self.mainImage = mainImage
        self.description = description
        self.screenColor = screenColor
        self.iconNavigator = iconNavigator
        self.titleTextColor = titleTextColor
        self.descriptionTextColor = descriptionTextColor
        self.titleFont = titleFont
        self.descriptionFont = descriptionFont
    }
}
