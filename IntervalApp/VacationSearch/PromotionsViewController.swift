//
//  PromotionsViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/19/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class PromotionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promotionsTableView: UITableView!
    var promotionsArray = [Promotion]()
    var selectedPromotionIndex: IndexPath?
    var completionHandler: (Bool) -> Void = { _ in }
    
    override func viewDidLoad() {
        promotionsTableView.delegate = self
        promotionsTableView.dataSource = self
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func didPressCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func promotionCellSelected() {

    }

}

extension PromotionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPromotionIndex = indexPath
        promotionsTableView.reloadData()
        
        if indexPath.section == 0 {
            Constant.MyClassConstants.isPromotionsEnabled = true

            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                if let shopExchangeFees = Constant.MyClassConstants.exchangeFees, let currencyCode = shopExchangeFees.currencyCode, let exchangeOriginalPrice = Constant.MyClassConstants.exchangeFeeOriginalPrice  {
                    Constant.MyClassConstants.selectedDestinationPromotionDisplayName = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: exchangeOriginalPrice, promotion: promotionsArray[indexPath.row])
                }
                Constant.MyClassConstants.exchangeFees?.shopExchange?.selectedOfferName = promotionsArray[indexPath.row].offerName
            } else {
                if let rentalFees = Constant.MyClassConstants.rentalFees, let currencyCode = rentalFees.currencyCode, let rentalOriginalPrice = Constant.MyClassConstants.rentalFeeOriginalPrice  {
                    Constant.MyClassConstants.selectedDestinationPromotionDisplayName = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: rentalOriginalPrice, promotion: promotionsArray[indexPath.row])
                }
                Constant.MyClassConstants.rentalFees?.rental?.selectedOfferName = promotionsArray[indexPath.row].offerName
            }

        } else {
            Constant.MyClassConstants.isPromotionsEnabled = false
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
               Constant.MyClassConstants.exchangeFees?.shopExchange?.selectedOfferName = "No Thanks".localized()
            } else {
                Constant.MyClassConstants.rentalFees?.rental?.selectedOfferName = "No Thanks".localized()
            }
            
            Constant.MyClassConstants.selectedDestinationPromotionDisplayName = "No Thanks".localized()
        }
        
        self.dismiss(animated: true, completion: nil)
        completionHandler(true)
    }
    
}

extension PromotionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return promotionsArray.count
        }
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let promotion = promotionsArray[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as? PromotionsCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
   
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                if let shopExchangeFees = Constant.MyClassConstants.exchangeFees, let currencyCode = shopExchangeFees.currencyCode, let exchangeOriginalPrice = Constant.MyClassConstants.exchangeFeeOriginalPrice  {
                    cell.promotionTextLabel.text = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: exchangeOriginalPrice, promotion: promotion)
                }
            } else {
                if let rentalFees = Constant.MyClassConstants.rentalFees, let currencyCode = rentalFees.currencyCode, let rentalOriginalPrice = Constant.MyClassConstants.rentalFeeOriginalPrice  {
                    cell.promotionTextLabel.text = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: rentalOriginalPrice, promotion: promotion)
                }
            }
 
            if cell.promotionTextLabel.text == Constant.MyClassConstants.selectedDestinationPromotionDisplayName {
                cell.promotionSelectionCheckBox.checked = true
            } else {
                cell.promotionSelectionCheckBox.checked = false
            }
            
            cell.promotionSelectionCheckBox.isUserInteractionEnabled = false
            cell.promotionSelectionCheckBox.addTarget(self, action: #selector(PromotionsViewController.promotionCellSelected), for: .touchUpInside)
            return cell
            
        } else {
            
           guard let cell = promotionsTableView.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as? PromotionsCell else { return UITableViewCell() }
            cell.promotionTextLabel.text = "No Thanks".localized()
            cell.selectionStyle = .none

            if cell.promotionTextLabel.text == Constant.MyClassConstants.selectedDestinationPromotionDisplayName {
                cell.promotionSelectionCheckBox.checked = true
            } else {
                cell.promotionSelectionCheckBox.checked = false
            }

            cell.promotionSelectionCheckBox.isUserInteractionEnabled = false
            return cell
        }
    }
    
}
