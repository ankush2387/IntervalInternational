//
//  SelectBedroomViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 8/22/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class SelectBedroomViewController: UIViewController {

    @IBOutlet weak private var bedroomSelectionTableView: UITableView!
    fileprivate var selectedBedroomArray = [String]()
    fileprivate var localArrayToHoldSelection = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bedroomSelectionTableView.delegate = self
        bedroomSelectionTableView.dataSource = self
        
        if Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count == 0 {
            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = [0, 1, 2, 3, 4]
            localArrayToHoldSelection = [0, 1, 2, 3, 4]
            Constant.MyClassConstants.alertSelectedBedroom = []
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        guard selectedBedroomArray.count > 0 else {
            self.presentAlert(with: "Bedroom Sizes", message: "Please select at least one bedroom size.")
            return
        }
        Constant.MyClassConstants.alertSelectedUnitSizeArray.removeAllObjects()
        
        if selectedBedroomArray.count == 5 {
            Constant.MyClassConstants.selectedBedRoomSize = "All Bedroom Sizes"
            Constant.MyClassConstants.alertSelectedBedroom = selectedBedroomArray
        } else {
            Constant.MyClassConstants.selectedBedRoomSize = ""
            for (index, selected) in selectedBedroomArray.enumerated() {
                Constant.MyClassConstants.alertSelectedBedroom = selectedBedroomArray
                if index == selectedBedroomArray.count - 1 {
                    Constant.MyClassConstants.selectedBedRoomSize.append("\(selected)")
                } else {
                    Constant.MyClassConstants.selectedBedRoomSize.append("\(selected), ")
                }
            }
        }
        
        if localArrayToHoldSelection.count != 0 {
            if localArrayToHoldSelection.count == 5 {
                Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.allBedrommSizes
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                
                for index in self.localArrayToHoldSelection {
                    Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(index as! Int)
                }
                
            } else {
                var i = 0
                var selectedBedroomsizes = ""
                for index in localArrayToHoldSelection {
                    if i < localArrayToHoldSelection.count - 1 {
                        let friendlyName = UnitSize.forDisplay[index as! Int].friendlyName()
                        let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: friendlyName)
                        selectedBedroomsizes = selectedBedroomsizes.appending("\(bedroomSize), ")
                        i = i + 1
                    } else {
                        let friendlyName = UnitSize.forDisplay[index as! Int].friendlyName()
                        let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: friendlyName)
                        selectedBedroomsizes = selectedBedroomsizes.appending("\(bedroomSize)")
                    }
                }
                Constant.MyClassConstants.selectedBedRoomSize = selectedBedroomsizes
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = self.localArrayToHoldSelection
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SelectBedroomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.MyClassConstants.bedRoomSize.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bedroomCell") as? BedroomTableViewCell else { return UITableViewCell() }
        let bedroom = UnitSize.fromFriendlyName(Constant.MyClassConstants.bedRoomSize[indexPath.row])
        
        cell.bedroomTitleLabel.text = bedroom?.friendlyName()
        cell.tag = indexPath.row
        if Constant.MyClassConstants.alertSelectedBedroom.count > 0 {
            if let bedRoomTitle = cell.bedroomTitleLabel.text {
                if Constant.MyClassConstants.alertSelectedBedroom.contains(bedRoomTitle) {
                    cell.checkedImageView.image = #imageLiteral(resourceName: "Checkmark-On")
                    selectedBedroomArray.append(bedRoomTitle)
                    self.localArrayToHoldSelection.add(cell.tag)
                } else {
                    cell.checkedImageView.image = #imageLiteral(resourceName: "Checkmark-Off")
                }
            }
       
        } else {
            selectedBedroomArray.append(cell.bedroomTitleLabel.text!)
            
        }
        
        return cell
    }
}

extension SelectBedroomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BedroomTableViewCell else { return }
        let selectedImg = #imageLiteral(resourceName: "Checkmark-On")
        let unSelectedImg = #imageLiteral(resourceName: "Checkmark-Off")
        
        if cell.checkedImageView.image == selectedImg {
            cell.checkedImageView.image = unSelectedImg
            if let bedRoomTitleLabel = cell.bedroomTitleLabel.text {
                updateSelectedBedroom(bedroom: bedRoomTitleLabel)
            }
        } else {
            cell.checkedImageView.image = selectedImg
            if let bedRoomTitleLabel = cell.bedroomTitleLabel.text {
                selectedBedroomArray.append(bedRoomTitleLabel)
            }
        }
        if self.localArrayToHoldSelection.count == 0 {
            self.localArrayToHoldSelection.add(cell.tag)

        } else {
            var flag = true
            let tempArray: NSMutableArray = NSMutableArray()
            for index in self.localArrayToHoldSelection where index as! Int == cell.tag {
                    let objectAt = self.localArrayToHoldSelection.index(of: index)
                    tempArray.add(objectAt)
                    flag = false
            }
            let indexSet = NSMutableIndexSet()
            for index in tempArray {
                indexSet.add(index as! Int)
            }
            self.localArrayToHoldSelection.removeObjects(at: indexSet as IndexSet)
            if flag {
                self.localArrayToHoldSelection.add(cell.tag)
            }
        }
    }
    
    fileprivate func updateSelectedBedroom(bedroom: String) {
        for (index, br) in selectedBedroomArray.enumerated() where bedroom == br {
                selectedBedroomArray.remove(at: index)
        }
    }
}
