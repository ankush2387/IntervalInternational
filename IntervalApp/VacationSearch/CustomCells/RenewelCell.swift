//
//  RenewelCell.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 9/21/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RenewelCell: UITableViewCell {
    
    
    @IBOutlet weak var renewelImageView: UIImageView!

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var renewelLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // view content border and corner radius
        viewContent.layer.cornerRadius = 10
        viewContent.layer.borderWidth = 2
        viewContent.layer.borderColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        
        // image view border and corner radius
        renewelImageView.layer.cornerRadius = 10
        renewelImageView.layer.borderWidth = 2
        renewelImageView.layer.borderColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
