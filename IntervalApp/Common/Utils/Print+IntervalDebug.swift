//
//  Print+IntervalDebug.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation


/// If the print to debug console is being called when built in debug mode - Print items
func intervalPrint(_ items: Any..., separator: String = "", terminator: String = "") {

    #if DEBUG
        print(items, separator: separator, terminator: terminator)
    #endif
}

/// If the debugPrint to debug console is being called when built in debug mode - Print items
func intervalDebugPrint(_ items: Any..., separator: String = "", terminator: String = "") {

    #if DEBUG
        debugPrint(items, separator: separator, terminator: terminator)
    #endif
}
