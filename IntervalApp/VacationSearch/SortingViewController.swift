//
//  SortingViewController.swift
//  IntervalApp
//
//  Created by Chetu on 20/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import Realm
import RealmSwift

protocol sortingOptionDelegate {
    func selectedOptionis(filteredValueIs:String, indexPath:NSIndexPath, isFromFiltered:Bool)
}

class SortingViewController: UIViewController {
  
    var delegate:sortingOptionDelegate?
    
    var isFilterClicked = false
     @IBOutlet weak var lblHeading: UILabel!
    var resortNameArray = [Resort]()
    
    
    //Outlets
    @IBOutlet weak var sortingTBLview: UITableView!
    
    //class variables
    var selectedIndex = -1
    var selectedSortingIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createFilterOptions()
        //remove extra separator of tableview
        self.sortingTBLview.tableFooterView = UIView()
        
        self.title = Constant.ControllerTitles.sorting
        //***** Add the cancel button  as left bar button item *****//
        
        /*let cancelButton = UIBarButtonItem(title: Constant.buttonTitles.cancel, style: .plain, target: self, action: #selector(cancelButtonPressed(_:)))

        cancelButton.tintColor = UIColor.init(colorLiteralRed: 52.0/255.0, green: 152.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = cancelButton
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white*/
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Set options for filter
    func createFilterOptions(){

        let storedData = Helper.getLocalStorageWherewanttoGo()
        
        if(storedData.count > 0) {
            let realm = try! Realm()
            try! realm.write {
                Constant.MyClassConstants.filterOptionsArray.removeAll()
                for (index,object) in storedData.enumerated(){
                    if(object.destinations.count > 0){
                        Constant.MyClassConstants.filterOptionsArray.append(
                            .Destination(object.destinations[0])
                            )
                       
                    }else if(object.resorts.count > 0){
                        Constant.MyClassConstants.filterOptionsArray.append(.Resort(object.resorts[0]))
                    }
                }
            }
        }
    }
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
        if self.isFilterClicked {
            let cell = sender.superview?.superview?.superview as? FilterCell
            let indexPath = self.sortingTBLview.indexPath(for: cell!)
            
            self.selectedIndex = (indexPath?.row)!
             self.sortingTBLview.reloadData()
            
            switch Constant.MyClassConstants.filterOptionsArray[(indexPath?.row)!] {
            case .Destination(let val):
                self.delegate?.selectedOptionis(filteredValueIs: val.destinationName, indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
            case .Resort(let val):
                 self.delegate?.selectedOptionis(filteredValueIs: val.resortName, indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
            }
            
            //let resortName = resortNameArray[(indexPath?.row)!].resortName
            
            //self.delegate?.selectedOptionis(filteredValueIs: resortName!, indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
            
        } else { // sorting option clicked
            let cell = sender.superview?.superview?.superview as? SortingOptionCell
            let indexPath = self.sortingTBLview.indexPath(for: cell!)
            
            self.selectedSortingIndex = (indexPath?.row)!
            
            self.delegate?.selectedOptionis(filteredValueIs: Constant.MyClassConstants.sortingOptionArray[(indexPath?.row)!], indexPath: indexPath! as NSIndexPath, isFromFiltered: false)
        }
        
        //self.navigationController?.popViewController(animated: true)
        
        
       // self.sortingTBLview.reloadData()
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
   /* func cancelButtonPressed(_ sender:UIBarButtonItem) {
        
         //self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }*/

}

extension SortingViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        self.selectedSortingIndex = indexPath.row
        self.sortingTBLview.reloadData()
        
        // set selected value here from array.
        if self.isFilterClicked {
            switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
            case .Destination(let val):
                self.delegate?.selectedOptionis(filteredValueIs: val.destinationName, indexPath: indexPath as NSIndexPath, isFromFiltered: true)
            case .Resort(let val):
                self.delegate?.selectedOptionis(filteredValueIs: val.resortName, indexPath: indexPath as NSIndexPath, isFromFiltered: true)
            }
            //self.delegate?.selectedOptionis(filteredValueIs: resortNameArray[indexPath.row].resortName!, indexPath: indexPath as NSIndexPath, isFromFiltered: true)
        } else {
            self.delegate?.selectedOptionis(filteredValueIs: Constant.MyClassConstants.sortingOptionArray[(indexPath.row)], indexPath: indexPath as NSIndexPath, isFromFiltered: false)
        }
        
        //self.navigationController?.popViewController(animated: true)
    }
}

extension SortingViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFilterClicked {
            return Constant.MyClassConstants.filterOptionsArray.count
        } else {
            return Constant.MyClassConstants.sortingOptionArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isFilterClicked  {
            
            
            
             self.lblHeading.text = Constant.MyClassConstants.filterSearchResult
             let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.filterOptionCell, for: indexPath) as! FilterCell
            switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
            case .Destination(let val):
                cell.lblFilterOption.text = val.destinationName
            case .Resort(let val):
                cell.lblFilterOption.text = val.resortName
            }
            //cell.lblFilterOption.text = resortNameArray[indexPath.row].resortName
            
            if(self.selectedIndex == indexPath.row) {
                
                cell.lblFilterOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            }else {
                
                cell.lblFilterOption.textColor = UIColor.lightGray
                cell.checkBox.checked = false
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else { // sorting options
            self.lblHeading.text = Constant.MyClassConstants.sorting
             let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.sortingOptionCell, for: indexPath) as! SortingOptionCell
            cell.lblSortingOption.text = Constant.MyClassConstants.sortingOptionArray[indexPath.row]
            cell.lblSortingRange.text = Constant.MyClassConstants.sortingRangeArray[indexPath.row]
            if(self.selectedSortingIndex == indexPath.row) {
                
                cell.lblSortingOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            }else {
                
                cell.lblSortingOption.textColor = UIColor.black
                cell.checkBox.checked = false
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        
    }
    
    
}
