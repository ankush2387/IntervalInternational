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
                    
                    
                } else if ((object as AnyObject).isKind(of: Deposits.self)) {
                    _ = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).weekNumber))
                    print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isLockOff)
                    if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isLockOff || (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isFloat){
                        cell.bedroomNumber.isHidden = false
                        
                        let resortList = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).unitDetails
                        print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).resort[0].resortName, resortList.count)
                        if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isFloat){
                            let floatDetails = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).floatDetails
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                        }else{
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                    }else{
                        cell.bedroomNumber.isHidden = true
                    }
                    cell.lblTitle.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).resort[0].resortName), \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).relinquishmentYear)"
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

        let storedData = Helper.getLocalStorageWherewanttoTrade()
        
        if(storedData.count > 0) {
            
            
            let realm = try! Realm()
            try! realm.write {

                
                if((Constant.MyClassConstants.whatToTradeArray[Index] as AnyObject).isKind(of: OpenWeeks.self)){
                    
                    var floatWeekIndex = -1
                    let dataSelected = Constant.MyClassConstants.whatToTradeArray[Index] as! OpenWeeks
                    if(dataSelected.isFloat){
                        
                        
                        for (index,object) in storedData.enumerated(){
                            let openWk1 = object.openWeeks[0].openWeeks[0]
                            if(openWk1.relinquishmentID == dataSelected.relinquishmentID){
                                floatWeekIndex = index
                            }
                        }
                    
                
                //TODO - Jhon : once code is updated, review is this variables are neeeded, if not delete.
                var isFloatRemoved: Bool?
                var isFloat: Bool?
                var relinquishmentId: String?
                var relinquismentYear: Int?
                var resortName: String?
                var unitNumber: String?
                var unitSize: String?
                
                for openWk in Constant.MyClassConstants.whatToTradeArray{
                    if ((openWk as AnyObject).isKind(of: OpenWeeks.self)){
                        var floatWeek = OpenWeeks()
                        let openWk1 = openWk as! OpenWeeks
                        if(!openWk1.isFloatRemoved){
                            floatWeek = openWk1
                            isFloatRemoved = floatWeek.isFloatRemoved
                            relinquishmentId = floatWeek.relinquishmentID
                            relinquismentYear = floatWeek.relinquishmentYear
                            resortName = floatWeek.resort[0].resortName
                            if floatWeek.floatDetails.count > 0 {
                                unitNumber = floatWeek.floatDetails[0].unitNumber
                                unitSize = floatWeek.floatDetails[0].unitSize
                            }
                            Constant.MyClassConstants.floatRemovedArray.removeAllObjects()
                            Constant.MyClassConstants.floatRemovedArray.add(floatWeek)
                        }else{
                            isFloat = false
                        }
                        
                        
                    } else if ((openWk as AnyObject).isKind(of: Deposits.self)) {
                        var floatWeek = Deposits()
                        let deposit = openWk as! Deposits
                        if(!deposit.isFloatRemoved){
                            floatWeek = deposit
                            isFloatRemoved = floatWeek.isFloatRemoved
                            relinquishmentId = floatWeek.relinquishmentID
                            relinquismentYear = floatWeek.relinquishmentYear
                            resortName = floatWeek.resort[0].resortName
                            if floatWeek.floatDetails.count > 0 {
                                unitNumber = floatWeek.floatDetails[0].unitNumber
                                unitSize = floatWeek.floatDetails[0].unitSize
                            }
                            Constant.MyClassConstants.floatRemovedArray.removeAllObjects()
                            Constant.MyClassConstants.floatRemovedArray.add(floatWeek)
                        
                        }else{
                            isFloat = false
                        }
                        
                    }
                    
                    
                }
                //delete from local Storage
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
                    
                   
                    
                    if(!isFloatRemoved! && isFloat!){
                        //Realm local storage for selected relinquishment
                        let storedata = OpenWeeksStorage()
                        let Membership = UserContext.sharedInstance.selectedMembership
                        let relinquishmentList = TradeLocalData()
                        
                        let selectedOpenWeek = OpenWeeks()
                        selectedOpenWeek.isFloat = true
                        selectedOpenWeek.isFloatRemoved = true
                        selectedOpenWeek.isFromRelinquishment = false
                        selectedOpenWeek.weekNumber = ""
                        selectedOpenWeek.relinquishmentID = relinquishmentId!
                        selectedOpenWeek.relinquishmentYear = relinquismentYear!
                        let resort = ResortList()
                        resort.resortName = (resortName!)
                        
                        let floatDetails = ResortFloatDetails()
                        floatDetails.reservationNumber = ""
                        floatDetails.unitNumber = unitNumber!
                        floatDetails.unitSize = unitSize!
                        selectedOpenWeek.floatDetails.append(floatDetails)

                        
                        storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloatRemoved = true
                        storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloat = true
                        storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFromRelinquishment = false

                        if(Constant.MyClassConstants.whatToTradeArray.count > 0){
                            
                            ADBMobile.trackAction(Constant.omnitureEvents.event43, data: nil)
                            Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                            Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: Index)
                            Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: Index)

                        selectedOpenWeek.resort.append(resort)
                        relinquishmentList.openWeeks.append(selectedOpenWeek)
                        storedata.openWeeks.append(relinquishmentList)
                        storedata.membeshipNumber = Membership!.memberNumber!
//                        Constant.MyClassConstants.floatRemovedArray.removeAllObjects()
//                        Constant.MyClassConstants.floatRemovedArray.add(floatWeek)
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(storedata)

                        }
                    }else{
                        Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                        Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: Index)
                        realm.delete(storedData[Index])
                    }

                }else{
                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                    Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: Index)
                    realm.delete(storedData[Index])

                

                }
                
                let deletionIndexPath = IndexPath(item: Index, section: 0)
                self.collectionView.deleteItems(at: [deletionIndexPath])
                Helper.InitializeOpenWeeksFromLocalStorage()
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


