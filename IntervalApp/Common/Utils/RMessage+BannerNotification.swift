//
//  RMessage+BannerNotification.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import RMessage

extension UIViewController {

    func showBannerNotification(with title: String, subtitle: String, for type: RMessageType, seconds: Int = 5) {

        RMessage.showNotification(in: self,
                                  title: title,
                                  subtitle: subtitle,
                                  type: type,
                                  customTypeName: nil,
                                  duration: TimeInterval(seconds),
                                  callback: nil)
    }

    func showAPNSPushBanner(for title: String, with message: String, callBack: (() -> Void)?) {

        // Will show only for the viability of the special (15 minutes = 900 seconds)
        // Predetermined time set by Ralph
        RMessage.showNotification(in: self,
                                  title: title,
                                  subtitle: message,
                                  iconImage: #imageLiteral(resourceName: "FavoriteIcon-On"),
                                  type: callBack == nil ? .success : .normal,
                                  customTypeName: nil,
                                  duration: TimeInterval(900),
                                  callback: callBack,
                                  buttonTitle: nil,
                                  buttonCallback: nil,
                                  at: .top,
                                  canBeDismissedByUser: true)
    }
}
