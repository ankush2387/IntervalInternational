//
//  SimpleOnboardingDataSource.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//
import Foundation

/**
 *  The SimpleOnboardingDataSource protocol is adopted by an object that mediates the application’s data model for a PaperOnboarding object.
 The data source information it needs to construct and modify a SimpleOnboardingView.
 */
protocol SimpleOnboardingDataSource: class {

    /**
     Asks the data source to return the number of items.

     - parameter index: An index of item in SimpleOnboardingView.
     - returns: The number of items in SimpleOnboardingView.
     */
    func onboardingItemsCount() -> Int

    /**
     Asks the data source for configureation item.

     - parameter index: An index of item in SimpleOnboardingView.
     - returns: configuration info for item
     */
    func onboardingItemAtIndex(_ index: Int) -> SimpleOnboardingPageEntity
}
