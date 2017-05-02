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

class BedroomSizeViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var bedroomSizeTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
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
       
        // Do any additional setup after loading the view.
        //titleLabel.text = Constant.ControllerTitles.bedroomSizeViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(self.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        //***** creating and adding right bar button for Done option button *****//
        let doneButton = UIBarButtonItem(title: Constant.AlertPromtMessages.done, style: .plain, target: self, action: #selector(self.doneButtonPressed(_
            :)))
        doneButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = doneButton
        
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
            
            if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
                self.dismiss(animated: true, completion: nil)
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
                
                //***** creating animation transition to show custom transition animation *****//
                let transition: CATransition = CATransition()
                let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.duration = 0.50
                transition.timingFunction = timeFunc
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }else{
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
        
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            return Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count
        }else{
            return Constant.MyClassConstants.bedRoomSize.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell   = tableView.dequeueReusableCell(withIdentifier: Constant.bedroomSizeViewController.bedroomsizeCellIdentifier) as? BedroomSizeTableViewCell
        
        if(Constant.ControllerTitles.selectedControllerTitle == Constant.storyboardControllerID.relinquishmentSelectionViewController){
            
            cell?.bedroomSizelabel.text = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[indexPath.row] as! String
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
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
