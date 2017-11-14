//
//  ClubPointWithCheckBoxTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class ClubPointWithCheckBoxTableViewCell: UITableViewCell {
    
    /** Outlets */
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var firstCheckBoxView: UIView!
    
    @IBOutlet weak var secondCheckBoxView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    /**
     Configure cell components
     - parameter No Parameter:
     - returns : No value is return
     */
    func getCell(_ ischeckbox: Bool = false, index: Int, checkBoxTagArray: Int) {
        
        //if !ischeckbox{
        var indexPrefix = "1"
        var finalIndex = "\(indexPrefix)\(index)"
        indexPrefix = "2"
        finalIndex = "\(indexPrefix)\(index)"
    }
    
    fileprivate func setBackgroundColorAndBorderColorOfSuperView(_ isborder: Bool, subview: IUIKCheckbox) {
        
        if isborder {
            subview.superview?.layer.borderColor = UIColor.red.cgColor
            subview.superview?.layer.borderWidth = 1
            subview.superview?.backgroundColor = UIColor.white
        } else {
            subview.superview?.layer.borderColor = UIColor.clear.cgColor
            subview.superview?.layer.borderWidth = 0
            subview.superview?.backgroundColor = UIColor.clear
            
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
