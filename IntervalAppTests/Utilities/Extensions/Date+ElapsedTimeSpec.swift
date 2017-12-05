//
//  Date+ElapsedTimeSpec.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 10/20/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Nimble
import Quick

@testable import IntervalApp

class Date_ElapsedTimeSpec: QuickSpec {
    
    override func spec() {
        
        describe("The elapsed minutes extension variable") {
            
            it("Should correctly calculate the number of elapsed minutes") {
                
                // Note: Time delay async Unit Tests should not exceed one minute
                // Otherwise it will affect our CI/CD build times too greatly
                
                let dateToCheck = Date()
                let sixtySeconds = 60.0
                
                waitUntil(timeout: sixtySeconds + 5) { done in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + sixtySeconds) {
                        expect(dateToCheck.numberOfMinutesElapsedFromDate) == 1
                        done()
                    }
                }
            }
        }
    }
}
