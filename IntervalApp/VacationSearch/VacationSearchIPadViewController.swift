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
    let dateString = ""
    
    //***** class variables *****//
    var childCounter = 0
    var adultCounter = 2
    var segmentTitle = ""
    var segmentIndex = 0
    var moreButton:UIBarButtonItem?
    var value:Bool! = true
    let defaults = UserDefaults.standard
    var rentalHasNotAvailableCheckInDates : Bool = false
    var exchangeHasNotAvailableCheckInDates : Bool = false
    
    var showGetaways = true
    var showExchange = true
    //var vacationSearch = VacationSearch()
    
    override func viewDidAppear(_ animated: Bool) {
        self.getVacationSearchDetails()
        Helper.InitializeArrayFromLocalStorage()
        Helper.InitializeOpenWeeksFromLocalStorage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchVacationSegementControl.removeAllSegments()
        
        // updating segment control number of segment according to app settings response
        for i in 0 ..< (UserContext.sharedInstance.appSettings?.vacationSearch?.vacationSearchTypes.count)! {
            
            let type = UserContext.sharedInstance.appSettings?.vacationSearch?.vacationSearchTypes[i]
            self.searchVacationSegementControl.insertSegment(withTitle: Helper.vacationSearchTypeSegemtStringToDisplay(vacationSearchType: type!), at: i, animated: true)
            
            self.searchVacationSegementControl.selectedSegmentIndex = 0
            self.segmentTitle = searchVacationSegementControl.titleForSegment(at: 0)!
        }
        
        var isPrePopulatedData =  Constant.AlertPromtMessages.no
        self.searchVacationTableView.estimatedRowHeight = 100
        
        if(Constant.MyClassConstants.whereTogoContentArray.count > 0 || Constant.MyClassConstants.whatToTradeArray.count > 0) {
            
            isPrePopulatedData = Constant.AlertPromtMessages.yes
        }

        // omniture tracking with event 87
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar20 : isPrePopulatedData,
            Constant.omnitureEvars.eVar21 : Constant.MyClassConstants.selectedDestinationNames,
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
        ]

        ADBMobile.trackAction(Constant.omnitureEvents.event87, data: userInfo)
        
        Helper.getTopDeals(senderVC: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
        
        self.getVacationSearchDetails()
        
        
        if(segmentIndex != 2) {
            
            //***** Registering the custom cell with UITabelview *****//
            let cellNib = UINib(nibName:Constant.customCellNibNames.whoIsTravelingCell, bundle: nil)
            self.searchVacationTableView!.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.whoIsTravelingCell)
        }

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
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
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
        if((self.segmentTitle == "Search Both" || self.segmentTitle == "Exchange") && tableView.tag != 1){
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
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.view.bounds.width - 30, height: 50))
        
        if(self.segmentIndex != 1) {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.fourSegmentHeaderTextArray[section]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
        else {
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.threeSegmentHeaderTextArray[section]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 1) {
            let cellIdentifier = Constant.customCellNibNames.featuredTableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            if(indexPath.section == 1){
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: (cell?.contentView.frame.width)! - 20, height: 20))
                resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                cell?.addSubview(resortImageNameLabel)
            }else{
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: (cell?.contentView.frame.width)! - 20, height: 20))
                if showExchange == false {
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                } else {
                    resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                }
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                cell?.addSubview(resortImageNameLabel)
            }
            
            //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width:280, height: 175)
            // layout.minimumInteritemSpacing = 1.0
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0.0001
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 30, width: self.view.bounds.width, height: 380), collectionViewLayout: layout)
            
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
            return 410
        }else{
            switch (indexPath as NSIndexPath).row{
            case 0:
                return 170
            case 1:
                if(self.segmentTitle == "Search Both" || self.segmentTitle == "Exchange"){
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
        
        //self.searchVacationTableView.beginUpdates()

        self.segmentTitle = searchVacationSegementControl.titleForSegment(at: sender.selectedSegmentIndex)!
        
        Constant.MyClassConstants.vacationSearchSelectedSegmentIndex = sender.selectedSegmentIndex
        
        self.segmentIndex = sender.selectedSegmentIndex
        
        switch segmentTitle {
        case Constant.segmentControlItems.searchBoth:
            showGetaways = true
            showExchange = true
            break
        case Constant.segmentControlItems.getaways:
            showGetaways = true
            showExchange = false
            break
        case Constant.segmentControlItems.exchange:
            showGetaways = false
            showExchange = true
            break
        default:
            break
        }
        
        
        self.searchVacationTableView.reloadData()
        //self.searchVacationTableView.endUpdates()
        featuredDestinationsTableView.reloadData()
        
        // omniture tracking with event 63
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar24 : Helper.selectedSegment(index: sender.selectedSegmentIndex)
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event63, data: userInfo)
    }
    
    @IBAction func addDestinationPressed(_ sender: IUIKButton){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as! GoogleMapViewController
        viewController.sourceController = Constant.MyClassConstants.vacationSearch
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        let navController = UINavigationController(rootViewController: viewController)
        self.navigationController!.present(navController, animated: true)
    }
    
    @IBAction func addWhereToTradePressed(_ sender: IUIKButton){
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: self.view)
        ExchangeClient.getMyUnits(UserContext.sharedInstance.accessToken, onSuccess: { (Relinquishments) in
            
            DarwinSDK.logger.debug(Relinquishments)
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if(Relinquishments.pointsProgram != nil){
                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram!
                
                if (Relinquishments.pointsProgram!.availablePoints != nil) {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram!.availablePoints!
                }
                
            }
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as! RelinquishmentSelectionViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            let navController = UINavigationController(rootViewController: viewController)
            self.navigationController!.present(navController, animated: true)
            
        }, onError: {(error) in
            
            print(error.description)
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            
        })
    }
    
    @IBAction func featuredDestinationsPressed(_ sender: AnyObject){
        
        if (featuredDestinationsTopConstraint.constant == 50)
        {
            featuredDestinationsTopConstraint.constant = 870
        }
        else {
            
            Helper.getTopDeals(senderVC: self)
            featuredDestinationsTopConstraint.constant = 50;
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func executeExchangeSearchDates() {
        
        ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
                                   onSuccess: { (response) in
                                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                    
                                    // Get activeInterval
                                    let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                    
                                    // Update active interval
                                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                    
                                    // Check not available checkIn dates for the active interval
                                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                        
                                        // We do not have available CheckInDates in Rental and Exchange
                                        if (self.rentalHasNotAvailableCheckInDates) {
                                            Helper.showNotAvailabilityResults()
                                        }
                                        
                                    } else {
                                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format: Constant.MyClassConstants.dateFormat) , senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    }
                                    
                                    //expectation.fulfill()
        },
                                   onError:{ (error) in
                                    DarwinSDK.logger.error("Error Code: \(error.code)")
                                    DarwinSDK.logger.error("Error Description: \(error.description)")
                                    
                                    // TODO: Handle SDK/API errors
                                    DarwinSDK.logger.error("Handle SDK/API errors.")
                                    
                        
        }
        )
        
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
    
    func getSavedDestinationsResorts(storedData:Results <RealmLocalStorage>, searchCriteria:VacationSearchCriteria){
        if((storedData.first?.destinations.count)! > 0){
            let destination = AreaOfInfluenceDestination()
            destination.destinationName  = storedData[0].destinations[0].destinationName
            destination.destinationId = storedData[0].destinations[0].destinationId
            destination.aoiId = storedData[0].destinations[0].aoid
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        }else if((storedData.first?.resorts.count)! > 0){
            
            if((storedData.first?.resorts[0].resortArray.count)! > 0){
                var resorts = [Resort]()
                for resortDetails in (storedData.first?.resorts[0].resortArray)!{
                    let resort = Resort()
                    resort.resortName = storedData[0].resorts[0].resortName
                    resort.resortCode = storedData[0].resorts[0].resortCode
                    resorts.append(resort)
                }
                searchCriteria.resorts = resorts
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(String(describing: storedData.first?.resorts[0].resortArray[0].resortName)) + more"
                
            }else{
                let resort = Resort()
                resort.resortName = storedData[0].resorts[0].resortName
                resort.resortCode = storedData[0].resorts[0].resortCode
                searchCriteria.resorts = [resort]
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName!
            }
        }
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
        
        //Set travel PartyInfo
        let travelPartyInfo = TravelParty()
        travelPartyInfo.adults = Int(self.adultCounter)
        travelPartyInfo.children = Int(self.childCounter)
        
        Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
        
        Helper.helperDelegate = self
        ADBMobile.trackAction(Constant.omnitureEvents.event1, data: nil)
        
        if(Constant.MyClassConstants.whereTogoContentArray.contains(Constant.MyClassConstants.allDestinations) ){
            
            let (_,fromDateTop) = getSearchDatesTop()
            var searchType: VacationSearchType
            let settings = Helper.createSettings()
      
            
            let checkInDate = fromDateTop
            
            let bookingWindow = BookingWindow()
            bookingWindow.calculateIntervals(checkInDate: checkInDate)
            
            let activeInterval = bookingWindow.getActiveInterval()
            let requestRental = RentalSearchRegionsRequest()
            let requestExchange = ExchangeSearchRegionsRequest()
        
            if(segmentTitle == Constant.segmentControlItems.exchange){
                
                searchType = VacationSearchType.Exchange
                requestExchange.checkInFromDate = activeInterval?.startDate
                requestExchange.checkInToDate = activeInterval?.endDate
            }
            else{
                
                searchType = VacationSearchType.Rental
                requestRental.checkInFromDate = activeInterval?.startDate
                requestRental.checkInToDate = activeInterval?.endDate
            }
            
            
            Helper.showProgressBar(senderView: self)
            sender.isEnabled = false
            Constant.MyClassConstants.regionArray.removeAll()
            Constant.MyClassConstants.regionAreaDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeArray.removeAllObjects()
            
            if ((settings.vacationSearch?.vacationSearchTypes.contains(searchType.rawValue))! && searchType.isRental()) {
                RentalClient.searchRegions(UserContext.sharedInstance.accessToken, request: requestRental, onSuccess: {(response)in
                    print(response)
                    
                    for rsregion in response {
                        let region = Region()
                        region.regionName = rsregion.regionName
                        region.regionCode = rsregion.regionCode
                        region.areas = rsregion.areas
                        Constant.MyClassConstants.regionArray.append(rsregion)
                        Helper.hideProgressBar(senderView: self)
                        
                    }
                    Helper.hideProgressBar(senderView: self)
                    sender.isEnabled = true
                    self.performSegue(withIdentifier:"allAvailableDestination", sender: self)
                    Constant.MyClassConstants.isFromExchangeAllavialble = false
                    
                }, onError: { (error) in
                    sender.isEnabled = true
                    print(error)
                })
            }else{
                
                if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                    
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    Helper.hideProgressBar(senderView: self)
                    sender.isEnabled = true
                    
                }else{
                    
                    ExchangeClient.searchRegions(UserContext.sharedInstance.accessToken, request: requestExchange, onSuccess: { (response) in
                        
                        print(response)
                        
                        for rsregion in response {
                            let region = Region()
                            region.regionName = rsregion.regionName
                            region.regionCode = rsregion.regionCode
                            region.areas = rsregion.areas
                            Constant.MyClassConstants.regionArray.append(rsregion)
                            Helper.hideProgressBar(senderView: self)
                            
                        }
                        Helper.hideProgressBar(senderView: self)
                        sender.isEnabled = true
                        Constant.MyClassConstants.isFromExchangeAllavialble = true
                        self.performSegue(withIdentifier:"allAvailableDestination", sender: self)
                        
                        
                    }, onError: { (error) in
                        
                        print(error)
                    })
                }
                
            }
        } else {
            
            if (self.segmentTitle == Constant.segmentControlItems.getaways && (Helper.getAllResortsFromLocalStorage().count>0 || Constant.MyClassConstants.whereTogoContentArray.count>0)) {
                
                Helper.showProgressBar(senderView: self)
                sender.isEnabled = false
                
                if Reachability.isConnectedToNetwork() == true{
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    
                    if(storedData.count > 0) {
                        
                        let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
                        self.getSavedDestinationsResorts(storedData:storedData, searchCriteria:rentalSearchCriteria)
                        
                        rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        
                        
                        Constant.MyClassConstants.initialVacationSearch = VacationSearch(UserContext.sharedInstance.appSettings, rentalSearchCriteria)
                        
                        
                        
                        RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                                 onSuccess: { (response) in
                                                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                                    
                                                    // Get activeInterval
                                                    let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                                    
                                                    // Update active interval
                                                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                                    
                                                    // Always show a fresh copy of the Scrolling Calendar
                                                    
                                                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                    
                                                    // Check not available checkIn dates for the active interval
                                                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                                        Helper.showNotAvailabilityResults()
                                                    } else {
                                                        
                                                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                                        let initialSearchCheckInDate = Helper.convertStringToDate(dateString:Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!,format:Constant.MyClassConstants.dateFormat)
                                                        Constant.MyClassConstants.checkInDates = response.checkInDates
                                                        sender.isEnabled = true
                                                        Helper.helperDelegate = self
                                                        Helper.hideProgressBar(senderView: self)
                                                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: initialSearchCheckInDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                    }
                        },
                                                 onError:{ (error) in
                                                    Helper.hideProgressBar(senderView: self)
                                                    sender.isEnabled = true
                                                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                        }
                        )
                    }
                } else{
                    sender.isEnabled = true
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.networkError)
                }
                
                Constant.MyClassConstants.isFromExchange = false
                
                
                
            } else if(self.segmentTitle == Constant.segmentControlItems.exchange && (Helper.getAllDestinationFromLocalStorage().count>0 || Helper.getAllResortsFromLocalStorage().count>0)){
                
                if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                    sender.isEnabled = true
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                }else{
                    sender.isEnabled = false
                    Helper.showProgressBar(senderView: self)
                    
                    
                    let travelPartyInfo = TravelParty()
                    travelPartyInfo.adults = Int(self.adultCounter)
                    travelPartyInfo.children = Int(self.childCounter)
                    
                    Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
                    
                    if Reachability.isConnectedToNetwork() == true {
                        
                        let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
                        
                        //exchangeSearchCriteria.relinquishmentsIds = ["Ek83chJmdS6ESNRpVfhH8XUt24BdWzaYpSIODLB0Scq6rxirAlGksihR1PCb1xSC"]
                        exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                        exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                        exchangeSearchCriteria.searchType = VacationSearchType.Exchange
                        
                        let storedData = Helper.getLocalStorageWherewanttoGo()
                        
                        if(storedData.count > 0) {
                            
                            self.getSavedDestinationsResorts(storedData:storedData, searchCriteria:exchangeSearchCriteria)
                            
                            
                            Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(UserContext.sharedInstance.appSettings, exchangeSearchCriteria)
                            
                            ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                                
                                sender.isEnabled = true
                                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                
                                // Get activeInterval (or initial search interval)
                                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                
                                // Update active interval
                                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                
                                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                
                                // Check not available checkIn dates for the active interval
                                if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                    Helper.showNotAvailabilityResults()
                                }
                                
                                Helper.hideProgressBar(senderView: self)
                                
                                if (activeInterval?.hasCheckInDates())!{
                                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                    let initialSearchCheckInDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format: Constant.MyClassConstants.dateFormat)
                                    
                                    Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate:initialSearchCheckInDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    
                                }else{
                                    Helper.hideProgressBar(senderView: self)
                                    Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate:exchangeSearchCriteria.checkInDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                }
                                
                            }, onError: { (error) in
                                sender.isEnabled = true
                                Helper.hideProgressBar(senderView: self)
                                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.noResultError)
                            })
                        }}else{
                        Helper.hideProgressBar(senderView: self)
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.networkError)
                    }
                    
                }
                Constant.MyClassConstants.isFromExchange = true
            } else{
                Constant.MyClassConstants.isFromSearchBoth = true
                if(self.segmentTitle == Constant.segmentControlItems.getaways){
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                }else if(self.segmentTitle == Constant.segmentControlItems.exchange){
                    if((Helper.getAllDestinationFromLocalStorage().count == 0 && Helper.getAllResortsFromLocalStorage().count == 0)){
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                    }else if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    }else{
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                    }
                }else{
                    
                    if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                        sender.isEnabled = true
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                        
                        
                    }else if((Helper.getAllDestinationFromLocalStorage().count == 0 && Helper.getAllResortsFromLocalStorage().count == 0)){
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                    } else {
                        
                        Helper.showProgressBar(senderView: self)
                        let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Combined)
                        let storedData = Helper.getLocalStorageWherewanttoGo()
                        
                        if(storedData.count > 0) {
                            self.getSavedDestinationsResorts(storedData:storedData, searchCriteria:rentalSearchCriteria)
                            
                            let travelPartyInfo = TravelParty()
                            travelPartyInfo.adults = Int(self.adultCounter)
                            travelPartyInfo.children = Int(self.childCounter)
                            
                            Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
                            rentalSearchCriteria.relinquishmentsIds = ["Ek83chJmdS6ESNRpVfhH8XUt24BdWzaYpSIODLB0Scq6rxirAlGksihR1PCb1xSC"]//Constant.MyClassConstants.relinquishmentIdArray as? [String]
                            rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                            rentalSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo                    //rentalSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                            
                            Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(UserContext.sharedInstance.appSettings, rentalSearchCriteria)
                            
                            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
                            
                            
                            RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                                
                                Helper.hideProgressBar(senderView: self)
                                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                // Update active interval
                                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                Helper.helperDelegate = self
                                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                // Check not available checkIn dates for the active interval
                                if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                    Helper.hideProgressBar(senderView: self)
                                    self.rentalHasNotAvailableCheckInDates = true
                                }else{
                                    Helper.hideProgressBar(senderView: self)
                                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                    let vacationSearchInitialDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: vacationSearchInitialDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                }
                                Constant.MyClassConstants.checkInDates = response.checkInDates
                                sender.isEnabled = true
                                
                            })
                            { (error) in
                                
                                Helper.hideProgressBar(senderView: self)
                                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                            }
                            
                        }
                        
                    }
                    
                    
                }
            }
        }
        
        
        
    }
}


//Extension for collection view.
extension VacationSearchIPadViewController:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.topTenGetawaySelected(selectedIndexPath: indexPath)
    }
}

extension VacationSearchIPadViewController:UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 && showExchange == true {
            return Constant.MyClassConstants.flexExchangeDeals.count
        } else {
            return Constant.MyClassConstants.topDeals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }

        if(collectionView.tag == 1 && self.showExchange == true) {
            let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 175) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            
            if let imgURL = flexDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                resortFlaxImageView.contentMode = .center
            }
            
            cell.addSubview(resortFlaxImageView)
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.midY - 25, width: cell.contentView.frame.width - 20, height: 50))
            resortImageNameLabel.text = flexDeal.name
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.white
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
        }
        else {
            let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 125) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            let rentalDeal:RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
            resortFlaxImageView.setImageWith(URL(string: (rentalDeal.images[0].url) ?? ""), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                if (error != nil) {
                    resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    resortFlaxImageView.contentMode = .center
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            cell.addSubview(resortFlaxImageView)

            
            
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
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 15, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = topTenDeals.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 12)
            unitLabel.textColor = UIColor.white
            unitLabel.backgroundColor = UIColor.clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 35, width: centerView.frame.size.width - 20, height: 20))
            priceLabel.text = "From $" + String(describing: topTenDeals.price!.fromPrice) + " Wk."
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
                    resort.address?.cityName = resortsToShow.resortCityName
                    resort.address?.territoryCode = resortsToShow.territorrycode
                    
                    resortsArray.add(resort)
                    
                }
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(resortsArray)
            }
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(object)
        }
        
        
        self.navigationController!.present(viewController, animated: true, completion: nil)
    }
    
    
    func searchAvailability(exchangeAvailabilityRequest:ExchangeSearchAvailabilityRequest, sender:IUIKButton){
        ExchangeClient.searchAvailability(UserContext.sharedInstance.accessToken, request: exchangeAvailabilityRequest, onSuccess: { (exchangeAvailability) in
            Helper.hideProgressBar(senderView: self)
            Constant.MyClassConstants.showAlert = false
            Constant.MyClassConstants.resortsArray.removeAll()
            Constant.MyClassConstants.exchangeInventory.removeAll()
            for exchangeResorts in exchangeAvailability{
                Constant.MyClassConstants.resortsArray.append(exchangeResorts.resort!)
                Constant.MyClassConstants.exchangeInventory.append(exchangeResorts.inventory!)
            }
            if(Constant.MyClassConstants.resortsArray.count == 0){
                Constant.MyClassConstants.showAlert = true
            }
            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
        }, onError: { (error) in
            Helper.hideProgressBar(senderView: self)
            sender.isEnabled = true
            Constant.MyClassConstants.showAlert = true
            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
        })
    }
    
    
}

// Mark: Extension for Helper
extension VacationSearchIPadViewController:HelperDelegate {
    func resortSearchComplete(){
        if (Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat) ) {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
    }
    func resetCalendar(){
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
    }
}
