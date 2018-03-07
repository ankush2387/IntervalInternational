//
//  InfoDetailViewController.swift
//  IntervalApp
//
//  Created by Chetu on 07/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class InfoDetailViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var resortDetailView: UIView!
    
    //****** class variables *****//
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//***** extensiion class to define tableview datasource methods *****//
extension InfoDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension InfoDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch Constant.MyClassConstants.selectedGetawayAlertDestinationArray[0] {
        case .resorts(let resorts):
            return resorts.count
        default :
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath as IndexPath) as! ResortInfoTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        switch Constant.MyClassConstants.selectedGetawayAlertDestinationArray[0] {
        case .resorts(let resorts):
            let resort = resorts[indexPath.row]
            cell.resortInfoLabel.text = "\u{2022}" + " " +
                resort.resortName.unwrappedString
        default :
            break
        }
       
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
