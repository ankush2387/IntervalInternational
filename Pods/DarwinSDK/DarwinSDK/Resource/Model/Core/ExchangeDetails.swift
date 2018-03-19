//
//  ExchangeTripsDetails.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeDetails {
    
    open var exchangeTransactionType : String? // ExchangeTransactionType
    open var confirmationNumber : String?
    open var exchangeStatus : String? // ExchangeStatus
    open var transactionDate : String?
    open var destination : ExchangeDestination?
    open var relinquishment : ExchangeRelinquishment?
    open var ancillaryProducts : AncillaryProducts?
    open var payment : CruiseSupplementalPayment?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.exchangeTransactionType = json["type"].string ?? ""
        self.confirmationNumber = json["confirmationNumber"].string ?? ""
        self.exchangeStatus = json["status"].string ?? ""
        self.transactionDate = json["transactionDate"].string ?? ""
        
        if json["destination"].exists() {
            let destinationJson:JSON = json["destination"]
            self.destination = ExchangeDestination(json:destinationJson)
        }
        
        if json["relinquishment"].exists() {
            let relinquishmentJson:JSON = json["relinquishment"]
            self.relinquishment = ExchangeRelinquishment(json:relinquishmentJson)
        }
        
        if json["ancillaryProducts"].exists() {
            let ancillaryProductsJson:JSON = json["ancillaryProducts"]
            self.ancillaryProducts = AncillaryProducts(json:ancillaryProductsJson)
        }
        
        if json["payment"].exists() {
            let paymentJson:JSON = json["payment"]
            self.payment = CruiseSupplementalPayment(json:paymentJson)
        }
    }
    
}


