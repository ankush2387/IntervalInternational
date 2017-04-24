//
//  VacationOrResortTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class VacationOrResortTableViewCell: UITableViewCell {

    @IBOutlet weak var vacationNameLabel: UILabel!
    
    @IBOutlet weak var vacationPlaceLabel: UILabel!
    
    @IBOutlet weak var vacationPlaceCodeLabel: UILabel!
    
    @IBOutlet weak var vacationImageView: UIImageView!
    
    @IBOutlet weak var transparentMainView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    //MARK:get cell
    /**
    Configure Cell components
    - parameter No parameter :
    - returns : No return value
    */
    func getCell(){
        setPropertiesToCellElements()
        updateCellComponetstext()
    }
    //MARK:set properties to elements of cell
    /**
    Apply properties to cell components
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func setPropertiesToCellElements(){
        vacationNameLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        vacationPlaceLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        vacationPlaceCodeLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryB.rawValue)
        removeSublayersFromViewLayer(transparentMainView)
        Helper.addLinearGradientToView(view: transparentMainView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        Helper.applyShadowOnUIView(view: transparentMainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1)
        
    }
    /**
     Update Cell components Text
     - parameter No parameter :
     - returns : No return value
     */
    fileprivate func updateCellComponetstext(){
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    fileprivate func removeSublayersFromViewLayer(_ view:UIView){
        for layer in view.layer.sublayers! {
            if layer.isKind(of: CAGradientLayer.self){
                layer.removeFromSuperlayer()
            }
        }
    }

}
