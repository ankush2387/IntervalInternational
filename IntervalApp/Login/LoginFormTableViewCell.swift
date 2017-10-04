//
//  LoginFormTableViewCell.swift
//  LeisureTimePassport
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import LocalAuthentication
import IntervalUIKit

//***** custum delegate method declaration *****//
protocol LoginFormTableViewCellDelegate{
	func enableTouchIdButtonAction(_ enable:Bool)
}


//***** Login form tableview cell class *****//
class LoginFormTableViewCell: UITableViewCell
{
  
  //***** Outlets *****//
    @IBOutlet weak var userNameTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    @IBOutlet weak var loginButton : UIButton!
    @IBOutlet weak var helpButton : UIButton!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var enableTouchIdTextLabel: UILabel!
    @IBOutlet var touchIdImageView: UIImageView!
    @IBOutlet var enableTouchIdButton: UIButton!
  
    @IBOutlet weak var signInButtonBackgroundView: UIView!
    //***** variable declaration *****//
    var delegate:LoginFormTableViewCellDelegate?
	
	// computed property for touchIDEnabled, will turn on/off the checkbox
	var touchIDEnabled : Bool = false {
		didSet {
            enableTouchIdButton.isSelected = touchIDEnabled;
			enableTouchIdButton(touchIDEnabled)
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        //***** setting delegate for textfield *****//
        self.userNameTextField.placeholder = Constant.textFieldTitles.usernamePlaceholder
        self.passwordTextField.placeholder = Constant.textFieldTitles.passwordPlaceholder
        self.enableTouchIdTextLabel.text = Constant.labelTitles.enableTouchIDLabel
        self.helpButton.setTitle(Constant.buttonTitles.help, for: UIControlState())
        self.loginButton.setTitle(Constant.CommonLocalisedString.sign_in, for: UIControlState())
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signInButtonBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)//UIColor(white: 255/255, alpha: 0.7)
        enableTouchIdTextLabel.textColor = IUIKColorPalette.primary1.color
        
        //***** checking touch id sensor feature on running device *****//
        var hasTouchID:Bool = false
		hasTouchID = TouchID.isTouchIDAvailable()
        if(!(hasTouchID)){
            self.touchIdImageView.isHidden = true
            self.enableTouchIdTextLabel.isHidden = true
            self.enableTouchIdButton.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //***** Configure the view for the selected state *****//
    }

	@IBAction func enableTouchIdButtonAction(_ sender: UIButton) {
    
    	//***** selecting and deselecting enable touchID option *****//
		sender.isSelected = !sender.isSelected;

		// call the computed property to trigger the setting of touchid
		self.touchIDEnabled = sender.isSelected;
  	}
	
	fileprivate func enableTouchIdButton(_ enable:Bool)
	{
		if (enable)
		{
			enableTouchIdTextLabel.textColor = IUIKColorPalette.primary1.color
			self.touchIdImageView.image = UIImage(named: Constant.assetImageNames.TouchIdOn)
			OldLoginViewController().touchIdButtonEnabled = true
		}
		else
		{
			self.touchIdImageView.image = UIImage(named: Constant.assetImageNames.TouchIdOff)
			enableTouchIdTextLabel.textColor = UIColor.lightGray
		}
		
		self.delegate?.enableTouchIdButtonAction(enable)
	}
}

extension LoginFormTableViewCell:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
