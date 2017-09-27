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
    var arrayProducts = [Renewal]()
    
    
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

        // Do any additional setup after loading the view.
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
        
        if(Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()) {
            return (Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals?.products.count)!
            
        } else {
            return (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.products.count)!
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewelCell) as! RenewelCell
        
        var priceAndCurrency = ""
        
        var currencyCodeWithSymbol = ""
        
        var currencyCode = ""
        
        var arrProducts = NSMutableArray()
        
        if(Constant.MyClassConstants.searchBothExchange || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()) {
            
            arrProducts = Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals?.products as! NSMutableArray
            
            currencyCode = (Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals?.currencyCode)!
            
            currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals?.currencyCode)!)
            
        } else {
            
            arrProducts = Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.products as! NSMutableArray
            
            currencyCode = (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!
            
            currencyCodeWithSymbol = Helper.currencyCodetoSymbol(code: (Constant.MyClassConstants.processStartResponse.view?.forceRenewals?.currencyCode)!)
           
        }
        
        for products in arrProducts as! [Renewal] {
            
            if products.term == 12 {
                
                let term = "1 year"
                
                let price = String(format:"%.2f", products.price)
                
               // priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + (Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals?.currencyCode)!
                
                priceAndCurrency = currencyCodeWithSymbol + "\(price)" + " " + currencyCode
                
                // make attributed string
                let mainString = "Your interval membership expire before your travel date.To continue, a \(term) membership fee of \(priceAndCurrency) will be included with this transaction."
                
                let range = (mainString as NSString).range(of: priceAndCurrency)
                
                let attributeString = NSMutableAttributedString.init(string: mainString)
                
                attributeString.setAttributes([NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueMedium, size: CGFloat(26.0))!
                    , NSForegroundColorAttributeName : UIColor(red: 0.0/255.0, green: 201.0/255.0, blue: 11.0/255.0, alpha: 1.0)], range: range)
                
                cell.renewelLbl.attributedText = attributeString
                break
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
    


