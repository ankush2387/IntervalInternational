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
                Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName = promotionsArray[indexPath.row].offerName
            } else {
               Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName = promotionsArray[indexPath.row].offerName
            }

        } else {
            Constant.MyClassConstants.isPromotionsEnabled = false
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
               Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName = "No Thanks".localized()
            } else {
                Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName = "No Thanks".localized()
            }
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as? PromotionsCell else { return UITableViewCell() }
            let promotion = promotionsArray[indexPath.row]
            cell.selectionStyle = .none
            cell.promotionTextLabel.text = promotion.offerName

            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                if cell.promotionTextLabel.text == Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName {
                    cell.promotionSelectionCheckBox.checked = true
                } else {
                    cell.promotionSelectionCheckBox.checked = false
                }
            } else {
                if cell.promotionTextLabel.text == Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName {
                    cell.promotionSelectionCheckBox.checked = true
                } else {
                    cell.promotionSelectionCheckBox.checked = false
                }
            }
            
            cell.promotionSelectionCheckBox.isUserInteractionEnabled = false
            cell.promotionSelectionCheckBox.addTarget(self, action: #selector(PromotionsViewController.promotionCellSelected), for: .touchUpInside)
            return cell
        } else {
           guard let cell = promotionsTableView.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as? PromotionsCell else { return UITableViewCell() }
            cell.promotionTextLabel.text = "No Thanks".localized()
            cell.selectionStyle = .none

            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                
                if cell.promotionTextLabel.text == Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName {
                    cell.promotionSelectionCheckBox.checked = true
                } else {
                    cell.promotionSelectionCheckBox.checked = false
                }
                
            } else {
                
                if cell.promotionTextLabel.text == Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName {
                    cell.promotionSelectionCheckBox.checked = true
                } else {
                    cell.promotionSelectionCheckBox.checked = false
                }
            }
            cell.promotionSelectionCheckBox.isUserInteractionEnabled = false
            return cell
        }
    }
    
}
