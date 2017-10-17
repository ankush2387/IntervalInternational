//
//  AutoLogoutTimer.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol AutoLogoutDelegate: class {
    func startWarning()
    func stopWarning()
    func warningTimeLeft(seconds: Int)
    func startAutoLogout()
}

final class AutoLogoutTimer {
    
    // MARK: - Public properties
    weak var delegate: AutoLogoutDelegate?
    
    var currentTimerRemainingInterval: TimeInterval? {
        return logoutTimer?.fireDate.timeIntervalSinceNow
    }
    
    /// Number in seconds before the coordinator delegate will be notified to start autologout countdown
    var autoLogoutSeconds: Double = 1200
    
    /// Number of seconds coordinator delegate will be given a countdown before patient logout is triggered.
    var countDownSeconds: Double = 30 {
        didSet {
            countDown = countDownSeconds
        }
    }
    
    // MARK: - Private properties
    private var backgroundTimeStamp = Date()
    private var warningNotificationDelay: Double {
        return autoLogoutSeconds - countDownSeconds
    }
    private var logoutTimer: Timer?
    private var countDown: Double
    
    init() {
        countDown = countDownSeconds
    }
    
    // MARK: - Public functions
    
    func restart() {
        startWarningNotificationTimer()
    }
    
    func stop() {
        logoutTimer?.invalidate()
        logoutTimer = nil
    }
    
    /// Only call this function after the application has entered the foreground.
    /// It will autologout if the timer has expired.
    func applicationEnteredForeground() {
        delegate?.stopWarning()
        var elapsedTime: TimeInterval
        /* The firedate for the repeating countdown timer is one second in the future so we use 30 seconds from the
         background timestamp as the logout time. Otherwise we use the remaining time from the non-repeating timer.
         */
        if logoutTimer?.timeInterval == TimeInterval(1.0) {
            elapsedTime = (backgroundTimeStamp + 30).timeIntervalSinceNow
        } else {
            elapsedTime = currentTimerRemainingInterval ?? TimeInterval(countDown)
        }
        if elapsedTime < TimeInterval(0) {
            stop()
            delegate?.startAutoLogout()
        } else {
            restart()
        }
    }
    
    func applicationEnteredBackground() {
        backgroundTimeStamp = Date()
    }
    
    // MARK: - private functions
    
    private func startWarningNotificationTimer() {
        stop()
        logoutTimer = Timer.scheduledTimer(timeInterval: warningNotificationDelay,
                                           target: self,
                                           selector: #selector(autoLogoutWarningTimerFired),
                                           userInfo: nil,
                                           repeats: false)
    }
    
    private func startCountDownTimer() {
        stop()
        countDown = countDownSeconds
        logoutTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(countDownTimerFired),
                                           userInfo: nil,
                                           repeats: true)
        logoutTimer?.tolerance = 0.1
    }
    
    // MARK: - @objc private func
    
    @objc private func countDownTimerFired() {
        if countDown > 0 {
            delegate?.warningTimeLeft(seconds: Int(countDown))
            countDown -= 1
        } else {
            delegate?.startAutoLogout()
            stop()
        }
    }
    
    @objc private func autoLogoutWarningTimerFired() {
        startCountDownTimer()
        delegate?.startWarning()
    }
}
