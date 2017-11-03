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
    @IBOutlet weak var paymentSelectionTBLview: UITableView!
    
    //Class variables
    var requiredSectionIntTBLview = 1
    var selectedCardIndex = -1
    var lastFourDigitCardNumber = ""
    var cardType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // function to dismis current controller on cancel button button pressed
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
     self.dismiss(animated: true, completion: nil)
    }
    
    func doneButton_Clicked( _ sender:UIBarButtonItem){
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
    }
    
    // function called when credit card selected from card list
    func checkBoxCheckedAtIndex(_ sender:IUIKCheckbox) {
        
        self.selectedCardIndex = sender.tag
        paymentSelectionTBLview.reloadData()
        
        
        var isCardExpired : Bool = false
      
        let creditcard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
      
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateTimeFormat
        var expiryDate: Date?
        if let date = creditcard.expirationDate {
            
            let dateStringArray = date.components(separatedBy: "-")
            if(dateStringArray.count > 2){
                expiryDate = dateFormatter.date(from: creditcard.expirationDate!)!
            }else{
                dateFormatter.dateFormat = Constant.MyClassConstants.monthDateFormat
                expiryDate = dateFormatter.date(from: creditcard.expirationDate!)!
            }
            
            let myComponents = (myCalendar as NSCalendar).components([.month,.year], from: expiryDate!)
            let month = myComponents.month!
            let year = myComponents.year!
            let CurrDate = Date()
            let calendar = Calendar.current
            let CurrYear = calendar.component(.year, from: CurrDate)
            let CurrMonth = calendar.component(.month, from: CurrDate)
            
            if(year<CurrYear){
                //card Expired
                isCardExpired = true
            }else if(year == CurrYear){
                if(month < CurrMonth){
                    //card Expired
                    isCardExpired = true
                    
                }else{
                    isCardExpired = false
                }
            }
        }

        if(isCardExpired == true){
            
            var cvv: UITextField?
            var expiryDate: UITextField?
            
            let title = Constant.PaymentSelectionViewControllerCellIdentifiersAndHardCodedStrings.cvvandExpiryDateAlertTitle;
            
            let message = "\(cardType!) Ending in \(lastFourDigitCardNumber) \n\n\n";
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert);
            alert.isModalInPopover = true;
            
            
            let inputFrame = CGRect(x: 0, y: 140, width: 270, height: 40)
            let inputView: UIView = UIView(frame: inputFrame);
            
            
            let codeFrame = CGRect(x: 7, y: 0, width: 120, height: 35)
            let cvvTextField: UITextField = UITextField(frame: codeFrame);
            cvvTextField.placeholder = Constant.textFieldTitles.cvv;
            cvvTextField.layer.borderWidth = 1.0
            cvvTextField.borderStyle = UITextBorderStyle.line;
            cvvTextField.layer.borderColor = UIColor.lightGray.cgColor
            cvvTextField.keyboardType = UIKeyboardType.numberPad;
            
            let numberFrame = CGRect(x: 142, y: 0, width: 120, height: 35)
            let expirydateTextField: UITextField = UITextField(frame: numberFrame);
            expirydateTextField.placeholder = Constant.textFieldTitles.expirationDatePlaceHolder;
            expirydateTextField.layer.borderWidth = 1.0
            expirydateTextField.borderStyle = UITextBorderStyle.line;
            expirydateTextField.layer.borderColor = UIColor.lightGray.cgColor
            expirydateTextField.keyboardType = UIKeyboardType.numbersAndPunctuation;
            
            cvv = cvvTextField;
            expiryDate = expirydateTextField;
            
            inputView.addSubview(cvv!);
            inputView.addSubview(expiryDate!);
            
            alert.view.addSubview(inputView);
            
            alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: .default, handler: nil))
            
            
            alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.done, style: .default, handler: { [weak alert] (_) in
                
                
                if((cvv?.text?.characters.count)! == 0){
                    cvv?.layer.borderColor = UIColor.red.cgColor
                    return
                }
                if((expiryDate?.text?.characters.count)! == 0){
                    expiryDate?.layer.borderColor = UIColor.red.cgColor
                    return
                }
                
                (Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]).cvv = (cvv?.text)
                let expirydate = expiryDate?.text
                let dateArr : [String] = expirydate!.components(separatedBy: "/")
                
                // And then to access the individual words:
                let month : String = dateArr[0]
                let year : String = "20" + dateArr[1]
                
                //creating date component with new exp date
                var dateComponents = DateComponents()
                dateComponents.year = Int(year)
                dateComponents.month = Int(month)
                dateComponents.day = 01
        
                
                let dt = Calendar(identifier: Calendar.Identifier.gregorian).date(from: dateComponents)
                let df = DateFormatter()
                df.dateFormat = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateTimeFormat
                let dateString: String = df.string(from: dt!)

                (Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]).expirationDate = dateString
                
                if(self.selectedCardIndex < (Session.sharedSession.contact?.creditcards?.count)!) {
                    
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    let existingCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                    Constant.MyClassConstants.selectedCreditCard.append(existingCard)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                else {
                    
                    Constant.MyClassConstants.selectedCreditCard.removeAll()
                    let newCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                    newCard.creditcardId = 0
                    Constant.MyClassConstants.selectedCreditCard.append(newCard)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
            }))
            
            self.present(alert, animated: true, completion: nil);
            
            
        }else{
        
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: Constant.PaymentSelectionViewControllerCellIdentifiersAndHardCodedStrings.cvvAlertTitle, message: "\(cardType!) Ending in \(lastFourDigitCardNumber)", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = Constant.textFieldTitles.cvv
            textField.keyboardType = UIKeyboardType.numberPad
            
            //Add done button to numeric pad keyboard
            /*let toolbarDone = UIToolbar.init()
            toolbarDone.sizeToFit()
            let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                                  target: self, action: #selector(PaymentSelectionViewController.doneButton_Clicked(_:)))
            
            toolbarDone.items = [barBtnDone] // You can even add cancel button too
            textField.inputAccessoryView = toolbarDone*/
            
        }
        
    
        alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: .default, handler: nil))

        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: Constant.AlertPromtMessages.done, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
           
          (Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]).cvv = (textField?.text)
            
            if(self.selectedCardIndex < (Session.sharedSession.contact?.creditcards?.count)!) {
                
                Constant.MyClassConstants.selectedCreditCard.removeAll()
                let existingCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                Constant.MyClassConstants.selectedCreditCard.append(existingCard)
                self.dismiss(animated: true, completion: nil)
                
            }
            else {
                
                Constant.MyClassConstants.selectedCreditCard.removeAll()
                 let newCard = Constant.MyClassConstants.memberCreditCardList[self.selectedCardIndex]
                newCard.creditcardId = 0
                Constant.MyClassConstants.selectedCreditCard.append(newCard)
                self.dismiss(animated: true, completion: nil)
                
            }
            
            }))
        self.present(alert, animated: true){
            
        }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//Extension class starts from here

extension PaymentSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == Constant.MyClassConstants.memberCreditCardList.count) {
            
            if(UIDevice.current.userInterfaceIdiom == .pad) {
                
                let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                let secondViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.addDebitOrCreditCardViewController) as! AddDebitOrCreditCardViewController
                self.modalTransitionStyle = .flipHorizontal
                secondViewController.delegate = self
                self.present(secondViewController, animated: true, completion: nil)
            } else {
            let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let secondViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.addDebitOrCreditCardViewController) as! AddDebitOrCreditCardViewController
            self.modalTransitionStyle = .flipHorizontal
            secondViewController.delegate = self
            self.present(secondViewController, animated: true, completion: nil)
         }
        } else {
            
        }
    }
    
}

// extension class for tableview datasource method implementation
extension PaymentSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.requiredSectionIntTBLview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.memberCreditCardList.count + 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.row == Constant.MyClassConstants.memberCreditCardList.count) {
            
            if(Constant.RunningDevice.deviceIdiom == .pad) {
                return 80
            } else {
                return 50
            }
        } else {
            if(Constant.RunningDevice.deviceIdiom == .pad) {
               return 150
            } else {
                return 80
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row ==  Constant.MyClassConstants.memberCreditCardList.count) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.addNewCreditCardCell, for: indexPath) as! AddNewCreditCardCell
            return cell
        }
        else {
            
            let creditcard = Constant.MyClassConstants.memberCreditCardList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.selectPaymentMethodCell, for: indexPath) as! SelectPaymentMethodCell
            cell.cardHolderName.text = creditcard.cardHolderName!.capitalized
            cell.cardImageView.image = UIImage(named: Helper.cardImageMapping(cardType: creditcard.typeCode!))
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateTimeFormat
            var expiryDate: Date?
            if let date = creditcard.expirationDate {
                
                let dateStringArray = date.components(separatedBy: "-")
                if(dateStringArray.count > 2){
                    expiryDate = dateFormatter.date(from: creditcard.expirationDate!)!
                }else{
                    dateFormatter.dateFormat = Constant.MyClassConstants.monthDateFormat
                    expiryDate = dateFormatter.date(from: creditcard.expirationDate!)!
                }
                
                let myComponents = (myCalendar as NSCalendar).components([.month,.year], from: expiryDate!)
                let month = myComponents.month!
                let year = myComponents.year!
                let CurrDate = Date()
                let calendar = Calendar.current
                let CurrYear = calendar.component(.year, from: CurrDate)
                let CurrMonth = calendar.component(.month, from: CurrDate)
                
                if(year<CurrYear){
                    cell.expireDate.textColor = UIColor.red
                    cell.expireDateLabel.textColor = UIColor.red
                    cell.expireDateLabel.text = "Expired :"
                }else if(year == CurrYear){
                    if(month < CurrMonth){
                        cell.expireDate.textColor = UIColor.red
                        cell.expireDateLabel.textColor = UIColor.red
                        cell.expireDateLabel.text = "Expired :"
                    }else{
                        cell.expireDate.textColor = UIColor.black
                        cell.expireDateLabel.textColor = UIColor.black
                        cell.expireDateLabel.text = "Expires :"
                    }
                }
                
                if(month < 10) {
                    cell.expireDate.text = "0\(myComponents.month!)/\(myComponents.year!)"
                }
                else {
                    cell.expireDate.text = "\(myComponents.month!)/\(myComponents.year!)"
                }
            }else{
                cell.expireDate.text = ""
            }
            
            
            
            let cardNumber = creditcard.cardNumber!
            let last4 = cardNumber.substring(from:(cardNumber.index((cardNumber.endIndex), offsetBy: -4)))
            cell.cardLastFourDigitNumber.text = last4
            self.lastFourDigitCardNumber = last4
            let cardType = Helper.cardTypeCodeMapping(cardType: (creditcard.typeCode!))
            self.cardType = cardType
            cell.cardType.text = "\(cardType) ending in"
            if(self.selectedCardIndex == indexPath.row) {
                cell.cardSelectionCheckBox.checked = true
            }
            else {
                cell.cardSelectionCheckBox.checked = false
            }
            
            cell.cardSelectionCheckBox.tag = indexPath.row
            cell.cardSelectionCheckBox.addTarget(self, action: #selector(PaymentSelectionViewController.checkBoxCheckedAtIndex(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            
            return cell
        }
        
    }
}

//custom delegate method
extension PaymentSelectionViewController: AddDebitOrCreditCardViewControllerDelegate {

    func newCreditCardAdded() {
        self.dismiss(animated: true, completion: nil)
    }
}
