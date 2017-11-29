//
//  SimpleOnboardingViewDelegate.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

/**
 *  The delegate of a SimpleOnboardingView object must adopt the PaperOnboardingDelegate protocol. Optional methods of the
 protocol allow the delegate to manage items, configure items, and perform other actions.
 */
protocol SimpleOnboardingViewDelegate: class {

    /**
     Should `SimpleOnboardingView` react to taps on `PageControl` view.
     If `true`, will scroll to tapped page.
     */
    var enableTapsOnPageControl: Bool { get }

    /**
     Tells the delegate that the paperOnbording start scrolling.

     - parameter index: An curretn index item
     */
    func onboardingWillTransitonToIndex(_ index: Int)

    /**
     Tells the delegate that the specified item is now selected

     - parameter index: An curretn index item
     */
    func onboardingDidTransitonToIndex(_ index: Int)

    /**
     Tells the delegate the SimpleOnboardingView is about to draw a item for a particular row. Use this method for configure items

     - parameter item:  A OnboardingContentViewItem object that SimpleOnboardingView is going to use when drawing the row.
     - parameter index: An curretn index item
     */
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int)
}

// This extension will make the delegate method optional
extension SimpleOnboardingViewDelegate {
    func onboardingWillTransitonToIndex(_ index: Int) { }
    func onboardingDidTransitonToIndex(_ index: Int) { }
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) { }
    var enableTapsOnPageControl: Bool { return true }
}
