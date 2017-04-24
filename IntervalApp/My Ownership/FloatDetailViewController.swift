//
//  FloatDetailViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/2/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class FloatDetailViewController: UIViewController {
    
    /**
     PopcurrentViewcontroller from NavigationController
     - parameter sender: UIButton reference.
     - returns : No return.
     */
    @IBAction func floatCancelButtonIsTapped(_ sender: UIButton) {
        //self.navigationController?.popViewControllerAnimated(true)
        let storyboard = UIStoryboard(name: "AvailableDestinationsIphone", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ControllerTitles.floatDetailViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(FloatDetailViewController.menuBackButtonPressed(_:)))
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
}
/** Extension for tableview data source */
extension FloatDetailViewController : UITableViewDataSource{
    /** number of rows in section */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    /** cell for an indexPath */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  resortcallCell:CallYourResortTableViewCell?
        var vacationdetailcell:VacationDetailTableViewCell?
        var selectClubresortcell:UITableViewCell?
        var registrationNumbercell:UITableViewCell?
        var unitNumberbedroomCell:UITableViewCell?
        var checkindateCell:FloatDetailsCheckIndateTableViewCell?
        var saveandcancelCell:FloatSaveAndCancelButtonTableViewCell?
        switch (indexPath as NSIndexPath).row{
        case 0:
            
            resortcallCell  = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
            
        case 1:
            
            vacationdetailcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.vacationdetailcellIdentifier) as? VacationDetailTableViewCell
            vacationdetailcell!.getCell()
        case 2:
            
            selectClubresortcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.selectclubcellIdentifier)
        case 3:
            registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.registrationNumbercellIdentifier)
        case 4:
            unitNumberbedroomCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.unitnumberandbedroomdetailcellIdentifier)
        case 5 :
            checkindateCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.checkindatecellIdentifier) as?FloatDetailsCheckIndateTableViewCell
        case 6 :
            saveandcancelCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.saveandcancelcellIdentifier) as? FloatSaveAndCancelButtonTableViewCell
        default:
            resortcallCell  = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
        }
        if resortcallCell != nil{
            return resortcallCell!
        }
        else if vacationdetailcell != nil{
            return vacationdetailcell!
        }
        else if selectClubresortcell != nil{
            return selectClubresortcell!
        }
        else if registrationNumbercell != nil{
            return registrationNumbercell!
        }
        else if unitNumberbedroomCell != nil{
            return unitNumberbedroomCell!
        }
        else if checkindateCell != nil{
            return checkindateCell!
        }
        else if saveandcancelCell != nil{
            return saveandcancelCell!
        }
        else{
            return resortcallCell!
        }
        
    }
}
/** Extension for table view delegate */
extension FloatDetailViewController : UITableViewDelegate{
	/**Height of Row at index path */
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var rowHeight:CGFloat = 100
		switch (indexPath as NSIndexPath).row{
		case 0:
			rowHeight = 100
		case 1:
			rowHeight = 135
		case 2:
			rowHeight = 105
		case 3:
			rowHeight = 90
		case 4:
			rowHeight = 120
		case 5:
			rowHeight = 80
		case 6:
			rowHeight = 130
		default :
			rowHeight = 100
		}
		return rowHeight
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 2
        {
            self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
        }
    }
}
