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
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblRatingReviews: UILabel!
    @IBOutlet weak var ratingImgView1: UIImageView!
    @IBOutlet weak var ratingImgView2: UIImageView!
    @IBOutlet weak var ratingImgView3: UIImageView!
    @IBOutlet weak var ratingImgView4: UIImageView!
    @IBOutlet weak var ratingImgView5: UIImageView!
    
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
            self.resortImageView?.image = UIImage(named: Constant.MyClassConstants.noImage)
            self.resortImageView.contentMode = .scaleAspectFit
        } else {
            self.resortImageView.contentMode = .scaleToFill
            self.resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }
        self.resortName.text = inventoryItem.resortName
        self.resortAddress.text = inventoryItem.address?.cityName
        self.resortCode.text = inventoryItem.resortCode
        if let tierImageName = inventoryItem.tier {
             let tier = Helper.getTierImageName(tier: tierImageName.uppercased())
            self.tierImage.image = UIImage(named: tier)
        }
        
        if let reviews = inventoryItem.rating?.totalResponses {
            self.lblRatingReviews.text = "\(reviews) Member Reviews"
        }
        
    }
    
}
