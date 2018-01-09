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
    func favoritesButtonSelectedAtIndex(_ index: Int)
}

class ResortDirectoryResortCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var favoriteButton: IUIKButton!
    @IBOutlet weak var resortNameGradientView: UIView!
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortAddress: UILabel!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var resortCollectionView: UICollectionView!
    @IBOutlet weak var tierImageView: UIImageView!
    @IBOutlet weak var searchVacationButton: IUIKButton?
    @IBOutlet weak var showResortLocationButton: UIButton?
    @IBOutlet weak var showResortWeatherbutton: UIButton?
    //***** class variables *****//
     var delegate: ResortDirectoryResortCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if case .some = resortCollectionView {
            
            resortCollectionView.delegate = self
            resortCollectionView.dataSource = self
            resortCollectionView.isPagingEnabled = true
        }
        
        if case .some = favoriteButton {
            self.bringSubview(toFront: favoriteButton)
        }
    }

    func getCell(resortDetails: Resort) {
        setPropertiesTocellComponenet(resort: resortDetails)
    }
    
    // MARK: set properties to cell component
    /**
     Apply Properties to cell components
     - parameter No parameter:
     - returns : No return value
     */
    fileprivate func setPropertiesTocellComponenet(resort: Resort) {
        Helper.addLinearGradientToView(view: resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
        if let name = resort.resortName {
            resortName.text = name
        }
        resortAddress.text = resort.address?.cityName
        if let code = resort.resortCode {
            resortCode.text = code
        }
    }

//***** method called when the added notification reloadFavoritesTab fired from other classes *****//
    func loginNotification() {
        
        if self.favoriteButton != nil {
            
            self.favoriteButton.isSelected = true
        }
    }
    
    @IBAction func favoriteButtonPressed(_ sender: IUIKButton) {
        
        if favoriteButton.isSelected == false {
            
            if Session.sharedSession.userAccessToken == nil {
                self.delegate?.favoritesButtonSelectedAtIndex(sender.tag)
            } else {
                
            }
        } else {
            
            //favoriteButton.isSelected = false
        }
    }
}

//***** collectionview delegate methods for collection view actons *****//
extension ResortDirectoryResortCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        }
}

//***** collectionview datasource methods for reloading  collection view  *****//
extension ResortDirectoryResortCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.imagesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.whereToGoTableViewCell, for: indexPath) as? ResortCollectionViewCell else { return UICollectionViewCell() }
		if !Constant.MyClassConstants.imagesArray.isEmpty {
			cell.imgView.setImageWith(URL(string: Constant.MyClassConstants.imagesArray[indexPath.row]), completed: { (image:UIImage?, error:Error?, _:SDImageCacheType, _:URL?) in
                if case .some = error {
					cell.imgView.image = #imageLiteral(resourceName: "NoImageIcon")
				}
				}, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		}
        cell.pageControl.currentPage = indexPath.row
        cell.delegate = self
        return cell
    }
}

//***** collectionview layout delegate methods for creating collecton view cell items *****//
extension ResortDirectoryResortCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if Constant.RunningDevice.deviceIdiom == .pad {
			return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.height)
		} else {
			return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.height)
		}
	}
}

//***** custom cell delegate methods implementation *****//
extension ResortDirectoryResortCell: ResortCollectionViewCellDelegate {
    func favoritesButtonSelectedAtIndex(_ index: Int) {
        self.delegate?.favoritesButtonSelectedAtIndex(index)
    }
}
