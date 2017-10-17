//
//  ComputationHelperSpec.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Quick
import Nimble
@testable import IntervalApp

final class ComputationHelperSpec: QuickSpec { }

extension ComputationHelperSpec: ComputationHelper {
    override func spec() {
        describe("An index increment function") {
            
            let indexesWithinRange = [0, 1, 2, 3, 4, 5, 6]
            let indexesOutsideRange = [7, 8, 9, 10]
            let range = 0..<7
            
            describe("When incrementing indexes within the range") {
                it("should not overflow to first index zero") {
                    for index in indexesWithinRange {
                        expect(self.rotate(index, within: range)).to(equal(index + 1))
                    }
                }
            }
            
            describe("When incrementing indexes outside the range") {
                it("should overflow to first index zero") {
                    for index in indexesOutsideRange {
                        expect(self.rotate(index, within: range)).to(equal(0))
                    }
                }
            }
        }
    }
}
