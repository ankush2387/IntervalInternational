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
        
        if let reviews = inventoryItem.rating?.totalResponses {
            self.lblRatingReviews.text = "\(reviews) Member Reviews"
        }
        
        // set rating view here
        
        for category in inventoryItem.rating?.categories ?? [] {
            
            let categoryCode = category.categoryCode.unwrappedString
            if categoryCode.uppercased() == "OVERALL" {
                showRating(rating: category.rating)
                break
            }
        }
    }
    
    //set rating
    func showRating(rating: Float) {
        //set empty image here
        for i in 1...5 {
            if let imageView = self.viewWithTag(i) as? UIImageView {
                imageView.image = #imageLiteral(resourceName: "empty_circle")
            }
        }
        
        func parse(_ rating: Float) -> (wholeRating: Int, hasHalfRating: Bool) {
            let parsedRating = String(rating).split(separator: ".")
            let wholeRating = Int(parsedRating.first ?? "") ?? 0
            let halfRating = Int(parsedRating.last ?? "")
            let hasHalfRating = (halfRating ?? 0) > 0
            return (wholeRating, hasHalfRating)
        }
        
        let parsedRating = parse(rating)
        
        for currentRating in 1...parsedRating.wholeRating {
            
            // Set all full circles here by creating your casting to the UIimageView
            if let imageView = self.viewWithTag(currentRating) as? UIImageView {
                imageView.image = #imageLiteral(resourceName: "full_filled_circle")
            }
            
            if currentRating == parsedRating.wholeRating && parsedRating.hasHalfRating {
                // Currently in the last rating index and has half rating
                if let imageView = self.viewWithTag(currentRating + 1) as? UIImageView {
                    imageView.image = #imageLiteral(resourceName: "half_filled_circle")
                }
            }
        }
    }
}
