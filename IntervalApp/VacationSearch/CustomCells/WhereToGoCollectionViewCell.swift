//
//  WhereToGoCollectionViewCell.swift
//  IntervalApp
//
//  Created by Chetu on 26/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

//***** custum delegate method declaration *****//
protocol WhereToGoCollectionViewCellDelegate{
    
    func deleteButtonClickedAtIndex(_ Index:Int)
    func infoButtonClickedAtIndex(_ Index:Int)

}


class WhereToGoCollectionViewCell: UICollectionViewCell {
    
    var delegate:WhereToGoCollectionViewCellDelegate?
    
    @IBOutlet weak var viewBaseView: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var bedroomNumber: UILabel!
    
    @IBOutlet weak var tradeDeleteButton: IUIKButton!
   
    @IBOutlet weak var infobutton: UIButton!
    
    @IBOutlet weak var deletebutton: IUIKButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.deleteButtonClickedAtIndex(sender.tag)
    }
    
    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.infoButtonClickedAtIndex(sender.tag)
    }
}
