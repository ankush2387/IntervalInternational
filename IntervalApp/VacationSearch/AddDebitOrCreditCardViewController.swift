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
import TPKeyboardAvoiding
import TPKeyboardAvoiding.UIScrollView_TPKeyboardAvoidingAdditions


class AddDebitOrCreditCardViewController: UIViewController {
    
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
    var expServerDate = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if let contact = Session.sharedSession.contact {
            Constant.GetawaySearchResultCardFormDetailData.nameOnCard = "\(contact.firstName.unwrappedString) \(contact.lastName.unwrappedString)"
        }
        //address from contact list
        if let address = Session.sharedSession.contact?.addresses {
            if !address.isEmpty {
                Constant.GetawaySearchResultCardFormDetailData.pinCode = address[0].postalCode ?? ""
                Constant.GetawaySearchResultCardFormDetailData.city = address[0].cityName ?? ""
                 Constant.GetawaySearchResultCardFormDetailData.countryCode = address[0].countryCode ?? ""
                
                Constant.GetawaySearchResultCardFormDetailData.stateCode = address[0].territoryCode ?? ""
                
                if address[0].addressLines.count > 1 {
                    Constant.GetawaySearchResultCardFormDetailData.address1 = address[0].addressLines[0]
                    Constant.GetawaySearchResultCardFormDetailData.address2 = address[0].addressLines[1]
                } else if !address[0].addressLines.isEmpty {
                    Constant.GetawaySearchResultCardFormDetailData.address1 = address[0].addressLines[0]
                }
            }
        }
       
        LookupClient.getCountries(Constant.MyClassConstants.systemAccessToken!, onSuccess: {[weak self] (response) in
            
            for country in (response ) {
                if Constant.GetawaySearchResultCardFormDetailData.countryCode == country.countryCode {
                    Constant.GetawaySearchResultCardFormDetailData.country = country.countryName ?? ""
                }
                Constant.countryListArray.append(country)
            }
            self?.cardDetailTBLview.reloadData()
            self?.hideHudAsync()
            
        }) {[weak self] _ in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.generic)
        }
        
        //get states here on the basis of country code
        Helper.getStates(countryCode: Constant.GetawaySearchResultCardFormDetailData.countryCode, CompletionBlock: { [weak self] error in
         if error != nil {
            self?.presentErrorAlert(UserFacingCommonError.handleError(Error))
         } else {
            for state in Constant.stateListArray where state.code == Constant.GetawaySearchResultCardFormDetailData.stateCode {
                    Constant.GetawaySearchResultCardFormDetailData.state = state.name ?? ""
                    self?.cardDetailTBLview.reloadData()
                }
            }
         })
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
       ADBMobile.trackAction(Constant.omnitureEvents.event57, data: nil)
       modalTransitionStyle = .flipHorizontal
        cardDetailTBLview.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    // MARK: - Function to pop to search results if holding time is lost
    func updateResortHoldingTime() {
        
        func updateResortHoldingTime() {
            
            if Constant.holdingTime == 0 {
                Constant.holdingTimer?.invalidate()
                let alertController = UIAlertController(title: "", message: Constant.AlertMessages.holdingTimeLostMessage, preferredStyle: .alert)
                let Ok = UIAlertAction(title: "OK".localized(), style: .default) {[weak self] (_:UIAlertAction)  in
                    
                    self?.performSegue(withIdentifier: "unwindToAvailabiity", sender: self)
                }
                alertController.addAction(Ok)
                present(alertController, animated: true, completion:nil)
            }
        }
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        
        isKeyBoardOpen = true
        
        if moved {
            let info = aNotification.userInfo as! [String: AnyObject],
            kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
            contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            
            cardDetailTBLview.contentInset = contentInsets
            cardDetailTBLview.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = view.frame
            aRect.size.height -= kbSize.height
            
            if !aRect.contains(activeField!.frame.origin) {
                
                cardDetailTBLview.scrollRectToVisible(activeField!.frame, animated: true)
                
            }
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        isKeyBoardOpen = false
        
        if moved {
            moved = false
            let contentInsets = UIEdgeInsets.zero
            cardDetailTBLview.contentInset = contentInsets
            cardDetailTBLview.scrollIndicatorInsets = contentInsets
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
        Constant.GetawaySearchResultCardFormDetailData.expDate = ""
        Constant.GetawaySearchResultCardFormDetailData.cvv = ""
        
    }
    
    // function called when add new card button pressed to validate new card details.
    func addCardButtonPressed(_ sender: IUIKButton) {
        
        if Constant.GetawaySearchResultCardFormDetailData.nameOnCard != "" && Constant.GetawaySearchResultCardFormDetailData.cardNumber != "" && Constant.GetawaySearchResultCardFormDetailData.cardType != "" && Constant.GetawaySearchResultCardFormDetailData.expDate != "" && Constant.GetawaySearchResultCardFormDetailData.cvv != "" &&  Constant.GetawaySearchResultCardFormDetailData.country != "" &&  Constant.GetawaySearchResultCardFormDetailData.state != "" {
            
                let newCreditCard = Creditcard()
                newCreditCard.creditcardId = 0
                newCreditCard.cardHolderName = Constant.GetawaySearchResultCardFormDetailData.nameOnCard
                newCreditCard.cardNumber = Constant.GetawaySearchResultCardFormDetailData.cardNumber
                
                //creating date component with new exp date
                let dateComp = expServerDate.components(separatedBy: "-")
                var year = ""
                var month = ""
                if dateComp.count > 1 {
                    month = dateComp[0]
                    year = dateComp[1]
                }
                
                var dateComponents = DateComponents()
                dateComponents.year = Int(year)
                dateComponents.month = Int(month)
                dateComponents.day = 1
                
                let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                let date = calendar.date(from: dateComponents)
                let dateFor = DateFormatter()
                dateFor.dateFormat = Constant.MyClassConstants.dateFormat
                dateFor.timeZone = Helper.createTimeZone()
                 
                let expString: String = dateFor.string(from: date ?? Date())
                debugPrint(expString)
                newCreditCard.expirationDate = expString
                newCreditCard.cvv = Constant.GetawaySearchResultCardFormDetailData.cvv
                
                let billingAdrs = Address()
                var address = [String]()
                address.append(Constant.GetawaySearchResultCardFormDetailData.address1)
                address.append(Constant.GetawaySearchResultCardFormDetailData.address2)
                billingAdrs.addressLines = address
                billingAdrs.cityName = Constant.GetawaySearchResultCardFormDetailData.city
                billingAdrs.countryCode = Constant.GetawaySearchResultCardFormDetailData.countryCode
                billingAdrs.postalCode = Constant.GetawaySearchResultCardFormDetailData.pinCode
                billingAdrs.territoryCode = Constant.GetawaySearchResultCardFormDetailData.stateCode
                
                newCreditCard.billingAddress = billingAdrs
                newCreditCard.typeCode = Helper.cardNameMapping(cardName: Constant.GetawaySearchResultCardFormDetailData.cardType)
                newCreditCard.autoRenew = false
                newCreditCard.preferredCardIndicator = false
                
                if saveCardCheckBoxChecked {
                    newCreditCard.saveCardIndicator = true
                } else {
                    newCreditCard.saveCardIndicator = false
                }
                
                //API call to tokenize new credit card.
                
                showHudAsync()
                CreditCardTokenizeClient.tokenize(Session.sharedSession.userAccessToken, creditCardNumber: newCreditCard.cardNumber!, onSuccess: {[weak self](response) in
                    guard let strongSelf = self else { return }
                    ADBMobile.trackAction(Constant.omnitureEvents.event59, data: nil)
                    
                    Constant.MyClassConstants.selectedCreditCard = nil

                    //TODO: Update card number with card token
                    if let cardToken = response.cardToken {
                        newCreditCard.cardNumber = cardToken
                    }
                    
                    if strongSelf.saveCardCheckBoxChecked {
                        //TODO: Save the new Credit Card
                        
                        guard let accessToken = Session.sharedSession.userAccessToken else {
                            strongSelf.hideHudAsync()
                            strongSelf.presentErrorAlert(UserFacingCommonError.generic)
                            return
                        }
                        
                        UserClient.createCreditCard(accessToken, creditCard: newCreditCard, onSuccess: {[weak self](savedCreditCard) in
                            //TODO: Unfortunately we have to re-add the cvv since the service call removes it
                            savedCreditCard.cvv = Constant.GetawaySearchResultCardFormDetailData.cvv
                            
                            //TODO: Add the saved Credit Card to the Member credit cards list
                            Session.sharedSession.contact?.creditcards?.append(savedCreditCard)
                            
                            //TODO: Set the saved Credit Card as the selected
                            Constant.MyClassConstants.selectedCreditCard = savedCreditCard
                            
                            //FIXME(Frank) - what is this?
                            strongSelf.resetCreditCardDetails()
                            
                            strongSelf.hideHudAsync()
                            strongSelf.performSegue(withIdentifier: "unwindToCheckout", sender: self)
                        }, onError: {(error) in
                            strongSelf.hideHudAsync()
                            strongSelf.presentErrorAlert(UserFacingCommonError.handleError(error))
                        })
                        
                    } else {
                  
                        //TODO: Set the new Credit Card as the selected
                        Constant.MyClassConstants.selectedCreditCard = newCreditCard
                        
                        //FIXME(Frank) - what is this?
                        strongSelf.resetCreditCardDetails()
                        
                        strongSelf.hideHudAsync()
                        strongSelf.performSegue(withIdentifier: "unwindToCheckout", sender: self)
                    }
                    
                }, onError: {[weak self](_) in
                    self?.presentErrorAlert(UserFacingCommonError.generic)
                    self?.hideHudAsync()
                })
            
        } else {
            if Constant.GetawaySearchResultCardFormDetailData.cvv == "" {
                self.presentAlert(with: "", message: "Please enter a valid security code.".localized(), hideCancelButton: true)
            } else {
                self.presentAlert(with: Constant.MyClassConstants.newCardalertTitle, message: Constant.MyClassConstants.alertReqFieldMsg, hideCancelButton: true)
            }
        }
    }
    
    // function to enable and disable save this card option with checkbox
    func saveNewCreditCardPressed(_ sender: IUIKCheckbox) {
        
        if saveCardCheckBoxChecked == false {
            saveCardCheckBoxChecked = true
        } else {
            saveCardCheckBoxChecked = false
        }
    }
    
    //function called when drop down button pressed
    func dropDownButtonPressed(_ sender: IUIKButton) {
        
        dropDownSelectionRow = sender.tag
        dropDownSelectionSection = Int(sender.accessibilityValue ?? "") ?? 0
        if dropDownSelectionSection == 0 && dropDownSelectionRow == 3 {
            
            if hideStatus == false {
                hideStatus = true
                showPickerView()
                
            } else {
                hideStatus = false
                hidePickerView()
            }
            
        } else {
            
            if hideStatus == false {
                if dropDownSelectionRow == 0 {
                     Constant.GetawaySearchResultCardFormDetailData.state.removeAll()
                    let indexPath = IndexPath(row: 4, section: dropDownSelectionSection)
                    cardDetailTBLview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
                if dropDownSelectionRow == 4 && Constant.stateListArray.isEmpty {
                    let state = State()
                    state.name = "N/A"
                    state.code = "  "
                    
                    Constant.stateListArray.append(state)
                }
                
                    hideStatus = true
                    showPickerView()
                    self.pickerView.reloadAllComponents()
            } else {
                hideStatus = false
                hidePickerView()
            }
        }
    }
    
    // function to create picker view when drop down button pressed.
    func createPickerView() {
        
        pickerBaseView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200))
        pickerBaseView.backgroundColor = IUIKColorPalette.primary1.color
        let doneButton = UIButton(frame: CGRect(x: pickerBaseView.frame.size.width - 60, y: 5, width: 50, height: 50))
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: .normal)
        doneButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.pickerDoneButtonPressed(_:)), for: .touchUpInside)
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: pickerBaseView.frame.size.width, height: pickerBaseView.frame.size.height - 60))
        pickerView.setValue(UIColor.white, forKeyPath: Constant.MyClassConstants.keyTextColor)
        pickerBaseView.addSubview(doneButton)
        pickerBaseView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(pickerBaseView)
    }
    
    //function to show picker view.
    func showPickerView() {
        activeField?.resignFirstResponder()
        hideStatus = true
        createPickerView()
    }
    
    //function to hide picker view.
    func hidePickerView() {
        hideStatus = false
        pickerBaseView.isHidden = true
    }
    
    //function called when picker view done button pressed.
    func pickerDoneButtonPressed(_ sender: UIButton) {
        hideStatus = false
        pickerBaseView.isHidden = true
        let row = pickerView.selectedRow(inComponent: 0)
        intervalPrint(row)
        pickerView(pickerView, didSelectRow: row, inComponent:0)
        let indexPath = IndexPath(row: dropDownSelectionRow, section: dropDownSelectionSection)
        cardDetailTBLview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }

    //function to dismiss current controller on cancel button pressed.
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
         resetCreditCardDetails()
         self.dismiss(animated: true)
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
        
        return requiredSectionIntTBLview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 6
        } else {
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 40
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
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
        
          if UIDevice.current.userInterfaceIdiom == .pad {
          
            switch indexPath.section {
             case 0 :
                switch indexPath.row {
                case 5:
                    return 80
                case 0:
                    return 90
                default :
                    return 60
                }
            default:
                switch indexPath.row {
                case 6 :
                    return 80
                default:
                    return 60
                }
            }

        } else {
            switch indexPath.section {
            case 0 :
                switch indexPath.row {
                case 5:
                    return 80
                case 0:
                    return 75
                default :
                    return 50
                }
            default:
                switch indexPath.row {
                case 6 :
                    return 70
                default:
                    return 50
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as? GuestTextFieldCell else {
                    
                    return UITableViewCell()
                }
                cell.acceptedCardsMSG.text = ""
                cell.nameTF.delegate = self
                cell.nameTF.text = ""
                if indexPath.row == 0 {
                    cell.acceptedCardsMSG.text = "Interval accepts all major credit and debit cards.".localized()
                    cell.nameTF.placeholder = "Name on Card".localized()
                    if Constant.GetawaySearchResultCardFormDetailData.nameOnCard.isEmpty {
                        cell.nameTF.placeholder = "Name on Card".localized()
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.nameOnCard
                    }
                    cell.nameTF.tag = indexPath.row
                    cell.nameTF.accessibilityValue = "\(indexPath.section)"
                } else if indexPath.row == 1 {
                    
                     if Constant.GetawaySearchResultCardFormDetailData.cardNumber.isEmpty {
                        cell.nameTF.placeholder = "Card Number".localized()
                     } else {
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.cardNumber
                    }
                    cell.nameTF.tag = indexPath.row
                    cell.nameTF.accessibilityValue = "\(indexPath.section)"
                    
                } else {
               
                     if Constant.GetawaySearchResultCardFormDetailData.cvv.isEmpty {
                        cell.nameTF.placeholder = Constant.textFieldTitles.cvv
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.cvv
                    }
                    cell.nameTF.tag = indexPath.row
                    cell.nameTF.accessibilityValue = "\(indexPath.section)"
                }
               
                cell.borderView.layer.borderColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
                cell.borderView.layer.borderWidth = 2
                cell.borderView.layer.cornerRadius = 5
                cell.selectionStyle = .none
                
                return cell
            } else if indexPath.row == 5 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.saveCardOptionCell, for: indexPath) as? SaveCardOptionCell else {
                    
                    return UITableViewCell()
                }
                cell.saveThisCardCheckBox.checked = saveCardCheckBoxChecked
                cell.saveThisCardCheckBox.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.saveNewCreditCardPressed(_:)), for: .touchUpInside)
                
                return cell
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.dropDownListCell, for: indexPath) as? DropDownListCell else {
                    
                    return UITableViewCell()
                }
                if indexPath.row == 3 {
                    
                    if Constant.GetawaySearchResultCardFormDetailData.expDate.isEmpty {
                        cell.selectedTextLabel.text = Constant.textFieldTitles.expirationDate
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = DateFormatter.Style.short
                        cell.selectedTextLabel.text = Constant.GetawaySearchResultCardFormDetailData.expDate //strDate
                    }
                    cell.selectedTextLabel.textColor = UIColor.lightGray

                } else {
                    
                    if Constant.GetawaySearchResultCardFormDetailData.cardType.isEmpty {
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
            
            if indexPath.row == 0 || indexPath.row == 4 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.dropDownListCell, for: indexPath) as? DropDownListCell else {
                    return UITableViewCell()
                }
                if indexPath.row == 0 {
                    //country name
                    
                    if Constant.GetawaySearchResultCardFormDetailData.country.isEmpty {
                        cell.selectedTextLabel.text = Constant.textFieldTitles.guestFormSelectCountryPlaceholder
                    } else {
                            cell.selectedTextLabel.text = Constant.GetawaySearchResultCardFormDetailData.country
                    }
                } else {
                    //state name
                    if Constant.GetawaySearchResultCardFormDetailData.state.isEmpty {
                        
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
                
            } else if indexPath.row == 6 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.addYourCardButtonCell, for: indexPath) as? AddYourCardButtonCell else {
                    return UITableViewCell()
                }
                cell.addYourCardButton.addTarget(self, action: #selector(AddDebitOrCreditCardViewController.addCardButtonPressed(_:)), for: .touchUpInside)
                return cell
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.guestTextFieldCell, for: indexPath) as? GuestTextFieldCell else {
                    return UITableViewCell()
                }
                cell.acceptedCardsMSG.text = ""
                cell.nameTF.delegate = self
                cell.nameTF.text = ""
                if indexPath.row == 1 {
                    
                    //address line 1 info
                    if Constant.GetawaySearchResultCardFormDetailData.address1.isEmpty {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress1
                    } else {
                        cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.address1
                            
                    }
                } else if indexPath.row == 2 {
                    //address line2 info
                    
                    if Constant.GetawaySearchResultCardFormDetailData.address2.isEmpty {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormAddress2
                    } else {
                       cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.address2
                    }
                } else if indexPath.row == 3 {
                    
                    // city name info
                    if Constant.GetawaySearchResultCardFormDetailData.city.isEmpty {
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormCity
                    } else {
                       cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.city
                    }
                    
                } else {
                    
                    //postal code info
                    if Constant.GetawaySearchResultCardFormDetailData.pinCode.isEmpty {
                        
                        cell.nameTF.placeholder = Constant.textFieldTitles.guestFormPostalCode
                    } else {
                       cell.nameTF.text = Constant.GetawaySearchResultCardFormDetailData.pinCode
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
        
        if dropDownSelectionSection == 0 {
           
            if dropDownSelectionRow == 3 {
                
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
                // this should be changed on the ESB side but for now
                if creditCardType.name == "MASTER CARD" {
                    return "MASTERCARD".localized()
                }
                return creditCardType.name
            }
            
        } else {
            
            if dropDownSelectionRow == 0 {
                return Constant.countryListArray[row].countryName
            } else {
                return Constant.stateListArray[row].name
            }
        }
            }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if dropDownSelectionSection == 0 {
            
            if dropDownSelectionRow == 3 {
                
                let month = months[pickerView.selectedRow(inComponent: 0)]
                let year = years[pickerView.selectedRow(inComponent: 1)]
                let expiryDate = "\(month), \(year)"
                expServerDate = "\(Helper.getMonth(Helper.MonthType.number, for: month) ?? "")-\(year)"
                Constant.GetawaySearchResultCardFormDetailData.expDate = expiryDate
                
            } else if dropDownSelectionRow == 2 {
                
                let cardType = Constant.MyClassConstants.allowedCreditCardType[row]
                var name = cardType.name ?? ""
                if name == "MASTER CARD" {
                    name = "MASTERCARD".localized()
                }
                Constant.GetawaySearchResultCardFormDetailData.cardType = name
                
            } else {
                
            }
        } else {
            
             if dropDownSelectionRow == 0 {
                if !Constant.countryListArray.isEmpty {
                    if let countryName = Constant.countryListArray[row].countryName {
                        Constant.GetawaySearchResultCardFormDetailData.country = countryName
                    }
                    Constant.GetawaySearchResultCardFormDetailData.countryCode = Constant.countryListArray[row].countryCode ?? ""
                }
            
                Helper.getStates(countryCode: Constant.GetawaySearchResultCardFormDetailData.countryCode, CompletionBlock: { [weak self] error in
                    if let Error = error {
                        self?.presentErrorAlert(UserFacingCommonError.handleError(Error))
                    } else if Constant.stateListArray.count == 0 {
                        DispatchQueue.main.async {
                            Constant.GetawaySearchResultCardFormDetailData.state = "N/A".localized()
                            Constant.GetawaySearchResultCardFormDetailData.stateCode = " "
                            self?.cardDetailTBLview.reloadData()
                        }
                    }
                })
                
             } else {
                if !Constant.stateListArray.isEmpty {
                    if let stateName = Constant.stateListArray[row].name,
                        let stateCode = Constant.stateListArray[row].code {
                        Constant.GetawaySearchResultCardFormDetailData.state = stateName
                        Constant.GetawaySearchResultCardFormDetailData.stateCode = stateCode
                    }
                }
            }
        }
    }
}

// implementing data source methods for picker view.
extension AddDebitOrCreditCardViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if dropDownSelectionRow == 3 {
            
            return 2
            
        } else {
           return 1
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if dropDownSelectionSection == 0 {
            
            if dropDownSelectionRow == 3 {
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
            
            if dropDownSelectionRow == 0 {
                return Constant.countryListArray.count
            } else {
                return Constant.stateListArray.count
            }

        }
    }
}

//***** extension class for uitextfield delegate methods definition *****//
extension AddDebitOrCreditCardViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField?.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = textField.text as NSString? ?? ""
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if Int(textField.accessibilityValue.unwrappedString) == 0 {
            if textField.tag == 0 {
                Constant.GetawaySearchResultCardFormDetailData.nameOnCard = textAfterUpdate
            } else if textField.tag == 1 {
                Constant.GetawaySearchResultCardFormDetailData.cardNumber = textAfterUpdate
            } else {
                Constant.GetawaySearchResultCardFormDetailData.cvv = textAfterUpdate
            }
        } else {
                
            if textField.tag == 1 {
                
                Constant.GetawaySearchResultCardFormDetailData.address1 = textAfterUpdate
            } else if textField.tag == 2 {
                Constant.GetawaySearchResultCardFormDetailData.address2 = textAfterUpdate
            } else if textField.tag == 3 {
                Constant.GetawaySearchResultCardFormDetailData.city = textAfterUpdate
            } else {
                Constant.GetawaySearchResultCardFormDetailData.pinCode = textAfterUpdate
                }
            }
            return  true
        }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        moved = true

        if Int(textField.accessibilityValue.unwrappedString) == 0 {

            if textField.tag == 0 {
               textField.keyboardType = .default
            } else {
                textField.keyboardType = .numberPad
                addDoneButtonOnNumpad(textField: textField)
            }
            
        } else {
            
            if textField.tag == 5 {
                textField.keyboardType = .numberPad
                addDoneButtonOnNumpad(textField: textField)
            } else {
                textField.keyboardType = .default
            }
            
        }
    }
}
