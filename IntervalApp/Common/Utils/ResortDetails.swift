//
//  ResortDetails.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

//***** custom delegate method declaration *****//

protocol ResortDetailsDelegate {
    func tableViewSelected(_ index: Int)
}

class ResortDetails: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: ResortDetailsDelegate?
    var unfavHandler: (Int) -> Void = { _ in }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 252
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.favoritesResortArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let resortDetails = Constant.MyClassConstants.favoritesResortArray[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath) as? SearchResultContentTableCell else { return UITableViewCell() }
        guard let sublayers = cell.resortNameGradientView.layer.sublayers else { return UITableViewCell() }
        for layer in sublayers {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
        let frame = CGRect(x: 0, y: 0, width: cell.frame.size.width + 300, height: cell.resortNameGradientView.frame.size.height)
        cell.resortNameGradientView.frame = frame
        Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        cell.backgroundColor = IUIKColorPalette.contentBackground.color
        cell.favoriteButton.isSelected = true
        cell.favoriteButton.tag = indexPath.row
        for imgStr in resortDetails.images where imgStr.size == Constant.MyClassConstants.imageSize {
            if let url = imgStr.url {
                let url = URL(string: url)
                cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }
        }
        cell.resortName.text = resortDetails.resortName
        if let address = resortDetails.address {
            cell.resortCountry.text = address.postalAddresAsString()
        }
        cell.resortCode.text = resortDetails.resortCode
        if let tier = resortDetails.tier {
            let tierImageName = Helper.getTierImageName(tier: tier.uppercased())
            cell.tierImageView.image = UIImage(named: tierImageName)
            cell.tierImageView.isHidden = false
        } else {
            cell.tierImageView.isHidden = true
        }
        cell.allIncImageView.image = #imageLiteral(resourceName: "Resort_All_Inclusive")
        cell.allIncImageView.isHidden = !resortDetails.allInclusive
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 5 || tableView.tag == 6 {
            if Constant.MyClassConstants.systemAccessToken != nil {
                delegate?.tableViewSelected(indexPath.row)
            }
        }
    }
}
extension ResortDetails: SearchResultContentTableCellDelegate {
    func favoriteButtonClicked(_ sender: UIButton) {
        
        let validIndex = 0..<Constant.MyClassConstants.favoritesResortArray.count ~= sender.tag
        let rowNumber = validIndex ? sender.tag : 0
        if sender.isSelected == false {
            
            UserClient.addFavoriteResort(Session.sharedSession.userAccessToken,
                                         resortCode: Constant.MyClassConstants.resortsArray[rowNumber].resortCode.unwrappedString,
                                         onSuccess: {(response) in
                
                intervalPrint(response)
                sender.isSelected = true
                
            }, onError: {(error) in
                intervalPrint(error)
            })
        } else {
            sender.isSelected = false
            intervalPrint()
            unfavHandler(rowNumber)
        }
    }
}
