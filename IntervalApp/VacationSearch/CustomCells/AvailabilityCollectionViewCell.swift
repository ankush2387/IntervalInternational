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

    @IBOutlet weak var resortImageView:UIImageView!
   
    @IBOutlet weak var resortName: UILabel!
 
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortAddress: UILabel!
 
    @IBOutlet weak var viewGradient: UIView!
    
    @IBOutlet weak var tierImage: UIImageView!
    //***** class variables *****//
    //var delegate:ResortDirectoryCollectionViewCellDelegate?
    
    
    func setResortDetails(inventoryItem:Resort){
        for layer in self.viewGradient.layer.sublayers!{
            if(layer.isKind(of: CAGradientLayer.self)) {
                layer.removeFromSuperlayer()
            }
        }
        
        var url = URL(string: "")
        for imgStr in inventoryItem.images {
            if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                url = URL(string: imgStr.url!)!
                break
            }
        }
        Helper.addLinearGradientToView(view: self.viewGradient, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        self.resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        self.resortName.text = inventoryItem.resortName
        self.resortAddress.text = inventoryItem.address?.cityName
        self.resortCode.text = inventoryItem.resortCode
        let tierImageName = Helper.getTierImageName(tier: inventoryItem.tier!.uppercased())
        self.tierImage.image = UIImage(named: tierImageName)
        DarwinSDK.logger.info("\(String(describing: Helper.resolveResortInfo(resort: inventoryItem)))")
    }
    
}
