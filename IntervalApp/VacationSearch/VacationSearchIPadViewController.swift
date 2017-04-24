//
//  VacationSearchIPadViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import RealmSwift
import SVProgressHUD
import SDWebImage

class VacationSearchIPadViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    //***** Outlets *****//
    @IBOutlet weak var searchVacationSegementControl: UISegmentedControl!
    @IBOutlet weak var searchVacationTableView: UITableView!
    @IBOutlet weak var featuredDestinationsTableView:UITableView!
    @IBOutlet weak var featuredDestinationsTopConstraint: NSLayoutConstraint!
    @IBOutlet var homeTableCollectionView:UICollectionView!
    
    //***** class variables *****//
    var childCounter = 0
    var adultCounter = 2
    var segmentIndex = 0
    var moreButton:UIBarButtonItem?
    var value:Bool! = true
    let defaults = UserDefaults.standard
    
    var showGetaways = true
    var showExchange = false
    
    override func viewDidAppear(_ animated: Bool) {
        self.getVacationSearchDetails()
        Helper.InitializeArrayFromLocalStorage()
        Helper.InitializeOpenWeeksFromLocalStorage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
        self.getVacationSearchDetails()
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if(UIDevice.current.orientation.isLandscape == true) {
            
            homeTableCollectionView.frame =  CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 270)
            homeTableCollectionView.reloadData()
            searchVacationTableView.reloadData()
        }
        else {
            
            homeTableCollectionView.frame =  CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 490)
            homeTableCollectionView.reloadData()
            searchVacationTableView.reloadData()
        }
        
        
    }

    
    func getVacationSearchDetails() {
        
        if let selecteddate = defaults.object(forKey: Constant.MyClassConstants.selectedDate) {
            if ((selecteddate as! Date).isLessThanDate(Constant.MyClassConstants.todaysDate as Date)) {
                Constant.MyClassConstants.vacationSearchShowDate = Constant.MyClassConstants.todaysDate
            }else{
                Constant.MyClassConstants.vacationSearchShowDate = selecteddate as! Date
            }
        }
        else {
            let date = Date()
            Constant.MyClassConstants.vacationSearchShowDate = date
            defaults.set(date, forKey: Constant.MyClassConstants.selectedDate)
        }
        
        if let childct = defaults.object(forKey: Constant.MyClassConstants.childCounterString) {
            
            self.childCounter = childct as! Int
            Constant.MyClassConstants.stepperChildCurrentValue = self.childCounter
        }
        if let adultct = defaults.object(forKey: Constant.MyClassConstants.adultCounterString) {
            
            self.adultCounter = adultct as! Int
            Constant.MyClassConstants.stepperAdultCurrentValue = self.adultCounter
        }
        self.searchVacationTableView.reloadData()
    }
    
    func refreshTableView(){
        self.featuredDestinationsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Constant.MyClassConstants.topDeals = []
        
        if let rvc = self.revealViewController() {
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.parent!.navigationItem.leftBarButtonItem = menuButton
            
            
            moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(MoreNavButtonPressed(_:)))
            
            moreButton!.tintColor = UIColor.white
            
            self.parent!.navigationItem.rightBarButtonItem = moreButton
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
        Helper.InitializeArrayFromLocalStorage()
        self.searchVacationTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(tableView.tag == 1) {
            
            if(showGetaways == true && showExchange == true){
                return 2
            }
            else if(showGetaways == false && showExchange == false) {
                return 0
            }
            else {
                return 1
            }
        }
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if((self.segmentIndex == 0 || self.segmentIndex == 2) && tableView.tag != 1){
            return 4
        }else if(tableView.tag == 1) {
            return 1
        }else{
            return 4
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView.tag == 1){
            return 0
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect (x: 0, y: 0, width: Constant.MyClassConstants.runningDeviceWidth!, height: 40))
        headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        let titleLabel = UILabel(frame: CGRect (x: 20, y: 0, width: Constant.MyClassConstants.runningDeviceWidth! - 20, height: 40))
        titleLabel.text = Constant.segmentControlItems.getawaysIpadText
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 1) {
            let cellIdentifier = Constant.customCellNibNames.featuredTableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
        
                if(!showExchange){
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: (cell?.contentView.frame.width)! - 20, height: 20))
                    resortImageNameLabel.text = "TOP 10 GETAWAYS"
                    
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    cell?.addSubview(resortImageNameLabel)
                }else{
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: (cell?.contentView.frame.width)! - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    cell?.addSubview(resortImageNameLabel)
                    
                }

        
                
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: (cell?.contentView.frame.width)! - 20, height: 20))
                resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                cell?.addSubview(resortImageNameLabel)
            
            
            //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width:280, height: 220 )
            // layout.minimumInteritemSpacing = 1.0
            layout.minimumLineSpacing = 10.0
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 490 ), collectionViewLayout: layout)
            
            homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            homeTableCollectionView.backgroundColor = UIColor.clear
            homeTableCollectionView.delegate = self
            homeTableCollectionView.dataSource = self
            if(indexPath.section == 0) {
                homeTableCollectionView.tag = 1
            }
            else {
                homeTableCollectionView.tag = 2
            }
            
            homeTableCollectionView.isScrollEnabled = true
            cell?.backgroundColor = UIColor(red: 240.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            cell?.addSubview(homeTableCollectionView)
            
            return cell!

        }else{
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cellIdentifier = Constant.customCellNibNames.wereToGoTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! WereWantToGoTableViewCell
                cell.lblCellTitle.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[(indexPath as NSIndexPath).section])"
                cell.lblCellTitle.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.delegate = self
                cell.selectionStyle = .none
                cell.collectionView.collectionViewLayout.invalidateLayout()
                cell.collectionView.reloadData()
                
                return cell
            case 1:
                let cellIdentifier = Constant.customCellNibNames.whereToTradeTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! WereWantToTradeTableViewCell
                cell.lblCellTitle.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[(indexPath as NSIndexPath).row])"
                cell.lblCellTitle.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.selectionStyle = .none
                cell.collectionView.collectionViewLayout.invalidateLayout()
                cell.collectionView.reloadData()
                
                return cell
            case 3:
                let cellIdentifier = Constant.customCellNibNames.searchTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SearchTableViewCell
                cell.selectionStyle = .none
                cell.delegate = self
                
                return cell
            default:
                let cellIdentifier = Constant.customCellNibNames.dateAndPassengerTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DateAndPassengerSelectionTableViewCell
                
                cell.checkInClosestToHeaderLabel.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[2])"
                cell.checkInClosestToHeaderLabel.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.whoIsTravellingHeaderLabel.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[3])"
                cell.whoIsTravellingHeaderLabel.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.selectionStyle = .none
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.vacationSearchShowDate as Date)
                cell.dayName.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                cell.dayDate.text = "\(myComponents.day!)"
                
                cell.year.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(myComponents.year!)"
                cell.delegate = self
                cell.childCountLabel.text = String(self.childCounter)
                cell.adultCountLabel.text = String(self.adultCounter)
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 1){
            return 540
        }else{
            switch (indexPath as NSIndexPath).row{
            case 0:
                return 170
            case 1:
                if(self.segmentIndex == 0 || self.segmentIndex == 2){
                    return 170
                }else{
                    return 0
                }
            case 3:
                return 90
            default:
                return 140
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func MoreNavButtonPressed(_ sender:UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.searchOption, message: "", preferredStyle: .actionSheet)
        
        //***** Create and add the View my recent search *****//
        let viewMyRecentSearchAction: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.viewMyRecentSearches, style: .default) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(viewMyRecentSearchAction)
        //***** Create and add the Reset my search *****//
        let resetMySearchAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.resetMySearch, style: .default) { action -> Void in
            Constant.MyClassConstants.checkInClosestContentArray.removeAllObjects()
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            let realm = try! Realm()
            let allDest = Helper.getLocalStorageWherewanttoGo()
            if (allDest.count > 0) {
                try! realm.write{
                    realm.deleteAll()
                }
            }
            self.searchVacationTableView.reloadData()
        }
        actionSheetController.addAction(resetMySearchAction)
        //***** Create and add help *****//
        let helpAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.help, style: .default) { action -> Void in
        }
        actionSheetController.addAction(helpAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        actionSheetController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width,y: 0, width: 100, height: 60)
        actionSheetController.popoverPresentationController!.permittedArrowDirections = .up;
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    func showTopDeals(){
        
        self.featuredDestinationsTableView.reloadData()
        
        
    }
    
    @IBAction func segementValueDidChange(_ sender: AnyObject) {
        
        self.searchVacationTableView.beginUpdates()
        self.segmentIndex = sender.selectedSegmentIndex
        Constant.MyClassConstants.vacationSearchSelectedSegmentIndex = sender.selectedSegmentIndex
        self.searchVacationTableView.reloadData()
        self.searchVacationTableView.endUpdates()
    }
    
    @IBAction func addDestinationPressed(_ sender: IUIKButton){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as! GoogleMapViewController
        viewController.sourceController = Constant.MyClassConstants.vacationSearch
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addWhereToTradePressed(_ sender: IUIKButton){
        
        
        Constant.MyClassConstants.matrixDataArray.removeAllObjects()
        DirectoryClient.getResortClubPointsChart(UserContext.sharedInstance.accessToken, resortCode:  "EVC", onSuccess:{ (ClubPointsChart) in
            
            if(ClubPointsChart.matrices[0].description == Constant.MyClassConstants.matrixTypeSingle){
                Constant.MyClassConstants.showSegment = false
            }else{
                Constant.MyClassConstants.showSegment = true
            }
            //if(ClubPointsChart.matrices[0].description == Constant.MyClassConstants.matrixTypeSingle || ClubPointsChart.matrices[0].description == Constant.MyClassConstants.matrixTypePremium){
            for matrices in ClubPointsChart.matrices {
                let pointsDictionary = NSMutableDictionary()
                for grids in matrices.grids {
                    
                    Constant.MyClassConstants.fromdatearray.add(grids.fromDate!)
                    Constant.MyClassConstants.todatearray.add(grids.toDate!)
                    
                    for rows in grids.rows
                    {
                        print(rows.units[0].clubPoints)
                        Constant.MyClassConstants.labelarray.add(rows.label!)
                    }
                    let dictKey = "\(grids.fromDate!) - \(grids.toDate!)"
                    pointsDictionary.setObject(grids.rows, forKey: String(describing: dictKey) as NSCopying)
                }
                Constant.MyClassConstants.matrixDataArray.add(pointsDictionary)
            }
            //}
            
            
            let storyboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
            let clubPointselectionViewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController)as? ClubPointSelectionViewController
            self.navigationController?.pushViewController(clubPointselectionViewController!, animated: true)
            
        }, onError:{ (error) in
            
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
            print(error.description)
        })
        
        
        
        //        SVProgressHUD.show()
        //        Helper.addServiceCallBackgroundView(view: self.view)
        //        ExchangeClient.getMyUnits(UserContext.sharedInstance.accessToken, onSuccess: { (Relinquishments) in
        //
        //            DarwinSDK.logger.debug(Relinquishments)
        //            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
        //            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
        //
        //            if(Relinquishments.pointsProgram != nil){
        //                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram!
        //
        //                if (Relinquishments.pointsProgram!.availablePoints != nil) {
        //                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram!.availablePoints!
        //                }
        //
        //            }
        //
        //            SVProgressHUD.dismiss()
        //            Helper.removeServiceCallBackgroundView(view: self.view)
        //            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        //            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as! RelinquishmentSelectionViewController
        //
        //            let transitionManager = TransitionManager()
        //            self.navigationController?.transitioningDelegate = transitionManager
        //            self.navigationController!.pushViewController(viewController, animated: true)
        //
        //        }, onError: {(error) in
        //            
        //            print(error.description)
        //            SVProgressHUD.dismiss()
        //            Helper.removeServiceCallBackgroundView(view: self.view)
        //            
        //        })
    }
    
    @IBAction func featuredDestinationsPressed(_ sender: AnyObject){
        
        if (featuredDestinationsTopConstraint.constant == 0)
        {
            featuredDestinationsTopConstraint.constant = 870
        }
        else {
            
            Helper.getTopDeals(senderVC: self)
            featuredDestinationsTopConstraint.constant = 0;
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension VacationSearchIPadViewController:DateAndPassengerSelectionTableViewCellDelegate {
    
    //Function called when adult stepper is changed.
    func adultStepperChanged(_ value:Int) {
        
        //***** updating adult counter increment and decrement
        self.adultCounter = value
        Constant.MyClassConstants.stepperAdultCurrentValue = value
        if defaults.object(forKey: Constant.MyClassConstants.adultCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.adultCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
            
        else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        self.searchVacationTableView.reloadData()
    }
    //Function called when child stepper value is changed.
    func childrenStepperChanged(_ value:Int) {
        
        //***** Updating children counter increment and decrement
        self.childCounter = value
        Constant.MyClassConstants.stepperChildCurrentValue = value
        if defaults.object(forKey: Constant.MyClassConstants.childCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.childCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        
        self.searchVacationTableView.reloadData()
    }
    //Function that invock when calendar button clicked
    func calendarIconClicked(_ sender:UIButton) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.CalendarViewSegue, sender: nil)
    }
}

extension Foundation.Date {
    
    // MARK: - Dates comparison
    
    func isGreaterThanDate(_ dateToCompare: Foundation.Date) -> Bool {
        
        return self.compare(dateToCompare) == ComparisonResult.orderedDescending
    }
    
    func isLessThanDate(_ dateToCompare: Foundation.Date) -> Bool {
        
        return self.compare(dateToCompare) == ComparisonResult.orderedAscending
    }
    
    func equalToDate(_ dateToCompare: Foundation.Date) -> Bool {
        
        return self.compare(dateToCompare) == ComparisonResult.orderedSame
    }
}

extension VacationSearchIPadViewController:SearchTableViewCellDelegate {
    
    func searchButtonClicked(_ sender : IUIKButton) {
        
        
        if (self.segmentIndex == 1 && (Helper.getAllDestinationFromLocalStorage().count>0 || Helper.getAllResortsFromLocalStorage().count>0)) {
            
            sender.isEnabled = false
            SVProgressHUD.show()
            
            var fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow/2), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
            
            var toDate:Date!
            if (fromDate.isGreaterThanDate(Constant.MyClassConstants.todaysDate as Date)) {
                
                toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: (Constant.MyClassConstants.totalWindow/2), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
            }
            else {
                _ = Helper.getDifferenceOfDates()
                fromDate = Constant.MyClassConstants.todaysDate as Date
                toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: (Constant.MyClassConstants.totalWindow) + Helper.getDifferenceOfDates(), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
            }
            
            if (toDate.isGreaterThanDate(Constant.MyClassConstants.dateAfterTwoYear!)) {
                
                toDate = Constant.MyClassConstants.dateAfterTwoYear
                fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow) + Helper.getDifferenceOfDatesAhead(), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
            }
            
            Constant.MyClassConstants.currentFromDate = fromDate
            Constant.MyClassConstants.currentToDate = toDate
            let searchDateRequest = RentalSearchDatesRequest()
            searchDateRequest.checkInToDate = toDate
            searchDateRequest.checkInFromDate = fromDate
            searchDateRequest.destinations = Helper.getAllDestinationFromLocalStorage()
            searchDateRequest.resorts = Helper.getAllResortsFromLocalStorage()
            if Reachability.isConnectedToNetwork() == true {
                
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: searchDateRequest, onSuccess:{ (searchDates) in
                    var combinedSearchDates = [Date]()
                    combinedSearchDates = searchDates.checkInDates.map { $0 }
                    combinedSearchDates.append(contentsOf: searchDates.surroundingCheckInDates.map { $0 })
                    
                    var combinedResortCodes = [String]()
                    combinedResortCodes = searchDates.resortCodes.map { $0 } + searchDates.surroundingResortCodes.map { $0 }
                    
                    Constant.MyClassConstants.combinedCheckInDates = searchDates.checkInDates
                    Constant.MyClassConstants.surroundingCheckInDates = searchDates.surroundingCheckInDates.map { $0 }
                    Constant.MyClassConstants.checkInDates = combinedSearchDates
                    Constant.MyClassConstants.resortCodesArray = combinedResortCodes
                    Constant.MyClassConstants.surroundingResortCodesArray = searchDates.surroundingResortCodes.map { $0 }
                    sender.isEnabled = true
                    if(searchDates.checkInDates.count == 0) {
                        
                        SVProgressHUD.dismiss()
                        SimpleAlert.alert(self, title: Constant.AlertErrorMessages.noResultError, message: Constant.AlertMessages.noResultMessage)
                    }
                    else {
                        var calendar = Calendar.current
                        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                        let result = Constant.MyClassConstants.checkInDates.filter { calendar.isDate($0, equalTo: Constant.MyClassConstants.vacationSearchShowDate, toGranularity:.day) }
                        if result.count == 0{
                            
                            Constant.MyClassConstants.resortsArray.removeAll()
                            Constant.MyClassConstants.checkInDates.insert(Constant.MyClassConstants.vacationSearchShowDate, at: 0)
                            
                            if let dateToSelect = Constant.MyClassConstants.checkInDates.index(of: Constant.MyClassConstants.vacationSearchShowDate) {
                                Constant.MyClassConstants.searchResultCollectionViewScrollToIndex = dateToSelect + 1
                            }
                            
                            Constant.MyClassConstants.showAlert = true
                            SVProgressHUD.dismiss()
                            Helper.removeServiceCallBackgroundView(view: self.view)
                            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
                        }
                        else {
                            
                            if let dateToSelect = Constant.MyClassConstants.checkInDates.index(of: Constant.MyClassConstants.vacationSearchShowDate) {
                                Constant.MyClassConstants.searchResultCollectionViewScrollToIndex = dateToSelect + 1
                                Constant.MyClassConstants.showAlert = false
                                Helper.resortDetailsClicked(toDate: Constant.MyClassConstants.checkInDates[dateToSelect] as NSDate, senderVC: self)
                            }
                            else {
                                Constant.MyClassConstants.searchResultCollectionViewScrollToIndex = 1
                                Helper.resortDetailsClicked(toDate: Constant.MyClassConstants.checkInDates[0] as NSDate, senderVC: self)
                            }
                        }
                    }
                    
                })
                { (error) in
                    
                    SVProgressHUD.dismiss()
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
            }
            else {
                
            }
        }
        else if(self.segmentIndex == 1){
            SimpleAlert.alert(self, title: Constant.AlertMessages.searchVacationTitle, message: Constant.AlertMessages.searchVacationMessage)
        }
        
    }
}

//Extension for collection view.
extension VacationSearchIPadViewController:UICollectionViewDelegate {
}

extension VacationSearchIPadViewController:UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(Constant.MyClassConstants.topDeals != nil){
            return Constant.MyClassConstants.topDeals.count
        }else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        
        let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
        let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 180) )
        resortFlaxImageView.backgroundColor = UIColor.lightGray
        let rentalDeal:RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
        resortFlaxImageView.setImageWith(URL(string: (rentalDeal.image?.url!)!), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
            if (error != nil) {
                resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
            }
        }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        cell.addSubview(resortFlaxImageView)
        
        
        if(collectionView.tag == 1 && self.showExchange == true) {
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 50))
            
            resortImageNameLabel.text = topTenDeals.header!
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
        }
        else {
            
            
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 50))
            
            resortImageNameLabel.text = topTenDeals.header!
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            
            
            let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
            centerView.center = resortFlaxImageView.center
            centerView.backgroundColor = Constant.RGBColorCode.centerViewRgb
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 10, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = topTenDeals.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 12)
            unitLabel.textColor = UIColor.white
            unitLabel.backgroundColor = UIColor.clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: centerView.frame.size.width - 20, height: 20))
            priceLabel.text = "From " + String(describing: topTenDeals.price!.price) + " Wk."
            priceLabel.numberOfLines = 2
            priceLabel.textAlignment = NSTextAlignment.center
            priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
            priceLabel.textColor = UIColor.white
            priceLabel.backgroundColor = UIColor.clear
            centerView.addSubview(priceLabel)
            
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            
            
            cell.addSubview(centerView)
            
        }
        
        
        return cell
    }
    
}

extension VacationSearchIPadViewController:WereWantToGoTableViewCellDelegate {
    
    func multipleResortInfoButtonPressedAtIndex(_ Index: Int) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
        viewController.selectedIndex = Index
        
        let resortsArray:NSMutableArray = []
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAllObjects()
        //outer loop for all object in where to go content array
        
        for object in Constant.MyClassConstants.whereTogoContentArray {
            if ((object as AnyObject).isKind(of: List<ResortByMap>.self)){
                //internal loop for array of resorts at index
                for resortsToShow in object as! List<ResortByMap>{
                    
                    let resort = Resort()
                    resort.resortName = resortsToShow.resortName
                    resort.resortCode = resortsToShow.resortCode
                    resort.address?.city = resortsToShow.resortCityName
                    resort.address?.territory = resortsToShow.territorrycode
                    
                    resortsArray.add(resort)
                    
                }
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(resortsArray)
            }
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(object)
        }
        
        
        self.navigationController!.present(viewController, animated: true, completion: nil)
    }
}
