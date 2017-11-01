//
//  WereWantToGoTableViewCell.swift
//  IntervalApp
//
//  Created by Chetu on 26/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import RealmSwift
import IntervalUIKit
import DarwinSDK


protocol WereWantToGoTableViewCellDelegate{
    
    func multipleResortInfoButtonPressedAtIndex(_ Index:Int)
    
}


class WereWantToGoTableViewCell: UITableViewCell {
    
    var delegate:WereWantToGoTableViewCellDelegate?
    var selectedIndex:Int = -1
    
    @IBOutlet weak var btnAddDestination: UIButton!
    @IBOutlet weak var lblCellTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if(collectionView != nil) {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


extension WereWantToGoTableViewCell:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if((indexPath as NSIndexPath).row == selectedIndex) {
            
            selectedIndex = -1
            collectionView.reloadData()
        }
        else {
            
            self.selectedIndex = (indexPath as NSIndexPath).row
            collectionView.reloadData()
        }
    }
    
}
extension WereWantToGoTableViewCell:UICollectionViewDataSource {
    
    // collection view delegate and data sorce
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.whereTogoContentArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.destinationReusableCell, for: indexPath) as! WhereToGoCollectionViewCell
        
        if((indexPath as NSIndexPath).row == selectedIndex ) {
            let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as AnyObject
            if (object.isKind(of: List<ResortByMap>.self)){
                
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = false
            }
            else {
                
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = true
            }
            
        }
        else {
            
            if(cell.subviews.count > 1){
            cell.deletebutton.isHidden = true
            cell.infobutton.isHidden = true
            }
        }
        
        let obj = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as AnyObject
        if (obj.isKind(of: List<ResortByMap>.self)){
            
            let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as! List<ResortByMap>
            
            let resort = object[0]
            
            
            var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
            if(object.count > 1){
                resortNameString = resortNameString + " and \(object.count - 1) more"
            }
                if(cell.lblTitle != nil){
                cell.lblTitle.text = resortNameString
                if((indexPath as NSIndexPath).row != selectedIndex){
                cell.deletebutton.isHidden = true
                cell.infobutton.isHidden = true
                }
            }
        }
            
        else {
            
            let resortNameWithCode = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as! String
            
            if(cell.lblTitle != nil){
            cell.lblTitle.text = resortNameWithCode
            }
        }
        
        if(cell.subviews.count > 1){
        cell.deletebutton.tag = (indexPath as NSIndexPath).row
        cell.infobutton.tag = (indexPath as NSIndexPath).row
        }
        cell.delegate = self
        cell.layer.borderWidth = 2
        cell.layer.borderColor = IUIKColorPalette.border.color.cgColor
        cell.layer.cornerRadius = 5
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
}

extension WereWantToGoTableViewCell:WhereToGoCollectionViewCellDelegate {
    
    func deleteButtonClickedAtIndex(_ Index: Int) {
        let storedData = Helper.getLocalStorageWherewanttoGo()
        if(storedData.count > 0) {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(storedData[Index])
            }
            
        }
        if(Constant.MyClassConstants.whereTogoContentArray.count > 0) {
            intervalPrint( Constant.MyClassConstants.whereTogoContentArray)
            Constant.MyClassConstants.whereTogoContentArray.removeObject(at: Index)
            intervalPrint( Constant.MyClassConstants.whereTogoContentArray)
            selectedIndex = -1
        }
        if(Constant.MyClassConstants.realmStoredDestIdOrCodeArray.count > 0){
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: Index)
        }
        let allDest = Helper.getLocalStorageAllDest()
        if (allDest.count > 0){
        Helper.deleteObjectFromAllDest()
        }
        let deletionIndexPath = IndexPath(item: Index, section: 0)
        self.collectionView.deleteItems(at: [deletionIndexPath])
        
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        
        self.delegate?.multipleResortInfoButtonPressedAtIndex(Index)
    }
}

