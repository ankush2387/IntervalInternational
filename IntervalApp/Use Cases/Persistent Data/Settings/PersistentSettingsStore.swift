//
//  PersistentSettingsStore
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol PersistentSettingsStore {
    var backgroundImageIndex: Int? { get set }
    var touchIDEnabled: Bool { get set }
}
