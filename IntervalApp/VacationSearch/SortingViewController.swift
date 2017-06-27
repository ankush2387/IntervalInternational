//
//  SortingViewController.swift
//  IntervalApp
//
//  Created by Chetu on 20/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class SortingViewController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var sortingTBLview: UITableView!
    
    
    //class variables
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = Constant.ControllerTitles.sorting
        //***** Add the cancel button  as left bar button item *****//
        
        let cancelButton = UIBarButtonItem(title: Constant.buttonTitles.cancel, style: .plain, target: self, action: #selector(cancelButtonPressed(_:)))

        cancelButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = cancelButton
        
        //***** Creating and adding right bar button for more option button *****//
        let doneButton = UIBarButtonItem(title:Constant.AlertPromtMessages.done, style: .plain, target: self, action: #selector(doneButtonPressed(_:)))
        doneButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = doneButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func doneButtonPressed(_ sender:UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonPressed(_ sender:UIBarButtonItem) {
        
         self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension SortingViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        self.sortingTBLview.reloadData()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.sortingOptionCell, for: indexPath) as! SortingOptionCell
        
        if(self.selectedIndex == indexPath.row) {
            
            cell.sortingOptionLabel.textColor = IUIKColorPalette.secondaryB.color
        }else {
            
            cell.sortingOptionLabel.textColor = UIColor.lightGray
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell

    }
    
        
    
    
}
