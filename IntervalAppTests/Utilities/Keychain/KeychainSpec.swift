//
//  KeychainSpec.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 11/4/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Quick
import Nimble
@testable import IntervalApp

final class KeychainSpec: QuickSpec {

    override func spec() {

        describe("The Keychain wrapper struct with generic read and write methods") {

            let keychain = Keychain(service: "Mock Keychain Service")

            describe("The behavior when saving generic values to keychain") {
                it("should save and retrieve the Strings successfully") {

                    do {
                        try keychain.save(item: "ABC", for: "Key 1", and: "123456789")
                        try keychain.save(item: "DEF", for: "Key 2")
                        try keychain.save(item: "GHI", for: "Key 3")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: String())
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: String())
                        let valueThree = try keychain.getItem(for: "Key 3", ofType: String())
                        expect(valueOne) == "ABC"
                        expect(valueTwo) == "DEF"
                        expect(valueThree) == "GHI"
                    } catch {
                        fail()
                    }
                }

                it("should save and retrieve the Ints successfully") {

                    do {
                        try keychain.save(item: 123, for: "Key 1", and: "123456789")
                        try keychain.save(item: 456, for: "Key 2")
                        try keychain.save(item: 789, for: "Key 3")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: Int())
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: Int())
                        let valueThree = try keychain.getItem(for: "Key 3", ofType: Int())
                        expect(valueOne) == 123
                        expect(valueTwo) == 456
                        expect(valueThree) == 789
                    } catch {
                        fail()
                    }
                }

                it("should save and retrieve the Doubles successfully") {

                    do {
                        try keychain.save(item: 1.5, for: "Key 1", and: "123456789")
                        try keychain.save(item: 1.99, for: "Key 2")
                        try keychain.save(item: 255, for: "Key 3")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: Double())
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: Double())
                        let valueThree = try keychain.getItem(for: "Key 3", ofType: Double())
                        expect(valueOne) == 1.5
                        expect(valueTwo) == 1.99
                        expect(valueThree) == 255
                    } catch {
                        fail()
                    }
                }

                it("should save and retrieve the Bools successfully") {

                    do {
                        try keychain.save(item: true, for: "Key 1", and: "123456789")
                        try keychain.save(item: false, for: "Key 2")
                        try keychain.save(item: true == false, for: "Key 3")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: Bool())
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: Bool())
                        let valueThree = try keychain.getItem(for: "Key 3", ofType: Bool())
                        expect(valueOne) == true
                        expect(valueTwo) == false
                        expect(valueThree) == false
                    } catch {
                        fail()
                    }
                }

                it("should save and retrieve arrays (even of mixed type) successfully") {

                    do {
                        try keychain.save(item: ["abc", "def", "ghi"], for: "Key 1", and: "123456789")
                        try keychain.save(item: [1, 2, 3], for: "Key 2")
                        try keychain.save(item: ["abc", "def", 123], for: "Key 3")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: [String]())
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: [Int]())
                        let valueThree = try keychain.getItem(for: "Key 3", ofType: [AnyHashable]())
                        expect(valueOne) == ["abc", "def", "ghi"]
                        expect(valueTwo) == [1, 2, 3]
                        expect(valueThree) == ["abc", "def", 123]
                    } catch {
                        fail()
                    }
                }

                it("should save and retrieve sets successfully") {

                    do {
                        try keychain.save(item: Set([1, 1, 2, 2, 3]), for: "Key 1", and: "123456789")
                        try keychain.save(item: Set(["one", "two", "one", "two"]), for: "Key 2")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: Set([1]))
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: Set(["one"]))
                        expect(valueOne) == Set([1, 2, 3])
                        expect(valueTwo) == Set(["one", "two"])
                    } catch {
                        fail()
                    }
                }

                it("should save and retrieve dictionaries successfully") {

                    do {
                        try keychain.save(item: ["one": 1, "two": 2], for: "Key 1", and: "123456789")
                        try keychain.save(item: [1: "one", 2: "two"], for: "Key 2")
                    } catch {
                        fail()
                    }

                    do {
                        let valueOne = try keychain.getItem(for: "Key 1", and: "123456789", ofType: [String: Int]())
                        let valueTwo = try keychain.getItem(for: "Key 2", ofType: [Int: String]())
                        expect(valueOne) == ["one": 1, "two": 2]
                        expect(valueTwo) == [1: "one", 2: "two"]
                    } catch {
                        fail()
                    }
                }
            }
        }
    }
}
