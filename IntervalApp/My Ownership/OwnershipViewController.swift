//
//  OwnershipViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/29/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class OwnershipViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var ownerShiptableView: UITableView!
    //Class Variables
    fileprivate let numberOfSection = 3
    //private var numberOfrows = 5
    fileprivate let numberOfRowInclubIntervalGoldPointSection = 5
    fileprivate let numberOfRowInClubPointSection = 1
    fileprivate let numberOfRowInIntervalWeeksSection = 4
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.ownershipViewController
        ownerShiptableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.searchResultContentTableCell)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayMenuButton()
        ownerShiptableView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        // ownerShiptableView.reloadData()
    }
    //MARK:Display menu button
    /**
     Display  Hamburger menu button.
     - parameter No parameter:
     - returns :No return value.
     */
    fileprivate func displayMenuButton(){
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK:Get header view with Title label
    /**
     Generate an UIView for Section header.
     - parameter sectionheaderTitle: set title for section header
     - returns : An UIView Object for Section Header View
     */
    fileprivate func viewForSectionHeaderWithTitleLabel(sectionheaderTitle : String = "")->UIView{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ownerShiptableView.frame.size.width, height: 40))
        headerView.backgroundColor = UIColor.gray
        headerView.alpha = 0.45
        let sectionTitleLabel  = UILabel()
        headerView.addSubview(sectionTitleLabel)
        sectionTitleLabel.text = sectionheaderTitle
        sectionTitleLabel.textColor = UIColor.white
        
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let leadingConstraint = NSLayoutConstraint(item: sectionTitleLabel, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1.0, constant: 20)
        let centerYConstraint = NSLayoutConstraint(item: sectionTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([leadingConstraint])
        headerView.addConstraints([leadingConstraint,centerYConstraint])
        return headerView
    }
    
    
    
}
/** Extension for tableview data source */
extension OwnershipViewController:UITableViewDataSource{
    //MARK:set number of section in tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSection
    }
    /** Number of rows in a section */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfrows = 0
        switch section{
        case 0:
            numberOfrows = numberOfRowInclubIntervalGoldPointSection
        case 1:
            numberOfrows = numberOfRowInClubPointSection
        case 2:
            numberOfrows = numberOfRowInIntervalWeeksSection
        default:
            break
        }
        return numberOfrows
    }
    /** TableView cell for row */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myOwnershipavailablePointToolCell :MyOwnershipAvailablePointTooolTableViewCell?
        let myOwnershipclubIntervalGoldpointscell:MyownershipClubIntervalGoldPointsTableViewCell?
        let myOwnershipVacationResortcell:VacationOrResortTableViewCell?
        let ownershipdetailtableviewcell:OwnershipDetailTableViewCell?
        let clubpointcell:ClubpointTableViewCell?
        let ownershipdetalWithFreedeposit:OwnershipDetailWithFreeDepositTableViewCell?
        let ownershipfloatcell:OwnershipFloatTableViewCell?
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0{
            
            
            
            myOwnershipavailablePointToolCell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.myownershipAvailablepointTableViewCellIdentifier) as? MyOwnershipAvailablePointTooolTableViewCell
            
            myOwnershipavailablePointToolCell!.getCell()
            return myOwnershipavailablePointToolCell!
            
            
            
        }
        else if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1{
            
            myOwnershipclubIntervalGoldpointscell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.myownershipclubintervalgoldpointdetailcellIdentifier) as? MyownershipClubIntervalGoldPointsTableViewCell
            myOwnershipclubIntervalGoldpointscell!.getCell()
            return myOwnershipclubIntervalGoldpointscell!
            
            
        }
        else if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2{
            
            //***** Register collection cell xib with collection view *****//
            
            /*ownerShiptableView.registerNib(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier:  Constant.ownershipViewController.myownershipVacationResortcellIdentifier)
             */
            
            
            //myOwnershipVacationResortcell = tableView.dequeueReusableCellWithIdentifier(Constant.ownershipViewController.myownershipVacationResortcellIdentifier) as? VacationOrResortTableViewCell
            
            
            
            
            myOwnershipVacationResortcell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.myownershipVacationResortcellIdentifier) as? VacationOrResortTableViewCell
            
            
            myOwnershipVacationResortcell!.getCell()
            
            return myOwnershipVacationResortcell!
            
        }
        else if (indexPath as NSIndexPath).section == 0 {
            ownershipdetailtableviewcell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.ownershipdetailcellIdentifier) as? OwnershipDetailTableViewCell
            var isConstraintUpdate = false
            
            if  (indexPath as NSIndexPath).row == numberOfRowInclubIntervalGoldPointSection - 1 {
                isConstraintUpdate = true
            }
            ownershipdetailtableviewcell!.getCell(isConstraintUpdate)
            
            return ownershipdetailtableviewcell!
        }
            /*else if indexPath.section == 1 && indexPath.row == 0{
             /* myOwnershipVacationResortcell = tableView.dequeueReusableCellWithIdentifier(Constant.ownershipViewController.myownershipVacationResortcellIdentifier) as? VacationOrResortTableViewCell
             myOwnershipVacationResortcell!.getCell()*/
             myOwnershipVacationResortcell = tableView.dequeueReusableCellWithIdentifier(Constant.ownershipViewController.myownershipVacationResortcellIdentifier) as? VacationOrResortTableViewCell
             
             myOwnershipVacationResortcell?.getCell()
             return myOwnershipVacationResortcell!
             
             }*/
        else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0{
            clubpointcell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.ownershipclubpointIdentifier) as? ClubpointTableViewCell
            clubpointcell?.getCell()
            return clubpointcell!
        }
        else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0{
            myOwnershipVacationResortcell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.myownershipVacationResortcellIdentifier) as? VacationOrResortTableViewCell
            myOwnershipVacationResortcell!.getCell()
            
            return myOwnershipVacationResortcell!
        }
        else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 1{
            ownershipdetailtableviewcell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.ownershipdetailcellIdentifier) as? OwnershipDetailTableViewCell
            var isConstraintUpdate = false
            if (indexPath as NSIndexPath).row == numberOfRowInIntervalWeeksSection - 1 {
                isConstraintUpdate = true
            }
            ownershipdetailtableviewcell!.getCell(isConstraintUpdate)
            
            return ownershipdetailtableviewcell!
        }
        else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 2{
            ownershipdetalWithFreedeposit = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.ownershipdetailwithfreedepositIdentifier) as? OwnershipDetailWithFreeDepositTableViewCell
            ownershipdetalWithFreedeposit?.getCell()
            return ownershipdetalWithFreedeposit!
        }
        else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 3{
            ownershipfloatcell = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.ownershipfloatIdentifier) as? OwnershipFloatTableViewCell
            ownershipfloatcell?.getCell(isConstraintUpdate: true)
            return ownershipfloatcell!
        }
        else{
            ownershipdetalWithFreedeposit = tableView.dequeueReusableCell(withIdentifier: Constant.ownershipViewController.ownershipdetailwithfreedepositIdentifier) as? OwnershipDetailWithFreeDepositTableViewCell
            ownershipdetalWithFreedeposit!.getCell()
            return ownershipdetalWithFreedeposit!
            
        }
        
    }
    
    /** Edit Row at indexPath */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var canEdit = false
        
        switch (indexPath as NSIndexPath).section{
        case 0:
            switch (indexPath as NSIndexPath).row{
            case 0:
                canEdit = false
            case 2:
                canEdit = false
            default:
                canEdit = true
                break
            }
        case 1:
            if (indexPath as NSIndexPath).row == 0{
                canEdit = true
            }
            else{
                canEdit = true
            }
        case 2:
            if (indexPath as NSIndexPath).row != 0{
                canEdit = true
            }
            
        default :
            break
        }
        return canEdit
        
    }
}
/*
 
 extension for tableview delegate
 */
extension OwnershipViewController:UITableViewDelegate{
    /** Perform Edit action for row at indexPath */
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let detail = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: Constant.ownershipViewController.vacationForSearchTitle) { (action,index) -> Void in
            //Segue to Float detail view controller
            if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 3{
                self.performSegue(withIdentifier: Constant.ownershipViewController.floatdetailViewControllerIdentifier, sender: self)
            }
            else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0{
                let storyboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                let clubPointselectionViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController)as? ClubPointSelectionViewController
                self.navigationController?.pushViewController(clubPointselectionViewController!, animated: true)
                
            }
            else{
                let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                self.present((storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController)!, animated: true, completion: nil)
            }
            
        }
        detail.backgroundColor = UIColor.brown
        return [detail]
    }
    
    /** Height for Section Header */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight:CGFloat = 90.0
        switch (indexPath as NSIndexPath).section{
        case 0 :
            switch (indexPath as NSIndexPath).row{
            case 0 :
                rowHeight = 90
                break
            case 1 :
                rowHeight = 82
            case 2 :
                rowHeight = 255
            case 3 :
                rowHeight = 85
            default :
                break
            }
            break
        case 1:
            switch (indexPath as NSIndexPath).row{
            case 0 :
                rowHeight = 100
            case 1:
                rowHeight = 112
            default :
                break
            }
        case 2:
            switch (indexPath as NSIndexPath).row{
            case 0 :
                rowHeight = 255
            case 2:
                rowHeight = 145
            default :
                break
            }
            
        default :
            break
        }
        
        return rowHeight
    }
    
    /** set custom view for section */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var sectionHeaderTitle = Constant.ownershipViewController.clubIntervalGoldWeeksSectionHeaderTitle
        switch section{
        case 0 :
            sectionHeaderTitle = Constant.ownershipViewController.clubIntervalGoldWeeksSectionHeaderTitle
            
        case 1:
            sectionHeaderTitle = Constant.ownershipViewController.clubPointsSectionHeaderTitle
        case 2:
            sectionHeaderTitle = Constant.ownershipViewController.intervalWeeksSectionHeaderTitle
        default :
            sectionHeaderTitle = Constant.ownershipViewController.clubIntervalGoldWeeksSectionHeaderTitle
        }
        return viewForSectionHeaderWithTitleLabel(sectionheaderTitle: sectionHeaderTitle)
    }
}

