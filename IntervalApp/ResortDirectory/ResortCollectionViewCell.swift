//
//  ResortCollectionViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/29/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

//***** custom delegate method declaration *****//
protocol ResortCollectionViewCellDelegate {
    
    func favoritesButtonSelectedAtIndex(_ index: Int)
}

class ResortCollectionViewCell: UICollectionViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
     //***** class variables *****//
    var delegate: ResortCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
          NotificationCenter.default.addObserver(self, selector: #selector(loginNotification), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
    }
    
     //***** custom cell favorites button action implementation *****//
    @IBAction func favirotesButtonPressed(_ sender: AnyObject) {
        
        if(favoriteButton.isSelected == false) {
            
            if(Session.sharedSession.userAccessToken == nil) {
                self.delegate?.favoritesButtonSelectedAtIndex(sender.tag)
            } else {
               
            }
        } else {
            
          favoriteButton.isSelected = false
        }
    }
//***** method called when the added notification reloadFavoritesTab fired from other classes *****//
    func loginNotification() {
        if(self.favoriteButton != nil) {
         self.favoriteButton.isSelected = true
        }
    }
}
