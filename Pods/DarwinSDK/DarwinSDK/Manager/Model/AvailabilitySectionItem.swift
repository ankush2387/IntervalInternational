//
//  AvailabilitySectionItem.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class AvailabilitySectionItem {
    
    open var rentalAvailability : Resort?
    open var exchangeAvailability : ExchangeAvailability?
    
    public init(rentalAvailability:Resort) {
        self.rentalAvailability = rentalAvailability
    }
    
    public init(exchangeAvailability:ExchangeAvailability) {
        self.exchangeAvailability = exchangeAvailability
    }
    
    open func hasRentalAvailability() -> Bool {
        return self.rentalAvailability != nil
    }
    
    open func hasExchangeAvailability() -> Bool {
        return self.exchangeAvailability != nil
    }

}
