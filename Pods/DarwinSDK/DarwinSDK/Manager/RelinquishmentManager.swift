//
//  RelinquishmentManager.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

open class RelinquishmentManager {
    
    public init() {
    }

    open func getRelinquishmentGroups(myUnits: MyUnits) -> RelinquishmentGroups {
        let groups = RelinquishmentGroups()
        
        if let value = myUnits.pointsProgram {
            groups.cigPointsProgram = value
        }
        
        // Grouping OpenWeeks
        for openWeek in myUnits.openWeeks {
            if let value = openWeek.pointsProgramCode, PointsProgramCode.fromName(name: value).isCIG() {
                groups.cigPointsWeeks.append(Relinquishment(openWeek: openWeek))
            } else if let value = openWeek.weekNumber, WeekNumber.fromName(name: value).isPointWeek() {
               groups.pointsWeeks.append(Relinquishment(openWeek: openWeek))
            } else {
                groups.intervalWeeks.append(Relinquishment(openWeek: openWeek))
            }
        }
        
        // Grouping Deposits
        for deposit in self.filterDeposits(deposits: myUnits.deposits) {
        //for deposit in myUnits.deposits {
            groups.intervalWeeks.append(Relinquishment(deposit: deposit))
        }
       
        return sort(gropus: groups)
    }

    //
    // Filter Deposits
    //
    fileprivate func filterDeposits(deposits: [Deposit]) -> [Deposit] {
        var filteredDeposits = [Deposit]()
        
        for deposit in deposits {
            // Filter out deposits based on:
            //  Rule-1: expired for >90 days
            //  Rule-2: PointsProgram is CIG and non actions
            
            if !excludeDeposit(deposit: deposit) {
                filteredDeposits.append(deposit)
            }
        }
        return filteredDeposits
    }
    
    fileprivate func excludeDeposit(deposit: Deposit) -> Bool {
        return evaluateFilterOutByExpirationDateGreatThan90Days(deposit: deposit) || evaluateFilterOutByCIGPointsProgramWithNoActions(deposit: deposit)
    }
    
    fileprivate func evaluateFilterOutByExpirationDateGreatThan90Days(deposit: Deposit) -> Bool {
        let diff = deposit.getDaysUntilExpirationDate()
        if diff < 0 && abs(diff) > 90 {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func evaluateFilterOutByCIGPointsProgramWithNoActions(deposit: Deposit) -> Bool {
        if let value = deposit.pointsProgramCode, PointsProgramCode.fromName(name: value).isCIG(), deposit.actions.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    //
    // Sort Relinquishment Groups
    //
    fileprivate func sort(gropus: RelinquishmentGroups) -> RelinquishmentGroups {
        
        // Sort by:
        //  Relinquishment Year (ASC)
        //  Resort Name (ASC)
        //  OpenWeeks with actions
        //  Deposits with actions
        //  OpenWeeks without actions
        //  Deposits without actions
        //
        return gropus
    }
    
}
