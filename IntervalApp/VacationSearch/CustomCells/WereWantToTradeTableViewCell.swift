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

protocol WereWantToTradeTableViewCellDelegate {
    
    func multipleResortInfoButtonPressedAtIndex(_ Index: Int)
    
}

class WereWantToTradeTableViewCell: UITableViewCell {
    
    var delegate: WereWantToTradeTableViewCellDelegate?
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // collection view delegate and data sorce
    }

extension WereWantToTradeTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == self.selectedIndex {
            
            self.selectedIndex = -1
            collectionView.reloadData()
        } else {
            
            self.selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
}

extension WereWantToTradeTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.whatToTradeArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wereToGo", for: indexPath) as? WhereToGoCollectionViewCell else { return UICollectionViewCell() }
            
            if cell.lblTitle != nil {
                
                let object = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject
                if object.isKind(of: OpenWeek.self) {
                    guard let openWk = object as? OpenWeek else { return cell }
                    if let resortName = openWk.resort?.resortName {
                        cell.lblTitle.text = "\(resortName)"
                    }
                    if let relinquishmentYear = openWk.relinquishmentYear {
                        cell.lblTitle.text = "\(String(describing: cell.lblTitle.text)), \(relinquishmentYear)"
                    }
                    if let weekNumber = openWk.weekNumber {
                        cell.lblTitle.text = "\(String(describing: cell.lblTitle.text)), Week \(weekNumber)"
                    }
                } else if object.isKind(of: OpenWeeks.self) {
                    guard let openWk = object as? OpenWeeks else { return cell }
                    let weekNumber = Constant.getWeekNumber(weekType: (openWk.weekNumber))
                    if  openWk.isLockOff || openWk.isFloat {
                        cell.bedroomNumber.isHidden = false
                        
                        let resortList = openWk.unitDetails
                        if openWk.isFloat {
                            let floatDetails = openWk.floatDetails
                            if floatDetails[0].showUnitNumber {
                                cell.bedroomNumber.text = "\(floatDetails[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                            } else {
                                cell.bedroomNumber.text = "\(floatDetails[0].unitSize), \(resortList[0].kitchenType)"
                            }
                        } else {
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                    } else {
                        cell.bedroomNumber.isHidden = true
                    }
                    if weekNumber != ""{
                        cell.lblTitle.text = "\(openWk.resort[0].resortName)/ \(openWk.relinquishmentYear), Wk\(weekNumber)"
                    } else {
                        cell.lblTitle.text = "\(openWk.resort[0].resortName)/ \(openWk.relinquishmentYear)"
                    }
                } else if (object as AnyObject).isKind(of: Deposits.self) {
                    guard let deposits = object as? Deposits else { return cell }
                    
                    //Deposits
                    let weekNumber = Constant.getWeekNumber(weekType: (deposits.weekNumber))
                    
                    if deposits.isLockOff || deposits.isFloat {
                        cell.bedroomNumber.isHidden = false
                        
                        let resortList = deposits.unitDetails
                        if deposits.isFloat {
                            let floatDetails = deposits.floatDetails
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                        } else {
                            cell.bedroomNumber.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                    } else {
                        cell.bedroomNumber.isHidden = true
                    }
                    if weekNumber != "" {
                        cell.lblTitle.text = "\(deposits.resort[0].resortName)/ \(deposits.relinquishmentYear), Wk\(weekNumber)"
                    } else {
                        cell.lblTitle.text = "\(deposits.resort[0].resortName)/ \(deposits.relinquishmentYear)"
                    }
                    
                } else if object.isKind(of: List<ClubPoints>.self) {
                    
                    guard let clubPoints = object as? List<ClubPoints> else { return cell }
                    
                    if clubPoints[0].isPointsMatrix == false {
                        let resortNameWithYear = "\(clubPoints[0].resort[0].resortName)/\(clubPoints[0].relinquishmentYear)"
                        cell.lblTitle.text = "\(resortNameWithYear)"
                    } else {
                        let pointsSpent = clubPoints[0].pointsSpent
                        cell.lblTitle.text = "Club Points upto \(String(describing: pointsSpent))"
                    }
                    cell.bedroomNumber.isHidden = true
                    return cell
                } else {
                    
                    let availablePointsNumber = Constant.MyClassConstants.relinquishmentAvailablePointsProgram as NSNumber
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    
                    if let availablePoints = numberFormatter.string(from: availablePointsNumber) {
                        cell.lblTitle.text = "\(Constant.getDynamicString.clubInterValPointsUpTo) \(availablePoints)"
                    }
                    
                    cell.bedroomNumber.isHidden = true
                }
                
            }
            if( self.selectedIndex == indexPath.row) {
                
                cell.deletebutton.isHidden = false
                
            } else {
                cell.deletebutton.isHidden = true
                
            }
            if(cell.subviews.count > 1) {
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

extension WereWantToTradeTableViewCell: WhereToGoCollectionViewCellDelegate {
    
    func deleteButtonClickedAtIndex(_ Index: Int) {

        let storedData = Helper.getLocalStorageWherewanttoTrade()
        
        if storedData.isEmpty == false {
            
            let realm = try! Realm()
            try! realm.write {
                let relinquishment = Constant.MyClassConstants.whatToTradeArray[Index] as AnyObject
                
                if relinquishment.isKind(of: OpenWeeks.self) {
                    
                    var floatWeekIndex = -1
                    guard let dataSelected = relinquishment as? OpenWeeks else { return }
                    if dataSelected.isFloat {
                        for (index, object) in storedData.enumerated() {
                            let openWk1 = object.openWeeks[0].openWeeks[0]
                            if openWk1.relinquishmentID == dataSelected.relinquishmentID {
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
                        
                        for openWk in Constant.MyClassConstants.whatToTradeArray {
                            if ((openWk as AnyObject).isKind(of: OpenWeeks.self)) {
                                var floatWeek = OpenWeeks()
                                let openWk1 = openWk as! OpenWeeks
                                if(!openWk1.isFloatRemoved) {
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
                                } else {
                                    isFloat = false
                                }
                                
                            }
                            
                        }
                        //delete from local Storage
                        realm.delete(storedData[Index])
                        
                        if(Constant.MyClassConstants.whatToTradeArray.count > 0) {
                            
                            ADBMobile.trackAction(Constant.omnitureEvents.event43, data: nil)
                            Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                            Constant.MyClassConstants.relinquishmentIdArray.remove(at: Index)
                            Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: Index)
                        }
                        
                        let deletionIndexPath = IndexPath(item: Index, section: 0)
                        self.collectionView.deleteItems(at: [deletionIndexPath])
                        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            
                            if !isFloatRemoved! && isFloat! {
                                //Realm local storage for selected relinquishment
                                let storedata = OpenWeeksStorage()
                                let Membership = Session.sharedSession.selectedMembership
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
                                
                                if Constant.MyClassConstants.whatToTradeArray.count > 0 {
                                    
                                    ADBMobile.trackAction(Constant.omnitureEvents.event43, data: nil)
                                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                                    Constant.MyClassConstants.relinquishmentIdArray.remove(at: Index)
                                    Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: Index)
                                    
                                    selectedOpenWeek.resort.append(resort)
                                    relinquishmentList.openWeeks.append(selectedOpenWeek)
                                    storedata.openWeeks.append(relinquishmentList)
                                    storedata.membeshipNumber = Membership!.memberNumber!
                                    
                                    let realm = try! Realm()
                                    try! realm.write {
                                        realm.add(storedata)
                                        
                                    }
                                } else {
                                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                                    Constant.MyClassConstants.relinquishmentIdArray.remove(at: Index)
                                    realm.delete(storedData[Index])
                                }
                                
                            } else {
                                Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                                Constant.MyClassConstants.relinquishmentIdArray.remove(at: Index)
                                realm.delete(storedData[Index])
                                
                            }
                            
                            let deletionIndexPath = IndexPath(item: Index, section: 0)
                            self.collectionView.deleteItems(at: [deletionIndexPath])
                            Helper.InitializeOpenWeeksFromLocalStorage()
                        }
                    } else {
                        
                        Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                        Constant.MyClassConstants.relinquishmentIdArray.remove(at: Index)
                        realm.delete(storedData[Index])
                        let deletionIndexPath = IndexPath(item: Index, section: 0)
                        self.collectionView.deleteItems(at: [deletionIndexPath])
                        Helper.InitializeOpenWeeksFromLocalStorage()
                    }
                } else {
                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: Index)
                    realm.delete(storedData[Index])
                    let deletionIndexPath = IndexPath(item: Index, section: 0)
                    self.collectionView.deleteItems(at: [deletionIndexPath])
                }
            }
}
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        
        self.delegate?.multipleResortInfoButtonPressedAtIndex(Index)
    }
    
}
