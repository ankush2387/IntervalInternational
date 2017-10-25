//
//  DictionaryMapAllValuesSpec.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 10/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Nimble
import Quick

@testable import IntervalApp

final class DictionaryMapAllValuesSpec: QuickSpec {

    let sourceDictionary: [Int : Any] = [0: "A", 1: "B", 2: 2, 3: 3]

    override func spec() {

        describe(".mapPairs(key, value)") {

            it("iterates through the values in the dictionary allowing for transformation of the values into another type") {
                let mappedStringDictionary = self.sourceDictionary.mapPairs { ($0, String(describing: $1)) }
                expect(mappedStringDictionary.count) == 4
                mappedStringDictionary.forEach { expect($0.value.isEmpty) == false }
            }

            it("Should produce four value key pairs, but only two should have succesfully cast to Ints") {
                let mappedIntDictionary = self.sourceDictionary.mapPairs { ($0, $1 as? Int) }
                expect(mappedIntDictionary.count) == 4
                expect(mappedIntDictionary.flatMap { $0.value }.count) == 2
            }
        }
    }
}

