//
//  DashboardIPadTableViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/20/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import SVProgressHUD

class DashboardIPadTableViewController: UITableViewController {
    
    // class outlets
    @IBOutlet var homeTableView: UITableView!
    @IBOutlet var homeTableCollectionView: UICollectionView!
    
    // class variables
    var dashboardArray = [String]()
    var showGetaways = true
    var showExchange = true
    var childCounter = 0
    var adultCounter = 2
    var showAlertActivityIndicatorView = true
    var showSearchResults = false
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Adding notification to reload table when all alerts have been fetched *****//
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAlert), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopDestinations), name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUpcomingTrip), name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        Helper.InitializeOpenWeeksFromLocalStorage()
        getNumberOfSections()
        homeTableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //***** Remove added notifications. *****//
        showSearchResults ? (navigationController?.navigationBar.isHidden = false) :
            (navigationController?.navigationBar.isHidden = true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get all alerts
        Helper.getAllAlerts {[unowned self] error in
            if case .some = error {
                self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
            }
        }
        title = Constant.ControllerTitles.dashboardTableViewController
        showHudAsync()
        let delayInSeconds = 1.5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            Helper.getTopDeals(senderVC: self)
            Helper.getFlexExchangeDeals(senderVC: self) { (success) in
                if success {
                    DispatchQueue.main.async {[weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.getNumberOfSections()
                    }
                    self.homeTableView.reloadData()
                    
                } else {
                    
                }
            }
            //***** Setup the hamburger menu.  This will reveal the side menu. *****//
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
    }
    //***** Function to calculate number of sections. *****//
    func getNumberOfSections() {
        dashboardArray.removeAll()
        if !Constant.MyClassConstants.dashBoardAlertsArray.isEmpty {
            dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.alert)
        }
        dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.upcoming)
        if showExchange && showGetaways {
            
            if !Constant.MyClassConstants.flexExchangeDeals.isEmpty {
                dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.exchange)
            }
            if !Constant.MyClassConstants.topDeals.isEmpty {
                dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.getaway)
            }
        }
    }
    
    //***** Function called when notification for top 10 deals is fired. *****//
    func reloadTopDestinations() {
        hideHudAsync()
        showGetaways = true
        getNumberOfSections()
        homeTableView.reloadData()
    }
    
    //***** Function to show upcoming trip to user *****//
    
    func reloadUpcomingTrip() {
        hideHudAsync()
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
        if let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as? UpComingTripDetailIPadViewController {
            let navController = UINavigationController(rootViewController: resultController)
            self.present(navController, animated:true, completion: nil)
        }
        
    }
    //***** Function called when notification for getaway alerts is fired. *****//
    func refreshAlert() {
        showAlertActivityIndicatorView = false
        getNumberOfSections()
        homeTableView.reloadData()
    }
    
    //***** function to call alert list screen when view all alert button pressed *****//
    func viewAllAlertButtonPressed(_ sender: IUIKButton) {
        
        Constant.MyClassConstants.alertOriginationPoint = Constant.CommonStringIdentifiers.alertOriginationPoint
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.getawayAlertsIphone : Constant.storyboardNames.getawayAlertsIpad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
    }
    
    //***** function to call alert list screen when view all alert button pressed *****//
    func refreshAlertButtonPressed(_ sender: IUIKButton) {
        
        showAlertActivityIndicatorView = true
        homeTableView.reloadData()
        Helper.getAllAlerts {[unowned self] error in
            if case .some = error {
                self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
            }
        }
    }
    //Mark:- Button Clicked
    func searchVacationButtonPressed(_ sender: IUIKButton) {
        showSearchResults = false
        Constant.MyClassConstants.searchOriginationPoint = Constant.omnitureCommonString.homeDashboard
        
        let isRunningOnIpad = UIDevice.current.userInterfaceIdiom == .pad
        let storyboardName = isRunningOnIpad ? Constant.storyboardNames.vacationSearchIPad : Constant.storyboardNames.vacationSearchIphone
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
        
    }
    
    //***** function to call trip list screen when view all trip button pressed *****//
    func viewAllTripButtonPressed(_ sender: IUIKButton) {
        
        Constant.MyClassConstants.upcomingOriginationPoint = Constant.omnitureCommonString.homeDashboard
        let storyboardName = Constant.storyboardNames.myUpcomingTripIpad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    func homeAlertSelected(indexPath: IndexPath) {
        
        guard let alertID = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId else { return }
        if let value = Constant.MyClassConstants.alertsSearchDatesDictionary.value(forKey: String(alertID)) as? NSArray {
            //unable to perform isEmpty with value
            if value.count > 0 {
                if let  getawayAlert = Constant.MyClassConstants.alertsDictionary.value(forKey: String(alertID)) as? RentalAlert {
                    
                    showHudAsync()
                    let searchCriteria = createSearchCriteriaFor(alert: getawayAlert)
                    let settings = Helper.createSettings()
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
                    
                    RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { response in
                        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                        // Get activeInterval
                        let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                        // Update active interval
                        Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                        Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                        // Check not available checkIn dates for the active interval
                        if activeInterval?.fetchedBefore != nil && activeInterval?.hasCheckInDates() != nil {
                            
                            if  let activeInterval = activeInterval {
                                activeInterval.hasCheckInDates() ?self.rentalSearchAvailability(activeInterval: activeInterval) :self.noResultsAvailability()
                            }
                            
                        }
                    },
                                             onError: {[unowned self] error in
                                                self.hideHudAsync()
                                                self.presentErrorAlert(UserFacingCommonError.custom(title: "Error".localized(), body: error.localizedDescription))
                    })
                }
            } else {
                let alertController = UIAlertController(title: title, message: Constant.AlertErrorMessages.getawayAlertMessage, preferredStyle: .alert)
                showSearchResults = true
                let startSearch = UIAlertAction(title: Constant.AlertPromtMessages.newSearch, style: .default) { (action: UIAlertAction!) in
                    
                    let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
                    let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
                    if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                }
                
                let close = UIAlertAction(title: Constant.AlertPromtMessages.close, style: .default) { (_:UIAlertAction) in
                    
                }
                
                //Add Custom Actions to Alert viewController
                alertController.addAction(startSearch)
                alertController.addAction(close)
                self.present(alertController, animated: true, completion:nil)
            }
        }
    }
    
    func createSearchCriteriaFor(alert: RentalAlert) -> VacationSearchCriteria {
        // Split destinations and resorts to create multiples VacationSearchCriteria
        let checkInDate = alert.getCheckInDate()
        
        let searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
        searchCriteria.checkInDate = Helper.convertStringToDate(dateString: checkInDate, format: Constant.MyClassConstants.dateFormat)
        if let earliestCheckInDate = alert.earliestCheckInDate {
            searchCriteria.checkInFromDate = Helper.convertStringToDate(dateString: earliestCheckInDate, format: Constant.MyClassConstants.dateFormat)
        }
        if let latestCheckInDate = alert.latestCheckInDate {
            searchCriteria.checkInToDate = Helper.convertStringToDate(dateString: latestCheckInDate, format: Constant.MyClassConstants.dateFormat)
        }
        getDestinationsResortsForAlert(alert:alert, searchCriteria: searchCriteria)
        alertFilterOptionsArray.removeAll()
        
        for destination in alert.destinations {
            let dest = AreaOfInfluenceDestination()
            if let destinationName = destination.destinationName {
                dest.destinationName = destinationName
            } else {
                dest.destinationName = "Cancun".localized()
            }
            dest.aoiId = destination.aoiId
            dest.destinationId = destination.destinationId
            alertFilterOptionsArray
                .append(Constant.AlertResortDestination.Destination(dest))
        }
        for resort in alert.resorts {
            let alertResort = Resort()
            alertResort.resortName = resort.resortName
            alertResort.resortCode = resort.resortCode
            alertFilterOptionsArray
                .append(Constant.AlertResortDestination.Resort(resort))
        }
        return searchCriteria
    }
    
    func rentalSearchAvailability(activeInterval: BookingWindowInterval) {
        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
        Helper.helperDelegate = self
        if let searchDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
            Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: searchDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        }
    }
    
    //Function for no results availability
    func noResultsAvailability() {
        Constant.MyClassConstants.noAvailabilityView = true
        navigateToSearchResults()
        
    }
    func navigateToSearchResults() {
        showSearchResults = false
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? VacationSearchResultIPadController {
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func getDestinationsResortsForAlert(alert: RentalAlert, searchCriteria: VacationSearchCriteria) {
        if !alert.destinations.isEmpty {
            let destination = AreaOfInfluenceDestination()
            if let destinationName = alert.destinations[0].destinationName {
                destination.destinationName = destinationName
            } else {
                destination.destinationName  = "Cancun".localized()
            }
            destination.destinationId = alert.destinations[0].destinationId
            destination.aoiId = alert.destinations[0].aoiId
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if !alert.resorts.isEmpty {
            Constant.MyClassConstants.initialVacationSearch.searchCriteria.resorts = alert.resorts
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        homeTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dashboardArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch dashboardArray[section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.alert:
            return Constant.MyClassConstants.getawayAlertsArray.isEmpty ? 0 : 1
        default:
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch dashboardArray[indexPath.section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming:
            return 210
        case Constant.dashboardTableScreenReusableIdentifiers.alert:
            return 100
        default :
            return 320
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch dashboardArray[section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.getaway:
            return 0
            
        case Constant.dashboardTableScreenReusableIdentifiers.exchange:
            return 0
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming:
            return 50
            
        case Constant.dashboardTableScreenReusableIdentifiers.alert:
            return 50
            
        default :
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch dashboardArray[section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.alert:
            let headerView = UIView()
            headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            
            let titleLabel = UILabel()
            titleLabel.text = "Getaway Alerts".localized()
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: 20, y: headerView.frame.height / 2 - titleLabel.frame.height / 2, width: titleLabel.frame.width, height: titleLabel.frame.height)
            titleLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
            titleLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(titleLabel)
            
            let viewAllAlertButton = IUIKButton()
            viewAllAlertButton.frame = CGRect(x: headerView.frame.width - 220, y: 10, width: 150, height: 40)
            viewAllAlertButton.setTitle(Constant.buttonTitles.viewAllAlerts, for: UIControlState.normal)
            viewAllAlertButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
            viewAllAlertButton.addTarget(self, action: #selector(DashboardIPadTableViewController.viewAllAlertButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            headerView.addSubview(viewAllAlertButton)
            
            let refreshAllAlertButton = IUIKButton()
            refreshAllAlertButton.frame = CGRect(x: headerView.frame.width - 70, y: 10, width: 50, height: 50)
            refreshAllAlertButton.setImage(UIImage(named:Constant.assetImageNames.refreshAlert), for: .normal)
            refreshAllAlertButton.addTarget(self, action: #selector(DashboardIPadTableViewController.refreshAlertButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            headerView.addSubview(refreshAllAlertButton)
            return headerView
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming:
            
            let headerView = UIView()
            headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            
            let titleLabel = UILabel()
            titleLabel.text = "My Upcoming Trips".localized()
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: 20, y: headerView.frame.height / 2 - titleLabel.frame.height / 2, width: titleLabel.frame.width, height: titleLabel.frame.height)
            titleLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
            titleLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(titleLabel)
            let viewAllTripButton = IUIKButton()
            viewAllTripButton.frame = CGRect(x: headerView.frame.width - 170, y: 10, width: 150, height: 30)
            viewAllTripButton.setTitle(Constant.buttonTitles.viewAllTrips, for: UIControlState.normal)
            viewAllTripButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
            viewAllTripButton.addTarget(self, action: #selector(DashboardIPadTableViewController.viewAllTripButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            headerView.addSubview(viewAllTripButton)
            return headerView
            
        default :
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch dashboardArray[indexPath.section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.alert:
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.reuseIdentifier, for: indexPath) as? HomeAlertTableViewCell {
                cell.alertCollectinView.tag = 3
                cell.alertCollectinView.delegate = self
                cell.alertCollectinView.dataSource = self
                if showAlertActivityIndicatorView {
                    
                    cell.activityIndicatorBseView.isHidden = false
                    cell.activityIndicatorBackgroundView.layer.borderWidth = 2
                    cell.activityIndicatorBackgroundView.layer.cornerRadius = 10
                    cell.activityIndicatorBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.activityIndicatorBackgroundView.layer.masksToBounds = true
                    cell.activityIndicator.startAnimating()
                } else {
                    cell.activityIndicatorBseView.isHidden = true
                    cell.activityIndicator.stopAnimating()
                    cell.alertCollectinView.reloadData()
                }
                return cell
            } else {
                return UITableViewCell()
            }
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming:
            
            if let cell: UpComingTripsTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.upComingTripsCell, for: indexPath) as? UpComingTripsTableViewCell {
                cell.searchVacationButton.addTarget(self, action: #selector(DashboardIPadTableViewController.searchVacationButtonPressed(_:)), for: UIControlEvents.touchUpInside)
                cell.vacationSearchCollectionView.reloadData()
                
                cell.vacationSearchContainerView.frame = CGRect(x: 20, y: 20, width: 200, height: 200)
                
                cell.vacationSearchCollectionView.reloadData()
                cell.vacationSearchCollectionView.delegate = self
                cell.vacationSearchCollectionView.dataSource = self
                cell.vacationSearchContainerView.layer.cornerRadius = 7
                cell.vacationSearchContainerView.layer.borderWidth = 4
                cell.vacationSearchContainerView.layer.borderColor = UIColor(red: 224.0 / 255.0, green: 118.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0).cgColor
                
                return cell
            } else {
                return UITableViewCell()
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            if dashboardArray[indexPath.section] == Constant.dashboardTableScreenReusableIdentifiers.exchange {
                if !showExchange {
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                    cell.addSubview(resortImageNameLabel)
                } else {
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                    cell.addSubview(resortImageNameLabel)
                    
                }
            } else {
                
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                cell.addSubview(resortImageNameLabel)
            }
            
            //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width:280, height: 260 )
            layout.minimumLineSpacing = 20.0
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 260 ), collectionViewLayout: layout)
            
            homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            homeTableCollectionView.backgroundColor = UIColor.clear
            homeTableCollectionView.delegate = self
            homeTableCollectionView.dataSource = self
            if dashboardArray[indexPath.section] == Constant.dashboardTableScreenReusableIdentifiers.exchange {
                homeTableCollectionView.tag = 2
            } else {
                homeTableCollectionView.tag = 1
            }
            
            homeTableCollectionView.isScrollEnabled = true
            cell.backgroundColor = UIColor(red: 240.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
            cell.addSubview(homeTableCollectionView)
            return cell
        }
        
    }
}

extension DashboardIPadTableViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView.tag {
            
        case 1:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexChangeSearchIpadViewController) as? FlexChangeSearchIpadViewController {
                Constant.MyClassConstants.viewController = self
                Constant.MyClassConstants.travelPartyInfo = Helper.travelPartyInfo(adults: 2, children: 0)
                viewController.selectedFlexchange = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        case 2:
            showSearchResults = true
            Helper.helperDelegate = self
            topTenGetawaySelected(selectedIndexPath: indexPath)
            
        case 3:
            homeAlertSelected(indexPath: indexPath)
            
        case 4:
            if let exchangeNumber = Constant.MyClassConstants.upcomingTripsArray[indexPath.row].exchangeNumber {
                Constant.MyClassConstants.transactionNumber = "\(exchangeNumber)"
                Helper.getTripDetails(senderViewController: self)
            }
            
        default:
            break
        }
    }
}

extension DashboardIPadTableViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView.tag {
            
        case 1:
            return Constant.MyClassConstants.flexExchangeDeals.count
        case 2:
            return (Constant.MyClassConstants.topDeals.count)
        case 3:
            return Constant.MyClassConstants.getawayAlertsArray.count
        case 4:
            return Constant.MyClassConstants.upcomingTripsArray.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            if let imageURL = flexDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if error != nil {
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
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.masksToBounds = true
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 220) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            let rentalDeal: RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
            if let imageURL = rentalDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if error != nil {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }
            cell.addSubview(resortFlaxImageView)
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 50))
            if let header = topTenDeals.header {
                resortImageNameLabel.text = header
            }
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
            if let price = topTenDeals.price {
                priceLabel.text = "From $" + String(price.fromPrice) + " Wk.".localized()
            }
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
            
            cell.backgroundColor = UIColor.white
            cell.addSubview(centerView)
            return cell
            
        case 3:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeAlertCollectionCell", for: indexPath) as? HomeAlertCollectionCell {
                if let alertTitle = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name {
                    cell.alertTitle.text = alertTitle
                }
                
                var fromDate = ""
                var toDate = ""
                if let earchInDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].earliestCheckInDate {
                    
                    let alertFromDate = Helper.convertStringToDate(dateString:earchInDate, format: Constant.MyClassConstants.dateFormat)
                    
                    fromDate = (Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.month)).appendingFormat(". ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.year))
                }
                
                if let latchInDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].latestCheckInDate {
                    
                    let alertToDate = Helper.convertStringToDate(dateString: latchInDate, format: Constant.MyClassConstants.dateFormat)
                    
                    toDate = Helper.getWeekDay(dateString: alertToDate, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: Constant.MyClassConstants.year))
                }
                
                let dateRange = fromDate.appending(" - " + toDate)
                cell.alertDate.text = dateRange
                
                if let alertID = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId {
                    if let value = Constant.MyClassConstants.alertsSearchDatesDictionary.value(forKey: String(alertID)) as? NSArray {
                        //unable to check isEmpty with value
                        if value.count > 0 {
                            cell.alertStatus.text = Constant.buttonTitles.viewResults
                            cell.alertStatus.textColor = UIColor.white
                            cell.layer.borderColor = UIColor(red: 224.0 / 255.0, green: 118.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0).cgColor
                            cell.backgroundColor = UIColor(red: 224.0 / 255.0, green: 118.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
                        } else {
                            cell.alertStatus.text = Constant.buttonTitles.nothingYet
                            cell.alertStatus.textColor = UIColor.white
                            cell.layer.borderColor = UIColor(red: 167.0 / 255.0, green: 167.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0).cgColor
                            cell.backgroundColor = UIColor(red: 167.0 / 255.0, green: 167.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
                        }
                    } else {
                        cell.alertStatus.text = Constant.buttonTitles.nothingYet
                        cell.alertStatus.textColor = UIColor.white
                        cell.layer.borderColor = UIColor(red: 167.0 / 255.0, green: 167.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0).cgColor
                        cell.backgroundColor = UIColor(red: 167.0 / 255.0, green: 167.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
                    }
                }
                
                cell.layer.borderWidth = 2.0
                cell.layer.cornerRadius = 3
                cell.layer.masksToBounds = true
                return cell
            } else {
                return UICollectionViewCell()
            }
        case 4:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.upcomingCell, for: indexPath) as? VacationCollectionViewCell {
                let upcomingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.row]
                if let resort = upcomingTrip.resort {
                    cell.resortTitleLabel.text = resort.resortName
                    
                    if let address = resort.address {
                        cell.resortAddressLabel.text = "\(address.cityName ?? ""), \(address.territoryCode ?? "") \(address.countryCode ?? "")".localized()
                        cell.resortCodeLabel.text = address.countryCode?.localized()
                    }
                    
                }
                var formatedCheckInDate = ""
                var formatedCheckOutDate = ""
                if let unitCheckInDate = upcomingTrip.unit?.checkInDate {
                    
                    let checkInDate = Helper.convertStringToDate(dateString:unitCheckInDate, format: Constant.MyClassConstants.dateFormat1)
                    
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: checkInDate)
                    
                    formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber:myComponents.weekday ?? 0)) \(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)). \(myComponents.day ?? 0), \(myComponents.year ?? 0)"
                    
                }
                
                if let unitCheckOutDate = upcomingTrip.unit?.checkOutDate {
                    
                    let checkOutDate = Helper.convertStringToDate(dateString: unitCheckOutDate, format: Constant.MyClassConstants.dateFormat1)
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents1 = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: checkOutDate)
                    
                    formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday ?? 0)) \(Helper.getMonthnameFromInt(monthNumber: myComponents1.month ?? 0)). \(myComponents1.day ?? 0), \(myComponents1.year ?? 0)"
                }
                
                cell.resortAvailabilityLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)"
                
                if let imageUrl = upcomingTrip.resort?.images.first?.url {
                    cell.iconImageView.setImageWith(URL(string: imageUrl), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                        if error != nil {
                            cell.iconImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                            cell.iconImageView.contentMode = .center
                        }
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                } else {
                    cell.iconImageView.image = UIImage(named:Constant.MyClassConstants.noImage)
                }
                if cell.gradientView.layer.sublayers != nil {
                    for layer in cell.gradientView.layer.sublayers! {
                        if layer.isKind(of: CAGradientLayer.self) {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
                cell.gradientView.frame = CGRect(x: cell.gradientView.frame.origin.x, y: cell.gradientView.frame.origin.y, width: cell.contentView.frame.width, height: cell.gradientView.frame.height)
                Helper.addLinearGradientToView(view: cell.gradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1.0
                cell.layer.cornerRadius = 7
                cell.layer.masksToBounds = true
                
                return cell
            } else {
                return UICollectionViewCell()
            }
            
        default :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            return cell
            
        }
    }
}

extension DashboardIPadTableViewController: HelperDelegate {
    func resortSearchComplete() {
        navigateToSearchResults()
    }
    func resetCalendar() {
        
    }
}
