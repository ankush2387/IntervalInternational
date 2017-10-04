//
//  main.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import Foundation

UIApplicationMain(CommandLine.argc,
                  UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self,
                                                                             capacity:Int(CommandLine.argc)),
                                                                             NSStringFromClass(IntervalApplication.self),
                                                                             NSStringFromClass(AppDelegate.self))
