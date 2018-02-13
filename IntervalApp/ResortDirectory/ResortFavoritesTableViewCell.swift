//
//  ResortFavoritesTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 7/2/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

//***** Custom delegate method declaration *****//
protocol ResortFavoritesTableViewCellDelegate : class {
    
    func favoritesResortSelectedAtIndex(_ index: Int, signInRequired: Bool, isFavorite: Bool)
    func showResortDetails(_ index: Int)
}

class ResortFavoritesTableViewCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var backgroundNameView: UIView!
    @IBOutlet weak var resortAreaName: UILabel!
    @IBOutlet weak var resortDescription: UILabel!
    @IBOutlet weak var imageViewTop: UIImageView!
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    //***** Class variables *****//
    weak var delegate: ResortFavoritesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if(favoritesCollectionView != nil) {
            
            favoritesCollectionView.delegate = self
            favoritesCollectionView.dataSource = self
            favoritesCollectionView.isScrollEnabled = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//***** Extension class to define collection view flow layout delegate methods *****//
extension ResortFavoritesTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(Constant.RunningDevice.deviceOrientation == UIDeviceOrientation.landscapeLeft) {
            
            return CGSize(width: (collectionView.frame.size.width - 10) / 2, height: (collectionView.frame.size.width - 10) / 2)
            
        } else {
            return CGSize(width: (collectionView.frame.size.width - 10) / 2, height: (collectionView.frame.size.width - 10) / 2)
        }
        
    }
    
}

//***** Extension class to define collection view delegate methods *****//
extension ResortFavoritesTableViewCell: UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.showResortDetails((indexPath as NSIndexPath).item)
    }
    
}

//***** Extension class to define collection view  data source methods *****//
extension ResortFavoritesTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.resortDirectoryResortArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let resort = Constant.MyClassConstants.resortDirectoryResortArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.resortDetailCell, for: indexPath) as! ResortDirectoryCollectionViewCell
        if !resort.images.isEmpty {
            
            if let stringUrl = resort.images[2].url {
                let url = URL(string: stringUrl)
                cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }
        }
        
        for layer in cell.resortNameGradientView.layer.sublayers! {
            
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
        let frame = CGRect(x: 0, y: (collectionView.frame.size.width - 10) / 2 - 80, width: (collectionView.frame.size.width - 10) / 2, height: 80)
        cell.resortNameGradientView.frame = frame
        Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        cell.backgroundColor = IUIKColorPalette.contentBackground.color
        cell.favoriteButton.tag = indexPath.row
        if let resortCode = resort.resortCode {
            let status = Helper.isResrotFavorite(resortCode: resortCode)
            status ? (cell.favoriteButton.isSelected = true) :  (cell.favoriteButton.isSelected = false)
        }
        if Constant.MyClassConstants.btnTag == indexPath.row {
            cell.favoriteButton.isSelected = true
        }
        cell.regionNameLabel.text = resort.resortName
        cell.regionResortCode.text = resort.resortCode
        let tierImage = Helper.getTierImageName(tier: resort.tier!.uppercased())
        if resort.tier != nil && cell.tierImageView != nil {
            cell.tierImageView.image = UIImage(named: tierImage)
        } else {
            cell.tierImageView.isHidden = true
        }
        if let city = resort.address?.cityName {
            cell.regionAreaLabel.text = "\(city)"
        }
        cell.delegate = self
        cell.backgroundColor = IUIKColorPalette.contentBackground.color
        
        return cell
    }
}

/***** Extension for ResortDirectoryCollectionViewCellDelegate for favorite and unfavorite *****/
extension ResortFavoritesTableViewCell: ResortDirectoryCollectionViewCellDelegate {
    func favoriteCollectionButtonClicked(_ sender: UIButton) {
        
        Constant.MyClassConstants.btnTag = sender.tag
        if Session.sharedSession.userAccessToken != nil && Constant.MyClassConstants.isLoginSuccessfull {
            self.delegate?.favoritesResortSelectedAtIndex(sender.tag, signInRequired: false, isFavorite: false)
        } else {
            self.delegate?.favoritesResortSelectedAtIndex(sender.tag, signInRequired: true, isFavorite: false)
        }
    }
    func unfavoriteCollectionButtonClicked(_ sender: UIButton) {
        
        Constant.MyClassConstants.btnTag = sender.tag
        if Session.sharedSession.userAccessToken != nil && Constant.MyClassConstants.isLoginSuccessfull {
            self.delegate?.favoritesResortSelectedAtIndex(sender.tag, signInRequired: false, isFavorite: true)
        } else {
            self.delegate?.favoritesResortSelectedAtIndex(sender.tag, signInRequired: true, isFavorite: true)
        }
    }
    
}
