//
//  AvailablePointToolViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/7/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD

class AvailablePointToolViewController: UIViewController {
    
    /** Outlets */
    @IBOutlet weak var availablePointTableView: UITableView!
    
    /**
     Navigate to root view controller in Navigation stack
     - parameter sender : UIButton reference
     - returns : No value is returned
     */
    @IBAction func doneButtonIsTapped(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    var availablePoints = AvailablePoints()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.title = Constant.ControllerTitles.availablePointToolViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed(_:)))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate == nil) {
            
            SimpleAlert.alert(self, title: Constant.ControllerTitles.availablePointToolViewController, message: Constant.AlertMessages.availablePointToolDefaultSelectedDateAlert)
            
            Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate = Date()
        }
        
        let dateStr = Helper.convertDateToString(date: Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
        
        showHudAsync()

        UserClient.getProgramAvailablePoints(Session.sharedSession.userAccessToken, date: dateStr, onSuccess:{ (availablePoints) in
            
            SVProgressHUD.dismiss()
            self.hideHudAsync()
            self.availablePoints = availablePoints
            self.availablePointTableView.reloadData()
        }, onError:{ (error) in
            
            SVProgressHUD.dismiss()
            self.hideHudAsync()
            print(error)
        })
        
        self.availablePointTableView.reloadData()
    }
    
    
}
/** Extension for UITableViewDataSource */
extension AvailablePointToolViewController:UITableViewDataSource{
    
    /** Implements UITableView Datasource Methods */
    
    /** Number of Sections in Table View */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    /** Cell for a Row */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0){
            
            if(indexPath.row == 0) {
                
                let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.pointToolDetailpointcellIdentifier) as! AvailablePointsAsOfTableViewCell
                
                
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate)
                let year = String(describing: myComponents.year!)
                let weekDay = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                let month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \( myComponents.day!)"
                
                
                cell.dateLabel.text = "\(weekDay), \(month) \(year)"
                cell.selectionStyle = .none
                return cell

            }
            else {
                
                let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.availablePointCell) as! AvailablePointCell
                
                let availablePointsNumber = self.availablePoints.availablePoints! as NSNumber
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                
                let availablePoints = numberFormatter.string(from: availablePointsNumber)
                
                cell.availablePointValueLabel.text = availablePoints
                
                return cell
            }
            
        }
        else {
            if(indexPath.row == 0) {
                
                 let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.headerCell) as! HeaderCell
                return cell
            }
            else if (indexPath.row == self.availablePoints.usage.count + 1){
                
                let  Cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.donebuttoncellIdentifier) as! FloatdetaildoneButtonTableViewCell
                
                    Cell.donebutton.layer.cornerRadius = 7
                
                    return Cell

            }
            else {
                
                let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.depositedpointhistorycellIdentifier) as! DepositedPointHistoryTableViewCell
                
                let programPointsUsage = self.availablePoints.usage
                let usage = programPointsUsage[indexPath.row - 1]
                
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from:Helper.convertStringToDate(dateString: usage.expirationDate!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat))
                let year = String(describing: myComponents.year!)
                let month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \( myComponents.day!)"
                
                cell.pointsLabel.text = String(usage.points!)
                cell.expirationdateLabel.text = "\(month) \(year)"
                cell.depositstatusLabel.text = usage.pointsType?.capitalized
                
                return cell

            }
            
        }
      
    }
    /** Number of Rows in a Section */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 2
        }
        else {
            return self.availablePoints.usage.count + 2
        }
    }
}
/** Extension for UITableVieWDelegate */
extension AvailablePointToolViewController:UITableViewDelegate{
		
	/** Height for a Row at Index Path */
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if (indexPath.section == 0){
            if(indexPath.row == 0) {
                
                return 70
            }
            else {
                return 90
            }
		}
        else {
            if(indexPath.row == self.availablePoints.usage.count + 1) {
                return 90
            }
            else {
                return 40
            }
            
        }
    
	}
	/** Height for Header In Section */
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0{
			return 0
		}
		else {
			return 50
		}
		
	}
	/** View For Header Section */
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0{
			return nil
		}
		else {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.availablePointTableView.frame.size.width, height: 50))
            
            let headerStringLabel = UILabel(frame: CGRect(x: 5, y: 5, width: self.availablePointTableView.frame.size.width, height: 40))
                headerStringLabel.text = Constant.availablePointToolViewController.depositedPointHistoryinformationLabelText
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerView.addSubview(headerStringLabel)
                
			return headerView
		}
		
	}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0 && indexPath.row == 0) {
           
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as! CalendarViewController
            viewController.requestedController = Constant.MyClassConstants.relinquishment
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)

        }
    }
}


