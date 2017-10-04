//
//  AutoLogoutTimer.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol IntervalApplicationDelegate: class {
    func userDidTouchScreen()
}

final class IntervalApplication: UIApplication {
    
    // MARK: - Public properties
    weak var callbackDelegate: IntervalApplicationDelegate?
    
    // MARK: - Overrides
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        // swiftlint:disable empty_count
        if let allTouches = event.allTouches as NSSet?, let phase = (allTouches.anyObject() as? UITouch)?.phase,
            allTouches.count > 0, phase == .began {
            callbackDelegate?.userDidTouchScreen()
        }
    }
}
