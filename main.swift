//
//  main.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/29/17.
//  Copyright © 2017 Interval International. All rights reserved.
//  based off information found on Stack Overflow and old Interval App
//  Updated code to Swift
//  https://stackoverflow.com/questions/8085188/ios-perform-action-after-period-of-inactivity-no-user-interaction

import UIKit
import Foundation

UIApplicationMain(CommandLine.argc, UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self,capacity:Int(CommandLine.argc)), NSStringFromClass(TimerUIApplication.self),NSStringFromClass(AppDelegate.self))
