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


class RealmLocalStorage:Object {
    
    var resorts = List<ResortList>()
    var destinations = List<DestinationList>()
    //var openWeeks = List<TradeLocalData>()
    dynamic var membeshipNumber = ""
}

class OpenWeeksStorage:Object {
    var resorts = List<ResortList>()
    var openWeeks = List<TradeLocalData>()
    dynamic var membeshipNumber = ""
}

class DestinationList:Object {
    
    dynamic var destinationName = ""
    dynamic var destinationId = ""
    dynamic var territorrycode = ""
    dynamic var countryCode = ""
    dynamic var aoid = ""
}

class ResortList:Object {
    
    dynamic var resortName = ""
    dynamic var resortCode = ""
    dynamic var thumbnailurl = ""
    dynamic var resortCityName = ""
    dynamic var countryCode = ""
    dynamic var territorrycode = ""
    var resortArray = List<ResortByMap>()
}
class ResortByMap:Object {
    
    dynamic var resortName = ""
    dynamic var resortCode = ""
    dynamic var thumbnailurl = ""
    dynamic var resortCityName = ""
    dynamic var countryCode = ""
    dynamic var territorrycode = ""
}

class AllAvailableDestination:Object {
    
     var destination = ""
}

class TradeLocalData:Object {
    
    var openWeeks = List<OpenWeeks>()
    var pProgram = List<rlmPointsProgram>()
}

class rlmPointsProgram:Object {
    
    dynamic var relinquishmentId = ""
    dynamic var code = ""
    dynamic var availablePoints = 0
    dynamic var pointsSpent = 0
    
}
class OpenWeeks:Object {
    
    dynamic var relinquishmentID = ""
    dynamic var pointsProgramCode = ""
    dynamic var exchangeStatus = ""
    dynamic var weekNumber = ""
    dynamic var relinquishmentYear = 0
    var resort = List<ResortList>()
    //dynamic var units = [InventoryUnit]()
}


