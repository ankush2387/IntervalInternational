//
//  SVProgressHUD+Async.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 3/6/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation
import SVProgressHUD

protocol AsyncTasks { }

extension AsyncTasks {
    
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.clear)
        }
    }
    
    func dismissLoadingIndicator() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}
