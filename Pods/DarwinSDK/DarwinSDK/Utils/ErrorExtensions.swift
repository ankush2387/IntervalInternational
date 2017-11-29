//
//  ErrorExtensions.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 7/24/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
