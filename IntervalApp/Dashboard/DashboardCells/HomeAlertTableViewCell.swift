//
//  HomeAlertTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/7/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class HomeAlertTableViewCell: UITableViewCell {
    
    //IBOutlets
    @IBOutlet weak var alertCollectinView: UICollectionView!
    @IBOutlet weak var activityIndicatorBseView: UIView!
    @IBOutlet weak var activityIndicatorBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

