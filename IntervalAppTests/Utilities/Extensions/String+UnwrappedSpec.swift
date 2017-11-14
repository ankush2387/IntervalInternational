//
//  String+UnwrappedSpec.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 10/17/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Quick
import Nimble
@testable import IntervalApp

class String_UnwrappedSpec: QuickSpec {
    
    override func spec() {
        
        let emptyStringOne: Optional<String> = ""
        let emptyStringTwo: Optional<String> = nil
        let emptyStringThree: Optional<Int> = 40
        let emptyStringFour: Optional<Int> = nil
        let stringWithValueOne: Optional<String> = "Hello World"
        let stringWithValueTwo: Optional<Int> = 1010101
        let stringWithValueThree: Optional<Date> = Date()
        
        describe("The behavior for the unwrappedString extension on optional type") {
            
            it("should return an empty string for a non supported value or already empty string") {
                expect(emptyStringOne.unwrappedString).to(beEmpty())
                expect(emptyStringTwo.unwrappedString).to(beEmpty())
                expect(emptyStringThree.unwrappedString).to(beEmpty())
                expect(emptyStringFour.unwrappedString).to(beEmpty())
                expect(stringWithValueTwo.unwrappedString).to(beEmpty())
                expect(stringWithValueThree.unwrappedString).to(beEmpty())
            }
            
            it("Should return an unwrapped string") {
                expect(stringWithValueOne.unwrappedString) == "Hello World"
            }
        }
    }
}
