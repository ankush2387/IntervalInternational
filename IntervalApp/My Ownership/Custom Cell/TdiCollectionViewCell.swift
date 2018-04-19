//
//  TdiCollectionViewCell.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 05/04/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class TdiCollectionViewCell: UICollectionViewCell {
    public var identifier = "TDIHeaderCell"
    public var infoIconTapped: CallBack?
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var checkBoxView: IUIKCheckbox!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var lineImage: UIView!
    @IBOutlet weak var horizontalLineImage: UIView!
    
    @IBAction private func infoButtonPressed(_sender: UIButton) {
        infoIconTapped?()
    }

}
