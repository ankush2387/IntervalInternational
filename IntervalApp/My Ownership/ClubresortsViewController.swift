//
//  ClubresortsViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ClubresortsViewController: UIViewController {

    /** Outlets */
    @IBOutlet weak var clubresortTableView: UITableView!
    
    @IBOutlet weak var clubresortNameLabel: UILabel!
    
    /**
        used to update selected resort from resort list
        - parameter sender:AnyObject Type reference
        - returns : No value is return
    */
    @IBAction func clubselectedIstapped(_ sender: AnyObject) {
        guard let currentCheckedIndex = self.currentCheckedIndex else{
            Constant.MyClassConstants.savedClubFloatResort = Constant.MyClassConstants.clubFloatResorts[sender.tag].resortName!
            isbedroomSizeCheckboxchecked = true
            self.currentCheckedIndex = sender.tag
            clubresortTableView.reloadData()
            self.navigationController?.popViewController(animated: true)
            return
        }
        if currentCheckedIndex == sender.tag{
            isbedroomSizeCheckboxchecked = false
        }
        else{
            isbedroomSizeCheckboxchecked = true
            self.currentCheckedIndex = sender.tag
        }
        
        clubresortTableView.reloadData()
    }
    
    /** Class Variables */
    var clubresortArrayOfDictionary = [[String:String]]()
    var currentCheckedIndex : Int?
    var isbedroomSizeCheckboxchecked:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ControllerTitles.clubresortsViewController
        
        var clubresortdictionary = [String:String]()
        /** Dummy Data */
        clubresortdictionary.updateValue("Cibola Vista Resort and Spa • CIR", forKey: "clubresortname")
        clubresortdictionary.updateValue("Valid check-in days:Sun Sat", forKey: "clubresoravailabilty")
        clubresortArrayOfDictionary.append(clubresortdictionary)
        clubresortArrayOfDictionary.append(clubresortdictionary)
        // Do any additional setup after loading the view.
        clubresortTableView.estimatedRowHeight  = 69
        clubresortTableView.rowHeight = UITableViewAutomaticDimension

        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(ClubresortsViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
    }
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
}
/** Extension for UITableViewDataSource */
extension ClubresortsViewController:UITableViewDataSource{
    /** Implements UITableViewDataSource Methods */
    
    /** Number of Rows In Sections */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.MyClassConstants.clubFloatResorts.count
    }
    /** Cell For Row At IndexPath */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resort = Constant.MyClassConstants.clubFloatResorts[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: Constant.clubresortsViewController.clubresortcellIdentifier) as? ClubresortTableViewCell
        if currentCheckedIndex != nil{
            if (indexPath as NSIndexPath).row == currentCheckedIndex!{
                
                cell?.getCell(clubresortArrayOfDictionary[(indexPath as NSIndexPath).row], index: currentCheckedIndex!, isChecked:isbedroomSizeCheckboxchecked)
            }
            else{
                cell?.getCell(clubresortArrayOfDictionary[(indexPath as NSIndexPath).row],index: (indexPath as NSIndexPath).row)
            }
        }
        else{
            cell?.getCell(clubresortArrayOfDictionary[(indexPath as NSIndexPath).row],index: (indexPath as NSIndexPath).row)
        }
        
        cell?.clubresortNameLabel.text = "\(resort.resortName!) . \(resort.resortCode!)"

        
        return cell!
    }
}
/** Extension for UITableViewDelegate */
extension ClubresortsViewController : UITableViewDelegate{
    
}
