//
//  BedroomSizeViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import RealmSwift

//***** custom delegate method declaration *****//
@objc protocol BedroomSizeViewControllerDelegate {
    func doneButtonClicked(selectedUnitsArray: NSMutableArray)
    @objc optional func floatLockOffDetails(bedroomDetails: String)
}

class BedroomSizeViewController: UIViewController {
    
    //***** Custom cell delegate to access the delegate method *****//
    var delegate: BedroomSizeViewControllerDelegate?
    var selectedUnit = InventoryUnit()
    var selectedRelinquismentId: String?
    var isDeposit = false
    var isOnwershipSelection = false
    //***** Outlets *****//
    @IBOutlet weak var bedroomSizeTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    //***** Class variables *****//
    var selectionChanged = false
    internal var localArrayToHoldSelection = NSMutableArray()
    //internal var userSelectedUnitsArray = [String]()
    
    //***** function to determine the selection of bedroom size *****//
    @IBAction private func bedroomSizeCheckboxIsTapped(_ sender: IUIKCheckbox) {
        selectionChanged = true
        if localArrayToHoldSelection.count == 0 {
            localArrayToHoldSelection.add(sender.tag)
            sender.isSelected = true
            doneButton.isEnabled = true
        } else {
            var flag = true
            let tempArray = NSMutableArray()
            for index in localArrayToHoldSelection where index as? Int ?? 0 == sender.tag {
                let objectAt = localArrayToHoldSelection.index(of: index)
                tempArray.add(objectAt)
                flag = false
                sender.isSelected = false
            }
            let indexSet = NSMutableIndexSet()
            for index in tempArray {
                indexSet.add(index as? Int ?? 0)
            }
            localArrayToHoldSelection.removeObjects(at: indexSet as IndexSet)
            if flag {
                localArrayToHoldSelection.add(sender.tag)
                sender.isSelected = true
            }
        }
        if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController {
        }
    }
    
    //*** Change frame layout while change iPad in Portrait and Landscape mode.***//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if Constant.RunningDevice.deviceIdiom == .pad {
            frameChangeOnPortraitandLandscape()
        }
    }
    
    func frameChangeOnPortraitandLandscape() {
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            
        }
        
        self.bedroomSizeTableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSelectedUnitAndRelinquismentID()
        
        Constant.MyClassConstants.userSelectedStringArray.removeAll()
        // Function to get unit details saved in database
        self.getSaveUnitDetails()
        
        self.bedroomSizeTableView.estimatedRowHeight = 60
        if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController {
            self.titleLabel.text = Constant.MyClassConstants.relinquishmentTitle
        } else if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
            self.titleLabel.text = Constant.MyClassConstants.bedroomTitle
        } else {
            if Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count == 0 {
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = [0, 1, 2, 3, 4]
                localArrayToHoldSelection = [0, 1, 2, 3, 4]
            } else {
                for index in Constant.MyClassConstants.unitNumberSelectedArray {
                    localArrayToHoldSelection.add(index as? Int ?? 0)
                }
            }
            self.titleLabel.text = Constant.MyClassConstants.bedroomTitle
        }
        if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController {
            
            doneButton.isEnabled = false
            // omniture tracking with event 40
            let userInfo: [String: String] = [
                Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.simpleLockOffUnitOptions
            ]
            ADBMobile.trackAction(Constant.omnitureEvents.event40, data: userInfo)
            
        } else if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
            
            // omniture tracking with event 40
            let pageView: [String: String] = [
                Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.lockOffFloatUnitOptions
            ]
            ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
            self.titleLabel.text = Constant.MyClassConstants.floatTitle
            doneButton.isHidden = true
        }
        self.bedroomSizeTableView.reloadData()
    }
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    
    func getSelectedUnitAndRelinquismentID() {
        
        if let unit = Constant.MyClassConstants.relinquishmentSelectedWeek.unit {
            selectedUnit = unit
            selectedRelinquismentId = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId
        }
        
        if let unit = Constant.MyClassConstants.relinquismentSelectedDeposit.unit {
            isDeposit = true
            selectedUnit = unit
            selectedRelinquismentId = Constant.MyClassConstants.relinquismentSelectedDeposit.relinquishmentId
        }
        
    }
    
    @IBAction private func closeButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func menuBackButtonPressed(_ sender: AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Function to get unit details saved in database
    func getSaveUnitDetails() {
        for unitDetails in Constant.MyClassConstants.userSelectedUnitsArray {
            guard let unit = unitDetails as? List<ResortUnitDetails> else { return }
            let unitDetailString = "\(unit[0].unitSize),\(unit[0].kitchenType)"
            Constant.MyClassConstants.userSelectedStringArray.append(unitDetailString)
        }
    }
    
    //***** function to dismis the current controller and  pass the selected data in previous controller *****//
    
    @IBAction private func doneButtonPressed(_ sender: AnyObject) {
        
        if localArrayToHoldSelection.count != 0 {
            if isOnwershipSelection {
                Helper.deleteObjectsFromLocalStorage()
            }
            if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController {
                delegate?.doneButtonClicked(selectedUnitsArray: localArrayToHoldSelection)
            } else {
                if selectionChanged {
                    
                    if localArrayToHoldSelection.count == 5 {
                        Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.allBedrommSizes
                        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                        
                        for index in localArrayToHoldSelection {
                            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(index as? Int ?? 0)
                        }
                        
                    } else {
                        var i = 0
                        var selectedBedroomsizes = [String]()
                        for index in localArrayToHoldSelection {
                            
                            Constant.MyClassConstants.alertSelectedUnitSizeArray.append(Constant.MyClassConstants.bedRoomSize[index as? Int ?? 0])
                            if i < localArrayToHoldSelection.count {
                                
                                let friendlyName = UnitSize.forDisplay[index as? Int ?? 0].friendlyName()
                                
                                let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: friendlyName)
                                selectedBedroomsizes.append(bedroomSize)
                                
                                i = i + 1
                            }
                        }
                        Constant.MyClassConstants.selectedBedRoomSize = selectedBedroomsizes.joined(separator: ", ")
                        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = localArrayToHoldSelection
                    }
                }
                if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
                    delegate?.doneButtonClicked(selectedUnitsArray: localArrayToHoldSelection)
                }
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            presentAlert(with: Constant.AlertPromtMessages.bedRoomSizeTitle, message: Constant.AlertMessages.bedroomSizeAlertMessage)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/** Extension for UITableViewDataSource */
extension BedroomSizeViewController: UITableViewDataSource {
    
    /** Implementaion of UITableViewDataSource Methods */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController || Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
            return Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count
        } else {
            return Constant.MyClassConstants.bedRoomSize.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.bedroomSizeViewController.bedroomsizeCellIdentifier) as? BedroomSizeTableViewCell else { return UITableViewCell() }
        
        if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController || Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
            
            cell.backgroundCellView.layer.borderColor = UIColor.white.cgColor
            cell.bedroomSizelabel.text = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as? String
            cell.checkBoxButton.tag = indexPath.row + 1000
            intervalPrint(Constant.MyClassConstants.userSelectedStringArray)
            if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
                cell.checkBoxButton.isHidden = true
            } else {
                cell.checkBoxButton.isHidden = false
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.bedroomSizelabel.tag = indexPath.row + 100
            cell.unitSizeLabel.tag = indexPath.row + 10
            var unitDetails = ""
            if indexPath.row < Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count - 1 || Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count == 1 {
                
                if selectedUnit.lockOffUnits.count > 0 {
                    
                    let units = "\((selectedUnit.lockOffUnits[indexPath.row].unitNumber) ?? "")"
                    let unitnumber = units.replacingOccurrences(of: "/", with: "")
                    if let kitchenType = selectedUnit.lockOffUnits[indexPath.row].kitchenType {
                        unitDetails = "\(unitnumber), \(String(describing: Helper.getKitchenEnums(kitchenType: kitchenType)))"
                    }
                }
            } else {
                if let unitNumber = selectedUnit.unitNumber {
                    unitDetails = "\(String(describing: unitNumber))"
                }
                if let kitchenType = selectedUnit.kitchenType {
                    unitDetails.append(", \(String(describing: Helper.getKitchenEnums(kitchenType: kitchenType)))")
                }
            }
            cell.unitSizeLabel.text = unitDetails
            let unitNumber = unitDetails.components(separatedBy: ",")
            if Constant.MyClassConstants.userSelectedStringArray.contains(Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as? String ?? "") {
                if unitNumber[0] == Constant.MyClassConstants.unitNumberSelectedArray[indexPath.row] as? String ?? "" {
                    localArrayToHoldSelection.add(cell.checkBoxButton.tag as Any)
                    doneButton.isEnabled = true
                    cell.bedroomSizelabel.textColor = IUIKColorPalette.secondaryB.color
                    cell.unitSizeLabel.textColor = IUIKColorPalette.secondaryB.color
                    cell.checkBoxButton.checked = true
                }
            } else {
                cell.checkBoxButton.checked = false
            }
            intervalPrint(Constant.MyClassConstants.unitNumberSelectedArray)
            let setUnitSize = cell.bedroomSizelabel.text?.components(separatedBy: ",")[0]
            let setUnitNumber = cell.unitSizeLabel.text?.components(separatedBy: ",")[0]
            for selectedUnitDetails in Constant.MyClassConstants.saveLockOffDetailsArray {
                guard let relinquishmentID =  Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId else { return cell }
                if selectedUnitDetails.components(separatedBy: ",")[0] == setUnitNumber && selectedUnitDetails.components(separatedBy: ",")[1] == setUnitSize && Constant.MyClassConstants.realmOpenWeeksID.contains(relinquishmentID) {
                    cell.backgroundCellView.layer.borderColor = UIColor.orange.cgColor
                    cell.unitSizeLabel.textColor = IUIKColorPalette.secondaryB.color
                    cell.bedroomSizelabel.textColor = IUIKColorPalette.secondaryB.color
                    cell.infoSavedLabel.isHidden = false
                }
            }
            return cell
            
        } else {
            if Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count != 0 {
                var match = false
                for index in Constant.MyClassConstants.bedRoomSizeSelectedIndexArray where indexPath.row == index as? Int ?? 0 {
                    match = true
                    break
                }
                if match {
                    
                    cell.bedroomSizelabel.text = "\(UnitSize.forDisplay[indexPath.row].friendlyName())"
                    cell.checkBoxButton.checked = true
                    cell.checkBoxButton.tag = indexPath.row
                    
                } else {
                    
                    cell.bedroomSizelabel.text = "\(UnitSize.forDisplay[indexPath.row].friendlyName())"
                    cell.checkBoxButton.checked = false
                    cell.checkBoxButton.tag = indexPath.row
                }
                
            } else {
                
                cell.bedroomSizelabel.text = "\(UnitSize.forDisplay[indexPath.row].friendlyName())"
                cell.checkBoxButton.checked = true
                cell.checkBoxButton.tag = indexPath.row
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        }
    }
}

/** Extension for UITableViewDelegate */
extension BedroomSizeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController {
            let selectedBedroom = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as? String ?? ""
            Constant.MyClassConstants.selectedBedRoomSize = selectedBedroom
            let unitArray = selectedBedroom.components(separatedBy: ",")
            Constant.MyClassConstants.savedBedroom = unitArray[0]
            intervalPrint(indexPath.row)
            if indexPath.row < Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count - 1 {
                if let unitNUmber = selectedUnit.lockOffUnits[indexPath.row].unitNumber {
                    Constant.MyClassConstants.unitNumberLockOff = "\(unitNUmber)"
                }
                
            } else {
                if let unitNUmber = selectedUnit.unitNumber {
                    Constant.MyClassConstants.unitNumberLockOff = "\(unitNUmber)"
                }
                
            }
            
            for floatWeek in Constant.MyClassConstants.whatToTradeArray {
                
                if !(floatWeek as AnyObject).isKind(of: List<rlmPointsProgram>.self) {
                    guard let floatWeekTraversed = floatWeek as? OpenWeeks else { return }
                    if floatWeekTraversed.isFloat && selectedRelinquismentId == floatWeekTraversed.relinquishmentID {
                        if Constant.MyClassConstants.unitNumberLockOff == floatWeekTraversed.floatDetails[0].unitNumber {
                            Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                            Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
                        }
                        
                    }
                }
                for floatWeek in Constant.MyClassConstants.floatRemovedArray {
                    guard let floatWeekTraversed = floatWeek as? OpenWeeks else { return }
                    if floatWeekTraversed.isFloatRemoved && selectedRelinquismentId == floatWeekTraversed.relinquishmentID {
                        if Constant.MyClassConstants.unitNumberLockOff == floatWeekTraversed.floatDetails[0].unitNumber {
                            Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                            Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
                        }
                    }
                }
            }
            delegate?.floatLockOffDetails?(bedroomDetails:Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as? String ?? "")
            self.dismiss(animated: false, completion: nil)
        }
    }
}

