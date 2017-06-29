//
//  ShareActivityURL.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class ShareActivityURL: NSObject, UIActivityItemSource {
    var activityURL: String
    
    init(activityURL: String) {
        self.activityURL = activityURL
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.mail {
            return ""
        }
        
        if activityType == UIActivityType.message {
            return "https://www.intrvl.com/resort/\(activityURL)"
        }
        
        return URL(string: "https://www.intervalworld.com/web/cs?a=1503&resortCode=\(activityURL)")
    }

}
