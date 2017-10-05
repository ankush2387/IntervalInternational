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

class RenewalOtherOptionsVC: UIViewController {
    
    //MARK:- clas  outlets
    @IBOutlet weak var renewalOtherOptionsTableView: UITableView!
    
    // class variables
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
            renewalOtherOptionsTableView.tableHeaderView = headerLabel
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Clicked
    
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectClicked(_ sender: UIButton) {
        // core select clicked
        if sender.tag == 0 {
            print("core selecte clicked")
            
        } else { // non core select clicked
            print("non core selecte clicked")
            
        }
    }
    
}


//MARK:- table view datasource
extension RenewalOtherOptionsVC:UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewelCell) as!
        RenewelCell
        
        let term = "1 year"
        
        var priceAndCurrency = ""
        
        if indexPath.section == 0 {
            for product in (forceRenewals.products) {
                
                if product.term == 12 {
                    
                    cell.renewelImageView?.image = UIImage.init(named: product.productCode!)
                    
                    cell.renewelCoreImageView?.image = UIImage.init(named: product.productCode!)
                    
                    // hide core and non core here
                    
                    cell.renewelCoreImageView?.isHidden = true
                    cell.renewelnonCoreImageView?.isHidden = true
                    
                    let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!)
                    
                    let price = String(format:"%.0f", product.price)
                    
                    priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                    
                    // make attributed string
                    let mainString = "Your interval membership expire before your travel date.To continue, a \(term) membership fee of \n\(priceAndCurrency)\nwill be included with this transaction."
                    
                    let range = (mainString as NSString).range(of: priceAndCurrency)
                    
                    let attributeString = NSMutableAttributedString.init(string: mainString)
                    
                    attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(25.0))!
                        , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                    
                    cell.renewelLbl?.attributedText = attributeString
                    
                    // set button select tag
                    cell.buttonSelect.tag = indexPath.section
                    break
                }
                
            }
            
        } else {
            
            for nonCoreProduct in (forceRenewals.crossSelling){
                if nonCoreProduct.term == 12{
                    
                 
                    // hide core and non core image here
                    cell.renewelCoreImageView?.isHidden = true
                    cell.renewelnonCoreImageView?.isHidden = true
                    
                    // show only non core image
                    cell.renewelImageView?.image = UIImage.init(named: nonCoreProduct.productCode!)
                    
                    let currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!)
                    
                    let price = String(format:"%.0f", nonCoreProduct.price)
                    
                    priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (forceRenewals.currencyCode)!
                    
                    // Create attributed string
                    let mainString = "Your \(String(describing: nonCoreProduct.displayName!)) membership expires before your travel date. To keep your Interval Platinum benefits, a \(term) membership fee of \n\(priceAndCurrency)\nwill be included with this transaction."
                    
                    let range = (mainString as NSString).range(of: priceAndCurrency)
                    
                    let attributeString = NSMutableAttributedString.init(string: mainString)
                    
                    attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(20.0))!
                        , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                    
                    /*let nextLine = NSMutableAttributedString.init(string: "\n\n")
                    
                    let attributedString = cell.renewelLbl?.attributedText
                    
                    let combination = NSMutableAttributedString()
                    
                    combination.append(attributedString!)
                    combination.append(nextLine)
                    combination.append(attributeString)*/
                    
                    cell.renewelLbl?.attributedText = attributeString
                    
                    // set button select tag
                    cell.buttonSelect.tag = indexPath.section
                    break
                }
            }
        }
        
        return cell
    }
    
}


//MARK:- table view delegate
extension RenewalOtherOptionsVC:UITableViewDelegate {
    
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

