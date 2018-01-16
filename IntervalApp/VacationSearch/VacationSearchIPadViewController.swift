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

class VacationSearchIPadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //***** Outlets *****//
    @IBOutlet weak var searchVacationSegementControl: UISegmentedControl!
    @IBOutlet weak var searchVacationTableView: UITableView!
    @IBOutlet weak var featuredDestinationsTableView: UITableView!
    @IBOutlet weak var featuredDestinationsTopConstraint: NSLayoutConstraint!
    @IBOutlet var homeTableCollectionView: UICollectionView!
    let dateString = ""
    
    //***** class variables *****//
    var childCounter = 0
    var adultCounter = 2
    var segmentTitle = ""
    var segmentIndex = 0
    var moreButton: UIBarButtonItem?
    var value = true
    let defaults = UserDefaults.standard
    var rentalHasNotAvailableCheckInDates: Bool = false
    var exchangeHasNotAvailableCheckInDates: Bool = false
    
    var showGetaways = true
    var showExchange = true
    //var vacationSearch = VacationSearch()
    
    override func viewDidAppear(_ animated: Bool) {
        getVacationSearchDetails()
        Helper.InitializeArrayFromLocalStorage()
        Helper.InitializeOpenWeeksFromLocalStorage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchVacationSegementControl.removeAllSegments()
        
        // updating segment control number of segment according to app settings response
        for i in 0 ..< (Session.sharedSession.appSettings?.vacationSearch?.vacationSearchTypes.count)! {
            
            let type = Session.sharedSession.appSettings?.vacationSearch?.vacationSearchTypes[i]
            searchVacationSegementControl.insertSegment(withTitle: Helper.vacationSearchTypeSegemtStringToDisplay(vacationSearchType: type!), at: i, animated: true)
            
            searchVacationSegementControl.selectedSegmentIndex = 0
            segmentTitle = searchVacationSegementControl.titleForSegment(at: 0)!
        }
        
        var isPrePopulatedData = Constant.AlertPromtMessages.no
        searchVacationTableView.estimatedRowHeight = 100
        
        if Constant.MyClassConstants.whereTogoContentArray.count > 0 || Constant.MyClassConstants.whatToTradeArray.count > 0 {
            
            isPrePopulatedData = Constant.AlertPromtMessages.yes
        }
        
        // omniture tracking with event 87
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar20: isPrePopulatedData,
            Constant.omnitureEvars.eVar21: Constant.MyClassConstants.selectedDestinationNames,
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event87, data: userInfo)
        
        Helper.getTopDeals(senderVC: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
        
        getVacationSearchDetails()
        
        if segmentIndex != 2 {
            
            //***** Registering the custom cell with UITabelview *****//
            let cellNib = UINib(nibName: Constant.customCellNibNames.whoIsTravelingCell, bundle: nil)
            searchVacationTableView!.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.whoIsTravelingCell)
        }
        
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape == true {
            
            homeTableCollectionView.frame = CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 270)
            homeTableCollectionView.reloadData()
            searchVacationTableView.reloadData()
        } else {
            
            homeTableCollectionView.frame = CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 490)
            homeTableCollectionView.reloadData()
            searchVacationTableView.reloadData()
        }
        
    }
    
    func getVacationSearchDetails() {
        
        if let selecteddate = defaults.object(forKey: Constant.MyClassConstants.selectedDate) {
            if (selecteddate as! Date).isLessThanDate(Constant.MyClassConstants.todaysDate as Date) {
                Constant.MyClassConstants.vacationSearchShowDate = Constant.MyClassConstants.todaysDate
            } else {
                Constant.MyClassConstants.vacationSearchShowDate = selecteddate as! Date
            }
        } else {
            let date = Date()
            Constant.MyClassConstants.vacationSearchShowDate = date
            defaults.set(date, forKey: Constant.MyClassConstants.selectedDate)
        }
        
        if let childct = defaults.object(forKey: Constant.MyClassConstants.childCounterString) {
            
            childCounter = childct as! Int
            Constant.MyClassConstants.stepperChildCurrentValue = childCounter
        }
        if let adultct = defaults.object(forKey: Constant.MyClassConstants.adultCounterString) {
            
            adultCounter = adultct as! Int
            Constant.MyClassConstants.stepperAdultCurrentValue = adultCounter
        }
        searchVacationTableView.reloadData()
    }
    
    func refreshTableView() {
        featuredDestinationsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        Constant.MyClassConstants.topDeals = []
        
        if let rvc = revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.parent!.navigationItem.leftBarButtonItem = menuButton
            
            moreButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action: #selector(moreNavButtonPressed(_:)))
            
            moreButton!.tintColor = UIColor.white
            
            self.parent!.navigationItem.rightBarButtonItem = moreButton
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
        
        searchVacationTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView.tag == 1 {
            
            if showGetaways == true && showExchange == true {
                return 2
            } else if showGetaways == false && showExchange == false {
                return 0
            } else {
                return 1
            }
        } else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentTitle == "Search Both" || segmentTitle == "Exchange") && tableView.tag != 1 {
            return 4
        } else if tableView.tag == 1 {
            return 1
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 {
            return 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.view.bounds.width - 30, height: 50))
        
        if segmentIndex != 1 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.fourSegmentHeaderTextArray[section]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        } else {
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.threeSegmentHeaderTextArray[section]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            let cellIdentifier = Constant.customCellNibNames.featuredTableViewCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else { return UITableViewCell() }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            if indexPath.section == 1 {
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                cell.addSubview(resortImageNameLabel)
            } else {
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                if showExchange == false {
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                } else {
                    resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                }
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                cell.addSubview(resortImageNameLabel)
            }
            
            //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: 280, height: 175)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0.0001
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 30, width: self.view.bounds.width, height: 380), collectionViewLayout: layout)
            
            homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            homeTableCollectionView.backgroundColor = UIColor.clear
            homeTableCollectionView.delegate = self
            homeTableCollectionView.dataSource = self
            if indexPath.section == 0 && (!showGetaways || (showGetaways && showExchange)) {
                homeTableCollectionView.tag = 1
            } else {
                homeTableCollectionView.tag = 2
            }
            
            homeTableCollectionView.isScrollEnabled = true
            cell.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            cell.addSubview(homeTableCollectionView)
            
            return cell
            
        } else {
            switch indexPath.row {
            case 0:
                let cellIdentifier = Constant.customCellNibNames.wereToGoTableViewCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WereWantToGoTableViewCell else { return UITableViewCell() }
                cell.lblCellTitle.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[indexPath.section])"
                cell.lblCellTitle.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.delegate = self
                cell.selectionStyle = .none
                cell.collectionView.collectionViewLayout.invalidateLayout()
                cell.collectionView.reloadData()
                
                return cell
            case 1:
                let cellIdentifier = Constant.customCellNibNames.whereToTradeTableViewCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WereWantToTradeTableViewCell else { return UITableViewCell() }
                cell.lblCellTitle.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[indexPath.row])"
                cell.lblCellTitle.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.selectionStyle = .none
                cell.collectionView.collectionViewLayout.invalidateLayout()
                cell.collectionView.reloadData()
                
                return cell
            case 3:
                let cellIdentifier = Constant.customCellNibNames.searchTableViewCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchTableViewCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.delegate = self
                
                return cell
            default:
                let cellIdentifier = Constant.customCellNibNames.dateAndPassengerTableViewCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DateAndPassengerSelectionTableViewCell else { return UITableViewCell() }
                
                cell.checkInClosestToHeaderLabel.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[2])"
                cell.checkInClosestToHeaderLabel.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.whoIsTravellingHeaderLabel.text = "  \(Constant.MyClassConstants.fourSegmentHeaderTextArray[3])"
                cell.whoIsTravellingHeaderLabel.backgroundColor = IUIKColorPalette.titleBackdrop.color
                cell.selectionStyle = .none

               
                let myComponents = Calendar.current.dateComponents([.day, .weekday, .month, .year], from: Constant.MyClassConstants.vacationSearchShowDate)
                cell.dayName.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday ?? 0))".localized()
                cell.dayDate.text = "\(myComponents.day ?? 0)".localized()
                
                cell.year.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) \(myComponents.year ?? 0)".localized()
                cell.delegate = self
                cell.childCountLabel.text = String(childCounter)
                cell.adultCountLabel.text = String(adultCounter)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 1 {
            return 410
        } else {
            switch indexPath.row {
            case 0:
                return 170
            case 1:
                if segmentTitle == "Search Both" || segmentTitle == "Exchange" {
                    return 170
                } else {
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
    func moreNavButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheetController = UIAlertController(title: "", message: Constant.buttonTitles.searchOption, preferredStyle: .actionSheet)
        
        let attributedText = NSMutableAttributedString(string: Constant.buttonTitles.searchOption)
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSKernAttributeName, value: 1.5, range: range)
        if let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 18.0) {
            attributedText.addAttribute(NSFontAttributeName, value: font, range: range)
            actionSheetController.setValue(attributedText, forKey: "attributedMessage")
        }
        //***** Create and add the Reset my search *****//
        let resetMySearchAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.resetMySearch, style: .default) { _ -> Void in
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Helper.deleteObjectsFromLocalStorage()
            self.searchVacationTableView.reloadData()
        }
        actionSheetController.addAction(resetMySearchAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { _ -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        actionSheetController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width, y: 0, width: 100, height: 60)
        actionSheetController.popoverPresentationController!.permittedArrowDirections = .up
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    func showTopDeals() {
        featuredDestinationsTableView.reloadData()
    }
    
    @IBAction func segementValueDidChange(_ sender: AnyObject) {
        
        segmentTitle = searchVacationSegementControl.titleForSegment(at: sender.selectedSegmentIndex)!
        
        Constant.MyClassConstants.vacationSearchSelectedSegmentIndex = sender.selectedSegmentIndex
        
        segmentIndex = sender.selectedSegmentIndex
        
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
        
        searchVacationTableView.reloadData()
        featuredDestinationsTableView.reloadData()
        
        // omniture tracking with event 63
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar24: Helper.selectedSegment(index: sender.selectedSegmentIndex)
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event63, data: userInfo)
    }
    
    @IBAction func addDestinationPressed(_ sender: IUIKButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as! GoogleMapViewController
        viewController.sourceController = Constant.MyClassConstants.vacationSearch
       Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearch
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addWhereToTradePressed(_ sender: IUIKButton) {
        
        Constant.MyClassConstants.viewController = self
        
        showHudAsync()
        
        ExchangeClient.getMyUnits(Session.sharedSession.userAccessToken, onSuccess: { (Relinquishments) in
            
            DarwinSDK.logger.debug(Relinquishments)
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if Relinquishments.pointsProgram != nil {
                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram ?? PointsProgram()
                
                if Relinquishments.pointsProgram?.availablePoints != nil {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram?.availablePoints ?? 0
                }
                
            }
            
            self.hideHudAsync()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as? RelinquishmentSelectionViewController {
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                let navController = UINavigationController(rootViewController: viewController)
                self.navigationController?.present(navController, animated: true)
            }
            
        }, onError: {(_) in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.generic)
        })
    }
    
    @IBAction func featuredDestinationsPressed(_ sender: AnyObject) {
        
        if featuredDestinationsTopConstraint.constant == 20 {
            featuredDestinationsTopConstraint.constant = view.frame.size.height - 200
        } else {
            
            Helper.getTopDeals(senderVC: self)
            featuredDestinationsTopConstraint.constant = 20
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func executeExchangeSearchDates() {
        
        ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
               onSuccess: { (response) in
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                
                // Get activeInterval
                guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                // Check not available checkIn dates for the active interval
                if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                    
                    // We do not have available CheckInDates in Rental and Exchange
                    if self.rentalHasNotAvailableCheckInDates {
                        Helper.showNotAvailabilityResults()
                    }
                    
                } else {
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
                    
                }
                                    
                                    //expectation.fulfill()
        },
           onError: { (error) in
            DarwinSDK.logger.error("Error Code: \(error.code)")
            DarwinSDK.logger.error("Error Description: \(error.description)")
            
            // TODO: Handle SDK/API errors
            DarwinSDK.logger.error("Handle SDK/API errors.")
                                    
        }
        )
        
    }
    func noAvailabilityResults(vacationSearch: VacationSearch) {
        hideHudAsync()
        Constant.MyClassConstants.initialVacationSearch = vacationSearch
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? VacationSearchResultIPadController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
}

extension VacationSearchIPadViewController: DateAndPassengerSelectionTableViewCellDelegate {
    
    //Function called when adult stepper is changed.
    func adultStepperChanged(_ value: Int) {
        
        //***** updating adult counter increment and decrement
        adultCounter = value
        Constant.MyClassConstants.stepperAdultCurrentValue = value
        if defaults.object(forKey: Constant.MyClassConstants.adultCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.adultCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        } else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        searchVacationTableView.reloadData()
    }
    //Function called when child stepper value is changed.
    func childrenStepperChanged(_ value: Int) {
        
        //***** Updating children counter increment and decrement
        childCounter = value
        Constant.MyClassConstants.stepperChildCurrentValue = value
        if defaults.object(forKey: Constant.MyClassConstants.childCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.childCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        } else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        
        searchVacationTableView.reloadData()
    }
    //Function that invock when calendar button clicked
    func calendarIconClicked(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.CalendarViewSegue, sender: nil)
    }
    
    func getSavedDestinationsResorts(storedData: Results <RealmLocalStorage>, searchCriteria: VacationSearchCriteria) {
        Constant.MyClassConstants.filteredIndex = 0
        if storedData.first?.destinations.count ?? 0 > 0 {
            
            let destination = AreaOfInfluenceDestination()
            destination.destinationName = storedData.first?.destinations.first?.destinationName
            destination.destinationId = storedData.first?.destinations.first?.destinationId
            destination.aoiId = storedData.first?.destinations.first?.aoid
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if storedData.first?.resorts.count ?? 0 > 0 {
            
            if let resortArrayList = storedData.first?.resorts.first?.resortArray {
                if resortArrayList.count > 0 {
                    var resorts = [Resort]()
                    for selectedResort in resortArrayList {
                        let resort = Resort()
                        resort.resortName = selectedResort.resortName
                        resort.resortCode = selectedResort.resortCode
                        resorts.append(resort)
                    }
                    searchCriteria.resorts = resorts
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(String(describing: storedData.first?.resorts.first?.resortArray.first?.resortName)) + more"
                } else {
                    let resort = Resort()
                    resort.resortName = storedData.first?.resorts.first?.resortName
                    resort.resortCode = storedData.first?.resorts.first?.resortCode
                    searchCriteria.resorts = [resort]
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName ?? ""
                }
            }
        }
        createFilterOptions()
    }
}

// MARK: Set options for filter
func createFilterOptions() {
    
    Constant.MyClassConstants.filterOptionsArray.removeAll()
    let storedData = Helper.getLocalStorageWherewanttoGo()
    let allDest = Helper.getLocalStorageAllDest()
    
    if storedData.count > 0 {
        Constant.MyClassConstants.filterOptionsArray.removeAll()
        for object in storedData {
            
            if object.destinations.count > 0 {
                Constant.MyClassConstants.filterOptionsArray.append(
                    .Destination(object.destinations[0])
                )
                
            } else if object.resorts.count > 0 {
                
                if object.resorts[0].resortArray.count > 0 {
                    
                    var arrayOfResorts = List<ResortByMap>()
                    var reswortByMap = [ResortByMap]()
                    arrayOfResorts = object.resorts[0].resortArray
                    for resort in arrayOfResorts {
                        reswortByMap.append(resort)
                    }
                    
                    Constant.MyClassConstants.filterOptionsArray.append(.ResortList(reswortByMap))
                } else {
                    Constant.MyClassConstants.filterOptionsArray.append(.Resort(object.resorts[0]))
                }
            }
        }
    } else if allDest.count > 0 {
        for areaCode in Constant.MyClassConstants.selectedAreaCodeArray {
            let dictionaryArea = ["\(areaCode)": Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: areaCode as! String)]
            Constant.MyClassConstants.filterOptionsArray.append(.Area(dictionaryArea as! NSMutableDictionary))
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

extension VacationSearchIPadViewController: SearchTableViewCellDelegate {
    
    // MARK: - Button events
    func searchButtonClicked(_ sender: IUIKButton) {
        
        var isNetworkAbl: String?
        if Reachability.isConnectedToNetwork() { isNetworkAbl = "Yes" }
        guard let _ = isNetworkAbl else { return presentErrorAlert(UserFacingCommonError.noNetConnection) }
        
        //Set travel PartyInfo
        let travelPartyInfo = TravelParty()
        travelPartyInfo.adults = Int(adultCounter)
        travelPartyInfo.children = Int(childCounter)
        Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
       
        ADBMobile.trackAction(Constant.omnitureEvents.event1, data: nil)
        
        if Constant.MyClassConstants.whereTogoContentArray.contains(Constant.MyClassConstants.allDestinations) {
            
           
            let dateComp = Calendar.current.dateComponents([.day], from: Constant.MyClassConstants.vacationSearchShowDate)
            let checkInToDate = dateComp.day ?? 0
            var searchType: VacationSearchType
            let requestRental = RentalSearchRegionsRequest()
            let requestExchange = ExchangeSearchRegionsRequest()
            
            //Seprate exchange, rental and search both region search
            switch segmentTitle {
            case Constant.segmentControlItems.exchange:
                requestExchange.setCheckInToDate(checkInToDate)
                searchType = VacationSearchType.Exchange
                
            case Constant.segmentControlItems.getaways:
                requestRental.setCheckInToDate(checkInToDate)
                searchType = VacationSearchType.Rental
                
            default:
                requestRental.setCheckInToDate(checkInToDate)
                searchType = VacationSearchType.Combined
            }
            
            showHudAsync()
            sender.isEnabled = false
            
            Constant.MyClassConstants.regionArray.removeAll()
            Constant.MyClassConstants.regionAreaDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeArray.removeAllObjects()
            
            if  searchType.isRental() || searchType.isCombined() {
                RentalClient.searchRegions(Session.sharedSession.userAccessToken, request: requestRental, onSuccess: {(response)in
                    
                    for rsregion in response {
                        let region = Region()
                        region.regionName = rsregion.regionName
                        region.regionCode = rsregion.regionCode
                        region.areas = rsregion.areas
                        Constant.MyClassConstants.regionArray.append(rsregion)
                        
                    }
                    self.hideHudAsync()
                    sender.isEnabled = true
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.allAvailableDestinations, sender: self)
                    Constant.MyClassConstants.isFromExchangeAllAvailable = false
                    if searchType.isCombined() {
                        Constant.MyClassConstants.isFromRentalAllAvailable = false
                    } else {
                        Constant.MyClassConstants.isFromRentalAllAvailable = true
                    }
                }, onError: { (_) in
                    self.hideHudAsync()
                    self.presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    sender.isEnabled = true
                })
            } else {
                
                ExchangeClient.searchRegions(Session.sharedSession.userAccessToken, request: requestExchange, onSuccess: { (response) in
                    
                    for rsregion in response {
                        let region = Region()
                        region.regionName = rsregion.regionName
                        region.regionCode = rsregion.regionCode
                        region.areas = rsregion.areas
                        Constant.MyClassConstants.regionArray.append(rsregion)
                        
                    }
                    self.hideHudAsync()
                    sender.isEnabled = true
                    Constant.MyClassConstants.isFromExchangeAllAvailable = true
                    Constant.MyClassConstants.isFromRentalAllAvailable = false
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.allAvailableDestinations, sender: self)
                    
                }, onError: { (_) in
                    self.presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    sender.isEnabled = true
                })
                
            }
        } else {
            // MARK: - Rental Search
            switch segmentTitle {
            case Constant.segmentControlItems.getaways:
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 {
                     presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                } else {
                    showHudAsync()
                    sender.isEnabled = false
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    if storedData.count > 0 {
                        
                        let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
                        getSavedDestinationsResorts(storedData: storedData, searchCriteria: rentalSearchCriteria)
                        
                        rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        
                        Constant.MyClassConstants.initialVacationSearch = VacationSearch(Session.sharedSession.appSettings, rentalSearchCriteria)
                        
                        RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { (response) in
                            
                             Helper.helperDelegate = self
                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                            
                            // Get activeInterval
                            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                            
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            
                            // Always show a fresh copy of the Scrolling Calendar
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            
                            // Check not available checkIn dates for the active interval
                            if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                                sender.isEnabled = true
                                self.hideHudAsync()
                                Helper.showNotAvailabilityResults()
                                self.noAvailabilityResults(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            } else {
                                Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                let searchCheckInDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat)
                                sender.isEnabled = true
                                Helper.helperDelegate = self
                                Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: searchCheckInDate, senderViewController: self)
                            }
                            
                        },
                         onError: { [weak self] (_) in
                            self?.hideHudAsync()
                            sender.isEnabled = true
                            self?.presentErrorAlert(UserFacingCommonError.generic)
                        })
                    }
                    Constant.MyClassConstants.isFromExchange = false
                }
                
            case Constant.segmentControlItems.exchange:
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 {
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                } else if Constant.MyClassConstants.relinquishmentIdArray.isEmpty {
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                } else {
                    sender.isEnabled = false
                    showHudAsync()
                    let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
                    exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                    exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                    exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                    
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    if storedData.count > 0 {
                        
                        getSavedDestinationsResorts(storedData: storedData, searchCriteria: exchangeSearchCriteria)
                        Constant.MyClassConstants.initialVacationSearch = VacationSearch(Session.sharedSession.appSettings, exchangeSearchCriteria)
                        
                        ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                            
                            sender.isEnabled = true
                            Helper.helperDelegate = self
                            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                            
                            // Get activeInterval (or initial search interval)
                            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            
                            // Check not available checkIn dates for the active interval
                            if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                                self.hideHudAsync()
                                Helper.showNotAvailabilityResults()
                            } else {
                                Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                let initialSearchCheckInDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat)
                                
                                Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: initialSearchCheckInDate, senderViewController: self)
                                
                            }
                        }, onError: { [weak self] error in
                            sender.isEnabled = true
                            self?.hideHudAsync()
                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                        })
                    }
                  Constant.MyClassConstants.isFromExchange = true
                }
                
            case Constant.segmentControlItems.searchBoth:
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 {
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                } else if Constant.MyClassConstants.relinquishmentIdArray.isEmpty {
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                } else {
                    showHudAsync()
                    let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Combined)
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    
                    if storedData.count > 0 {
                        getSavedDestinationsResorts(storedData: storedData, searchCriteria: rentalSearchCriteria)
                        
                        rentalSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                        rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        rentalSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                        
                        Constant.MyClassConstants.initialVacationSearch = VacationSearch(Session.sharedSession.appSettings, rentalSearchCriteria)
                        
                        ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
                        
                        RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { (response) in
                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            // Check not available checkIn dates for the active interval
                            if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                                self.rentalHasNotAvailableCheckInDates = true
                                Helper.executeExchangeSearchDates(senderVC: self)
                            } else {
                                Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
                                
                            }
                            Constant.MyClassConstants.checkInDates = response.checkInDates
                            sender.isEnabled = true
                            
                        }) { error in
                            self.hideHudAsync()
                            self.presentErrorAlert(UserFacingCommonError.handleError(error))
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
}

//Extension for collection view.
extension VacationSearchIPadViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // navigate to flex chane screen
        if collectionView.tag == 1 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexChangeSearchIpadViewController) as? FlexChangeSearchIpadViewController else { return }
            
            // set travel party info
            let travelPartyInfo = TravelParty()
            travelPartyInfo.adults = Int(adultCounter)
            travelPartyInfo.children = Int(childCounter)
            
            Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
            
            viewController.selectedFlexchange = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            topTenGetawaySelected(selectedIndexPath: indexPath)
        }
        
    }
}

extension VacationSearchIPadViewController: UICollectionViewDataSource {
    
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
        if collectionView.tag == 1 && showExchange == true {
            let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 175) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            
            if let imgURL = flexDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, _:SDImageCacheType, _:URL?) in
                    if error != nil {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    } else {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
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
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
        } else {
            let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 125) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            let rentalDeal: RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
            resortFlaxImageView.setImageWith(URL(string: (rentalDeal.images[0].url) ?? ""), completed: { (image:UIImage?, error:Error?, _:SDImageCacheType, _:URL?) in
                if error != nil {
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
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            
            let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
            centerView.center = resortFlaxImageView.center
            centerView.backgroundColor = Constant.RGBColorCode.centerViewRgb
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 15, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = topTenDeals.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 12)
            unitLabel.textColor = UIColor.white
            unitLabel.backgroundColor = UIColor.clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 35, width: centerView.frame.size.width - 20, height: 20))
            priceLabel.text = "From $" + String(describing: topTenDeals.price!.fromPrice) + " Wk."
            priceLabel.numberOfLines = 2
            priceLabel.textAlignment = NSTextAlignment.center
            priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
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

extension VacationSearchIPadViewController: WereWantToGoTableViewCellDelegate {
    
    func multipleResortInfoButtonPressedAtIndex(_ Index: Int) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
        viewController.selectedIndex = Index
        
        var resortsArray = [Resort]()
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
        for object in Constant.MyClassConstants.whereTogoContentArray {

            if (object as AnyObject).isKind(of: List<ResortByMap>.self) {
                
                //internal loop for array of resorts at index
                for resortsToShow in object as! List<ResortByMap> {
                    
                    let resort = Resort()
                    resort.resortName = resortsToShow.resortName
                    resort.resortCode = resortsToShow.resortCode
                    resort.address?.cityName = resortsToShow.resortCityName
                    resort.address?.territoryCode = resortsToShow.territorrycode
                    
                    resortsArray.append(resort)
                    
                }
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.resorts(resortsArray))
            }
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.destination(object as! AreaOfInfluenceDestination))
        }
        
        navigationController!.present(viewController, animated: true, completion: nil)
    }
    
    func searchAvailability(exchangeAvailabilityRequest: ExchangeSearchAvailabilityRequest, sender: IUIKButton) {
        ExchangeClient.searchAvailability(Session.sharedSession.userAccessToken, request: exchangeAvailabilityRequest, onSuccess: { (exchangeAvailability) in
            self.hideHudAsync()
            Constant.MyClassConstants.showAlert = false
            Constant.MyClassConstants.resortsArray.removeAll()
            Constant.MyClassConstants.exchangeInventory.removeAll()
            for exchangeResorts in exchangeAvailability {
                Constant.MyClassConstants.resortsArray.append(exchangeResorts.resort!)
                Constant.MyClassConstants.exchangeInventory.append(exchangeResorts.inventory!)
            }
            if Constant.MyClassConstants.resortsArray.count == 0 {
                Constant.MyClassConstants.showAlert = true
            }
            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
        }, onError: { (_) in
            self.hideHudAsync()
            sender.isEnabled = true
            Constant.MyClassConstants.showAlert = true
            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
        })
    }
    
}

// MARK: - Extension for Helper
extension VacationSearchIPadViewController: HelperDelegate {
    func resortSearchComplete() {
        hideHudAsync()
        navigateToSearchResultsScreen()
    }
}
