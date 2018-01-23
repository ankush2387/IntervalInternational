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
    var openWkToRemoveArray: NSMutableArray!
    var requiredSection = 0
    var masterUnitSize = ""
    var masterUnitNumber = ""
    var cellHeight: CGFloat = 80
    var relinquishmentDeposit = [Deposit]()
    
    //Outlets
    @IBOutlet weak var relinquishmentTableview: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.isNavigationBarHidden = false
        Helper.InitializeOpenWeeksFromLocalStorage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Constant.MyClassConstants.savedBedroom = ""
        Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate = nil
        Constant.MyClassConstants.savedClubFloatResort = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.vacationSearchRelinquishmentSelect
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        self.relinquishmentTableview.estimatedRowHeight = 200
        self.relinquishmentPointsProgramArray.append(Constant.MyClassConstants.relinquishmentProgram)
        
        relinquishmentOpenWeeksArray.removeAll()
        
        //Get Deposits to display
        verifyDepositsToDisplay()
        
        //Array to get details of unit details saved by user for lock-off capable.
        Constant.MyClassConstants.saveLockOffDetailsArray.removeAll()
        
        for fixed_week_type in Constant.MyClassConstants.relinquishmentOpenWeeks {
            if let relinquishmentId = fixed_week_type.relinquishmentId {
                //Check if the week number is of point week type
                if fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.pointWeek {
                    //Check if relinquishment ID is already added
                    if !Constant.MyClassConstants.relinquishmentIdArray.contains(relinquishmentId) {
                        pointOpenWeeksArray.append(fixed_week_type)
                    }
                } else if fixed_week_type.pointsProgramCode != "" || fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.floatWeek {
                    
                    if let lockOffUnits = fixed_week_type.unit?.lockOffUnits {
                        let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(relinquishmentId) })
                        let count = results.filter({ $0 == true }).count
                        if count != lockOffUnits.count + 1 {
                            
                            if fixed_week_type.weekNumber == Constant.CommonStringIdentifiers.floatWeek {
                                if Constant.MyClassConstants.whatToTradeArray.count > 0 {
                                    
                                    for traversedOpenWeek in Constant.MyClassConstants.whatToTradeArray {
                                        let relinquishment = traversedOpenWeek as AnyObject
                                        
                                        if relinquishment.isKind(of: List<rlmPointsProgram>.self) {
                                            
                                        } else if relinquishment.isKind(of: Deposits.self) {
                                            
                                        } else {
                                            
                                            let floatLockOffWeek = traversedOpenWeek as! OpenWeeks
                                            if floatLockOffWeek.relinquishmentID == fixed_week_type.relinquishmentId {
                                                Constant.MyClassConstants.saveLockOffDetailsArray.append("\(floatLockOffWeek.floatDetails[0].unitNumber),\(floatLockOffWeek.floatDetails[0].unitSize)")
                                            }
                                        }
                                    }
                                }
                                
                                if Constant.MyClassConstants.floatRemovedArray.count > 0 {
                                    for traversedOpenWeek in Constant.MyClassConstants.floatRemovedArray {
                                        let floatLockOffWeek = traversedOpenWeek as! OpenWeeks
                                        if floatLockOffWeek.relinquishmentID == fixed_week_type.relinquishmentId {
                                            Constant.MyClassConstants.saveLockOffDetailsArray.append("\(floatLockOffWeek.floatDetails[0].unitNumber),\(floatLockOffWeek.floatDetails[0].unitSize)")
                                        }
                                    }
                                }
                                relinquishmentOpenWeeksArray.append(fixed_week_type)
                                
                            }
                        }
                        if !Constant.MyClassConstants.relinquishmentIdArray.contains(relinquishmentId) {
                            relinquishmentOpenWeeksArray.append(fixed_week_type)
                        }
                    } else {
                        if Constant.MyClassConstants.relinquishmentIdArray.contains(relinquishmentId) {
                            self.intervalOpenWeeksArray.append(fixed_week_type)
                        } else {
                            if let lockOffUnits = fixed_week_type.unit?.lockOffUnits {
                                
                                let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(relinquishmentId) })
                                let count = results.filter({ $0 == true }).count
                                
                                if count != lockOffUnits.count + 1 {
                                    self.intervalOpenWeeksArray.append(fixed_week_type)
                                }
                            }
                        }
                    }
                } else {
                    if Constant.MyClassConstants.relinquishmentIdArray.contains(relinquishmentId) {
                        self.intervalOpenWeeksArray.append(fixed_week_type)
                    } else {
                        if let lockOffUnits = fixed_week_type.unit?.lockOffUnits {
                            
                            let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(relinquishmentId) })
                            let count = results.filter({ $0 == true }).count
                            
                            if count != lockOffUnits.count + 1 {
                                self.intervalOpenWeeksArray.append(fixed_week_type)
                            }
                        }
                    }
                }
            }
        }
        
        if let relinquishmentID = relinquishmentPointsProgramArray[0].relinquishmentId {
            if Constant.MyClassConstants.relinquishmentIdArray.contains(relinquishmentID) {
                self.relinquishmentPointsProgramArray.remove(at: 0)
            }
        }
        
//        if self.requiredNumberOfSection() == 0 {
//            presentAlert(with: Constant.ControllerTitles.relinquishmentSelectiongControllerTitle, message: Constant.MyClassConstants.noRelinquishmentavailable)
//        
//        }
//        
//        if self.relinquishmentTableview != nil {
//            relinquishmentTableview.reloadData()
//        }
//        // Adding controller title
//        self.title = Constant.ControllerTitles.relinquishmentSelectiongControllerTitle
        
        // Adding navigation back button
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(RelinquishmentSelectionViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Do any additional setup after loadingvare view.
        
        // Omniture tracking with event 61
        
        var cigPoints: Int? = Constant.MyClassConstants.relinquishmentProgram.availablePoints
        if Constant.MyClassConstants.relinquishmentProgram.availablePoints == nil {
            cigPoints = 0
        }
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vacationSearch,
            Constant.omnitureEvars.eVar35: "\(Constant.omnitureCommonString.cigPoints)\(cigPoints! > 0 ?  Constant.omnitureCommonString.available : Constant.omnitureCommonString.notAvailable ): \(Constant.omnitureCommonString.clubPoints) \(pointOpenWeeksArray.count > 0 ? Constant.omnitureCommonString.available : Constant.omnitureCommonString.notAvailable ): Fixed Open- \(relinquishmentOpenWeeksArray.count) : Float Open- \(intervalOpenWeeksArray.count) : Unredeemed -\(cigPoints!): Pending Request-\(0)"
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event61, data: userInfo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyDepositsToDisplay() {
        for fixed_week_type in Constant.MyClassConstants.relinquishmentDeposits {
            guard let relinquinshmentID = fixed_week_type.relinquishmentId else { return }
            
            if !Constant.MyClassConstants.relinquishmentIdArray.contains(relinquinshmentID) {
                self.relinquishmentDeposit.append(fixed_week_type)
            }
        }
    }
    
    func requiredNumberOfSection() -> Int {
        
        if self.relinquishmentPointsProgramArray.count > 0 {
            if self.relinquishmentPointsProgramArray[0].availablePoints != nil {
                self.requiredSection = self.requiredSection + 1
            }
        }
        
        if relinquishmentOpenWeeksArray.count > 0 {
            self.requiredSection = self.requiredSection + 1
        }
        if pointOpenWeeksArray.count > 0 {
            self.requiredSection = self.requiredSection + 1
        }
        if intervalOpenWeeksArray.count > 0 {
            self.requiredSection = self.requiredSection + 1
        }
        if relinquishmentDeposit.count > 0 {
            self.requiredSection += 1
        }
        
        return self.requiredSection
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        isRunningOnIphone ?  _ = navigationController?.popViewController(animated: true) : dismiss(animated: true, completion: nil)
        
    }
    
    func availablePointToolButtonPressed(_ sender: IUIKButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.availablePointToolViewController) as? AvailablePointToolViewController else {return}
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
        
    }
    
    func addIntervalWeekButtonPressed(_ sender: IUIKButton) {
        if (intervalOpenWeeksArray[sender.tag].unit?.lockOffUnits.count)! > 0 {
            Constant.ControllerTitles.bedroomSizeViewController = Constant.MyClassConstants.relinquishmentTitle
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            if let unitSize = intervalOpenWeeksArray[sender.tag].unit?.unitSize, let sleeps = intervalOpenWeeksArray[sender.tag].unit?.publicSleepCapacity {
                masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: unitSize)), Sleeps \(unitSize)"
            }
            
            if let unitNumber = intervalOpenWeeksArray[sender.tag].unit?.unitNumber {
                masterUnitNumber = unitNumber
            }
            
            let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(intervalOpenWeeksArray[sender.tag].relinquishmentId!) })
            
            Constant.MyClassConstants.senderRelinquishmentID = intervalOpenWeeksArray[sender.tag].relinquishmentId!
            let count = results.filter({ $0 == true }).count
            
            if count > 0 {
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray {
                    
                    let selectedDict = selectedUnits as? NSMutableDictionary
                    
                    if intervalOpenWeeksArray[sender.tag].relinquishmentId ?? "" == selectedDict?.allKeys.first as? String {
                        Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict?.object(forKey: intervalOpenWeeksArray[sender.tag].relinquishmentId ?? "") ?? "")
                     
                    }
                    intervalPrint(Constant.MyClassConstants.userSelectedUnitsArray)
                }
            } else {
                Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
            }
            getUnitSize((intervalOpenWeeksArray[sender.tag].unit?.lockOffUnits)!)
            
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag]
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            var mainStoryboard = UIStoryboard()
            if Constant.RunningDevice.deviceIdiom == .pad {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
            } else {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
            }
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as? BedroomSizeViewController  else {return}
            
            viewController.delegate = self
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.present(viewController, animated: true, completion: nil)
        } else {
            Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag]
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
            if let relinquishmentId = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId {
                Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentId)
            }
            
            //Realm local storage for selected relinquishment
            let storedata = OpenWeeksStorage()
            let Membership = Session.sharedSession.selectedMembership
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
            
            if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
                _ = self.navigationController?.popViewController(animated: true)
                
                return
            }
            
            if Constant.RunningDevice.deviceIdiom == .pad {
                self.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func addClubPointButtonPressed(_ sender: IUIKButton) {
        Constant.MyClassConstants.relinquishmentSelectedWeek = pointOpenWeeksArray[sender.tag]
        if Constant.MyClassConstants.relinquishmentSelectedWeek.pointsMatrix == false {
            intervalPrint("false")
            let storedata = OpenWeeksStorage()
            let membership = Session.sharedSession.selectedMembership
            let relinquishmentList = TradeLocalData()
            
            let selectedClubPoint = ClubPoints()
            if let relinquishmentId = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId {
                selectedClubPoint.relinquishmentId = relinquishmentId
            }
            
            selectedClubPoint.isPointsMatrix = false
            selectedClubPoint.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear ?? 0
            
            let resort = ResortList()
            if let resortName = Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName {
                resort.resortName = resortName
            }
            selectedClubPoint.resort.append(resort)
            relinquishmentList.clubPoints.append(selectedClubPoint)
            storedata.openWeeks.append(relinquishmentList)
            if let memberNumber = membership?.memberNumber {
                storedata.membeshipNumber = memberNumber
            }
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(storedata)
                }
            } catch {
                presentErrorAlert(UserFacingCommonError.generic)
            }
            
            if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
                _ = self.navigationController?.popViewController(animated: true)
                return
            }
            
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            isRunningOnIphone ?  _ = navigationController?.popViewController(animated: true) : dismiss(animated: true, completion: nil)
            
        } else {
            showHudAsync()
            Constant.MyClassConstants.matrixDataArray.removeAllObjects()
            
            guard let resortCode = Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortCode else { return }
            
            DirectoryClient.getResortClubPointsChart(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { clubPointsChart in
                
                Constant.MyClassConstants.selectionType = 1
                self.hideHudAsync()
                if let clubPointsChartType = clubPointsChart.type {
                    Constant.MyClassConstants.matrixType = clubPointsChartType
                }
                if let matrixDescription = clubPointsChart.matrices[0].description {
                    Constant.MyClassConstants.matrixDescription = matrixDescription
                }
                if Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeSingle || Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeColor {
                    Constant.MyClassConstants.showSegment = false
                } else {
                    Constant.MyClassConstants.showSegment = true
                }
                for matrices in clubPointsChart.matrices {
                    let pointsDictionary = NSMutableDictionary()
                    for grids in matrices.grids {
                        guard let gridFromDate = grids.fromDate else { return }
                        
                        Constant.MyClassConstants.fromdatearray.add(gridFromDate)
                        
                        guard let gridToDate = grids.toDate else { return }
                        
                        Constant.MyClassConstants.todatearray.add(gridToDate)
                        
                        for rows in grids.rows {
                            if let rowsLabel = rows.label {
                                Constant.MyClassConstants.labelarray.add(rowsLabel)
                            }
                        }
                        let dictKey = "\(String(describing: gridFromDate)) - \(String(describing: gridToDate))"
                        pointsDictionary.setObject(grids.rows, forKey: String(describing: dictKey) as NSCopying)
                    }
                    Constant.MyClassConstants.matrixDataArray.add(pointsDictionary)
                }
                
                let storyboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                guard let clubPointselectionViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController) as? ClubPointSelectionViewController else {return}
                self.navigationController?.pushViewController(clubPointselectionViewController, animated: true)
                
            }, onError: { error in
                self.hideHudAsync()
                intervalPrint(error.description)
            })
            
        }
        
    }
    func addAvailablePoinButtonPressed(_ sender: IUIKButton) {
        if sender.tag == 0 {
            guard let relinquishmentId = Constant.MyClassConstants.relinquishmentProgram.relinquishmentId else {
                return
            }
            Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentProgram)
            Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentId)
            //Realm local storage for selected relinquishment
            let storedata = OpenWeeksStorage()
            let relinquishmentList = TradeLocalData()
            let rlmPProgram = rlmPointsProgram()
            
            rlmPProgram.availablePoints = Constant.MyClassConstants.relinquishmentProgram.availablePoints!
            rlmPProgram.code = Constant.MyClassConstants.relinquishmentProgram.code!
            
            rlmPProgram.relinquishmentId = relinquishmentId
            
            relinquishmentList.pProgram.append(rlmPProgram)
            storedata.openWeeks.append(relinquishmentList)
            if let memberNumber = Session.sharedSession.selectedMembership?.memberNumber {
                storedata.membeshipNumber = memberNumber
            }
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(storedata)
                }
            } catch {
                presentErrorAlert(UserFacingCommonError.generic)
            }
            
            if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
                _ = self.navigationController?.popViewController(animated: true)
                
                return
            }
            
            if Constant.RunningDevice.deviceIdiom == .pad {
                self.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            if !(relinquishmentOpenWeeksArray[sender.tag - 1].unit?.lockOffUnits.isEmpty)! {
                guard let relinquishmentId = relinquishmentOpenWeeksArray[sender.tag - 1].relinquishmentId else { return }
                Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
                masterUnitSize = ""
                masterUnitNumber = ""
                
                if let unitSize = relinquishmentOpenWeeksArray[sender.tag - 1].unit?.unitSize, let sleeps = relinquishmentOpenWeeksArray[sender.tag - 1].unit?.publicSleepCapacity, unitSize != "UNKNOWN" {
                    masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: unitSize)), Sleeps \(sleeps)"
                }
                
                if let unitNumber = relinquishmentOpenWeeksArray[sender.tag - 1].unit?.unitNumber, !unitNumber.isEmpty {
                    masterUnitNumber = unitNumber
                }
                
                let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(relinquishmentId) })
                
                Constant.MyClassConstants.senderRelinquishmentID = relinquishmentId
                let count = results.filter({ $0 == true }).count
                
                if count > 0 {
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                    for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray {
                        let selectedDict = selectedUnits as? NSMutableDictionary
                        if relinquishmentId == selectedDict?.allKeys.first as? String {
                            Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict?.object(forKey: relinquishmentId) ?? "")
                        }
                    }
                } else {
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                }
                if let relinquishmentUnits = relinquishmentOpenWeeksArray[sender.tag - 1].unit {
                    getUnitSize(relinquishmentUnits.lockOffUnits)
                }
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
                Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
                Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentId)
                
                var mainStoryboard = UIStoryboard()
                if Constant.RunningDevice.deviceIdiom == .pad {
                    mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
                } else {
                    mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                }
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as? BedroomSizeViewController else {return}
                
                viewController.delegate = self
                let transitionManager = TransitionManager()
                navigationController?.transitioningDelegate = transitionManager
                navigationController?.present(viewController, animated: true, completion: nil)
            } else {
                guard let relinquishmentId = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId else { return }
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
                Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek)
                Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentId)
                
                //Realm local storage for selected relinquishment
                let storedata = OpenWeeksStorage()
                let Membership = Session.sharedSession.selectedMembership
                let relinquishmentList = TradeLocalData()
                
                let selectedOpenWeek = OpenWeeks()
                if let weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber {
                    selectedOpenWeek.weekNumber = weekNumber
                }
                selectedOpenWeek.relinquishmentID = relinquishmentId
                if let relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear {
                    selectedOpenWeek.relinquishmentYear = relinquishmentYear
                }
                let resort = ResortList()
                if let resortName = Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName {
                    resort.resortName = resortName
                }
                
                selectedOpenWeek.resort.append(resort)
                relinquishmentList.openWeeks.append(selectedOpenWeek)
                storedata.openWeeks.append(relinquishmentList)
                if let memberNumber = Session.sharedSession.selectedMembership?.memberNumber {
                    storedata.membeshipNumber = memberNumber
                }
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(storedata)
                    }
                } catch {
                    presentErrorAlert(UserFacingCommonError.generic)
                }
                
                if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
                    _ = self.navigationController?.popViewController(animated: true)
                    return
                }
                
                if Constant.RunningDevice.deviceIdiom == .pad {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func addClubFloatWeek(_ sender: IUIKButton) {
        Constant.MyClassConstants.selectedFloatWeek = OpenWeeks()
        if relinquishmentOpenWeeksArray.count > 0 {
            Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
        } else if intervalOpenWeeksArray.count > 0 {
            Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag - 1]
        }
        
        if let lockOffUnits = Constant.MyClassConstants.relinquishmentSelectedWeek.unit?.lockOffUnits {
            if !lockOffUnits.isEmpty {
                Constant.ControllerTitles.bedroomSizeViewController = Constant.MyClassConstants.relinquishmentTitle
                Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
                masterUnitSize = ""
                if let unitSize = Constant.MyClassConstants.relinquishmentSelectedWeek.unit?.unitSize, let sleeps = Constant.MyClassConstants.relinquishmentSelectedWeek.unit?.publicSleepCapacity {
                    masterUnitSize = "\(Helper.getBedroomNumbers(bedroomType: unitSize)), Sleeps \(sleeps)"
                }
                
                let results = Constant.MyClassConstants.relinquishmentIdArray.map({ ($0 as AnyObject).contains(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!) })
                
                Constant.MyClassConstants.senderRelinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
                let count = results.filter({ $0 == true }).count
                
                if count > 0 {
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                    for selectedUnits in Constant.MyClassConstants.relinquishmentUnitsArray {
                        
                        let selectedDict = selectedUnits as! NSMutableDictionary
                        intervalPrint(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!, selectedDict.allKeys.first!, selectedDict)
                        if Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId! == selectedDict.allKeys.first as! String {
                            Constant.MyClassConstants.userSelectedUnitsArray.add(selectedDict.object(forKey: Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)!)
                            intervalPrint(Constant.MyClassConstants.userSelectedUnitsArray)
                            
                        }
                    }
                } else {
                    Constant.MyClassConstants.userSelectedUnitsArray.removeAllObjects()
                }
                getUnitSize((Constant.MyClassConstants.relinquishmentSelectedWeek.unit?.lockOffUnits)!)
                
                Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.floatViewController
                //Constant.MyClassConstants.relinquishmentIdArray.add(Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!)
                
                var mainStoryboard = UIStoryboard()
                if Constant.RunningDevice.deviceIdiom == .pad {
                    mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
                } else {
                    mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                }
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as? BedroomSizeViewController  else {return}
                viewController.delegate = self
                Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.floatViewController
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController!.present(viewController, animated: true, completion: nil)
            }
        } else {
            
            if !relinquishmentOpenWeeksArray.isEmpty {
                Constant.MyClassConstants.relinquishmentSelectedWeek = relinquishmentOpenWeeksArray[sender.tag - 1]
                Helper.navigateToViewController(senderViewController: self, floatResortDetails: relinquishmentOpenWeeksArray[sender.tag - 1].resort!, isFromLockOff: false)
            } else if intervalOpenWeeksArray.count > 0 {
                Constant.MyClassConstants.relinquishmentSelectedWeek = intervalOpenWeeksArray[sender.tag - 1]
                Helper.navigateToViewController(senderViewController: self, floatResortDetails: intervalOpenWeeksArray[sender.tag - 1].resort!, isFromLockOff: false)
            } else {
                
            }
            
            for floatWeek in Constant.MyClassConstants.whatToTradeArray {
                
                guard let floatWeekTraversed = floatWeek as? OpenWeeks else { return }
                if floatWeekTraversed.isFloat && Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId! == floatWeekTraversed.relinquishmentID {
                    Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                    Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
                }
            }
            for floatWeek in Constant.MyClassConstants.floatRemovedArray {
                guard let floatWeekTraversed = floatWeek as? OpenWeeks else { return }
                if floatWeekTraversed.isFloatRemoved && Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId! == floatWeekTraversed.relinquishmentID {
                    Constant.MyClassConstants.selectedFloatWeek = floatWeekTraversed
                    Constant.MyClassConstants.savedClubFloatResort = floatWeekTraversed.floatDetails[0].clubResortDetails
                }
            }
            intervalPrint(Constant.MyClassConstants.selectedFloatWeek)
        }
    }
    
    func addDeposits(_ sender: IUIKButton) {
        guard let relinquishmentId = relinquishmentDeposit[sender.tag].relinquishmentId else { return }
        Constant.MyClassConstants.relinquismentSelectedDeposit = relinquishmentDeposit[sender.tag]
        Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.relinquishmentSelectionViewController
        Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentId)
        
        //Realm local storage for selected relinquishment
        let storedata = OpenWeeksStorage()
        let relinquishmentList = TradeLocalData()
        
        let selectedOpenWeek = Deposits()
        if let weekNumber = Constant.MyClassConstants.relinquismentSelectedDeposit.weekNumber {
            selectedOpenWeek.weekNumber = weekNumber
        }
        selectedOpenWeek.relinquishmentID = relinquishmentId
        if let relinquishmentYear = Constant.MyClassConstants.relinquismentSelectedDeposit.relinquishmentYear {
            selectedOpenWeek.relinquishmentYear = relinquishmentYear
        }
        let resort = ResortList()
        if let name = Constant.MyClassConstants.relinquismentSelectedDeposit.resort?.resortName {
            resort.resortName = name
        }
        
        selectedOpenWeek.resort.append(resort)
        relinquishmentList.deposits.append(selectedOpenWeek)
        storedata.openWeeks.append(relinquishmentList)
        Constant.MyClassConstants.whatToTradeArray.add(selectedOpenWeek)
        if let membershipNumber = Session.sharedSession.selectedMembership?.memberNumber {
            storedata.membeshipNumber = membershipNumber
        }
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(storedata)
            }
        } catch {
            presentErrorAlert(UserFacingCommonError.generic)
        }
        
        if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        if Constant.RunningDevice.deviceIdiom == .pad {
            self.dismiss(animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getUnitSize(_ unitSize: [InventoryUnit]) {
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
        Constant.MyClassConstants.unitNumberSelectedArray.removeAllObjects()
        let unitSizeRelinquishment = unitSize
        for unit in unitSizeRelinquishment {
            if let unitSize = unit.unitSize {
                let unitString = "\(Helper.getBedroomNumbers(bedroomType: unitSize)), Sleeps \(unit.publicSleepCapacity)"
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(unitString)
            }
            if let unitNumber = unit.unitNumber {
                Constant.MyClassConstants.unitNumberSelectedArray.add(unitNumber)
            }
        }
        if masterUnitSize != "" {
            Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.add(masterUnitSize)
        }
        if masterUnitNumber != "" {
            Constant.MyClassConstants.unitNumberSelectedArray.add(masterUnitNumber)
        }
    }
}

extension RelinquishmentSelectionViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Height for deposit cells
        if indexPath.section == 4 {
            guard let windowHeight = self.view.window?.bounds.height else { return 0 }
            if Float(windowHeight) <= 568.0 {
                //height for devices with smaller screen (iPhone 5s and beyond)
                return 135
            } else {
                //height for devices with bigger screens (iPhone 6 and beyond)
                return UITableViewAutomaticDimension
            }
        }
        
        if indexPath.row == 0 {
            if indexPath.section == 0 {
                return UITableViewAutomaticDimension
            }
            return cellHeight
        } else {
            return cellHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            guard let windowHeight = self.view.window?.bounds.height else { return 0 }
            if Float(windowHeight) <= 568.0 {
                //height for devices with smaller screen (iPhone 5s and beyond)
                return 135
            } else {
                //height for devices with bigger screens (iPhone 6 and beyond)
                return 130
            }
        }
        
        return 80
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 || section == 2 || section == 3 {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
            let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width - 30, height: 30))
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            if section == 0 {
                headerTextLabel.text = Constant.ownershipViewController.clubIntervalGoldWeeksSectionHeaderTitle
            } else if section == 2 {
                
                headerTextLabel.text = Constant.ownershipViewController.clubPointsSectionHeaderTitle
            } else {
                
                headerTextLabel.text = Constant.ownershipViewController.intervalWeeksSectionHeaderTitle
            }
            headerTextLabel.textColor = UIColor.darkGray
            headerTextLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
            headerView.addSubview(headerTextLabel)
            return headerView
        } else {
            
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            if !relinquishmentPointsProgramArray.isEmpty && self.relinquishmentPointsProgramArray[0].availablePoints == nil {
                return 0
            } else {
                return 30
            }
            
        case 2:
            if !pointOpenWeeksArray.isEmpty {
                return 30
            } else {
                return 0
            }
            
        case 3:
            if !intervalOpenWeeksArray.isEmpty {
                return 30
            } else {
                return 0
            }
            
        default:
            return 0
        }
    }
}

extension RelinquishmentSelectionViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            
        case 0:
            if (self.relinquishmentPointsProgramArray.count == 1 && self.relinquishmentPointsProgramArray[0].availablePoints == nil) {
                return 0
            } else {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionCIGCell, for: indexPath) as! RelinquishmentSelectionCIGCell
            cell.availablePointToolButton.addTarget(self, action: #selector(RelinquishmentSelectionViewController.availablePointToolButtonPressed(_:)), for: .touchUpInside)
            cell.addAvailablePointButton.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addAvailablePoinButtonPressed(_:)), for: .touchUpInside)
            cell.addAvailablePointButton.tag = indexPath.section + indexPath.row
            if Constant.MyClassConstants.relinquishmentProgram.availablePoints != nil {
                
                let largeNumber = Constant.MyClassConstants.relinquishmentProgram.availablePoints!
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedString = numberFormatter.string(for: largeNumber)
                if(formattedString?.characters.count)! > 5 {
                    
                    cell.availablePointValueWidth.constant = 120
                }
                cell.availablePointValueLabel.text = formattedString
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else if indexPath.section == 1 || indexPath.section == 3 {
            
            var openWeek: OpenWeek!
            if indexPath.section == 1 {
                
                openWeek = relinquishmentOpenWeeksArray[indexPath.row]
                
                if openWeek.weekNumber == Constant.CommonStringIdentifiers.floatWeek {
                    intervalPrint(openWeek.relinquishmentId!, Constant.MyClassConstants.realmOpenWeeksID)
                    if Constant.MyClassConstants.realmOpenWeeksID.contains(openWeek.relinquishmentId!) && openWeek.unit?.lockOffUnits.count == 0 {
                        
                        guard let  cell = tableView.dequeueReusableCell(withIdentifier: RelinquishmentSelectionOpenWeeksCell.identifier, for: indexPath) as? RelinquishmentSelectionOpenWeeksCell else { return UITableViewCell() }
                        
                        if cell.savedView.layer.sublayers != nil {
                            for layer in cell.savedView.layer.sublayers! {
                                if layer.isKind(of: CAGradientLayer.self) {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        Helper.addGredientColorOnFloatSavedCell(view: cell.savedView)
                        
                        if Constant.MyClassConstants.floatRemovedArray.count == 0 {
                            
                            cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                            cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                            cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType: openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType: openWeek.unit!.kitchenType!))"
                            cell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                            if indexPath.section == 1 {
                                cell.addButton?.tag = indexPath.row + indexPath.section
                            } else {
                                cell.addButton?.tag = indexPath.row + 1
                            }
                            cell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addClubFloatWeek(_:)), for: .touchUpInside)
                            
                            //display promotion
                            if relinquishmentOpenWeeksArray.count > 0 {
                                if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                                    cell.promLabel.text = promotion.offerName
                                    cellHeight = 110
                                } else {
                                    cell.promLabel.isHidden = true
                                    cell.promImgView.isHidden = true
                                    cellHeight = 90
                                }
                                
                            } else {
                                cell.promLabel.isHidden = true
                                cell.promImgView.isHidden = true
                                cellHeight = 90
                            }
                            
                            return cell
                            
                        } else {
                            
                            for openWk in Constant.MyClassConstants.floatRemovedArray {
                                
                                let openWk1 = openWk as! OpenWeeks
                                let floatWeek = openWk1
                                if openWeek.relinquishmentId == openWk1.relinquishmentID {
                                    
                                    intervalPrint(floatWeek)
                                    
                                    cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                                    cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType: openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType: openWeek.unit!.kitchenType!))"
                                    cell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                                    if indexPath.section == 1 {
                                        cell.addButton?.tag = indexPath.row + indexPath.section
                                    } else {
                                        cell.addButton?.tag = indexPath.row + 1
                                    }
                                    cell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addClubFloatWeek(_:)), for: .touchUpInside)
                                }
                            }
                            
                            //display promotion
                            if let promotion = openWeek.promotion {
                                cell.promLabel.text = promotion.offerName
                                cellHeight = 110
                            } else {
                                cell.promLabel.isHidden = true
                                cell.promImgView.isHidden = true
                                cellHeight = 90
                            }
                            
                            return cell
                        }
                    } else {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.floatWeekUnsavedCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                        cell.resortName.text = "\(openWeek.resort!.resortName!)/\(openWeek.resort!.resortCode!)"
                        cell.totalWeekLabel.text = "\(openWeek.relinquishmentYear!)"
                        if indexPath.section == 1 {
                            cell.addButton?.tag = indexPath.row + indexPath.section
                        } else {
                            cell.addButton?.tag = indexPath.row + 1
                        }
                        if (openWeek.unit?.lockOffUnits.count)! > 0 {
                            cell.bedroomSizeAndKitchenClient.isHidden = false
                            cell.bedroomSizeAndKitchenClient.text = Constant.MyClassConstants.lockOffCapable
                        } else {
                            cell.bedroomSizeAndKitchenClient.isHidden = true
                        }
                        cell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addClubFloatWeek(_:)), for: .touchUpInside)
                        
                        //display promotion
                        if relinquishmentOpenWeeksArray.count > 0 {
                            if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                                cell.promLabel.text = promotion.offerName
                                cellHeight = 110
                            } else {
                                cell.promLabel.isHidden = true
                                cell.promImgView.isHidden = true
                                cellHeight = 90
                            }
                            
                        } else {
                            cell.promLabel.isHidden = true
                            cell.promImgView.isHidden = true
                            cellHeight = 90
                        }
                        
                        return cell
                    }
                    
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionOpenWeeksCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    
                    cell.resortName.text = "\(openWeek.resort!.resortName!)"
                    cell.yearLabel.text = "\(openWeek.relinquishmentYear!)"
                    let date = openWeek.checkInDates
                    if date.count > 0 {
                        
                        let dateString = date[0]
                        let date = Helper.convertStringToDate(dateString: dateString, format: Constant.MyClassConstants.dateFormat)
                        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                        let myComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: date)
                        let day = myComponents.day!
                        var month = ""
                        if day < 10 {
                            month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                        } else {
                            month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                        }
                        
                        cell.dayAndDateLabel.text = month.uppercased()
                        
                    } else {
                        
                        cell.dayAndDateLabel.text = ""
                    }
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber!))"
                    cell.addButton?.tag = indexPath.row + 1
                    
                    if let lockOfUnits = openWeek.unit?.lockOffUnits {
                        if !lockOfUnits.isEmpty {
                            cell.bedroomSizeAndKitchenClient.text = Constant.MyClassConstants.lockOffCapable
                            cell.totalSleepAndPrivate.text = ""
                        }
                    }
                    cell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addAvailablePoinButtonPressed(_:)), for: .touchUpInside)
                    
                    //display promotion
                    if relinquishmentOpenWeeksArray.count > 0 {
                        if let promotion = relinquishmentOpenWeeksArray[indexPath.row].promotion {
                            cell.promLabel.text = promotion.offerName
                            cellHeight = 110
                        } else {
                            cell.promLabel.isHidden = true
                            cell.promImgView.isHidden = true
                            cellHeight = 90
                        }
                        
                    } else {
                        cell.promLabel.isHidden = true
                        cell.promImgView.isHidden = true
                        cellHeight = 90
                    }
                    
                    return cell
                    
                }
            } else {
                
                openWeek = intervalOpenWeeksArray[indexPath.row]
                let  intervalWeekCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentSelectionOpenWeeksCell, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                
                intervalWeekCell.resortName.text = openWeek.resort?.resortName!
                intervalWeekCell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType: openWeek.unit!.unitSize!))), \(Helper.getKitchenEnums(kitchenType: openWeek.unit!.kitchenType!))"
                intervalWeekCell.totalSleepAndPrivate.text = "Sleeps \(openWeek.unit!.publicSleepCapacity), \(openWeek.unit!.privateSleepCapacity) Private"
                intervalWeekCell.dayAndDateLabel.text = ""
                
                if let lockOfUnits = openWeek.unit?.lockOffUnits {
                    if !lockOfUnits.isEmpty {
                        intervalWeekCell.bedroomSizeAndKitchenClient.text = Constant.MyClassConstants.lockOffCapable
                        intervalWeekCell.totalSleepAndPrivate.text = ""
                    }
                }
                
                if indexPath.section == 1 {
                    intervalWeekCell.addButton?.tag = indexPath.row + indexPath.section
                    intervalWeekCell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addAvailablePoinButtonPressed(_:)), for: .touchUpInside)
                } else {
                    
                    intervalWeekCell.addButton?.tag = indexPath.row
                    intervalWeekCell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addIntervalWeekButtonPressed(_:)), for: .touchUpInside)
                }
                intervalWeekCell.yearLabel.text = "\(openWeek.relinquishmentYear!)"
                let date = openWeek.checkInDates
                if date.count > 0 {
                    
                    let dateString = date[0]
                    let date = Helper.convertStringToDate(dateString: dateString, format: Constant.MyClassConstants.dateFormat)
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: date)
                    let day = myComponents.day!
                    var month = ""
                    if day < 10 {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                    } else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                    }
                    
                    intervalWeekCell.dayAndDateLabel.text = month.uppercased()
                    
                } else {
                    
                    intervalWeekCell.dayAndDateLabel.text = " "
                }
                intervalWeekCell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber!))"
                
                intervalWeekCell.selectionStyle = UITableViewCellSelectionStyle.none
                intervalWeekCell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addIntervalWeekButtonPressed(_:)), for: .touchUpInside)
                
                //display promotion
                if intervalOpenWeeksArray.count > 0 {
                    if let promotion = openWeek.promotion {
                        intervalWeekCell.promLabel.text = promotion.offerName
                        cellHeight = 110
                    } else {
                        intervalWeekCell.promLabel.isHidden = true
                        intervalWeekCell.promImgView.isHidden = true
                        cellHeight = 90
                    }
                } else {
                    intervalWeekCell.promLabel.isHidden = true
                    intervalWeekCell.promImgView.isHidden = true
                    cellHeight = 90
                }
                
                return intervalWeekCell
            }
            
        } else if indexPath.section == 4 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DepositedCell", for: indexPath) as? RelinquishmentSelectionOpenWeeksCell {
                let deposit = relinquishmentDeposit[indexPath.row] as Deposit
                cell.setupDepositedCell(deposit: deposit)
                cell.addButton?.tag = indexPath.row
                cell.addButton?.addTarget(self, action: #selector(self.addDeposits(_:)), for: .touchUpInside)
                return cell
            }
            
            return UITableViewCell()
        } else {
            
            let openWeek = pointOpenWeeksArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.clubPointCell, for: indexPath) as! clubPointCell
            
            cell.nameLabel.text = openWeek.resort?.resortName!
            cell.yearLabel.text = "\(String(describing: openWeek.relinquishmentYear!))"
            cell.addButton?.tag = indexPath.row
            cell.addButton?.addTarget(self, action: #selector(RelinquishmentSelectionViewController.addClubPointButtonPressed(_:)), for: .touchUpInside)
            
            return cell
        }
    }
}

extension RelinquishmentSelectionViewController: BedroomSizeViewControllerDelegate {
    
    func doneButtonClicked(selectedUnitsArray: NSMutableArray) {
        //Realm local storage for selected relinquishment
        
        for unitDetails1 in selectedUnitsArray {
            
            let unitSizeFullDetail1 = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[(unitDetails1 as! Int - 1000)] as! String
            let unitNumber = Constant.MyClassConstants.unitNumberSelectedArray[(unitDetails1 as! Int - 1000)] as! String
            if !Constant.MyClassConstants.userSelectedStringArray.contains(unitSizeFullDetail1) {
                
                let storedata = OpenWeeksStorage()
                let Membership = Session.sharedSession.selectedMembership
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
        for unitValue in selectedUnitsArray {
            let unitSizeFullDetail = Constant.MyClassConstants.bedRoomSizeSelectedIndexArray[(unitValue as! Int - 1000)] as! String
            addedUnitsArray.append(unitSizeFullDetail)
        }
        let storedData = Helper.getLocalStorageWherewanttoTrade()
        
        if storedData.count > 0 {
            for obj in storedData {
                let openWeeks = obj.openWeeks
                for openWk in openWeeks {
                    if !openWk.openWeeks.isEmpty {
                        for object in openWk.openWeeks {
                            if object.relinquishmentID == Constant.MyClassConstants.senderRelinquishmentID {
                                let unitInOpenWeek = "\(object.unitDetails[0].unitSize),\(object.unitDetails[0].kitchenType)"
                                if !addedUnitsArray.contains(unitInOpenWeek) {
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
        var viewcontroller: UIViewController?
        if (Constant.RunningDevice.deviceIdiom == .phone) {
            if Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexchangeViewController) as? FlexchangeSearchViewController
                
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                return
            } else {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController
            }
        } else {
            if Constant.MyClassConstants.viewController.isKind(of: FlexChangeSearchIpadViewController.self) || Constant.MyClassConstants.viewController.isKind(of: FlexchangeSearchViewController.self) {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexChangeSearchIpadViewController) as? FlexChangeSearchIpadViewController
                
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                return
            } else {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController
                
            }
            
        }
        
        //***** creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.0
        transition.timingFunction = timeFunc
        viewcontroller?.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        UIApplication.shared.keyWindow?.rootViewController = viewcontroller
    }
    
    func floatLockOffDetails(bedroomDetails: String) {
        Helper.navigateToViewController(senderViewController: self, floatResortDetails: Constant.MyClassConstants.relinquishmentSelectedWeek.resort!, isFromLockOff: true)
    }
    
}

