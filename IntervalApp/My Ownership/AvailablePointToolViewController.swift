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
        _ = navigationController?.popViewController(animated: true)
    }
    
    var availablePoints = AvailablePoints()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate = nil
        title = Constant.ControllerTitles.availablePointToolViewController
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = menuButton
    }
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate == nil {
            presentAlert(with: Constant.ControllerTitles.availablePointToolViewController, message: Constant.AlertMessages.availablePointToolDefaultSelectedDateAlert)
            
            Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate = Date()
        }
        
        if let AblToolSelectdDate = Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate {
            
          let dateStr = AblToolSelectdDate.stringWithShortFormatForJSON()
            showHudAsync()
            UserClient.getProgramAvailablePoints(Session.sharedSession.userAccessToken, date: dateStr, onSuccess: {[weak self] (availablePoints) in
                guard let strongSelf = self else { return }
                strongSelf.hideHudAsync()
                self?.availablePointTableView.delegate = self
                self?.availablePointTableView.dataSource = self
                strongSelf.availablePoints = availablePoints
                strongSelf.availablePointTableView.reloadData()
                }, onError: {[unowned self] (error) in
                    
                    self.hideHudAsync()
                    intervalPrint(error)
            })
        }
        availablePointTableView.reloadData()
    }
    
}
/** Extension for UITableViewDataSource */
extension AvailablePointToolViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
            
                guard let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.pointToolDetailpointcellIdentifier) as? AvailablePointsAsOfTableViewCell else { return UITableViewCell() }
                    if let AblToolSelectedDate = Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate {
                    
                        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                        let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: AblToolSelectedDate)
                        let year = "\(myComponents.year ?? 0)"
                        let weekDay = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday ?? 0))"
                        let month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) \( myComponents.day ?? 0)"
                        cell.dateLabel.text = "\(weekDay), \(month) \(year)".localized()
                    }
                    cell.selectionStyle = .none
                    return cell

            } else {
                guard let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.availablePointCell) as? AvailablePointCell else { return UITableViewCell() }
                
                let availablePointsNumber = self.availablePoints.availablePoints ?? 0
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let availablePoints = numberFormatter.string(from: NSNumber(integerLiteral: availablePointsNumber))
                cell.availablePointValueLabel.text = availablePoints
                return cell
            }
        } else {
            if indexPath.row == 0 {
                guard let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.headerCell) as? HeaderCell else { return UITableViewCell() }
                 return cell
                
            } else if indexPath.row == self.availablePoints.usage.count + 1 {
                guard let  Cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.donebuttoncellIdentifier) as? FloatdetaildoneButtonTableViewCell else { return UITableViewCell() }
                
                    Cell.donebutton.layer.cornerRadius = 7
                    return Cell
            } else {
                
                guard let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.depositedpointhistorycellIdentifier) as? DepositedPointHistoryTableViewCell else { return UITableViewCell() }
                
                let programPointsUsage = self.availablePoints.usage
                let usage = programPointsUsage[indexPath.row - 1]
                
                if let expirationDate = usage.expirationDate {
                    let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                    let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: expirationDate.dateFromShortFormat())
                    let year = "\(myComponents.year ?? 0)"
                    let month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) \( myComponents.day ?? 0)"
                    
                    cell.pointsLabel.text = "\(usage.points ?? 0)".localized()
                    cell.expirationdateLabel.text = "\(month) \(year)".localized()
                    cell.depositstatusLabel.text = usage.pointsType?.localizedCapitalized
                }
   
                return cell
            }
        }
    }
    /** Number of Rows in a Section */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       let returnValue = (section == 0) ? 2 : self.availablePoints.usage.count + 2
        return returnValue

    }
}
/** Extension for UITableVieWDelegate */
extension AvailablePointToolViewController: UITableViewDelegate {
    
    /** Height for a Row at Index Path */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 70
            } else {
                return 90
            }
		} else {
            if indexPath.row == self.availablePoints.usage.count + 1  {
                return 90
            } else {
                return 40
            }
        }

	}
	/** Height for Header In Section */
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 0
		} else {
			return 50
		}
		
	}
	/** View For Header Section */
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return nil
		} else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: availablePointTableView.frame.size.width, height: 50))
            let headerStringLabel = UILabel(frame: CGRect(x: 5, y: 5, width: availablePointTableView.frame.size.width, height: 40))
            headerStringLabel.text = Constant.availablePointToolViewController.depositedPointHistoryinformationLabelText.localized()
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerView.addSubview(headerStringLabel)
            
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {

           
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as? CalendarViewController {
                viewController.requestedController = Constant.MyClassConstants.relinquishment
                let transitionManager = TransitionManager()
                navigationController?.transitioningDelegate = transitionManager
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
