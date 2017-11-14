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
    @IBOutlet var selectResortLabel: UILabel!
    @IBOutlet var resortAttributeLabel: FloatLabelTextField!
    @IBOutlet var resortPlaceHolderLabel: UILabel!
    @IBOutlet var textFieldView: UIView!
    @IBOutlet var viewButton: UIButton!
    let placeholderArray = [Constant.textFieldTitles.reservationNumber, Constant.textFieldTitles.unitNumber, Constant.textFieldTitles.numberOfBedrooms, Constant.textFieldTitles.checkInDate]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getCell() {
        setPropertiesTocellComponenet()
    }
    // MARK: set properties to cell component
    /**
     Apply Properties to cell components
     - parameter No parameter:
     - returns : No return value
     */
    fileprivate func setPropertiesTocellComponenet() {
        
        for (index, textField) in registrationTextFieldsCollection.enumerated() {
            textField.placeholder = placeholderArray[index]
            textField.layer.borderColor = UIColor.lightGray.cgColor
            let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            textField.leftView = paddingViewLeft
            textField.leftViewMode = .always
            
            let paddingViewRight = UIView(frame: CGRect(x: textField.frame.size.width - 35, y: 0, width: 35, height: 15))
            textField.rightView = paddingViewRight
            textField.rightViewMode = .always
            if(textField.tag == 3) {
                textField.text = Constant.MyClassConstants.savedBedroom
            }
        }
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
