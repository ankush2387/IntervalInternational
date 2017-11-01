//
//  ShareActivityImage.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import SDWebImage

class ShareActivityImage: NSObject, UIActivityItemSource {
    var resortImg: UIImage?
    
    func getResrtImage(strURL: String) {
        let manager = SDWebImageManager.shared()
        let imgURL = URL(string: strURL)
        manager?.downloadImage(with: imgURL, options: [], progress: { (recivedSize, expectedSize) in
            intervalPrint(recivedSize)
        }, completed: { (image, error, cached, finished, url) in
            self.resortImg = image
        })
        
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.mail {
            return self.resortImg
        }
        
        return nil
    }

}
