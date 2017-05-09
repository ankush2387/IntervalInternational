//
//  SearchResultContentTableCell.swift
//  IntervalApp
//
//  Created by Chetu on 11/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

//***** custom delegate method declaration *****//

protocol SearchResultContentTableCellDelegate {
    func favoriteButtonClicked(_ sender: UIButton)
    func unfavoriteButtonClicked(_ sender: UIButton)
}

class SearchResultContentTableCell: UITableViewCell {

    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var resortCountry: UILabel!
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortNameGradientView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var tierImageView: UIImageView!
    
    var delegate:SearchResultContentTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func feboriteButtonPressed(_ sender: UIButton) {
       self.delegate?.favoriteButtonClicked(sender)
        
    }
}
