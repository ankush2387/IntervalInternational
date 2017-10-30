//
//  Data+EncryptionKey.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension Data {
    static var encryptionKey: Data {
        var key = Data(count: 64)
        _ = key.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 64, $0) }
        return key
    }
}
