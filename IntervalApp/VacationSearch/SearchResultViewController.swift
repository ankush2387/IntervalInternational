//
//  SearchResultViewController.swift
//  IntervalApp
//
//  Created by Chetu on 09/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage
import RealmSwift

class SearchResultViewController: UIViewController {
    
    //***** Outlets ****//
    @IBOutlet weak fileprivate var searchResultColelctionView: UICollectionView!
    @IBOutlet weak fileprivate var searchResultTableView: UITableView!
    
    //***** variable declaration *****//
    var collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
    var selectedIndex = -1
    var loadFirst = true
    var enablePreviousMore = true
    var enableNextMore = true
    var unitSizeArray = [AnyObject]()
    var alertView = UIView()
    let headerVw = UIView()
    let titleLabel = UILabel()
    var offerString = String()
    var cellHeight = 50
    var selectedSection = 0
    var selectedRow = 0
    var timer = Timer()
    var bucketIndex = 0
    var exactMatchResortsArray = [Resort]()
    var surroundingMatchResortsArray = [Resort]()
    var surroundingMatchResortsArrayExchange = [ExchangeAvailability]()
    var exactMatchResortsArrayExchange = [ExchangeAvailability]()
    var combinedExactSearchItems = [AvailabilitySectionItem]()
    var combinedSurroundingSearchItems = [AvailabilitySectionItem]()
    var dateCellSelectionColor = Constant.CommonColor.blueColor
    var myActivityIndicator = UIActivityIndicatorView()
    var value: String = ""
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    
    // Only one section with surroundings found
    var onlySurroundingsFound = false
    var showInfoIcon = false
    var vacationSearch = Constant.MyClassConstants.initialVacationSearch
    static let whoWillBeCheckingInViewController = "WhoWillBeCheckingInViewController"
    
    // MARK: - Timer to show availability header
    func runTimer() {
        
        Constant.MyClassConstants.isShowAvailability = false
        self.searchResultTableView.reloadData()
        timer.invalidate()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        createSections()
        self.searchResultColelctionView.reloadData()
        self.searchResultTableView.reloadData()
    }
    
    func createSections() {
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
        
        if sections.isEmpty == true {
            searchResultTableView.tableHeaderView = Helper.noResortView(senderView: self.view)
        } else {
            let headerVw = UIView()
            searchResultTableView.tableHeaderView = headerVw
        }
        
        exactMatchResortsArray.removeAll()
        exactMatchResortsArrayExchange.removeAll()
        surroundingMatchResortsArray.removeAll()
        surroundingMatchResortsArrayExchange.removeAll()
        combinedExactSearchItems.removeAll()
        combinedSurroundingSearchItems.removeAll()
        
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange {
            for section in sections {
                if section.exactMatch == nil || section.exactMatch == true {
                    dateCellSelectionColor = Constant.CommonColor.blueColor
                    guard let items = section.items else { return }
                    for exactResorts in items {
                        if let resortsExact = exactResorts.exchangeAvailability {
                            exactMatchResortsArrayExchange.append(resortsExact)
                        }
                    }
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    guard let items = section.items else { return }
                    for surroundingResorts in items {
                        if let resortsSurrounding = surroundingResorts.exchangeAvailability {
                            exactMatchResortsArrayExchange.append(resortsSurrounding)
                        }
                    }
                }
            }
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
            
            for section in sections {
                if section.exactMatch == nil || section.exactMatch == true {
                    guard let items = section.items else { return }
                    for exactResorts in items {
                        if let resortsExact = exactResorts.rentalAvailability {
                            exactMatchResortsArray.append(resortsExact)
                        }
                    }
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    guard let items = section.items else { return }
                    for surroundingResorts in items {
                            if let resortsSurrounding = surroundingResorts.rentalAvailability {
                            surroundingMatchResortsArray.append(resortsSurrounding)
                        }
                    }
                }
            }
        } else {
            for section in sections {
                guard let items = section.items else { return }
                if section.exactMatch == nil || section.exactMatch == true {
                    combinedExactSearchItems = items
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    combinedSurroundingSearchItems = items
                }
            }
        }
        
        checkExactSurroundingSections()
    }
    
    func checkExactSurroundingSections() {
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
            if exactMatchResortsArray.count > 0 {
                onlySurroundingsFound = false
            } else {
                onlySurroundingsFound = true
            }
            
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            if exactMatchResortsArrayExchange.count > 0 {
                onlySurroundingsFound = false
            } else {
                onlySurroundingsFound = true
            }
        } else {
            if combinedExactSearchItems.count > 0 {
                onlySurroundingsFound = false
            } else {
                onlySurroundingsFound = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.helperDelegate = self
        searchResultTableView.estimatedRowHeight = 400
        searchResultTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        self.hideHudAsync()
        //***** Register collection cell xib with collection view *****//
        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchResultColelctionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
        searchResultTableView.register(UINib(nibName: "SearchResultContentTableCell", bundle: nil), forCellReuseIdentifier: "SearchResultContentTableCell")
        
        self.title = Constant.ControllerTitles.searchResultViewController
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(SearchResultViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        if Constant.MyClassConstants.showAlert == true {
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            headerVw.isHidden = true
            self.view.bringSubview(toFront: self.alertView)
        } else {
            headerVw.isHidden = false
            self.alertView.isHidden = true
        }
        
        self.collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
        
        if Session.sharedSession.userAccessToken != nil {
            showHudAsync()
            UserClient.getFavoriteResorts(Session.sharedSession.userAccessToken, onSuccess: { (response) in
                Constant.MyClassConstants.favoritesResortArray.removeAll()
                for item in [response][0] {
                    if let resort = item.resort {
                        if let code = resort.resortCode {
                        Constant.MyClassConstants.favoritesResortCodeArray.add(code)
                        Constant.MyClassConstants.favoritesResortArray.append(resort)
                        }
                    }
                    
                }

                self.hideHudAsync()
            }) { (_) in
                self.presentErrorAlert(UserFacingCommonError.generic)
                self.hideHudAsync()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSavedDestinationsResorts(storedData: Results <RealmLocalStorage>, searchCriteria: VacationSearchCriteria) {
        //if let storedData = storedData.count {}
        if let firstDestination = storedData.first?.destinations[0] {
            
            let destination = AreaOfInfluenceDestination()
            destination.destinationName = firstDestination.destinationName
            destination.destinationId = firstDestination.destinationId
            destination.aoiId = firstDestination.aoid
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if let resorts = storedData.first?.resorts {
            
            if resorts[0].resortArray.count > 0 {
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(String(describing: resorts[0].resortArray[0].resortName)) + more"
                
            } else {
                let resort = Resort()
                resort.resortName = resorts[0].resortName
                resort.resortCode = resorts[0].resortCode
                searchCriteria.resorts = [resort]
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = resorts[0].resortName
            }
        }
    }
    
    func intervalBucketClicked(calendarItem: CalendarItem, cell: UICollectionViewCell) {
        
        myActivityIndicator.hidesWhenStopped = true
    
        // Resolve the next active interval based on the Calendar interval selected
        guard let activeInterval = vacationSearch.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate, intervalEndDate: calendarItem.intervalEndDate) else { return }
        
        // Fetch CheckIn dates only in the active interval doesn't have CheckIn dates
        if activeInterval.hasCheckInDates() == false {
            
            // Execute Search Dates
            if vacationSearch.searchCriteria.searchType.isRental() {
                
                // Update CheckInFrom and CheckInTo dates
                vacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                vacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearch.rentalSearch?.searchContext.request,
             onSuccess: { (response) in
                
                self.vacationSearch.rentalSearch?.searchContext.response = response
                // Update active interval
                self.vacationSearch.updateActiveInterval(activeInterval: activeInterval)
                Helper.showScrollingCalendar(vacationSearch: self.vacationSearch)
                Constant.MyClassConstants.calendarDatesArray.removeAll()
                Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
                self.searchResultColelctionView.reloadData()
                self.hideHudAsync()
            },
            onError: { (_) in
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.generic)
                }
            )
        } else if vacationSearch.searchCriteria.searchType.isCombined() {
                 
            // Update CheckInFrom and CheckInTo dates
            vacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
            vacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
            vacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
            vacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
            
            // Execute Rental Search Dates
            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearch.rentalSearch?.searchContext.request,
            onSuccess: { (response) in
                
                self.vacationSearch.rentalSearch?.searchContext.response = response
                                            
                // Update active interval
                self.vacationSearch.updateActiveInterval(activeInterval: activeInterval)
                
                // Check not available checkIn dates for the active interval for Rental
                if activeInterval.hasCheckInDates() == false {
                    Constant.MyClassConstants.rentalHasNotAvailableCheckInDatesAfterSelectInterval = true
                }
                self.hideHudAsync()
                // Run Exchange Search Dates
                Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchResultColelctionView)
                
                },
                 onError: { (_) in
                    // Run Exchange Search Dates
                    self.hideHudAsync()
                    Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchResultColelctionView)
                }
                )
            } else {
                
                // Update CheckInFrom and CheckInTo dates
                vacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                vacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                
                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearch.exchangeSearch?.searchContext.request,
                   onSuccess: { (response) in
                    
                    self.vacationSearch.exchangeSearch?.searchContext.response = response
                    self.vacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore == true && activeInterval.hasCheckInDates() == false {
                        Helper.showNotAvailabilityResults()
                        
                    }
                    Constant.MyClassConstants.calendarDatesArray.removeAll()
                    Constant.MyClassConstants.calendarDatesArray =
                        Constant.MyClassConstants.totalBucketArray
                    self.hideHudAsync()
                    self.searchResultColelctionView.reloadData()
                },

               onError: { (_) in
                     self.hideHudAsync()
                     self.presentErrorAlert(UserFacingCommonError.generic)
                }
                )
            }
        } else {
            hideHudAsync()
            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
            Constant.MyClassConstants.calendarDatesArray.removeAll()
            Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
            self.searchResultColelctionView.reloadData()
            myActivityIndicator.stopAnimating()
            cell.alpha = 1.0
        }
    }
    
    //*****Function for more button press *****//
    func intervalDateItemClicked(_ toDate: Date) {
         showHudAsync()
         searchResultColelctionView.reloadData()
         if combinedExactSearchItems.isEmpty && combinedSurroundingSearchItems.isEmpty && exactMatchResortsArray.isEmpty && exactMatchResortsArrayExchange.isEmpty && surroundingMatchResortsArray.isEmpty && surroundingMatchResortsArrayExchange.isEmpty {
            intervalPrint("All empty")
         } else {
            let indexPath = IndexPath(row: 0, section: 0)
            searchResultTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
        Helper.helperDelegate = self
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
            Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        } else {
            showHudAsync()
            let request = RentalSearchResortsRequest()
            request.checkInDate = toDate
            request.resortCodes = activeInterval?.resortCodes
            
            RentalClient.searchResorts(Session.sharedSession.userAccessToken, request: request,
                                       onSuccess: { (response) in
                                        // Update Rental inventory
                                        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.inventory = response.resorts
                                        
                                        // Run Exchange Search Dates
                                        
                                        if let searchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
                                            Helper.executeExchangeSearchAvailabilityAfterSelectCheckInDate(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: searchCheckInDate, format: Constant.MyClassConstants.dateFormat), searchCriteria: Constant.MyClassConstants.initialVacationSearch.searchCriteria, senderVC: self)
                                        }
                                      
                                        
            },
                                       onError: { (_) in
                                       self.presentErrorAlert(UserFacingCommonError.generic)
            }
            )
            
        }
        
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Dynamic API hit
    
    func getFilterRelinquishments(selectedInventoryUnit: Inventory, selectedIndex: Int, selectedExchangeInventory: ExchangeInventory) {
        showHudAsync()
        let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
        exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        exchangeSearchDateRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
        
        let exchangeDestination = ExchangeDestination()
        let resort = Resort()
        resort.resortCode = Constant.MyClassConstants.selectedResort.resortCode
        
        exchangeDestination.resort = resort
        
        let unit = InventoryUnit()
        
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined() {
            let currentFromDate = selectedInventoryUnit.checkInDate
            let currentToDate = selectedInventoryUnit.checkOutDate
            unit.kitchenType = selectedInventoryUnit.units[selectedIndex].kitchenType!
            unit.unitSize = selectedInventoryUnit.units[selectedIndex].unitSize!
            exchangeDestination.checkInDate = currentFromDate
            exchangeDestination.checkOutDate = currentToDate
            unit.publicSleepCapacity = selectedInventoryUnit.units[selectedIndex].publicSleepCapacity
            unit.privateSleepCapacity = selectedInventoryUnit.units[selectedIndex].privateSleepCapacity
            
        } else {
            let currentFromDate = selectedExchangeInventory.checkInDate
            let currentToDate = selectedExchangeInventory.checkOutDate
            unit.kitchenType = selectedExchangeInventory.buckets[selectedIndex].unit?.kitchenType!
            unit.unitSize = selectedExchangeInventory.buckets[selectedIndex].unit?.unitSize!
            exchangeDestination.checkInDate = currentFromDate
            exchangeDestination.checkOutDate = currentToDate
            unit.publicSleepCapacity = selectedExchangeInventory.buckets[selectedIndex].unit!.publicSleepCapacity
            unit.privateSleepCapacity = selectedExchangeInventory.buckets[selectedIndex].unit!.privateSleepCapacity
        }
        exchangeDestination.unit = unit
        exchangeSearchDateRequest.destination = exchangeDestination
        Constant.MyClassConstants.exchangeDestination = exchangeDestination
        
        ExchangeClient.filterRelinquishments(Session.sharedSession.userAccessToken, request: exchangeSearchDateRequest, onSuccess: { (response) in
            self.hideHudAsync()
            Constant.MyClassConstants.filterRelinquishments.removeAll()
            
            for exchageDetail in response {
                Constant.MyClassConstants.filterRelinquishments.append(exchageDetail.relinquishment!)
            }
            
            Constant.MyClassConstants.selectedUnitIndex = selectedIndex
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Combined {
                self.navigateToWhatToUseViewController()
            } else {
                if Constant.MyClassConstants.filterRelinquishments.count > 1 {
                    self.navigateToWhatToUseViewController()
                } else if response.count > 0 && response[0].destination?.upgradeCost != nil {
                    self.navigateToWhatToUseViewController()
                } else {
                    self.startProcess()
                }
            }
            
        }, onError: { (_) in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.generic)
        })
    }
    
    // MARK: - navigation Methods
    func navigateToWhatToUseViewController() {
        if Constant.RunningDevice.deviceIdiom == .phone {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whatToUseViewController) as! WhatToUseViewController
            viewController.delegate = self
            viewController.showInfoIcon = showInfoIcon
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        } else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whatToUseViewController) as! WhatToUseViewController
            viewController.delegate = self
            
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
    }
    
    //Start process function call
    
    func startProcess() {
        
        //Start process request
        
        //Exchange process request parameters
        showHudAsync()
        let processResort = ExchangeProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        let processRequest = ExchangeProcessStartRequest()
        
        processRequest.destination = Constant.MyClassConstants.exchangeDestination
        // Note: constant has value obtained from vacation search screen
        processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
    
        if (Constant.MyClassConstants.filterRelinquishments.count > 0) {
            
            if let openWeek = Constant.MyClassConstants.filterRelinquishments[0].openWeek {
                processRequest.relinquishmentId = openWeek.relinquishmentId
            }
            
            if let deposit = Constant.MyClassConstants.filterRelinquishments[0].deposit {
                processRequest.relinquishmentId = deposit.relinquishmentId
            }
            
            if let pointsProgram = Constant.MyClassConstants.filterRelinquishments[0].pointsProgram {
                processRequest.relinquishmentId = pointsProgram.relinquishmentId
            }
            
            if let clubPoints = Constant.MyClassConstants.filterRelinquishments[0].clubPoints {
                processRequest.relinquishmentId = clubPoints.relinquishmentId
            }
        }
    
        ExchangeProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: {(response) in
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            Constant.MyClassConstants.exchangeViewResponse = response.view!
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            if let exchangeFees = response.view?.fees {
                Constant.MyClassConstants.exchangeFees = [exchangeFees]
            }
            
            for amenity in (response.view?.destination?.resort?.amenities)! {
                if amenity.nearby == false {
                    Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                } else {
                    Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                }
            }
            UserClient.getCurrentMembership(Session.sharedSession.userAccessToken, onSuccess: {(Membership) in
                
                // Got an access token!  Save it for later use.
                self.hideHudAsync()
                Constant.MyClassConstants.membershipContactArray = Membership.contacts!
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                
                if response.view?.forceRenewals != nil {
                    // Navigate to Renewals Screen
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                    viewController.delegate = self
                    self.present(viewController, animated: true, completion: nil)
                    
                } else {
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
                    viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[self.selectedRow]
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                }
            }, onError: { (_) in
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.generic)
                
            })
            
        }, onError: {(_) in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.generic)
        })
    }

    //Passing information while preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    // function called when search result page map view button pressed
    @IBAction func mapViewButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultMapSegue, sender: nil)
    }
    
    @IBAction func sortByNameButtonPressed(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        viewController.selectedSortingIndex = Constant.MyClassConstants.sortingIndex
        self.present(viewController, animated: true, completion: nil)

    }
    
    //funciton called when search result page sort by name button pressed
    @IBAction func filterByNameButtonPressed(_ sender: UIButton) {

        if !Constant.MyClassConstants.noFilterOptions {
            sender.isEnabled = true
            if(Constant.MyClassConstants.filterOptionsArray.count > 1 || alertFilterOptionsArray.count > 1) {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
                viewController.isFilterClicked = true
                viewController.alertFilterOptionsArray = alertFilterOptionsArray
                viewController.resortNameArray = Constant.MyClassConstants.resortsArray
                viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
                self.present(viewController, animated: true, completion: nil)
            } else {
                sender.isEnabled = false
            }
        } else if(alertFilterOptionsArray.count > 1) {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
            viewController.isFilterClicked = true
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            viewController.resortNameArray = Constant.MyClassConstants.resortsArray
            viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
            self.present(viewController, animated: true, completion: nil)
        }

  }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let firstVisibleIndexPath = searchResultTableView.indexPathsForVisibleRows?.first
        let indexPath = IndexPath(item: collectionviewSelectedIndex, section: 0)
        if(firstVisibleIndexPath?.section == 1) {
            dateCellSelectionColor = Constant.CommonColor.greenColor
        } else {
            checkExactSurroundingSections()
            if(onlySurroundingsFound == true) {
                dateCellSelectionColor = Constant.CommonColor.greenColor
            } else {
                dateCellSelectionColor = Constant.CommonColor.blueColor
            }
        }
        
        if(indexPath.row <= Constant.MyClassConstants.calendarDatesArray.count) {
            if(searchResultColelctionView != nil) {
                searchResultColelctionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    // Common method to get exchange collection view cell
    func getGetawayCollectionCell(indexPath: IndexPath, collectionView: UICollectionView) -> RentalInventoryCVCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortInventoryCell, for: indexPath) as! RentalInventoryCVCell
        return cell
    }
    
    // Common method to get rental collection view cell
    func getExchangeCollectionCell(indexPath: IndexPath, collectionView: UICollectionView) -> ExchangeInventoryCVCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.exchangeInventoryCell, for: indexPath) as! ExchangeInventoryCVCell
        return cell
        
    }
    
    // Common method to get Resort Info collection view cell
    func getResortInfoCollectionCell(indexPath: IndexPath, collectionView: UICollectionView, resort: Resort) -> AvailabilityCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as! AvailabilityCollectionViewCell
        cell.setResortDetails(inventoryItem: resort)
        intervalPrint(Constant.MyClassConstants.favoritesResortCodeArray)
        let status = Helper.isResrotFavorite(resortCode: resort.resortCode!)
        if(status) {
            cell.favourite.isSelected = true
        } else {
            cell.favourite.isSelected = false
        }
        
        if(collectionView.superview?.superview?.tag == 0) {
            
            if(exactMatchResortsArray.count > 0) {
                cell.favourite.tag = collectionView.tag
                cell.favourite.accessibilityValue = collectionView.accessibilityValue
            } else {
                cell.favourite.tag = collectionView.tag
                cell.favourite.accessibilityValue = collectionView.accessibilityValue
            }
            
        } else {
            cell.favourite.tag = collectionView.tag
            cell.favourite.accessibilityValue = collectionView.accessibilityValue
        }
        
        cell.favourite.addTarget(self, action: #selector(favoriteButtonclicked(_:)), for: .touchUpInside)
        return cell
    }
    func update() {
        
        self.searchResultTableView.reloadData()
        
    }
    
    // MARK: - Call for membership
    func checkUserMembership(response: RentalProcessPrepareResponse) {
        UserClient.getCurrentMembership(Session.sharedSession.userAccessToken, onSuccess: {(Membership) in
            
            // Got an access token!  Save it for later use.
            self.hideHudAsync()
            Constant.MyClassConstants.membershipContactArray = Membership.contacts!
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            
            if response.view?.forceRenewals != nil {
                // Navigate to Renewals Screen
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            } else {
                // Navigate to Who Will Be Checking in Screen
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            
        }, onError: { (_) in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.generic)
        })
    }
    
    func favoriteButtonclicked(_ sender: UIButton) {
        
        let section = sender.accessibilityValue!
        
        if (Session.sharedSession.userAccessToken) != nil {
            
            var resortCode = ""
            if  section == "0" {
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
                    if exactMatchResortsArray.count == 0 {
                        resortCode = surroundingMatchResortsArray[sender.tag].resortCode!
                    } else {
                        resortCode = exactMatchResortsArray[sender.tag].resortCode!
                    }
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange {
                    if exactMatchResortsArrayExchange.count == 0 {
                        resortCode = (surroundingMatchResortsArrayExchange[sender.tag].resort?.resortCode!)!
                    } else {
                        resortCode = (exactMatchResortsArrayExchange[sender.tag].resort?.resortCode!)!
                    }
                } else {
                    resortCode = (combinedExactSearchItems[sender.tag].rentalAvailability?.resortCode)!
                }
                
            } else {
                
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
                    resortCode = surroundingMatchResortsArray[sender.tag].resortCode!
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange {
                    resortCode = (surroundingMatchResortsArrayExchange[sender.tag].resort?.resortCode!)!
                } else {
                    resortCode = (combinedSurroundingSearchItems[sender.tag].rentalAvailability?.resortCode)!
                }
                
            }
            
            if sender.isSelected == false {
                showHudAsync()
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: {(_) in
                    
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                    let indexpath = NSIndexPath(row: sender.tag, section: Int(section)!)
                    intervalPrint(Constant.MyClassConstants.favoritesResortCodeArray)
                    self.searchResultTableView.reloadRows(at: [indexpath as IndexPath], with: .automatic)
                    
                }, onError: {(_) in
                    self.hideHudAsync()
                })
            } else {
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: {(_) in
                    
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                    let indexpath = NSIndexPath(row: sender.tag, section: Int(section)!)
                    self.searchResultTableView.reloadRows(at: [indexpath as IndexPath], with: .automatic)
                    
                }, onError: {(_) in
                    self.hideHudAsync()
                })
                
            }
        } else {
            
            Constant.MyClassConstants.btnTag = sender.tag
            self.performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
        }
    }
    
}

//***** MARK: Extension classes starts from here *****//

extension SearchResultViewController: UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == -1 {
            
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            
            if cell.isKind(of: MoreCell.self) {
                
                let viewForActivity = UIView()
                viewForActivity.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                
                myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                
                // Position Activity Indicator in the center of the main view
                myActivityIndicator.center = cell.contentView.center
                
                // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
                myActivityIndicator.hidesWhenStopped = false
                
                // Start Activity Indicator
                myActivityIndicator.startAnimating()

                cell.alpha = 0.3
                viewForActivity.addSubview(myActivityIndicator)
                cell.contentView.addSubview(viewForActivity)
            }
            
            collectionviewSelectedIndex = indexPath.item
            dateCellSelectionColor = Constant.CommonColor.blueColor
            if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval! {
                showHudAsync()
                intervalBucketClicked(calendarItem: Constant.MyClassConstants.calendarDatesArray[indexPath.item], cell: cell)
            } else {
                
                intervalDateItemClicked(Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[indexPath.item].checkInDate!, format: Constant.MyClassConstants.dateFormat))
            }
        } else {
            
            // Check for renewals no thanks
            Constant.MyClassConstants.noThanksForNonCore = false
            
            if indexPath.section == 0 {
                Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
                Constant.MyClassConstants.isFromSearchResult = true

                showHudAsync()
                var resortCode = ""
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
                    
                    if collectionView.superview?.superview?.tag == 0 && exactMatchResortsArray.count > 0 {
                       resortCode = exactMatchResortsArray[collectionView.tag].resortCode!
                    } else {
                        resortCode = surroundingMatchResortsArray[collectionView.tag].resortCode!
                    }
                  
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    if collectionView.superview?.superview?.tag == 0 && exactMatchResortsArrayExchange.count > 0 {
                        resortCode = (self.exactMatchResortsArrayExchange[collectionView.tag].resort?.resortCode!)!
                    } else {
                        resortCode = (self.surroundingMatchResortsArrayExchange[collectionView.tag].resort?.resortCode!)!
                    }
                } else {
                    if collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count > 0 {
                        if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil {
                            resortCode = (combinedExactSearchItems[collectionView.tag].rentalAvailability!.resortCode!)
                        } else {
                            resortCode = (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort?.resortCode!)!
                        }
                        
                    } else {
                        if combinedSurroundingSearchItems[indexPath.section].rentalAvailability != nil {
                            resortCode = (combinedSurroundingSearchItems[indexPath.section].rentalAvailability!.resortCode!)
                        } else {
                            resortCode = (combinedSurroundingSearchItems[indexPath.section].exchangeAvailability?.resort?.resortCode!)!
                        }
                    }
                }
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { (response) in
                    
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAllObjects()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray {
                        if imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame {
                            
                            Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                        }
                    }
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = collectionView.tag + 1
                    self.hideHudAsync()
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.vacationSearchDetailSegue, sender: nil)
                }) { (_) in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
            } else {
                
                // it is used in renewal screen to change the title of header
                Constant.MyClassConstants.isChangeNoThanksButtonTitle = false
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        selectedSection = (collectionView.superview?.superview?.tag)!
                        selectedRow = collectionView.tag
                        if collectionView.superview?.superview?.tag == 0 {
                            if let resort = exactMatchResortsArrayExchange[collectionView.tag].resort {
                                Constant.MyClassConstants.selectedResort = resort
                            }
                            if let inventory = exactMatchResortsArrayExchange[collectionView.tag].inventory {
                                self.getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory)
                            }
                        } else {
                            if let resort = surroundingMatchResortsArrayExchange[collectionView.tag].resort {
                                Constant.MyClassConstants.selectedResort = resort
                            }
                            if let inventory = surroundingMatchResortsArrayExchange[collectionView.tag].inventory {
                                self.getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory)
                            }
                        }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                    
                    showHudAsync()
                    
                    if collectionView.superview?.superview?.tag == 0 && self.exactMatchResortsArray.isEmpty == false {
                           Constant.MyClassConstants.selectedResort = self.exactMatchResortsArray[collectionView.tag]
                    } else {
                        Constant.MyClassConstants.selectedResort = self.surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    var inventoryDict = Inventory()
                    inventoryDict = Constant.MyClassConstants.selectedResort.inventory!
                    let invent = inventoryDict
                    let units = invent.units
                    
                    Constant.MyClassConstants.inventoryPrice = invent.units[indexPath.item].prices
                    
                    let processResort = RentalProcess()
                    processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                    
                    let processRequest = RentalProcessStartRequest()
                    processRequest.resort = Constant.MyClassConstants.selectedResort
                    if Constant.MyClassConstants.selectedResort.allInclusive {
                        Constant.MyClassConstants.hasAdditionalCharges = true
                    } else {
                        Constant.MyClassConstants.hasAdditionalCharges = false
                    }
                    processRequest.unit = units[indexPath.item]
                    
                    let processRequest1 = RentalProcessStartRequest(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate!, unitSize: UnitSize(rawValue: units[indexPath.item].unitSize!)!, kitchenType: KitchenType(rawValue: units[indexPath.item].kitchenType!)!)
                    
                    RentalProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
                        
                        let processResort = RentalProcess()
                        processResort.processId = response.processId
                        Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
                        Constant.MyClassConstants.processStartResponse = response
                        self.hideHudAsync()
                        Constant.MyClassConstants.viewResponse = response.view!
                        if let rentalFees = response.view?.fees {
                            Constant.MyClassConstants.rentalFees = [rentalFees]
                        }
                        
                        Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                        Constant.MyClassConstants.onsiteArray.removeAllObjects()
                        Constant.MyClassConstants.nearbyArray.removeAllObjects()
                        
                        for amenity in (response.view?.resort?.amenities)! {
                            if(amenity.nearby == false) {
                                Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                            } else {
                                Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                            }
                        }
                        
                        // MARK: - Check forced renewals before calling membership
                        self.checkUserMembership(response: response)
                    }, onError: {(_) in
                        self.hideHudAsync()
                        self.presentErrorAlert(UserFacingCommonError.generic)
                    })
                } else { // search both
                    selectedSection = (collectionView.superview?.superview?.tag)!
                    selectedRow = collectionView.tag
                    Constant.MyClassConstants.selectedUnitIndex = indexPath.item
                    if collectionView.superview?.superview?.tag == 0 {
                        
                        if combinedExactSearchItems.count > 0 {
                            if combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil {
                                
                                Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                                if let bucket = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets[indexPath.row] {
                                    if bucket.pointsCost != bucket.memberPointsRequired {
                                        showInfoIcon = true
                                    }
                                }
                                
                            } else {
                                Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].rentalAvailability!)
                            }
                        } else {
                            if combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability != nil {
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                                if let bucket = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets[indexPath.row] {
                                    if bucket.pointsCost != bucket.memberPointsRequired {
                                        showInfoIcon = true
                                    }
                                }
                            } else {
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                            }
                        }
                        
                        if combinedExactSearchItems.count > 0 {
                        if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil || combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil {
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].rentalAvailability!)
                            
                            if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability() {
                                
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                
                            } else if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                self.navigateToWhatToUseViewController()
                            } else {
                              
                                  self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                               
                            }
                            
                        } else {
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }
                        } else {
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil) {
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                                
                                if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()) {
                                    
                                    Constant.MyClassConstants.filterRelinquishments.removeAll()
                                    self.navigateToWhatToUseViewController()
                                } else {
                                    self.getFilterRelinquishments(selectedInventoryUnit: (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                }
                                
                            } else {
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                            }
                        }
                    } else {
                        
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil {
                            Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                        } else {
                            Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }
                        
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability != nil {
                            
                            if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability()) {
                                
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                
                            } else if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()) {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                self.navigateToWhatToUseViewController()
                            } else {
                                
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                
                            }
                       
                        } else {
                            self.navigateToWhatToUseViewController()
                        }
                    }
                }
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if (loadFirst) {
            
            loadFirst = false
        }
    }
}
extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 6.0, bottom: 5.0, right: 6.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView.tag == -1) {
            if (Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)! {
                return CGSize(width: 110.0, height: 60.0)
            } else {
                return CGSize(width: 60.0, height: 60.0)
            }
        } else {
            if(indexPath.section == 0) {
                return CGSize(width: UIScreen.main.bounds.width, height: 270.0)
            } else {
                return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
            }
        }
        
    }
}

extension SearchResultViewController: UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(collectionView.tag == -1) {
            return 1
        } else {
            return 2
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView.tag == -1) {
            return Constant.MyClassConstants.calendarDatesArray.count
        } else {
            if(section == 0) {
                return 1
            } else {
                
                if(collectionView.superview?.superview?.tag == 0) {
                    
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()) {
                        
                         return (exactMatchResortsArrayExchange[collectionView.tag].inventory?.buckets.count)!
                    } else if (Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()) {
                        
                        if(exactMatchResortsArray.count > 0) {
                            
                           return (exactMatchResortsArray[collectionView.tag].inventory?.units.count)!
                        } else {
                            
                            return (surroundingMatchResortsArray[collectionView.tag].inventory?.units.count)!
                        }
                        
                    } else {
                        
                        if(combinedExactSearchItems.count > 0) {
                            
                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil) {
                            return (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                        } else {
                            return (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                        }
                        } else {
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil) {
                                return (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                            } else {
                                return (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                            }
                        }
                        
                    }
                   
                } else {
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()) {
                        
                        return (surroundingMatchResortsArrayExchange[collectionView.tag].inventory?.buckets.count)!
                    } else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()) {
                        
                        return (surroundingMatchResortsArray[collectionView.tag].inventory?.units.count)!
                    } else {
                        if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil) {
                            return (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                        } else {
                            return (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                        }

                    }
                }
              
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == -1 {
            
            if (Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)! {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.moreCell, for: indexPath) as! MoreCell
                if(Constant.MyClassConstants.calendarDatesArray[indexPath.item].isIntervalAvailable)! {
                    cell.isUserInteractionEnabled = true
                    cell.backgroundColor = UIColor.white
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = UIColor.lightGray
                }
                cell.setDateForBucket(index: indexPath.item, selectedIndex: collectionviewSelectedIndex, color: dateCellSelectionColor)

                return cell
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell, for: indexPath) as! SearchResultCollectionCell
                if((indexPath as NSIndexPath).row == collectionviewSelectedIndex) {
                    
                    if(dateCellSelectionColor == Constant.CommonColor.greenColor) {
                        cell.backgroundColor = IUIKColorPalette.primary1.color
                    } else {
                        cell.backgroundColor = Constant.CommonColor.headerGreenColor
                    }
                    cell.dateLabel.textColor = UIColor.white
                    cell.daynameWithyearLabel.textColor = UIColor.white
                    cell.monthYearLabel.textColor = UIColor.white

                } else {
                    cell.backgroundColor = UIColor.white
                    cell.dateLabel.textColor = IUIKColorPalette.primary1.color
                    cell.daynameWithyearLabel.textColor = IUIKColorPalette.primary1.color
                    cell.monthYearLabel.textColor = IUIKColorPalette.primary1.color
                }
                cell.layer.cornerRadius = 7
                cell.layer.borderWidth = 2
                cell.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                cell.layer.masksToBounds = true
                
                cell.setSingleDateItems(index: indexPath.item)
                return cell
            }
            
        } else {
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
                
                var inventoryItem = Resort()
                if(collectionView.superview?.superview?.tag == 0) {
                    if(exactMatchResortsArray.count > 0) {
                        inventoryItem = exactMatchResortsArray[collectionView.tag]
                        
                    } else {
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                } else {
                    inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                }
                
                if(indexPath.section == 0) {
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                    
                } else {
                    
                    let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.setDataForRentalInventory(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange {
                
                if(indexPath.section == 0) {
                    
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0) {
                        inventoryItem = exactMatchResortsArrayExchange[collectionView.tag].resort!
                    } else {
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                } else {
                    
                    var inventoryItem = ExchangeInventory()
                    if(collectionView.superview?.superview?.tag == 0) {
                        inventoryItem = exactMatchResortsArrayExchange[collectionView.tag].inventory!
                    } else {
                        inventoryItem = surroundingMatchResortsArrayExchange[collectionView.tag].inventory!
                    }
                    
                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.exchangeCellDelegate = self
                    cell.setUpExchangeCell(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            } else {
                if(indexPath.section == 0) {
                    
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count != 0) {
                        if(combinedExactSearchItems[collectionView.tag].hasRentalAvailability()) {
                            let rentalInventory = combinedExactSearchItems[collectionView.tag].rentalAvailability
                            inventoryItem = rentalInventory!
                        } else {
                            let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability
                            inventoryItem = (exchangeInventory?.resort)!
                        }
                        
                    } else {
                        if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()) {
                            let rentalInventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                            inventoryItem = rentalInventory!
                        } else {
                            let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability
                            inventoryItem = (exchangeInventory?.resort)!
                        }
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                } else {
                    
                    if((collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count > 0 && combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability()) || (collectionView.superview?.superview?.tag == 1 && combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability())) {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as! SearchBothInventoryCVCell
                     
                        if(collectionView.superview?.superview?.tag == 0) {
                            if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil) {
                                let inventory = combinedExactSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            } else {
                                let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort
                                cell.setDataForBothInventoryType(invetoryItem: exchangeInventory!, indexPath: indexPath)
                            }
                        } else {
                            
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil) {
                                let inventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            } else {
                                let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort
                                cell.setDataForBothInventoryType(invetoryItem: exchangeInventory!, indexPath: indexPath)
                            }
                            
                        }
                        
                        return cell
                    } else if(collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count > 0) {
                        if(combinedExactSearchItems[collectionView.tag].hasRentalAvailability()) {
                            let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.setDataForRentalInventory( invetoryItem: combinedExactSearchItems[collectionView.tag].rentalAvailability!, indexPath: indexPath)
                            return cell
                        } else {
                            let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.exchangeCellDelegate = self
                            cell.setUpExchangeCell(invetoryItem: (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory)!, indexPath:indexPath)
                            return cell
                        }
                    } else {
                        if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()) {
                            let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.setDataForRentalInventory( invetoryItem: combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!, indexPath: indexPath)
                            return cell
                        } else {
                            let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.exchangeCellDelegate = self
                            cell.setUpExchangeCell(invetoryItem: (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory)!, indexPath:indexPath)
                            return cell
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(section == 0) {
           return 0
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.frame.width - 60, height: 40))
        headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
        let headerButton = UIButton(frame: CGRect(x: 20, y: 0, width: tableView.frame.width - 40, height: 40))
        headerButton.addTarget(self, action: #selector(SearchResultViewController.filterByNameButtonPressed(_:)), for: .touchUpInside)
        let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
        if sectionsInSearchResult.count > 0 {
                    for sections in sectionsInSearchResult {
                        if (sections.exactMatch == nil || sections.exactMatch == true) && section == 0  {
                            headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                            headerView.backgroundColor = Constant.CommonColor.headerGreenColor
                            break
                        } else if (sections.exactMatch == nil || sections.exactMatch == false) && section == 1 {
                            headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                            headerView.backgroundColor = IUIKColorPalette.primary1.color
                        } else {
                            headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                            headerView.backgroundColor = IUIKColorPalette.primary1.color
                        }
                    }
        }
        headerLabel.textColor = UIColor.white
        headerView.addSubview(headerLabel)
        
        let dropDownImgVw = UIImageView(frame: CGRect(x: tableView.frame.width - 40, y: 5, width: 30, height: 30))
        dropDownImgVw.image = UIImage(named: Constant.assetImageNames.dropArrow)
        if !Constant.MyClassConstants.noFilterOptions || alertFilterOptionsArray.count > 0 {
            if Constant.MyClassConstants.filterOptionsArray.count > 1 || alertFilterOptionsArray.count > 1 {
            headerView.addSubview(dropDownImgVw)
            headerView.addSubview(headerButton)
            }
        }
        return headerView
    }
}

extension SearchResultViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if indexPath.section == 0 {
            
            if indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                return 110
            } else {
                if Constant.MyClassConstants.isShowAvailability == true {
                    let index = indexPath.row - 1
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        if self.exactMatchResortsArrayExchange.count > 0 {
                            if let totalUnits = self.exactMatchResortsArrayExchange[index].inventory?.buckets.count {
                                return CGFloat(totalUnits*80 + 270 + 10)
                            } else {
                                return 0
                            }
                            
                        } else {
                            if let totalUnits = self.surroundingMatchResortsArrayExchange[index].inventory?.buckets.count {
                            return CGFloat(totalUnits*80 + 270 + 10)
                            } else {
                                return 0
                            }
                        }
                        
                    } else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()) {
                        if exactMatchResortsArray.count > 0 {
                            if let totalUnits = self.exactMatchResortsArray[index].inventory?.units.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        } else {
                            if let totalUnits = self.surroundingMatchResortsArray[index].inventory?.units.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        }
                       
                    } else {
                        if combinedExactSearchItems.count > 0 {
                        if(combinedExactSearchItems[index].hasRentalAvailability()) {
                            let rentalInventory = combinedExactSearchItems[index].rentalAvailability
                            if let totalUnits = rentalInventory?.inventory?.units.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        } else {
                            let exchangeInventory = combinedExactSearchItems[index].exchangeAvailability
                            if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        }
                        } else {
                            if combinedSurroundingSearchItems[index].hasRentalAvailability() {
                                let rentalInventory = combinedSurroundingSearchItems[index].rentalAvailability
                                if let totalUnits = rentalInventory?.inventory?.units.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                                } else {
                                    return 0
                                }
                            } else {
                                let exchangeInventory = combinedSurroundingSearchItems[index].exchangeAvailability
                                if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                                } else {
                                    return 0
                                }
                            }
                        }
                    }
                } else {
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        if let totalUnits = self.exactMatchResortsArrayExchange[indexPath.row].inventory?.buckets.count {
                        return CGFloat(totalUnits * 80 + 270 + 10)
                        } else {
                            return 0
                        }
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        if exactMatchResortsArray.count > 0 {
                            if let totalUnits = self.exactMatchResortsArray[indexPath.row].inventory?.units.count {
                            return CGFloat(totalUnits*80 + 270 + 10)
                            } else {
                                return 0
                            }
                        } else {
                            if let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        }
                        
                    } else {
                        if combinedExactSearchItems.isEmpty == false {
    
                        if combinedExactSearchItems[indexPath.row].hasRentalAvailability() {
                            let rentalInventory = combinedExactSearchItems[indexPath.row].rentalAvailability
                            if let totalUnits = rentalInventory?.inventory?.units.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        } else {
                            let exchangeInventory = combinedExactSearchItems[indexPath.row].exchangeAvailability
                            if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        }
                        } else {
                            
                            if combinedSurroundingSearchItems[indexPath.row].hasRentalAvailability() {
                                let rentalInventory = combinedSurroundingSearchItems[indexPath.row].rentalAvailability
                                if let totalUnits = rentalInventory?.inventory?.units.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                                } else {
                                    return 0
                                }
                            } else {
                                let exchangeInventory = combinedSurroundingSearchItems[indexPath.row].exchangeAvailability
                                if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                                } else {
                                    return 0
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                if let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count {
                return CGFloat(totalUnits * 80 + 270 + 10)
                } else {
                    return 0
                }
            } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                if let totalUnits = self.surroundingMatchResortsArrayExchange[indexPath.row].inventory?.buckets.count {
                return CGFloat(totalUnits * 80 + 270 + 10)
                } else {
                    return 0
                }
            } else {
                if combinedSurroundingSearchItems[indexPath.row].rentalAvailability != nil {
                    if let totalUnits = self.combinedSurroundingSearchItems[indexPath.row].rentalAvailability?.inventory?.units.count {
                    return CGFloat(totalUnits * 80 + 270 + 10 )
                    } else {
                        return 0
                    }
                } else {
                    if let totalUnits = self.combinedSurroundingSearchItems[indexPath.row].exchangeAvailability?.inventory?.buckets.count {
                    return CGFloat(totalUnits * 80 + 270 + 10)
                    } else {
                        return 0
                    }
                }
            }
        }
    }
}

extension SearchResultViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
            if indexPath.section == 0 && indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.novailabilityCell, for: indexPath)
                    cell.tag = indexPath.section
                
                    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimer), userInfo: nil, repeats: false)
               
                return cell
                
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.availabilityCell, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
                cell.tag = indexPath.section
                if Constant.MyClassConstants.isShowAvailability == true && indexPath.section == 0 {
                    
                    cell.resortInfoCollectionView.tag = indexPath.row - 1
                    cell.resortInfoCollectionView.accessibilityValue = String(indexPath.section)
                } else {
                    cell.resortInfoCollectionView.tag = indexPath.row
                    cell.resortInfoCollectionView.accessibilityValue = String(indexPath.section)
                }
                
                cell.resortInfoCollectionView.reloadData()
                cell.resortInfoCollectionView
                    .isScrollEnabled = false
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = UIColor.lightGray.cgColor
                return cell
                
            }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
        return sectionsInSearchResult.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            
            if section == 0 && exactMatchResortsArrayExchange.count == 0 || section == 1 {
                if exactMatchResortsArrayExchange.count == 0 && Constant.MyClassConstants.isShowAvailability == true {
                    return surroundingMatchResortsArrayExchange.count + 1
                } else {
                    return surroundingMatchResortsArrayExchange.count
                }
            } else {
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArrayExchange.count + 1
                    
                } else {
                    return exactMatchResortsArrayExchange.count
                }
            
            }
            
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
            if section == 0 && exactMatchResortsArray.count == 0 || section == 1 {
                if exactMatchResortsArray.count == 0 && Constant.MyClassConstants.isShowAvailability == true {
                    return surroundingMatchResortsArray.count + 1
                } else {
                    return surroundingMatchResortsArray.count
                }
                
            } else {
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArray.count + 1
                    
                } else {
                    return exactMatchResortsArray.count
                }
            }
        } else {
            if section == 0 && combinedExactSearchItems.count == 0 || section == 1 {
                
                if combinedExactSearchItems.count == 0 && Constant.MyClassConstants.isShowAvailability == true {
                    return combinedSurroundingSearchItems.count + 1
                } else {
                    return combinedSurroundingSearchItems.count
                }
               
            } else {
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return combinedExactSearchItems.count + 1
                    
                } else {
                    return combinedExactSearchItems.count
                }
            }
        }
    }
}

extension SearchResultViewController: SearchResultContentTableCellDelegate {
    func favoriteButtonClicked(_ sender: UIButton) {
        guard let resortCode = Constant.MyClassConstants.resortsArray[sender.tag].resortCode else { return }
        
        if (Session.sharedSession.userAccessToken) != nil {
            
            if sender.isSelected == false {
                
                showHudAsync()
                
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: {(_) in
                   
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                    self.searchResultTableView.reloadData()
                    
                }, onError: {(_) in
                    
                    self.hideHudAsync()
                    
                })
            } else {
                
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { response in
                    intervalPrint(response)
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                    self.update()
                }, onError: {(_) in
                    self.hideHudAsync()
                })
            }
        } else {
            Constant.MyClassConstants.btnTag = sender.tag
            self.performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
        }
        
    }
    func unfavoriteButtonClicked(_ sender: UIButton) {
        sender.isSelected = false
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension SearchResultViewController: HelperDelegate {
    
    func resortSearchComplete() {
        
        self.hideHudAsync()
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        
        self.createSections()
        self.searchResultColelctionView.reloadData()
        self.searchResultTableView.reloadData()
        if combinedExactSearchItems.isEmpty && combinedSurroundingSearchItems.isEmpty && exactMatchResortsArray.isEmpty && exactMatchResortsArrayExchange.isEmpty && surroundingMatchResortsArray.isEmpty && surroundingMatchResortsArrayExchange.isEmpty {
            intervalPrint("All empty")
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            searchResultTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func resetCalendar() {
        
    }

}

// Implementing custom delegate method definition
extension SearchResultViewController: RenewelViewControllerDelegate {
    
    //remove later
    func dismissWhatToUse(renewalArray: [Renewal]) {
        self.dismiss(animated: false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.renewalsArray = renewalArray
        intervalPrint("_______>self.selectedRow,\(self.selectedRow)")
        viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[self.selectedRow]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
  
     func selectedRenewalFromWhoWillBeCheckingIn(renewalArray: [Renewal]) {
        self.dismiss(animated: false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.renewalsArray = renewalArray
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func noThanks() {
        self.dismiss(animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        if Constant.RunningDevice.deviceIdiom == .phone {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.renewalOtherOptionsVC) as? RenewalOtherOptionsVC else { return }
            viewController.delegate = self
            
            viewController.forceRenewals = forceRenewals
            self.present(viewController, animated: true, completion: nil)
            
            return
            
        } else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.renewalOtherOptionsVC) as? RenewalOtherOptionsVC else { return }
            viewController.delegate = self
            
            viewController.forceRenewals = forceRenewals
            self.present(viewController, animated: true, completion: nil)
            
            return
        }
    }
    
}

// Mark : - Delegate
extension SearchResultViewController: RenewalOtherOptionsVCDelegate {
    func selectedRenewal(selectedRenewal: String, forceRenewals: ForceRenewals) {
        var renewalArray = [Renewal]()
        renewalArray.removeAll()
        if selectedRenewal == Helper.renewalType(type: 0) {
            // Selected core renewal
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products where renewal.term == lowestTerm {
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalItem.productCode = renewal.productCode
                    renewalArray.append(renewalItem)
                    break
            }
        } else if selectedRenewal == Helper.renewalType(type: 2) {
            // Selected combo renewal
            
            for comboProduct in (forceRenewals.comboProducts) {
                let comboLowestTerm = comboProduct.renewalComboProducts[0].term
                for renewalComboProduct in comboProduct.renewalComboProducts where renewalComboProduct.term == comboLowestTerm {
                        let renewalItem = Renewal()
                        renewalItem.id = renewalComboProduct.id
                        renewalItem.productCode = renewalComboProduct.productCode
                        renewalArray.append(renewalItem)
                }
            }
        } else {
            // Selected non core renewal
            let lowestTerm = forceRenewals.crossSelling[0].term
            for renewal in forceRenewals.crossSelling where renewal.term == lowestTerm {
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalArray.append(renewalItem)
                    break
            }
        }
        
        // Selected single renewal from other options. Navigate to WhoWillBeCheckingIn screen
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        viewController.isFromRenewals = true
        viewController.renewalsArray = renewalArray
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchResultViewController: WhoWillBeCheckInDelegate {
    func navigateToWhoWillBeCheckIn(renewalArray: [Renewal], selectedRow: Int) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.renewalsArray = renewalArray
        viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[selectedRow]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchResultViewController:ExchangeInventoryCVCellDelegate {
    func infoIconPressed() {
        self.performSegue(withIdentifier: "pointsInfoSegue", sender: self)
    }
}
