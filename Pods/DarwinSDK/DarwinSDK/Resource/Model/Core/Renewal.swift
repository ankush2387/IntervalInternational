//
//  Renewal.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Renewal {
    
    open var id : String?
    open var displayName : String?
    open var displayOrder : Int?
    open var transactionCode : String?
    open var transactionTypeCode : String?
    open var transactionTypeDescription : String?
    open var isCoreProduct : Bool = false
    open var price : Float = 0.0
    open var term : Int?
    open var productCode : String?
    open var selectedOfferName : String?
    open lazy var promotions = [Promotion]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.id = json["id"].string ?? ""
        self.displayName = json["displayName"].string ?? ""
        self.displayOrder = json["displayOrder"].intValue
        self.transactionCode = json["transactionCd"].string ?? ""
        self.transactionTypeCode = json["transTypeCd"].string ?? ""
        self.transactionTypeDescription = json["transTypeDesc"].string ?? ""
        self.isCoreProduct = json["isCoreProduct"].boolValue
        self.price = json["price"].floatValue
        self.term = json["term"].intValue
        self.productCode = json["productCd"].string ?? ""
        self.selectedOfferName = json["selectedOfferName"].string ?? ""
        
        if json["promotions"].exists() {
            let promotionsArray:[JSON] = json["promotions"].arrayValue
            self.promotions = promotionsArray.map { Promotion(json:$0) }
        }
    }
    
}
