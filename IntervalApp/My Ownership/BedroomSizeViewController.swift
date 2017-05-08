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
protocol BedroomSizeViewControllerDelegate {
    func doneButtonClicked()
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
    
    //***** function to determine the selection of bedroom size *****//
    @IBAction func bedroomSizeCheckboxIsTapped(_ sender:AnyObject) {
        
        let checkBox:IUIKCheckbox = sender as! IUIKCheckbox
        self.selectionChanged = true
        if(self.localArrayToHoldSelection.count == 0) {
            self.localArrayToHoldSelection.add(sender.tag)
            checkBox.isSelected = true
        }
        else {
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
        
        let arrayTableCells = NSMutableArray()
        for checkTableCell in bedroomSizeTableView.subviews{
            for checkCellsTableCell in checkTableCell.subviews{
                if (checkCellsTableCell.isKind(of: UITableViewCell.self)){
                    let tableCell = checkCellsTableCell as? UITableViewCell
                    arrayTableCells.add(tableCell!)
                }
            }
        }
        if(sender.tag - 1000 == Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count - 1){
            for tblCell in arrayTableCells{
                let masterCell = tblCell as! UITableViewCell
                let backgroundView = self.view.viewWithTag(masterCell.tag - 100 + 10)
                if(masterCell.tag - 100 != sender.tag - 1000){
                    if(sender.checked){
                        doneButton.isEnabled = true
                        backgroundView?.backgroundColor = IUIKColorPalette.titleBackdrop.color
                        masterCell.isUserInteractionEnabled = false
                    }else{
                        doneButton.isEnabled = false
                        backgroundView?.backgroundColor = UIColor.white
                        masterCell.isUserInteractionEnabled = true
                    }
                }else{
                    backgroundView?.backgroundColor = UIColor.white
                    masterCell.isUserInteractionEnabled = true
                    changeLabelColor(checkBox: sender as! IUIKCheckbox, masterCell: masterCell, checkState: sender.checked)
                }
            }
        }else{
            for tblCell in arrayTableCells{
                let masterCell = tblCell as! UITableViewCell
                let backgroundView = self.view.viewWithTag(masterCell.tag - 100 + 10)
                if(masterCell.tag - 100 == Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count - 1){
                    if(sender.checked){
                        doneButton.isEnabled = true
                        backgroundView?.backgroundColor = IUIKColorPalette.titleBackdrop.color
                        masterCell.isUserInteractionEnabled = false
                    }else{
                        doneButton.isEnabled = false
                        backgroundView?.backgroundColor = UIColor.white
                        masterCell.isUserInteractionEnabled = true
                    }
                }else{
                    for (ind,index) in localArrayToHoldSelection.enumerated(){
                        let checkBox:IUIKCheckbox = self.view.viewWithTag(index as! Int) as! IUIKCheckbox
                        if(ind < localArrayToHoldSelection.count - 1){
                            checkBox.checked = false
                        }
                    }
                    if(localArrayToHoldSelection.count > 1){
                        localArrayToHoldSelection.removeObject(at: 0)
                    }
                    if(masterCell.tag - 100 == sender.tag - 1000){
                        changeLabelColor(checkBox: checkBox, masterCell: masterCell, checkState: sender.checked)
                    }else{
                        changeLabelColor(checkBox: checkBox, masterCell: masterCell, checkState: false)
                    }
                }
            }
        }
    }
    
    // Function to change label colors on checkbox selection
    func changeLabelColor(checkBox:IUIKCheckbox, masterCell:UITableViewCell, checkState:Bool){
        for labels in masterCell.contentView.subviews{
            if(labels .isKind(of: UILabel.self)){
                let titleLabel = labels as? UILabel
                if(checkState){
                    titleLabel?.textColor = UIColor.orange
                }else{
                    titleLabel?.textColor = UIColor.black
                }
            }
        }
    }
    
    //Function to change table cell color
    func changeTableCellColor(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bedroomSizeTableView.estimatedRowHeight = 60
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            
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
        }
        doneButton.isEnabled = false
        self.bedroomSizeTableView.reloadData()
    }
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    
    
    @IBAction func closeButtonPressed(_ sender:AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func menuBackButtonPressed(_ sender:AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //***** function to dismis the current controller and  pass the selected data in previous controller *****//
    
    @IBAction func doneButtonPressed(_ sender:AnyObject) {
        
        if(localArrayToHoldSelection.count != 0) {
            
            if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
                delegate?.doneButtonClicked()
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
        
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            return Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count
        }else{
            return Constant.MyClassConstants.bedRoomSize.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell   = tableView.dequeueReusableCell(withIdentifier: Constant.bedroomSizeViewController.bedroomsizeCellIdentifier) as? BedroomSizeTableViewCell
        
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            
            cell?.bedroomSizelabel.text = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as? String
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.checkBoxButton.tag = indexPath.row
            cell?.tag = indexPath.row + 100
            cell?.backgroundCellView.tag = indexPath.row + 10
            cell?.checkBoxButton.tag = indexPath.row + 1000
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
}
