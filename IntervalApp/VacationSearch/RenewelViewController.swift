//
//  RenewelViewController.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 9/21/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

//***** Custom delegate method declaration *****//
protocol RenewelViewControllerDelegate: class {
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?, selectedRelinquishment: ExchangeRelinquishment?)
    func noThanks(selectedRelinquishment: ExchangeRelinquishment?)
    func otherOptions(forceRenewals: ForceRenewals)
    func dismissWhatToUse(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?)
}

class RenewelViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: RenewelViewControllerDelegate?

    // MARK: - clas  outlets
    @IBOutlet fileprivate weak var renewalsTableView: UITableView!
    @IBOutlet fileprivate weak var lblHeaderTitle: UILabel?
    
    // class variables
    //FIXME(Frank) - what is this as NSMutableArray? - this is not GOOD
    var arrayProductStorage = NSMutableArray()
    var renewelMessage = ""
    var sectionCount = 0
    //FIXME(Frank) - why 2 flags to handle the same?
    var isCombo = false
    var isNonCombo = false
    //FIXME(Frank) - why 2 flags to handle the same?
    var isCore = false
    var isNonCore = false
    
    var filterRelinquishment: ExchangeRelinquishment?
    //FIXME(Frank) - why we need here the forceRenewals? - why is not optional?
    var forceRenewals = ForceRenewals()
    var renewalCoreProduct: Renewal?
    var renewalNonCoreProduct: Renewal?
    
    // MARK: - lifecycle
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if Constant.MyClassConstants.noThanksForNonCore || Constant.MyClassConstants.isChangeNoThanksButtonTitle {
             Constant.MyClassConstants.renewalsHeaderTitle = Constant.MyClassConstants.freeGuestCertificateTitle
            lblHeaderTitle?.text = Constant.MyClassConstants.freeGuestCertificateTitle
        } else if !forceRenewals.comboProducts.isEmpty || (!forceRenewals.crossSelling.isEmpty && !forceRenewals.products.isEmpty) {
            Constant.MyClassConstants.renewalsHeaderTitle = Constant.MyClassConstants.comboHeaderTitle
            lblHeaderTitle?.text = Constant.MyClassConstants.comboHeaderTitle
        } else {
            Constant.MyClassConstants.renewalsHeaderTitle = Constant.MyClassConstants.coreHeaderTitle
            lblHeaderTitle?.text = Constant.MyClassConstants.coreHeaderTitle
        }
        
        if Constant.RunningDevice.deviceIdiom == .phone {
            //Set title for table view
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 375, height: 40))
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
            headerLabel.textAlignment = .center
            headerLabel.text = Constant.MyClassConstants.renewalsHeaderTitle
            renewalsTableView.tableHeaderView = headerLabel
        }
        checkForComboNonCombo()
 
    }
    
    // MARK: - Check for combo and non combo
    func checkForComboNonCombo() {
        if Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            if let forceRenewalsFromExchange = Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals {
                forceRenewals = forceRenewalsFromExchange
            }
        } else {
            if let forceRenewalsFromRental = Constant.MyClassConstants.processStartResponse.view?.forceRenewals {
                forceRenewals = forceRenewalsFromRental
            }
        }
        
        // case for core product
        if forceRenewals.comboProducts.count == 0 && forceRenewals.crossSelling.count == 0 && !forceRenewals.products.isEmpty {
            sectionCount = 1
            
            // case for como
        } else if !forceRenewals.comboProducts.isEmpty || (forceRenewals.crossSelling.count == 0 && forceRenewals.products.count == 0) {
            
           sectionCount = 2
           isCombo = true
            
        } else {
            
            sectionCount = 2
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Clicked
    
    @IBAction func selectClicked(_ sender: UIButton) {
        
        if sender.tag == 0 && isNonCombo {
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products where renewal.term == lowestTerm {
                renewalCoreProduct = renewal
                break
            }
            
            let lowestCrossSellingTerm = forceRenewals.crossSelling[0].term
            for renewal in forceRenewals.crossSelling where renewal.term == lowestCrossSellingTerm {
                renewalNonCoreProduct = renewal
                break
            }
            
        } else if sender.tag == 1 && isNonCombo {
            
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products where renewal.term == lowestTerm {
                renewalCoreProduct = renewal
               
                // show guest certificate
                let lowestTerm = forceRenewals.crossSelling[0].term
                for renewal in forceRenewals.crossSelling {
                    if renewal.productCode == "PLT" && renewal.term == lowestTerm {
                        Constant.MyClassConstants.noThanksForNonCore = true
                    } else {
                        Constant.MyClassConstants.noThanksForNonCore = false
                    }
                }
            }
            
        } else if isCombo {
            
            if !forceRenewals.comboProducts.isEmpty {
                //FIXME(Frank): take the 1st combo
                let firstRenewComboProduct = forceRenewals.comboProducts[0]
                // Combo is composed by 2 renewals (Core and NonCore)
                if firstRenewComboProduct.renewalComboProducts.count == 2 {
                    // Split the combo
                    let renewalPairA = firstRenewComboProduct.renewalComboProducts[0]
                    let renewalPairB = firstRenewComboProduct.renewalComboProducts[1]
                    
                    if renewalPairA.isCoreProduct {

                        renewalCoreProduct = Renewal()
                        renewalCoreProduct?.id = renewalPairA.id
                        renewalCoreProduct?.productCode = renewalPairA.productCode
                    } else {
                        renewalNonCoreProduct = Renewal()
                        renewalNonCoreProduct?.id = renewalPairA.id
                        renewalNonCoreProduct?.productCode = renewalPairA.productCode
                    }

                    if renewalPairB.isCoreProduct {
                        renewalCoreProduct = Renewal()
                        renewalCoreProduct?.id = renewalPairB.id
                        renewalCoreProduct?.productCode = renewalPairB.productCode
                    } else {
                        renewalNonCoreProduct = Renewal()
                        renewalNonCoreProduct?.id = renewalPairB.id
                        renewalNonCoreProduct?.productCode = renewalPairB.productCode
                    }
                }
            }

        } else if isNonCore {
            
            let lowestTerm = forceRenewals.crossSelling[0].term
            for renewal in forceRenewals.crossSelling where renewal.term == lowestTerm {
                renewalNonCoreProduct = renewal

                //FIXME(Frank): - what is this?
                for renewal in forceRenewals.crossSelling {
                    if renewal.productCode == "PLT" && renewal.term == lowestTerm {
                        Constant.MyClassConstants.noThanksForNonCore = true
                    } else {
                        Constant.MyClassConstants.noThanksForNonCore = false
                    }
                }
                break
            }
            
        } else if isCore {
            
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products where renewal.term == lowestTerm {
                renewalCoreProduct = renewal
                break
            }
        }
        
        if Constant.MyClassConstants.isFromWhatToUse {
            self.delegate?.dismissWhatToUse(renewalCoreProduct: renewalCoreProduct, renewalNonCoreProduct: renewalNonCoreProduct)
        } else {
            delegate?.selectedRenewalFromWhoWillBeCheckingIn(renewalCoreProduct: renewalCoreProduct, renewalNonCoreProduct: renewalNonCoreProduct, selectedRelinquishment: filterRelinquishment)
            
        }
    }
    
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickNoThanks(_ sender: UIButton) {
        
        if Constant.MyClassConstants.noThanksForNonCore {
            self.dismiss(animated: true, completion: nil)
            Constant.MyClassConstants.noThanksForNonCore = false
            self.delegate?.noThanks(selectedRelinquishment: filterRelinquishment)
            
        } else {
            
            if self.isCombo {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.otherOptions(forceRenewals: self.forceRenewals)
                return
            } else if isNonCore {
                if Constant.MyClassConstants.noThanksForNonCore {
                    Constant.MyClassConstants.noThanksForNonCore = false
                } else {
                    if Constant.MyClassConstants.isNoThanksFromRenewalAgain {
                        Constant.MyClassConstants.isNoThanksFromRenewalAgain = false
                        //self.dismiss(animated: true, completion: nil)
                        self.delegate?.noThanks(selectedRelinquishment: filterRelinquishment)
                        return
                    } else {
                        
                        // show guest certificate
                        let lowestTerm = forceRenewals.crossSelling[0].term
                        for renewal in forceRenewals.crossSelling {
                            if renewal.productCode == Constant.productCodeImageNames.platinum && renewal.term == lowestTerm {
                                Constant.MyClassConstants.noThanksForNonCore = true
                            } else {
                                Constant.MyClassConstants.noThanksForNonCore = false
                            }
                        }
                        self.delegate?.noThanks(selectedRelinquishment: filterRelinquishment)
                    }
                }
                
                return
            }
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

// MARK: - table view datasource
extension RenewelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionCount
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewelCell) as? RenewelCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.selectButton?.tag = indexPath.section
        
        var term = "1-year"
        
        var priceAndCurrency = ""
        
        let currencyHelper = CurrencyHelperLocator.sharedInstance.provideHelper()
        
        var countryCode: String?
        if let currentProfile = Session.sharedSession.contact {
            countryCode = currentProfile.getCountryCode()
        }
        
        //Combo
        if !forceRenewals.comboProducts.isEmpty {

             if lblHeaderTitle?.text == Constant.MyClassConstants.freeGuestCertificateTitle || Constant.MyClassConstants.renewalsHeaderTitle == Constant.MyClassConstants.freeGuestCertificateTitle {
                let lowestTerm = forceRenewals.crossSelling[0].term
                term = "\( (lowestTerm ?? 12) / 12)-year"
                for crossSelling in forceRenewals.crossSelling where crossSelling.term == lowestTerm {
                    if let productCode = crossSelling.productCode {
                        cell.renewelImageView?.image = UIImage(named: productCode )
                    }
                        
                        // hide core and non core here
                        
                        cell.renewelCoreImageView?.isHidden = true
                        cell.renewelnonCoreImageView?.isHidden = true
                    
                    if let currencyCode = forceRenewals.currencyCode {
                        priceAndCurrency = Helper.createPriceAndCurrency(currencyCode: currencyCode, price: crossSelling.price)
                    }
                        
                        // make attributed string
                        let formattedString = Helper.returnStringWithPriceAndTerm(price: priceAndCurrency, term: term)
                        
                        let range = (formattedString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString(string: formattedString)
                        if let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0)) {
                        attributeString.setAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                    }
                        
                        cell.renewelLbl?.attributedText = attributeString
                        cell.selectButton?.setTitle(Constant.MyClassConstants.renewNow, for: .normal)
                        
                        break
                }
                
            } else {
                let comboLowestTerm = forceRenewals.comboProducts[0].renewalComboProducts[0].term
                term = "\((comboLowestTerm ?? 12)/12)-year"
                for comboProduct in (forceRenewals.comboProducts) {
                    for renewalComboProduct in comboProduct.renewalComboProducts where renewalComboProduct.term == comboLowestTerm {
                            //hide renewal image here
                            cell.renewelImageView?.isHidden = true
                            
                            // show core and non core here
                            
                            cell.renewelCoreImageView?.isHidden = false
                            cell.renewelnonCoreImageView?.isHidden = false
                            
                            // currency code
                        if let currencyCode = forceRenewals.currencyCode {
                            if renewalComboProduct.isCoreProduct {
                                if let productCode = renewalComboProduct.productCode {
                                    cell.renewelCoreImageView?.image = UIImage(named: productCode)
                                }
                                
                                priceAndCurrency = Helper.createPriceAndCurrency(currencyCode: currencyCode, price: renewalComboProduct.price)
                                
                                if let displayName = renewalComboProduct.displayName?.capitalized {
                                    //formatted string
                                    let formattedString = Helper.returnIntervalMembershipString(displayName: displayName, price: priceAndCurrency, term: term)
                                    
                                    let range = (formattedString as NSString).range(of: priceAndCurrency)
                                    
                                    let attributeString = NSMutableAttributedString(string: formattedString)
                                    if let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0)) {
                                        attributeString.setAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                                    }
                                    
                                    cell.renewelLbl?.attributedText = attributeString
                                }
                                
                            } else {
                               
                                if let productCode = renewalComboProduct.productCode {
                                    cell.renewelnonCoreImageView?.image = UIImage(named: productCode)
                                }
                                
                                priceAndCurrency = Helper.createPriceAndCurrency(currencyCode: currencyCode, price: renewalComboProduct.price)
                                var mainString = ""
                                // Create attributed string
                                
                                if let displayName = renewalComboProduct.displayName?.capitalized {
                                if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                                    
                                    mainString = Helper.returnIntervalMembershipStringWithDisplayName(displayName: String(describing: displayName), price: priceAndCurrency, term: term)
                                } else {
                                    
                                    mainString = Helper.returnIntervalMembershipStringWithDisplayName1(displayName: String(describing:displayName), price: priceAndCurrency, term: term)
                                }
                                }
                                
                                let range = (mainString as NSString).range(of: priceAndCurrency)
                                
                                let attributeString = NSMutableAttributedString(string: mainString)
                                
                                attributeString.setAttributes([NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                                
                                let nextLine = NSMutableAttributedString(string: "\n\n")
                                
                                if let attributedString = cell.renewelLbl?.attributedText {
                                
                                let combination = NSMutableAttributedString()
                                
                                combination.append(attributedString)
                                combination.append(nextLine)
                                combination.append(attributeString)
                                
                                cell.renewelLbl?.attributedText = combination
                                }
                                break
                                
                            }

                        }
                        
                     }
                    
                }
                
            }
            
            // show other option button
            
            if !forceRenewals.crossSelling.isEmpty && !forceRenewals.products.isEmpty {
                if indexPath.section == 1 {
                    self.isCombo = true
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewalAdditionalCell) as? RenewalAdditionalCell else { return UITableViewCell() }
                    
                    if Constant.MyClassConstants.noThanksForNonCore || Constant.MyClassConstants.isChangeNoThanksButtonTitle {
                        cell.noThanksButton.setTitle(Constant.MyClassConstants.noThanks, for: .normal)
                    } else {
                        cell.noThanksButton.setTitle(Constant.MyClassConstants.otherOptions, for: .normal)
                    }
                    
                    return cell
                }
            }
            
        } else if !forceRenewals.crossSelling.isEmpty && !forceRenewals.products.isEmpty || !forceRenewals.products.isEmpty {
            
            //Core, Non combo both
            isCore = true
            
            if lblHeaderTitle?.text == Constant.MyClassConstants.freeGuestCertificateTitle || Constant.MyClassConstants.renewalsHeaderTitle == Constant.MyClassConstants.freeGuestCertificateTitle {
                
                if indexPath.section == 1 {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewalAdditionalCell) as? RenewalAdditionalCell else { return UITableViewCell() }
                    cell.noThanksButton.setTitle(Constant.MyClassConstants.noThanks, for: .normal)
                    
                    return cell
                }
                
            } else {
                let lowestTerm = forceRenewals.products[0].term
                //FIXME(Frank): what is this? - term could be "2 year" - this is not GOOD
                term = "\((lowestTerm ?? 12)/12)-year"
                for product in (forceRenewals.products) where product.term == lowestTerm {
                    
                    if let productCode = product.productCode {
                        cell.renewelImageView?.image = UIImage(named: productCode)
                    }
                    // hide core and non core here
                    
                    cell.renewelCoreImageView?.isHidden = true
                    cell.renewelnonCoreImageView?.isHidden = true
                    if let currencyCode = forceRenewals.currencyCode,
                        let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0)) {
                        
                        if let displayName = product.displayName?.capitalized {
                            priceAndCurrency = Helper.createPriceAndCurrency(currencyCode: currencyCode, price: product.price)
                            let formattedString = Helper.returnIntervalMembershipString(displayName: displayName, price: priceAndCurrency, term: term)
                            let range = (formattedString as NSString).range(of: priceAndCurrency)
                            
                            let attributeString = NSMutableAttributedString(string: formattedString)
                            attributeString.setAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                            cell.renewelLbl?.attributedText = attributeString
                        }
                    }
                    
                    break
                }
                
            }
            
            if indexPath.section == 0 && !forceRenewals.crossSelling.isEmpty {
                isCore = false
                isNonCombo = true
                let lowestTerm = forceRenewals.crossSelling[0].term
                term = "\(lowestTerm)-year"
                for nonCoreProduct in (forceRenewals.crossSelling) where nonCoreProduct.term == lowestTerm {
                    // hide renewel image  here
                    cell.renewelImageView?.isHidden = true
                    
                    // show core and non core image here
                    cell.renewelCoreImageView?.isHidden = false
                    cell.renewelnonCoreImageView?.isHidden = false
                    
                    if let productCode = nonCoreProduct.productCode {
                        cell.renewelnonCoreImageView?.image = UIImage(named: productCode)
                    }
                    if let currencyCode = forceRenewals.currencyCode {
                        priceAndCurrency = Helper.createPriceAndCurrency(currencyCode: currencyCode, price: nonCoreProduct.price)
                    }
                    
                    // formatted string
                    if let displayName = nonCoreProduct.displayName?.capitalized {
                        
                        let mainString = Helper.returnIntervalMembershipStringWithDisplayName2(displayName: displayName, price: priceAndCurrency, term: term)
                        
                        let range = (mainString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString(string: mainString)
                        
                        if let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0)) {
                        attributeString.setAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                        }
                        
                        let nextLine = NSMutableAttributedString(string: "\n\n")
                        
                        if let attributedString = cell.renewelLbl?.attributedText {
                        
                        let combination = NSMutableAttributedString()
                        
                        combination.append(attributedString)
                        combination.append(nextLine)
                        combination.append(attributeString)
                        
                        cell.renewelLbl?.attributedText = combination
                        }
                    }
                    
                    if Constant.MyClassConstants.noThanksForNonCore {
                        cell.selectButton?.setTitle(Constant.MyClassConstants.renewNow, for: .normal)
                    } else {
                        cell.selectButton?.setTitle(Constant.MyClassConstants.select, for: .normal)
                    }
                    
                    break
                }
            }
            
        } else if !forceRenewals.crossSelling.isEmpty {
            //Non core
            isNonCore = true
            
            if indexPath.section == 0 {
                
                let lowestTerm = forceRenewals.crossSelling[0].term
                for nonCoreProduct in (forceRenewals.crossSelling) where nonCoreProduct.term == lowestTerm {
                        
                    // show renewel image  here
                    cell.renewelImageView?.isHidden = false
                    if let productCode = nonCoreProduct.productCode {
                        cell.renewelImageView?.image = UIImage(named: productCode)
                    }
                        
                        // show core and non core image here
                    cell.renewelCoreImageView?.isHidden = true
                    cell.renewelnonCoreImageView?.isHidden = true
                    
                    if let currencyCode = forceRenewals.currencyCode {
                        priceAndCurrency = Helper.createPriceAndCurrency(currencyCode: currencyCode, price: nonCoreProduct.price)
                    }
                    
                    if let displayName = nonCoreProduct.displayName?.capitalized {
                        // Create attributed string
                        var mainString = self.filterRelinquishment == nil ? Helper.returnIntervalMembershipStringWithDisplayName3(displayName: displayName, price: priceAndCurrency, term: term) : Helper.returnIntervalMembershipStringWithDisplayName2(displayName: displayName, price: priceAndCurrency, term: term)
                        
                        if Constant.MyClassConstants.noThanksForNonCore {
                            mainString = Helper.returnIntervalMembershipStringWithDisplayName4(displayName: displayName, price: priceAndCurrency, term: term)
                        }
                        
                        let range = (mainString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString(string: mainString)
                        if let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0)) {
                        attributeString.setAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.0 / 255.0, green: 201.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)], range: range)
                        }
                        
                        let combination = NSMutableAttributedString()
                        combination.append(attributeString)
                        cell.renewelLbl?.attributedText = combination
                        
                }
                        
                        if Constant.MyClassConstants.noThanksForNonCore {
                            cell.selectButton?.setTitle(Constant.MyClassConstants.renewNow, for: .normal)
                        } else {
                            cell.selectButton?.setTitle(Constant.MyClassConstants.select, for: .normal)
                        }
                    
                        break
                }
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewalAdditionalCell) as? RenewalAdditionalCell else { return UITableViewCell() }
                return cell
            }
            
        }
        
        return cell
        
    }
    
}

// MARK: - table view delegate
extension RenewelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isNonCombo {
            return 50
        }
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        view.backgroundColor = .clear
        
        return view
        
    }
  
}
