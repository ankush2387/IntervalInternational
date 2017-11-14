//
//  UpComingTripsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 8/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class UpComingTripsTableViewCell: UITableViewCell {
     //***** Outlets *****//
    @IBOutlet var vacationSearchCollectionView: UICollectionView!
    
    @IBOutlet weak var searchVacationButton: IUIKButton!
    @IBOutlet weak var vacationSearchContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        if(vacationSearchContainerView != nil) {
        self.vacationSearchContainerView.frame = CGRect(x: 20, y: 20, width: 150, height: 150)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
