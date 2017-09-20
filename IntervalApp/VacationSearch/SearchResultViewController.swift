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
import SVProgressHUD
import RealmSwift

class SearchResultViewController: UIViewController {
    
    
    
    //***** Outlets ****//
    @IBOutlet weak var searchResultColelctionView: UICollectionView!
    @IBOutlet weak var searchResultTableView: UITableView!
    
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
    var vacationSearch = VacationSearch()
    var exactMatchResortsArray = [Resort]()
    var surroundingMatchResortsArray = [Resort]()
    var surroundingMatchResortsArrayExchange = [ExchangeAvailability]()
    var exactMatchResortsArrayExchange = [ExchangeAvailability]()
    var combinedExactSearchItems = [AvailabilitySectionItem]()
    var combinedSurroundingSearchItems = [AvailabilitySectionItem]()
    var dateCellSelectionColor = Constant.CommonColor.blueColor
    var myActivityIndicator = UIActivityIndicatorView()
    
    // sorting optionDelegate call
    
    func selectedOptionis(filteredValueIs:String, indexPath:NSIndexPath, isFromFiltered:Bool) {
        
    }
    
    func runTimer()  {
        
        Constant.MyClassConstants.isShowAvailability = false
        let sectionIndex = IndexSet(integer: 0)
        self.searchResultTableView.reloadSections(sectionIndex, with: .none)
        
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 70.0/255.0, green: 136.0/255.0, blue: 193.0/255.0, alpha: 1.0)

        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        createSections()

        self.searchResultColelctionView.reloadData()
        self.searchResultTableView.reloadData()
    }
    
    func createSections(){
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
        
        if(sections.count == 0){
            searchResultTableView.tableHeaderView = Helper.noResortView(senderView: self.view)
        }else{
            let headerVw = UIView()
            searchResultTableView.tableHeaderView = headerVw
        }
        
        exactMatchResortsArray.removeAll()
        exactMatchResortsArrayExchange.removeAll()
        surroundingMatchResortsArray.removeAll()
        surroundingMatchResortsArrayExchange.removeAll()
        combinedExactSearchItems.removeAll()
        combinedSurroundingSearchItems.removeAll()
        
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange){
            
            if(sections.count > 0){
                
              for section in sections{
                    
                if(section.exactMatch == nil || section.exactMatch == true){
                    
                    dateCellSelectionColor = Constant.CommonColor.blueColor
                    
                    for exactResorts in (section.items)!{
                        
                        if(exactResorts.exchangeAvailability != nil){
                                
                            let resortsExact = exactResorts.exchangeAvailability
                                exactMatchResortsArrayExchange.append(resortsExact!)
                            }
                        }
                }else{
                    if(sections.count == 1){
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    for surroundingResorts in (section.items)!{
                        
                        if(surroundingResorts.exchangeAvailability != nil){
                            let resortsSurrounding = surroundingResorts.exchangeAvailability
                            exactMatchResortsArrayExchange.append(resortsSurrounding!)
                        }
                    }
                 }
                }
                
                /*if(sections.count > 1){
                    
                    for section in sections{
                        
                        if(section.exactMatch == nil || section.exactMatch == false){
                            
                            for surroundingResorts in (section.items)!{
                                
                                if(surroundingResorts.exchangeAvailability != nil){
                                    
                                    let resortsSurrounding = surroundingResorts.exchangeAvailability
                                    surroundingMatchResortsArrayExchange.append(resortsSurrounding!)
                                }
                            }
                        }
                    }
                }*/
            }
        }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental){
            
            exactMatchResortsArray.removeAll()
            for section in sections{
                
                if(section.exactMatch == nil || section.exactMatch == true){
                    
                    for exactResorts in (section.items)!{
                        
                        if(exactResorts.rentalAvailability != nil){
                            
                            let resortsExact = exactResorts.rentalAvailability
                            exactMatchResortsArray.append(resortsExact!)
                        }
                    }
                }else{
                    if(sections.count == 1){
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    for surroundingResorts in (section.items)!{
                        
                        if(surroundingResorts.rentalAvailability != nil){
                            let resortsSurrounding = surroundingResorts.rentalAvailability
                            surroundingMatchResortsArray.append(resortsSurrounding!)
                        }
                    }
                }
            }
        }else{
            for section in sections{
                
                if(section.exactMatch == nil || section.exactMatch == true){
                    
                    combinedExactSearchItems = section.items!
                    
                }else{
                    
                    if(sections.count == 1){
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    
                    combinedSurroundingSearchItems = section.items!
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.helperDelegate = self
        searchResultTableView.estimatedRowHeight = 400
        searchResultTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        Helper.removeServiceCallBackgroundView(view: self.view)
        //***** Register collection cell xib with collection view *****//
        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchResultColelctionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
        searchResultTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier:  Constant.customCellNibNames.searchResultContentTableCell)
        
        self.title = Constant.ControllerTitles.searchResultViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(SearchResultViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
     
        
        if (Constant.MyClassConstants.showAlert == true) {
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            headerVw.isHidden = true
            self.view.bringSubview(toFront: self.alertView)
        }else{
            headerVw.isHidden = false
            self.alertView.isHidden = true
        }
        
        self.collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    func intervalBucketClicked(calendarItem:CalendarItem!, cell:UICollectionViewCell){
        
        myActivityIndicator.hidesWhenStopped = true
        Helper.hideProgressBar(senderView: self)
    
        // Resolve the next active interval based on the Calendar interval selected
        let activeInterval = Constant.MyClassConstants.initialVacationSearch.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate, intervalEndDate: calendarItem.intervalEndDate)
        
        // Fetch CheckIn dates only in the active interval doesn't have CheckIn dates
        if (activeInterval != nil && !(activeInterval?.hasCheckInDates())!) {
            
            // Execute Search Dates
            if (Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()) {
                
                // Update CheckInFrom and CheckInTo dates
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
             onSuccess: { (response) in
                
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        
                Constant.MyClassConstants.calendarDatesArray.removeAll()
                
                Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
                
                self.searchResultColelctionView.reloadData()
                
            },
            onError:{ (error) in
                
                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                
                }
            )
        }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined()){
                 
            // Update CheckInFrom and CheckInTo dates
            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
            
            // Execute Rental Search Dates
            RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
            onSuccess: { (response) in
            
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                            
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                
                // Check not available checkIn dates for the active interval for Rental
                if (!(activeInterval?.hasCheckInDates())!) {
                    Constant.MyClassConstants.rentalHasNotAvailableCheckInDatesAfterSelectInterval = true
                }
                
                // Run Exchange Search Dates
                Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV:self.searchResultColelctionView)
                
                //expectation.fulfill()
                },
                 onError:{ (error) in
                    // Run Exchange Search Dates
                    Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchResultColelctionView)
                }
                )
                
                
            }else{
                
                // Update CheckInFrom and CheckInTo dates
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString:calendarItem.intervalStartDate!,format:Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString:calendarItem.intervalEndDate!,format:Constant.MyClassConstants.dateFormat)
                
                
                ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
                   onSuccess: { (response) in
                    
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                    let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        Helper.showNotAvailabilityResults()
                        
                    }
                    Constant.MyClassConstants.calendarDatesArray.removeAll()
                    
                    Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
                    
                    self.searchResultColelctionView.reloadData()
                    
                },
               onError:{ (error) in
                
                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
                )
            }
        }else {
            
            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
            
            Constant.MyClassConstants.calendarDatesArray.removeAll()
            
            Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
            
            self.searchResultColelctionView.reloadData()
            myActivityIndicator.stopAnimating()
            cell.alpha = 1.0
        }
    }
    
    
    //*****Function for more button press *****//
    func intervalDateItemClicked(_ toDate: Date){
         searchResultColelctionView.reloadData()
         if(combinedExactSearchItems.isEmpty && combinedSurroundingSearchItems.isEmpty && exactMatchResortsArray.isEmpty && exactMatchResortsArrayExchange.isEmpty && surroundingMatchResortsArray.isEmpty && surroundingMatchResortsArrayExchange.isEmpty){
            print("All empty")
         }else{
            let indexPath = IndexPath(row: 0, section: 0)
            searchResultTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
        Helper.helperDelegate = self
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
            Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        }else{
            Helper.showProgressBar(senderView: self)
            let request = RentalSearchResortsRequest()
            request.checkInDate = toDate
            request.resortCodes = activeInterval?.resortCodes
            
            RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: request,
                                       onSuccess: { (response) in
                                        // Update Rental inventory
                                        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.inventory = response.resorts
                                        
                                        // Run Exchange Search Dates
                                        Helper.executeExchangeSearchAvailabilityAfterSelectCheckInDate(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format: Constant.MyClassConstants.dateFormat), searchCriteria: Constant.MyClassConstants.initialVacationSearch.searchCriteria, senderVC: self)
                                        
                                        
            },
                                       onError:{ (error) in
                                        SimpleAlert.alert(self, title: Constant.AlertMessages.noResultMessage, message: error.localizedDescription)
            }
            )
            
        }
        
    }
    
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func resortDetailsClicked(_ toDate: Date){
        
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        
        if(Constant.MyClassConstants.surroundingCheckInDates.contains(Constant.MyClassConstants.checkInDates[collectionviewSelectedIndex - 1])){
            
            searchResortRequest.resortCodes = Constant.MyClassConstants.surroundingResortCodesArray
        }else{
            
            searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        }
        
        Constant.MyClassConstants.resortsArray.removeAll()
        Helper.showProgressBar(senderView: self)
        
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
            Constant.MyClassConstants.resortsArray = response.resorts
            if(self.alertView.isHidden == false){
                self.alertView.isHidden = true
                self.headerVw.isHidden = false
            }
            self.searchResultTableView.reloadData()
            Helper.hideProgressBar(senderView: self)
        }, onError: { (error) in
            Constant.MyClassConstants.resortsArray.removeAll()
            self.searchResultTableView.reloadData()
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            self.headerVw.isHidden = true
            Helper.hideProgressBar(senderView: self)
        })
        
    }


    //Dynamic API hit
    
    func getFilterRelinquishments(selectedInventoryUnit:Inventory, selectedIndex:Int, selectedExchangeInventory: ExchangeInventory){
        Helper.showProgressBar(senderView: self)
        let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
        exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        exchangeSearchDateRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as! [String]
        
        let exchangeDestination = ExchangeDestination()
        let resort = Resort()
        resort.resortCode = Constant.MyClassConstants.selectedResort.resortCode
        
        exchangeDestination.resort = resort
        
        let unit = InventoryUnit()
        
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined()){
            let currentFromDate = selectedInventoryUnit.checkInDate
            let currentToDate = selectedInventoryUnit.checkOutDate
            unit.kitchenType = selectedInventoryUnit.units[selectedIndex].kitchenType!
            unit.unitSize = selectedInventoryUnit.units[selectedIndex].unitSize!
            exchangeDestination.checkInDate = currentFromDate
            exchangeDestination.checkOutDate = currentToDate
            unit.publicSleepCapacity = selectedInventoryUnit.units[selectedIndex].publicSleepCapacity
            unit.privateSleepCapacity = selectedInventoryUnit.units[selectedIndex].privateSleepCapacity
            
        }else{
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
        
        ExchangeClient.filterRelinquishments(UserContext.sharedInstance.accessToken, request: exchangeSearchDateRequest, onSuccess: { (response) in
            Helper.hideProgressBar(senderView: self)
            Constant.MyClassConstants.filterRelinquishments.removeAll()
            
            for exchageDetail in response{
                Constant.MyClassConstants.filterRelinquishments.append(exchageDetail.relinquishment!)
            }
            
            Constant.MyClassConstants.selectedUnitIndex = selectedIndex
            
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Combined){
                self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
            }else{
                if(Constant.MyClassConstants.filterRelinquishments.count > 1){
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                }else if(response.count > 0 && response[0].destination?.upgradeCost != nil){
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                }else {
                    self.startProcess()
                }
            }
            
        }, onError: { (error) in
            Helper.hideProgressBar(senderView: self)
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.description)
        })
    }
    
    //Start process function call
    
    func startProcess(){
        
        
        //Start process request
        
        //Exchange process request parameters
        Helper.showProgressBar(senderView: self)
        let processResort = ExchangeProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        
        let processRequest = ExchangeProcessStartRequest()
        
        processRequest.destination = Constant.MyClassConstants.exchangeDestination
        processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        if(Constant.MyClassConstants.filterRelinquishments[0].openWeek?.relinquishmentId != nil){
            processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.relinquishmentId
        }else{
            processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[0].deposit?.relinquishmentId
        }
        
        
        ExchangeProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: {(response) in
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            Constant.MyClassConstants.exchangeViewResponse = response.view!
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            for amenity in (response.view?.destination?.resort?.amenities)!{
                if(amenity.nearby == false){
                    Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                }else{
                    Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                }
            }
            UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                
                // Got an access token!  Save it for later use.
                Helper.hideProgressBar(senderView: self)
                Constant.MyClassConstants.membershipContactArray = Membership.contacts!
                var viewController = UIViewController()
                    viewController = WhoWillBeCheckingInViewController()
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                    viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                    (viewController as! WhoWillBeCheckingInViewController).filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[0]
                    
                    
                
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController!.pushViewController(viewController, animated: true)
            }, onError: { (error) in
                
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                
            })
            
        }, onError: {(error) in
            Helper.hideProgressBar(senderView: self)
            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
        })
    }
  

    //Passing information while preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // function called when search result page map view button pressed
    @IBAction func mapViewButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultMapSegue , sender: nil)
    }
    
    @IBAction func sortByNameButtonPressed(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        viewController.selectedSortingIndex = Constant.MyClassConstants.sortingIndex
        self.present(viewController, animated: true, completion: nil)

    }
    
    //funciton called when search result page sort by name button pressed
    @IBAction func filterByNameButtonPressed(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        viewController.isFilterClicked = true
        viewController.resortNameArray = Constant.MyClassConstants.resortsArray
        viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
        self.present(viewController, animated: true, completion: nil)

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let firstVisibleIndexPath = searchResultTableView.indexPathsForVisibleRows?.first
        let indexPath = IndexPath(item: collectionviewSelectedIndex, section: 0)
        if(firstVisibleIndexPath?.section == 1){
            dateCellSelectionColor = Constant.CommonColor.greenColor
        }else{
            //dateCellSelectionColor = Constant.CommonColor.blueColor
        }
        
        if(indexPath.row <= Constant.MyClassConstants.calendarDatesArray.count){
            if(searchResultColelctionView != nil){
                searchResultColelctionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    // Common method to get exchange collection view cell
    func getGetawayCollectionCell(indexPath: IndexPath, collectionView:UICollectionView) -> RentalInventoryCVCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortInventoryCell, for: indexPath) as! RentalInventoryCVCell
        return cell
    }
    
    // Common method to get rental collection view cell
    func getExchangeCollectionCell(indexPath: IndexPath, collectionView:UICollectionView) -> ExchangeInventoryCVCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.exchangeInventoryCell, for: indexPath) as! ExchangeInventoryCVCell
        return cell
        
    }
    
    // Common method to get Resort Info collection view cell
    func getResortInfoCollectionCell(indexPath: IndexPath, collectionView:UICollectionView, resort:Resort) -> AvailabilityCollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as! AvailabilityCollectionViewCell
        cell.setResortDetails(inventoryItem: resort)
        return cell
    }
    
}

func enableDisablePreviousMoreButton(_ position : NSString) -> Bool{
    let currentDate = Date()
    var order = (Calendar.current as NSCalendar).compare(Constant.MyClassConstants.currentFromDate as Date, to: currentDate,toUnitGranularity: .hour)
    if (position.isEqual(to: Constant.MyClassConstants.right)) {
        let nextDate =  (Calendar.current as NSCalendar).date(byAdding: .month, value: +24, to: Constant.MyClassConstants.currentFromDate as Date, options: [])!
        order = (Calendar.current as NSCalendar).compare(currentDate, to: nextDate,toUnitGranularity: .hour)
    }
    
    switch order {
    case .orderedDescending:
        if (position.isEqual(to: Constant.MyClassConstants.right)) {
            return false
        }else{
            return true
        }
    case .orderedAscending:
        if (position.isEqual(to: Constant.MyClassConstants.right)) {
            return true
        }else{
            return false
        }
    case .orderedSame:
        return false
    }
}


//***** MARK: Extension classes starts from here *****//

extension SearchResultViewController:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView.tag == -1){
            
            let cell = collectionView.cellForItem(at: indexPath)
            
            if(cell?.isKind(of:MoreCell.self))!{
                
                let viewForActivity = UIView()
                viewForActivity.frame = CGRect(x:0, y:0, width:(cell?.bounds.width)!, height:(cell?.bounds.height)!)
                
                myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                
                // Position Activity Indicator in the center of the main view
                myActivityIndicator.center = (cell?.contentView.center)!
                
                // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
                myActivityIndicator.hidesWhenStopped = false
                
                // Start Activity Indicator
                myActivityIndicator.startAnimating()

                cell?.alpha = 0.3
                viewForActivity.addSubview(myActivityIndicator)
                cell?.contentView.addSubview(viewForActivity)
            }
            
            let lastSelectedIndex = collectionviewSelectedIndex
            collectionviewSelectedIndex = indexPath.item
            dateCellSelectionColor = Constant.CommonColor.blueColor
            if(Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)!{
                
                Helper.showProgressBar(senderView: self)
                intervalBucketClicked(calendarItem:Constant.MyClassConstants.calendarDatesArray[indexPath.item], cell: cell!)
            }else{
                
                intervalDateItemClicked(Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[indexPath.item].checkInDate!, format: Constant.MyClassConstants.dateFormat))
            }
        }else{
            if((indexPath as NSIndexPath).section == 0) {
                Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
                Constant.MyClassConstants.isFromSearchResult = true
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()
                var resortCode = ""
                if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental){
                    
                    if(collectionView.superview?.superview?.tag == 0 && exactMatchResortsArray.count > 0){
                       resortCode = exactMatchResortsArray[collectionView.tag].resortCode!
                    }else{
                        resortCode = surroundingMatchResortsArray[collectionView.tag].resortCode!
                    }
                  
                }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                    if(collectionView.superview?.superview?.tag == 0 && exactMatchResortsArrayExchange.count > 0){
                        resortCode = (self.exactMatchResortsArrayExchange[collectionView.tag].resort?.resortCode!)!
                    }else{
                        resortCode = (self.surroundingMatchResortsArrayExchange[collectionView.tag].resort?.resortCode!)!
                    }
                }else{
                    if(collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count > 0){
                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                            resortCode = (combinedExactSearchItems[collectionView.tag].rentalAvailability!.resortCode!)
                        }else{
                            resortCode = (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort?.resortCode!)!
                        }
                        
                    }else{
                        if(combinedSurroundingSearchItems[indexPath.section].rentalAvailability != nil){
                            resortCode = (combinedSurroundingSearchItems[indexPath.section].rentalAvailability!.resortCode!)
                        }else{
                            resortCode = (combinedSurroundingSearchItems[indexPath.section].exchangeAvailability?.resort?.resortCode!)!
                        }
                    }
                }
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { (response) in
                    
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAllObjects()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray {
                        if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                            
                            Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                        }
                    }
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = collectionView.tag + 1
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.vacationSearchDetailSegue, sender: nil)
                })
                { (error) in
                    
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
                }
            }else{
                
                if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        selectedSection = (collectionView.superview?.superview?.tag)!
                        selectedRow = collectionView.tag
                        if(collectionView.superview?.superview?.tag == 0){
                            Constant.MyClassConstants.selectedResort = self.exactMatchResortsArrayExchange[collectionView.tag].resort!
                            self.getFilterRelinquishments(selectedInventoryUnit:Inventory(), selectedIndex:indexPath.item, selectedExchangeInventory: self.exactMatchResortsArrayExchange[collectionView.tag].inventory!)
                        }else{
                            Constant.MyClassConstants.selectedResort = self.surroundingMatchResortsArrayExchange[collectionView.tag].resort!
                            self.getFilterRelinquishments(selectedInventoryUnit:Inventory(), selectedIndex:indexPath.item, selectedExchangeInventory: self.surroundingMatchResortsArrayExchange[collectionView.tag].inventory!)
                        }
                    
                }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                    Helper.addServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.show()
                    
                    if(collectionView.superview?.superview?.tag == 0 && self.exactMatchResortsArray.count > 0){
                           Constant.MyClassConstants.selectedResort = self.exactMatchResortsArray[collectionView.tag]
                    }else{
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
                    if(Constant.MyClassConstants.selectedResort.allInclusive){
                        Constant.MyClassConstants.hasAdditionalCharges = true
                    }else{
                        Constant.MyClassConstants.hasAdditionalCharges = false
                    }
                    processRequest.unit = units[indexPath.item]
                    
                    let processRequest1 = RentalProcessStartRequest.init(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate!, unitSize: UnitSize(rawValue: units[indexPath.item].unitSize!)!, kitchenType: KitchenType(rawValue: units[indexPath.item].kitchenType!)!)
                    
                    RentalProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
                        
                        let processResort = RentalProcess()
                        processResort.processId = response.processId
                        Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
                        Constant.MyClassConstants.processStartResponse = response
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        Constant.MyClassConstants.viewResponse = response.view!
                        Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
                        Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                        Constant.MyClassConstants.onsiteArray.removeAllObjects()
                        Constant.MyClassConstants.nearbyArray.removeAllObjects()
                        
                        for amenity in (response.view?.resort?.amenities)!{
                            if(amenity.nearby == false){
                                Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                            }else{
                                Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                            }
                        }
                        
                        
                        UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                            
                            // Got an access token!  Save it for later use.
                            SVProgressHUD.dismiss()
                            Helper.removeServiceCallBackgroundView(view: self.view)
                            Constant.MyClassConstants.membershipContactArray = Membership.contacts!
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                            
                            let transitionManager = TransitionManager()
                            self.navigationController?.transitioningDelegate = transitionManager
                            self.navigationController!.pushViewController(viewController, animated: true)
                            
                        }, onError: { (error) in
                            
                            SVProgressHUD.dismiss()
                            Helper.removeServiceCallBackgroundView(view: self.view)
                            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
                            
                        })
                        
                    }, onError: {(error) in
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        SVProgressHUD.dismiss()
                        SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.description)
                    })
                }else{
                    selectedSection = (collectionView.superview?.superview?.tag)!
                    selectedRow = collectionView.tag
                    Constant.MyClassConstants.selectedUnitIndex = indexPath.item
                    if(collectionView.superview?.superview?.tag == 0){
                        
                        if(combinedExactSearchItems.count > 0){
                            if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                                Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].rentalAvailability!)
                            }else{
                                Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                            }
                        }else{
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                            }else{
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                            }
                        }
                        
                        if(combinedExactSearchItems.count > 0){
                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil || combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil){
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].rentalAvailability!)
                            
                            if(combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability())  {
                               
                                
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                
                                
                            }
                            else if(combinedExactSearchItems[collectionView.tag].hasRentalAvailability()) {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                            }
                            else {
                              
                                  self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                               
                            }
                            
                        }else{
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }
                        }else{
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil){
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                                
                                if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()) {
                                    
                                    Constant.MyClassConstants.filterRelinquishments.removeAll()
                                    self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                                }
                                else {
                                    self.getFilterRelinquishments(selectedInventoryUnit: (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                }
                                
                            }else{
                                Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                            }
                        }
                    }else{
                        
                        if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                            Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                        }else{
                            Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }
                        
                        if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability != nil){
                            
                            if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability())  {
                                
                                
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                
                                
                            }
                            else if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()) {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                            }
                            else {
                                
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                                
                            }
                            
                       
                        }else{
                            self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                        }
                        
                    }
                }
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath){
        if (loadFirst){
            
            
            loadFirst = false
        }
    }
}
extension SearchResultViewController:UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 6.0, bottom: 5.0, right: 6.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView.tag == -1){
            if (Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)!{
                return CGSize(width: 110.0, height: 60.0)
            }else{
                return CGSize(width: 60.0, height: 60.0)
            }
        }else{
            if(indexPath.section == 0){
                return CGSize(width: UIScreen.main.bounds.width, height: 270.0)
            }else{
                return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
            }
        }
        
    }
}

extension SearchResultViewController:UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(collectionView.tag == -1){
            return 1
        }else{
            return 2
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView.tag == -1){
            return Constant.MyClassConstants.calendarDatesArray.count
        }else{
            if(section == 0){
                return 1
            }else{
                
                if(collectionView.superview?.superview?.tag == 0){
                    
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        
                         return (exactMatchResortsArrayExchange[collectionView.tag].inventory?.buckets.count)!
                    }
                    else if (Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        
                        if(exactMatchResortsArray.count > 0){
                            
                           return (exactMatchResortsArray[collectionView.tag].inventory?.units.count)!
                        }else{
                            
                            return (surroundingMatchResortsArray[collectionView.tag].inventory?.units.count)!
                        }
                        
                    }else{
                        
                        if(combinedExactSearchItems.count > 0){
                            
                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                            return (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                        }else{
                            return (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                        }
                        }else{
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                                return (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                            }else{
                                return (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                            }
                        }
                        
                    }
                   
                }else{
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        
                        return (surroundingMatchResortsArrayExchange[collectionView.tag].inventory?.buckets.count)!
                    }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        
                        return (surroundingMatchResortsArray[collectionView.tag].inventory?.units.count)!
                    }else{
                        if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                            return (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                        }else{
                            return (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                        }

                    }
                }
              
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView.tag == -1){
            
            if (Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)! {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.moreCell, for: indexPath) as! MoreCell
                if(Constant.MyClassConstants.calendarDatesArray[indexPath.item].isIntervalAvailable)!{
                    cell.isUserInteractionEnabled = true
                    cell.backgroundColor = UIColor.white
                }else{
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = UIColor.lightGray
                }
                cell.setDateForBucket(index: indexPath.item, selectedIndex: collectionviewSelectedIndex, color: dateCellSelectionColor)

                return cell
            }else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell, for: indexPath) as! SearchResultCollectionCell
                if((indexPath as NSIndexPath).row == collectionviewSelectedIndex) {
                    
                    if(dateCellSelectionColor == Constant.CommonColor.greenColor){
                        cell.backgroundColor = IUIKColorPalette.primary1.color
                    }else{
                        cell.backgroundColor = Constant.CommonColor.headerGreenColor
                    }
                    cell.dateLabel.textColor = UIColor.white
                    cell.daynameWithyearLabel.textColor = UIColor.white
                    cell.monthYearLabel.textColor = UIColor.white

                }
                else {
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
            
        }else{
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
                
                var inventoryItem = Resort()
                if(collectionView.superview?.superview?.tag == 0){
                    if(exactMatchResortsArray.count > 0){
                        inventoryItem = exactMatchResortsArray[collectionView.tag]
                    }else{
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                }else{
                    inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                }
                
                if(indexPath.section == 0){
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                    
                }else{
                    
                    let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.setDataForRentalInventory(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange {
                
                if(indexPath.section == 0){
                    
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0){
                        inventoryItem = exactMatchResortsArrayExchange[collectionView.tag].resort!
                    }else{
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                } else {
                    
                    var inventoryItem = ExchangeInventory()
                    if(collectionView.superview?.superview?.tag == 0){
                        inventoryItem = exactMatchResortsArrayExchange[collectionView.tag].inventory!
                    }else{
                        inventoryItem = surroundingMatchResortsArrayExchange[collectionView.tag].inventory!
                    }
                    
                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.setUpExchangeCell(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            }else{
                if(indexPath.section == 0){
                    
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count != 0){
                        if(combinedExactSearchItems[collectionView.tag].hasRentalAvailability()){
                            let rentalInventory = combinedExactSearchItems[collectionView.tag].rentalAvailability
                            inventoryItem = rentalInventory!
                        }else{
                            let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability
                            inventoryItem = (exchangeInventory?.resort)!
                        }
                        
                    }else{
                        if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()){
                            let rentalInventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                            inventoryItem = rentalInventory!
                        }else{
                            let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability
                            inventoryItem = (exchangeInventory?.resort)!
                        }
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                } else {
                    
                    if((collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count > 0 && combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability()) || (collectionView.superview?.superview?.tag == 1 && combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability())){
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as! SearchBothInventoryCVCell
                     
                        if(collectionView.superview?.superview?.tag == 0){
                            if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                                let inventory = combinedExactSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            }else{
                                let exchangeInventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort
                                cell.setDataForBothInventoryType(invetoryItem: exchangeInventory!, indexPath: indexPath)
                            }
                        }else{
                            
                            if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                                let inventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            }else{
                                let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort
                                cell.setDataForBothInventoryType(invetoryItem: exchangeInventory!, indexPath: indexPath)
                            }
                            
                        }
                        
                        return cell
                    }else if(collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count > 0){
                        if(combinedExactSearchItems[collectionView.tag].hasRentalAvailability()){
                            let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.setDataForRentalInventory( invetoryItem: combinedExactSearchItems[collectionView.tag].rentalAvailability!, indexPath: indexPath)
                            return cell
                        }else{
                            let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.setUpExchangeCell(invetoryItem: (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory)!, indexPath:indexPath)
                            return cell
                        }
                    }else {
                        if(combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability()){
                            let cell = self.getGetawayCollectionCell(indexPath: indexPath, collectionView: collectionView)
                            cell.setDataForRentalInventory( invetoryItem: combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!, indexPath: indexPath)
                            return cell
                        }else{
                            let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
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
        if(section == 0){
           return 20
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.searchResultTableView.frame.width, height: 20))
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.searchResultTableView.frame.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.searchResultTableView.frame.width - 60, height: 40))
        headerLabel.font = UIFont(name:Constant.fontName.helveticaNeue, size:15)
        let headerButton = UIButton(frame: CGRect(x: 20, y: 0, width: self.searchResultTableView.frame.width - 40, height: 40))
        headerButton.addTarget(self, action: #selector(SearchResultViewController.filterByNameButtonPressed(_:)), for: .touchUpInside)
        let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
        if(sectionsInSearchResult.count > 0){
                    for sections in sectionsInSearchResult{
                        if((sections.exactMatch == nil || sections.exactMatch == true) && section == 0){
                            headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                            headerView.backgroundColor = Constant.CommonColor.headerGreenColor
                            break
                        }else if((sections.exactMatch == nil || sections.exactMatch == false) && section == 1){
                            headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                            headerView.backgroundColor = IUIKColorPalette.primary1.color
                        }else{
                            headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                            headerView.backgroundColor = IUIKColorPalette.primary1.color
                        }
                    }
        }
        headerLabel.textColor = UIColor.white
        headerView.addSubview(headerLabel)
        
        let dropDownImgVw = UIImageView(frame: CGRect(x: self.searchResultTableView.frame.width - 40, y: 5, width: 30, height: 30))
        dropDownImgVw.image = UIImage(named: Constant.assetImageNames.dropArrow)
        headerView.addSubview(dropDownImgVw)
        headerView.addSubview(headerButton)
        return headerView
    }
}

extension SearchResultViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if(indexPath.section == 0){
            
            if indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                return 110
            }else{
                if Constant.MyClassConstants.isShowAvailability == true {
                    let index = indexPath.row - 1
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        if(self.exactMatchResortsArrayExchange.count > 0){
                            let totalUnits = self.exactMatchResortsArrayExchange[index].inventory?.buckets.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }else{
                            let totalUnits = self.surroundingMatchResortsArrayExchange[index].inventory?.buckets.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }
                        
                    }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        if(exactMatchResortsArray.count > 0){
                            let totalUnits = self.exactMatchResortsArray[index].inventory?.units.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }else{
                            let totalUnits = self.surroundingMatchResortsArray[index].inventory?.units.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }
                       
                    }else{
                        if(combinedExactSearchItems.count > 0){
                        if(combinedExactSearchItems[index].hasRentalAvailability()){
                            let rentalInventory = combinedExactSearchItems[index].rentalAvailability
                            let totalUnits = rentalInventory?.inventory?.units.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }else{
                            let exchangeInventory = combinedExactSearchItems[index].exchangeAvailability
                            let totalUnits = exchangeInventory?.inventory?.buckets.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }
                        }else{
                            if(combinedSurroundingSearchItems[index].hasRentalAvailability()){
                                let rentalInventory = combinedSurroundingSearchItems[index].rentalAvailability
                                let totalUnits = rentalInventory?.inventory?.units.count
                                return CGFloat(totalUnits!*80 + 270 + 10)
                            }else{
                                let exchangeInventory = combinedSurroundingSearchItems[index].exchangeAvailability
                                let totalUnits = exchangeInventory?.inventory?.buckets.count
                                return CGFloat(totalUnits!*80 + 270 + 10)
                            }
                        }
                    }
                }else {
                    
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        let totalUnits = self.exactMatchResortsArrayExchange[indexPath.row].inventory?.buckets.count
                        return CGFloat(totalUnits!*80 + 270 + 10)
                        
                    }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        if(exactMatchResortsArray.count > 0){
                            let totalUnits = self.exactMatchResortsArray[indexPath.row].inventory?.units.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }else{
                            let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }
                        
                        
                    }else{
                        if(combinedExactSearchItems.count > 0){
    
                        if(combinedExactSearchItems[indexPath.row].hasRentalAvailability()){
                            let rentalInventory = combinedExactSearchItems[indexPath.row].rentalAvailability
                            let totalUnits = rentalInventory?.inventory?.units.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }else{
                            let exchangeInventory = combinedExactSearchItems[indexPath.row].exchangeAvailability
                            let totalUnits = exchangeInventory?.inventory?.buckets.count
                            return CGFloat(totalUnits!*80 + 270 + 10)
                        }
                        }else{
                            
                            if(combinedSurroundingSearchItems[indexPath.row].hasRentalAvailability()){
                                let rentalInventory = combinedSurroundingSearchItems[indexPath.row].rentalAvailability
                                let totalUnits = rentalInventory?.inventory?.units.count
                                return CGFloat(totalUnits!*80 + 270 + 10)
                            }else{
                                let exchangeInventory = combinedSurroundingSearchItems[indexPath.row].exchangeAvailability
                                let totalUnits = exchangeInventory?.inventory?.buckets.count
                                return CGFloat(totalUnits!*80 + 270 + 10)
                            }
                        }
                    }
                }
            }
        }else{
            
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count
                return CGFloat(totalUnits!*80 + 270 + 10)
            }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                let totalUnits = self.surroundingMatchResortsArrayExchange[indexPath.row].inventory?.buckets.count
                return CGFloat(totalUnits!*80 + 270 + 10)
            }else{
                if(combinedSurroundingSearchItems[indexPath.row].rentalAvailability != nil){
                    let totalUnits = self.combinedSurroundingSearchItems[indexPath.row].rentalAvailability?.inventory?.units.count
                    return CGFloat(totalUnits!*80 + 270 + 10 )
                }else{
                    let totalUnits = self.combinedSurroundingSearchItems[indexPath.row].exchangeAvailability?.inventory?.buckets.count
                    return CGFloat(totalUnits!*80 + 270 + 10)
                }
            }
            
        }
    }
}

extension SearchResultViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func update(){
        
        self.searchResultTableView.reloadData()
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
            if indexPath.section == 0 && indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.novailabilityCell, for: indexPath)
                    cell.tag = indexPath.section
                
                    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector:#selector(runTimer), userInfo: nil, repeats: false)
               
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.availabilityCell, for: indexPath) as! SearchTableViewCell
                cell.tag = indexPath.section
                if (Constant.MyClassConstants.isShowAvailability == true && indexPath.section == 0){
                    
                    cell.resortInfoCollectionView.tag = indexPath.row - 1
                   
                } else {
                    cell.resortInfoCollectionView.tag = indexPath.row
                   
                }
                
                cell.resortInfoCollectionView.reloadData()
                cell.resortInfoCollectionView.isScrollEnabled = false
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
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
            
            if(section == 0 && exactMatchResortsArrayExchange.count == 0 || section == 1){
                if(exactMatchResortsArrayExchange.count == 0 && Constant.MyClassConstants.isShowAvailability == true){
                    return surroundingMatchResortsArrayExchange.count + 1
                }else{
                    return surroundingMatchResortsArrayExchange.count
                }
            }else{
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArrayExchange.count + 1
                    
                } else {
                    return exactMatchResortsArrayExchange.count
                }
            
            }
            
        }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
            if(section == 0 && exactMatchResortsArray.count == 0 || section == 1){
                if(exactMatchResortsArray.count == 0 && Constant.MyClassConstants.isShowAvailability == true){
                    return surroundingMatchResortsArray.count + 1
                }else{
                    return surroundingMatchResortsArray.count
                }
                
            }else{
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArray.count + 1
                    
                } else {
                    return exactMatchResortsArray.count
                }
            }
        }else{
            if(section == 0 && combinedExactSearchItems.count == 0 || section == 1){
                
                if(combinedExactSearchItems.count == 0 && Constant.MyClassConstants.isShowAvailability == true){
                    return combinedSurroundingSearchItems.count + 1
                }else{
                    return combinedSurroundingSearchItems.count
                }
               
            }else{
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return combinedExactSearchItems.count + 1
                    
                } else {
                    return combinedExactSearchItems.count
                }
            }
        }
    }
}

extension SearchResultViewController:SearchResultContentTableCellDelegate{
    func favoriteButtonClicked(_ sender: UIButton){
        
        if((UserContext.sharedInstance.accessToken) != nil) {
            
            if (sender.isSelected == false){
                
                SVProgressHUD.show()
                Helper.addServiceCallBackgroundView(view: self.view)
                UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                    
                   
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                    self.searchResultTableView.reloadData()
                    
                }, onError: {(error) in
                    
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    
                })
            }
            else {
                
                SVProgressHUD.show()
                Helper.addServiceCallBackgroundView(view: self.view)
                UserClient.removeFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                    
                    print(response)
                    sender.isSelected = false
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                    self.searchResultTableView.reloadData()
                    
                }, onError: {(error) in
                    
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                   
                })
                
            }
        }else{
            
            Constant.MyClassConstants.btnTag = sender.tag
            self.performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
        }
        
    }
    func unfavoriteButtonClicked(_ sender: UIButton){
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




extension SearchResultViewController:HelperDelegate {
    
    func resortSearchComplete(){
        
        Helper.hideProgressBar(senderView: self)
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        Helper.hideProgressBar(senderView: self)
        self.createSections()
        self.searchResultColelctionView.reloadData()
        self.searchResultTableView.reloadData()
        if(combinedExactSearchItems.isEmpty && combinedSurroundingSearchItems.isEmpty && exactMatchResortsArray.isEmpty && exactMatchResortsArrayExchange.isEmpty && surroundingMatchResortsArray.isEmpty && surroundingMatchResortsArrayExchange.isEmpty){
            let indexPath = IndexPath(row: 0, section: 0)
            searchResultTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func resetCalendar(){
        
    }

}

