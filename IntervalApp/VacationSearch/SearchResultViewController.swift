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
    var dateCellSelectionColor = Constant.CommonColor.greenColor
    var myActivityIndicator = UIActivityIndicatorView()
    var value: String = ""
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    var currencyCode = ""
    var currencySymbol = ""
    var availabilitySections = [AvailabilitySection]()
    var availabilityExactMatchSection: AvailabilitySection?
    var availabilitySurroundingMatchSection: AvailabilitySection?
    var resortImageCellHeight = 310
    
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
        // Clean availability sections
        availabilityExactMatchSection = nil
        availabilitySurroundingMatchSection = nil
        
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
        if sections.isEmpty {
            title = "No Availability".localized()
            searchResultTableView.tableHeaderView = Helper.noResortView(senderView: self.view)
        } else {
            title = "Search Results".localized()
            searchResultTableView.tableHeaderView = UIView()

            //FIXME(Frank): Analyze if keep the availabilitySections or availabilityExactMatchSection & availabilitySurroundingMatchSection
            availabilitySections = sections
            for section in sections {
                if section.exactMatch {
                    availabilityExactMatchSection = section
                } else {
                    availabilitySurroundingMatchSection = section
                }
            }
            
            checkDateCellSelectionColor()
        }
        
        searchResultColelctionView.reloadData()
        
        var index = 0
        for (calendarItemIndex, calendarItem) in Constant.MyClassConstants.calendarDatesArray.enumerated() where calendarItem.checkInDate == Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
            index = calendarItemIndex
            break
        }
        let indexPath = IndexPath(item: index, section: 0)
        searchResultColelctionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
            alertView = Helper.noResortView(senderView: self.view)
            alertView.isHidden = false
            headerVw.isHidden = true
            view.bringSubview(toFront: self.alertView)
            title = "No Availability".localized()
        } else {
            title = "Search Results".localized()
            headerVw.isHidden = false
            alertView.isHidden = true
        }
        
        if Session.sharedSession.userAccessToken != nil {
            showHudAsync()
            UserClient.getFavoriteResorts(Session.sharedSession.userAccessToken, onSuccess: { (response) in
                Constant.MyClassConstants.favoritesResortArray.removeAll()
                for item in [response][0] {
                    if let resort = item.resort {
                        if let code = resort.resortCode {
                            Constant.MyClassConstants.favoritesResortCodeArray.append(code)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToActiveDate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func scrollToActiveDate() {
        let numberOfRecords = Constant.MyClassConstants.calendarDatesArray.count
        let vacationSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate

        for index in 0..<numberOfRecords {
            let calendarItemCheckInDate = Constant.MyClassConstants.calendarDatesArray[index].checkInDate
            if vacationSearchCheckInDate == calendarItemCheckInDate {
                searchResultColelctionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                break
            }
        }
    }

    func getSavedDestinationsResorts(storedData: Results <RealmLocalStorage>, searchCriteria: VacationSearchCriteria) {
        //if let storedData = storedData.count {}
        if let firstDestination = storedData.first?.destinations[0] {
            
            let destination = AreaOfInfluenceDestination()
            destination.destinationName = firstDestination.destinationName
            destination.destinationId = firstDestination.destinationId
            destination.aoiId = firstDestination.aoid
            searchCriteria.destination = destination
            
            // FIXME(Frank): Why? - Use the AvailabilitySection.header
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if let resorts = storedData.first?.resorts {
            
            if !resorts[0].resortArray.isEmpty {
                // FIXME(Frank): Why? - Use the AvailabilitySection.header
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(String(describing: resorts[0].resortArray[0].resortName)) + more"
                
            } else {
                let resort = Resort()
                resort.resortName = resorts[0].resortName
                resort.resortCode = resorts[0].resortCode
                searchCriteria.resorts = [resort]
                
                // FIXME(Frank): Why? - Use the AvailabilitySection.header
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = resorts[0].resortName
            }
        }
    }
    
    func intervalBucketClicked(calendarItem: CalendarItem, cell: UICollectionViewCell) {
        
        myActivityIndicator.hidesWhenStopped = true
        intervalPrint(Constant.MyClassConstants.initialVacationSearch)
        
        // Resolve the next active interval based on the Calendar interval selected
        guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate!, intervalEndDate: calendarItem.intervalEndDate!) else { return }
        
        // Fetch CheckIn dates only in the active interval doesn't have CheckIn dates
        if activeInterval.hasCheckInDates() == false {
            
            switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                
            case VacationSearchType.RENTAL:
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = calendarItem.intervalStartDate?.dateFromShortFormat()
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = calendarItem.intervalEndDate?.dateFromShortFormat()
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                         onSuccess: { [weak self] (response) in
                                            
                                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch) {
                                                DispatchQueue.main.async {
                                                    self?.searchResultColelctionView.reloadSections(IndexSet(integer: 0))
                                                    self?.hideHudAsync()
                                                }
                                            }
                },
                                         onError: { [weak self] error in
                                            self?.hideHudAsync()
                                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            case VacationSearchType.EXCHANGE:
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = calendarItem.intervalStartDate?.dateFromShortFormat()
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = calendarItem.intervalEndDate?.dateFromShortFormat()
                
                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
                                           onSuccess: { (response) in
                                            
                                            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            self.hideHudAsync()
                                            self.searchResultColelctionView.reloadSections(IndexSet(integer: 0))
                },
                                           
                                           onError: { [weak self] error in
                                            self?.hideHudAsync()
                                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            case VacationSearchType.COMBINED:
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = calendarItem.intervalStartDate?.dateFromShortFormat()
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = calendarItem.intervalEndDate?.dateFromShortFormat()
     
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = calendarItem.intervalStartDate?.dateFromShortFormat()
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = calendarItem.intervalEndDate?.dateFromShortFormat()
                
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
            self.searchResultColelctionView.reloadSections(IndexSet(integer: 0))
            myActivityIndicator.stopAnimating()
            cell.alpha = 1.0
        }
    }
    
    //*****Function for more button press *****//
    func intervalDateItemClicked(_ calendarItem: CalendarItem) {
        showHudAsync()
        
        searchResultTableView.reloadData()
        
        if let selectedDate = calendarItem.checkInDate?.dateFromShortFormat() {
            intervalPrint(selectedDate)
            Constant.MyClassConstants.vacationSearchShowDate = selectedDate
            
            Helper.helperDelegate = self as! HelperDelegate
            
            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
            Constant.MyClassConstants.initialVacationSearch.searchCheckInDate = calendarItem.checkInDate
            
            self.searchResultColelctionView.reloadSections(IndexSet(integer: 0))
            
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

    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
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
    
    // MARK: - SDK calls
    func startRentalProcess(_ selectedAvailabilityResort: AvailabilitySectionItemResort, _ selectedAvailabilityBucket: AvailabilitySectionItemInventoryBucket) {
        // showHudAsync()
        
        // FIXME(Frank) - Why we need this new global definition? - we already have the resort that was selected
        Constant.MyClassConstants.hasAdditionalCharges = selectedAvailabilityResort.allInclusive
        
        // Create the RentalProcessStartRequest
        let resort = Resort()
        resort.resortCode = selectedAvailabilityResort.code
        
        let unit = InventoryUnit()
        unit.checkInDate = selectedAvailabilityBucket.checkInDate
        unit.checkOutDate = selectedAvailabilityBucket.checkOutDate
        unit.kitchenType = selectedAvailabilityBucket.unit.kitchenType.rawValue
        unit.unitSize = selectedAvailabilityBucket.unit.unitSize.rawValue
        
        let rentalProcessStartRequest = RentalProcessStartRequest()
        rentalProcessStartRequest.resort = resort
        rentalProcessStartRequest.unit = unit
        
        RentalProcessClient.start(Session.sharedSession.userAccessToken, process: RentalProcess(), request: rentalProcessStartRequest,
          onSuccess: { [weak self] response in
            Constant.MyClassConstants.processStartResponse = response
            
            let rentalProcess = RentalProcess()
            rentalProcess.processId = response.processId
            rentalProcess.currentStep = response.step
            rentalProcess.holdUnitStartTimeInMillis = Constant.holdingTime
            
            Constant.MyClassConstants.getawayBookingLastStartedProcess = rentalProcess
            
            if let view = response.view {
                Constant.MyClassConstants.viewResponse = view
                
                if let rentalFees = view.fees {
                    //FIXME(Frank) - If you already has a global for the "view" that contains the rentalFees then why have a new one global for the fees?
                    //FIXME(Frank) - Why rentalFees is an array? - The same is happen with exchangeFees - this is not GOOD
                    Constant.MyClassConstants.rentalFees = rentalFees
                    
                    if let guestCertificate = rentalFees.guestCertificate {
                        //FIXME(Frank) - If you already has a global for the "view" then why have a new one global for the guestCertificate?
                        Constant.MyClassConstants.guestCertificate = guestCertificate
                    }
                }
            }
            
            //FIXME(Frank) - more of the same BAD use of globals for everything - this is madness
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
            
            // self.hideHudAsync()
            
            // MARK: - Check forced renewals and redirect user to what to user or who will be checking In
            self?.checkForceRenewals(response: response)
          },
          onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
          })
    }
    
    func filterRelinquishments(_ selectedAvailabilityResort: AvailabilitySectionItemResort, _ selectedAvailabilityBucket: AvailabilitySectionItemInventoryBucket) {
        showHudAsync()
        
        // Create the ExchangeFilterRelinquishmentsRequest
        let resort = Resort()
        resort.resortCode = selectedAvailabilityResort.code
        
        let unit = InventoryUnit()
        unit.kitchenType = selectedAvailabilityBucket.unit.kitchenType.rawValue
        unit.unitSize = selectedAvailabilityBucket.unit.unitSize.rawValue
        unit.publicSleepCapacity = selectedAvailabilityBucket.unit.publicSleepCapacity
        unit.privateSleepCapacity = selectedAvailabilityBucket.unit.privateSleepCapacity
        
        let exchangeDestination = ExchangeDestination()
        exchangeDestination.checkInDate = selectedAvailabilityBucket.checkInDate
        exchangeDestination.checkOutDate = selectedAvailabilityBucket.checkOutDate
        exchangeDestination.resort = resort
        exchangeDestination.unit = unit
        Constant.MyClassConstants.exchangeDestination = exchangeDestination
        
        let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
        exchangeSearchDateRequest.destination = exchangeDestination
        exchangeSearchDateRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
        exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        ExchangeClient.filterRelinquishments(Session.sharedSession.userAccessToken, request: exchangeSearchDateRequest,
         onSuccess: { [weak self] response in
            // FIXME(Frank) - GOOD PRACTICE we need to apply this to all the SDK calls
            //guard let strongSelf = self else { return }
            //strongSelf.hideHudAsync()
            
            self?.hideHudAsync()
            
            // FIXME(Frank) - why we need this ???
            Constant.MyClassConstants.filterRelinquishments.removeAll()
            for exchageDetail in response {
                if let relinquishment = exchageDetail.relinquishment {
                    Constant.MyClassConstants.filterRelinquishments.append(relinquishment)
                }
                
                if let destination = exchageDetail.destination {
                    Constant.MyClassConstants.filterDestinations.append(destination)
                }
            }
            
            // Apply Business Rules - https://jira.iilg.com/browse/MOBI-1834
            // - If the SearchType selected was "All/Combined", then present the "What To Use?" screen.
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.COMBINED {
                self?.navigateToWhatToUseViewController(hasSearchAllAvailability: selectedAvailabilityBucket.vacationSearchType.isCombined())
            } else {
                if response.count > 1 {
                    // - If more than 1 relinquishment can be used, then present the "What To Use?" screen.
                    self?.navigateToWhatToUseViewController(hasSearchAllAvailability: selectedAvailabilityBucket.vacationSearchType.isCombined())
                } else if response.count == 1, let destination = response[0].destination, let _ = destination.upgradeCost {
                    // - If only 1 relinquishment can be used and the destination has upgradeCost, then present the "What To Use?" screen.
                    self?.navigateToWhatToUseViewController(hasSearchAllAvailability: selectedAvailabilityBucket.vacationSearchType.isCombined())
                } else {
                    // - Skip the "What To Use?" screen and go directy to the Start Process.
                    self?.startExchangeProcess()
                }
            }
         },
         onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
         })
    }
    
    func startExchangeProcess() {
        showHudAsync()
        
        let exchangeProcessStartRequest = ExchangeProcessStartRequest()
        // Note: constant has value obtained from vacation search screen
        exchangeProcessStartRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        exchangeProcessStartRequest.destination = Constant.MyClassConstants.exchangeDestination
        
        // Set the pointsCost should apply only for Exchange
        if let selectedBucket = Constant.MyClassConstants.selectedAvailabilityInventoryBucket, let pointsCost = selectedBucket.exchangePointsCost, let destination =  exchangeProcessStartRequest.destination {
            destination.pointsCost = pointsCost
        }
        
        // FIXME(Frank) - What is this? - why use the relinq in index [0]
        // FIXME(Frank) - we need use here the new Relinquishment definition to avoid inspecting if is: openWeek|deposit|...
        if !Constant.MyClassConstants.filterRelinquishments.isEmpty {
            if let openWeek = Constant.MyClassConstants.filterRelinquishments[0].openWeek {
                exchangeProcessStartRequest.relinquishmentId = openWeek.relinquishmentId
            }
            
            if let deposit = Constant.MyClassConstants.filterRelinquishments[0].deposit {
                exchangeProcessStartRequest.relinquishmentId = deposit.relinquishmentId
            }
            
            if let pointsProgram = Constant.MyClassConstants.filterRelinquishments[0].pointsProgram {
                exchangeProcessStartRequest.relinquishmentId = pointsProgram.relinquishmentId
            }
            
            if let clubPoints = Constant.MyClassConstants.filterRelinquishments[0].clubPoints {
                exchangeProcessStartRequest.relinquishmentId = clubPoints.relinquishmentId
            }
        }
        
        ExchangeProcessClient.start(Session.sharedSession.userAccessToken, process: ExchangeProcess(), request: exchangeProcessStartRequest,
            onSuccess: { [weak self] response in
                Constant.MyClassConstants.exchangeProcessStartResponse = response
                
                let exchangeProcess = ExchangeProcess()
                exchangeProcess.processId = response.processId
                exchangeProcess.currentStep = response.step
                exchangeProcess.holdUnitStartTimeInMillis = Constant.holdingTime
                
                Constant.MyClassConstants.exchangeBookingLastStartedProcess = exchangeProcess
                
                if let view = response.view {
                    Constant.MyClassConstants.exchangeViewResponse = view
                    
                    if let exchangeFees = view.fees {
                        //FIXME(Frank) - If you already has a global for the "view" that contains the exchangeFees then why have a new one global for the fees?
                        //FIXME(Frank) - Why exchangeFees is an array? - The same is happen with rentalFees - this is not GOOD
                        Constant.MyClassConstants.exchangeFees = exchangeFees
                        
                        if let guestCertificate = exchangeFees.guestCertificate {
                            //FIXME(Frank) - If you already has a global for the "view" then why have a new one global for the guestCertificate?
                            Constant.MyClassConstants.guestCertificate = guestCertificate
                        }
                    }
                }
                
                //FIXME(Frank) - more of the same BAD use of globals for everything - this is madness
                Constant.MyClassConstants.onsiteArray.removeAllObjects()
                Constant.MyClassConstants.nearbyArray.removeAllObjects()
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
                
                self?.hideHudAsync()
                
                if let membership = Session.sharedSession.selectedMembership, let contacts = membership.contacts {
                    // FIXME(Frank) - If we already have Session.sharedSession.selectedMembership that contains the contacts,
                    // then why we need other different global arrays "membershipContactArray" to store the contacts? - not GOOD
                    Constant.MyClassConstants.membershipContactArray = contacts
                }
                
                let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                if response.view?.forceRenewals != nil {
                    // Navigate to Renewals Screen
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                    viewController.filterRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]
                    viewController.delegate = self
                    self?.present(viewController, animated: true)
                } else {
                    guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
                    viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            },
            onError: { [weak self] error in
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
        
        if firstVisibleIndexPath?.section == 1 {
            dateCellSelectionColor = Constant.CommonColor.blueColor
        } else {
            checkDateCellSelectionColor()
        }
    }
    
    // Common method to get the rental collection view cell
    func getRentalCollectionCell(indexPath: IndexPath, collectionView: UICollectionView) -> RentalInventoryCVCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortInventoryCell, for: indexPath) as? RentalInventoryCVCell else { return RentalInventoryCVCell() }
        return cell
    }
    
    // Common method to get exchange collection view cell
    func getExchangeCollectionCell(indexPath: IndexPath, collectionView: UICollectionView) -> ExchangeInventoryCVCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.exchangeInventoryCell, for: indexPath) as? ExchangeInventoryCVCell else { return ExchangeInventoryCVCell() }
        cell.exchangeCellDelegate = self
        return cell
    }
    
    // Common method to get Resort Info collection view cell
    func getResortInfoCollectionCell(indexPath: IndexPath, collectionView: UICollectionView, resort: AvailabilitySectionItemResort) -> AvailabilityCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as? AvailabilityCollectionViewCell else { return AvailabilityCollectionViewCell() }
        cell.setResortDetails(resort: resort)
        intervalPrint(Constant.MyClassConstants.favoritesResortCodeArray)
        
        if Helper.isResrotFavorite(resortCode: resort.code) {
            cell.favourite.isSelected = true
        } else {
            cell.favourite.isSelected = false
        }
        
        // FIXME(Frank): Next block is not good - change me pleaseeeeee
        if collectionView.superview?.superview?.tag == 0 {
            if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                cell.favourite.tag = collectionView.tag
                cell.favourite.accessibilityValue = collectionView.accessibilityValue
            } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
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
    
    func checkDateCellSelectionColor() {
        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
            onlySurroundingsFound = false
            dateCellSelectionColor = Constant.CommonColor.greenColor
        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
            onlySurroundingsFound = true
            dateCellSelectionColor = Constant.CommonColor.blueColor
        }
    }
    
    func update() {
        self.searchResultTableView.reloadData()
    }
    
    func checkForceRenewals(response: RentalProcessPrepareResponse) {
        
        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        if response.view?.forceRenewals != nil {
            // Navigate to Renewals Screen
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return hideHudAsync() }
            viewController.delegate = self
            hideHudAsync()
            present(viewController, animated: true, completion: nil)
        } else {
            // Navigate to Who Will Be Checking in Screen
            hideHudAsync()
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func favoriteButtonclicked(_ sender: UIButton) {
        
        let section = sender.accessibilityValue
        
        //FIXME(Frank) - what is this?
        if let _ = Session.sharedSession.userAccessToken {
            
            if  section == "0" {
                
                if let resort = resolveResort(index: sender.tag) {
                    
                    if sender.isSelected == false {
                        showHudAsync()
                        UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resort.code, onSuccess: { _ in
                            Constant.MyClassConstants.favoritesResortCodeArray.append(resort.code)
                            
                            self.hideHudAsync()
                            sender.isSelected = true
                            let indexpath = IndexPath(row: sender.tag, section: Int(section ?? "0") ?? 0)
                            self.searchResultTableView.reloadRows(at: [indexpath], with: .automatic)
                        }, onError: { [weak self] error in
                            self?.hideHudAsync()
                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                        })
                    } else {
                        showHudAsync()
                        UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resort.code, onSuccess: { _ in
                            Constant.MyClassConstants.favoritesResortCodeArray = Constant.MyClassConstants.favoritesResortCodeArray.filter{ $0 != resort.code }
                            
                            self.hideHudAsync()
                            sender.isSelected = false
                            let indexpath = IndexPath(row: sender.tag, section: Int(section ?? "0") ?? 0)
                            self.searchResultTableView.reloadRows(at: [indexpath], with: .automatic)
                        }, onError: { [weak self] error in
                            self?.hideHudAsync()
                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                        })
                    }
                }

            } else {
                Constant.MyClassConstants.btnTag = sender.tag
                performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
            }
        }
    }
    
    func resolveResort(index: Int) -> AvailabilitySectionItemResort? {
        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty, let resort = exactMatchSection.items[index].getResort() {
            return resort
        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty, let resort = surroundingMatchSection.items[index].getResort() {
            return resort
        }
        return nil
    }
    
    // MARK: - Other Renewal option selected
    func selectedRenewal(selectedRenewal: String, forceRenewals: ForceRenewals, selectedRelinquishment: ExchangeRelinquishment) {
        var renewalCoreProduct: Renewal?
        var renewalNonCoreProduct: Renewal?
        
        if selectedRenewal == Helper.renewalType(type: 0) {
            // Selected core renewal
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products where renewal.term == lowestTerm {
                renewalCoreProduct = Renewal()
                renewalCoreProduct?.id = renewal.id
                renewalCoreProduct?.productCode = renewal.productCode
                break
            }
        } else if selectedRenewal == Helper.renewalType(type: 2) {
            // Selected combo renewal
            
            if !forceRenewals.comboProducts.isEmpty {
                //FIXME(Frank): take the 1st combo
                let firstRenewComboProduct = forceRenewals.comboProducts[0]
                // Combo is composed by 2 renewals (Core and NonCore)
                if firstRenewComboProduct.renewalComboProducts.count == 2 {
                    // Split the combo
                    let renewalPairA = firstRenewComboProduct.renewalComboProducts[0]
                    let renewalPairB = firstRenewComboProduct.renewalComboProducts[1]
                    
                    if renewalPairA.isCoreProduct {
                        renewalCoreProduct = Renewal()
                        renewalCoreProduct?.id = renewalPairA.id
                        renewalCoreProduct?.productCode = renewalPairA.productCode
                    } else if !renewalPairA.isCoreProduct {
                        renewalNonCoreProduct = Renewal()
                        renewalNonCoreProduct?.id = renewalPairA.id
                        renewalNonCoreProduct?.productCode = renewalPairA.productCode
                    } else if renewalPairB.isCoreProduct {
                        renewalCoreProduct = Renewal()
                        renewalCoreProduct?.id = renewalPairB.id
                        renewalCoreProduct?.productCode = renewalPairB.productCode
                    } else if !renewalPairB.isCoreProduct {
                        renewalNonCoreProduct = Renewal()
                        renewalNonCoreProduct?.id = renewalPairB.id
                        renewalNonCoreProduct?.productCode = renewalPairB.productCode
                    }
                }
            }
            
        } else {
            // Selected non core renewal
            let lowestTerm = forceRenewals.crossSelling[0].term
            for renewal in forceRenewals.crossSelling where renewal.term == lowestTerm {
                renewalNonCoreProduct = Renewal()
                renewalNonCoreProduct?.id = renewal.id
                renewalNonCoreProduct?.productCode = renewal.productCode
                break
            }
        }
        
        // Selected single renewal from other options. Navigate to WhoWillBeCheckingIn screen
        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.isFromRenewals = true
        viewController.renewalCoreProduct = renewalCoreProduct
        viewController.renewalNonCoreProduct = renewalNonCoreProduct
        viewController.selectedRelinquishment = selectedRelinquishment
        navigationController?.pushViewController(viewController, animated: true)
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
                
                if let resort = resolveResort(index: collectionView.tag) {
                    DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resort.code, onSuccess: {[weak self](response) in
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
                }
  
            } else {
                
                showHudAsync()
                
                let selectedBucketIndex = indexPath.row // indexPath.item
                // FIXME(Frank) - what is this ?
                Constant.MyClassConstants.selectedAvailabilityInventoryBucketIndex = selectedBucketIndex
                
                // FIXME(Frank) - what is this ?
                // it is used in renewal screen to change the title of header
                Constant.MyClassConstants.isChangeNoThanksButtonTitle = false
                
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    
                    if selectedSection == 0 {
                        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                            if let resort = exactMatchSection.items[selectedRow].getResort() {
                                Constant.MyClassConstants.selectedAvailabilityResort = resort
                                
                                if let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                                    let bucket = inventoryBuckets[selectedBucketIndex]
                                    // FIXME(Frank) - what is this ?
                                    Constant.MyClassConstants.selectedAvailabilityInventoryBucket = bucket
                                    
                                    self.filterRelinquishments(resort, bucket)
                                }
                            }
                        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                Constant.MyClassConstants.selectedAvailabilityResort = resort
                                
                                if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                    let bucket = inventoryBuckets[selectedBucketIndex]
                                    // FIXME(Frank) - what is this ?
                                    Constant.MyClassConstants.selectedAvailabilityInventoryBucket = bucket
                                    
                                    self.filterRelinquishments(resort, bucket)
                                }
                            }
                        }
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    
                    if selectedSection == 0 {
                        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                            if let resort = exactMatchSection.items[selectedRow].getResort() {
                                Constant.MyClassConstants.selectedAvailabilityResort = resort
                                
                                if let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                                    let bucket = inventoryBuckets[selectedBucketIndex]
                                    // FIXME(Frank) - what is this ?
                                    Constant.MyClassConstants.selectedAvailabilityInventoryBucket = bucket
                                    
                                    //FIXME(Frank) - we already have Constant.MyClassConstants.selectedAvailabilityInventoryBucket
                                    // that can or not contains the "rentalPrices" - why a new global definition?
                                    if let rentalPrices = bucket.rentalPrices {
                                        Constant.MyClassConstants.rentalPrices = rentalPrices
                                    }
                                    
                                    self.startRentalProcess(resort, bucket)
                                }
                            }
                        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                Constant.MyClassConstants.selectedAvailabilityResort = resort
                                
                                if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                    let bucket = inventoryBuckets[selectedBucketIndex]
                                    // FIXME(Frank) - what is this ?
                                    Constant.MyClassConstants.selectedAvailabilityInventoryBucket = bucket
                                    
                                    //FIXME(Frank) - we already have Constant.MyClassConstants.selectedAvailabilityInventoryBucket
                                    // that can or not contains the "rentalPrices" - why a new global definition?
                                    if let prices = bucket.rentalPrices {
                                        Constant.MyClassConstants.rentalPrices = prices
                                    }
                                    
                                    self.startRentalProcess(resort, bucket)
                                }
                            }
                        }
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined() {
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    
                    if selectedSection == 0 {
                        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                            if let resort = exactMatchSection.items[selectedRow].getResort() {
                                Constant.MyClassConstants.selectedAvailabilityResort = resort
                                
                                if let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                                    let bucket = inventoryBuckets[selectedBucketIndex]
                                    // FIXME(Frank) - what is this ?
                                    Constant.MyClassConstants.selectedAvailabilityInventoryBucket = bucket
                                    
                                    //FIXME(Frank) - we already have Constant.MyClassConstants.selectedAvailabilityInventoryBucket
                                    // that can or not contains the "rentalPrices" - why a new global definition?
                                    if let rentalPrices = bucket.rentalPrices {
                                        Constant.MyClassConstants.rentalPrices = rentalPrices
                                    }
                                    
                                    // Set the pointsCost should apply only for Exchange
                                    if let selectedBucket = Constant.MyClassConstants.selectedAvailabilityInventoryBucket, let pointsCost = selectedBucket.exchangePointsCost, let memberPointsRequired = selectedBucket.exchangeMemberPointsRequired, pointsCost != memberPointsRequired {
                                        showInfoIcon = true
                                    }
                                    
                                    if bucket.vacationSearchType.isCombined() || bucket.vacationSearchType.isExchange() {
                                        self.filterRelinquishments(resort, bucket)
                                    } else if bucket.vacationSearchType.isRental() {
                                        // FIXME(Frank) - what is this ?
                                        Constant.MyClassConstants.filterRelinquishments.removeAll()
                                        
                                        self.navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                                    }
                                }
                            }
                        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                Constant.MyClassConstants.selectedAvailabilityResort = resort
                                
                                if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                    let bucket = inventoryBuckets[selectedBucketIndex]
                                    // FIXME(Frank) - what is this ?
                                    Constant.MyClassConstants.selectedAvailabilityInventoryBucket = bucket
                                    
                                    //FIXME(Frank) - we already have Constant.MyClassConstants.selectedAvailabilityInventoryBucket
                                    // that can or not contains the "rentalPrices" - why a new global definition?
                                    if let prices = bucket.rentalPrices {
                                        Constant.MyClassConstants.rentalPrices = prices
                                    }
                                    
                                    if bucket.vacationSearchType.isCombined() || bucket.vacationSearchType.isExchange() {
                                        self.filterRelinquishments(resort, bucket)
                                    } else if bucket.vacationSearchType.isRental() {
                                        // FIXME(Frank) - what is this ?
                                        Constant.MyClassConstants.filterRelinquishments.removeAll()
                                        
                                        self.navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                                    }
                                }
                            }
                        }
                    
                    } else {
                        /// ????
                        intervalPrint("Why?")
                        
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
                return CGSize(width: UIScreen.main.bounds.width, height: CGFloat(resortImageCellHeight))
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
                selectedSection = collectionView.superview?.superview?.tag ?? 0
                selectedRow = collectionView.tag
           
                if selectedSection == 0 {
                    switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                        
                    case VacationSearchType.RENTAL:
                        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                            return exactMatchSection.items.count
                        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            return surroundingMatchSection.items.count
                        } else {
                            return 0
                        }
                        
                    case VacationSearchType.EXCHANGE:
                        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                            return exactMatchSection.items.count
                        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            return surroundingMatchSection.items.count
                        } else {
                            return 0
                        }
                        
                    case VacationSearchType.COMBINED:
                        if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                            return exactMatchSection.items.count
                        } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            return surroundingMatchSection.items.count
                        } else {
                            return 0
                        }
                        
                    default:
                        return 0
                    }
                    
                } else {
                    
                    switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
                        
                    case VacationSearchType.RENTAL:
                        if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            return surroundingMatchSection.items.count
                        } else {
                            return 0
                        }
       
                    case VacationSearchType.EXCHANGE:
                        if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            return surroundingMatchSection.items.count
                        } else {
                           return 0
                        }
                        
                    case VacationSearchType.COMBINED:
                        if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                            return surroundingMatchSection.items.count
                        } else {
                            return 0
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
                        cell.backgroundColor = Constant.CommonColor.headerGreenColor
                    } else {
                        cell.backgroundColor = IUIKColorPalette.primary1.color
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
                selectedSection = collectionView.superview?.superview?.tag ?? 0
                selectedRow = collectionView.tag
                
                var availabilityResort: AvailabilitySectionItemResort?
                var availabilityBuckets: [AvailabilitySectionItemInventoryBucket]?
                
                if selectedSection == 0 {
                    if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                        availabilityResort = exactMatchSection.items[selectedRow].getResort()
                        
                        if let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                            availabilityBuckets = inventoryBuckets
                        }
                    } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                        availabilityResort = surroundingMatchSection.items[selectedRow].getResort()
                        
                        if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                            availabilityBuckets = inventoryBuckets
                        }
                    }
                } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                    availabilityResort = surroundingMatchSection.items[selectedRow].getResort()
                    
                    if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                        availabilityBuckets = inventoryBuckets
                    }
                }
                
                if indexPath.section == 0 {
                    if let resort = availabilityResort {
                        let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                        return cell
                    }
                } else {
                    if let buckets = availabilityBuckets {
                        let cell = self.getRentalCollectionCell(indexPath: indexPath, collectionView: collectionView)
                        cell.setBucket(bucket: buckets[indexPath.item])
                        return cell
                    }
                }

            case VacationSearchType.EXCHANGE:
                selectedSection = collectionView.superview?.superview?.tag ?? 0
                selectedRow = collectionView.tag
                
                if selectedSection == 0 {
                    if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                        if indexPath.section == 0 {
                            if let resort = exactMatchSection.items[selectedRow].getResort() {
                                let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                                return cell
                            }
                        } else {
                            if let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                                let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                cell.setBucket(bucket: inventoryBuckets[indexPath.item])
                                return cell
                            }
                        }
                    } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                        if indexPath.section == 0 {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                                return cell
                            }
                        } else {
                            if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                cell.setBucket(bucket: inventoryBuckets[indexPath.item])
                                cell.exchangeCellDelegate = self
                                return cell
                            }
                        }
                    }
                    
                } else {
                    //FIXME(Frank) - Why?
                    if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                        if indexPath.section == 0 {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                                return cell
                            }
                        } else {
                            if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                cell.setBucket(bucket: inventoryBuckets[indexPath.item])
                                cell.exchangeCellDelegate = self
                                return cell
                            }
                        }
                    }
                }

            case VacationSearchType.COMBINED:
                selectedSection = collectionView.superview?.superview?.tag ?? 0
                selectedRow = collectionView.tag
                
                if selectedSection == 0 {
                    if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
                        if indexPath.section == 0 {
                            if let resort = exactMatchSection.items[selectedRow].getResort() {
                                let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                                return cell
                            }
                        } else {
                            if let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                                let bucket = inventoryBuckets[indexPath.item]
                                
                                if bucket.vacationSearchType.isCombined() {
                                    guard let collectionSuperviewTag = collectionView.superview?.superview?.tag else { return UICollectionViewCell() }
                                    
                                    if collectionSuperviewTag == 0 {
                                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as? SearchBothInventoryCVCell else { return UICollectionViewCell() }
                                        cell.setBucket(bucket: bucket)
                                        cell.exchangeCellDelegate = self
                                        return cell
                                    }
     
                                } else if bucket.vacationSearchType.isExchange() {
                                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                    cell.setBucket(bucket: bucket)
                                    cell.exchangeCellDelegate = self
                                    return cell
                                    
                                } else if bucket.vacationSearchType.isRental() {
                                    let cell = self.getRentalCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                    cell.setBucket(bucket: bucket)
                                    return cell
                                }
                            }
                        }
                    } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                        if indexPath.section == 0 {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                                return cell
                            }
                        } else {
                            if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                let bucket = inventoryBuckets[indexPath.item]
                                
                                if bucket.vacationSearchType.isCombined() {
                                    guard let collectionSuperviewTag = collectionView.superview?.superview?.tag else { return UICollectionViewCell() }
                                    
                                    if collectionSuperviewTag == 1 {
                                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as? SearchBothInventoryCVCell else { return UICollectionViewCell() }
                                        cell.setBucket(bucket: bucket)
                                        return cell
                                    }
                                    
                                } else if bucket.vacationSearchType.isExchange() {
                                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                    cell.setBucket(bucket: bucket)
                                    cell.exchangeCellDelegate = self
                                    return cell
                                    
                                } else if bucket.vacationSearchType.isRental() {
                                    let cell = self.getRentalCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                    cell.setBucket(bucket: bucket)
                                    return cell
                                }
                            }
                        }
                    }
                    
                } else {
                    //FIXME(Frank) - Why?
                    if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
                        if indexPath.section == 0 {
                            if let resort = surroundingMatchSection.items[selectedRow].getResort() {
                                let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: resort)
                                return cell
                            }
                        } else {
                            if let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets() {
                                let bucket = inventoryBuckets[indexPath.item]
                                
                                if bucket.vacationSearchType.isCombined() {
                                    guard let collectionSuperviewTag = collectionView.superview?.superview?.tag else { return UICollectionViewCell() }
                                    
                                    if collectionSuperviewTag == 1 {
                                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as? SearchBothInventoryCVCell else { return UICollectionViewCell() }
                                        cell.setBucket(bucket: bucket)
                                        return cell
                                    }
                                    
                                } else if bucket.vacationSearchType.isExchange() {
                                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                    cell.setBucket(bucket: bucket)
                                    cell.exchangeCellDelegate = self
                                    return cell
                                    
                                } else if bucket.vacationSearchType.isRental() {
                                    let cell = self.getRentalCollectionCell(indexPath: indexPath, collectionView: collectionView)
                                    cell.setBucket(bucket: bucket)
                                    return cell
                                }
                            }
                        }
                    }
                }
 
            default:
                return UICollectionViewCell()
            }
        }
        
        return UICollectionViewCell()
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

        if !availabilitySections.isEmpty {
            for availabilitySection in availabilitySections {
                if availabilitySection.exactMatch == true && section == 0 {
                    // FIXME(Frank): Why? - this is not GOOD
                    //headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    headerLabel.text = availabilitySection.header
                    headerView.backgroundColor = Constant.CommonColor.headerGreenColor
                    break
                } else if availabilitySection.exactMatch == false && section == 1 {
                    // FIXME(Frank): Why? - this is not GOOD
                    //headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    headerLabel.text = availabilitySection.header
                    headerView.backgroundColor = IUIKColorPalette.primary1.color
                    break
                } else {
                    // FIXME(Frank): Why? - this is not GOOD
                    //headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    headerLabel.text = availabilitySection.header
                    headerView.backgroundColor = IUIKColorPalette.primary1.color
                }
            }
        }
        headerLabel.textColor = UIColor.white
        headerView.addSubview(headerLabel)
        
        // Selector of Destination/Area/Resort/Resort Group
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
                    let selectedRow = indexPath.row - 1
                    
                    if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty,
                        let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                        return CGFloat(inventoryBuckets.count * 80 + resortImageCellHeight + 10)
                    } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty,
                        let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets()  {
                        return CGFloat(inventoryBuckets.count * 80 + resortImageCellHeight + 10)
                    }
                    
                    return 0

                } else {
                    
                    let selectedRow = indexPath.row
                    
                    if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty,
                        let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                        return CGFloat(inventoryBuckets.count * 80 + resortImageCellHeight + 10)
                    } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty,
                        let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets()  {
                        return CGFloat(inventoryBuckets.count * 80 + resortImageCellHeight + 10)
                    }
                    
                    return 0
                }
            }
            
        } else {
            //FIXME(Frank) - Why?
            let selectedRow = indexPath.row
            
            if let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty,
                let inventoryBuckets = exactMatchSection.items[selectedRow].getInventoryBuckets() {
                return CGFloat(inventoryBuckets.count * 80 + resortImageCellHeight + 10)
            } else if let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty,
                let inventoryBuckets = surroundingMatchSection.items[selectedRow].getInventoryBuckets()  {
                return CGFloat(inventoryBuckets.count * 80 + resortImageCellHeight + 10)
            }
            
            return 0
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
        return availabilitySections.count
    }
    
    // MARK:- Table Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        if section == 0, let exactMatchSection = availabilityExactMatchSection, !exactMatchSection.items.isEmpty {
            if Constant.MyClassConstants.isShowAvailability == true {
                return exactMatchSection.items.count + 1
            } else {
                return exactMatchSection.items.count
            }
        } else if section == 0, let surroundingMatchSection = availabilitySurroundingMatchSection, !surroundingMatchSection.items.isEmpty {
            if Constant.MyClassConstants.isShowAvailability == true {
                return surroundingMatchSection.items.count + 1
            } else {
                return surroundingMatchSection.items.count
            }
        }
        
        return 0
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
                    Constant.MyClassConstants.favoritesResortCodeArray.append(resortCode)
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
                    Constant.MyClassConstants.favoritesResortCodeArray = Constant.MyClassConstants.favoritesResortCodeArray.filter{ $0 != resortCode }
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
        let userSelectedCheckInDate = Constant.MyClassConstants.vacationSearchShowDate.stringWithShortFormatForJSON()
        if Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != userSelectedCheckInDate {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        
        hideHudAsync()
        createSections()
        searchResultTableView.reloadData()
    }
}

// Implementing custom delegate method definition
extension SearchResultViewController: RenewelViewControllerDelegate {
    
    //remove later
    func dismissWhatToUse(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?) {
        self.dismiss(animated: false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.renewalCoreProduct = renewalCoreProduct
        viewController.renewalNonCoreProduct = renewalNonCoreProduct
        intervalPrint("_______>self.selectedRow,\(self.selectedRow)")
        viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?, selectedRelinquishment: ExchangeRelinquishment) {
        self.dismiss(animated: false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.renewalCoreProduct = renewalCoreProduct
        viewController.renewalNonCoreProduct = renewalNonCoreProduct
        viewController.selectedRelinquishment = selectedRelinquishment
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func noThanks(selectedRelinquishment: ExchangeRelinquishment) {
        self.dismiss(animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.selectedRelinquishment = selectedRelinquishment
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        if Constant.RunningDevice.deviceIdiom == .phone {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.renewalOtherOptionsVC) as? RenewalOtherOptionsVC else { return }
            viewController.selectAction = { [weak self] (selectedType, renewal, relinquishment) in
                self?.selectedRenewal(selectedRenewal: selectedType, forceRenewals: renewal, selectedRelinquishment: relinquishment)
            }
            
            viewController.forceRenewals = forceRenewals
            if !Constant.MyClassConstants.filterRelinquishments.isEmpty {
                viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]
            }
            present(viewController, animated: true)
            
            return
            
        } else {
            
            let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.renewalOtherOptionsVC) as? RenewalOtherOptionsVC else { return }
            viewController.selectAction = { [weak self] (selectedType, renewal, relinquishment) in
                self?.selectedRenewal(selectedRenewal: selectedType, forceRenewals: renewal, selectedRelinquishment: relinquishment)
            }
            if !Constant.MyClassConstants.filterRelinquishments.isEmpty {
                viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]
            }
            viewController.forceRenewals = forceRenewals
            present(viewController, animated: true)
            
            return
        }
    }
    
}

extension SearchResultViewController: WhoWillBeCheckInDelegate {
    func navigateToWhoWillBeCheckIn(renewalCoreProduct: Renewal?, renewalNonCoreProduct: Renewal?, selectedRow: Int, selectedRelinquishment: ExchangeRelinquishment) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: SearchResultViewController.whoWillBeCheckingInViewController) as? WhoWillBeCheckingInViewController else { return }
        viewController.renewalCoreProduct = renewalCoreProduct
        viewController.renewalNonCoreProduct = renewalNonCoreProduct
        viewController.selectedRelinquishment = selectedRelinquishment
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchResultViewController: ExchangeInventoryCVCellDelegate {
    func infoIconPressed() {
        self.performSegue(withIdentifier: "pointsInfoSegue", sender: self)
    }
}

