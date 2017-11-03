//
//  AddDebitOrCreditCardViewController.swift
//  IntervalApp
//
//  Created by Chetu on 19/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD

//***** Custom delegate method declaration *****//
protocol AddDebitOrCreditCardViewControllerDelegate {
    func newCreditCardAdded()
}

class AddDebitOrCreditCardViewController: UIViewController {
    
    //***** Custom cell delegate to access the delegate method *****//
    var delegate: AddDebitOrCreditCardViewControllerDelegate?
    
    //Outlets
    @IBOutlet weak var cardDetailTBLview: UITableView!
    
    //Class variables
    var requiredSectionIntTBLview = 2
    var pickerBaseView: UIView!
    var pickerView: UIPickerView!
    var datePickerView: UIDatePicker!
    var hideStatus = false
    var dropDownSelectionRow = -1
    var dropDownSelectionSection = -1
    var saveCardCheckBoxChecked = false
    var isKeyBoardOpen = false
    var moved: Bool = false
    var activeField: UITextField?
    var countryIndex: Int = 0
    var months: [String]!
    var years: [Int]!
    var selectedrow: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        // population years with localized names
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            for _ in 1...15 {
                years.append(year)
                year += 1
            }
        }
        self.years = years
        intervalPrint(years)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
       ADBMobile.trackAction(Constant.omnitureEvents.event57, data: nil)
       modalTransitionStyle = .flipHorizontal
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    // MARK: - Function to pop to search results if holding time is lost
    func updateResortHoldingTime() {
        
        if(Constant.holdingTime != 0) {
        } else {
            presentAlert(with: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage)
        }
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        
        isKeyBoardOpen = true
        
        if(self.moved) {
            let info = aNotification.userInfo as! [String: AnyObject],
            kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
            contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            
            self.cardDetailTBLview.contentInset = contentInsets
            self.cardDetailTBLview.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= kbSize.height
            
            if !aRect.contains(activeField!.frame.origin) {
                
                self.cardDetailTBLview.scrollRectToVisible(activeField!.frame, animated: true)
                
            }
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        isKeyBoardOpen = false
        
        if(self.moved) {
            self.moved = false
            let contentInsets = UIEdgeInsets.zero
            self.cardDetailTBLview.contentInset = contentInsets
            self.cardDetailTBLview.scrollIndicatorInsets = contentInsets
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to reset previous filled card information when booking completed.
    func resetCreditCardDetails() {
        
        Constant.GetawaySearchResultCardFormDetailData.nameOnCard = ""
        Constant.GetawaySearchResultCardFormDetailData.cardNumber = ""
        Constant.GetawaySearchResultCardFormDetailData.cardType = ""
        Constant.GetawaySearchResultCardFormDetailData.address1 = ""
        Constant.GetawaySearchResultCardFormDetailData.address2 = ""
        Constant.GetawaySearchResultCardFormDetailData.pinCode = ""
        Constant.GetawaySearchResultCardFormDetailData.city = ""
        Constant.GetawaySearchResultCardFormDetailData.state = ""
        Constant.GetawaySearchResultCardFormDetailData.country = ""
        Constant.GetawaySearchResultCardFormDetailData.expDate = nil
        Constant.GetawaySearchResultCardFormDetailData.cvv = ""
        
    }
    
    // function called when add new card button pressed to validate new card details.
    func addCardButtonPressed(_ sender: IUIKButton) {
        
        if(Constant.GetawaySearchResultCardFormDetailData.nameOnCard != "" && Constant.GetawaySearchResultCardFormDetailData.cardNumber != "" && Constant.GetawaySearchResultCardFormDetailData.cardType != "" && Constant.GetawaySearchResultCardFormDetailData.expDate != nil && Constant.GetawaySearchResultCardFormDetailData.cvv != "" && Constant.GetawaySearchResultCardFormDetailData.address1 != "" && Constant.GetawaySearchResultCardFormDetailData.address2 != "" && Constant.GetawaySearchResultCardFormDetailData.country != "" && Constant.GetawaySearchResultCardFormDetailData.city != "" && Constant.GetawaySearchResultCardFormDetailData.state != "" && Constant.GetawaySearchResultCardFormDetailData.pinCode != "") {
            
            var isNewCard = true
            
            for creditCard in Constant.MyClassConstants.memberCreditCardList {
                
                let cardNumber = creditCard.cardNumber!
                let last4 = cardNumber.substring(from: (cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
                let enteredCardLastDigit = Constant.GetawaySearchResultCardFormDetailData.cardNumber.substring(from: (Constant.GetawaySearchResultCardFormDetailData.cardNumber.index((Constant.GetawaySearchResultCardFormDetailData.cardNumber.endIndex), offsetBy: -4)))
                
                if(last4 == enteredCardLastDigit) {
                        isNewCard = false
                }
            }
           
            if(isNewCard) {
                let newCreditCard = Creditcard()
                newCreditCard.cardHolderName = Constant.GetawaySearchResultCardFormDetailData.nameOnCard
                newCreditCard.cardNumber = Constant.GetawaySearchResultCardFormDetailData.cardNumber
                newCreditCard.expirationDate = Constant.GetawaySearchResultCardFormDetailData.expDate
                newCreditCard.cvv = Constant.GetawaySearchResultCardFormDetailData.cvv
                
                let billingAdrs = Address()
                var address = [String]()
                address.append(Constant.GetawaySearchResultCardFormDetailData.address1)
                address.append(Constant.GetawaySearchResultCardFormDetailData.address2)
                billingAdrs.addressLines = address
                
                /*billingAdrs.addrLine1 = Constant.GetawaySearchResultCardFormDetailData.address1
                billingAdrs.addrLine2 = Constant.GetawaySearchResultCardFormDetailData.address2*/
                billingAdrs.cityName = Constant.GetawaySearchResultCardFormDetailData.city
                
                billingAdrs.countryCode = Constant.GetawaySearchResultCardFormDetailData.countryCode
                billingAdrs.postalCode = Constant.GetawaySearchResultCardFormDetailData.pinCode
                billingAdrs.territoryCode = Constant.GetawaySearchResultCardFormDetailData.stateCode
                
                newCreditCard.billingAddress = billingAdrs
                newCreditCard.typeCode = Helper.cardNameMapping(cardName: Constant.GetawaySearchResultCardFormDetailData.cardType)
                newCreditCard.autoRenew = false
                newCreditCard.preferredCardIndicator = false
                if(saveCardCheckBoxChecked) {
                    newCreditCard.saveCardIndicator = true
                } else {
                    newCreditCard.saveCardIndicator = false
                }
                
                //API call to tokenize new credit card.
                
                showHudAsync()
                CreditCardTokenizeClient.tokenize(Session.sharedSession.userAccessToken, creditCardNumber: newCreditCard.cardNumber!, onSuccess: {(response) in
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event59, data: nil)
                    self.hideHudAsync()
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    newCreditCard.creditcardId = 0
                    newCreditCard.cardNumber = response.cardToken!
                    Constant.MyClassConstants.selectedCreditCard.append(newCreditCard)
                    self.resetCreditCardDetails()
                    self.dismiss(animated: false, completion: nil)
                    self.delegate?.newCreditCardAdded()
                    
                    }, onError: {(_) in
                        self.presentErrorAlert(UserFacingCommonError.generic)
                        self.hideHudAsync()
                       
                })
            } else {
                self.presentAlert(with: Constant.MyClassConstants.newCardalertTitle, message: Constant.MyClassConstants.newCardalertMess)
            }
            
        } else {
            self.presentAlert(with: Constant.MyClassConstants.newCardalertTitle, message: Constant.MyClassConstants.alertReqFieldMsg)
        }
    }
    
    // function to enable and disable save this card option with checkbox
    func saveNewCreditCardPressed(_ sender: IUIKCheckbox) {
        
        if(self.saveCardCheckBoxChecked == false) {
            
            self.saveCardCheckBoxChecked = true
        } else {
            
            self.saveCardCheckBoxChecked = false
        }
    }
    
    func dateSelectedFromDatePicker(_ sender: UIDatePicker) {
        
    }
    
    //function called when picker view done button pressed.
    func dropDownButtonPressed(_ sender: IUIKButton) {
        
        self.dropDownSelectionRow = sender.tag
        self.dropDownSelectionSection = Int(sender.accessibilityValue!)!
        if(self.dropDownSelectionSection == 0 && self.dropDownSelectionRow == 3) {
            
            if(self.hideStatus == false) {
                
                self.hideStatus = true
               // showDatePickerView()
                showPickerView()

            } else {
                
                self.hideStatus = false
                //hideDatePickerView()
                hidePickerView()
                
            }

        } else {
          
            if(self.hideStatus == false) {
                
                self.hideStatus = true
                showPickerView()
                self.pickerView.reloadAllComponents()
            } else {
                
                self.hideStatus = false
                hidePickerView()
            }
        }
    }
    
    // function to create date picker view when drop down button pressed.
    func createDatePicker() {
        
        pickerBaseView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200))
        pickerBaseView.backgroundColor = IUIKColorPalette.primary1.color
        let doneButton = UIButton(frame: CGRect(x: 0, y: 5, width: pickerBaseView.frame.size.width - 20, height: 50))
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: .normal)
        doneButton.contentHorizontalAlignment = .right
        doneButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.pickerDoneButtonPressed(_:)), for: .touchUpInside)
        
        self.datePickerView = UIDatePicker(frame: CGRect(x: 0, y: 50, width: pickerBaseView.frame.size.width, height: pickerBaseView.frame.size.height - 60))
        self.datePickerView.datePickerMode = .date
        self.datePickerView.setValue(UIColor.white, forKeyPath: Constant.MyClassConstants.keyTextColor)
        self.datePickerView.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.dateSelectedFromDatePicker(_:)), for: UIControlEvents.valueChanged)
        self.pickerBaseView.addSubview(doneButton)
        self.pickerBaseView.addSubview(datePickerView)
        
        self.view.addSubview(pickerBaseView)
    }
    
    // function to create picker view when drop down button pressed.
    func createPickerView() {
        
        pickerBaseView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200))
        self.pickerBaseView.backgroundColor = IUIKColorPalette.primary1.color
        let doneButton = UIButton(frame: CGRect(x: pickerBaseView.frame.size.width - 60, y: 5, width: 50, height: 50))
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: .normal)
        doneButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.pickerDoneButtonPressed(_:)), for: .touchUpInside)
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: pickerBaseView.frame.size.width, height: pickerBaseView.frame.size.height - 60))
        pickerView.setValue(UIColor.white, forKeyPath: Constant.MyClassConstants.keyTextColor)
        self.pickerBaseView.addSubview(doneButton)
        self.pickerBaseView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.view.addSubview(pickerBaseView)
    }
    
    // function to create picker view when drop down button pressed.
    func showDatePickerView() {

        self.hideStatus = true
        self.createDatePicker()
    }
    
    //function to hide date picker view.
    func hideDatePickerView() {
        
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
    }
    
    //function to show picker view.
    func showPickerView() {
        self.activeField?.resignFirstResponder()
        self.hideStatus = true
        self.createPickerView()
    }
    
    //function to hide picker view.
    func hidePickerView() {
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
    }
    
    //function called when picker view done button pressed.
    func pickerDoneButtonPressed(_ sender: UIButton) {
        
        self.hideStatus = false
        self.pickerBaseView.isHidden = true
        if(datePickerView != nil) {
            
            //Constant.GetawaySearchResultCardFormDetailData.expDate = datePickerView.date
        }
       
        let indexPath = NSIndexPath(row: self.dropDownSelectionRow, section: self.dropDownSelectionSection)
        self.cardDetailTBLview.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }

    //function to dismiss current controller on cancel button pressed.
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
         self.dismiss(animated: true, completion: nil)
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
        
        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        // add a toolbar with a done button above the number pad
        textField.inputAccessoryView = keypadToolbar
    }
  
}

//Extension class starts from here

// extension class for implementing delegate methods of table view.
extension AddDebitOrCreditCardViewController: UITableViewDelegate {
    
}

// extension class for implementing data source methods of table view.
extension AddDebitOrCreditCardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.requiredSectionIntTBLview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0) {
            
            return 6
        } else {
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if(section == 0) {
            
            return 40
        } else {
            
            return 20
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if(section == 0) {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: cardDetailTBLview.frame.size.width, height: 40))
            
            headerView.backgroundColor = IUIKColorPalette.primary1.color
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: 5, width: cardDetailTBLview.frame.size.width - 40, height: 30)
            headerLabel.text = Constant.MyClassConstants.addressStringForCardDetailSection
            headerLabel.textColor = UIColor.white
            headerLabel.numberOfLines = 2
            
            headerView.addSubview(headerLabel)
            
            return headerView
        } else {
            
            return nil
        }
        
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            if(indexPath.section == 0) {
                
                if(indexPath.row == 5) {
                    
                    return 80
                } else if(indexPath.row == 0) {
                    return 90
                } else {
                    
                    return 60
                }
            } else {
                
                if(indexPath.row == 6) {
                    
                    return 80
                } else {
                    
                    return 60
                }
                
            }
        } else {
            if(indexPath.section == 0) {
                
                if(indexPath.row == 5) {
                    
                    return 60
                } else if(indexPath.row == 0) {
                    
                    return 75
                } else {
                    
                    return 50
                }
            } else {
                
                if(indexPath.row == 6) {
                    
                    return 70
                } else {
                    
                    return 50
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            
            if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4) {
                
                  let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
                cell.nameTF.delegate = self
                cell.nameTF.text = ""
                if(indexPath.row == 0) {
                    
                    if(Constant.GetawaySearchResultCardFormDetailData.nameOnCard == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.nameOnCard
                    } else {
                        
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.nameOnCard
                    }
                } else if(indexPath.row == 1) {
                    
                     if(Constant.GetawaySearchResultCardFormDetailData.cardNumber == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.cardNumber
                     } else {
                        
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.cardNumber
                    }
                    
                } else {
                   
                     if(Constant.GetawaySearchResultCardFormDetailData.cvv == "") {
                        cell.nameTF.placeholder = Constant.textFieldTitles.cvv
                    } else {
                        
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.cvv
                    }
                }
                cell.nameTF.tag = indexPath.row
                cell.nameTF.accessibilityValue = "\(indexPath.section)"
                cell.borderView.layer.borderColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                
                return cell
            } else if(indexPath.row == 5) {
                
                  let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.saveCardOptionCell, for: indexPath) as! SaveCardOptionCell
                
                if(self.saveCardCheckBoxChecked == false) {
                    
                    cell.saveThisCardCheckBox.checked = false
                } else {
                    
                    cell.saveThisCardCheckBox.checked = true
                }

                cell.saveThisCardCheckBox.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.saveNewCreditCardPressed(_:)), for: .touchUpInside)
                
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.dropDownListCell, for: indexPath) as! DropDownListCell
                
                if(indexPath.row == 3) {
                    
                    if(Constant.GetawaySearchResultCardFormDetailData.expDate == nil) {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.expirationDate
                    } else {
                        
                    
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = DateFormatter.Style.short
                        
                       // let strDate = dateFormatter.string(from: Constant.GetawaySearchResultCardFormDetailData.expDate!)
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultCardFormDetailData.expDate //strDate
                    }
                    cell.selectedTextLabel.textColor = UIColor.lightGray

                } else {
                    
                    if(Constant.GetawaySearchResultCardFormDetailData.cardType == "") {
                        cell.selectedTextLabel.text = Constant.textFieldTitles.type
                    } else {
                        
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultCardFormDetailData.cardType
                    }
                }
               
                cell.selectedTextLabel.textColor = UIColor(red: 199.0 / 255.0, green: 199.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
                cell.dropDownButton.tag = indexPath.row
                cell.dropDownButton.accessibilityValue = "\(indexPath.section)"
                cell.dropDownButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.dropDownButtonPressed(_:)), for: .touchUpInside)
                cell.borderView.layer.borderColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none

                return cell
            }
          
        } else {
            
            if(indexPath.row == 0 || indexPath.row == 4) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.dropDownListCell, for: indexPath) as! DropDownListCell
                
                if(indexPath.row == 0) {
                    //country name
                    
                    if(Constant.GetawaySearchResultCardFormDetailData.country == "") {
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectCountryPlaceholder
                    } else {
                        
                        if let address = Session.sharedSession.contact?.addresses![0] {
                            cell.selectedTextLabel.text = address.countryCode
                            
                        } else {
                            cell.selectedTextLabel.text = Constant.GetawaySearchResultCardFormDetailData.country
                            
                        }
                        
                    }
                } else {
                    //state name
                    if(Constant.GetawaySearchResultCardFormDetailData.state == "") {
                        
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectState
                    } else {
                        
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultCardFormDetailData.state
                    }
                }
                cell.selectedTextLabel.textColor = UIColor(red: 199.0 / 255.0, green: 199.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
                cell.dropDownButton.tag = indexPath.row
                cell.dropDownButton.accessibilityValue = "\(indexPath.section)"
                cell.dropDownButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.dropDownButtonPressed(_:)), for: .touchUpInside)
                cell.borderView.layer.borderColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                
                return cell
                
            } else if(indexPath.row == 6) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.addYourCardButtonCell, for: indexPath) as! AddYourCardButtonCell
                
                cell.addYourCardButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.addCardButtonPressed(_:)), for: .touchUpInside)
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as! GuestTextFieldCell
                cell.nameTF.delegate = self
                cell.nameTF.text = ""
                if(indexPath.row == 1) {
                    
                    //address line 1 info
                    if(Constant.GetawaySearchResultCardFormDetailData.address1 == "") {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                    } else {
                        
                        if let addressLine = Session.sharedSession.contact?.addresses![0].addressLines {
                            cell.nameTF.text = addressLine[0]
                            
                        } else {
                            
                            cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.address1
                            
                        }
                        
                    }
                    
                } else if(indexPath.row == 2) {
                    //address line2 info
                    
                    if(Constant.GetawaySearchResultCardFormDetailData.address2 == "") {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                    } else {
                        if let addressLine2 = Session.sharedSession.contact?.addresses![0].addressLines[1] {
                            cell.nameTF.text = addressLine2
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.address2
                            
                        }
                        
                    }
                    
                } else if(indexPath.row == 3) {
                    
                    // city name info
                    if(Constant.GetawaySearchResultCardFormDetailData.city == "") {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                    } else {
                        if let address = Session.sharedSession.contact?.addresses![0] {
                            cell.nameTF.text = address.cityName
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.city
                        }
                        
                    }
                } else {
                    
                    //postal code info
                    if(Constant.GetawaySearchResultCardFormDetailData.pinCode == "") {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                    } else {
                        if let address = Session.sharedSession.contact?.addresses![0] {
                            cell.nameTF.text = address.postalCode
                            
                        } else {
                            cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.pinCode
                            
                        }
                    }
                }
                cell.nameTF.tag = indexPath.row
                cell.nameTF.accessibilityValue = "\(indexPath.section)"
                cell.borderView.layer.borderColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                
                return cell
                
            }
            
        }
    }
}

//implementing delegate methods of picker view.
extension AddDebitOrCreditCardViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if(self.dropDownSelectionSection == 0) {
           
            if(self.dropDownSelectionRow == 3) {
                
                switch component {
                case 0:
                    return months[row]
                case 1:
                    return "\(years[row])"
                default:
                    return nil
                }
                
            } else {
                let creditCardType = Constant.MyClassConstants.allowedCreditCardType[row]
                return creditCardType.name
            }
            
        } else {
            
            if(self.dropDownSelectionRow == 0) {
    
                return Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName
            } else {
                
                return Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name
            }

        }
            }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(self.dropDownSelectionSection == 0) {
            
            if(self.dropDownSelectionRow == 3) {
                
                let month = months[pickerView.selectedRow(inComponent: 0)]
                let year = years[pickerView.selectedRow(inComponent: 1)]
                let expiryDate = "\(year), \(month)"
                intervalPrint(expiryDate)
                Constant.GetawaySearchResultCardFormDetailData.expDate = expiryDate
                
            } else if(self.dropDownSelectionRow == 2) {
                
                let cardType = Constant.MyClassConstants.allowedCreditCardType[row]
                Constant.GetawaySearchResultCardFormDetailData.cardType = cardType.name!
                
            } else {
                
            }
        } else {
            
             if(self.dropDownSelectionRow == 0) {

                 Constant.GetawaySearchResultCardFormDetailData.country = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName!
                Constant.GetawaySearchResultCardFormDetailData.countryCode = Constant.GetawaySearchResultGuestFormDetailData.countryCodeArray[row]
                
                Helper.getStates(country: Constant.GetawaySearchResultCardFormDetailData.countryCode, viewController: self)
             }
//             else {
//                
//                Constant.GetawaySearchResultCardFormDetailData.state = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row]
//                Constant.GetawaySearchResultCardFormDetailData.stateCode = Constant.GetawaySearchResultGuestFormDetailData.stateCodeArray[row]
//
//                guard let countryName = Constant.GetawaySearchResultGuestFormDetailData.countryListArray[row].countryName else { return }
//                countryIndex = row
//                 Constant.GetawaySearchResultCardFormDetailData.country = countryName
//             }
             else {
                guard let stateName = Constant.GetawaySearchResultGuestFormDetailData.stateListArray[row].name else { return }
                Constant.GetawaySearchResultCardFormDetailData.state = stateName

            }
            
        }
    }
}

// implementing data source methods for picker view.
extension AddDebitOrCreditCardViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if(self.dropDownSelectionRow == 3) {
            
            return 2
            
        } else {
           return 1
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if(self.dropDownSelectionSection == 0) {
            
            if(self.dropDownSelectionRow == 3) {
                switch component {
                    
                case 0 :
                    return months.count
                case 1 :
                    return years.count
                default:
                    return 0
                }
                
            } else {
                return Constant.MyClassConstants.allowedCreditCardType.count
            }
            
        } else {
            
            if(self.dropDownSelectionRow == 0) {
                return Constant.GetawaySearchResultGuestFormDetailData.countryListArray.count
            } else {
                return Constant.GetawaySearchResultGuestFormDetailData.stateListArray.count
            }

        }
    }
}

//***** extension class for uitextfield delegate methods definition *****//
extension AddDebitOrCreditCardViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeField?.resignFirstResponder()
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField?.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        intervalPrint(string)
        if (range.length == 1 && string.characters.count == 0) {
            intervalPrint("backspace tapped")
        }
        if(Int(textField.accessibilityValue!) == 0) {
                
                if(textField.tag == 0) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.nameOnCard.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultCardFormDetailData.nameOnCard = "\(textField.text!)\(string)"
                    }

                } else if(textField.tag == 1) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.cardNumber.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultCardFormDetailData.cardNumber = "\(textField.text!)\(string)"
                    }
                    
                } else {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.cvv.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultCardFormDetailData.cvv = "\(textField.text!)\(string)"
                    }

            }
        } else {
                
                if(textField.tag == 1) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.address1.characters.removeLast()
                    } else {
                        
                        Constant.GetawaySearchResultCardFormDetailData.address1 = "\(textField.text!)\(string)"
                    }
                    
                } else if(textField.tag == 2) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.address2.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultCardFormDetailData.address2 = "\(textField.text!)\(string)"

                    }
                    
                } else if(textField.tag == 3) {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.city.characters.removeLast()
                    } else {
                        Constant.GetawaySearchResultCardFormDetailData.city = "\(textField.text!)\(string)"
                    }
                } else {
                    
                    if (range.length == 1 && string.characters.count == 0) {
                        Constant.GetawaySearchResultCardFormDetailData.pinCode.characters.removeLast()
                    } else {
                       Constant.GetawaySearchResultCardFormDetailData.pinCode = "\(textField.text!)\(string)"
                        
                    }
                    
                }
            }
        
            return  true
        }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeField = textField
        
        self.moved = true
        
        if(Int(textField.accessibilityValue!) == 0) {
            if(textField.tag == 0) {
               textField.keyboardType = .default
            } else {
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            }
            
        } else {
            
            if(textField.tag == 5) {
                
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
            } else {
                textField.keyboardType = .default
            }
            
        }
        
    }
    
}
