//
//  AllAvailableDestinationsIpadViewController.swift
//  IntervalApp
//
//  Created by Chetu on 01/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class AllAvailableDestinationsIpadViewController: UIViewController {
    
    
    // class outlet
    @IBOutlet weak var allAvailableDestinatontableview: UITableView!
    
    @IBOutlet weak var searchButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchButton: UIButton!
    
    
    //Class Varaiables
    var areaArray = [RegionArea]()
    var regionAreaDictionary = NSMutableDictionary()
    var selectedAreaDictionary = NSMutableDictionary()
    var moreButton:UIBarButtonItem?
    var selectedCheckBox = IUIKCheckbox()
    var mainCounter = 0
    var sectionCounter = 0
    var selectedSectionArray = NSMutableArray()
    var regionCounterDict = [Int:String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewButtonHeightConstraint.constant = 0
        self.searchButtonHeightConstraint.constant = 0
        self.searchButton.isHidden = true
        
        // set corneer radius of search button
        self.searchButton.layer.cornerRadius = 5
        // set navigation right bar buttons
        
        self.title = "Available Destinations"
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(AllAvailableDestinationsIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = menuButton

    }
    
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        print("search button clicked")
    }
    
    
    //Function to add and remove areas and destinations
    
    func addRemoveAreasInRegion(indexPathForSelectedRegion:IndexPath){
        let region = Constant.MyClassConstants.regionArray[indexPathForSelectedRegion.section]
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
                //regionCounterDict = [1,region.regionName]
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
    
    func menuButtonClicked()  {
        print("menu button clicked");
        
        
        let optionMenu = UIAlertController(title: nil, message: "All Destinations Options", preferredStyle: .actionSheet)
        
        let viewSelectedResorts = UIAlertAction(title: "View My Selected Resorts", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showSelectedResortsIpad, sender: self)
        })
        
     
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(viewSelectedResorts)
        optionMenu.addAction(cancelAction)
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
            optionMenu.popoverPresentationController?.sourceView = self.view
            optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width,y: 0, width: 100, height: 60)
            optionMenu.popoverPresentationController!.permittedArrowDirections = .up;
        }
        
        //Present the AlertController
        self.present(optionMenu, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Buttons  Clicked
    
    @IBAction func headerButtonClicked(_ sender: UIButton) {
        let cell = sender.superview?.superview as? AvailableDestinationCountryOrContinentsTableViewCell
        
        
        let rsregion = Constant.MyClassConstants.regionArray [sender.tag]
        if Constant.MyClassConstants.regionAreaDictionary[rsregion.regionCode!] == nil {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: rsregion.regionCode!)
            
            cell?.imgIconPlus?.image = UIImage.init(named: "up_arrow_icon")
            
        }else{
            Constant.MyClassConstants.regionAreaDictionary.removeObject(forKey: rsregion.regionCode!)
            
            cell?.imgIconPlus?.image = UIImage.init(named: "DropArrowIcon")
            
        }
        
        
       /* if sender.isSelected {
            cell?.imgIconPlus?.image = UIImage.init(named: "DropArrowIcon")
            sender.isSelected = false

        } else {
            sender.isSelected = true
            cell?.imgIconPlus?.image = UIImage.init(named: "up_arrow_icon")
            
        }*/
        
        self.allAvailableDestinatontableview.reloadData()
        
    }
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
        UIView.animate(withDuration: 15, delay: 20, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.viewButtonHeightConstraint.constant = 100
            self.searchButtonHeightConstraint.constant = 50
            self.searchButton.isHidden = false
        }, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectedResort = segue.destination as! SelectedResortsIpadViewController
        selectedResort.areaDictionary = self.selectedAreaDictionary
        print(selectedResort.areaDictionary)
    }
}


extension AllAvailableDestinationsIpadViewController:UITableViewDataSource {
    
    
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
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let areasInRegionArray = Constant.MyClassConstants.regionAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[indexPath.section].regionCode!) as! [RegionArea]
        self.areaArray.removeAll()
        if(selectedAreaDictionary.count > 0){
            if let selectedAreas = selectedAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[indexPath.section].regionName!){
                let area = selectedAreas as! [String]
                print(area.count,area,area.count)
                
                let areaName = areasInRegionArray[indexPath.row].areaName
                if(area.contains(areaName!)){
                    cell.placeSelectionCheckBox.checked = true
                }else{
                    cell.placeSelectionCheckBox.checked = false
                }
            }else{
                cell.placeSelectionCheckBox.checked = false
            }
        }else{
            cell.placeSelectionCheckBox.checked = false
        }
        
        for areas in areasInRegionArray{
            self.areaArray.append(areas)
        }
        
        cell.setAllAvailableAreaCell(index:indexPath.row, area:self.areaArray[indexPath.row])
        
        return cell
    }
    
}


extension AllAvailableDestinationsIpadViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! AvailableDestinationPlaceTableViewCell
        // Only six items can be selected
        if(selectedCell.placeSelectionCheckBox.checked){
            sectionCounter = sectionCounter - 1
            selectedSectionArray.remove(indexPath.section)
            self.addRemoveAreasInRegion(indexPathForSelectedRegion:indexPath)
        }else{
            if(sectionCounter == 6){
                SimpleAlert.alert(self, title: "Alert!", message: "Maximum limit reached")
            }else{
                selectedSectionArray.add(indexPath.section)
                sectionCounter = sectionCounter + 1
                self.addRemoveAreasInRegion(indexPathForSelectedRegion:indexPath)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.regionCell) as! AvailableDestinationCountryOrContinentsTableViewCell
        cell.setDataForAllAvailableDestinations(index: section)
        cell.expandRegionButton.tag = section
        if(sectionCounter == 0){
            cell.selectdDestinationCountLabel?.isHidden = true
        }else{
            let region = Constant.MyClassConstants.regionArray[section]
            for selectedRegion in selectedAreaDictionary.allKeys{
                if String(describing: selectedRegion) == region.regionName{
                    let totalAreas = selectedAreaDictionary.value(forKey: selectedRegion as! String) as! [String]
                    cell.selectdDestinationCountLabel?.text = String(totalAreas.count)
                    cell.selectdDestinationCountLabel?.isHidden = false
                }
            }
            
        }
        
        return cell
    }
        
}



    



