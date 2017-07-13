//
//  RelinguishmentDetailsViewController.swift
//  IntervalApp
//
//  Created by Chetu on 12/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RelinquishmentDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RelinquishmentDetailsViewController:UITableViewDataSource, UITabBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
            cell.dayAndDateLabel.text = ""
            cell.yearLabel.text = ""
            cell.totalWeekLabel.text = ""
            cell.resortName.text = ""
            cell.bedroomSizeAndKitchenClient.text = ""
            cell.totalSleepAndPrivate.text = ""
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath) as! SearchResultContentTableCell
            
            cell.resortName.text = "westwood at SplitRock"
            cell.resortCountry.text = "USA, miami"
            cell.resortCode.text = "WAP"
            
            return cell
            
        }
   
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
}
