//
//  WereWantToTradeTableViewCell.swift
//  IntervalApp
//
//  Created by Chetu on 26/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import RealmSwift
import DarwinSDK

protocol WereWantToTradeTableViewCellDelegate{
    
    func multipleResortInfoButtonPressedAtIndex(_ Index:Int)
    
}

class WereWantToTradeTableViewCell: UITableViewCell {
    
    var delegate:WereWantToTradeTableViewCellDelegate?
    var selectedIndex = -1
    
    @IBOutlet weak var btnAddItemToTrade: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblCellTitle: UILabel!
  
    @IBOutlet weak var deleteButton: IUIKButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // collection view delegate and data sorce
    }

extension WereWantToTradeTableViewCell:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == self.selectedIndex) {
            
            self.selectedIndex = -1
            collectionView.reloadData()
        }
        else {
            
            self.selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
}

extension WereWantToTradeTableViewCell:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.whatToTradeArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.wereToGoTableViewCell, for: indexPath) as! WhereToGoCollectionViewCell
        
            if(cell.lblTitle != nil){
                
                
                
                    let object = Constant.MyClassConstants.whatToTradeArray[indexPath.row]
                    if((object as AnyObject) .isKind(of: OpenWeek.self)){
                        
                        let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeek).weekNumber)!)
                        cell.lblTitle.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeek).resort!.resortName!), \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeek).relinquishmentYear!) Week \(weekNumber)"
                        

                    }
                    else if((object as AnyObject).isKind(of: OpenWeeks.self)) {
                        
                        let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).weekNumber))
                        cell.lblTitle.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName), \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).relinquishmentYear) Week \(weekNumber)"
                        
                        if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isLockOff){
                            cell.bedroomNumber.isHidden = false
                            
                            let resortList = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).unitDetails
                            print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName, resortList.count)
                            cell.bedroomNumber.text = resortList[0].unitSize
                        }
                        
                        
                    }
                    else {
                        
                        let availablePointsNumber = Constant.MyClassConstants.relinquishmentAvailablePointsProgram as NSNumber
                        
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        
                        let availablePoints = numberFormatter.string(from: availablePointsNumber)
                         cell.lblTitle.text = "Club Interval Gold Points up to \(availablePoints!)"
                    }
                    
        }
        if( self.selectedIndex == indexPath.row) {
            
            cell.deletebutton.isHidden = false
            
        }
        else {
            cell.deletebutton.isHidden = true
           
        }
        if(cell.subviews.count > 1){
            cell.deletebutton.tag = indexPath.row
        }
                cell.delegate = self
                cell.layer.borderWidth = 2
                cell.layer.borderColor = IUIKColorPalette.border.color.cgColor
                cell.layer.cornerRadius = 5
                cell.updateConstraintsIfNeeded()
                return cell
        
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width/3 , height: collectionView.frame.height - 25)
//    }

}

extension WereWantToTradeTableViewCell:WhereToGoCollectionViewCellDelegate {
    
    func deleteButtonClickedAtIndex(_ Index: Int) {
        print(Index)
        let storedData = Helper.getLocalStorageWherewanttoTrade()
        if(Constant.MyClassConstants.whatToTradeArray.count > 0){
            
            
            
            Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
            Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: Index)
            Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: Index )
        }

        if(storedData.count > 0) {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(storedData[Index])
            }
            
        }
        let deletionIndexPath = IndexPath(item: Index, section: 0)
        self.collectionView.deleteItems(at: [deletionIndexPath])
        
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        
        self.delegate?.multipleResortInfoButtonPressedAtIndex(Index)
    }
}


