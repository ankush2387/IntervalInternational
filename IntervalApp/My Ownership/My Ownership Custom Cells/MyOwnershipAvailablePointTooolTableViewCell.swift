//
//  MyOwnershipAvailablePointTooolTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class MyOwnershipAvailablePointTooolTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var clubIntervalImageView: UIImageView!
    
    @IBOutlet weak var availablePointsToolbutton: UIButton!
    
    @IBOutlet weak var availablePointToolMainView: UIView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK:get cell
    /**
     Configure Cell components
     - parameter No parameter :
     - returns : No return value
     */
    func getCell(){
        self.setPropertiesToCellElements()
        self.updateCellComponentstext()
    }
    //MARK:set properties to elements of cell
    /**
     Apply properties to cell components
     - parameter No parameter :
     - returns : No return value
     */
    fileprivate func setPropertiesToCellElements(){
        availablePointsToolbutton.setTitleColor(UIColor(rgb: IUIKColorPalette.primary1.rawValue), for: .normal)
        Helper.applyCornerRadious(view: availablePointToolMainView, cornerradious: Constant.viewProperties.cornerRadious)
        Helper.applyBorderarroundView(view: availablePointsToolbutton, bordercolor: UIColor(rgb: IUIKColorPalette.border.rawValue), borderwidth: 1, cornerradious: 8)
        Helper.applyShadowOnUIView(view: availablePointToolMainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
        
    }
    /**
     Update cell Componetns text or title
     - parameter No parameter:
     - returns : No value is return
     */
    fileprivate func updateCellComponentstext(){
        availablePointsToolbutton.setTitle(Constant.ownershipViewController.clubIntervalGoldPointTableViewCell.availablePointsToolbuttonTitle, for: UIControlState())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
