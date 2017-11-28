//
//  DictionaryExtensions.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/31/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension Dictionary  {
    
    // Custom initializer for Dictionary
    // Use it as:
    // var myDictionary = Dictionary(keyValuePairs: myArray.map{($0.position, $0.name)})
    //
    init(elements:[(Key, Value)]) {
        self.init()
        
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }
    
}
