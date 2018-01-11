//
//  File.swift
//  IntervalApp
//
//  Created by Chetu on 07/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import RealmSwift
import DarwinSDK
import DarwinSDK.Swift

class RealmLocalStorage: Object {
    
    var resorts = List<ResortList>()
    var destinations = List<DestinationList>()
    dynamic var membeshipNumber = ""
    
}

final class OpenWeeksStorage: Object {
    var resorts = List<ResortList>()
    var openWeeks = List<TradeLocalData>()
    var membeshipNumber = ""
}

final class DestinationList: Object {
    
    dynamic var destinationName = ""
    dynamic var destinationId = ""
    dynamic var territorrycode = ""
    dynamic var countryCode = ""
    dynamic var aoid = ""
}

final class ResortList: Object {
    
    dynamic var resortName = ""
    dynamic var resortCode = ""
    dynamic var thumbnailurl = ""
    dynamic var resortCityName = ""
    dynamic var countryCode = ""
    dynamic var territorrycode = ""
    var units = InventoryUnit()
    var resortArray = List<ResortByMap>()
}
final class ResortUnitDetails: Object {
    dynamic var kitchenType = ""
    dynamic var unitSize = ""
}
final class ResortFloatDetails: Object {
    dynamic var reservationNumber = ""
    dynamic var unitNumber = ""
    dynamic var unitSize = ""
    dynamic var checkInDate = ""
    dynamic var clubResortDetails = ""
    dynamic var showUnitNumber = true
}

final class ResortByMap: Object {
    
    dynamic var resortName = ""
    dynamic var resortCode = ""
    dynamic var thumbnailurl = ""
    dynamic var resortCityName = ""
    dynamic var countryCode = ""
    dynamic var territorrycode = ""
}

final class AllAvailableDestination: Object {
    
     dynamic var destination = ""
}

final class TradeLocalData: Object {
    
    var openWeeks = List<OpenWeeks>()
    var pProgram = List<rlmPointsProgram>()
    var deposits = List<Deposits>()
    var clubPoints = List<ClubPoints>()
}

final class rlmPointsProgram: Object {
    
    dynamic var relinquishmentId = ""
    dynamic var code = ""
    dynamic var availablePoints = 0
    dynamic var pointsSpent = 0
    
}
final class OpenWeeks: Object {
    
    dynamic var relinquishmentID = ""
    dynamic var pointsProgramCode = ""
    dynamic var exchangeStatus = ""
    dynamic var weekNumber = ""
    dynamic var relinquishmentYear = 0
    dynamic var isLockOff = false
    dynamic var isFloat = false
    dynamic var isFloatRemoved = false
    dynamic var isFromRelinquishment = false
    var resort = List<ResortList>()
    var unitDetails = List<ResortUnitDetails>()
    var floatDetails = List<ResortFloatDetails>()
    //dynamic var units = [InventoryUnit]()
}

final class Deposits: Object {
    dynamic var relinquishmentID = ""
    dynamic var pointsProgramCode = ""
    dynamic var exchangeStatus = ""
    dynamic var weekNumber = ""
    dynamic var relinquishmentYear = 0
    dynamic var isLockOff = false
    dynamic var isFloat = false
    dynamic var isFloatRemoved = false
    dynamic var isFromRelinquishment = false
    var resort = List<ResortList>()
    var unitDetails = List<ResortUnitDetails>()
    var floatDetails = List<ResortFloatDetails>()
}

final class ClubPoints: Object {
    dynamic var relinquishmentId = ""
    var resort = List<ResortList>()
    dynamic var pointsSpent = 0
    dynamic var isPointsMatrix = false
    dynamic var relinquishmentYear = 0
}
