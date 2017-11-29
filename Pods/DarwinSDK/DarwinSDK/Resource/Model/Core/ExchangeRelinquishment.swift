//
//  ExchangeRelinquishment.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeRelinquishment {
    
    open var pointsProgram : PointsProgram?
    open var clubPoints : ClubPoints?
    open var openWeek : OpenWeek?
    open var deposit : Deposit?
    open var accommodationCertificate : AccommodationCertificate?

    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if json["pointsProgram"].exists() {
            let pointsProgramJson:JSON = json["pointsProgram"]
            self.pointsProgram = PointsProgram(json:pointsProgramJson)
        }
        
        if json["clubPoints"].exists() {
            let clubPointsJson:JSON = json["clubPoints"]
            self.clubPoints = ClubPoints(json:clubPointsJson)
        }
        
        if json["openWeek"].exists() {
            let openWeekJson:JSON = json["openWeek"]
            self.openWeek = OpenWeek(json:openWeekJson)
        }
        
        if json["deposit"].exists() {
            let depositJson:JSON = json["deposit"]
            self.deposit = Deposit(json:depositJson)
        }
        
        if json["accommodationCertificate"].exists() {
            let accommodationCertificateJson:JSON = json["accommodationCertificate"]
            self.accommodationCertificate = AccommodationCertificate(json:accommodationCertificateJson)
        }
    }

    
}
