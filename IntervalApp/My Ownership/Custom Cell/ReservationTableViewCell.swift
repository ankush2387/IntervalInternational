//
//  ReservationTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 5/26/17.
//  Copyright © 2017 Interval International. All rights reserved.
//
import UIKit


class ReservationTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet var registrationTextFieldsCollection: [UITextField]!
    let placeholderArray = [Constant.textFieldTitles.reservationNumber, Constant.textFieldTitles.unitNumber, Constant.textFieldTitles.numberOfBedrooms, Constant.textFieldTitles.checkInDate]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getCell(){
        setPropertiesTocellComponenet()
    }
    //MARK:set properties to cell component
    /**
     Apply Properties to cell components
     - parameter No parameter:
     - returns : No return value
     */
    fileprivate func setPropertiesTocellComponenet(){
        for (index,textField) in registrationTextFieldsCollection.enumerated(){
            textField.placeholder = placeholderArray[index]
            textField.layer.borderColor = UIColor.lightGray.cgColor
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
