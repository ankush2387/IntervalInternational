//
//  Relinquishment.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

open class Relinquishment {
    
    open var relinquishmentId : String?
    open lazy var actions = [String]() // AvailableWeekAction
    open var relinquishmentYear : Int?
    open var exchangeStatus : String? // ExchangeStatus
    open var weekNumber : String? // WeekNumber
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var checkInDate : String?
    open var checkOutDate : String?
    open var pointsProgramCode : String? // PointProgramCode
    open var promotion : Promotion?
   
    // Both: Virtual Week Actions
    open lazy var virtualWeekActions = [String]() // VirtualWeekAction
    
    // OpenWeek | Deposit | Both: Flags
    open var pointsMatrix : Bool = false // OpenWeek -> Points
    open var blackedOut : Bool = false // OpenWeek
    open var memberUnitLocked : Bool = false // OpenWeek
    open var bulkAssignment : Bool = false // OpenWeek
    open var payback : Bool = false // OpenWeek
    open var supplementalWeek : Bool = false // Deposit
    open var waitList : Bool = false // OpenWeek & Deposit
    
    // OpenWeek: Additional Info
    open var fixWeekReservation : FixWeekReservation?
    open lazy var reservationAttributes = [String]() // ReservationAttribute
    
    // OpenWeek: More
    open var lockOffUnits : [InventoryUnit]?
    open lazy var checkInDates = [String]()
    open var masterUnitNumber : String?
  
    // Deposit: More
    open var exchangeNumber : Int?
    open var requestType : String? // RequestType
    open var expirationDate : String?
    open var programPoints : Int = 0
    open var insurancePurchase : String?
    open var homeReplacementWeek : Bool = false
    
    // Extra
    open var saved : Bool = false

    public init(openWeek: OpenWeek) {
        relinquishmentId = openWeek.relinquishmentId
        actions = openWeek.actions
        relinquishmentYear = openWeek.relinquishmentYear
        exchangeStatus = openWeek.exchangeStatus
        weekNumber = openWeek.weekNumber
        resort = openWeek.resort
        unit = openWeek.unit
        checkInDate = openWeek.checkInDate
        checkOutDate = openWeek.checkOutDate
        pointsProgramCode = openWeek.pointsProgramCode
        promotion = openWeek.promotion
        
        // OpenWeek: Virtual Week Actions
        virtualWeekActions = openWeek.virtualWeekActions
        
        // OpenWeek: Flags
        if let value = openWeek.pointsMatrix {
            pointsMatrix = value
        }
        if let value = openWeek.blackedOut {
            blackedOut = value
        }
        if let value = openWeek.memberUnitLocked {
            memberUnitLocked = value
        }
        if let value = openWeek.bulkAssignment {
            bulkAssignment = value
        }
        if let value = openWeek.payback {
            payback = value
        }
        if let value = openWeek.waitList {
            waitList = value
        }
 
        // OpenWeek: Additional Info
        if !openWeek.reservationAttributes.isEmpty {
            if openWeek.reservationAttributes.contains(ReservationAttribute.RESORT_CLUB.name) {
                // Keep only RESORT_CLUB as ReservationAttributes
                reservationAttributes.append(ReservationAttribute.RESORT_CLUB.name)
            } else {
                reservationAttributes = openWeek.reservationAttributes
            }
            
            fixWeekReservation = FixWeekReservation()
        }

        // OpenWeek: More
        if let marterUnit = unit {
            // Set the relinqId for Master Unit
            marterUnit.relinquishmentId = relinquishmentId
            // Get the lockOffUnits
            if !marterUnit.lockOffUnits.isEmpty {
                lockOffUnits = marterUnit.lockOffUnits
            }
            // Clean the Master Unit if only comes lock-offs
            if let unitNumber = marterUnit.unitNumber, unitNumber.isEmpty {
                unit = nil
            }
        }
        checkInDates = filterOutChechInDatesWithLessThan14DaysFromToday(checkInDates: openWeek.checkInDates)
        masterUnitNumber = openWeek.masterUnitNumber
    }
    
    public init(deposit: Deposit) {
        relinquishmentId = deposit.relinquishmentId
        actions = deposit.actions
        relinquishmentYear = deposit.relinquishmentYear
        exchangeStatus = deposit.exchangeStatus
        weekNumber = deposit.weekNumber
        resort = deposit.resort
        unit = deposit.unit
        checkInDate = deposit.checkInDate
        checkOutDate = deposit.checkOutDate
        pointsProgramCode = deposit.pointsProgramCode
        promotion = deposit.promotion
        
        // Deposit: Virtual Week Actions
        virtualWeekActions = deposit.virtualWeekActions
        homeReplacementWeek = deposit.homeReplacementWeek
        
        // Deposit: Flags
        if let value = deposit.waitList {
            waitList = value
        }
        if let value = deposit.supplementalWeek {
            supplementalWeek = value
        }

        // Deposit: More
        exchangeNumber = deposit.exchangeNumber
        requestType = deposit.requestType
        expirationDate = deposit.expirationDate
        insurancePurchase = deposit.insurancePurchase
        if let value = deposit.programPoints {
            programPoints = value
        }
    }
    
    open func isDeposit() -> Bool {
        return exchangeNumber != nil
    }
    
    open func hasActions() -> Bool {
        return !actions.isEmpty
    }
    
    open func hasResort() -> Bool {
        return resort != nil
    }
    
    open func hasResortPhoneNumber() -> Bool {
        guard let r = resort, let p = r.phone else { return false }
        return !p.isEmpty
    }

    open func hasCheckInDates() -> Bool {
        return !checkInDates.isEmpty
    }
    
    open func hasVirtualWeeksActions() -> Bool {
        return !virtualWeekActions.isEmpty
    }
    
    open func supressCheckInDate() -> Bool {
        return hasVirtualWeeksActions() && virtualWeekActions.contains(VirtualWeekAction.SUPPRESS_VIRTUAL_DATES.rawValue)
    }
    
    open func supressWeekNumber() -> Bool {
        return hasVirtualWeeksActions() && virtualWeekActions.contains(VirtualWeekAction.SUPPRESS_VIRTUAL_WEEK.rawValue)
    }
    
    open func requireAdditionalInfo() -> Bool {
        return !reservationAttributes.isEmpty
    }
    
    open func requireClubResort() -> Bool {
        return requireAdditionalInfo() && reservationAttributes.contains(ReservationAttribute.RESORT_CLUB.rawValue)
    }
    
    open func requireReservationNumber() -> Bool {
        return requireAdditionalInfo() && reservationAttributes.contains(ReservationAttribute.RESERVATION_NUMBER.rawValue)
    }
    
    open func requireUnitNumberAndUnitSize() -> Bool {
        return requireAdditionalInfo() && reservationAttributes.contains(ReservationAttribute.UNIT_NUMBER.rawValue)
    }
    
    open func requireCheckInDateAndWeekNumber() -> Bool {
        return requireAdditionalInfo() && reservationAttributes.contains(ReservationAttribute.CHECK_IN_DATE.rawValue)
    }
    
    open func resetReservation() {
        if fixWeekReservation != nil {
            fixWeekReservation = FixWeekReservation()
        }
    }
    
    open func refreshReservationAttributes(reservationAttributes: [ReservationAttribute]) {
        refreshReservationAttributes(reservationAttributes: reservationAttributes.map { $0.name })
    }
    
    open func refreshReservationAttributes(reservationAttributes: [String]) {
        self.reservationAttributes = reservationAttributes
    }
    
    fileprivate func filterOutChechInDatesWithLessThan14DaysFromToday(checkInDates: [String]) -> [String] {
        var newCheckInDates = [String]()
        if !checkInDates.isEmpty {
            for checkInDate in checkInDates {
                let diff = getDaysUntilCheckInDate(checkInDate: checkInDate)
                if diff > 14 {
                    newCheckInDates.append(checkInDate)
                }
            }
        }
        return newCheckInDates
    }
    
    fileprivate func getDaysUntilCheckInDate(checkInDate: String) -> Int {
        let today = Date()
        return today.daysBetween(to: checkInDate.dateFromShortFormat()!)
    }
}
