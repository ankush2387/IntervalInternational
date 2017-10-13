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
   protocol RenewelViewControllerDelegate {
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalArray:[Renewal])
    func noThanks()
    func otherOptions(forceRenewals:ForceRenewals)
    func dismissWhatToUse(renewalArray:[Renewal])
}


//protocol SelectRenewalsOptionDelegate {
//    
//    func selecteButtonClicked(renewalArray:[Renewal])
//    
//}

class RenewelViewController: UIViewController {
 

    
    //MARK:- Delegate
    var delegate: RenewelViewControllerDelegate?
    
    // delegate
    //var delegate:SelectRenewalsOptionDelegate?

    //MARK:- clas  outlets
    @IBOutlet weak var renewalsTableView: UITableView!
    
    @IBOutlet weak var lblHeaderTitle: UILabel?
    
    // class variables
    var arrayProductStorage = NSMutableArray()
    var renewelMessage = ""
    var sectionCount = 0
    var isCombo = false
    var isNonCombo = false
    var isCore = false
    var isNonCore = false
    var renewalArray = [Renewal()]
    
    var forceRenewals = ForceRenewals()
    
    // MARK:- lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(Constant.MyClassConstants.noThanksForNonCore || Constant.MyClassConstants.isChangeNoThanksButtonTitle) {
             Constant.MyClassConstants.renewalsHeaderTitle = Constant.MyClassConstants.freeGuestCertificateTitle
            lblHeaderTitle?.text = Constant.MyClassConstants.freeGuestCertificateTitle
        }else if(forceRenewals.comboProducts.count > 0 || (forceRenewals.crossSelling.count > 0 && forceRenewals.products.count > 0)){
            Constant.MyClassConstants.renewalsHeaderTitle = Constant.MyClassConstants.comboHeaderTitle
            lblHeaderTitle?.text = Constant.MyClassConstants.comboHeaderTitle
        }else{
            Constant.MyClassConstants.renewalsHeaderTitle = Constant.MyClassConstants.coreHeaderTitle
            lblHeaderTitle?.text = Constant.MyClassConstants.coreHeaderTitle
        }
        
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
            //Set title for table view
            let headerLabel = UILabel(frame:CGRect(x: 0, y: 0, width: 375, height: 40))
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
            headerLabel.textAlignment = .center
            headerLabel.text = Constant.MyClassConstants.renewalsHeaderTitle
            renewalsTableView.tableHeaderView = headerLabel
        }
        checkForComboNonCombo()
        
        /*let value: Int = 1605436
        
        // "1,605,436" where Locale == en_US
        let formattedInt = String(format: "%d", locale: Locale.current, value)
        
        print("formated price is \(formattedInt)")*/

        // Do any additional setup after loading the view.
    }
    
    //MARK:- Check for combo and non combo
    
    func checkForComboNonCombo(){
        if(Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
           forceRenewals = (Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals)!
            
        }else{
            
            forceRenewals = (Constant.MyClassConstants.processStartResponse.view?.forceRenewals)!
        }
        
        // case for core product
        if(forceRenewals.comboProducts.count == 0 && forceRenewals.crossSelling.count == 0 && forceRenewals.products.count > 0){
            sectionCount = 1
            
            // case for como
        }else if(forceRenewals.comboProducts.count > 0 || (forceRenewals.crossSelling.count == 0 && forceRenewals.products.count == 0)){
            
           sectionCount = 2
           isCombo = true
            
        }else{
            
            sectionCount = 2
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Clicked
    
    @IBAction func selectClicked(_ sender: UIButton) {
    
        renewalArray.removeAll()
        if(sender.tag == 0 && isNonCombo){
            for renewal in forceRenewals.products{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalItem.productCode = renewal.productCode
                    renewalArray.append(renewalItem)
                    break
                }
            }
            for renewal in forceRenewals.crossSelling{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalItem.productCode = renewal.productCode
                    renewalArray.append(renewalItem)
                    break
                }
            }
        }else if(sender.tag == 1 && isNonCombo){
            for renewal in forceRenewals.products{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalItem.productCode = renewal.productCode
                    renewalArray.append(renewalItem)
                    
                    // show guest certificate
                    for renewal in forceRenewals.crossSelling {
                        if (renewal.productCode == "PLT" && renewal.term == 12) {
                            Constant.MyClassConstants.noThanksForNonCore = true
                        }else{
                            Constant.MyClassConstants.noThanksForNonCore = false
                        }
                    }
                   
                }
            }
            
        }else if(isCombo){
            for renewalComboArray in forceRenewals.comboProducts{
                for renewals in renewalComboArray.renewalComboProducts{
                    if(renewals.term == 12){
                        let renewalItem = Renewal()
                        renewalItem.id = renewals.id
                        renewalItem.productCode = renewals.productCode
                        renewalArray.append(renewalItem)
                    }
                }
            }
        }else if(isNonCore){
            for renewal in forceRenewals.crossSelling{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalItem.productCode = renewal.productCode
                    renewalArray.append(renewalItem)
                    
                    for renewal in forceRenewals.crossSelling {
                        if (renewal.productCode == "PLT" && renewal.term == 12) {
                            Constant.MyClassConstants.noThanksForNonCore = true
                        } else {
                            Constant.MyClassConstants.noThanksForNonCore = false
                
                        }
                    }

                    
                    break
                }
            }
        }else if(isCore){
            for renewal in forceRenewals.products{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalItem.productCode = renewal.productCode
                    renewalArray.append(renewalItem)
                    break
                }
            }
        }
        
        if(Constant.RunningDevice.deviceIdiom == .phone || Constant.RunningDevice.deviceIdiom == .pad){
            if(Constant.MyClassConstants.noThanksForNonCore){
                self.dismiss(animated: true, completion: nil)
                
                if Constant.MyClassConstants.isFromWhatToUse {
                    self.delegate?.dismissWhatToUse(renewalArray: renewalArray)
                } else {
                    delegate?.selectedRenewalFromWhoWillBeCheckingIn(renewalArray: renewalArray)
                    
                }
                
            }else{
                
                self.dismiss(animated: false, completion: nil)
                
                if Constant.MyClassConstants.isFromWhatToUse {
                    self.delegate?.dismissWhatToUse(renewalArray: renewalArray)
                } else {
                    delegate?.selectedRenewalFromWhoWillBeCheckingIn(renewalArray: renewalArray)
                    
                }

            }
        }
        
    }

    
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickNoThanks(_ sender: UIButton) {
        
        if(Constant.MyClassConstants.noThanksForNonCore){
            self.dismiss(animated: true, completion: nil)
            Constant.MyClassConstants.noThanksForNonCore = false
            self.delegate?.noThanks()
        }else{
            
            if self.isCombo {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.otherOptions(forceRenewals: self.forceRenewals)
                return
            }else if(isNonCore){
                if(Constant.MyClassConstants.noThanksForNonCore){
                    Constant.MyClassConstants.noThanksForNonCore = false
                }else{
                    if(Constant.MyClassConstants.isNoThanksFromRenewalAgain){
                        Constant.MyClassConstants.isNoThanksFromRenewalAgain = false
                        //self.dismiss(animated: true, completion: nil)
                        self.delegate?.noThanks()
                        return
                    }else{
                        
                        // show guest certificate
                        for renewal in forceRenewals.crossSelling {
                            if (renewal.productCode == Constant.productCodeImageNames.platinum && renewal.term == 12) {
                                Constant.MyClassConstants.noThanksForNonCore = true
                            }else{
                                Constant.MyClassConstants.noThanksForNonCore = false
                            }
                        }
                        self.delegate?.noThanks()
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
        if(segue.destination.isKind(of: WhoWillBeCheckingInViewController.self)){
            
            let whoWillBeCheckingInVwController = segue.destination as! WhoWillBeCheckingInViewController
            whoWillBeCheckingInVwController.renewalsArray = renewalArray
        }
    }
    

}


//MARK:- table view datasource
extension RenewelViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionCount
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewelCell) as! RenewelCell
        cell.selectionStyle = .none
        cell.selectButton?.tag = indexPath.section
        
        let term = "1 year"
        
        var priceAndCurrency = ""
        
        //Combo
        if((forceRenewals.comboProducts.count) > 0) {
    
             if (lblHeaderTitle?.text == Constant.MyClassConstants.freeGuestCertificateTitle || Constant.MyClassConstants.renewalsHeaderTitle == Constant.MyClassConstants.freeGuestCertificateTitle) {
                
                for crossSelling in (forceRenewals.crossSelling) {
                    
                    if crossSelling.term == 12 {
                        
                        cell.renewelImageView?.image = UIImage.init(named: crossSelling.productCode!)
                        
                        cell.renewelCoreImageView?.image = UIImage.init(named: crossSelling.productCode!)
                        
                        // hide core and non core here
                        
                        cell.renewelCoreImageView?.isHidden = true
                        cell.renewelnonCoreImageView?.isHidden = true
                        
                        let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (forceRenewals.currencyCode)!)
                        
                        let price = String(format:"%.0f", crossSelling.price)
                        
                        priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                        
                        // make attributed string
                       let formattedString = Helper.returnStringWithPriceAndTerm(price: priceAndCurrency, term: term)
                        
                        let range = (formattedString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString.init(string: formattedString)
                        
                        attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                            , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                        
                        cell.renewelLbl?.attributedText = attributeString
                        cell.selectButton?.setTitle(Constant.MyClassConstants.renewNow, for: .normal)
                        
                        break
                    }
                }
                
            } else {
                
                for comboProduct in (forceRenewals.comboProducts) {
                    
                    for renewalComboProduct in comboProduct.renewalComboProducts {
                        if renewalComboProduct.term == 12 {
                            
                            //hide renewal image here
                            cell.renewelImageView?.isHidden = true
                            
                            // show core and non core here
                            
                            cell.renewelCoreImageView?.isHidden = false
                            cell.renewelnonCoreImageView?.isHidden = false
                            
                            // currency code
                            let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (forceRenewals.currencyCode)!)
                            
                            if (renewalComboProduct.isCoreProduct) {
                                cell.renewelCoreImageView?.image = UIImage.init(named: renewalComboProduct.productCode!)
                                
                                
                                let price = String(format:"%.0f", renewalComboProduct.price)
                                
                                priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                                
                                // make attributed string
                                let mainString = "\(Constant.MyClassConstants.intervalMembership) \(term) membership fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                                
                                let range = (mainString as NSString).range(of: priceAndCurrency)
                                
                                let attributeString = NSMutableAttributedString.init(string: mainString)
                                
                                attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                                    , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                                
                                cell.renewelLbl?.attributedText = attributeString
                                
                                
                            } else {
                                cell.renewelnonCoreImageView?.image = UIImage.init(named: renewalComboProduct.productCode!)
                                
                                let price = String(format:"%.0f", renewalComboProduct.price)
                                
                                priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                                var mainString = ""
                                // Create attributed string
                                if(Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange){
                                    mainString = "In addition, to keep your \(String(describing: renewalComboProduct.displayName!)) benefits, a \(term) membership fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                                }else{
                                     mainString = "In addition, your \(String(describing: renewalComboProduct.displayName!)) membership expires before your travel date. To continue booking your Getaway at the current discounted rate, a \(term) membership fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                                }
                                
                                
                                let range = (mainString as NSString).range(of: priceAndCurrency)
                                
                                let attributeString = NSMutableAttributedString.init(string: mainString)
                                
                                attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                                    , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                                
                                let nextLine = NSMutableAttributedString.init(string: "\n\n")
                                
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
                    
                    
                }
                
            }
            
            
            // show other option button
            
            if ((forceRenewals.crossSelling.count) > 0 && (forceRenewals.products.count) > 0) {
                if indexPath.section == 1 {
                    self.isCombo = true
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewalAdditionalCell) as! RenewalAdditionalCell
                    
                    if (Constant.MyClassConstants.noThanksForNonCore || Constant.MyClassConstants.isChangeNoThanksButtonTitle){
                        cell.noThanksButton.setTitle(Constant.MyClassConstants.noThanks, for: .normal)
                    } else {
                        cell.noThanksButton.setTitle(Constant.MyClassConstants.otherOptions, for: .normal)
                    }
                    
                    
                    return cell
                }
            }
            
            
            
        }else if(((forceRenewals.crossSelling.count) > 0 && (forceRenewals.products.count) > 0) || (forceRenewals.products.count) > 0){
            
            //Core, Non combo both
            isCore = true
            
            if (lblHeaderTitle?.text == Constant.MyClassConstants.freeGuestCertificateTitle || Constant.MyClassConstants.renewalsHeaderTitle == Constant.MyClassConstants.freeGuestCertificateTitle) {
                
                if indexPath.section == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewalAdditionalCell) as! RenewalAdditionalCell
                    cell.noThanksButton.setTitle(Constant.MyClassConstants.noThanks, for: .normal)
                    
                    return cell
                }
              
                
            } else {
                for product in (forceRenewals.products) {
                    
                    if product.term == 12 {
                        
                        cell.renewelImageView?.image = UIImage.init(named: product.productCode!)
                        
                        cell.renewelCoreImageView?.image = UIImage.init(named: product.productCode!)
                        
                        // hide core and non core here
                        
                        cell.renewelCoreImageView?.isHidden = true
                        cell.renewelnonCoreImageView?.isHidden = true
                        
                        let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (forceRenewals.currencyCode)!)
                        
                        let price = String(format:"%.0f", product.price)
                        
                        priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                        
                        // make attributed string
                        let mainString = "\(Constant.MyClassConstants.intervalMembership) \(term) membership fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                        
                        let range = (mainString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString.init(string: mainString)
                        
                        attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                            , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                        
                        cell.renewelLbl?.attributedText = attributeString
                        
                        break
                    }
                }
                
            }

            
            if(indexPath.section == 0 && forceRenewals.crossSelling.count > 0){
                isCore = false
                isNonCombo = true
                for nonCoreProduct in (forceRenewals.crossSelling){
                    if nonCoreProduct.term == 12{
                        
                        // hide renewel image  here
                        cell.renewelImageView?.isHidden = true
                        
                        
                        // show core and non core image here
                        cell.renewelCoreImageView?.isHidden = false
                        cell.renewelnonCoreImageView?.isHidden = false
                        
                        cell.renewelnonCoreImageView?.image = UIImage.init(named: nonCoreProduct.productCode!)
                        
                        let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (forceRenewals.currencyCode)!)
                        
                        let price = String(format:"%.0f", nonCoreProduct.price)
                        
                        priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                        
                        // Create attributed string
                        let mainString = "In addition, your \(String(describing: nonCoreProduct.displayName!)) membership expires before your travel date. To keep your Interval Platinum benefits, a \(term) membership fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                        
                        let range = (mainString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString.init(string: mainString)
                        
                        attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                            , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                        
                        let nextLine = NSMutableAttributedString.init(string: "\n\n")
                        
                        let attributedString = cell.renewelLbl?.attributedText
                        
                        let combination = NSMutableAttributedString()
                        
                        combination.append(attributedString!)
                        combination.append(nextLine)
                        combination.append(attributeString)
                        
                        
                        cell.renewelLbl?.attributedText = combination
                        
                        if(Constant.MyClassConstants.noThanksForNonCore){
                            cell.selectButton?.setTitle(Constant.MyClassConstants.renewNow, for: .normal)
                        }else{
                            cell.selectButton?.setTitle(Constant.MyClassConstants.select, for: .normal)
                        }
                        
                        break
                    }
                }
            }
            
        }else if((forceRenewals.crossSelling.count) > 0){
            //Non core
            isNonCore = true
            
            if indexPath.section == 0 {
                for nonCoreProduct in (forceRenewals.crossSelling){
                    if nonCoreProduct.term == 12{
                        
                        // show renewel image  here
                        cell.renewelImageView?.isHidden = false
                        cell.renewelImageView?.image = UIImage.init(named: nonCoreProduct.productCode!)
                        
                        // show core and non core image here
                        cell.renewelCoreImageView?.isHidden = true
                        cell.renewelnonCoreImageView?.isHidden = true
                        
                        
                        let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (forceRenewals.currencyCode)!)
                        
                        let price = String(format:"%.0f", nonCoreProduct.price)
                        
                        priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                        
                        // Create attributed string
                        var mainString = "Your \(String(describing: nonCoreProduct.displayName!)) membership expires before your travel date. To continue booking your Getaway at the current discounted rate, a \(term) \(String(describing: nonCoreProduct.displayName!)) membership fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                        if(Constant.MyClassConstants.noThanksForNonCore){
                            mainString = "Get a FREE Guest Certificate now and every time with \(String(describing: nonCoreProduct.displayName!)). Your Interval Platinum must be active through your travel dates to receive FREE Guest Certificates. To upgrade or renew, a \(term) \(String(describing: nonCoreProduct.displayName!)) fee of \n\(priceAndCurrency)\n\(Constant.MyClassConstants.intervalTransaction)"
                        }
                        
                        if(Constant.MyClassConstants.noThanksForNonCore){
                            cell.selectButton?.setTitle(Constant.MyClassConstants.renewNow, for: .normal)
                        }else{
                            cell.selectButton?.setTitle(Constant.MyClassConstants.select, for: .normal)
                        }
                        
                        let range = (mainString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString.init(string: mainString)
                        
                        attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                            , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                        
                        
                        let combination = NSMutableAttributedString()
                        combination.append(attributeString)
                        cell.renewelLbl?.attributedText = combination
                        break
                    }
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewalAdditionalCell) as! RenewalAdditionalCell
                return cell
            }
            
        }
        
        return cell
        
    }
    
}

//MARK:- table view delegate
extension RenewelViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(isNonCombo){
            return 50
        }
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view   = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        view.backgroundColor = .clear
        
        return view
        
    }
  
}




