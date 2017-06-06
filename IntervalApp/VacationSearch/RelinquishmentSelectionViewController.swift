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
        print(Constant.MyClassConstants.floatRemovedArray)
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.vacationSearchRelinquishmentSelect
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        
        self.relinquishmentTableview.estimatedRowHeight = 200
        self.relinquishmentPointsProgramArray.append(Constant.MyClassConstants.relinquishmentProgram)
        
        relinquishmentOpenWeeksArray.removeAll()
        
        for fixed_week_type in Constant.MyClassConstants.relinquishmentOpenWeeks{
            
            
           // if(fixed_week_type.weekNumber != Constant.CommonStringIdentifiers.floatWeek){
                
                if(fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.pointWeek) {
                    
                    if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                        pointOpenWeeksArray.append(fixed_week_type)
                    }
                    else {
                    }
                    
                }
                else if(fixed_week_type.pointsProgramCode != "") {
                    
                    if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!)) || fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.floatWeek) {
                            relinquishmentOpenWeeksArray.append(fixed_week_type)
                    }else if ((fixed_week_type.unit?.lockOffUnits.count)! > 0){
                        let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(fixed_week_type.relinquishmentId!)})
                        let count = results.filter({ $0 == true }).count
                        
                        if(count != ((fixed_week_type.unit?.lockOffUnits.count)! + 1)){
                            print(fixed_week_type.unit!.lockOffUnits.count)
                            relinquishmentOpenWeeksArray.append(fixed_week_type)
                        }
                    }
                }else {
                    if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                        self.intervalOpenWeeksArray.append(fixed_week_type)
                    }
                    else {
                        if((fixed_week_type.unit?.lockOffUnits.count)! > 0){
                            print(fixed_week_type.relinquishmentId!, Constant.MyClassConstants.idUnitsRelinquishmentDictionary.value(forKey: fixed_week_type.relinquishmentId!)!)
                            
                            let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(fixed_week_type.relinquishmentId!)})
                            let count = results.filter({ $0 == true }).count
                            
                            if(count != ((fixed_week_type.unit?.lockOffUnits.count)! + 1)){
                                self.intervalOpenWeeksArray.append(fixed_week_type)
                            }
                            
                            let selectedLockOffArray = Constant.MyClassConstants.idUnitsRelinquishmentDictionary.value(forKey: fixed_week_type.relinquishmentId!)!
                            print(selectedLockOffArray)
                        }
                    }
                }
            /*}else{
                print(fixed_week_type.weekNumber, fixed_week_type.relinquishmentId, fixed_week_type.unit?.lockOffUnits.count)
            }*/
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
        // Adding controller title
        self.title = Constant.ControllerTitles.relinquishmentSelectiongControllerTitle
        
        // Adding navigation back button
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(RelinquishmentSelectionViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Do any additional setup after loadingvare view.
        
        // Omniture tracking with event 61
        
        var cigPoints:Int? = Constant.MyClassConstants.relinquishmentProgram.availablePoints
        if(Constant.MyClassConstants.relinquishmentProgram.availablePoints == nil){
            cigPoints = 0
        }
        
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vacationSearch,
            Constant.omnitureEvars.eVar35 : "\(Constant.omnitureCommonString.cigPoints)\(cigPoints! > 0 ?  Constant.omnitureCommonString.available : Constant.omnitureCommonString.notAvailable ): \(Constant.omnitureCommonString.clubPoints) \(pointOpenWeeksArray.count > 0 ? Constant.omnitureCommonString.available : Constant.omnitureCommonString.notAvailable ): Fixed Open- \(relinquishmentOpenWeeksArray.count) : Float Open- \(intervalOpenWeeksArray.count) : Unredeemed -\(cigPoints!): Pending Request-\(0)"
        ]
        
        
        ADBMobile.trackAction(Constant.omnitureEvents.event61, data: userInfo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func requiredNumberOfSection() -> Int{
        
        if(self.relinquishmentPointsProgramArray.count > 0) {
            if (self.relinquishmentPointsProgramArray[0].availablePoints != nil){
                self.requiredSection = self.requiredSection + 1
            }
            
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
            
            let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(intervalOpenWeeksArray[sender.tag].relinquishmentId!)})
            
            Constant.MyClassConstants.senderRelinquishmentID = intervalOpenWeeksArray[sender.tag].relinquishmentId!
            let count = results.filter({ $0 == true }).count
            
            if(count > 0){
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray{
                    
                    let selectedDict = selectedUnits as! NSMutableDictionary
                    if(intervalOpenWeeksArray[sender.tag].relinquishmentId! == selectedDict.allKeys.first as! String){
                        Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict.object(forKey: intervalOpenWeeksArray[sender.tag].relinquishmentId!)!)
                    }
                    print(Constant.MyClassConstants.userSelectedUnitsArray)
                }
            }else{
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
            }
            getUnitSize((intervalOpenWeeksArray[sender.tag].unit?.lockOffUnits)!)
            
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag]
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            //Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
            
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
        Helper.addServiceCallBackgroundView(view: self.view)
        SVProgressHUD.show()
        Constant.MyClassConstants.matrixDataArray.removeAllObjects()
        DirectoryClient.getResortClubPointsChart(UserContext.sharedInstance.accessToken, resortCode:  (Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortCode)!, onSuccess:{ (ClubPointsChart) in
            
            Constant.MyClassConstants.selectionType = 1
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
            Constant.MyClassConstants.matrixType = ClubPointsChart.type!
            Constant.MyClassConstants.matrixDescription =
                ClubPointsChart.matrices[0].description!
            if(Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeSingle || Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeColor){
                Constant.MyClassConstants.showSegment = false
            }else{
                Constant.MyClassConstants.showSegment = true
            }
            for matrices in ClubPointsChart.matrices {
                let pointsDictionary = NSMutableDictionary()
                for grids in matrices.grids {
                    
                    Constant.MyClassConstants.fromdatearray.add(grids.fromDate!)
                    Constant.MyClassConstants.todatearray.add(grids.toDate!)
                    
                    for rows in grids.rows
                    {
                        Constant.MyClassConstants.labelarray.add(rows.label!)
                    }
                    let dictKey = "\(grids.fromDate!) - \(grids.toDate!)"
                    pointsDictionary.setObject(grids.rows, forKey: String(describing: dictKey) as NSCopying)
                }
                Constant.MyClassConstants.matrixDataArray.add(pointsDictionary)
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
                
                let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(relinquishmentOpenWeeksArray[sender.tag - 1].relinquishmentId!)})
                
                Constant.MyClassConstants.senderRelinquishmentID = relinquishmentOpenWeeksArray[sender.tag - 1].relinquishmentId!
                let count = results.filter({ $0 == true }).count
                
                if(count > 0){
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                    for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray{
                        
                        let selectedDict = selectedUnits as! NSMutableDictionary
                        if(relinquishmentOpenWeeksArray[sender.tag - 1].relinquishmentId! == selectedDict.allKeys.first as! String){
                            Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict.object(forKey: relinquishmentOpenWeeksArray[sender.tag - 1].relinquishmentId!)!)
                        }
                    }
                }else{
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                }
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
    
    func addClubFloatWeek(_ sender:IUIKButton){
        Constant.MyClassConstants.selectedFloatWeek = OpenWeeks()
        if(relinquishmentOpenWeeksArray.count > 0){
            Helper.navigateToViewController(senderViewController: self, floatResortDetails: relinquishmentOpenWeeksArray[sender.tag - 1].resort!)
            Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
        }else if(intervalOpenWeeksArray.count > 0){
            Helper.navigateToViewController(senderViewController: self, floatResortDetails: intervalOpenWeeksArray[sender.tag - 1].resort!)
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag - 1]
        }else{
            
        }
        
        for floatWeek in Constant.MyClassConstants.whatToTradeArray{
            let floatWeekTraversed = floatWeek as! OpenWeeks
            if(floatWeekTraversed.isFloat && Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId == floatWeekTraversed.relinquishmentID){
                Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
            }
        }
        for floatWeek in Constant.MyClassConstants.floatRemovedArray{
            let floatWeekTraversed = floatWeek as! OpenWeeks
            if(floatWeekTraversed.isFloat && Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId == floatWeekTraversed.relinquishmentID){
                Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
            }
        }
        print(Constant.MyClassConstants.selectedFloatWeek)
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
        }else if(indexPath.section == 1 || indexPath.section == 3){
            
            var openWeek:OpenWeek!
            if(indexPath.section == 1 ) {
                
                openWeek = relinquishmentOpenWeeksArray[indexPath.row]
                
                if(openWeek.weekNumber == Constant.CommonStringIdentifiers.floatWeek){
                    
                    if(Constant.MyClassConstants.realmOpenWeeksID.contains(openWeek.relinquishmentId!)) {
                        
                        let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.floatWeekSavedCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                        
                        if(Constant.MyClassConstants.floatRemovedArray.count == 0){
                            
                            cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                            cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType:openWeek.unit!.kitchenType!))"
                            cell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                            if(indexPath.section == 1){
                                cell.addButton.tag = indexPath.row + indexPath.section
                            }else{
                                cell.addButton.tag = indexPath.row + 1
                            }
                            cell.addButton.addTarget(self, action:  #selector(RelinquishmentSelectionViewController.addClubFloatWeek(_:)), for: .touchUpInside)
                            
                            return cell
                            
                        }
                        else{
                            
                            for openWk in Constant.MyClassConstants.floatRemovedArray{
                                
                                let openWk1 = openWk as! OpenWeeks
                                let floatWeek = openWk1
                                if(openWeek.relinquishmentId == openWk1.relinquishmentID ) {
                                    
                                    print(floatWeek)
                                    
                                    cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                                    //cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                                    if(indexPath.section == 1){
                                        cell.addButton.tag = indexPath.row + indexPath.section
                                    }else{
                                        cell.addButton.tag = indexPath.row + 1
                                    }
                                    cell.addButton.addTarget(self, action:  #selector(RelinquishmentSelectionViewController.addClubFloatWeek(_:)), for: .touchUpInside)
                                }
                            }
                            
                            return cell
                        }
                    }
                    else {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.floatWeekUnsavedCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                        cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                        cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                        if(indexPath.section == 1){
                            cell.addButton.tag = indexPath.row + indexPath.section
                        }else{
                            cell.addButton.tag = indexPath.row + 1
                        }
                        cell.addButton.addTarget(self, action:  #selector(RelinquishmentSelectionViewController.addClubFloatWeek(_:)), for: .touchUpInside)
                        
                        return cell
                    }
                    
                }
                
                else {
                    
                      let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.clubPointCell, for: indexPath) as! clubPointCell
                    
                    return cell
                }
            }
            else {
                
                openWeek = intervalOpenWeeksArray[indexPath.row]
                 let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.clubPointCell, for: indexPath) as! clubPointCell
                
                return cell
            }
          
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
    
    func doneButtonClicked(selectedUnitsArray:NSMutableArray) {
        //Realm local storage for selected relinquishment
        
        for unitDetails1 in selectedUnitsArray{
            
            let unitSizeFullDetail1 = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[(unitDetails1 as! Int - 1000)] as! String
            
            if(!Constant.MyClassConstants.userSelectedStringArray.contains(unitSizeFullDetail1)){
                
                let storedata = OpenWeeksStorage()
                let Membership = UserContext.sharedInstance.selectedMembership
                let relinquishmentList = TradeLocalData()
                
                let selectedOpenWeek = OpenWeeks()
                selectedOpenWeek.isLockOff = true
                selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber!
                selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
                selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!
                
                let resort = ResortList()
                resort.resortName = (Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName)!
                
                let resortUnitDetails = ResortUnitDetails()
                let unitSizeFullDetail = (Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[(unitDetails1 as! Int - 1000)] as! String).components(separatedBy: ",")
                
                resortUnitDetails.unitSize = unitSizeFullDetail[0]
                resortUnitDetails.kitchenType = unitSizeFullDetail[1]
                
                selectedOpenWeek.unitDetails.append(resortUnitDetails)
                selectedOpenWeek.resort.append(resort)
                
                relinquishmentList.openWeeks.append(selectedOpenWeek)
                
                storedata.openWeeks.append(relinquishmentList)
                storedata.membeshipNumber = Membership!.memberNumber!
                
                let realm = try! Realm()
                try! realm.write {
                    realm.add(storedata)
                }
            }
        }
        
        var addedUnitsArray = [String]()
        for unitValue in selectedUnitsArray{
            let unitSizeFullDetail = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[(unitValue as! Int - 1000)] as! String
            addedUnitsArray.append(unitSizeFullDetail)
        }
        let storedData = Helper.getLocalStorageWherewanttoTrade()
        
        if(storedData.count > 0) {
            for obj in storedData {
                let openWeeks = obj.openWeeks
                for openWk in openWeeks {
                    if(openWk.openWeeks.count > 0){
                        
                        for object in openWk.openWeeks {
                            if(object.relinquishmentID == Constant.MyClassConstants.senderRelinquishmentID){
                                let unitInOpenWeek = "\(object.unitDetails[0].unitSize),\(object.unitDetails[0].kitchenType)"
                                if(!addedUnitsArray.contains(unitInOpenWeek)){
                                    let realm = try! Realm()
                                    try! realm.write {
                                        realm.delete(obj)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Open vacation search view controller
        var viewcontroller:UIViewController
        if (Constant.RunningDevice.deviceIdiom == .phone) {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
        }
        else{
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
        }
        
        
        //***** creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.0
        transition.timingFunction = timeFunc
        viewcontroller.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        UIApplication.shared.keyWindow?.rootViewController = viewcontroller
    }
    
}
