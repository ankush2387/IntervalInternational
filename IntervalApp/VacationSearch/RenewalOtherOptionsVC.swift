//
//  RenewalOtherOptionsVC.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 10/3/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

//***** Custom delegate method declaration *****//
protocol RenewalOtherOptionsVCDelegate {
    func selectedRenewal(selectedRenewal: String, forceRenewals: ForceRenewals)
}

class RenewalOtherOptionsVC: UIViewController {
    
    //***** Custom cell delegate to access the delegate method *****//
    var delegate: RenewalOtherOptionsVCDelegate?
    
    // MARK: - clas  outlets
    @IBOutlet weak var renewalOtherOptionsTableView: UITableView!
    
    // class variables
    var forceRenewals = ForceRenewals()
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Constant.RunningDevice.deviceIdiom == .phone {
            //Set title for table view
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 375, height: 40))
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
            headerLabel.textAlignment = .center
            headerLabel.text = Constant.MyClassConstants.renewalsHeaderTitle
            renewalOtherOptionsTableView.tableHeaderView = headerLabel
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Clicked
    
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectClicked(_ sender: UIButton) {
        // core select clicked
        if sender.tag == 0 {
            delegate?.selectedRenewal(selectedRenewal: Helper.renewalType(type: 2), forceRenewals: forceRenewals)
        } else { // non core select clicked
            
            // show guest certificate
            let lowestTerm = forceRenewals.crossSelling[0].term
            for renewal in forceRenewals.crossSelling {
                if renewal.productCode == Constant.productCodeImageNames.platinum && renewal.term == lowestTerm {
                    Constant.MyClassConstants.isChangeNoThanksButtonTitle = true
                    Constant.MyClassConstants.noThanksForNonCore = true
             self.dismiss(animated: true, completion: nil)
                    delegate?.selectedRenewal(selectedRenewal: Helper.renewalType(type: 0), forceRenewals: forceRenewals)
                    return
                    
                } else {
                    Constant.MyClassConstants.noThanksForNonCore = false
                    Constant.MyClassConstants.isChangeNoThanksButtonTitle = false
                    self.dismiss(animated: true, completion: nil)
                    delegate?.selectedRenewal(selectedRenewal: Helper.renewalType(type: 0), forceRenewals: forceRenewals)
                    return
                }
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - table view datasource
extension RenewalOtherOptionsVC: UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewelCell) as!
        RenewelCell
        
        let term = "1-year"
        
        var priceAndCurrency = ""
        
        if indexPath.section == 0 {
            for comboProduct in (forceRenewals.comboProducts) {
                let lowestTerm = comboProduct.renewalComboProducts[0].term
                for renewalComboProduct in comboProduct.renewalComboProducts where renewalComboProduct.term == lowestTerm {
                        //hide renewal image here
                        cell.renewelImageView?.isHidden = true
                        
                        // show core and non core here
                        
                        cell.renewelCoreImageView?.isHidden = false
                        cell.renewelnonCoreImageView?.isHidden = false
                        
                        // currency code
                        var currencyCodeWithSymbol = ""
                        if let currencyCode = forceRenewals.currencyCode {
                            currencyCodeWithSymbol = Helper.currencyCodeToSymbol(code: currencyCode)
                        }
                        if renewalComboProduct.isCoreProduct {
                            if let productCode = renewalComboProduct.productCode {
                            cell.renewelCoreImageView?.image = UIImage(named: productCode)
                            }
                            
                            let price = String(format: "%.0f", renewalComboProduct.price)
                            
                            priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                            
                            // formatted string
                    
                            let mainString = Helper.returnIntervalMembershipString(price: priceAndCurrency, term: term)
                            
                            let range = (mainString as NSString).range(of: priceAndCurrency)
                            
                            let attributeString = NSMutableAttributedString(string: mainString)
                            
                            attributeString.setAttributes([NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                            
                            cell.renewelLbl?.attributedText = attributeString
                            
                        } else {
                            if let productCode = renewalComboProduct.productCode {
                                cell.renewelnonCoreImageView?.image = UIImage(named: productCode)
                            }
                            
                            let price = String(format: "%.0f", renewalComboProduct.price)
                            
                            priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                            
                            // formatted string
                            guard let displayName = renewalComboProduct.displayName?.capitalized else { return cell }
                            let mainString = Helper.returnIntervalMembershipStringWithDisplayName2(displayName: displayName, price: priceAndCurrency, term: term)
                            
                            let range = (mainString as NSString).range(of: priceAndCurrency)
                            
                            let attributeString = NSMutableAttributedString(string: mainString)
                            
                            attributeString.setAttributes([NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                            
                            let nextLine = NSMutableAttributedString(string: "\n\n")
                            
                            let attributedString = cell.renewelLbl?.attributedText
                            
                            let combination = NSMutableAttributedString()
                            
                            combination.append(attributedString!)
                            combination.append(nextLine)
                            combination.append(attributeString)
                            
                            cell.renewelLbl?.attributedText = combination
                            break
                            
                        }
            }
        }
            return cell
        } else {
            
            let lowestTerm = forceRenewals.products[0].term
            for coreProduct in forceRenewals.products where coreProduct.term == lowestTerm {
                
                    // hide core and non core image here
                    cell.renewelCoreImageView?.isHidden = true
                    cell.renewelnonCoreImageView?.isHidden = true
                    
                    // show only non core image
                if let productCode = coreProduct.productCode {
                    cell.renewelImageView?.image = UIImage(named:productCode)
                }
                    var currencyCodeWithSymbol = ""
                    if let currencyCode = forceRenewals.currencyCode {
                          currencyCodeWithSymbol = Helper.currencyCodeToSymbol(code: currencyCode)
                    }
                    guard let displayName = coreProduct.displayName?.capitalized, let currencyCode = forceRenewals.currencyCode else { return cell }
                    let price = String(format: "%.0f", coreProduct.price)
                    priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + currencyCode
                    
                    // formatted string
                    let mainString = Helper.returnIntervalMembershipStringWithDisplayName5(displayName: displayName, price: priceAndCurrency, term: term)
                    
                    let range = (mainString as NSString).range(of: priceAndCurrency)
                    
                    let attributeString = NSMutableAttributedString(string: mainString)
                    
                    attributeString.setAttributes([NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                    cell.renewelLbl?.attributedText = attributeString
                    
                    // set button select tag
                    cell.buttonSelect.tag = indexPath.section
                    break
        }
        return cell
    }
}
}

// MARK: - table view delegate
extension RenewalOtherOptionsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        view.backgroundColor = .clear
        
        return view
        
    }
    
}
