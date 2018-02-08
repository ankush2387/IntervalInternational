//
//  AvailabilityCollectionViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 8/8/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class AvailabilityCollectionViewCell: UICollectionViewCell {
    //***** Outlets *****//

    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var favourite: UIButton!
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortAddress: UILabel!
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var tierImage: UIImageView!
    @IBOutlet weak var allIncImageView: UIImageView!
    //***** class variables *****//
    //var delegate:ResortDirectoryCollectionViewCellDelegate?
    
    func setResortDetails(inventoryItem: Resort) {
        for layer in self.viewGradient.layer.sublayers! {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }

        var url = URL(string: "")
        for imgStr in inventoryItem.images {
            if imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame {
                url = URL(string: imgStr.url ?? "")
                break
            }
        }
        Helper.addLinearGradientToView(view: self.viewGradient, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        if url == nil {
            resortImageView?.image = UIImage(named: Constant.MyClassConstants.noImage)
            resortImageView.contentMode = .scaleAspectFit
        } else {
            resortImageView.contentMode = .scaleToFill
            resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }
        resortName.text = inventoryItem.resortName
        resortAddress.text = inventoryItem.address?.cityName
        resortCode.text = inventoryItem.resortCode
        if let tierImageName = inventoryItem.tier {
            tierImage.isHidden = false
            let tier = Helper.getTierImageName(tier: tierImageName.uppercased())
            if tier == "" {
                tierImage.isHidden = true
            } else {
                tierImage.image = UIImage(named: tier)
            }
        } else {
            tierImage.isHidden = true
        }
            allIncImageView.image = #imageLiteral(resourceName: "Resort_All_Inclusive")
            allIncImageView.isHidden = !inventoryItem.allInclusive
        
    }
    
}
