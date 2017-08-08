//
//  AvailabilityCollectionViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 8/8/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class AvailabilityCollectionViewCell: UICollectionViewCell {
    //***** Outlets *****//
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var regionAreaLabel: UILabel!
    @IBOutlet weak var regionResortCode: UILabel!
    @IBOutlet weak var resortImageView:UIImageView!
    @IBOutlet weak var favoriteButton:IUIKButton!
    @IBOutlet weak var resortNameGradientView:UIView!
    @IBOutlet weak var tierImageView:UIImageView!
    
    //***** class variables *****//
    //var delegate:ResortDirectoryCollectionViewCellDelegate?

}
