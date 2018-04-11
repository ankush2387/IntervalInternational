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

    open func getRelinquishmentSections(myUnits: MyUnits) -> RelinquishmentSections {
        let sections = RelinquishmentSections()
        
        if let value = myUnits.pointsProgram {
            sections.cigPointsProgram = value
        }
        
        // Grouping OpenWeeks
        if !myUnits.openWeeks.isEmpty {
            for openWeek in myUnits.openWeeks {
                if let value = openWeek.pointsProgramCode, PointsProgramCode.fromName(name: value).isCIG() {
                    sections.cigPointsWeeks.append(Relinquishment(openWeek: openWeek))
                } else if let value = openWeek.weekNumber, WeekNumber.fromName(name: value).isPointWeek() {
                    sections.pointsWeeks.append(Relinquishment(openWeek: openWeek))
                } else {
                    sections.intervalWeeks.append(Relinquishment(openWeek: openWeek))
                }
            }
        }
        
        // Grouping Deposits
        if !myUnits.deposits.isEmpty {
            for deposit in self.filterDeposits(deposits: myUnits.deposits) {
                sections.intervalWeeks.append(Relinquishment(deposit: deposit))
            }
        }

        return sort(sections: sections)
    }
    
    open func groupRelinquishmentsByResort(relinquishments: [Relinquishment]) -> [RelinquishmentGroup] {
        var groups = [RelinquishmentGroup]()
        
        if !relinquishments.isEmpty {
            var groupByResortDic = [String: [Relinquishment]]()
            for relinq in relinquishments {
                if let resort = relinq.resort, let resortCode = resort.resortCode {
                    if var list = groupByResortDic[resortCode] {
                        list.append(relinq)
                        groupByResortDic[resortCode] = list
                    } else {
                        var list = [Relinquishment]()
                        list.append(relinq)
                        groupByResortDic[resortCode] = list
                    }
                }
            }
            
            for list in groupByResortDic.values {
                let group = RelinquishmentGroup()
                group.resort = list.first?.resort
                group.relinquishments = list
                groups.append(group)
            }
        }
        
        return groups
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
    // Sort Relinquishment Sections
    //
    fileprivate func sort(sections: RelinquishmentSections) -> RelinquishmentSections {
        // Sort by:
        //  Relinquishment Year (ASC)
        //  Resort Name (ASC)
        //  OpenWeeks with actions
        //  Deposits with actions
        //  OpenWeeks without actions
        //  Deposits without actions
        //
        
        // Resort Name (ASC - alphabetical: A -> Z)
        sections.cigPointsWeeks.sort(by: {$0.resort?.resortName?.localizedCaseInsensitiveCompare(
            ($1.resort?.resortName!)!) == ComparisonResult.orderedAscending})
        sections.pointsWeeks.sort(by: {$0.resort?.resortName?.localizedCaseInsensitiveCompare(
            ($1.resort?.resortName!)!) == ComparisonResult.orderedAscending})
        sections.intervalWeeks.sort(by: {$0.resort?.resortName?.localizedCaseInsensitiveCompare(
            ($1.resort?.resortName!)!) == ComparisonResult.orderedAscending})
        
        // Relinquishment Year (alphabetical: A -> Z)
        sections.cigPointsWeeks.sort(by: {$0.relinquishmentYear! < $1.relinquishmentYear!})
        sections.pointsWeeks.sort(by: {$0.relinquishmentYear! < $1.relinquishmentYear!})
        sections.intervalWeeks.sort(by: {$0.relinquishmentYear! < $1.relinquishmentYear!})
       
        return sections
    }
    
}
