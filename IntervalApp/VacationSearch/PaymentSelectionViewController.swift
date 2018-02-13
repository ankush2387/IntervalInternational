//
//  PaymentSelectionViewController.swift
//  IntervalApp
//
//  Created by Chetu on 17/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class PaymentSelectionViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak fileprivate var paymentSelectionTBLview: UITableView!
    
    //Class variables
    var requiredSectionIntTBLview = 1
    var selectedCardIndex = -1
    var lastFourDigitCardNumber = ""
    var cardType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateResortHoldingTime), name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
        
        showHudAsync()
        UserClient.getCreditCards(Session.sharedSession.userAccessToken!, onSuccess: { response in
            
            Constant.MyClassConstants.memberCreditCardList = response
            self.hideHudAsync()
            DispatchQueue.main.async(execute: {
                self.paymentSelectionTBLview.reloadData()
            })
        }, onError: { [unowned self] error in
            self.hideHudAsync()
            self.paymentSelectionTBLview.reloadData()
            self.presentErrorAlert(UserFacingCommonError.handleError(error))
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func updateResortHoldingTime() {
        
        if Constant.holdingTime == 0 {
            Constant.holdingTimer?.invalidate()
            let alertController = UIAlertController(title: Constant.AlertMessages.holdingTimeLostTitle, message: Constant.AlertMessages.holdingTimeLostMessage, preferredStyle: .alert)
            let Ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default) { (_:UIAlertAction)  in
                
                 self.performSegue(withIdentifier: "unwindToAvailabiity", sender: self)
            }
            alertController.addAction(Ok)
            present(alertController, animated: true, completion:nil)
        }
    }
    // function to dismis current controller on cancel button button pressed
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    func doneButton_Clicked(_ sender: UIBarButtonItem) {
        for textField in view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
    }
    
    // function called when credit card selected from card list
    func checkBoxCheckedAtIndex(_ sender: IUIKCheckbox) {
        
        selectedCardIndex = sender.tag
        paymentSelectionTBLview.reloadData()
        
        var isCardExpired: Bool = false
        let creditcard = Constant.MyClassConstants.memberCreditCardList[selectedCardIndex]
      
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.MyClassConstants.dateTimeFormat
        var expiryDate: Date?
        if let date = creditcard.expirationDate {
            
            let dateStringArray = date.components(separatedBy: "-")
            if dateStringArray.count > 2 {
                expiryDate = dateFormatter.date(from: date)
            } else {
                dateFormatter.dateFormat = Constant.MyClassConstants.monthDateFormat
                expiryDate = dateFormatter.date(from: date)
            }
            if let expireDate = expiryDate {
               let myComponents = (myCalendar as NSCalendar).components([.month, .year], from: expireDate)
                if let month = myComponents.month, let year = myComponents.year {
                    let CurrDate = Date()
                    let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                    let CurrYear = calendar.component(.year, from: CurrDate)
                    let CurrMonth = calendar.component(.month, from: CurrDate)
                    if year < CurrYear {
                        //card Expired
                        isCardExpired = true
                   
                    } else if year == CurrYear, month < CurrMonth {
                             isCardExpired = true
                    } else {
                             isCardExpired = false
                    }
                }
            }
        }

        if isCardExpired == true {
            
            var cvv: UITextField
            var expiryDate: UITextField
            
            let title = Constant.PaymentSelectionControllerCellIdentifiersAndHardCodedStrings.cvvandExpiryDateAlertTitle
            
            let message = "\(cardType!) Ending in \(lastFourDigitCardNumber) \n\n\n"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.isModalInPopover = true
            
            let inputFrame = CGRect(x: 0, y: 140, width: 270, height: 40)
            let inputView: UIView = UIView(frame: inputFrame)
            
            let codeFrame = CGRect(x: 7, y: 0, width: 120, height: 35)
            cvv = UITextField(frame: codeFrame)
            cvv.placeholder = Constant.textFieldTitles.cvv
            cvv.layer.borderWidth = 1.0
            cvv.borderStyle = UITextBorderStyle.line
            cvv.layer.borderColor = UIColor.lightGray.cgColor
            cvv.keyboardType = UIKeyboardType.numberPad
            addDoneButtonOnNumpad(textField: cvv)
            
            let numberFrame = CGRect(x: 142, y: 0, width: 120, height: 35)
            expiryDate = UITextField(frame: numberFrame)
            expiryDate.placeholder = Constant.textFieldTitles.expirationDatePlaceHolder
            expiryDate.layer.borderWidth = 1.0
            expiryDate.borderStyle = UITextBorderStyle.line
            expiryDate.layer.borderColor = UIColor.lightGray.cgColor
            expiryDate.returnKeyType = .done
            expiryDate.autocorrectionType = .no
            expiryDate.keyboardType = UIKeyboardType.numbersAndPunctuation
            expiryDate.delegate = self
            //adding text fields on view
            inputView.addSubview(cvv)
            inputView.addSubview(expiryDate)
            alert.view.addSubview(inputView)
            
            alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: .default, handler: { (_) in
                self.selectedCardIndex = -1
                self.paymentSelectionTBLview.reloadData()
                }))
            
            alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.done, style: .default, handler: { [unowned self] (_) in
                guard let cvvNumber = cvv.text else { return }
                guard let expDate = expiryDate.text else { return }
                
                if cvvNumber.isEmpty {
                    self.selectedCardIndex = -1
                    self.paymentSelectionTBLview.reloadData()
                    let alertController = UIAlertController(title: "Alert".localized(), message: "CVV can not be empty!".localized(), preferredStyle: .alert)
                    let Ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default)
                    alertController.addAction(Ok)
                    self.present(alertController, animated: true, completion:nil)
                    return
                }
                let letters = CharacterSet.letters
                let range = expDate.rangeOfCharacter(from: letters)
                if expDate.isEmpty || range != nil {
                    self.selectedCardIndex = -1
                    self.paymentSelectionTBLview.reloadData()
                    let alertController = UIAlertController(title: "Alert".localized(), message: "Exp Date can not be empty or Alphabet!".localized(), preferredStyle: .alert)
                    let Ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default)
                    alertController.addAction(Ok)
                    self.present(alertController, animated: true, completion:nil)
                    return
                }
               
                Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex].cvv = cvvNumber
                let expirydate = expDate
                let dateArr: [String] = expirydate.components(separatedBy: "/")
                
                if dateArr.count == 1 || dateArr[0].count > 2 || dateArr[1].count > 2 {
                    
                    self.selectedCardIndex = -1
                    self.paymentSelectionTBLview.reloadData()
                    let alertController = UIAlertController(title: "Wrong Exp Date Format".localized(), message: "Please enter exp Date with MM/YY format.".localized(), preferredStyle: .alert)
                    let Ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default)
                    alertController.addAction(Ok)
                    self.present(alertController, animated: true, completion:nil)
                    return
                }
                // And then to access the individual words:
                let month: String = dateArr[0]
                let year: String = "20" + dateArr[1]
                
                //creating date component with new exp date
                var dateComponents = DateComponents()
                dateComponents.year = Int(year)
                dateComponents.month = Int(month)
                dateComponents.day = 01
                
                let dt = Calendar(identifier: Calendar.Identifier.gregorian).date(from: dateComponents)
                let df = DateFormatter()
                df.dateFormat = Constant.MyClassConstants.dateTimeFormat
                let dateString: String = df.string(from: dt!)

                (Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]).expirationDate = dateString
                
                if let creditCardCount = Session.sharedSession.contact?.creditcards?.count {
                    if self.selectedCardIndex < (creditCardCount) {
                        
                        Constant.MyClassConstants.selectedCreditCard.removeAll()
                        let existingCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                        Constant.MyClassConstants.selectedCreditCard.append(existingCard)
                        self.navigationController?.popViewController(animated: true)
                        
                    } else {
                        
                        Constant.MyClassConstants.selectedCreditCard.removeAll()
                        let newCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                        newCard.creditcardId = 0
                        Constant.MyClassConstants.selectedCreditCard.append(newCard)
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                }
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: Constant.PaymentSelectionControllerCellIdentifiersAndHardCodedStrings.cvvAlertTitle, message: "\(cardType!) Ending in \(lastFourDigitCardNumber)", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = Constant.textFieldTitles.cvv
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: .default, handler: { (_) in
            self.selectedCardIndex = -1
            self.paymentSelectionTBLview.reloadData()
        }))

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.done, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
           
          (Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]).cvv = (textField?.text)
            
            if let creditCardCount = Session.sharedSession.contact?.creditcards?.count {
                if self.selectedCardIndex < creditCardCount {
                    
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    let existingCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                    Constant.MyClassConstants.selectedCreditCard.append(existingCard)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    let newCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                    newCard.creditcardId = 0
                    Constant.MyClassConstants.selectedCreditCard.append(newCard)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            }))
        self.present(alert, animated: true) {
            
        }
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//Extension class starts from here
extension PaymentSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == Constant.MyClassConstants.memberCreditCardList.count {
            
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            if let addCardController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.addDebitOrCreditCardViewController) as? AddDebitOrCreditCardViewController {
                navigationController?.pushViewController(addCardController, animated: true)
               
            }
        }
    }
}

// extension class for tableview datasource method implementation
extension PaymentSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return requiredSectionIntTBLview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.memberCreditCardList.count + 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == Constant.MyClassConstants.memberCreditCardList.count {
            
            if Constant.RunningDevice.deviceIdiom == .pad {
                return 80
            } else {
                return 50
            }
        } else {
            if Constant.RunningDevice.deviceIdiom == .pad {
               return 150
            } else {
                return 80
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == Constant.MyClassConstants.memberCreditCardList.count {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.addNewCreditCardCell, for: indexPath) as? AddNewCreditCardCell else {
                
                return UITableViewCell()
            }
            return cell
        } else {
            
            let creditcard = Constant.MyClassConstants.memberCreditCardList[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.selectPaymentMethodCell, for: indexPath) as? SelectPaymentMethodCell else {
                
                return UITableViewCell()
            }
            if let cardHolderName = creditcard.cardHolderName, let typeCode = creditcard.typeCode {
                cell.cardHolderName.text = cardHolderName.capitalized
                cell.cardImageView.image = UIImage(named: Helper.cardImageMapping(cardType: typeCode))
            }
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constant.MyClassConstants.dateTimeFormat
            var expiryDate: Date?
            if let date = creditcard.expirationDate {
                
                let dateStringArray = date.components(separatedBy: "-")
                if dateStringArray.count > 2 {
                    expiryDate = dateFormatter.date(from: date)
                } else {
                    dateFormatter.dateFormat = Constant.MyClassConstants.monthDateFormat
                    expiryDate = dateFormatter.date(from: date)
                }
                if let expireDate = expiryDate {
                   let myComponents = (myCalendar as NSCalendar).components([.month, .year], from:expireDate)
                    if let month = myComponents.month, let year = myComponents.year {
                        let CurrDate = Date()
                        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                        let CurrYear = calendar.component(.year, from: CurrDate)
                        let CurrMonth = calendar.component(.month, from: CurrDate)
                        if year < CurrYear {
                            cell.expireDate.textColor = UIColor.red
                            cell.expireDateLabel.textColor = UIColor.red
                            cell.expireDateLabel.text = "Expired :".localized()
                        } else if year == CurrYear {
                            if month < CurrMonth {
                                cell.expireDate.textColor = UIColor.red
                                cell.expireDateLabel.textColor = UIColor.red
                                cell.expireDateLabel.text = "Expired :"
                            } else {
                                cell.expireDate.textColor = UIColor.black
                                cell.expireDateLabel.textColor = UIColor.black
                                cell.expireDateLabel.text = "Expires :".localized()
                            }
                        }
                        
                        if month < 10 {
                            cell.expireDate.text = "0\(month)/\(year)".localized()
                        } else {
                            cell.expireDate.text = "\(month)/\(year)".localized()
                        }
                        
                    }
                }
            } else {
                cell.expireDate.text = ""
            }
            
            if let cardNumber = creditcard.cardNumber {
                
                let last4 = cardNumber.substring(from:(cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
                cell.cardLastFourDigitNumber.text = last4
                lastFourDigitCardNumber = last4
                if let typeCode = creditcard.typeCode {
                    let cardType = Helper.cardTypeCodeMapping(cardType: typeCode)
                    self.cardType = cardType
                    cell.cardType.text = "\(cardType) ending in".localized()
                }
                if selectedCardIndex == indexPath.row {
                    cell.cardSelectionCheckBox.checked = true
                } else {
                    cell.cardSelectionCheckBox.checked = false
                }
            }

            cell.cardSelectionCheckBox.tag = indexPath.row
            cell.cardSelectionCheckBox.addTarget(self, action: #selector(PaymentSelectionViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            
            return cell
        }
    }
}

extension PaymentSelectionViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
