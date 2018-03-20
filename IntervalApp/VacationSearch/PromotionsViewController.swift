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
            let promotion = promotionsArray[indexPath.row]

            // TODO: to Handle the "No Thanks" option selection
            Constant.MyClassConstants.selectedDestinationPromotionOfferName = promotion.offerName
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                Constant.MyClassConstants.exchangeFees?.shopExchange?.selectedOfferName = promotion.offerName
                
                if let shopExchangeFees = Constant.MyClassConstants.exchangeFees, let currencyCode = shopExchangeFees.currencyCode, let exchangeOriginalPrice = Constant.MyClassConstants.exchangeFeeOriginalPrice  {
                    Constant.MyClassConstants.selectedDestinationPromotionDisplayName = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: exchangeOriginalPrice, promotion: promotion)
                }
                
            } else {
                
                Constant.MyClassConstants.rentalFees?.rental?.selectedOfferName = promotion.offerName
                
                if let rentalFees = Constant.MyClassConstants.rentalFees, let currencyCode = rentalFees.currencyCode, let rentalOriginalPrice = Constant.MyClassConstants.rentalFeeOriginalPrice  {
                    Constant.MyClassConstants.selectedDestinationPromotionDisplayName = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: rentalOriginalPrice, promotion: promotion)
                }
            }

        } else {
            
            // TODO: Handle the "No Thanks" option
            Constant.MyClassConstants.isPromotionsEnabled = false
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                Constant.MyClassConstants.exchangeFees?.shopExchange?.selectedOfferName = "No Thanks".localized()
            } else {
                Constant.MyClassConstants.rentalFees?.rental?.selectedOfferName = "No Thanks".localized()
            }
            
            Constant.MyClassConstants.selectedDestinationPromotionOfferName = "No Thanks".localized()
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
            cell.promotionSelectionCheckBox.checked = false
   
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                if let shopExchangeFees = Constant.MyClassConstants.exchangeFees, let currencyCode = shopExchangeFees.currencyCode, let exchangeOriginalPrice = Constant.MyClassConstants.exchangeFeeOriginalPrice  {
                    cell.promotionTextLabel.text = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: exchangeOriginalPrice, promotion: promotion)
                    
                    if let shopExchangeFee = shopExchangeFees.shopExchange, let selectedOfferName = shopExchangeFee.selectedOfferName, promotion.offerName == selectedOfferName {
                        cell.promotionSelectionCheckBox.checked = true
                    }
                }
            } else {
                if let rentalFees = Constant.MyClassConstants.rentalFees, let currencyCode = rentalFees.currencyCode, let rentalOriginalPrice = Constant.MyClassConstants.rentalFeeOriginalPrice  {
                    cell.promotionTextLabel.text = Helper.resolveDestinationPromotionDisplayName(currencyCode: currencyCode, originalPrice: rentalOriginalPrice, promotion: promotion)

                    if let rentalFee = rentalFees.rental, let selectedOfferName = rentalFee.selectedOfferName, promotion.offerName == selectedOfferName {
                        cell.promotionSelectionCheckBox.checked = true
                    }
                }
            }
 
            cell.promotionSelectionCheckBox.isUserInteractionEnabled = false
            cell.promotionSelectionCheckBox.addTarget(self, action: #selector(PromotionsViewController.promotionCellSelected), for: .touchUpInside)
            return cell
            
        } else {
            
           guard let cell = promotionsTableView.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as? PromotionsCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            cell.promotionSelectionCheckBox.checked = false
            cell.promotionTextLabel.text = "No Thanks".localized()

            if cell.promotionTextLabel.text == Constant.MyClassConstants.selectedDestinationPromotionOfferName {
                cell.promotionSelectionCheckBox.checked = true
            }

            cell.promotionSelectionCheckBox.isUserInteractionEnabled = false
            return cell
        }
    }
    
}
