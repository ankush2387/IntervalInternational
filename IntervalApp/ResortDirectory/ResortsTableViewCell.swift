//
//  ResortsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 5/7/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ResortsTableViewCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var resortLocationName: UILabel!
    @IBOutlet weak var resortCityName:UILabel!
    @IBOutlet weak var resortCode:UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    
    @IBOutlet weak var addResortButton: UIButton!
    @IBOutlet weak var showMapButton: UIButton!
    
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
