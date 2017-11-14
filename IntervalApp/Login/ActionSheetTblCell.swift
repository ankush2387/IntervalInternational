//
//  ActionSheetTblCell.swift
//  ActionSheetDemo
//
//  Created by Chetu-macmini-26 on 18/01/16.
//  Copyright © 2016 Chetu-macmini-26. All rights reserved.
//

import UIKit
import IntervalUIKit

//***** custom delegate method declaration *****//
protocol ActionSheetTblDelegate {
    func membershipSelectedAtIndex(_ index: Int)
}

class ActionSheetTblCell: UITableViewCell {
    
    //***** Custom cell delegate to access the delegate method *****//
     var delegate: ActionSheetTblDelegate?
    
    //***** Outlets *****//
    
    @IBOutlet weak var membershipName: UILabel!
    @IBOutlet weak var membershipTextLabel: UILabel!
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var membershipNumber: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //***** Validating and checking membership selection if more than one *****//
    @IBAction func membershipSelected(_ sender: IUIKButton) {
        
        if(sender.isSelected == false) {
            sender.isSelected = true
        self.delegate?.membershipSelectedAtIndex(sender.tag)
        } else {
            
            sender.isSelected = false
        }
    }
}
