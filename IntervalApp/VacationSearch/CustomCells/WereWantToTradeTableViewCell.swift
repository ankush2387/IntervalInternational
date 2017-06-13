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
    
    
    var SegmentIndex = 0
    
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
        
//        switch(section) {
//            
//        case 0:
//            return Constant.MyClassConstants.whereTogoContentArray.count + 1
//            
//        case 1:
//            if(self.SegmentIndex != 1) {
//                return Constant.MyClassConstants.whatToTradeArray.count + 1
//            }
//            else {
//                
//                return 1
//            }
//        default:
//            return 1
//        }
        
        
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
                    
                    _ = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).weekNumber))
                    print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isLockOff)
                    if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isLockOff || (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isFloat){
                        cell.bedroomNumber.isHidden = false
                        
                        let resortList = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).unitDetails
                        print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName, resortList.count)
                        if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isFloat){
                            let floatDetails = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).floatDetails
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                        }else{
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                    }else{
                        cell.bedroomNumber.isHidden = true
                    }
                    cell.lblTitle.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName), \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).relinquishmentYear)"
                    
                    
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
        var isFloat = true
        let storedData = Helper.getLocalStorageWherewanttoTrade()

        if(storedData.count > 0) {
            let realm = try! Realm()
            try! realm.write {
                var floatWeek = OpenWeeks()
                for openWk in Constant.MyClassConstants.whatToTradeArray{
                    let openWk1 = openWk as! OpenWeeks
                    if(!openWk1.isFloatRemoved){
                        floatWeek = openWk1
                    }else{
                        isFloat = false
                    }
                }
                
                realm.delete(storedData[Index])
                
                if(Constant.MyClassConstants.whatToTradeArray.count > 0){
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event43, data: nil)
                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                    Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: Index)
                    Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: Index)
                }
                
               
                let deletionIndexPath = IndexPath(item: Index, section: 0)
                self.collectionView.deleteItems(at: [deletionIndexPath])
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    
                   
                    
                    if(!floatWeek.isFloatRemoved && isFloat){
                        //Realm local storage for selected relinquishment
                        let storedata = OpenWeeksStorage()
                        let Membership = UserContext.sharedInstance.selectedMembership
                        let relinquishmentList = TradeLocalData()
                        
                        let selectedOpenWeek = OpenWeeks()
                        selectedOpenWeek.isFloat = true
                        selectedOpenWeek.isFloatRemoved = true
                        selectedOpenWeek.isFromRelinquishment = false
                        selectedOpenWeek.weekNumber = ""
                        selectedOpenWeek.relinquishmentID = floatWeek.relinquishmentID
                        selectedOpenWeek.relinquishmentYear = floatWeek.relinquishmentYear
                        let resort = ResortList()
                        resort.resortName = (floatWeek.resort[0].resortName)
                        
                        let floatDetails = ResortFloatDetails()
                        floatDetails.reservationNumber = ""
                        floatDetails.unitNumber = floatWeek.floatDetails[0].unitNumber
                        floatDetails.unitSize = floatWeek.floatDetails[0].unitSize
                        selectedOpenWeek.floatDetails.append(floatDetails)
                        
                        let unitDetails = ResortUnitDetails()
                        // unitDetails.kitchenType = (Helper.getKitchenEnums(kitchenType: (floatWeek.resort[0].units.kitchenType!)))
                        //unitDetails.unitSize = floatWeek.resort[0].units.unitNumber!
                        selectedOpenWeek.unitDetails.append(unitDetails)
                        
                        selectedOpenWeek.resort.append(resort)
                        relinquishmentList.openWeeks.append(selectedOpenWeek)
                        storedata.openWeeks.append(relinquishmentList)
                        storedata.membeshipNumber = Membership!.memberNumber!
                        Constant.MyClassConstants.floatRemovedArray.removeAllObjects()
                        Constant.MyClassConstants.floatRemovedArray.add(floatWeek)
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(storedata)
                        }
                    }
                    
                }
            }
            
        }

        
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        
        self.delegate?.multipleResortInfoButtonPressedAtIndex(Index)
    }
}


