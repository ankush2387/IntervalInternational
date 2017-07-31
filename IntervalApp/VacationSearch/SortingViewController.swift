//
//  SortingViewController.swift
//  IntervalApp
//
//  Created by Chetu on 20/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

protocol sortingOptionDelegate {
    func selectedOptionis(filteredValueIs:String)
}

class SortingViewController: UIViewController {
  
    var delegate:sortingOptionDelegate?
    
    var isFilterClicked = false
    
    //Outlets
    @IBOutlet weak var sortingTBLview: UITableView!
    
    //class variables
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //remove extra separator of tableview
        self.sortingTBLview.tableFooterView = UIView()
        
        self.title = Constant.ControllerTitles.sorting
        //***** Add the cancel button  as left bar button item *****//
        
        let cancelButton = UIBarButtonItem(title: Constant.buttonTitles.cancel, style: .plain, target: self, action: #selector(cancelButtonPressed(_:)))

        cancelButton.tintColor = UIColor.init(colorLiteralRed: 52.0/255.0, green: 152.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = cancelButton
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /*func doneButtonPressed(_ sender:UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }*/
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
        if self.isFilterClicked {
            let cell = sender.superview?.superview?.superview as? FilterCell
            let indexPath = self.sortingTBLview.indexPath(for: cell!)
            
            self.selectedIndex = (indexPath?.row)!
            
            self.delegate?.selectedOptionis(filteredValueIs: "filtered vale")
            
        } else {
            let cell = sender.superview?.superview?.superview as? SortingOptionCell
            let indexPath = self.sortingTBLview.indexPath(for: cell!)
            
            self.selectedIndex = (indexPath?.row)!
            
            self.delegate?.selectedOptionis(filteredValueIs: "sorting vale")
        }
        
        self.navigationController?.popViewController(animated: true)
        
        
       // self.sortingTBLview.reloadData()
        
    }
    
    
    
    func cancelButtonPressed(_ sender:UIBarButtonItem) {
        
         //self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}

extension SortingViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        self.sortingTBLview.reloadData()
        
        // set selected value here from array.
        if self.isFilterClicked {
            self.delegate?.selectedOptionis(filteredValueIs: "filtered vale")
        } else {
            self.delegate?.selectedOptionis(filteredValueIs: "sorting value")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension SortingViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.isFilterClicked  {
             let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.filterOptionCell, for: indexPath) as! FilterCell
            if(self.selectedIndex == indexPath.row) {
                
                cell.lblFilterOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            }else {
                
                cell.lblFilterOption.textColor = UIColor.lightGray
                cell.checkBox.checked = false
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else {
             let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.sortingOptionCell, for: indexPath) as! SortingOptionCell
            if(self.selectedIndex == indexPath.row) {
                
                cell.lblSortingOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            }else {
                
                cell.lblSortingOption.textColor = UIColor.lightGray
                cell.checkBox.checked = false
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        
    }
    
    
}
