//
//  DestinationResortViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/30/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class DestinationResortViewController: UIViewController {

    @IBOutlet weak var destinationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Destination")
        
//        destinationTableView.estimatedRowHeight = 68.0
        destinationTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        destinationTableView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//Extension for UITableViewDataSource 
extension DestinationResortViewController: UITableViewDataSource {
    //Return Number of rows in a section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    //Return cell for a row in section
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var resortdetailCell: ResortDetailCellTableViewCell?
        let unitdetailCell: UnitdetailTableViewCell?
        let advertisementCell: AdvertisementTableViewCell?
        let unitAndAdditionaladvertisementCell: UnitAndAdditionalAdvertisementTableViewCell?
        
        let checkIncheckoutDatecell: CheckInCheckOutTableViewCell?
        
        if indexPath.row == 0 {
            resortdetailCell = tableView.dequeueReusableCellWithIdentifier("resortdetailscell") as? ResortDetailCellTableViewCell
            resortdetailCell?.getCell()
            return resortdetailCell!
        } else if indexPath.row == 1 {
            
            checkIncheckoutDatecell = tableView.dequeueReusableCellWithIdentifier("checkincheckoutcell") as? CheckInCheckOutTableViewCell
            
            //
            return checkIncheckoutDatecell!
        } else if indexPath.row == 2 {
            unitdetailCell = tableView.dequeueReusableCellWithIdentifier("unitdeailcell") as? UnitdetailTableViewCell
           
            return unitdetailCell!
        } else if indexPath.row == 3 {
             advertisementCell = tableView.dequeueReusableCellWithIdentifier("advertisementcell") as? AdvertisementTableViewCell

            return advertisementCell!
        } else {
                        unitAndAdditionaladvertisementCell = tableView.dequeueReusableCellWithIdentifier("dropdowncell") as? UnitAndAdditionalAdvertisementTableViewCell
            return unitAndAdditionaladvertisementCell!
        }
        
    }
    //Retrun Row Height
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat = 200
        switch indexPath.row {
        case 0:
            height = 113
        case 1:
            height = 81
        case 2:
            height = 92
        case 3:
            height = 138
        case 4 :
            height = 48
        default:
            break
        }
        return height
    }
}
//Extension for UITableViewDelegate
extension DestinationResortViewController: UITableViewDelegate {
    
}
