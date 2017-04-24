//
//  TdiTableViewCell.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 05/04/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class TdiTableViewCell: UITableViewCell {

    @IBOutlet weak var tdicollectionview: UICollectionView!
    
    @IBOutlet weak var unitsizecollectionview: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//extension ClubPointPageItemViewController:UICollectionViewDataSource{
//        
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return 1
//        }
//        
//        
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            
//            
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TdiCollectionViewCell", for: indexPath)as! TdiCollectionViewCell
//            
//            return cell
//        }
//
//        
//    }
    
    
}
