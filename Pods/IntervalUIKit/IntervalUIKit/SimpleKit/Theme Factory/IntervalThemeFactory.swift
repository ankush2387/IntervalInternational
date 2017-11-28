//
//  IntervalThemeFactory.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public struct IntervalThemeFactory {
    // MARK: - Public properties
    // MARK: - Currently only supporting iPad and iPhone
    public static let deviceTheme: Theme = UIDevice.current.userInterfaceIdiom == .phone ? .iPhone : .iPad
}
