//
//  DashboardTableViewController.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD
import SDWebImage

class DashboardTableViewController: UITableViewController {
    
    //***** Outlets *****//
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var homeTableCollectionView: UICollectionView!
    @IBOutlet var homeTableView: UITableView!
    
    //***** Variables *****//
    var segmentSelectedIndex: Int = 0
    var showAlertActivityIndicatorView = true
    var noUpcomingTrip = false
    var showGetaways = true
    var showExchange = true
    var dashboardArray = [String]()
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    var isRunningOnIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    var showSearchResults = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //***** Adding notification to reload alert badge *****//
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAlertCollectionView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopDestinations), name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUpcomingTrip), name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        getNumberOfSections()
        Helper.InitializeOpenWeeksFromLocalStorage()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showSearchResults ? (navigationController?.navigationBar.isHidden = false) :
            (navigationController?.navigationBar.isHidden = true)
        
        //***** Removing notification to reload alert badge *****//
        NotificationCenter.default
            .removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default
            .removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constant.ControllerTitles.dashboardTableViewController
        if let accessToken = Session.sharedSession.userAccessToken {
            //Get all alerts
            readAllRentalAlerts(accessToken: accessToken)
            showHudAsync()
            
            //Read top10Deals
            ClientAPI.sharedInstance.readTopTenDeals(for: accessToken)
                .then { [weak self] topTenDeals in
                    guard let strongSelf = self else { return }
                    Constant.MyClassConstants.topDeals = topTenDeals
                    strongSelf.readFlexExchangeDeals(accessToken: accessToken)
                }
                .onError { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.presentErrorAlert(UserFacingCommonError.handleError(error))
                    strongSelf.readFlexExchangeDeals(accessToken: accessToken)
            }
        }
        // omniture tracking with event40
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.homeDashboard
        ]
        ADBMobile.trackState( Constant.omnitureEvents.event40, data: userInfo)
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = .white
            
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
    }
    
    // MARK: - FlexExchangeDeals
    func readFlexExchangeDeals(accessToken: DarwinAccessToken) {
        //Read FlexExchangeDeals
        ClientAPI.sharedInstance.readFlexchangeDeals(for: accessToken)
            .then { [weak self] flexExchangeDeal in
                guard let strongSelf = self else { return }
                Constant.MyClassConstants.flexExchangeDeals = flexExchangeDeal
                strongSelf.showGetaways = true
                strongSelf.getNumberOfSections()
                strongSelf.homeTableView.reloadData()
                strongSelf.hideHudAsync()
            }
            .onError { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.presentErrorAlert(UserFacingCommonError.handleError(error))
                strongSelf.hideHudAsync()
        }
    }
    
    // MARK: - Getaway Alerts
    func readAllRentalAlerts(accessToken: DarwinAccessToken) {
        ClientAPI.sharedInstance.readAllRentalAlerts(for: accessToken)
            .then { rentalAlertArray in
                
                Constant.MyClassConstants.getawayAlertsArray.removeAll()
                Constant.MyClassConstants.getawayAlertsArray = rentalAlertArray
                Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
                
                for alert in rentalAlertArray {
                    if let alertId = alert.alertId {
                        self.readRentalAlert(accessToken: accessToken, alertId: alertId)
                    }
                }
            }
            .onError { [weak self] error in
                self?.presentErrorAlert(UserFacingCommonError.handleError(error as NSError))
        }
    }
    
    func readRentalAlert(accessToken: DarwinAccessToken, alertId: Int64) {
        Constant.MyClassConstants.searchDateResponse.removeAll()
        ClientAPI.sharedInstance.readRentalAlert(for: accessToken, and: alertId)
            .then { rentalAlert in
                
                let rentalSearchDatesRequest = RentalSearchDatesRequest()
                if let checkInTodate = rentalAlert.latestCheckInDate {
                    rentalSearchDatesRequest.checkInToDate = Helper.convertStringToDate(dateString:checkInTodate, format:Constant.MyClassConstants.dateFormat)
                }
                if let checkInFromdate = rentalAlert.earliestCheckInDate {
                    rentalSearchDatesRequest.checkInFromDate = Helper.convertStringToDate(dateString:checkInFromdate, format:Constant.MyClassConstants.dateFormat)
                }
                rentalSearchDatesRequest.resorts = rentalAlert.resorts
                rentalSearchDatesRequest.destinations = rentalAlert.destinations
                
                Constant.MyClassConstants.dashBoardAlertsArray = Constant.MyClassConstants.getawayAlertsArray
                self.readDates(accessToken: accessToken, request: rentalSearchDatesRequest, rentalAlert: rentalAlert)
            }
            .onError { [weak self] error in self?.presentErrorAlert(UserFacingCommonError.handleError(error as NSError))
        }
    }
    
    func readDates(accessToken: DarwinAccessToken, request: RentalSearchDatesRequest, rentalAlert: RentalAlert) {
        ClientAPI.sharedInstance.readDates(for: accessToken, and: request)
            .then { rentalSearchDatesResponse in
                intervalPrint("____-->\(rentalSearchDatesResponse)")
                Constant.MyClassConstants.searchDateResponse.append(rentalAlert, rentalSearchDatesResponse)
                Helper.performSortingForMemberNumberWithViewResultAndNothingYet()
                
            }
            .onError { [weak self] error in
                self?.presentErrorAlert(UserFacingCommonError.handleError(error as NSError))
        }
    }
    
    //***** Function to calculate number of sections. *****//
    func getNumberOfSections() {
        dashboardArray.removeAll()
        if !Constant.MyClassConstants.dashBoardAlertsArray.isEmpty {
            dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.alert)
        }
        if !Constant.MyClassConstants.upcomingTripsArray.isEmpty {
            dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.upcoming)
        }
        if showExchange && showGetaways {
            dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.search)
            
            if !Constant.MyClassConstants.flexExchangeDeals.isEmpty {
                dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.exchange)
            }
            
            if !Constant.MyClassConstants.topDeals.isEmpty {
                dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.getaway)
            }
        }
        if !showExchange && !showGetaways {
            dashboardArray.append(Constant.dashboardTableScreenReusableIdentifiers.search)
        }
    }
    
    //***** Function called when notification for upcoming trips details is fired. *****//
    func reloadUpcomingTrip() {
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil {
            let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
            if let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as? UpComingTripDetailController {
                navigationController?.pushViewController(resultController, animated: true)
            }
        }
    }
    
    //***** Function called when notification for getaway alerts is fired. *****//
    func reloadAlertCollectionView() {
        showAlertActivityIndicatorView = false
        getNumberOfSections()
        homeTableView.reloadData()
    }
    
    //***** Function called when notification for top 10 deals is fired. *****//
    func reloadTopDestinations() {
        getNumberOfSections()
        homeTableView.reloadData()
    }
    
    //***** MARK: - Table view delegate methods *****//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dashboardArray[indexPath.section] == Constant.dashboardTableScreenReusableIdentifiers.upcoming {
            if let exchaneNumber = Constant.MyClassConstants.upcomingTripsArray[indexPath.row].exchangeNumber {
                Constant.MyClassConstants.transactionNumber = "\(exchaneNumber)"
            }
            
            Helper.getTripDetails(senderViewController: self)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //***** return row height according to section cell *****//
        switch dashboardArray[indexPath.section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming:
            return 70
        case Constant.dashboardTableScreenReusableIdentifiers.alert :
            return 100
        case Constant.dashboardTableScreenReusableIdentifiers.search:
            return 110
        default :
            return 290
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //***** Configure header cell for each section to show header labels *****//
        switch dashboardArray[section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.alert :
            if let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.headerCell) as? CustomHeaderCell {
                headerCell.headerLabel.text = Constant.dashboardTableViewControllerHeaderText.gatewayAlerts
                headerCell.headerDetailButton.setTitle(Constant.buttonTitles.viewAllAlerts, for: UIControlState.normal)
                headerCell.headerDetailButton.addTarget(self, action: #selector(DashboardTableViewController.viewAllAlertButtonPressed(_:)), for: .touchUpInside)
                headerCell.refreshAlertButton.addTarget(self, action: #selector(DashboardTableViewController.refreshAlertButtonPressed(_:)), for: .touchUpInside)
                return headerCell
            } else { return nil }
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming :
            if let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.headerCell) as? CustomHeaderCell {
                headerCell.headerLabel.text = Constant.dashboardTableViewControllerHeaderText.myUpcomingTrips
                headerCell.headerDetailButton.setTitle(Constant.buttonTitles.viewAllTrips, for: UIControlState.normal)
                headerCell.headerDetailButton.addTarget(self, action: #selector(DashboardTableViewController.viewAllTripButtonPressed(_:)), for: .touchUpInside)
                headerCell.refreshAlertButton.isHidden = true
                return headerCell
            } else { return nil }
            
        case Constant.dashboardTableScreenReusableIdentifiers.search :
            if let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.headerCell) as? CustomHeaderCell {
                headerCell.headerLabel.text = Constant.dashboardTableViewControllerHeaderText.planVacation
                headerCell.headerDetailButton.isHidden = true
                headerCell.refreshAlertButton.isHidden = true
                return headerCell
            } else { return nil }
            
        default :
            if let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.headerCell) as? CustomHeaderCell {
                headerCell.headerLabel.text = nil
                return headerCell
            } else { return nil }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dashboardArray[section] == Constant.dashboardTableScreenReusableIdentifiers.getaway || dashboardArray[section] == Constant.dashboardTableScreenReusableIdentifiers.exchange {
            return 0
        } else {
            return 50
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dashboardArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch dashboardArray[section] {
            
        case Constant.dashboardTableScreenReusableIdentifiers.alert:
            return !Constant.MyClassConstants.getawayAlertsArray.isEmpty ? 1 : 0
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming :
            return Constant.MyClassConstants.upcomingTripsArray.count <= 2 ? Constant.MyClassConstants.upcomingTripsArray.count : 2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = getTableViewContents(indexPath, type: dashboardArray[indexPath.section])
        return cell
        
    }
    
    func getTableViewContents(_ indexPath: IndexPath, type: String) -> UITableViewCell {
        
        switch type {
        case Constant.dashboardTableScreenReusableIdentifiers.alert :
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell, for: indexPath) as? HomeAlertTableViewCell {
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
            } else { return UITableViewCell() }
            
        case Constant.dashboardTableScreenReusableIdentifiers.upcoming :
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.sectionCell, for: indexPath) as? UpcomingTripSegmentCell {
                let upcomingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.row]
                if let resort = upcomingTrip.resort {
                    cell.resortNameLabel.text = resort.resortName
                    
                    if let address = resort.address {
                        cell.resortLocationLabel.text = "\(address.cityName ?? ""), \(address.territoryCode ?? "") \(address.countryCode ?? "")".localized()
                    }
                }
                
                if let tripDate = upcomingTrip.unit?.checkInDate {
                    let upcomingTripDate = Helper.convertStringToDate(dateString: tripDate, format: Constant.MyClassConstants.dateFormat)
                    cell.dayDateLabel.text = Helper.getWeekDay(dateString: upcomingTripDate, getValue: Constant.MyClassConstants.date)
                    
                    var dayNameYearText = "\(Helper.getWeekDay(dateString: upcomingTripDate, getValue: Constant.MyClassConstants.weekDay))\n\(Helper.getWeekDay(dateString: upcomingTripDate, getValue: Constant.MyClassConstants.month))"
                    dayNameYearText = "\(dayNameYearText) \(Helper.getWeekDay(dateString: upcomingTripDate, getValue: Constant.MyClassConstants.year))"
                    cell.dayNameYearLabel.text = dayNameYearText
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            } else { return UITableViewCell() }
            
        case Constant.dashboardTableScreenReusableIdentifiers.search :
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            let searchVacation = IUIKButton()
            searchVacation.backgroundColor = UIColor(red: 224 / 255.0, green: 118 / 255.0, blue: 69 / 255.0, alpha: 1.0)
            searchVacation.setTitle(Constant.buttonTitles.searchVacation, for: UIControlState.normal)
            searchVacation.titleLabel?.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 22)
            searchVacation.addTarget(self, action:#selector(DashboardTableViewController.searchVactionPressed(_:)), for:UIControlEvents.touchUpInside)
            cell.contentView.addSubview(searchVacation)
            searchVacation.layer.cornerRadius = 4
            searchVacation.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addConstraint(NSLayoutConstraint(item: searchVacation, attribute: .leadingMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 20))
            
            cell.contentView.addConstraint( NSLayoutConstraint(item: searchVacation, attribute: .trailingMargin, relatedBy: .equal, toItem: cell.contentView, attribute:.trailingMargin, multiplier: 1.0, constant: -20))
            
            cell.contentView.addConstraint(NSLayoutConstraint(item: searchVacation, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1.0, constant: 20))
            cell.contentView.addConstraint(NSLayoutConstraint(item: searchVacation, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1.0, constant: -20))
            
            return cell
            
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            let seprator = Seprator(x: 0, y: 0, width: cell.frame.size.width, height: 1)
            cell.addSubview(seprator)
            //header for top ten deals
            if type == Constant.dashboardTableScreenReusableIdentifiers.exchange {
                
                if !showExchange {
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    
                    resortImageNameLabel.textColor = .black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                    cell.addSubview(resortImageNameLabel)
                } else {
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                    resortImageNameLabel.textColor = .black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                    cell.addSubview(resortImageNameLabel)
                }
            } else {
                
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                
                resortImageNameLabel.textColor = .black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                cell.addSubview(resortImageNameLabel)
            }
            
            //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width:280, height: 220 )
            layout.minimumLineSpacing = 10.0
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 230 ), collectionViewLayout: layout)
            
            homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            homeTableCollectionView.backgroundColor = .clear
            homeTableCollectionView.delegate = self
            homeTableCollectionView.dataSource = self
            if type == Constant.dashboardTableScreenReusableIdentifiers.exchange {
                homeTableCollectionView.tag = 1
            } else {
                homeTableCollectionView.tag = 2
            }
            
            homeTableCollectionView.isScrollEnabled = true
            cell.backgroundColor = UIColor(red: 240.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
            cell.addSubview(homeTableCollectionView)
            
            return cell
        }
    }
    
    //***** Segment control selected item action *****//
    func segmentedControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            segmentSelectedIndex = sender.selectedSegmentIndex
            homeTableView.reloadData()
        } else {
            segmentSelectedIndex = sender.selectedSegmentIndex
            homeTableView.reloadData()
        }
    }
    //***** View all alerts button pressed *****//
    func viewAllAlertButtonPressed(_ sender: IUIKButton) {
        showSearchResults = false
        Constant.MyClassConstants.alertOriginationPoint = Constant.CommonStringIdentifiers.alertOriginationPoint
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.getawayAlertsIphone : Constant.storyboardNames.getawayAlertsIpad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        
    }
    //***** Refresh alert button action *****//
    func refreshAlertButtonPressed(_ sender: IUIKButton) {
        
        showAlertActivityIndicatorView = true
        if let accessToken = Session.sharedSession.userAccessToken {
            readAllRentalAlerts(accessToken: accessToken)
        }
        homeTableView.reloadData()
    }
    
    //***** View all trip button action *****//
    func viewAllTripButtonPressed(_ sender: IUIKButton) {
        
        Constant.MyClassConstants.upcomingOriginationPoint = Constant.omnitureCommonString.homeDashboard
        let storyboardName = Constant.storyboardNames.myUpcomingTripIphone
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
        
    }
    //***** Search vacation button action *****//
    // MARK: - Button Events
    func  searchVactionPressed(_ sender: AnyObject) {
        
        showSearchResults = false
        Constant.MyClassConstants.searchOriginationPoint = Constant.omnitureCommonString.homeDashboard
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    func homeAlertSelected(indexPath: IndexPath) {
        let (getawayAlert, searchDateResponse) = Constant.MyClassConstants.searchDateResponse[indexPath.row]
        
        if !searchDateResponse.checkInDates.isEmpty {
            showHudAsync()
            let searchCriteria = createSearchCriteriaFor(alert: getawayAlert)

            if let settings = Session.sharedSession.appSettings {
                Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
            }

            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = searchDateResponse
            // Get activeInterval
            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
            // Update active interval
            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
            
            // Check if active interval has check-in dates.
            activeInterval.hasCheckInDates() ?self.rentalSearchAvailability(activeInterval: activeInterval) : self.noResultsAvailability()
        } else {
            let alertController = UIAlertController(title: title, message: Constant.AlertErrorMessages.getawayAlertMessage, preferredStyle: .alert)
            showSearchResults = true
            let startSearch = UIAlertAction(title: Constant.AlertPromtMessages.newSearch, style: .default) { (_:UIAlertAction) in
                
                let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
                let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
                if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
                    self.navigationController?.pushViewController(initialViewController, animated: true)
                }
            }
            let close = UIAlertAction(title: Constant.AlertPromtMessages.close, style: .default, handler: nil)
            //Add Custom Actions to Alert viewController
            alertController.addAction(startSearch)
            alertController.addAction(close)
            present(alertController, animated: true)
        }
    }
    
    //Function for no results availability
    func noResultsAvailability() {
        Constant.MyClassConstants.noAvailabilityView = true
        navigateToSearchResults()
        
    }
    
    //Function for navigating to search results
    func navigateToSearchResults() {
        showSearchResults = false
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? SearchResultViewController {
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    //Function for rental search availability
    func rentalSearchAvailability(activeInterval: BookingWindowInterval) {
        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
        Helper.helperDelegate = self
        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
        
    }
    
    func createSearchCriteriaFor(alert: RentalAlert) -> VacationSearchCriteria {
        // Split destinations and resorts to create multiples VacationSearchCriteria
        let checkInDate = alert.getCheckInDate()
        
        let searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.RENTAL)
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
                // FIXME (Frank): Why hard coded ?
                dest.destinationName = "Cancun"
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
    
    func getDestinationsResortsForAlert(alert: RentalAlert, searchCriteria: VacationSearchCriteria) {
        if !alert.destinations.isEmpty {
            let destination = AreaOfInfluenceDestination()
            if let destinationName = alert.destinations[0].destinationName {
                destination.destinationName = destinationName
            } else {
                destination.destinationName  = "Cancun"
            }
            destination.destinationId = alert.destinations[0].destinationId
            destination.aoiId = alert.destinations[0].aoiId
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if !alert.resorts.isEmpty {
           searchCriteria.resorts = alert.resorts
            if let resortName = alert.resorts[0].resortName {
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(resortName) + \(alert.resorts.count) more"
            }
        }
    }
}
//***** MARK: Extension classes starts from here *****//
extension DashboardTableViewController: HelperDelegate {
    func resortSearchComplete() {
        hideHudAsync()
        // Check if not has availability in the desired check-In date.
        if Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat) {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? SearchResultViewController {
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
}
extension DashboardTableViewController: UICollectionViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView.tag {
            
        case 1:
            Constant.MyClassConstants.viewController = self
            flexchangeSelected(selectedIndexPath: indexPath)
            
        case 2:
            showSearchResults = true
            topTenGetawaySelected(selectedIndexPath: indexPath)
            
        case 3:
            homeAlertSelected(indexPath: indexPath)
        default :
            break
        }
        
    }
    
}

extension DashboardTableViewController: UICollectionViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView.tag {
            
        case 1 :
            return Constant.MyClassConstants.flexExchangeDeals.count
        case 2 :
            return (Constant.MyClassConstants.topDeals.count)
        case 3:
            return Constant.MyClassConstants.searchDateResponse.count
        default :
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
            
        case 1 :
            //flexDeals
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 180) )
            resortFlaxImageView.backgroundColor = .lightGray
            
            if let imgURL = flexDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if error != nil {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                resortFlaxImageView.image = UIImage(named: "\(Constant.MyClassConstants.noImage)")
                resortFlaxImageView.contentMode = .center
            }
            
            cell.addSubview(resortFlaxImageView)
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 60))
            
            resortImageNameLabel.text = flexDeal.name
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = .black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16)
            resortImageNameLabel.backgroundColor = .clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            
            return cell
            
        case 2 :
            //TOP10GETAWAY
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 180) )
            resortFlaxImageView.backgroundColor = .lightGray
            let rentalDeal: RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
            
            if let imgURL = rentalDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if error != nil {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                resortFlaxImageView.image = UIImage(named: "\(Constant.MyClassConstants.noImage)")
                resortFlaxImageView.contentMode = .center
            }
            
            cell.addSubview(resortFlaxImageView)
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 60))
            if let header = topTenDeals.header {
                resortImageNameLabel.text = header
            }
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.backgroundColor = .orange
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = .black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16)
            resortImageNameLabel.backgroundColor = .clear
            cell.addSubview(resortImageNameLabel)
            
            let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
            centerView.center = resortFlaxImageView.center
            centerView.backgroundColor = Constant.RGBColorCode.centerViewRgb
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 15, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = topTenDeals.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 12)
            unitLabel.textColor = .white
            unitLabel.backgroundColor = .clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 35, width: centerView.frame.size.width - 20, height: 20))
            if let pricefrom = topTenDeals.price?.fromPrice, let currencyCode = topTenDeals.price?.currencySymbol {
                if let attributedAmount = pricefrom.currencyFormatter(for: currencyCode, baseLineOffSet: 0) {
                    let fromAttributedString = NSMutableAttributedString(string: "From ", attributes: nil)
                    let wkAttributedString = NSAttributedString(string: " Wk.", attributes: nil)
                    fromAttributedString.append(attributedAmount)
                    fromAttributedString.append(wkAttributedString)
                    priceLabel.attributedText = fromAttributedString
                }
            }
            
            priceLabel.numberOfLines = 2
            priceLabel.textAlignment = NSTextAlignment.center
            priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
            priceLabel.textColor = .white
            priceLabel.backgroundColor = .clear
            centerView.addSubview(priceLabel)
            
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            cell.addSubview(centerView)
            return cell
            
        case 3 :
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeAlertCollectionCell", for: indexPath) as? HomeAlertCollectionCell {
                
                let (alert, searchDatesResponse) = Constant.MyClassConstants.searchDateResponse[indexPath.row]
                if let alertTitle = alert.name {
                    cell.alertTitle.text = alertTitle
                }
                
                var fromDate = ""
                var toDate = ""
                if let earliestCheckInDate = alert.earliestCheckInDate {
                    
                    let alertFromDate = Helper.convertStringToDate(dateString:earliestCheckInDate, format: Constant.MyClassConstants.dateFormat)
                    
                    fromDate = (Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.month)).appendingFormat(". ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.year))
                }
                
                if let latestCheckInDate = alert.latestCheckInDate {
                    
                    let alertToDate = Helper.convertStringToDate(dateString: latestCheckInDate, format: Constant.MyClassConstants.dateFormat)
                    
                    toDate = Helper.getWeekDay(dateString: alertToDate, getValue: "Month").appending(". ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: "Date")).appending(", ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: "Year"))
                }
                
                let dateRange = fromDate.appending(" - " + toDate)
                cell.alertDate.text = dateRange
                if let alertID = alert.alertId {
                    if !searchDatesResponse.checkInDates.isEmpty {
                        cell.alertStatus.text = Constant.buttonTitles.viewResults
                        cell.alertStatus.textColor = .white
                        cell.layer.borderColor = UIColor(red: 224.0 / 255.0, green: 118.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0).cgColor
                        cell.backgroundColor = UIColor(red: 224.0 / 255.0, green: 118.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
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
            } else { return UICollectionViewCell() }
            
        default :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            return cell
        }
        
    }
}

extension UIViewController {
    func topTenGetawaySelected(selectedIndexPath: IndexPath) {
        
        //Present No filter options
        Constant.MyClassConstants.noFilterOptions = true
        
        let topTenDeals = Constant.MyClassConstants.topDeals[selectedIndexPath.row]
        if let header = topTenDeals.header {
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = header
        }
        
        ADBMobile.trackAction(Constant.omnitureEvents.event1, data: nil)
        
        // latest changes
        let deal = RentalDeal()
        if let header = Constant.MyClassConstants.topDeals[selectedIndexPath.row].header {
            deal.header = header
        }
        deal.fromDate = Constant.MyClassConstants.topDeals[selectedIndexPath.row].fromDate
        if let areacode = Constant.MyClassConstants.topDeals[selectedIndexPath.row].areaCodes.first {
            deal.areaCodes = [areacode]
        }
        let searchCriteria = Helper.createSearchCriteriaForRentalDeal(deal: deal)
        
        if let settings = Session.sharedSession.appSettings {
            Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
        }

        if Reachability.isConnectedToNetwork() == true {
            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
            showHudAsync()
            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: {[unowned self] (response) in
                
                ADBMobile.trackAction(Constant.omnitureEvents.event18, data: nil)
                // omniture tracking with event 9
                let userInfo: [String: Any] = [
                    Constant.omnitureCommonString.listItem: Constant.MyClassConstants.selectedDestinationNames,
                    Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch,
                    Constant.omnitureEvars.eVar19: Constant.MyClassConstants.vacationSearchShowDate,
                    Constant.omnitureEvars.eVar23: Constant.omnitureCommonString.primaryAlternateDateAvailable,
                    Constant.omnitureEvars.eVar26: "",
                    Constant.omnitureEvars.eVar28: "" ,
                    Constant.omnitureEvars.eVar33: "" ,
                    Constant.omnitureEvars.eVar34: "" ,
                    Constant.omnitureEvars.eVar36: "\(Helper.omnitureSegmentSearchType(index:  Constant.MyClassConstants.searchForSegmentIndex))-\(Constant.MyClassConstants.resortsArray.count)" ,
                    Constant.omnitureEvars.eVar39: "" ,
                    Constant.omnitureEvars.eVar45: "\(Constant.MyClassConstants.vacationSearchShowDate)-\(Date())",
                    Constant.omnitureEvars.eVar47: "\(Constant.MyClassConstants.checkInDates.count)" ,
                    Constant.omnitureEvars.eVar53: "\(Constant.MyClassConstants.resortsArray.count)",
                    Constant.omnitureEvars.eVar61: Constant.MyClassConstants.searchOriginationPoint
                ]
                
                ADBMobile.trackAction(Constant.omnitureEvents.event9, data: userInfo)
                
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                
                // Get activeInterval
                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                
                // Always show a fresh copy of the Scrolling Calendar
                
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                self.hideHudAsync()
                
                // Check not available checkIn dates for the active interval
                
                if activeInterval?.fetchedBefore != nil && activeInterval?.hasCheckInDates() != nil {
                    Helper.showNotAvailabilityResults()
                    self.navigateToSearchResultsScreen()
                    
                } else {
                    
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    let initialSearchCheckInDate = Helper.convertStringToDate(dateString:Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format:Constant.MyClassConstants.dateFormat)
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    //sender.isEnabled = true
                    Helper.helperDelegate = self as? HelperDelegate
                    self.hideHudAsync()
                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: initialSearchCheckInDate, senderViewController: self)
                }
            }) {[unowned self] error in
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.custom(title: "Error".localized(), body: error.localizedDescription))
            }
        } else {
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.noNetConnection)
        }
    }
    
    func flexchangeSelected(selectedIndexPath: IndexPath) {
        
        //Present no filter options
        Constant.MyClassConstants.noFilterOptions = true
        
        let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexchangeViewController) as? FlexchangeSearchViewController {
            viewController.selectedFlexchange = Constant.MyClassConstants.flexExchangeDeals[selectedIndexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func navigateToSearchResultsScreen() {
        var isRunningOnIphone: Bool {
            return UIDevice.current.userInterfaceIdiom == .phone
        }
        if isRunningOnIphone {
            let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController)
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
}
