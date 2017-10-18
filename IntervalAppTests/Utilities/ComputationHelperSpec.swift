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
        
        describe("The ComputationHelper checkIfPassedIn version checker functionality") {
            it("Should correctly check if passed in version is newer or older than passed in current version") {
                
                let currentVersion = "1.0"
                let olderVersions = ["0", "0.9", "000.9999999.999999", "0000.000000.00"]
                let newerVersions = ["1.5", "2.1.2", "3.0.3", "5", "5.0", "5.6.0", "1000000.0.0", "1000000.0.1", "10000.000.000"]
                
                expect(self.checkIfPassedIn(currentVersion, isNewerThan: currentVersion)).to(beFalse())
                
                for version in olderVersions {
                    expect(self.checkIfPassedIn(version, isNewerThan: currentVersion)).to(beFalse())
                }
                
                for version in newerVersions {
                    expect(self.checkIfPassedIn(version, isNewerThan: currentVersion)).to(beTrue())
                }
            }
        }
    }
}
