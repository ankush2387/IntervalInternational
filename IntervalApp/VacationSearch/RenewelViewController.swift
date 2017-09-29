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

class RenewelViewController: UIViewController {

    //MARK:- clas  outlets
    @IBOutlet weak var renewalsTableView: UITableView!
    
    // class variables
    var arrayProductStorage = NSMutableArray()
    var renewelMessage = ""
    var sectionCount = 0
    var isCombo = false
    var forceRenewals = ForceRenewals()
    
    // MARK:- lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
            //Set title for table view
            let headerLabel = UILabel(frame:CGRect(x: 0, y: 0, width: 375, height: 40))
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0)
            headerLabel.textAlignment = .center
            headerLabel.text = Constant.MyClassConstants.renewalsHeaderTitle
            renewalsTableView.tableHeaderView = headerLabel
        }
        checkForComboNonCombo()

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
        
    }

    
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickNoThanks(_ sender: UIButton) {
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
        }else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as! WhoWillBeCheckingInIPadViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.present(viewController, animated: true, completion: nil)
            //self.navigationController?.pushViewController(viewController, animated: true)
           // self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        let term = "1 year"
        
        var priceAndCurrency = ""
        //Combo
        if((forceRenewals.comboProducts.count) > 0) {
            print("A Combo")
            
        }else if(((forceRenewals.crossSelling.count) > 0 && (forceRenewals.products.count) > 0) || (forceRenewals.products.count) > 0){
            
            //Core, Non combo both
            
            for product in (forceRenewals.products) {
                
                if product.term == 12 {
                    
                    cell.renewelImageView?.image = UIImage.init(named: product.productCode!)
                    
                    cell.renewelCoreImageView?.image = UIImage.init(named: product.productCode!)
                    
                    // hide core and non core here
                    
                    cell.renewelCoreImageView?.isHidden = true
                    cell.renewelnonCoreImageView?.isHidden = true
                    
                    let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!)
                    
                    let price = String(format:"%.2f", product.price)
                    
                    priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                    
                    // make attributed string
                    let mainString = "Your interval membership expire before your travel date.To continue, a \(term) membership fee of \n\(priceAndCurrency)\nwill be included with this transaction."
                    
                    let range = (mainString as NSString).range(of: priceAndCurrency)
                    
                    let attributeString = NSMutableAttributedString.init(string: mainString)
                    
                    attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(25.0))!
                        , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                    
                    cell.renewelLbl?.attributedText = attributeString
                    break
                }
                
            }
            
            if(indexPath.section == 0 && forceRenewals.crossSelling.count > 0){
                for nonCoreProduct in (forceRenewals.crossSelling){
                    if nonCoreProduct.term == 12{
                        
                        // hide renewel image  here
                        cell.renewelImageView?.isHidden = true
                        
                        
                        // show core and non core image here
                        cell.renewelCoreImageView?.isHidden = false
                        cell.renewelnonCoreImageView?.isHidden = false
                        
                        cell.renewelnonCoreImageView?.image = UIImage.init(named: nonCoreProduct.productCode!)
                        
                        let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!)
                        
                        let price = String(format:"%.2f", nonCoreProduct.price)
                        
                        priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                        
                        // Create attributed string
                        let mainString = "In addition, your \(String(describing: nonCoreProduct.displayName!)) membership expires before your travel date. To keep your Interval Platinum benefits, a \(term) membership fee of \n\(priceAndCurrency)\nwill be included with this transaction."
                        
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
                        cell.renewelLbl?.backgroundColor = UIColor.orange
                        break
                    }
                }
            }
            
            
        }else if((forceRenewals.crossSelling.count) > 0){
            //Non core
            
            if indexPath.section == 0 {
                for nonCoreProduct in (forceRenewals.crossSelling){
                    if nonCoreProduct.term == 12{
                        
                        // show renewel image  here
                        cell.renewelImageView?.isHidden = false
                        cell.renewelImageView?.image = UIImage.init(named: nonCoreProduct.productCode!)
                        
                        // show core and non core image here
                        cell.renewelCoreImageView?.isHidden = true
                        cell.renewelnonCoreImageView?.isHidden = true
                        
                        
                        let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!)
                        
                        let price = String(format:"%.2f", nonCoreProduct.price)
                        
                        priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                        
                        // Create attributed string
                        let mainString = "Your \(String(describing: nonCoreProduct.displayName!)) membership expires before your travel date. To continue booking your Getaway at the current discounted rate, a \(term) interval platinum a, membership fee of \n\(priceAndCurrency)\nwill be included with this transaction."
                        
                        let range = (mainString as NSString).range(of: priceAndCurrency)
                        
                        let attributeString = NSMutableAttributedString.init(string: mainString)
                        
                        attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                            , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                        
                        //let nextLine = NSMutableAttributedString.init(string: "\n\n")
                        
                        //let attributedString = cell.renewelLbl?.attributedText
                        
                        let combination = NSMutableAttributedString()
                        
                        //combination.append(attributedString!)
                        //combination.append(nextLine)
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
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view   = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        view.backgroundColor = .clear
        
        return view
        
    }
  
    
}
    


