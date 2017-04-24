//
//  ImageWithNameCell.swift
//  IntervalApp
//
//  Created by Chetu on 20/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

protocol ImageWithNameCellDelegate {
    
    func favratePressedAtIndex(_ Index:Int)
    
}


class ImageWithNameCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var resotImageView: UIImageView!
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortLocation: UILabel!
    @IBOutlet weak var resortNameLabel: UILabel!
    @IBOutlet weak var fevrateButton: UIButton!
    @IBOutlet weak var bottomViewForResortName: UIView!
    @IBOutlet weak var tierImageView: UIImageView!
     var delegate:ImageWithNameCellDelegate?
    @IBAction func fevrateButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.favratePressedAtIndex(sender.tag)
    }
    
}
