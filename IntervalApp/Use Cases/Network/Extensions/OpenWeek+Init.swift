//
//  OpenWeek+Init.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import DarwinSDK

extension OpenWeek {
    public convenience init(relinquishment: Relinquishment) {
        self.init()
        relinquishmentId = relinquishment.relinquishmentId
        actions = relinquishment.actions
        relinquishmentYear = relinquishment.relinquishmentYear
        exchangeStatus = relinquishment.exchangeStatus
        weekNumber = relinquishment.exchangeStatus
        masterUnitNumber = relinquishment.masterUnitNumber
        checkInDates = relinquishment.checkInDates
        checkInDate = relinquishment.checkInDate
        checkOutDate = relinquishment.checkOutDate
        pointsProgramCode = relinquishment.pointsProgramCode
        resort = relinquishment.resort
        unit = relinquishment.unit
        pointsMatrix = relinquishment.pointsMatrix
        blackedOut = relinquishment.blackedOut
        bulkAssignment = relinquishment.bulkAssignment
        memberUnitLocked = relinquishment.memberUnitLocked
        payback = relinquishment.payback
        reservationAttributes = relinquishment.reservationAttributes
        virtualWeekActions = relinquishment.virtualWeekActions
        promotion = relinquishment.promotion
    }
}
