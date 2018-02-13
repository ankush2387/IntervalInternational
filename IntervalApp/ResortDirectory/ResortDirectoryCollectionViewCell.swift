//
//  ResortDirectoryCollectionViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/14/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

//***** custom delegate method declaration *****//
protocol ResortDirectoryCollectionViewCellDelegate: class {
    
    func favoriteCollectionButtonClicked(_ sender: UIButton)
    func unfavoriteCollectionButtonClicked(_ sender: UIButton)
}

class ResortDirectoryCollectionViewCell: UICollectionViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var regionAreaLabel: UILabel!
    @IBOutlet weak var regionResortCode: UILabel!
    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var favoriteButton: IUIKButton!
    @IBOutlet weak var resortNameGradientView: UIView!
    @IBOutlet weak var tierImageView: UIImageView!
    @IBOutlet weak var allInclusiveImageView: UIImageView!
    
    //***** class variables *****//
    weak var delegate: ResortDirectoryCollectionViewCellDelegate?

//***** custom cell favorites button action implementation *****//
@IBAction func feboriteButtonPressed(_ sender: UIButton) {
    if sender.isSelected == false {
        
        sender.isSelected = true
        self.delegate?.favoriteCollectionButtonClicked(sender)
    } else {
        
        sender.isSelected = false
        self.delegate?.unfavoriteCollectionButtonClicked(sender)
    }
}
}
