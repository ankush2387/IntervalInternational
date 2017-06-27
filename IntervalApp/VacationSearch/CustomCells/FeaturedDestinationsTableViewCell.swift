//
//  FeaturedDestinationsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import SDWebImage

class FeaturedDestinationsTableViewCell: UITableViewCell {
    
    //****** Outlets ******//
    @IBOutlet weak var featuredCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        featuredCollectionView.dataSource = self
        featuredCollectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension FeaturedDestinationsTableViewCell:UICollectionViewDelegate {
}

extension FeaturedDestinationsTableViewCell:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return Constant.MyClassConstants.topDeals.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let deal = Constant.MyClassConstants.topDeals[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.cellIdentifiers.featuredCell, for: indexPath) as! FeaturedDestinationsCell
        cell.titleLabelDestination.text = deal.header
        cell.priceLabelDestination.text = "From " + String(describing: deal.price?.fromPrice) + " Wk."
        cell.unitLabelDestination.text = deal.details
        
        if let imageURL = deal.images.first?.url{
            cell.imageViewDestination.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                if (error != nil) {
                    cell.imageViewDestination.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }
		
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constant.MyClassConstants.runningDeviceWidth!/2 , height: collectionView.frame.height/2 - 0.5)
    }

}
