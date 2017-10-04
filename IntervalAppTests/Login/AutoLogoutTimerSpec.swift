//
//  IntervalAppTests.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 10/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Quick
import Nimble
@testable import IntervalApp

private let secondsBeforeWarning = Double(2)
private let getsWarnedTimeout = secondsBeforeWarning + 0.5
private let secondsBeforeAutologout = Double(1)
private let getsAutologoutTimeout = getsWarnedTimeout + secondsBeforeAutologout + 0.5

private final class MockAutoLogoutCoordinator: AutoLogoutDelegate {
    
    // MARK: - Public properties
    var didGetWarned = false
    var didStopWarning = false
    var warningTimeLeft: Int?
    var didGetAutoLogout = false
    
    // MARK: - Public functions
    func startWarning() {
        didGetWarned = true
    }
    
    func stopWarning() {
        didStopWarning = true
    }
    
    func warningTimeLeft(seconds: Int) {
        warningTimeLeft = seconds
    }
    
    func startAutoLogout() {
        didGetAutoLogout = true
    }
}

final class AutoLogoutTimerSpec: QuickSpec {
    
    // swiftlint:disable:next function_body_length
    override func spec() {
        
        var sut = AutoLogoutTimer()
        sut.autoLogoutSeconds = secondsBeforeWarning
        sut.countDownSeconds = secondsBeforeAutologout
        var delegate = MockAutoLogoutCoordinator()
        
        describe("an autologout timer") {
            beforeEach {
                sut = AutoLogoutTimer()
            }
            
            describe("before starting") {
                it("is not running") {
                    expect(sut.currentTimerRemainingInterval).to(beNil())
                }
            }
            
            describe("after starting") {
                it("begins running") {
                    sut.restart()
                    expect(sut.currentTimerRemainingInterval).toEventually(beGreaterThan(0))
                }
            }
            
            describe("after starting and stopping") {
                it("stops running") {
                    sut.restart()
                    sut.stop()
                    expect(sut.currentTimerRemainingInterval).toEventually(beNil())
                }
            }
        }
        
        describe("an autologout coordinator delegate") {
            beforeEach {
                sut = AutoLogoutTimer()
                sut.autoLogoutSeconds = secondsBeforeWarning
                sut.countDownSeconds = secondsBeforeAutologout
                delegate = MockAutoLogoutCoordinator()
                sut.delegate = delegate
            }
            
            describe("after starting the timer") {
                beforeEach {
                    sut.restart()
                }
                
                it("gets warned") {
                    expect(delegate.didGetWarned).toEventually(beTrue(), timeout: getsWarnedTimeout, description: "")
                }
                
                it("gets warning time updates") {
                    expect(delegate.warningTimeLeft).toEventually(beGreaterThan(0), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
                
                it("gets logged out") {
                    expect(delegate.didGetAutoLogout).toEventually(beTrue(), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
                
            }
            
            describe("after starting and stopping the timer") {
                beforeEach {
                    sut.restart()
                    sut.stop()
                }
                
                it("does not get warned") {
                    expect(delegate.didGetWarned).toEventually(beFalse(), timeout: getsWarnedTimeout, pollInterval: 1, description: "")
                }
                
                it("does not get warning time updates") {
                    expect(delegate.warningTimeLeft).toEventually(beNil(), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
                
                it("does not get logged out") {
                    expect(delegate.didGetAutoLogout).toEventually(beFalse(), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
            }
            
            describe("after starting the timer and the app is foregrounded prior to autologout firing") {
                beforeEach {
                    sut.restart()
                    sut.applicationEnteredForeground()
                }
                
                it("does not get warned") {
                    expect(delegate.didGetWarned).toEventually(beFalse(), timeout: getsWarnedTimeout, pollInterval: 1, description: "")
                }
                
                it("keeps getting warning time updates") {
                    expect(delegate.warningTimeLeft).toEventually(beGreaterThan(0), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
                
                it("does get logged out") {
                    expect(delegate.didGetAutoLogout).toEventually(beTrue(), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
                
                it("stops the warning") {
                    expect(delegate.didStopWarning).toEventually(beTrue(), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                }
            }
            
            describe("after starting the timer and the app is foregrounded after the autologout should have fired") {
                beforeEach {
                    sut.restart()
                    // Simulate going to background
                    sut.applicationEnteredBackground()
                    DispatchQueue.main.asyncAfter(deadline: .now() + getsAutologoutTimeout) { _ in
                        sut.applicationEnteredForeground()
                        
                        it("does not get warned") {
                            expect(delegate.didGetWarned).toEventually(beFalse(), timeout: getsWarnedTimeout, pollInterval: 1, description: "")
                        }
                        
                        it("keeps getting warning time updates") {
                            expect(delegate.warningTimeLeft).toEventually(beGreaterThan(0), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                        }
                        
                        it("does get logged out") {
                            expect(delegate.didGetAutoLogout).toEventually(beTrue(), timeout: getsAutologoutTimeout, pollInterval: 1, description: "")
                        }
                    }
                }
            }
        }
    }
}
