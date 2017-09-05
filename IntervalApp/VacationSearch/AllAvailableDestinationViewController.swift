//
//  AllAvailableDestinationViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 01/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class AllAvailableDestinationViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var allAvailableDestinatontableview: UITableView!
    
    //Class Varaiables
    var areaArray = [RegionArea]()
    var regionAreaDictionary = NSMutableDictionary()
    var selectedAreaDictionary = NSMutableDictionary()
    var moreButton:UIBarButtonItem?
    var selectedCheckBox = IUIKCheckbox()
    var mainCounter = 0
    var sectionCounter = 0
    var selectedSectionArray = NSMutableArray()
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Creating and adding right bar button for more option button *****//
        moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(moreNavButtonPressed(_:)))
        moreButton!.tintColor = UIColor.white
        self.navigationController?.navigationItem.rightBarButtonItem = moreButton
    }
    
    func moreNavButtonPressed(_ sender:UIBarButtonItem) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function for checkBox click
    
    func checkBoxClicked(){
        
    }
    
    //Function to add and remove areas and destinations
    
    func addRemoveAreasInRegion(indexPathForSelectedRegion:IndexPath){
        let region = Constant.MyClassConstants.regionArray[indexPathForSelectedRegion.section]
        print(region.regionCode!,region.areas)
        if(selectedAreaDictionary.value(forKey: region.regionName!) != nil){
            let selectedAreasArray = selectedAreaDictionary.value(forKey: region.regionName!) as! [String]
            let areaAtIndex = region.areas[indexPathForSelectedRegion.row]
            var newSelectedArray:[String] = selectedAreasArray
            for (index,areaName) in selectedAreasArray.enumerated(){
            if(selectedAreasArray.contains(areaAtIndex.areaName!)){
                newSelectedArray.remove(at: index)
                break
            }else{
                newSelectedArray.append(areaAtIndex.areaName!)
            }
            }
            /*for (index,areaName) in selectedAreasArray.enumerated(){
                if(areaName == areaAtIndex.areaName){
                    newSelectedArray.remove(at: index)
                }else{
                    newSelectedArray.append(areaName)
                }
            }*/
            if(newSelectedArray.count != 0){
                selectedAreaDictionary.setValue(newSelectedArray, forKey: region.regionName!)
            }else{
                selectedAreaDictionary.removeObject(forKey: region.regionName!)
            }
            
        }else{
            var areasArray = [String]()
            areasArray.append(region.areas[indexPathForSelectedRegion.row].areaName!)
            selectedAreaDictionary.setValue(areasArray, forKey: region.regionName!)
        }
        allAvailableDestinatontableview.reloadData()
       
    }
    
    func expandClicked(_ sender:UIButton){
        
        let rsregion = Constant.MyClassConstants.regionArray [sender.tag]
        if Constant.MyClassConstants.regionAreaDictionary[rsregion.regionCode!] == nil {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: rsregion.regionCode!)
        }else{
            Constant.MyClassConstants.regionAreaDictionary.removeObject(forKey: rsregion.regionCode!)
        }
        
        //self.allAvailableDestinatontableview.reloadSections(IndexSet(integer: sender.tag), with:.automatic)
        self.allAvailableDestinatontableview.reloadData()
        
    }
    
}


extension AllAvailableDestinationViewController:UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return Constant.MyClassConstants.regionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let areas = Constant.MyClassConstants.regionAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[section].regionCode!){
            let areasInRegionArray = areas as! [RegionArea]
            return areasInRegionArray.count
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.areaCell, for: indexPath) as! AvailableDestinationPlaceTableViewCell
        let areasArray = Constant.MyClassConstants.regionAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[indexPath.section].regionCode!) as! [RegionArea]
        self.areaArray.removeAll()
        if(selectedAreaDictionary.count > 0){
        let selectedAreas = selectedAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[indexPath.section].regionName!) as! [String]
        print(selectedAreas.count,selectedAreas,areasArray.count)
            
       // if(areasArray[indexPath.row].areaCode)
            
        //for areas in areasArray{
            /*if(selectedAreas.contains(where: {$0.areaCode == areasArray[indexPath.row].areaCode})){
                cell.placeSelectionCheckBox.checked = true
            }else{
                cell.placeSelectionCheckBox.checked = false
            }*/
        //}
        }
        
        for areas in areasArray{
            self.areaArray.append(areas)
        }
        
        cell.setAllAvailableAreaCell(index:indexPath.row, area:self.areaArray[indexPath.row])
        
        return cell
    }
    
}

extension AllAvailableDestinationViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! AvailableDestinationPlaceTableViewCell
        if(selectedCell.placeSelectionCheckBox.checked){
            sectionCounter = sectionCounter - 1
            selectedSectionArray.remove(indexPath.section)
            //selectedCell.placeSelectionCheckBox.checked = false
        }else{
            selectedSectionArray.add(indexPath.section)
            sectionCounter = sectionCounter + 1
            //selectedCell.placeSelectionCheckBox.checked = true
        }
       
        self.addRemoveAreasInRegion(indexPathForSelectedRegion:indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.regionCell) as! AvailableDestinationCountryOrContinentsTableViewCell
        cell.setDataForAllAvailableDestinations(index: section)
        cell.expandRegionButton.tag = section
        if(sectionCounter == 0){
            cell.selectdDestinationCountLabel.isHidden = true
        }else{
            cell.selectdDestinationCountLabel.text = String(sectionCounter)
            cell.selectdDestinationCountLabel.isHidden = false
        }
        cell.expandRegionButton.addTarget(self, action: #selector(AllAvailableDestinationViewController.expandClicked(_:)), for: .touchUpInside)
        
         return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 60
    }
    
    
}
