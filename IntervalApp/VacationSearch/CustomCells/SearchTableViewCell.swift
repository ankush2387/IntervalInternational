//
//  SearchTableViewCell.swift
//  IntervalApp
//
//  Created by Chetu on 28/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

//**** Custom delegate method declaration ****//

protocol SearchTableViewCellDelegate{
    
    func searchButtonClicked(_ sender: IUIKButton)
}

class SearchTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var searchVacation: IUIKButton!
    var delegate:SearchTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func searchButtonClicked(_ sender: IUIKButton){
        self.delegate?.searchButtonClicked(sender)
    }

    @IBAction func searchVacationClicked(_ sender: AnyObject) {
        
        self.delegate?.searchButtonClicked(sender as! IUIKButton)
        
    }
}
