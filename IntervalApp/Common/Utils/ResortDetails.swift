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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath) as! SearchResultContentTableCell
        
        for layer in cell.resortNameGradientView.layer.sublayers! {
            if(layer.isKind(of: CAGradientLayer.self)) {
                layer.removeFromSuperlayer()
            }
        }
        let frame = CGRect(x: 0, y: 0, width: Constant.MyClassConstants.runningDeviceWidth + 300, height: cell.resortNameGradientView.frame.size.height)
        cell.resortNameGradientView.frame = frame
        Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        cell.backgroundColor = IUIKColorPalette.contentBackground.color
        cell.favoriteButton.isSelected = true
        cell.favoriteButton.tag = (indexPath as NSIndexPath).row
        
        if (resortDetails.images.count > 0) {
            let url = URL(string: Constant.MyClassConstants.favoritesResortArray[indexPath.row].images[Constant.MyClassConstants.favoritesResortArray[indexPath.row].images.count - 1].url!)
            
            cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        } else {
        }
        cell.resortName.text = resortDetails.resortName
        let resortAddress = resortDetails.address!
        cell.resortCountry.text = resortAddress.cityName
        cell.resortCode.text = resortDetails.resortCode
        if let tier = resortDetails.tier {
            let tierImageName = Helper.getTierImageName(tier: tier.uppercased())
            cell.tierImageView.image = UIImage(named: tierImageName)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.tag == 5 || tableView.tag == 6) {
            if(Constant.MyClassConstants.systemAccessToken != nil) {
                
                self.delegate?.tableViewSelected((indexPath as NSIndexPath).row)
            }
        }
    }
}
extension ResortDetails: SearchResultContentTableCellDelegate {
    func favoriteButtonClicked(_ sender: UIButton) {
        
        if (sender.isSelected == false) {
            
            intervalPrint(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
            UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                
                intervalPrint(response)
                sender.isSelected = true
                
            }, onError: {(error) in
                intervalPrint(error)
            })
        } else {
            sender.isSelected = false
            intervalPrint()
            unfavHandler(sender.tag)
        }

    }
    
    func unfavoriteButtonClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.notificationNames.showUnfavorite), object: sender)
    }
}
