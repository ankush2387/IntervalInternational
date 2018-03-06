//
//  RelinquishmentSections.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

open class RelinquishmentSections {

    //
    // Group Name: Club Interval Gold Weeks
    // Rule: openWeek.pointProgramCode = CIG
    //
    open var cigPointsProgram: PointsProgram?
    open lazy var cigPointsWeeks = [Relinquishment]()
    
    //
    // Group Name: Points
    // Rule: openWeek.weekNumber = POINTS_WEEK
    //
    open lazy var pointsWeeks = [Relinquishment]()
    
    //
    // Group Name: Interval Weeks
    // Rule: openWeek.weekNumber = openWeek.pointProgramCode != CIG && openWeek.weekNumber != POINTS_WEEK
    //
    open lazy var intervalWeeks = [Relinquishment]()

    public init() {
    }
    
    open func hasCIGPointsProgram() -> Bool {
        return cigPointsProgram != nil
    }

    open func hasCIGPointsWeeks() -> Bool {
        return !cigPointsWeeks.isEmpty
    }
    
    open func hasPointsWeeks() -> Bool {
        return !pointsWeeks.isEmpty
    }
    
    open func hasIntervalWeeks() -> Bool {
        return !intervalWeeks.isEmpty
    }
}
