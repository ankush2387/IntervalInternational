//
//  PersistentSettings.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

struct PersistentSettings { }

extension PersistentSettings: PersistentSettingsStore {
    var backgroundImageIndex: Int? {
        get {
            let key = Persistent.backgroundImageIndex.key
            return UserDefaults.standard.value(forKey: key) as? Int
        }
        set {
            let key = Persistent.backgroundImageIndex.key
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    var touchIDEnabled: Bool {
        get {
            let key = Persistent.touchIDEnabled.key
            return UserDefaults.standard.bool(forKey: key)
        }
        set {
            let key = Persistent.touchIDEnabled.key
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
