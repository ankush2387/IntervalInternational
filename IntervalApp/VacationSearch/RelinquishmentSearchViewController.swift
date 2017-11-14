//
//  RelinquishmentSearchViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class RelinquishmentSearchViewController: UIViewController {
    
    @IBOutlet weak var tableViewRelinquishment: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = Constant.ControllerTitles.relinquishmentViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension RelinquishmentSearchViewController: UITableViewDataSource {
   
    //***** UITableview dataSource methods definition here *****//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 2:
            return 1
        case 3:
            return 3
        case 4:
            return 3
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            if ((indexPath as NSIndexPath).row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentCell, for: indexPath) as UITableViewCell
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.goldPointsCell, for: indexPath) as UITableViewCell
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.goldPointsCell, for: indexPath) as UITableViewCell
            
            return cell
        }
    }

}

extension RelinquishmentSearchViewController: UITableViewDelegate {
    //***** Implementing header cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 1) {
            return 0
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 12, width: self.view.bounds.width - 30, height: 20))
        headerView.backgroundColor = IUIKColorPalette.tertiary1.color
        headerTextLabel.text = Constant.MyClassConstants.relinquishmentHeaderArray[section]
        headerTextLabel.textColor = IUIKColorPalette.primaryText.color
        headerView.addSubview(headerTextLabel)
                return headerView
    }
}
