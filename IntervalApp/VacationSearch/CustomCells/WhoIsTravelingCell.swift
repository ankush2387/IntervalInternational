//
//  WhoIsTravelingCell.swift
//  IntervalApp
//
//  Created by Chetu on 11/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

//***** custom delegate method declaration *****//

protocol WhoIsTravelingCellDelegate {
    func adultChanged(_ value:Int)
    func childrenChanged(_ value:Int)
}


class WhoIsTravelingCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var childrenStepper: UIStepper!
    @IBOutlet weak var adultStepper: UIStepper!
    @IBOutlet weak var childCounterLabel: UILabel!
    @IBOutlet weak var adultCounterLabel: UILabel!
    
    var delegate:WhoIsTravelingCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        //***** Initialization code *****//
        self.adultStepper.maximumValue = 9
        self.adultStepper.minimumValue = 1
        self.adultStepper.value = Double(Constant.MyClassConstants.stepperAdultCurrentValue)
        
        
        self.childrenStepper.maximumValue = 9
        self.childrenStepper.minimumValue = 0
        self.childrenStepper.value = Double(Constant.MyClassConstants.stepperChildCurrentValue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //***** Configure the view for the selected state *****//
    }
    
    //***** function to recognise increment and decrement in adults *****//
    @IBAction func adultStepperValueChanged(_ sender: UIStepper) {
        
        self.delegate?.adultChanged(Int(sender.value))
    }
    
    //***** function to recognise increment and decrement in children *****//
    @IBAction func childrenStepperValueChanged(_ sender: UIStepper) {
        
        self.delegate?.childrenChanged(Int(sender.value))
    }
}
