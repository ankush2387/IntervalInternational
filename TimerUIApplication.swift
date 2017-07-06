//
//  TimerUIApplication.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/29/17.
//  Copyright © 2017 Interval International. All rights reserved.
//  based off information found on Stack Overflow and old Interval App
//  Updated code to Swift
//  https://stackoverflow.com/questions/8085188/ios-perform-action-after-period-of-inactivity-no-user-interaction

import Foundation
import UIKit

class TimerUIApplication: UIApplication {
    static let ApplicationDidTimoutNotification = "AppTimout"
    
    // The timeout in seconds for when to fire the idle timer.
    let timeoutInSeconds: TimeInterval = 1200
    
    var idleTimer: Timer?
    
    // Resent the timer because there was user interaction.
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds, target: self, selector: #selector(TimerUIApplication.idleTimerExceeded), userInfo: nil, repeats: false)
    }
    
    // If the timer reaches the limit as defined in timeoutInSeconds, post this notification.
    func idleTimerExceeded() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationDidTimoutNotification), object: nil)
    }
    
    
    override func sendEvent(_ event: UIEvent) {
        
        super.sendEvent(event)
        
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches {
                if touch.phase == UITouchPhase.began {
                    self.resetIdleTimer()
                }
            }
        }
        
    }
}
