//
//  VideoTBLCell.swift
//  IntervalApp
//
//  Created by Chetu on 13/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class VideoTBLCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var thumbnailimageView: UIImageView!
    @IBOutlet weak var playButton: IUIKButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
