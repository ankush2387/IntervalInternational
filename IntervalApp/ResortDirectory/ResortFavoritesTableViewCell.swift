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
protocol ResortFavoritesTableViewCellDelegate {
    
    func favoritesResortSelectedAtIndex(_ index:Int)
    func showResortDetails(_ index:Int)
}

class ResortFavoritesTableViewCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var backgroundNameView: UIView!
    @IBOutlet weak var resortAreaName: UILabel!
    @IBOutlet weak var resortDescription: UILabel!
    @IBOutlet weak var imageViewTop: UIImageView!
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    //***** Class variables *****//
    var delegate: ResortFavoritesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if(favoritesCollectionView != nil){
            
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
extension ResortFavoritesTableViewCell:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(Constant.RunningDevice.deviceOrientation == UIDeviceOrientation.landscapeLeft){
            
            return CGSize(width: (collectionView.frame.size.width-10)/2, height: (collectionView.frame.size.width-10)/2)
            
        }else{
            return CGSize(width: (collectionView.frame.size.width-10)/2, height: (collectionView.frame.size.width-10)/2)
        }
        
    }
    
}

//***** Extension class to define collection view delegate methods *****//
extension ResortFavoritesTableViewCell:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.showResortDetails((indexPath as NSIndexPath).item)
    }
    
}

//***** Extension class to define collection view  data source methods *****//
extension ResortFavoritesTableViewCell:UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.resortDirectoryResortArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let resort = Constant.MyClassConstants.resortDirectoryResortArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.resortDetailCell, for: indexPath) as! ResortDirectoryCollectionViewCell
        if(resort.images.count > 0) {
            
            if let stirngUrl = resort.images[0].url {
                let url = URL(string:stirngUrl)
                cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }
        }
        
        for layer in cell.resortNameGradientView.layer.sublayers! {
            
            if(layer.isKind(of: CAGradientLayer.self)) {
                layer.removeFromSuperlayer()
            }
        }
        let frame = CGRect(x: 0, y: (collectionView.frame.size.width-10)/2-80, width: (collectionView.frame.size.width-10)/2, height: 80)
        cell.resortNameGradientView.frame = frame
        
        cell.resortImageView.frame = cell.frame
        
        Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        cell.backgroundColor = IUIKColorPalette.contentBackground.color
        cell.favoriteButton.tag = indexPath.row
        let status = true //Helper.isResrotFavorite(resortCode: resort.resortCode!)
        if(status) {
            cell.favoriteButton.isSelected = true
        }
        else {
            cell.favoriteButton.isSelected = false
        }
        if(Constant.MyClassConstants.btnTag == (indexPath as NSIndexPath).row){
            cell.favoriteButton.isSelected = true
        }
        cell.regionNameLabel.text = resort.resortName
        cell.regionResortCode.text = resort.resortCode
//        let tierImage = Helper.getTierImageName(tier: resort.tier!)
//        if(resort.tier != nil && cell.tierImageView != nil){
//            cell.tierImageView.image = UIImage(named:tierImage)
//        }
        if let city = resort.address?.city {
            
            cell.regionAreaLabel.text = "\(city)"
            
        }
        cell.delegate = self
        cell.backgroundColor = IUIKColorPalette.contentBackground.color
        
        return cell
    }
}


/***** Extension for ResortDirectoryCollectionViewCellDelegate for favorite and unfavorite *****/
extension ResortFavoritesTableViewCell:ResortDirectoryCollectionViewCellDelegate {
    func favoriteCollectionButtonClicked(_ sender:UIButton) {
        
        sender.isSelected = false
        if((UserContext.sharedInstance.accessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {
            
            if (sender.isSelected == false){
                
                print(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                    
                    print(response)
                    sender.isSelected = true
                    
                    
                }, onError: {(error) in
                    
                    print(error)
                })
            }
            else {
                sender.isSelected = false
            }

        }
        else {
            
            Constant.MyClassConstants.btnTag = sender.tag
            self.delegate?.favoritesResortSelectedAtIndex(sender.tag)
        }
    }
    func unfavoriteCollectionButtonClicked(_ sender:UIButton){
        
    }
}
