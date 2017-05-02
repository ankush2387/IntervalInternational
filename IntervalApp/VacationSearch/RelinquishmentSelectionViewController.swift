//
//  RelinquishmentSelectionViewController.swift
//  IntervalApp
//
//  Created by Chetu on 10/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//
import UIKit
import IntervalUIKit

import DarwinSDK
import RealmSwift
import SVProgressHUD

class RelinquishmentSelectionViewController: UIViewController {
    
    var relinquishmentPointsProgramArray = [PointsProgram]()
    var relinquishmentOpenWeeksArray = [OpenWeek]()
    var pointOpenWeeksArray = [OpenWeek]()
    var intervalOpenWeeksArray = [OpenWeek]()
    var openWkToRemoveArray:NSMutableArray!
    var requiredSection = 0
    var masterUnitSize = ""
    
    //Outlets
    @IBOutlet weak var relinquishmentTableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.relinquishmentTableview.estimatedRowHeight = 200
        self.relinquishmentPointsProgramArray.append(Constant.MyClassConstants.relinquishmentProgram)
        
        relinquishmentOpenWeeksArray.removeAll()
        
        for fixed_week_type in Constant.MyClassConstants.relinquishmentOpenWeeks{
            
            if(fixed_week_type.weekNumber != Constant.CommonStringIdentifiers.floatWeek){
                
                if(fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.pointWeek) {
                    
                    if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                        pointOpenWeeksArray.append(fixed_week_type)
                    }
                    else {
                        
                    }
                    
                }
                else if(fixed_week_type.pointsProgramCode != ""){
                    
                    if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                        relinquishmentOpenWeeksArray.append(fixed_week_type)
                    }
                    else {
                        
                    }
                    
                }
                else {
                    
                    if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                        self.intervalOpenWeeksArray.append(fixed_week_type)
                    }
                    else {
                    }
                }
            }
        }
        if(Constant.MyClassConstants.relinquishmentIdArray.count > 0 && self.relinquishmentPointsProgramArray[0].relinquishmentId != nil){
            if(Constant.MyClassConstants.relinquishmentIdArray.contains(self.relinquishmentPointsProgramArray[0].relinquishmentId!))
            {
                self.relinquishmentPointsProgramArray.remove(at: 0)
            }
        }
        if(self.requiredNumberOfSection() == 0) {
            
            SimpleAlert.alert(self, title:Constant.ControllerTitles.relinquishmentSelectiongControllerTitle , message: Constant.MyClassConstants.noRelinquishmentavailable)
        }
        
        
        if(self.relinquishmentTableview != nil) {
            relinquishmentTableview.reloadData()
        }
        //adding controller title
        self.title = Constant.ControllerTitles.relinquishmentSelectiongControllerTitle
        
        //adding navigation back button
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(RelinquishmentSelectionViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Do any additional setup after loadingvare view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func requiredNumberOfSection() -> Int{
        
        if(self.relinquishmentPointsProgramArray[0].availablePoints != nil) {
            self.requiredSection = self.requiredSection + 1
            
        }
        
        if(relinquishmentOpenWeeksArray.count > 0) {
            
            self.requiredSection = self.requiredSection + 1
        }
        if(pointOpenWeeksArray.count > 0) {
            
            self.requiredSection = self.requiredSection + 1
        }
        if(intervalOpenWeeksArray.count > 0) {
            self.requiredSection = self.requiredSection + 1
        }
        
        return self.requiredSection
    }
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func availablePointToolButtonPressed(_ sender:IUIKButton) {
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.availablePointToolViewController) as! AvailablePointToolViewController
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
        
    }
    
    func addIntervalWeekButtonPressed(_ sender:IUIKButton) {

        if((intervalOpenWeeksArray[sender.tag].unit?.lockOffUnits.count)! > 0){
            Constant.ControllerTitles.bedroomSizeViewController = Constant.MyClassConstants.relinquishmentTitle
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: (intervalOpenWeeksArray[sender.tag].unit!.unitSize)!)), \(Helper.getKitchenEnums(kitchenType: (intervalOpenWeeksArray[sender.tag].unit!.kitchenType)!)) Sleeps \(String(describing: intervalOpenWeeksArray[sender.tag].unit!.publicSleepCapacity))"
            getUnitSize((intervalOpenWeeksArray[sender.tag].unit?.lockOffUnits)!)
            
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag]
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
            
            var mainStoryboard = UIStoryboard()
            if(Constant.RunningDevice.deviceIdiom == .pad) {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
            }
            else {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
            }
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as! BedroomSizeViewController
            viewController.delegate = self
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.present(viewController, animated: true, completion: nil)
        }else{
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag]
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
            
            //Realm local storage for selected relinquishment
            let storedata = OpenWeeksStorage()
            let Membership = UserContext.sharedInstance.selectedMembership
            let relinquishmentList = TradeLocalData()
            
            let selectedOpenWeek = OpenWeeks()
            selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber!
            selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
            selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!
            let resort = ResortList()
            resort.resortName = (Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName)!
            
            selectedOpenWeek.resort.append(resort)
            relinquishmentList.openWeeks.append(selectedOpenWeek)
            storedata.openWeeks.append(relinquishmentList)
            storedata.membeshipNumber = Membership!.memberNumber!
            let realm = try! Realm()
            try! realm.write {
                realm.add(storedata)
            }
            
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    func addClubPointButtonPressed(_ sender:IUIKButton) {
        
        Constant.MyClassConstants.relinquishmentSelectedWeek = pointOpenWeeksArray[sender.tag]
        
        if(Constant.MyClassConstants.relinquishmentSelectedWeek.pointsMatrix == false) {
            
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
            
            //Realm local storage for selected relinquishment
            let storedata = OpenWeeksStorage()
            let Membership = UserContext.sharedInstance.selectedMembership
            let relinquishmentList = TradeLocalData()
            
            let selectedOpenWeek = OpenWeeks()
            selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber!
            selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
            selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!
            let resort = ResortList()
            resort.resortName = (Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName)!
            
            selectedOpenWeek.resort.append(resort)
            relinquishmentList.openWeeks.append(selectedOpenWeek)
            storedata.openWeeks.append(relinquishmentList)
            storedata.membeshipNumber = Membership!.memberNumber!
            let realm = try! Realm()
            try! realm.write {
                realm.add(storedata)
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            // Helper.addServiceCallBackgroundView(view: self.view)
            //SVProgressHUD.show()
            DirectoryClient.getResortClubPointsChart(UserContext.sharedInstance.accessToken, resortCode:  (Constant.MyClassConstants.relinquishmentSelectedWeek.resort!.resortCode!), onSuccess:{ (ClubPointsChart) in
                
                
                for matrices in ClubPointsChart.matrices {
                    
                    for grids in matrices.grids {
                        
                        Constant.MyClassConstants.fromdatearray.add(grids.fromDate!)
                        Constant.MyClassConstants.todatearray.add(grids.toDate!)
                        
                        for rows in grids.rows
                        {
                            Constant.MyClassConstants.labelarray.add(rows.label!)
                        }
                    }
                    
                    print(Constant.MyClassConstants.fromdatearray)
                    print(Constant.MyClassConstants.labelarray)
                }
                
                
                let storyboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                let clubPointselectionViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController)as? ClubPointSelectionViewController
                self.navigationController?.pushViewController(clubPointselectionViewController!, animated: true)
                
            }, onError:{ (error) in
                
                Helper.removeServiceCallBackgroundView(view: self.view)
                SVProgressHUD.dismiss()
                print(error.description)
            })
            
            
        }
        
        
    }
    func addAvailablePoinButtonPressed(_ sender:IUIKButton) {
        if(sender.tag == 0){
            
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentProgram)
            Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentProgram.relinquishmentId!)
            //Realm local storage for selected relinquishment
            let storedata = OpenWeeksStorage()
            let Membership = UserContext.sharedInstance.selectedMembership
            let relinquishmentList = TradeLocalData()
            let rlmPProgram = rlmPointsProgram()
            
            rlmPProgram.availablePoints = Constant.MyClassConstants.relinquishmentProgram.availablePoints!
            rlmPProgram.code = Constant.MyClassConstants.relinquishmentProgram.code!
            
            rlmPProgram.relinquishmentId = Constant.MyClassConstants.relinquishmentProgram.relinquishmentId!
            
            relinquishmentList.pProgram.append(rlmPProgram)
            storedata.openWeeks.append(relinquishmentList)
            storedata.membeshipNumber = Membership!.memberNumber!
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(storedata)
            }
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }else{
            if((relinquishmentOpenWeeksArray[sender.tag - 1].unit?.lockOffUnits.count)! > 0){
                Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
                masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: (relinquishmentOpenWeeksArray[sender.tag - 1].unit!.unitSize)!)), \(Helper.getKitchenEnums(kitchenType: (relinquishmentOpenWeeksArray[sender.tag - 1].unit!.kitchenType)!)) Sleeps \(String(describing: relinquishmentOpenWeeksArray[sender.tag - 1].unit!.publicSleepCapacity))"
                getUnitSize((relinquishmentOpenWeeksArray[sender.tag - 1].unit?.lockOffUnits)!)
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
                Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
                Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
                
                var mainStoryboard = UIStoryboard()
                if(Constant.RunningDevice.deviceIdiom == .pad) {
                    mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
                }
                else {
                    mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                }
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as! BedroomSizeViewController
                viewController.delegate = self
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController!.present(viewController, animated: true, completion: nil)
            }else{
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
                Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
                Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
                
                //Realm local storage for selected relinquishment
                let storedata = OpenWeeksStorage()
                let Membership = UserContext.sharedInstance.selectedMembership
                let relinquishmentList = TradeLocalData()
                
                let selectedOpenWeek = OpenWeeks()
                selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber!
                selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
                selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!
                let resort = ResortList()
                resort.resortName = (Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName)!
                
                selectedOpenWeek.resort.append(resort)
                relinquishmentList.openWeeks.append(selectedOpenWeek)
                storedata.openWeeks.append(relinquishmentList)
                storedata.membeshipNumber = Membership!.memberNumber!
                let realm = try! Realm()
                try! realm.write {
                    realm.add(storedata)
                }
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func getUnitSize(_ unitSize:[InventoryUnit]) {
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
        let unitSizeRelinquishment = unitSize
        var unitString = ""
        for unit in unitSizeRelinquishment{
            unitString = "\(Helper.getBedroomNumbers(bedroomType: unit.unitSize!)), \(Helper.getKitchenEnums(kitchenType: unit.kitchenType!)) Sleeps \(unit.publicSleepCapacity)"
            
            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(unitString)
        }
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(masterUnitSize)
    }
}

extension RelinquishmentSelectionViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if(section == 0 || section == 2 || section == 3) {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
            let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width - 30, height: 30))
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            if(section == 0) {
                headerTextLabel.text = Constant.ownershipViewController.clubIntervalGoldWeeksSectionHeaderTitle
            }
            else if(section == 2){
                
                headerTextLabel.text = Constant.ownershipViewController.clubPointsSectionHeaderTitle
            }
            else {
                
                headerTextLabel.text = Constant.ownershipViewController.intervalWeeksSectionHeaderTitle
            }
            headerTextLabel.textColor = UIColor.darkGray
            headerTextLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
            headerView.addSubview(headerTextLabel)
            return headerView
        }
        else {
            
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            if (self.relinquishmentPointsProgramArray[0].availablePoints == nil){
                return 0
            }
            else{
                return 30
            }
            
        case 2:
            if(self.pointOpenWeeksArray.count > 0) {
                return 30
            }
            else {
                return 0
            }
            
        case 3:
            if(self.intervalOpenWeeksArray.count > 0) {
                return 30
            }
            else {
                return 0
            }
            
        default:
            return 0
        }
    }
}

extension RelinquishmentSelectionViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            
        case 0:
            if (self.relinquishmentPointsProgramArray.count == 1 && self.relinquishmentPointsProgramArray[0].availablePoints == nil) {
                return 0
            }
            else{
                return self.relinquishmentPointsProgramArray.count
            }
            
        case 1:
            return relinquishmentOpenWeeksArray.count
            
        case 2:
            return pointOpenWeeksArray.count
            
        case 3:
            return intervalOpenWeeksArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if(indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionCIGCell, for: indexPath) as! RelinquishmentSelectionCIGCell
            cell.availablePointToolButton.addTarget(self, action: #selector(RelinquishmentSelectionViewController.availablePointToolButtonPressed(_:)), for: .touchUpInside)
            cell.addAvailablePointButton.addTarget(self, action:  #selector(RelinquishmentSelectionViewController.addAvailablePoinButtonPressed(_:)), for: .touchUpInside)
            cell.addAvailablePointButton.tag = indexPath.section + indexPath.row
            if (Constant.MyClassConstants.relinquishmentProgram.availablePoints != nil) {
                let largeNumber = Constant.MyClassConstants.relinquishmentProgram.availablePoints!
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedString = numberFormatter.string(for: largeNumber)
                cell.availablePointValueLabel.text = formattedString
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if(indexPath.section == 1 || indexPath.section == 3){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionOpenWeeksCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
            
            var openWeek:OpenWeek!
            if(indexPath.section == 1 ) {
                
                openWeek = relinquishmentOpenWeeksArray[indexPath.row]
            }
            else {
                
                openWeek = intervalOpenWeeksArray[indexPath.row]
            }
            let units = openWeek.unit
            cell.resortName.text = openWeek.resort?.resortName!
            //cell.resortName.text = "Westwood"
            var bedroomSize = ""
            var kitchenType = ""
            
            if let roomSize = UnitSize(rawValue: (units?.unitSize!)!) {
                
                bedroomSize =  Helper.getBrEnums(brType: roomSize.rawValue)
            }
            
            if let kitchenSize = KitchenType(rawValue: (units?.kitchenType!)!) {
                kitchenType = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
            }
            
            cell.bedroomSizeAndKitchenClient.text = "\(bedroomSize) \(kitchenType)"
            let totalSleep = "Sleeps " + String((units?.publicSleepCapacity)! + (units?.privateSleepCapacity)!)
            let privateSleep = " total, " + (String(describing: units!.privateSleepCapacity)) + " Private"
            cell.totalSleepAndPrivate.text = "\(totalSleep) \(privateSleep)"
            
            if (units?.lockOffUnits.count) != 0{
                cell.bedroomSizeAndKitchenClient.text = "Lock off capable."
                cell.totalSleepAndPrivate.text = ""
            }
            
            cell.yearLabel.text = "\(openWeek.relinquishmentYear!)"
            
            if(indexPath.section == 1) {
                cell.addButton.tag = indexPath.row + indexPath.section
                cell.addButton.addTarget(self, action:  #selector(RelinquishmentSelectionViewController.addAvailablePoinButtonPressed(_:)), for: .touchUpInside)
            }
            else {
                
                cell.addButton.tag = indexPath.row
                cell.addButton.addTarget(self, action:  #selector(RelinquishmentSelectionViewController.addIntervalWeekButtonPressed(_:)), for: .touchUpInside)
            }
            let date = openWeek.checkInDates
            if(date.count > 0) {
                
                let dateString = date[0]
                let date =  Helper.convertStringToDate(dateString: dateString, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: date)
                let day = myComponents.day!
                var month = ""
                if(day < 10) {
                    month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                }
                else {
                    month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                }
                
                cell.dayAndDateLabel.text = month.uppercased()
                
            }
            else {
                
                cell.dayAndDateLabel.text = " "
            }
            cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber!))"
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else {
            
            let openWeek = pointOpenWeeksArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.clubPointCell, for: indexPath) as! clubPointCell
            
            cell.nameLabel.text = openWeek.resort?.resortName!
            cell.yearLabel.text = "\(openWeek.relinquishmentYear!)"
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addClubPointButtonPressed(_:)), for: .touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}

extension RelinquishmentSelectionViewController:BedroomSizeViewControllerDelegate {
    
    func doneButtonClicked() {
        //Realm local storage for selected relinquishment
        let storedata = OpenWeeksStorage()
        let Membership = UserContext.sharedInstance.selectedMembership
        let relinquishmentList = TradeLocalData()
        
        let selectedOpenWeek = OpenWeeks()
        selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber!
        selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
        selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!
        let resort = ResortList()
        resort.resortName = (Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName)!
        
        selectedOpenWeek.resort.append(resort)
        relinquishmentList.openWeeks.append(selectedOpenWeek)
        storedata.openWeeks.append(relinquishmentList)
        storedata.membeshipNumber = Membership!.memberNumber!
        let realm = try! Realm()
        try! realm.write {
            realm.add(storedata)
        }
        
        // Open vacation search view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
        
        //***** creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.50
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
}
