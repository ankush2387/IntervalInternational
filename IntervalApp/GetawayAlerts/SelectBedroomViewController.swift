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
    fileprivate var localArrayToHoldSelection = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bedroomSelectionTableView.delegate = self
        bedroomSelectionTableView.dataSource = self
        
        if Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.count == 0 {
            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = [0, 1, 2, 3, 4]
            Constant.MyClassConstants.alertSelectedBedroom = []
        }
        
        if Constant.MyClassConstants.selectedBedRoomSize == Constant.MyClassConstants.allBedrommSizes {
            localArrayToHoldSelection = [0, 1, 2, 3, 4]
        } else {
        let brWithoutSpaces = Constant.MyClassConstants.selectedBedRoomSize.replacingOccurrences(of: " ", with: "")
        let bedroomSizes = brWithoutSpaces.components(separatedBy: ",")
        for value in bedroomSizes {
            localArrayToHoldSelection.append(Int("\(value)") ?? 0)
        }
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
        
        guard !localArrayToHoldSelection.isEmpty else {
            self.presentAlert(with: "Bedroom Sizes", message: "Please select at least one bedroom size.")
            return
        }
        Constant.MyClassConstants.alertSelectedUnitSizeArray.removeAll()
        
        if localArrayToHoldSelection.count == 5 {
            Constant.MyClassConstants.selectedBedRoomSize = "All Bedroom Sizes"
            Constant.MyClassConstants.alertSelectedBedroom = selectedBedroomArray
        } else {
            Constant.MyClassConstants.selectedBedRoomSize = ""
            for (index, selected) in localArrayToHoldSelection.enumerated() {
                if index == selectedBedroomArray.count - 1 {
                    Constant.MyClassConstants.selectedBedRoomSize.append("\(selected)")
                } else {
                    Constant.MyClassConstants.selectedBedRoomSize.append("\(selected), ")
                }
            }
        }
        
        if !localArrayToHoldSelection.isEmpty {
            if localArrayToHoldSelection.count == 5 {
                Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.allBedrommSizes
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                
                for index in localArrayToHoldSelection {
                    Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(index)
                }
                
            } else {
                var i = 0
                var selectedBedroomsizes = [String]()
                localArrayToHoldSelection.sort()
                for index in localArrayToHoldSelection where i < localArrayToHoldSelection.count {
                    let friendlyName = UnitSize.forDisplay[index].friendlyName()
                    let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: friendlyName)
                    selectedBedroomsizes.append(bedroomSize)
                    i = i + 1
                    
                }
                Constant.MyClassConstants.selectedBedRoomSize = selectedBedroomsizes.joined(separator: ", ")
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray = localArrayToHoldSelection as? NSMutableArray ?? []
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
        
        if Constant.MyClassConstants.selectedBedRoomSize == Constant.MyClassConstants.allBedrommSizes {
            cell.checkedImageView.image = #imageLiteral(resourceName: "Checkmark-On")
        } else {
        let brWithoutSpaces = Constant.MyClassConstants.selectedBedRoomSize.replacingOccurrences(of: " ", with: "")
        let bedroomSizes = brWithoutSpaces.components(separatedBy: ",")
        if !bedroomSizes.isEmpty {
            bedroomSizes.contains("\(indexPath.row)") ?
                (cell.checkedImageView.image = #imageLiteral(resourceName: "Checkmark-On") ) : (cell.checkedImageView.image = #imageLiteral(resourceName: "Checkmark-Off"))
            if bedroomSizes.contains("Studio") && indexPath.row == 0 {
                (cell.checkedImageView.image = #imageLiteral(resourceName: "Checkmark-On") )
            }
        } else {
            if let text = cell.bedroomTitleLabel.text {
                selectedBedroomArray.append(text)
            }
        }
        }
        
        return cell
    }
}

extension SelectBedroomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BedroomTableViewCell else { return }
        let selectedImg = #imageLiteral(resourceName: "Checkmark-On")
        let unSelectedImg = #imageLiteral(resourceName: "Checkmark-Off")
        cell.checkedImageView.image = cell.checkedImageView.image == selectedImg ? unSelectedImg : selectedImg
        if localArrayToHoldSelection.count == 0 {
            localArrayToHoldSelection.append(cell.tag)
        } else {
            var flag = true
            let tempArray: NSMutableArray = NSMutableArray()
            for index in localArrayToHoldSelection where index == cell.tag {
                let objectAt = localArrayToHoldSelection.index(of: index)
                tempArray.add(objectAt as Any)
                flag = false
            }
            let indexSet = NSMutableIndexSet()
            
            for index in tempArray {
                if let Index = index as? Int {
                    indexSet.add(Index)
                }
                
            }
            for index in indexSet {
                localArrayToHoldSelection.remove(at: index)
            }
            if flag {
                localArrayToHoldSelection.append(cell.tag)
            }
        }
    }
    
    fileprivate func updateSelectedBedroom(bedroom: String) {
        for (index, br) in selectedBedroomArray.enumerated() where bedroom == br {
            selectedBedroomArray.remove(at: index)
        }
    }
}
