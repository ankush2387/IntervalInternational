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
    func doneButtonClicked(selectedUnitsArray:NSMutableArray)
    @objc optional func floatLockOffDetails(bedroomDetails:String)
}

class BedroomSizeViewController: UIViewController {
    
    //***** Custom cell delegate to access the delegate method *****//
    var delegate: BedroomSizeViewControllerDelegate?
    
    //***** Outlets *****//
    @IBOutlet weak var bedroomSizeTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    //***** Class variables *****//
    var selectionChanged = false
    internal var localArrayToHoldSelection = NSMutableArray()
    //internal var userSelectedUnitsArray = [String]()
    
    //***** function to determine the selection of bedroom size *****//
    @IBAction func bedroomSizeCheckboxIsTapped(_ sender:AnyObject) {
        
        let checkBox:IUIKCheckbox = sender as! IUIKCheckbox
       
        self.selectionChanged = true
        if(self.localArrayToHoldSelection.count == 0) {
            self.localArrayToHoldSelection.add(sender.tag)
            checkBox.isSelected = true
            doneButton.isEnabled = true
        }else {
            var flag = true
            let tempArray:NSMutableArray = NSMutableArray()
            for index in self.localArrayToHoldSelection {
                
                if(index as! Int == checkBox.tag) {
                    
                    let objectAt = self.localArrayToHoldSelection.index(of: index)
                    tempArray.add(objectAt)
                    flag = false
                    checkBox.isSelected = false
                }
            }
            let indexSet = NSMutableIndexSet()
            for index in tempArray {
                indexSet.add(index as! Int)
            }
            self.localArrayToHoldSelection.removeObjects(at: indexSet as IndexSet)
            if(flag) {
                self.localArrayToHoldSelection.add(sender.tag)
                checkBox.isSelected = true
            }
        }
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            self.changeLabelColor(checkBox: checkBox)
        }
    }
    
    // Function to change label colors on checkbox selection
    func changeLabelColor(checkBox:IUIKCheckbox){
        
        let checkedLabel = self.view.viewWithTag(checkBox.tag%10 + 100) as! UILabel
        if(checkBox.checked){
            checkedLabel.textColor = UIColor.orange
        }else{
            checkedLabel.textColor = UIColor.black
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Constant.MyClassConstants.userSelectedStringArray.removeAll()
        // Function to get unit details saved in database
        self.getSaveUnitDetails()
        
        // omniture tracking with event 68
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.simpleLockOffUnitOptions,
            ]
        ADBMobile.trackAction(Constant.omnitureEvents.event68, data: userInfo)

        
        self.bedroomSizeTableView.estimatedRowHeight = 60
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            self.titleLabel.text = Constant.MyClassConstants.relinquishmentTitle
        }else if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController){
            self.titleLabel.text = Constant.MyClassConstants.bedroomTitle
        }else{
            if(Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count == 0) {
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = [0,1,2,3,4]
                self.localArrayToHoldSelection = [0,1,2,3,4]
            }
            else {
                for index in Constant.MyClassConstants.bedRoomSizeSelectedIndexArray{
                    self.localArrayToHoldSelection.add(index as! Int)
                }
            }
            self.titleLabel.text = Constant.MyClassConstants.bedroomTitle
        }
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            doneButton.isEnabled = false
        }else{
            doneButton.isHidden = true
        }
        self.bedroomSizeTableView.reloadData()
    }
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    
    @IBAction func closeButtonPressed(_ sender:AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func menuBackButtonPressed(_ sender:AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Function to get unit details saved in database
    func getSaveUnitDetails(){
        for unitDetails in Constant.MyClassConstants.userSelectedUnitsArray{
            let unit:List<ResortUnitDetails> = unitDetails as! List<ResortUnitDetails>
            let unitDetailString = "\(unit[0].unitSize),\(unit[0].kitchenType)"
            Constant.MyClassConstants.userSelectedStringArray.append(unitDetailString)
        }
    }

    
    //***** function to dismis the current controller and  pass the selected data in previous controller *****//
    
    @IBAction func doneButtonPressed(_ sender:AnyObject) {
        
        if(localArrayToHoldSelection.count != 0) {
            
            if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
                delegate?.doneButtonClicked(selectedUnitsArray:localArrayToHoldSelection)
            }else{
                if(self.selectionChanged ) {
                    
                    if(localArrayToHoldSelection.count == 5) {
                        Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.allBedrommSizes
                        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                        
                        for index in self.localArrayToHoldSelection{
                            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(index as! Int)
                        }
                        
                    }
                    else {
                        var i = 0
                        var selectedBedroomsizes = ""
                        for index in localArrayToHoldSelection {
                            
                            Constant.MyClassConstants.alertSelectedUnitSizeArray.add(Constant.MyClassConstants.bedRoomSize[index as! Int])
                            if(i < localArrayToHoldSelection.count - 1) {
                                
                                let friendlyName = UnitSize.forDisplay[index as! Int].friendlyName()
                                
                                selectedBedroomsizes = selectedBedroomsizes.appending("\(friendlyName), ")
                                
                                i = i + 1
                            }
                            else {
                                
                                let friendlyName = UnitSize.forDisplay[index as! Int].friendlyName()
                                
                                selectedBedroomsizes = selectedBedroomsizes.appending("\(friendlyName)")
                            }
                        }
                        Constant.MyClassConstants.selectedBedRoomSize = selectedBedroomsizes
                        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = self.localArrayToHoldSelection
                    }
                }
                if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController){
                    delegate?.doneButtonClicked(selectedUnitsArray:localArrayToHoldSelection)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            SimpleAlert.alert(self, title: Constant.AlertPromtMessages.bedRoomSizeTitle, message: Constant.AlertMessages.bedroomSizeAlertMessage)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


/** Extension for UITableViewDataSource */
extension BedroomSizeViewController : UITableViewDataSource{
    
    /** Implementaion of UITableViewDataSource Methods */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController || Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController){
            return Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count
        }else{
            return Constant.MyClassConstants.bedRoomSize.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell   = tableView.dequeueReusableCell(withIdentifier: Constant.bedroomSizeViewController.bedroomsizeCellIdentifier) as? BedroomSizeTableViewCell
        
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController || Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController){
            
            cell?.backgroundCellView.layer.borderColor = UIColor.white.cgColor
            cell?.bedroomSizelabel.text = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as? String
            cell?.checkBoxButton.tag = indexPath.row + 1000
           if(Constant.MyClassConstants.userSelectedStringArray.contains(Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as! String)){
            if(!localArrayToHoldSelection.contains(cell?.checkBoxButton.tag as Any))
            {
                localArrayToHoldSelection.add(cell?.checkBoxButton.tag as Any)
                doneButton.isEnabled = true
                cell?.bedroomSizelabel.textColor = UIColor.orange
            }
                cell?.checkBoxButton.checked = true
            }else{
                cell?.checkBoxButton.checked = false
            }
            if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController){
                cell?.checkBoxButton.isHidden = true
            }else{
                cell?.checkBoxButton.isHidden = false
            }
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.bedroomSizelabel.tag = indexPath.row + 100
            var unitDetails = ""
            if(indexPath.row < Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count - 1 ){
            unitDetails = "\(String(describing: Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.lockOffUnits[indexPath.row].unitNumber!)), \(String(describing: Helper.getKitchenEnums(kitchenType: Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.lockOffUnits[indexPath.row].kitchenType!)))"
            }else{
                unitDetails = "\(String(describing: Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.unitNumber!)), \(String(describing: Helper.getKitchenEnums(kitchenType: Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.kitchenType!)))"
            }
            cell?.unitSizeLabel.text = unitDetails
            return cell!
            
        }else{
            if (Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count != 0) {
                var match = false
                for index in Constant.MyClassConstants.bedRoomSizeSelectedIndexArray {
                    if((indexPath as NSIndexPath).row == index as! Int) {
                        match = true
                        break
                    }
                }
                if(match) {
                    
                    cell?.bedroomSizelabel.text = "\(UnitSize.forDisplay[indexPath.row].friendlyName())"
                    cell?.checkBoxButton.checked = true
                    cell?.checkBoxButton.tag = indexPath.row
                    
                }
                else {
                    
                    cell?.bedroomSizelabel.text = "\(UnitSize.forDisplay[indexPath.row].friendlyName())"
                    cell?.checkBoxButton.checked = false
                    cell?.checkBoxButton.tag = indexPath.row
                }
                
            }
            else {
                
                cell?.bedroomSizelabel.text = "\(UnitSize.forDisplay[indexPath.row].friendlyName())"
                cell?.checkBoxButton.checked = true
                cell?.checkBoxButton.tag = indexPath.row
                
                
            }
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            return cell!
            
        }
    }
}



/** Extension for UITableViewDelegate */
extension BedroomSizeViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableView.cellForRow(at: indexPath) as! BedroomSizeTableViewCell
        tableCell.backgroundCellView.layer.borderColor = UIColor.orange.cgColor
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.floatViewController){
            let selectedBedroom = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as! String
            let unitArray = selectedBedroom.components(separatedBy: ",")
        Constant.MyClassConstants.savedBedroom = unitArray[0]
        Constant.MyClassConstants.unitNumberLockOff = (String(describing: Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.lockOffUnits[indexPath.row].unitNumber!))
        delegate?.floatLockOffDetails!(bedroomDetails:Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as! String)
        self.dismiss(animated: false, completion: nil)
        }
     }
}
