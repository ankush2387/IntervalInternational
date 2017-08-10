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

    @IBOutlet weak var resortImageView:UIImageView!
   
    @IBOutlet weak var resortName: UILabel!
 
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortAddress: UILabel!
 
    @IBOutlet weak var viewGradient: UIView!
    
    @IBOutlet weak var tierImage: UIImageView!
    //***** class variables *****//
    //var delegate:ResortDirectoryCollectionViewCellDelegate?
    
}
