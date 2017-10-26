//
//  SVProgressHUD+Async.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SVProgressHUD

extension UIViewController {

    func showHudAsync() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.clear)
        }
    }

    func hideHudAsync() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}
