//
//  ResortDirectoryResortCell.swift
//  IntervalApp
//
//  Created by Chetu on 10/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK

//***** custom delegate method declaration *****//
protocol ResortDirectoryResortCellDelegate {
    func favoritesButtonSelectedAtIndex(_ index:Int)
}


class ResortDirectoryResortCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var fevoriteButton: IUIKButton!
    @IBOutlet weak var resortNameGradientView: UIView!
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortAddress: UILabel!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var resortCollectionView: UICollectionView!
    @IBOutlet weak var tierImageView: UIImageView!
    @IBOutlet weak var searchVacationButton: IUIKButton?
   
    //***** class variables *****//
     var delegate: ResortDirectoryResortCellDelegate?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if(resortCollectionView != nil) {
            
            resortCollectionView.delegate = self
            resortCollectionView.dataSource = self
            resortCollectionView.isPagingEnabled = true
        }
        
        if(fevoriteButton != nil){
            self.bringSubview(toFront: fevoriteButton)
        }

    }

    func getCell(){
        setPropertiesTocellComponenet()
    }
    //MARK:set properties to cell component
    /**
     Apply Properties to cell components
     - parameter No parameter:
     - returns : No return value
     */
    fileprivate func setPropertiesTocellComponenet(){
        Helper.addLinearGradientToView(view: resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
    }
//***** custom cell favorites button action implementation *****//
    @IBAction func favirotesButtonPressed(_ sender: AnyObject) {
        
        if(fevoriteButton.isSelected == false) {
        
            if(UserContext.sharedInstance.accessToken == nil ) {
               self.delegate?.favoritesButtonSelectedAtIndex(sender.tag)
            }
            else {
                
                fevoriteButton.isSelected = true
            }
        }
        else {
            fevoriteButton.isSelected = false
        }
    }
//***** method called when the added notification reloadFavoritesTab fired from other classes *****//
    func loginNotification() {
        
        if(self.fevoriteButton != nil) {
            
            self.fevoriteButton.isSelected = true
        }
    }
}

//***** collectionview delegate methods for collection view actons *****//
extension ResortDirectoryResortCell:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        }
}

//***** collectionview datasource methods for reloading  collection view  *****//
extension ResortDirectoryResortCell:UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.imagesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.whereToGoTableViewCell, for: indexPath) as! ResortCollectionViewCell
		
        if((indexPath as NSIndexPath).row % 2 == 0){
            cell.backgroundColor = UIColor.green
        }
		if(Constant.MyClassConstants.imagesArray.count > 0){
			cell.imgView.setImageWith(URL(string: Constant.MyClassConstants.imagesArray[(indexPath as NSIndexPath).row] as! String), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
				if (error != nil) {
					cell.imgView.image = UIImage(named: Constant.MyClassConstants.noImage)
				}
				}, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		}
        cell.pageControl.currentPage = (indexPath as NSIndexPath).row
        cell.delegate = self
        return cell
    }
}


//***** collectionview layout delegate methods for creating collecton view cell items *****//
extension ResortDirectoryResortCell:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if(Constant.RunningDevice.deviceIdiom == .pad){
			return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.height)
		}else{
			return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.height)
		}
	}
}

//***** custom cell delegate methods implementation *****//
extension ResortDirectoryResortCell:ResortCollectionViewCellDelegate{
    func favoritesButtonSelectedAtIndex(_ index:Int){
        self.delegate?.favoritesButtonSelectedAtIndex(index)
    }
}

