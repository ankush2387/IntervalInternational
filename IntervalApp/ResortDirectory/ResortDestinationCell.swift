//
//  ResortDestinationCell.swift
//  IntervalApp
//
//  Created by Chetu on 24/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ResortDestinationCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var resortLocationName: UILabel!
    //@IBOutlet weak var resortCodeLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    
    @IBOutlet weak var addDestinationButton: UIButton!
    @IBOutlet weak var destinationMapIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //**** function called when any one resort selected from cell *****//
    @IBAction func resortSelectedAtIndex(_ sender: AnyObject) {
        
    }
}
