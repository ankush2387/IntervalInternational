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

    func showBannerNotification(with title: String, subtitle: String, for type: RMessageType) {

        RMessage.showNotification(in: self,
                                  title: title,
                                  subtitle: subtitle,
                                  type: type,
                                  customTypeName: nil,
                                  duration: TimeInterval(2),
                                  callback: nil)
    }
}
