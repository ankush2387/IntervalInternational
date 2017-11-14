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
    
    @IBOutlet weak var mainViewOfCheckBoxButton: UIView!
    
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
    func getCell(ischeckbox ischeckbox: Bool = false, index: Int, checkBoxTagArray: Int) {
        
        //if !ischeckbox{
        var indexPrefix = "1"
        var finalIndex = "\(indexPrefix)\(index)"
        firstCheckBoxView.tag = Int(String(finalIndex))!
        indexPrefix = "2"
        finalIndex = "\(indexPrefix)\(index)"
        secondCheckBoxView.tag = Int(String(finalIndex))!
        
        // }
        //else{
        setCellProperties(ischeckbox: ischeckbox, checkBoxTagArray: checkBoxTagArray)
        //}
        
    }
    private func setCellProperties(ischeckbox ischeckbox: Bool, checkBoxTagArray: Int) {
        let firstcheckbox = firstCheckBoxView as! IUIKCheckbox
        let secondcheckBox = secondCheckBoxView as! IUIKCheckbox
        if checkBoxTagArray != 0 {
            let checkBoxtag = checkBoxTagArray
            if firstcheckbox.tag == checkBoxtag {
                secondcheckBox.checked = false
                firstcheckbox.checked = true
                setBackgroundColorAndBorderColorOfSuperView(isborder: true, subview: firstcheckbox)
                setBackgroundColorAndBorderColorOfSuperView(isborder: false, subview: secondcheckBox)
            } else if secondcheckBox.tag == checkBoxtag {
                firstcheckbox.checked = false
                secondcheckBox.checked = true
                setBackgroundColorAndBorderColorOfSuperView(isborder: false, subview: firstcheckbox)
                setBackgroundColorAndBorderColorOfSuperView(isborder: true, subview: secondcheckBox)
            } else {
                secondcheckBox.checked = false
                firstcheckbox.checked = false
                setBackgroundColorAndBorderColorOfSuperView(isborder: false, subview: firstcheckbox)
                setBackgroundColorAndBorderColorOfSuperView(isborder: false, subview: secondcheckBox)
            }
            
        } else {
            secondcheckBox.checked = false
            firstcheckbox.checked = false
            setBackgroundColorAndBorderColorOfSuperView(isborder: false, subview: firstcheckbox)
            setBackgroundColorAndBorderColorOfSuperView(isborder: false, subview: secondcheckBox)
        }
        
    }
    
    private func setBackgroundColorAndBorderColorOfSuperView(isborder isborder: Bool, subview: IUIKCheckbox) {
        
        if isborder {
            subview.superview?.layer.borderColor = UIColor.redColor().CGColor
            subview.superview?.layer.borderWidth = 1
            subview.superview?.backgroundColor = UIColor.whiteColor()
        } else {
            subview.superview?.layer.borderColor = UIColor.clearColor().CGColor
            subview.superview?.layer.borderWidth = 0
            subview.superview?.backgroundColor = UIColor.clearColor()
            
        }
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
