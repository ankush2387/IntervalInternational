//
//  OwnershipViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/29/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import RealmSwift
import SVProgressHUD

class OwnershipViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var ownerShiptableView: UITableView!
    //Class Variables
    fileprivate let numberOfSection = 5
    //private var numberOfrows = 5
    fileprivate let numberOfRowInclubIntervalGoldPointSection = 5
    fileprivate let numberOfRowInClubPointSection = 1
    fileprivate let numberOfRowInIntervalWeeksSection = 4
    
    
    var relinquishmentPointsProgramArray = [PointsProgram]()
    var relinquishmentOpenWeeksArray = [OpenWeek]()
    var pointOpenWeeksArray = [OpenWeek]()
    var intervalOpenWeeksArray = [OpenWeek]()
    var openWkToRemoveArray:NSMutableArray!
    var requiredSection = 0
    var masterUnitSize = ""
    var masterUnitNumber = ""
    var cellHeight: CGFloat = 80
    var relinquishmentDeposit = [Deposit]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
            }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.showProgressBar(senderView: self)
        self.title = Constant.ControllerTitles.ownershipViewController
        ownerShiptableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.searchResultContentTableCell)
        
        ExchangeClient.getMyUnits(UserContext.sharedInstance.accessToken, onSuccess: { (Relinquishments) in
            
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if(Relinquishments.pointsProgram != nil){
                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram!
                
                if (Relinquishments.pointsProgram!.availablePoints != nil) {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram!.availablePoints!
                }
                
            }
            self.getRelinquishmentsInfo()
            self.ownerShiptableView.reloadData()
            Helper.hideProgressBar(senderView: self)
            
        }, onError: {(error) in
            Helper.hideProgressBar(senderView: self)
        })


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayMenuButton()
        ownerShiptableView.reloadData()
    }
    
    fileprivate func getRelinquishmentsInfo() {
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.vacationSearchRelinquishmentSelect
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        self.ownerShiptableView.estimatedRowHeight = 200
        self.relinquishmentPointsProgramArray.append(Constant.MyClassConstants.relinquishmentProgram)
        
        relinquishmentOpenWeeksArray.removeAll()
        
        //Get Deposits to display
        verifyDepositsToDisplay()
        
        //Array to get details of unit details saved by user for lock-off capable.
        Constant.MyClassConstants.saveLockOffDetailsArray.removeAllObjects()
        
        for fixed_week_type in Constant.MyClassConstants.relinquishmentOpenWeeks{
            
            if(fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.pointWeek) {
                
                if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                    pointOpenWeeksArray.append(fixed_week_type)
                }
                else {
                }
                
            }
            else if(fixed_week_type.pointsProgramCode != "" || fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.floatWeek) {
                
                if ((fixed_week_type.unit?.lockOffUnits.count)! > 0){
                    let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(fixed_week_type.relinquishmentId!)})
                    let count = results.filter({ $0 == true }).count
                    
                    if(count != ((fixed_week_type.unit?.lockOffUnits.count)! + 1)){
                        print(fixed_week_type.unit!.lockOffUnits.count)
                        print(Constant.MyClassConstants.whatToTradeArray,Constant.MyClassConstants.floatRemovedArray)
                        if(fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.floatWeek){
                            if(Constant.MyClassConstants.whatToTradeArray.count > 0){
                                for traversedOpenWeek in Constant.MyClassConstants.whatToTradeArray{
                                    if let floatLockOffWeek = traversedOpenWeek as? OpenWeeks {
                                        if(floatLockOffWeek.relinquishmentID == fixed_week_type.relinquishmentId){
                                            Constant.MyClassConstants.saveLockOffDetailsArray.add("\(floatLockOffWeek.floatDetails[0].unitNumber),\(floatLockOffWeek.floatDetails[0].unitSize)")
                                        }
                                    } else {
                                        let floatLockOffWeek = traversedOpenWeek as! Deposits
                                        if(floatLockOffWeek.relinquishmentID == fixed_week_type.relinquishmentId){
                                            Constant.MyClassConstants.saveLockOffDetailsArray.add("\(floatLockOffWeek.floatDetails[0].unitNumber),\(floatLockOffWeek.floatDetails[0].unitSize)")
                                        }
                                    }
                                    
                                    
                                }
                            }
                            
                            if(Constant.MyClassConstants.floatRemovedArray.count > 0){
                                for traversedOpenWeek in Constant.MyClassConstants.floatRemovedArray{
                                    let floatLockOffWeek = traversedOpenWeek as! OpenWeeks
                                    if(floatLockOffWeek.relinquishmentID == fixed_week_type.relinquishmentId){
                                        Constant.MyClassConstants.saveLockOffDetailsArray.add("\(floatLockOffWeek.floatDetails[0].unitNumber),\(floatLockOffWeek.floatDetails[0].unitSize)")
                                    }
                                }
                            }
                        }
                        relinquishmentOpenWeeksArray.append(fixed_week_type)
                    }
                }else if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(fixed_week_type.relinquishmentId!))) {
                    relinquishmentOpenWeeksArray.append(fixed_week_type)
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
        
        
        if(self.ownerShiptableView != nil) {
            ownerShiptableView.reloadData()
        }
    }
    
    fileprivate func verifyDepositsToDisplay(){
        for fixed_week_type in Constant.MyClassConstants.relinquishmentDeposits{
            guard let relinquinshmentID = fixed_week_type.relinquishmentId else { return }
            
            if(!(Constant.MyClassConstants.relinquishmentIdArray.contains(relinquinshmentID))) {
                self.relinquishmentDeposit.append(fixed_week_type)
            }
        }
    }
    
    fileprivate func requiredNumberOfSection() -> Int{
        
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
        
        if relinquishmentDeposit.count > 0 {
            self.requiredSection += 1
        }
        
        return self.requiredSection
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
    
    func availablePointToolButtonPressed() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.availablePointToolViewController) as! AvailablePointToolViewController
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func addAvailablePoinButtonPressed(senderTag: Int) {
        if(senderTag == 0) {
            Helper.deleteObjectsFromLocalStorage()
            
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
            
            initiateSearch()
            
        }else{
            if((relinquishmentOpenWeeksArray[senderTag - 1].unit?.lockOffUnits.count)! > 0){
                Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
                masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: (relinquishmentOpenWeeksArray[senderTag - 1].unit!.unitSize)!)), \(Helper.getKitchenEnums(kitchenType: (relinquishmentOpenWeeksArray[senderTag - 1].unit!.kitchenType)!)) Sleeps \(String(describing: relinquishmentOpenWeeksArray[senderTag - 1].unit!.publicSleepCapacity))"
                masterUnitNumber = relinquishmentOpenWeeksArray[senderTag - 1].unit!.unitNumber!
                
                let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(relinquishmentOpenWeeksArray[senderTag - 1].relinquishmentId!)})
                
                Constant.MyClassConstants.senderRelinquishmentID = relinquishmentOpenWeeksArray[senderTag - 1].relinquishmentId!
                let count = results.filter({ $0 == true }).count
                
                if(count > 0){
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                    for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray{
                        
                        let selectedDict = selectedUnits as! NSMutableDictionary
                        if(relinquishmentOpenWeeksArray[senderTag - 1].relinquishmentId! == selectedDict.allKeys.first as! String){
                            Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict.object(forKey: relinquishmentOpenWeeksArray[senderTag - 1].relinquishmentId!)!)
                        }
                    }
                }else{
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                }
                getUnitSize((relinquishmentOpenWeeksArray[senderTag - 1].unit?.lockOffUnits)!)
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[senderTag - 1]
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
                viewController.isOnwershipSelection = true
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController!.present(viewController, animated: true, completion: nil)
            }else{
                 Helper.deleteObjectsFromLocalStorage()
                
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[senderTag - 1]
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
                
                initiateSearch()
            }
        }
    }
    
    func addIntervalWeekButtonPressed(senderTag: Int) {
        if((intervalOpenWeeksArray[senderTag].unit?.lockOffUnits.count)! > 0){
            Constant.ControllerTitles.bedroomSizeViewController = Constant.MyClassConstants.relinquishmentTitle
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: (intervalOpenWeeksArray[senderTag].unit!.unitSize)!)), Sleeps \(String(describing: intervalOpenWeeksArray[senderTag].unit!.publicSleepCapacity))"
            masterUnitNumber = intervalOpenWeeksArray[senderTag].unit!.unitNumber!
            
            let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(intervalOpenWeeksArray[senderTag].relinquishmentId!)})
            
            Constant.MyClassConstants.senderRelinquishmentID = intervalOpenWeeksArray[senderTag].relinquishmentId!
            let count = results.filter({ $0 == true }).count
            
            if(count > 0){
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray{
                    
                    let selectedDict = selectedUnits as! NSMutableDictionary
                    if(intervalOpenWeeksArray[senderTag].relinquishmentId! == selectedDict.allKeys.first as! String){
                        Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict.object(forKey: intervalOpenWeeksArray[senderTag].relinquishmentId!)!)
                    }
                    print(Constant.MyClassConstants.userSelectedUnitsArray)
                }
            }else{
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
            }
            getUnitSize((intervalOpenWeeksArray[senderTag].unit?.lockOffUnits)!)
            
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[senderTag]
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            
            var mainStoryboard = UIStoryboard()
            if(Constant.RunningDevice.deviceIdiom == .pad) {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
            }
            else {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
            }
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as! BedroomSizeViewController
            viewController.delegate = self
            viewController.isOnwershipSelection = true
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.present(viewController, animated: true, completion: nil)
        }else{
            Helper.deleteObjectsFromLocalStorage()
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[senderTag]
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
            
            initiateSearch()
        }
    }
    
    func addClubPointButtonPressed(senderTag: Int) {
        Constant.MyClassConstants.relinquishmentSelectedWeek = pointOpenWeeksArray[senderTag]
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
    
    func addClubFloatWeek(senderTag: Int){
        Constant.MyClassConstants.selectedFloatWeek = OpenWeeks()
        if(relinquishmentOpenWeeksArray.count > 0){
            Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[senderTag - 1]
        }else if(intervalOpenWeeksArray.count > 0){
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[senderTag - 1]
        }else{
            
        }
        if((Constant.MyClassConstants.relinquishmentSelectedWeek.unit?.lockOffUnits.count)! > 0){
            Constant.ControllerTitles.bedroomSizeViewController = Constant.MyClassConstants.relinquishmentTitle
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: (Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.unitSize)!)), Sleeps \(String(describing: Constant.MyClassConstants.relinquishmentSelectedWeek.unit!.publicSleepCapacity))"
            
            let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)})
            
            Constant.MyClassConstants.senderRelinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
            let count = results.filter({ $0 == true }).count
            
            if(count > 0){
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray{
                    
                    let selectedDict = selectedUnits as! NSMutableDictionary
                    print(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!,selectedDict.allKeys.first!,selectedDict)
                    if(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId! == selectedDict.allKeys.first as! String){
                        Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict.object(forKey: Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)!)
                        print(Constant.MyClassConstants.userSelectedUnitsArray)
                    }
                }
            }else{
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
            }
            getUnitSize((Constant.MyClassConstants.relinquishmentSelectedWeek.unit?.lockOffUnits)!)
            
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.floatViewController
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
            viewController.isOnwershipSelection = true
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.floatViewController
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.present(viewController, animated: true, completion: nil)
        }else{
            
            if(relinquishmentOpenWeeksArray.count > 0){
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[senderTag - 1]
                Helper.navigateToViewController(senderViewController: self, floatResortDetails: relinquishmentOpenWeeksArray[senderTag - 1].resort!, isFromLockOff: false)
            }else if(intervalOpenWeeksArray.count > 0){
                Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[senderTag - 1]
                Helper.navigateToViewController(senderViewController: self, floatResortDetails: intervalOpenWeeksArray[senderTag - 1].resort!, isFromLockOff: false)
            }else{
                
            }
            
            for floatWeek in Constant.MyClassConstants.whatToTradeArray{
                let floatWeekTraversed = floatWeek as! OpenWeeks
                if(floatWeekTraversed.isFloat && Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId! == floatWeekTraversed.relinquishmentID){
                    Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                    Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
                }
            }
            for floatWeek in Constant.MyClassConstants.floatRemovedArray{
                let floatWeekTraversed = floatWeek as! OpenWeeks
                if(floatWeekTraversed.isFloatRemoved && Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId! == floatWeekTraversed.relinquishmentID){
                    Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                    Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
                }
            }
            print(Constant.MyClassConstants.selectedFloatWeek)
        }
    }
    
    func addDeposits(senderTag: Int) {
        Helper.deleteObjectsFromLocalStorage()
        Constant.MyClassConstants.relinquismentSelectedDeposit = relinquishmentDeposit[senderTag]
        Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
        Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquismentSelectedDeposit)
        Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquismentSelectedDeposit.relinquishmentId!)
        
        //Realm local storage for selected relinquishment
        let storedata = OpenWeeksStorage()
        let Membership = UserContext.sharedInstance.selectedMembership
        let relinquishmentList = TradeLocalData()
        
        let selectedOpenWeek = Deposits()
        selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquismentSelectedDeposit.weekNumber!
        selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquismentSelectedDeposit.relinquishmentId!
        selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquismentSelectedDeposit.relinquishmentYear!
        let resort = ResortList()
        if let name = Constant.MyClassConstants.relinquismentSelectedDeposit.resort?.resortName {
            resort.resortName = name
        }
        
        selectedOpenWeek.resort.append(resort)
        relinquishmentList.deposits.append(selectedOpenWeek)
        storedata.openWeeks.append(relinquishmentList)
        storedata.membeshipNumber = Membership!.memberNumber!
        let realm = try! Realm()
        try! realm.write {
            realm.add(storedata)
        }
        
        initiateSearch()
        
    }

    
    func getUnitSize(_ unitSize:[InventoryUnit]) {
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
        Constant.MyClassConstants.unitNumberSelectedArray.removeAllObjects()
        let unitSizeRelinquishment = unitSize
        var unitString = ""
        var unitNumber = ""
        for unit in unitSizeRelinquishment{
            unitString = "\(Helper.getBedroomNumbers(bedroomType: unit.unitSize!)), Sleeps \(unit.publicSleepCapacity)"
            unitNumber = unit.unitNumber!
            Constant.MyClassConstants.unitNumberSelectedArray.add(unitNumber)
            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(unitString)
        }
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(masterUnitSize)
        Constant.MyClassConstants.unitNumberSelectedArray.add(masterUnitNumber)
    }
    
    fileprivate func initiateSearch() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
            self.present(viewController, animated: true, completion: nil)
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
            self.present(viewController, animated: true, completion: nil)
        }
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
        case 4:
            return relinquishmentDeposit.count
        default:
            return 0
        }

    }
    /** TableView cell for row */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionCIGCell, for: indexPath) as! RelinquishmentSelectionCIGCell
            cell.availablePointToolButton.addTarget(self, action: #selector(self.availablePointToolButtonPressed), for: .touchUpInside)
            cell.tag = indexPath.section + indexPath.row
            if (Constant.MyClassConstants.relinquishmentProgram.availablePoints != nil) {
                
                let largeNumber = Constant.MyClassConstants.relinquishmentProgram.availablePoints!
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedString = numberFormatter.string(for: largeNumber)
                cell.availablePointValueLabel.text = formattedString
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else if(indexPath.section == 1 || indexPath.section == 3){
            
            var openWeek:OpenWeek!
            if(indexPath.section == 1 ) {
                
                openWeek = relinquishmentOpenWeeksArray[indexPath.row]
                
                if(openWeek.weekNumber == Constant.CommonStringIdentifiers.floatWeek){
                    print(openWeek.relinquishmentId!, Constant.MyClassConstants.realmOpenWeeksID)
                    if(Constant.MyClassConstants.realmOpenWeeksID.contains(openWeek.relinquishmentId!) && openWeek.unit?.lockOffUnits.count == 0) {
                        
                        let  cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.floatWeekSavedCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                        
                        if(cell.savedView.layer.sublayers != nil) {
                            for layer in cell.savedView.layer.sublayers!{
                                if(layer.isKind(of: CAGradientLayer.self)) {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        Helper.addGredientColorOnFloatSavedCell(view: cell.savedView)
                        
                        if(Constant.MyClassConstants.floatRemovedArray.count == 0){
                            
                            cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                            cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                            cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType:openWeek.unit!.kitchenType!))"
                            cell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                            if(indexPath.section == 1){
                                cell.tag = indexPath.row + indexPath.section
                            }else{
                                cell.tag = indexPath.row + 1
                            }

                            
                            //display promotion
                            if relinquishmentOpenWeeksArray.count > 0 {
                                if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                                    cell.promLabel.text = promotion.offerName
                                    cellHeight = 90
                                } else {
                                    cell.promLabel.isHidden = true
                                    cell.promImgView.isHidden = true
                                    cellHeight = 80
                                }
                                
                            } else {
                                cell.promLabel.isHidden = true
                                cell.promImgView.isHidden = true
                                cellHeight = 80
                            }
                            
                            return cell
                            
                        }
                        else{
                            
                            for openWk in Constant.MyClassConstants.floatRemovedArray{
                                
                                let openWk1 = openWk as! OpenWeeks
                                let floatWeek = openWk1
                                if(openWeek.relinquishmentId == openWk1.relinquishmentID ) {
                                    
                                    print(floatWeek)
                                    
                                    cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                                    cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType:openWeek.unit!.kitchenType!))"
                                    cell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                                    if(indexPath.section == 1){
                                        cell.tag = indexPath.row + indexPath.section
                                    }else{
                                        cell.tag = indexPath.row + 1
                                    }
                                }
                            }
                            
                            //display promotion
                            if relinquishmentOpenWeeksArray.count > 0 {
                                if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                                    cell.promLabel.text = promotion.offerName
                                    cellHeight = 90
                                } else {
                                    cell.promLabel.isHidden = true
                                    cell.promImgView.isHidden = true
                                    cellHeight = 80
                                }
                                
                            } else {
                                cell.promLabel.isHidden = true
                                cell.promImgView.isHidden = true
                                cellHeight = 80
                            }
                            return cell
                        }
                    }
                    else {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.floatWeekUnsavedCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                        cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                        cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                        if(indexPath.section == 1){
                            cell.tag = indexPath.row + indexPath.section
                        }else{
                            cell.tag = indexPath.row + 1
                        }
                        if((openWeek.unit?.lockOffUnits.count)! > 0){
                            cell.bedroomSizeAndKitchenClient.isHidden = false
                            cell.bedroomSizeAndKitchenClient.text = Constant.MyClassConstants.lockOffCapable
                        }else{
                            cell.bedroomSizeAndKitchenClient.isHidden = true
                        }
                        
                        //display promotion
                        if relinquishmentOpenWeeksArray.count > 0 {
                            if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                                cell.promLabel.text = promotion.offerName
                                cellHeight = 90
                            } else {
                                cell.promLabel.isHidden = true
                                cell.promImgView.isHidden = true
                                cellHeight = 80
                            }
                            
                        } else {
                            cell.promLabel.isHidden = true
                            cell.promImgView.isHidden = true
                            cellHeight = 80
                        }
                        
                        return cell
                    }
                    
                }
                    
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionOpenWeeksCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    
                    cell.resortName.text = "\(openWeek.resort!.resortName!)"
                    cell.yearLabel.text = "\(openWeek.relinquishmentYear!)"
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
                        
                        cell.dayAndDateLabel.text = ""
                    }
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber!))"
                    cell.tag = indexPath.row + 1
                    if((openWeek.unit?.lockOffUnits.count)! > 0){
                        cell.bedroomSizeAndKitchenClient.text = Constant.MyClassConstants.lockOffCapable
                        cell.totalSleepAndPrivate.text = ""
                    }
                    
                    //display promotion
                    if relinquishmentOpenWeeksArray.count > 0 {
                        if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                            cell.promLabel.text = promotion.offerName
                            cellHeight = 90
                        } else {
                            cell.promLabel.isHidden = true
                            cell.promImgView.isHidden = true
                            cellHeight = 80
                        }
                        
                    } else {
                        cell.promLabel.isHidden = true
                        cell.promImgView.isHidden = true
                        cellHeight = 80
                    }
                    
                    return cell
                    
                }
            }
            else {
                
                openWeek = intervalOpenWeeksArray[indexPath.row]
                let  intervalWeekCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionOpenWeeksCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                
                intervalWeekCell.resortName.text = openWeek.resort?.resortName!
                intervalWeekCell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType:openWeek.unit!.kitchenType!))"
                intervalWeekCell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                intervalWeekCell.dayAndDateLabel.text = ""
                if((openWeek.unit?.lockOffUnits.count)! > 0){
                    intervalWeekCell.bedroomSizeAndKitchenClient.text = Constant.MyClassConstants.lockOffCapable
                    intervalWeekCell.totalSleepAndPrivate.text = ""
                }
                if(indexPath.section == 1) {
                    intervalWeekCell.tag = indexPath.row + indexPath.section
                }
                else {
                    
                    intervalWeekCell.tag = indexPath.row
                }
                intervalWeekCell.yearLabel.text = "\(openWeek.relinquishmentYear!)"
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
                    
                    intervalWeekCell.dayAndDateLabel.text = month.uppercased()
                    
                }
                else {
                    
                    intervalWeekCell.dayAndDateLabel.text = " "
                }
                intervalWeekCell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber!))"
                
                intervalWeekCell.selectionStyle = UITableViewCellSelectionStyle.none
                
                //display promotion
                if relinquishmentOpenWeeksArray.count > 0 {
                    if let promotion = relinquishmentOpenWeeksArray[0].promotion {
                        intervalWeekCell.promLabel.text = promotion.offerName
                        cellHeight = 90
                    } else {
                        intervalWeekCell.promLabel.isHidden = true
                        intervalWeekCell.promImgView.isHidden = true
                        cellHeight = 80
                    }
                } else {
                    intervalWeekCell.promLabel.isHidden = true
                    intervalWeekCell.promImgView.isHidden = true
                    cellHeight = 80
                }
                
                
                return intervalWeekCell
            }
            
        }
        else if indexPath.section == 4 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DepositedCell", for: indexPath) as? RelinquishmentSelectionOpenWeeksCell {
                let deposit = relinquishmentDeposit[indexPath.row] as Deposit
                cell.setupDepositedCell(deposit: deposit)
                cell.tag = indexPath.row
                
                return cell
            }
            
            return UITableViewCell()
        } else {
            
            let openWeek = pointOpenWeeksArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.clubPointCell, for: indexPath) as! clubPointCell
            
            cell.nameLabel.text = openWeek.resort?.resortName!
            cell.yearLabel.text = "\(String(describing: openWeek.relinquishmentYear!))"
            cell.tag = indexPath.row
            
            return cell
        }        
    }
    
    /** Edit Row at indexPath */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
/*
 
 extension for tableview delegate
 */
extension OwnershipViewController:UITableViewDelegate{
    /** Perform Edit action for row at indexPath */
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let detail = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: Constant.ownershipViewController.vacationForSearchTitle) { (action,index) -> Void in
            let cell = tableView.cellForRow(at: indexPath)
            var openWeek:OpenWeek!
            if indexPath.section == 0 {
               self.addAvailablePoinButtonPressed(senderTag: (cell?.tag)!)
            } else if indexPath.section == 1 || indexPath.section == 3 {
                openWeek = self.relinquishmentOpenWeeksArray[indexPath.row]
                if indexPath.section == 1 {
                    if(openWeek.weekNumber == Constant.CommonStringIdentifiers.floatWeek) {
                        self.addClubFloatWeek(senderTag: (cell?.tag)!)
                    } else {
                        self.addAvailablePoinButtonPressed(senderTag: (cell?.tag)!)
                    }
                } else {
                    //section 3
                    self.addIntervalWeekButtonPressed(senderTag: (cell?.tag)!)
                }
                
                
            } else if indexPath.section == 4 {
                self.addDeposits(senderTag: (cell?.tag)!)
            } else {
                self.addClubPointButtonPressed(senderTag: (cell?.tag)!)
            }
            
            
            
//            //Segue to Float detail view controller
//            if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 3{
//                self.performSegue(withIdentifier: Constant.ownershipViewController.floatdetailViewControllerIdentifier, sender: self)
//            }
//            else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0{
//                let storyboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
//                let clubPointselectionViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController)as? ClubPointSelectionViewController
//                self.navigationController?.pushViewController(clubPointselectionViewController!, animated: true)
//                
//            }
//            else{
////                let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
////                self.present((storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController)!, animated: true, completion: nil)
//            }
            
        }
        detail.backgroundColor = UIColor(red: 245/255, green: 99/255, blue: 36/255, alpha: 1.0)
        return [detail]
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Height for deposit cells
        if indexPath.section == 4 {
            let windowHeight = self.view.window?.bounds.height
            if Float(windowHeight!) <= 568.0 {
                //height for devices with smaller screen (iPhone 5s and beyond)
                return 135
            } else{
                //height for devices with bigger screens (iPhone 6 and beyond)
                return 110
            }
        }
        
        if((indexPath as NSIndexPath).row == 0) {
            if ((indexPath as NSIndexPath).section == 0) {
                return UITableViewAutomaticDimension
            }
            return 90
        }
        else {
            return 90
        }
        
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
            if (self.relinquishmentPointsProgramArray.count > 0 && self.relinquishmentPointsProgramArray[0].availablePoints == nil){
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

extension OwnershipViewController:BedroomSizeViewControllerDelegate {
    func doneButtonClicked(selectedUnitsArray:NSMutableArray) {
        //Realm local storage for selected relinquishment
        
        for unitDetails1 in selectedUnitsArray{
            
            let unitSizeFullDetail1 = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[(unitDetails1 as! Int - 1000)] as! String
            let unitNumber = Constant.MyClassConstants.unitNumberSelectedArray[(unitDetails1 as! Int - 1000)] as! String
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
                
                let floatDetails = ResortFloatDetails()
                floatDetails.unitNumber = unitNumber
                
                selectedOpenWeek.unitDetails.append(resortUnitDetails)
                selectedOpenWeek.floatDetails.append(floatDetails)
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
    
    func floatLockOffDetails(bedroomDetails:String) {
        Helper.navigateToViewController(senderViewController: self, floatResortDetails: Constant.MyClassConstants.relinquishmentSelectedWeek.resort!, isFromLockOff: true)
    }

}

