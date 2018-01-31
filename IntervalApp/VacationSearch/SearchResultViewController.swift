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
    var currencyCode = ""
    
    // Only one section with surroundings found
    var onlySurroundingsFound = false
    var showInfoIcon = false
    static let whoWillBeCheckingInViewController = "WhoWillBeCheckingInViewController"
    
    // MARK: - Timer to show availability header
    func runTimer() {
        
        Constant.MyClassConstants.isShowAvailability = false
        self.searchResultTableView.reloadData()
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        createSections()
        self.searchResultTableView.reloadData()
        self.searchResultColelctionView.reloadData()
    }
    
    @IBAction func unwindToAvailabiity(_ segue: UIStoryboardSegue) {}
    
    func createSections() {
        
        if !Constant.MyClassConstants.resortsArray.isEmpty {
            
            let currencycode = Constant.MyClassConstants.initialVacationSearch.rentalSearch?.inventory?[0].inventory?.currencyCode ?? ""
            let currencyHelper = CurrencyHelper()
            let currency = currencyHelper.getCurrency(currencyCode: currencycode )
            currencyCode = ("\(currencyHelper.getCurrencyFriendlySymbol(currencyCode: currency.code))")
            
        }
        
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
        
        if sections.isEmpty {
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
        
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.EXCHANGE {
            for section in sections {
                if section.exactMatch {
                    dateCellSelectionColor = Constant.CommonColor.blueColor
                    for exactResorts in section.items {
                        if let resortsExact = exactResorts.exchangeAvailability {
                            exactMatchResortsArrayExchange.append(resortsExact)
                        }
                    }
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    // guard let items = section.items else { return }
                    for surroundingResorts in section.items {
                        if let resortsSurrounding = surroundingResorts.exchangeAvailability {
                            exactMatchResortsArrayExchange.append(resortsSurrounding)
                        }
                    }
                }
            }
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.RENTAL {
            
            for section in sections {
                if section.exactMatch {
                    dateCellSelectionColor = Constant.CommonColor.blueColor
                    for exactResorts in section.items {
                        if let resortsExact = exactResorts.rentalAvailability {
                            exactMatchResortsArray.append(resortsExact)
                        }
                    }
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    for surroundingResorts in section.items {
                        if let resortsSurrounding = surroundingResorts.rentalAvailability {
                            surroundingMatchResortsArray.append(resortsSurrounding)
                        }
                    }
                }
            }
        } else {
            for section in sections {
                if section.exactMatch {
                    combinedExactSearchItems = section.items
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    combinedSurroundingSearchItems = section.items
                }
            }
        }
        
        checkExactSurroundingSections()
        
        var index = 0
        for (Index, calendarItem) in Constant.MyClassConstants.calendarDatesArray.enumerated() {
            if calendarItem.checkInDate == Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
                index = Index
                break
            }
        }
        let indexpath = IndexPath(item: index, section: 0)
        searchResultColelctionView.scrollToItem(at: indexpath, at: .centeredHorizontally, animated: true)
        searchResultColelctionView.reloadData()
      
    }
    
    func checkExactSurroundingSections() {
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
            if !exactMatchResortsArray.isEmpty {
                onlySurroundingsFound = false
            } else {
                onlySurroundingsFound = true
            }
            
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            if !exactMatchResortsArrayExchange.isEmpty {
                onlySurroundingsFound = false
            } else {
                onlySurroundingsFound = true
            }
        } else {
            if !combinedExactSearchItems.isEmpty {
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
            }) { [weak self] error in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
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
            
            if !resorts[0].resortArray.isEmpty {
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
        intervalPrint(Constant.MyClassConstants.initialVacationSearch)
        // Resolve the next active interval based on the Calendar interval selected
        
        // FIXME (Frank): Optional unwrapped issue
        guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate!, intervalEndDate: calendarItem.intervalEndDate!) else { return }
        
        // Fetch CheckIn dates only in the active interval doesn't have CheckIn dates
        if activeInterval.hasCheckInDates() == false {
            
            switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                
            case VacationSearchType.RENTAL:
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate ?? "", format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate ?? "", format: Constant.MyClassConstants.dateFormat)
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                         onSuccess: { (response) in
                                            
                                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            self.searchResultColelctionView.reloadData()
                                            self.hideHudAsync()
                },
                                         onError: { [weak self] error in
                                            self?.hideHudAsync()
                                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            case VacationSearchType.EXCHANGE:
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate ?? "", format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate ?? "", format: Constant.MyClassConstants.dateFormat)
                
                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
                                           onSuccess: { (response) in
                                            
                                            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            self.hideHudAsync()
                                            self.searchResultColelctionView.reloadData()
                },
                                           
                                           onError: { [weak self] error in
                                            self?.hideHudAsync()
                                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            case VacationSearchType.COMBINED:
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate ?? "", format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate ?? "", format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate ?? "", format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate ?? "", format: Constant.MyClassConstants.dateFormat)
                
                // Execute Rental Search Dates
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                         onSuccess: { (response) in
                                            
                                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            // Check not available checkIn dates for the active interval for Rental
                                            if activeInterval.hasCheckInDates() == false {
                                                Constant.MyClassConstants.rentalHasNotAvailableCheckInDatesAfterSelectInterval = true
                                            }
                                            
                                            // Run Exchange Search Dates
                                            Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchResultColelctionView, activeInterval: activeInterval)
                                            
                },
                                         onError: { (_) in
                                            // Run Exchange Search Dates
                                            Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchResultColelctionView, activeInterval: activeInterval)
                })
                
            default:
                break
            }
        } else {
            hideHudAsync()
            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
            self.searchResultColelctionView.reloadData()
            myActivityIndicator.stopAnimating()
            cell.alpha = 1.0
        }
    }
    
    //*****Function for more button press *****//
    func intervalDateItemClicked(_ calendarItem: CalendarItem) {
        showHudAsync()
        searchResultColelctionView.reloadData()
        if combinedExactSearchItems.isEmpty && combinedSurroundingSearchItems.isEmpty && exactMatchResortsArray.isEmpty && exactMatchResortsArrayExchange.isEmpty && surroundingMatchResortsArray.isEmpty && surroundingMatchResortsArrayExchange.isEmpty {
            intervalPrint("All empty")
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            searchResultTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        let selectedDate = Helper.convertStringToDate(dateString: calendarItem.checkInDate ?? "", format: Constant.MyClassConstants.dateFormat)
        intervalPrint(selectedDate)
        Constant.MyClassConstants.vacationSearchShowDate = selectedDate
        Helper.helperDelegate = self
        guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
        Constant.MyClassConstants.initialVacationSearch.searchCheckInDate = calendarItem.checkInDate
        self.searchResultColelctionView.reloadData()
        switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
        case VacationSearchType.RENTAL:
               Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: selectedDate, senderViewController: self)
            
        case VacationSearchType.EXCHANGE:
            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: selectedDate, senderViewController: self)
            
        case VacationSearchType.COMBINED:
            let request = RentalSearchResortsRequest()
            request.checkInDate = selectedDate
            request.resortCodes = activeInterval.resortCodes
            
            RentalClient.searchResorts(Session.sharedSession.userAccessToken, request: request,
                                       onSuccess: { (response) in
                                        // Update Rental inventory
                                        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.inventory = response.resorts
                                        // Run Exchange Search Dates
                                        Helper.executeExchangeSearchAvailabilityAfterSelectCheckInDate(activeInterval: activeInterval, checkInDate: selectedDate, senderVC: self)
            },
                                       onError: { [weak self] error in
                                        self?.hideHudAsync()
                                        self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
        default:
            break
        }
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Dynamic API hit
    
    func getFilterRelinquishments(selectedInventoryUnit: Inventory, selectedIndex: Int, selectedExchangeInventory: ExchangeInventory, hasSearchAllAvailability: Bool) {
        showHudAsync()
        let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
        exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        exchangeSearchDateRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
        
        let exchangeDestination = ExchangeDestination()
        let resort = Resort()
        resort.resortCode = Constant.MyClassConstants.selectedResort.resortCode
        
        exchangeDestination.resort = resort
        
        let unit = InventoryUnit()
        
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined() && hasSearchAllAvailability {
            
            let currentFromDate = selectedInventoryUnit.checkInDate
            let currentToDate = selectedInventoryUnit.checkOutDate
            unit.kitchenType = selectedInventoryUnit.units[selectedIndex].kitchenType
            unit.unitSize = selectedInventoryUnit.units[selectedIndex].unitSize
            exchangeDestination.checkInDate = currentFromDate
            exchangeDestination.checkOutDate = currentToDate
            unit.publicSleepCapacity = selectedInventoryUnit.units[selectedIndex].publicSleepCapacity
            unit.privateSleepCapacity = selectedInventoryUnit.units[selectedIndex].privateSleepCapacity
            
        } else {
            let currentFromDate = selectedExchangeInventory.checkInDate
            let currentToDate = selectedExchangeInventory.checkOutDate
            unit.kitchenType = selectedExchangeInventory.buckets[selectedIndex].unit?.kitchenType
            unit.unitSize = selectedExchangeInventory.buckets[selectedIndex].unit?.unitSize
            exchangeDestination.checkInDate = currentFromDate
            exchangeDestination.checkOutDate = currentToDate
            unit.publicSleepCapacity = selectedExchangeInventory.buckets[selectedIndex].unit?.publicSleepCapacity ?? 0
            unit.privateSleepCapacity = selectedExchangeInventory.buckets[selectedIndex].unit?.privateSleepCapacity ?? 0
        }
        exchangeDestination.unit = unit
        exchangeSearchDateRequest.destination = exchangeDestination
        Constant.MyClassConstants.exchangeDestination = exchangeDestination
        
        ExchangeClient.filterRelinquishments(Session.sharedSession.userAccessToken, request: exchangeSearchDateRequest, onSuccess: { response in
            self.hideHudAsync()
            Constant.MyClassConstants.filterRelinquishments.removeAll()
            
            for exchageDetail in response {
                if let relinquishment = exchageDetail.relinquishment {
                    Constant.MyClassConstants.filterRelinquishments.append(relinquishment)
                }
            }
            
            Constant.MyClassConstants.selectedUnitIndex = selectedIndex
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.COMBINED {
                self.navigateToWhatToUseViewController(hasSearchAllAvailability: hasSearchAllAvailability)
            } else {
                if Constant.MyClassConstants.filterRelinquishments.count > 1 {
                    self.navigateToWhatToUseViewController(hasSearchAllAvailability: hasSearchAllAvailability)
                } else if !response.isEmpty && response[0].destination?.upgradeCost != nil {
                    self.navigateToWhatToUseViewController(hasSearchAllAvailability: hasSearchAllAvailability)
                } else {
                    self.startProcess()
                }
            }
            
        }, onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
    }
    
    // MARK: - navigation Methods
    func navigateToWhatToUseViewController(hasSearchAllAvailability: Bool) {
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        let mainStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whatToUseViewController) as? WhatToUseViewController {
            viewController.delegate = self
            viewController.showInfoIcon = showInfoIcon
            viewController.hasbothSearchAvailability = hasSearchAllAvailability
            navigationController?.pushViewController(viewController, animated: true)
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
        
        if !Constant.MyClassConstants.filterRelinquishments.isEmpty {
            
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
        
        ExchangeProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            if let view = response.view {
                Constant.MyClassConstants.exchangeViewResponse = view
            }
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            if let exchangeFees = response.view?.fees {
                Constant.MyClassConstants.exchangeFees = [exchangeFees]
            }
            
            if let resortAmenities = response.view?.destination?.resort?.amenities {
                for amenity in resortAmenities {
                    guard let amenityName = amenity.amenityName else { return }
                    if amenity.nearby == false {
                        Constant.MyClassConstants.onsiteArray.add(amenityName)
                        Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenityName)
                        Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                    } else {
                        Constant.MyClassConstants.nearbyArray.add(amenityName)
                        Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenityName)
                        Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                    }
                }
            }
            UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
                Session.sharedSession.selectedMembership = membership
                
                // Got an access token!  Save it for later use.
                self.hideHudAsync()
                if let contacts = membership.contacts {
                    Constant.MyClassConstants.membershipContactArray = contacts
                }
                
                let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                if response.view?.forceRenewals != nil {
                    // Navigate to Renewals Screen
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                    viewController.delegate = self
                    self.present(viewController, animated: true)
                    
                } else {
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
                    viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[0]
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                }
            }, onError: { [weak self] error in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                
            })
            
        }, onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
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
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as? SortingViewController else { return }
        viewController.selectedSortingIndex = Constant.MyClassConstants.sortingIndex
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    //funciton called when search result page sort by name button pressed
    @IBAction func filterByNameButtonPressed(_ sender: UIButton) {
        
        if !Constant.MyClassConstants.noFilterOptions {
            sender.isEnabled = true
            if Constant.MyClassConstants.filterOptionsArray.count > 1 || alertFilterOptionsArray.count > 1 {
                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as? SortingViewController else { return }
                viewController.isFilterClicked = true
                viewController.alertFilterOptionsArray = alertFilterOptionsArray
                viewController.resortNameArray = Constant.MyClassConstants.resortsArray
                viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
                self.present(viewController, animated: true, completion: nil)
            } else {
                sender.isEnabled = false
            }
        } else if alertFilterOptionsArray.count > 1 {
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as? SortingViewController else { return }
            viewController.isFilterClicked = true
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            viewController.resortNameArray = Constant.MyClassConstants.resortsArray
            viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
            self.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let firstVisibleIndexPath = searchResultTableView.indexPathsForVisibleRows?.first
        var index = 0
        for (Index, calendarItem) in Constant.MyClassConstants.calendarDatesArray.enumerated() {
            if calendarItem.checkInDate == Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
                index = Index
            }
        }
        let indexPath = IndexPath(item: index, section: 0)
        if firstVisibleIndexPath?.section == 1 {
            dateCellSelectionColor = Constant.CommonColor.greenColor
        } else {
            checkExactSurroundingSections()
            if onlySurroundingsFound == true {
                dateCellSelectionColor = Constant.CommonColor.greenColor
            } else {
                dateCellSelectionColor = Constant.CommonColor.blueColor
            }
        }
        if indexPath.row <= Constant.MyClassConstants.calendarDatesArray.count {
            if searchResultColelctionView != nil {
                
                searchResultColelctionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    // Common method to get exchange collection view cell
    func getGetawayCollectionCell(indexPath: IndexPath, collectionView: UICollectionView) -> RentalInventoryCVCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortInventoryCell, for: indexPath) as? RentalInventoryCVCell else { return RentalInventoryCVCell() }
        return cell
    }
    
    // Common method to get rental collection view cell
    func getExchangeCollectionCell(indexPath: IndexPath, collectionView: UICollectionView) -> ExchangeInventoryCVCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.exchangeInventoryCell, for: indexPath) as? ExchangeInventoryCVCell else { return ExchangeInventoryCVCell() }
        return cell
        
    }
    
    // Common method to get Resort Info collection view cell
    func getResortInfoCollectionCell(indexPath: IndexPath, collectionView: UICollectionView, resort: Resort) -> AvailabilityCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as? AvailabilityCollectionViewCell else { return AvailabilityCollectionViewCell() }
        cell.setResortDetails(inventoryItem: resort)
        intervalPrint(Constant.MyClassConstants.favoritesResortCodeArray)
        
        if Helper.isResrotFavorite(resortCode: resort.resortCode ?? "") {
            cell.favourite.isSelected = true
        } else {
            cell.favourite.isSelected = false
        }
        
        if collectionView.superview?.superview?.tag == 0 {
            
            if !exactMatchResortsArray.isEmpty {
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
        UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
            Session.sharedSession.selectedMembership = membership
            
            // Got an access token!  Save it for later use.
            self.hideHudAsync()
            if let contacts = membership.contacts {
                Constant.MyClassConstants.membershipContactArray = contacts
            }
            let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            
            if response.view?.forceRenewals != nil {
                // Navigate to Renewals Screen
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            } else {
                // Navigate to Who Will Be Checking in Screen
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            
        }, onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
    }
    
    func favoriteButtonclicked(_ sender: UIButton) {
        
        let section = sender.accessibilityValue
        
        if Session.sharedSession.userAccessToken != nil {
            
            var resortCode = ""
            if  section == "0" {
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.RENTAL {
                    if exactMatchResortsArray.count == 0 {
                        resortCode = surroundingMatchResortsArray[sender.tag].resortCode ?? ""
                    } else {
                        resortCode = exactMatchResortsArray[sender.tag].resortCode ?? ""
                    }
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.EXCHANGE {
                    if exactMatchResortsArrayExchange.count == 0 {
                        resortCode = surroundingMatchResortsArrayExchange[sender.tag].resort?.resortCode ?? ""
                    } else {
                        resortCode = exactMatchResortsArrayExchange[sender.tag].resort?.resortCode ?? ""
                    }
                } else {
                    resortCode = combinedExactSearchItems[sender.tag].rentalAvailability?.resortCode ?? ""
                }
                
            } else {
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.RENTAL {
                    resortCode = surroundingMatchResortsArray[sender.tag].resortCode.unwrappedString
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.EXCHANGE {
                    resortCode = surroundingMatchResortsArrayExchange[sender.tag].resort?.resortCode ?? ""
                } else {
                    resortCode = combinedSurroundingSearchItems[sender.tag].rentalAvailability?.resortCode ?? ""
                }
                
            }
            
            if sender.isSelected == false {
                showHudAsync()
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { _ in
                    
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                    let indexpath = IndexPath(row: sender.tag, section: Int(section ?? "0") ?? 0)
                    self.searchResultTableView.reloadRows(at: [indexpath], with: .automatic)
                    
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
            } else {
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { _ in
                    
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                    let indexpath = IndexPath(row: sender.tag, section: Int(section ?? "0") ?? 0)
                    self.searchResultTableView.reloadRows(at: [indexpath], with: .automatic)
                    
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            }
        } else {
            
            Constant.MyClassConstants.btnTag = sender.tag
            performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
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
            dateCellSelectionColor = Constant.CommonColor.blueColor
            if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval ?? false {
                showHudAsync()
                intervalBucketClicked(calendarItem: Constant.MyClassConstants.calendarDatesArray[indexPath.item], cell: cell)
            } else {
                intervalDateItemClicked(Constant.MyClassConstants.calendarDatesArray[indexPath.item])
            }
        } else {
            
            // Check for renewals no thanks
            Constant.MyClassConstants.noThanksForNonCore = false
            
            if indexPath.section == 0 {
                Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
                Constant.MyClassConstants.isFromSearchResult = true
                
                showHudAsync()
                var resortCode = ""
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.RENTAL {
                    
                    if collectionView.superview?.superview?.tag == 0 && !exactMatchResortsArray.isEmpty {
                        resortCode = exactMatchResortsArray[collectionView.tag].resortCode ?? ""
                    } else {
                        resortCode = surroundingMatchResortsArray[collectionView.tag].resortCode ?? ""
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    if collectionView.superview?.superview?.tag == 0 && !exactMatchResortsArrayExchange.isEmpty {
                        resortCode = exactMatchResortsArrayExchange[collectionView.tag].resort?.resortCode ?? ""
                    } else {
                        resortCode = surroundingMatchResortsArrayExchange[collectionView.tag].resort?.resortCode ?? ""
                    }
                } else {
                    if collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty {
                        if let combinedExact = combinedExactSearchItems[collectionView.tag].rentalAvailability, let code = combinedExact.resortCode {
                            resortCode = code
                        } else {
                            resortCode = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort?.resortCode ?? ""
                        }
                        
                    } else {
                        if let combinedSurroundings = combinedSurroundingSearchItems[indexPath.section].rentalAvailability, let code = combinedSurroundings.resortCode {
                            resortCode = code
                        } else {
                            resortCode = combinedSurroundingSearchItems[indexPath.section].exchangeAvailability?.resort?.resortCode ?? ""
                        }
                    }
                }
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: {[weak self](response) in
                    
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAll()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray {
                        if imgStr.size?.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame {
                            if let url = imgStr.url {
                                Constant.MyClassConstants.imagesArray.append(url)
                            }
                        }
                    }
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = collectionView.tag + 1
                    
                    self?.hideHudAsync()
                    self?.performSegue(withIdentifier: Constant.segueIdentifiers.vacationSearchDetailSegue, sender: nil)
                }) { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    
                }
            } else {
                
                // it is used in renewal screen to change the title of header
                Constant.MyClassConstants.isChangeNoThanksButtonTitle = false
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    if selectedSection == 0 {
                        if let resort = exactMatchResortsArrayExchange[collectionView.tag].resort {
                            Constant.MyClassConstants.selectedResort = resort
                        }
                        if let inventory = exactMatchResortsArrayExchange[collectionView.tag].inventory {
                            self.getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory, hasSearchAllAvailability: false)
                            Constant.MyClassConstants.selectedExchangeCigPoints = inventory.buckets[indexPath.row].pointsCost
                        }
                    } else {
                        if let resort = surroundingMatchResortsArrayExchange[collectionView.tag].resort {
                            Constant.MyClassConstants.selectedResort = resort
                        }
                        if let inventory = surroundingMatchResortsArrayExchange[collectionView.tag].inventory {
                            self.getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory, hasSearchAllAvailability: false)
                            Constant.MyClassConstants.selectedExchangeCigPoints = inventory.buckets[indexPath.row].pointsCost
                        }
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                    
                    showHudAsync()
                    
                    if collectionView.superview?.superview?.tag == 0 && !exactMatchResortsArray.isEmpty {
                        Constant.MyClassConstants.selectedResort = self.exactMatchResortsArray[collectionView.tag]
                    } else {
                        Constant.MyClassConstants.selectedResort = self.surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    let inventory = Constant.MyClassConstants.selectedResort.inventory
                    guard let units = inventory?.units else { return }
                    
                    if let prices = inventory?.units[indexPath.item].prices {
                        Constant.MyClassConstants.inventoryPrice = prices
                    }
                    
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
                    
                    if let checkInDate = inventory?.checkInDate, let checkOutDate = inventory?.checkOutDate, let unitSize =  inventory?.units[indexPath.item].unitSize, let kitchenType = inventory?.units[indexPath.item].kitchenType {
                        
                        let processRequest1 = RentalProcessStartRequest(resortCode: Constant.MyClassConstants.selectedResort.resortCode,
                                                                        checkInDate: checkInDate,
                                                                        checkOutDate: checkOutDate,
                                                                        unitSize: UnitSize(rawValue: unitSize),
                                                                        kitchenType: KitchenType(rawValue:kitchenType))
                        
                        RentalProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest1, onSuccess: { response in
                            
                            let processResort = RentalProcess()
                            processResort.processId = response.processId
                            Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
                            Constant.MyClassConstants.processStartResponse = response
                            self.hideHudAsync()
                            
                            if let rentalView = response.view, let rentalFees = rentalView.fees {
                                Constant.MyClassConstants.viewResponse = rentalView
                                Constant.MyClassConstants.rentalFees = [rentalFees]
                            }
                            
                            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                            Constant.MyClassConstants.onsiteArray.removeAllObjects()
                            Constant.MyClassConstants.nearbyArray.removeAllObjects()
                            
                            guard let resortAmenities = response.view?.resort?.amenities else { return }
                            
                            for amenity in resortAmenities {
                                guard let amenityName = amenity.amenityName else { return }
                                if !amenity.nearby {
                                    
                                    Constant.MyClassConstants.onsiteArray.add(amenityName)
                                    
                                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenityName)
                                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                                    
                                } else {
                                    Constant.MyClassConstants.nearbyArray.add(amenityName)
                                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenityName)
                                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                                }
                            }
                            
                            // MARK: - Check forced renewals before calling membership
                            self.checkUserMembership(response: response)
                        }, onError: { [weak self] error in
                            self?.hideHudAsync()
                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                        })
                    }
                    
                } else { // search both
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    Constant.MyClassConstants.selectedUnitIndex = indexPath.item

                    if collectionView.superview?.superview?.tag == 0 {
                        
                        if !combinedExactSearchItems.isEmpty {
                            if let exchangeAvailability = combinedExactSearchItems[collectionView.tag].exchangeAvailability {
                                
                                if let bucket = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets[indexPath.row] {
                                    Constant.MyClassConstants.selectedExchangeCigPoints = bucket.pointsCost
                                    if bucket.pointsCost != bucket.memberPointsRequired {
                                        showInfoIcon = true
                                    }
                                }
                                
                                if let rentalAvailability = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                    Constant.MyClassConstants.selectedResort = rentalAvailability
                                } else {
                                    if let resort = exchangeAvailability.resort {
                                        Constant.MyClassConstants.selectedResort = resort
                                    }
                                }
                            } else if let rentalAvailablility = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                Constant.MyClassConstants.selectedResort = rentalAvailablility
                            }
                        } else {
                            if let exchangeAvailability = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability {
                                if let bucket = exchangeAvailability.inventory?.buckets[indexPath.row] {
                                    Constant.MyClassConstants.selectedExchangeCigPoints = bucket.pointsCost
                                    if bucket.pointsCost != bucket.memberPointsRequired {
                                        showInfoIcon = true
                                    }
                                }
                                if let resort = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                                    Constant.MyClassConstants.selectedResort = resort
                                }
                            } else if let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                                Constant.MyClassConstants.selectedResort = rentalAvailability
                            }
                        }
                        
                        if !combinedExactSearchItems.isEmpty {
                            if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability() {
                                if let rentalInventory = combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory {
                                    getFilterRelinquishments(selectedInventoryUnit: rentalInventory,
                                                             selectedIndex: indexPath.item,
                                                             selectedExchangeInventory: ExchangeInventory(),
                                                             hasSearchAllAvailability: true)
                                }
                            } else if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() {
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                self.navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                            } else {
                                if let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory {
                                    getFilterRelinquishments(selectedInventoryUnit: Inventory(),
                                                             selectedIndex: indexPath.item,
                                                             selectedExchangeInventory:exchangeInventory,
                                                             hasSearchAllAvailability: false)
                                }
                            }
                        } else {
                            if let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                                Constant.MyClassConstants.selectedResort = rentalAvailability
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                            } else if let exchangeAvailability = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability {
                                if let resort = exchangeAvailability.resort, let exchangeInventory = exchangeAvailability.inventory {
                                    Constant.MyClassConstants.selectedResort = resort
                                    getFilterRelinquishments(selectedInventoryUnit: Inventory(),
                                                             selectedIndex: indexPath.item,
                                                             selectedExchangeInventory: exchangeInventory,
                                                             hasSearchAllAvailability: true)
                                }
                            }
                        }
                    } else {
                        
                        if let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                            Constant.MyClassConstants.selectedResort = rentalAvailability
                        } else if let exchangeResort = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort {
                            Constant.MyClassConstants.selectedResort = exchangeResort
                        }
                        
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability != nil {
                            
                            if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability() {
                                if let rentalInventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory {
                                    getFilterRelinquishments(selectedInventoryUnit: rentalInventory, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory(), hasSearchAllAvailability: true)
                                }
                                
                            } else if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                            } else {
                                if let inventory = combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory {
                                    getFilterRelinquishments(selectedInventoryUnit: inventory, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory(), hasSearchAllAvailability: false)
                                }
                            }
                            
                        } else {
                            navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                        }
                    }
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if loadFirst {
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
        
        if collectionView.tag == -1 {
            if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval ?? false {
                return CGSize(width: 110.0, height: 60.0)
            } else {
                return CGSize(width: 60.0, height: 60.0)
            }
        } else {
            if indexPath.section == 0 {
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
        if collectionView.tag == -1 {
            return 1
        } else {
            return 2
        }
    }
    
    // Mark : - Collection Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == -1 {
            return Constant.MyClassConstants.calendarDatesArray.count
        } else {
            if section == 0 {
                return 1
            } else {
                if collectionView.superview?.superview?.tag == 0 {
                    switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                        
                    case VacationSearchType.RENTAL:
                        if !exactMatchResortsArray.isEmpty {
                            return exactMatchResortsArray[collectionView.tag].inventory?.units.count ?? 0
                        } else {
                            return surroundingMatchResortsArray[collectionView.tag].inventory?.units.count ?? 0
                        }
                        
                    case VacationSearchType.EXCHANGE:
                        return exactMatchResortsArrayExchange[collectionView.tag].inventory?.buckets.count ?? 0
                        
                    case VacationSearchType.COMBINED:
                        if !combinedExactSearchItems.isEmpty {
                            if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil {
                                return combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count ?? 0
                                
                            } else {
                                return combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count ?? 0
                            }
                        } else {
                            if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil {
                                return combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count ?? 0
                                
                            } else {
                                return combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count ?? 0
                            }
                        }
                    default:
                        return 0
                    }
                    
                } else {
                    
                    switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                        
                    case VacationSearchType.RENTAL:
                         return surroundingMatchResortsArray[collectionView.tag].inventory?.units.count ?? 0
                        
                    case VacationSearchType.EXCHANGE:
                        return surroundingMatchResortsArrayExchange[collectionView.tag].inventory?.buckets.count ?? 0
                        
                    case VacationSearchType.COMBINED:
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil {
                            return combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count ?? 0
                        } else {
                            return combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count ?? 0
                        }
                        
                    default:
                        return 0
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == -1 {
            
            if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval {
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.moreCell, for: indexPath) as? MoreCell else { return UICollectionViewCell() }
                
                if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isIntervalAvailable {
                    cell.isUserInteractionEnabled = true
                    cell.backgroundColor = UIColor.white
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = UIColor.lightGray
                }
                cell.setDateForBucket(index: indexPath.item, selectedIndex: indexPath.item, color: dateCellSelectionColor)
                
                return cell
            } else {
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell, for: indexPath) as? SearchResultCollectionCell else { return UICollectionViewCell() }
                
                let vacationSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                let calendarItemCheckInDate = Constant.MyClassConstants.calendarDatesArray[indexPath.row].checkInDate
                if vacationSearchCheckInDate == calendarItemCheckInDate {
                    
                    if dateCellSelectionColor == Constant.CommonColor.greenColor {
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
            
            switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
            case VacationSearchType.RENTAL:
                var inventoryItem = Resort()
                if collectionView.superview?.superview?.tag == 0 {
                    if !exactMatchResortsArray.isEmpty {
                        inventoryItem = exactMatchResortsArray[collectionView.tag]
                    } else {
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                } else {
                    inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                }
                
                if indexPath.section == 0 {
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                    
                } else {
                    let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.setDataForRentalInventory(invetoryItem: inventoryItem, indexPath: indexPath, code: currencyCode)
                    return cell
                }
                
            case VacationSearchType.EXCHANGE:
                if indexPath.section == 0 {
                    var inventoryItem = Resort()
                    if collectionView.superview?.superview?.tag == 0 {
                        inventoryItem = exactMatchResortsArrayExchange[collectionView.tag].resort ?? Resort()
                    } else {
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                    
                } else {
                    var inventoryItem = ExchangeInventory()
                    if collectionView.superview?.superview?.tag == 0 {
                        inventoryItem = exactMatchResortsArrayExchange[collectionView.tag].inventory ?? ExchangeInventory()
                    } else {
                        inventoryItem = surroundingMatchResortsArrayExchange[collectionView.tag].inventory ?? ExchangeInventory()
                    }
                    
                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.exchangeCellDelegate = self
                    cell.setUpExchangeCell(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            case VacationSearchType.COMBINED:
                if indexPath.section == 0 {
                    var inventoryItem = Resort()
                    if collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty {
                        if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() {
                            if let rentalInventory = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                inventoryItem = rentalInventory
                            }
                        } else {
                            let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability
                            inventoryItem = exchangeInventory?.resort ?? Resort()
                        }
                        
                    } else {
                        if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() {
                            let rentalInventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                            inventoryItem = rentalInventory ?? Resort()
                        } else {
                            if let resort = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort {
                                inventoryItem = resort
                            }
                        }
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                } else {
                    
                    if (collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty && combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability()) || (collectionView.superview?.superview?.tag == 1 && combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability()) {
                        
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as? SearchBothInventoryCVCell else { return UICollectionViewCell() }
                        
                        if collectionView.superview?.superview?.tag == 0 {
                            if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil {
                                if let inventory = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                    cell.setDataForBothInventoryType(invetoryItem: inventory, indexPath: indexPath)
                                }
                            } else {
                                if let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort {
                                    cell.setDataForBothInventoryType(invetoryItem: exchangeInventory, indexPath: indexPath)
                                }
                            }
                        } else {
                            
                            if let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                                cell.setDataForBothInventoryType(invetoryItem: rentalAvailability, indexPath: indexPath)
                            } else {
                                if let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort {
                                    cell.setDataForBothInventoryType(invetoryItem: exchangeInventory, indexPath: indexPath)
                                }
                            }
                        }
                        return cell
                        
                    } else if collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty {
                        if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() {
                            let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)

                            if let rentalAvailability = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                cell.setDataForRentalInventory( invetoryItem: rentalAvailability, indexPath: indexPath, code: currencyCode)
                            }

                            return cell
                        } else {
                            let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.exchangeCellDelegate = self
                            guard let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory else { return cell }
                            cell.setUpExchangeCell(invetoryItem:exchangeInventory, indexPath:indexPath)
                            return cell
                        }
                    } else {
                        if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() {
                            let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)

                            guard let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability else { return cell }
                                cell.setDataForRentalInventory( invetoryItem: rentalAvailability, indexPath: indexPath, code: currencyCode)

                            return cell
                        } else {
                            let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.exchangeCellDelegate = self
                            guard let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory else { return cell }
                            cell.setUpExchangeCell(invetoryItem:exchangeInventory, indexPath:indexPath)
                            return cell
                        }
                    }
                }
            default:
                return UICollectionViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
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
        if !sectionsInSearchResult.isEmpty {
            for sections in sectionsInSearchResult {
                if sections.exactMatch == true && section == 0 {
                    headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    headerView.backgroundColor = Constant.CommonColor.headerGreenColor
                    break
                } else if sections.exactMatch == false && section == 1 {
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
        if !Constant.MyClassConstants.noFilterOptions || !alertFilterOptionsArray.isEmpty {
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
    // Mark : - TableHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                return 110
            } else {
                if Constant.MyClassConstants.isShowAvailability == true {
                    let index = indexPath.row - 1
                    
                    switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                    case VacationSearchType.EXCHANGE:
                        if !exactMatchResortsArrayExchange.isEmpty {
                            if let totalUnits = exactMatchResortsArrayExchange[index].inventory?.buckets.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                            
                        } else {
                            if let totalUnits = self.surroundingMatchResortsArrayExchange[index].inventory?.buckets.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
                            } else {
                                return 0
                            }
                        }
                        
                    case VacationSearchType.RENTAL:
                        if !exactMatchResortsArray.isEmpty {
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
                        
                    case VacationSearchType.COMBINED:
                        if !combinedExactSearchItems.isEmpty {
                            if combinedExactSearchItems[index].rentalAvailability != nil {
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
                            if combinedSurroundingSearchItems[index].rentalAvailability != nil {
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
                        
                    default:
                        return 0
                    }
                } else {
                    
                    switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                    case VacationSearchType.EXCHANGE:
                        if let totalUnits = self.exactMatchResortsArrayExchange[indexPath.row].inventory?.buckets.count {
                            return CGFloat(totalUnits * 80 + 270 + 10)
                        } else {
                            return 0
                        }
                        
                    case VacationSearchType.RENTAL:
                        if !exactMatchResortsArray.isEmpty {
                            if let totalUnits = self.exactMatchResortsArray[indexPath.row].inventory?.units.count {
                                return CGFloat(totalUnits * 80 + 270 + 10)
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
                        
                    case VacationSearchType.COMBINED:
                        if !combinedExactSearchItems.isEmpty {
                            if combinedExactSearchItems[indexPath.row].rentalAvailability != nil {
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
                            
                            if combinedSurroundingSearchItems[indexPath.row].rentalAvailability != nil {
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
                    default:
                        return 0
                    }
                }
            }
        } else {
            switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
            case VacationSearchType.RENTAL:
                if let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count {
                    return CGFloat(totalUnits * 80 + 270 + 10)
                } else {
                    return 0
                }
                
            case VacationSearchType.EXCHANGE:
                if let totalUnits = self.surroundingMatchResortsArrayExchange[indexPath.row].inventory?.buckets.count {
                    return CGFloat(totalUnits * 80 + 270 + 10)
                } else {
                    return 0
                }
                
            case VacationSearchType.COMBINED:
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
                
            default:
                return 0
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
    // MARK:- Table Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
        case VacationSearchType.RENTAL:
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
            
        case VacationSearchType.EXCHANGE:
            if section == 0 && exactMatchResortsArrayExchange.count == 0 || section == 1 {
                if exactMatchResortsArrayExchange.isEmpty && Constant.MyClassConstants.isShowAvailability == true {
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
            
        case VacationSearchType.COMBINED:
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
            
        default:
            return 0
        }
    }
}

extension SearchResultViewController: SearchResultContentTableCellDelegate {
    func favoriteButtonClicked(_ sender: UIButton) {
        guard let resortCode = Constant.MyClassConstants.resortsArray[sender.tag].resortCode else { return }
        
        if Session.sharedSession.userAccessToken != nil {
            
            if sender.isSelected == false {
                
                showHudAsync()
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: {(_) in
                    
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                    self.searchResultTableView.reloadData()
                    
                }, onError: {[unowned self](_) in
                    self.hideHudAsync()
                    self.presentAlert(with: "Add Favorites", message: "Oops server error please try again!".localized())
                })
            } else {
                
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { response in
                    intervalPrint(response)
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                    self.update()
                }, onError: {[unowned self](_) in
                    self.hideHudAsync()
                    self.presentAlert(with: "Remove Favorites".localized(), message: "Oops server error please try again!".localized())
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
        
        // Check if not has availability in the desired check-In date.
        let userSelectedCheckInDate = Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat)
        
        if Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != userSelectedCheckInDate {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        hideHudAsync()
        createSections()
        searchResultTableView.reloadData()
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
        viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[0]
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
        viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[0]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchResultViewController: ExchangeInventoryCVCellDelegate {
    func infoIconPressed() {
        self.performSegue(withIdentifier: "pointsInfoSegue", sender: self)
    }
}
