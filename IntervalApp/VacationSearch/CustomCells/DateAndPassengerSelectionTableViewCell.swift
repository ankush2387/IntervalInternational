//
//  DateAndPassengerSelectionTableViewCell.swift
//  IntervalApp
//
//  Created by Chetu on 26/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

//**** custom delegate method declaration ****//

protocol DateAndPassengerSelectionTableViewCellDelegate {
    
    func adultStepperChanged(_ value: Int)
    func childrenStepperChanged(_ value: Int)
    func calendarIconClicked(_ sender: UIButton)
    
}

class DateAndPassengerSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var calenderButton: UIButton?
    @IBOutlet weak var childCountLabel: UILabel!
    @IBOutlet weak var adultCountLabel: UILabel!
    @IBOutlet weak var stepperAdult: UIStepper!
    @IBOutlet weak var stepperChildren: UIStepper!
    
    @IBOutlet weak var checkInClosestToHeaderLabel: UILabel!
    @IBOutlet weak var whoIsTravellingHeaderLabel: UILabel!
   
    @IBOutlet weak var dayName: UILabel!
    
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var monthName: UILabel!
    @IBOutlet weak var dayDate: UILabel!
    var delegate: DateAndPassengerSelectionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.stepperAdult.maximumValue = 9
        self.stepperAdult.minimumValue = 1
        self.stepperAdult.value = Double(Constant.MyClassConstants.stepperAdultCurrentValue)
      
        self.stepperChildren.maximumValue = 9
        self.stepperChildren.minimumValue = 0
        self.stepperChildren.value = Double(Constant.MyClassConstants.stepperChildCurrentValue)
        // Configure the view for the selected state
    }
    
    //***** function to recognise increment and decrement in adults *****//
    @IBAction func adultStepperValueChanged(_ sender: UIStepper) {
        
        self.delegate?.adultStepperChanged(Int(sender.value))
    }
    
    //***** function to recognise increment and decrement in children *****//
    @IBAction func childrenStepperValueChanged(_ sender: UIStepper) {
        
        self.delegate?.childrenStepperChanged(Int(sender.value))
    }
    
    @IBAction func calenderButtonClicked(_ sender: UIButton) {
        self.delegate?.calendarIconClicked(sender)
    }

}
