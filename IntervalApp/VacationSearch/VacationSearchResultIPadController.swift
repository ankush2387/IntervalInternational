//
//  VacationSearchResultIPadController.swift
//  IntervalApp
//
//  Created by Chetu on 11/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage
import Realm
import RealmSwift
import SVProgressHUD

class VacationSearchResultIPadController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var searchedDateCollectionView: UICollectionView!
    @IBOutlet weak var resortDetailTBLView: UITableView!
    
    @IBOutlet weak var tabView: UIView!
    //***** Class variables *****//
    var unitSizeArray = [AnyObject]()
    var collectionviewSelectedIndex: Int = 0
    //var checkInDatesArray = Constant.MyClassConstants.checkInDates
    var loadFirst = true
    var enablePreviousMore = true
    var enableNextMore = true
    var alertView = UIView()
    let headerVw = UIView()
    let titleLabel = UILabel()
    var timer = Timer()
    var cellHeight = 80
    var selectedIndex = 0
    var selectedUnitIndex = 0
    var selectedSection = 0
    var selectedRow = 0
    var vacationSearch = VacationSearch()
    var exactMatchResortsArray = [Resort]()
    var surroundingMatchResortsArray = [Resort]()
    var exchangeExactMatchResortsArray = [ExchangeAvailability]()
    var exchangeSurroundingMatchResortsArray = [ExchangeAvailability]()
    var combinedExactSearchItems = [AvailabilitySectionItem]()
    var combinedSurroundingSearchItems = [AvailabilitySectionItem]()
    var dateCellSelectionColor = Constant.CommonColor.blueColor
    var myActivityIndicator = UIActivityIndicatorView()
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    var showInfoIcon = false
    var currencyCode = ""
    
    //Button events
    @IBAction func searchBothRentalClicked(_ sender: UIControl) {
    }
    
    @IBAction func searchBothExchangeClicked(_ sender: UIControl) {
    }
    
    // Function for header animation
    func runTimer() {
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            
            Constant.MyClassConstants.isShowAvailability = false
            self.resortDetailTBLView.reloadData()
        }, completion: nil)
        
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2745098039, green: 0.5333333333, blue: 0.7568627451, alpha: 1)

        if !Constant.MyClassConstants.resortsArray.isEmpty {
            let inventoryData = Constant.MyClassConstants.resortsArray[0].inventory
            if let code = inventoryData?.currencyCode {
                let currencyHelper = CurrencyHelper()
                let currency = currencyHelper.getCurrency(currencyCode: code)
                currencyCode = ("\(currencyHelper.getCurrencyFriendlySymbol(currencyCode: currency.code))")
            }
        }

        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchedDateCollectionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
        //create section
        createSections()
        searchedDateCollectionView.reloadData()
        resortDetailTBLView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    func createSections() {
        
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
        
        if sections.isEmpty {
            resortDetailTBLView.tableHeaderView = Helper.noResortView(senderView: self.view)
        } else {
            let headerVw = UIView()
            resortDetailTBLView.tableHeaderView = headerVw
        }
        
        exactMatchResortsArray.removeAll()
        exchangeExactMatchResortsArray.removeAll()
        surroundingMatchResortsArray.removeAll()
        exchangeSurroundingMatchResortsArray.removeAll()
        
        switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
        case VacationSearchType.EXCHANGE :
            for section in sections {
                if section.exactMatch == true {
                    dateCellSelectionColor = Constant.CommonColor.blueColor
                    // guard let items = section.items else { return }
                    for exactResorts in section.items {
                        if let exchangeAvailability = exactResorts.exchangeAvailability {
                            exchangeExactMatchResortsArray.append(exchangeAvailability)
                        }
                    }
                } else {
                    if sections.count == 1 {
                        dateCellSelectionColor = Constant.CommonColor.greenColor
                    }
                    // guard let items = section.items else { return }
                    for surroundingResorts in section.items {
                        if let resortsSurrounding = surroundingResorts.exchangeAvailability {
                            exchangeSurroundingMatchResortsArray.append(resortsSurrounding)
                        }
                    }
                }
            }

        case VacationSearchType.RENTAL :
            exactMatchResortsArray.removeAll()
            
            for section in sections {
                
                // guard let items = section.items else { return }
                if section.exactMatch == nil || section.exactMatch == true {
                    for exactResorts in section.items {
                        if let resortsExact = exactResorts.rentalAvailability {
                            exactMatchResortsArray.append(resortsExact)
                        }
                    }
                } else {
                    
                    for surroundingResorts in section.items {
                        if let resortsSurrounding = surroundingResorts.rentalAvailability {
                            surroundingMatchResortsArray.append(resortsSurrounding)
                        }
                    }
                }
            }
        default :
            for section in sections {
                if section.exactMatch == true {
                    combinedExactSearchItems = section.items
                } else {
                    combinedSurroundingSearchItems = section.items
                }
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        resortDetailTBLView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        //Adding back button on menu bar.
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(VacationSearchResultIPadController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = menuButton
        createSections()
        title = Constant.ControllerTitles.searchResultViewController
        
        if Constant.MyClassConstants.showAlert == true {
            
            alertView = Helper.noResortView(senderView: self.view)
            alertView.isHidden = false
            headerVw.isHidden = true
            view.bringSubview(toFront: self.alertView)
        } else {
            
            alertView.isHidden = true
            headerVw.isHidden = false
        }
        
        collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
        var index = 0
        for (Index, calendarItem) in Constant.MyClassConstants.calendarDatesArray.enumerated() where calendarItem.checkInDate == Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
            index = Index
            break
        }
        let indexpath = IndexPath(item: index, section: 0)
        searchedDateCollectionView.scrollToItem(at: indexpath, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func unwindToAvailabiity(_ segue: UIStoryboardSegue) {}
    // Function called to dismiss current controller when back button pressed.
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //**** Function for orientation change for iPad ****//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        resortDetailTBLView.reloadData()
        if alertView.isHidden == false {
            alertView.removeFromSuperview()
            alertView = Helper.noResortView(senderView: self.view)
            alertView.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Function for bucket click
    func intervalBucketClicked(calendarItem: CalendarItem, cell: UICollectionViewCell) {
        
        // FIXME (Frank): Fix issue with optional unwrapped
        // Resolve the next active interval based on the Calendar interval selected
        guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate!, intervalEndDate: calendarItem.intervalEndDate!) else { return }
        
        Helper.helperDelegate = self
        myActivityIndicator.hidesWhenStopped = true
        
        // Fetch CheckIn dates only in the active interval doesn't have CheckIn dates
        if !activeInterval.hasCheckInDates() {
            
            // Execute Search Dates
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                // Update CheckInFrom and CheckInTo dates
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                         onSuccess: { (response) in
                                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            self.hideHudAsync()
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            self.searchedDateCollectionView.reloadData()
                                            
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    }
                )
            } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                
                // Update CheckInFrom and CheckInTo dates
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                
                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
                                           onSuccess: { (response) in
                                            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            self.hideHudAsync()
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            self.searchedDateCollectionView.reloadData()
                                            
                },
                                           onError: { [weak self] error in
                                            self?.hideHudAsync()
                                            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    }
                )
                
            } else {
                
                // Update CheckInFrom and CheckInTo dates
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString: calendarItem.intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString: calendarItem.intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
                
                // Execute Rental Search Dates
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                         onSuccess: { (response) in
                                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                            
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            
                                            // Check not available checkIn dates for the active interval for Rental
                                            if !activeInterval.hasCheckInDates() {
                                                Constant.MyClassConstants.rentalHasNotAvailableCheckInDatesAfterSelectInterval = true
                                            }
                                            
                                            // Run Exchange Search Dates
                                            Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchedDateCollectionView, activeInterval: activeInterval)
                                            
                                            //expectation.fulfill()
                },
                                         onError: { (_) in
                                            // Run Exchange Search Dates
                                            Helper.executeExchangeSearchDatesAfterSelectInterval(senderVC: self, datesCV: self.searchedDateCollectionView, activeInterval: activeInterval)
                }
                )
                
            }
        } else {
            self.hideHudAsync()
            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
            searchedDateCollectionView.reloadData()
            myActivityIndicator.stopAnimating()
            cell.alpha = 1.0
        }
        
    }
    
    //*****Function for single date item press *****//
    func intervalDateItemClicked(_ toDate: Date) {
        searchedDateCollectionView.reloadData()
        guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
        Helper.helperDelegate = self
        
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
            showHudAsync()
            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self)
            
            
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
            showHudAsync()
            Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self)
        } else {
            showHudAsync()
            let request = RentalSearchResortsRequest()
            request.checkInDate = toDate
            request.resortCodes = activeInterval.resortCodes
            
            RentalClient.searchResorts(Session.sharedSession.userAccessToken, request: request,
                                       onSuccess: { (response) in
                                        // Update Rental inventory
                                        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.inventory = response.resorts
                                        
                                        // Run Exchange Search Dates
                                        Helper.executeExchangeSearchAvailabilityAfterSelectCheckInDate(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderVC: self)
                                        
            },
                                       onError: {[unowned self] (_) in
                                        self.hideHudAsync()
                                        self.presentErrorAlert(UserFacingCommonError.generic)
                }
            )
            
        }
    }
    
    //Function called when resort details button clicked.
    func resortDetailsClicked(_ toDate: Date) {
        
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        showHudAsync()
        Constant.MyClassConstants.resortsArray.removeAll()
        RentalClient.searchResorts(Session.sharedSession.userAccessToken, request: searchResortRequest, onSuccess: { (response) in
            self.hideHudAsync()
            Constant.MyClassConstants.resortsArray = response.resorts
            if self.alertView.isHidden == false {
                self.alertView.isHidden = true
                self.headerVw.isHidden = false
            }
            
            self.resortDetailTBLView.reloadData()
        }, onError: {[unowned self] (_) in
            self.resortDetailTBLView.reloadData()
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            self.headerVw.isHidden = true
            self.hideHudAsync()
        })
    }
    
    //Passing information while preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // function called when search result page map view button pressed
    @IBAction func mapViewButtonPressed(_ sender: Any) {
        Constant.MyClassConstants.isFromSearchResult = false
        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultMapSegue, sender: nil)
    }
    
    //funciton called when search result page sort by name button pressed
    @IBAction func sortByNameButtonPressed(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as? SortingViewController else { return }
        
        viewController.selectedSortingIndex = Constant.MyClassConstants.sortingIndex
        
        present(viewController, animated: true)
        
    }
    
    @IBAction func filterByNameButtonPressed(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as? SortingViewController else { return }
        viewController.isFilterClicked = true
        viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
        present(viewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let firstVisibleIndexPath = resortDetailTBLView.indexPathsForVisibleRows?.first
        let indexPath = IndexPath(item: collectionviewSelectedIndex, section: 0)
        if firstVisibleIndexPath?.section == 1 {
            dateCellSelectionColor = Constant.CommonColor.greenColor
        } else {
            dateCellSelectionColor = Constant.CommonColor.blueColor
        }
        
        if indexPath.row <= Constant.MyClassConstants.calendarDatesArray.count {
            searchedDateCollectionView.reloadItems(at: [indexPath])
        }
    }
    
}
// MARK: - Collection view FlowLayout Delegate
extension VacationSearchResultIPadController: UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == -1 {
            if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval {
                return CGSize(width: 160.0, height: 80.0)
            } else {
                return CGSize(width: 80.0, height: 80.0)
            }
        } else {
            if indexPath.section == 0 {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 410.0)
            } else {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 100.0)
            }
        }
    }
}

// MARK: - Collection View Delegate
extension VacationSearchResultIPadController: UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Collection view for calendar item. Top section collection view
        if collectionView.tag == -1 {
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                let viewForActivity = UIView()
                
                if cell.isKind(of: MoreCell.self) {
                    
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
                
                if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval == true {
                    showHudAsync()
                    intervalBucketClicked(calendarItem: Constant.MyClassConstants.calendarDatesArray[indexPath.item], cell: cell)
                } else {
                    
                    let lastSelectedIndex = collectionviewSelectedIndex
                    collectionviewSelectedIndex = indexPath.item
                    dateCellSelectionColor = Constant.CommonColor.blueColor
                    let lastIndexPath = IndexPath(item: lastSelectedIndex, section: 0)
                    let currentIndexPath = IndexPath(item: collectionviewSelectedIndex, section: 0)
                    searchedDateCollectionView.reloadItems(at: [lastIndexPath, currentIndexPath])
                    intervalDateItemClicked(Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[indexPath.item].checkInDate!, format: Constant.MyClassConstants.dateFormat))
                }
            }
            
        } else {
            
            //Collection for resorts
            //First section is for resort details
            
            if indexPath.section == 0 {
                // set isFrom Search true
                Constant.MyClassConstants.isFromSearchResult = true
                Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
                
                showHudAsync()
                var resortCode = ""
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                    
                    if collectionView.superview?.superview?.tag == 0 && !exactMatchResortsArray.isEmpty {
                        resortCode = exactMatchResortsArray[collectionView.tag].resortCode ?? ""
                    } else {
                        resortCode = surroundingMatchResortsArray[collectionView.tag].resortCode ?? ""
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    
                    if collectionView.superview?.superview?.tag == 0 && !exchangeExactMatchResortsArray.isEmpty {
                        resortCode = exchangeExactMatchResortsArray[indexPath.section].resort?.resortCode ?? ""
                    } else {
                        resortCode = exchangeSurroundingMatchResortsArray[indexPath.section].resort?.resortCode ?? ""
                    }
                    
                } else {
                    
                    if collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty {
                        if let combinedExactItems = combinedExactSearchItems[indexPath.section].rentalAvailability, let code = combinedExactItems.resortCode {
                            resortCode = code
                        } else {
                            if let code = combinedExactSearchItems[indexPath.section].exchangeAvailability?.resort?.resortCode {
                                resortCode = code
                            }
                        }
                        
                    } else {
                        
                        if let combinedSurroundings = combinedSurroundingSearchItems[indexPath.section].rentalAvailability, let code = combinedSurroundings.resortCode {
                            resortCode = code
                        } else {
                            if let code = combinedSurroundingSearchItems[indexPath.section].exchangeAvailability?.resort?.resortCode {
                                resortCode = code
                            }
                        }
                    }
                }
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { response in
                    
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
                    
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = indexPath.section + 1
                    self.hideHudAsync()
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.vacationSearchDetailSegue, sender: nil)
                }) { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                }
                
            } else {
                // it is used in renewal screen to change the title of header
                Constant.MyClassConstants.isChangeNoThanksButtonTitle = false
                //Second section for inventory items
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    if collectionView.superview?.superview?.tag == 0 && !exchangeExactMatchResortsArray.isEmpty {
                        
                        if let resort = exchangeExactMatchResortsArray[collectionView.tag].resort, let inventory = exchangeExactMatchResortsArray[collectionView.tag].inventory {
                            Constant.MyClassConstants.selectedResort = resort
                            
                            getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory, hasSearchAllAvailability: false)
                        }
                        
                    } else {
                        
                        if let resort = exchangeSurroundingMatchResortsArray[collectionView.tag].resort, let inventory = exchangeSurroundingMatchResortsArray[collectionView.tag].inventory {
                            Constant.MyClassConstants.selectedResort = resort
                            getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory, hasSearchAllAvailability: false)
                        }
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                    
                    showHudAsync()
                    
                    if collectionView.superview?.superview?.tag == 0 && !exactMatchResortsArray.isEmpty {
                        Constant.MyClassConstants.selectedResort = self.exactMatchResortsArray[collectionView.tag]
                    } else {
                        Constant.MyClassConstants.selectedResort = self.surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    if let inventory = Constant.MyClassConstants.selectedResort.inventory {
                        let units = inventory.units
                        
                        Constant.MyClassConstants.inventoryPrice = inventory.units[indexPath.item].prices
                        
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
                        
                        if let checkInDate = inventory.checkInDate,
                            let checkOutDate = inventory.checkOutDate,
                            let unitSize = units[indexPath.item].unitSize,
                            let kitchenType = units[indexPath.item].kitchenType {
                            
                            let processRequest = RentalProcessStartRequest(resortCode: Constant.MyClassConstants.selectedResort.resortCode, checkInDate: checkInDate, checkOutDate: checkOutDate, unitSize: UnitSize(rawValue: unitSize), kitchenType: KitchenType(rawValue: kitchenType))
                            
                            RentalProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
                                
                                let processResort = RentalProcess()
                                processResort.processId = response.processId
                                Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
                                Constant.MyClassConstants.processStartResponse = response
                                self.hideHudAsync()
                                if let responseView = response.view, let fees = response.view?.fees {
                                    Constant.MyClassConstants.viewResponse = responseView
                                    Constant.MyClassConstants.rentalFees = [fees]
                                }
                                
                                Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                                Constant.MyClassConstants.onsiteArray.removeAllObjects()
                                Constant.MyClassConstants.nearbyArray.removeAllObjects()
                                if let resortAmenities = response.view?.resort?.amenities {
                                    for amenity in resortAmenities {
                                        if let amenityName = amenity.amenityName {
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
                                    }
                                }
                                
                                UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
                                    Session.sharedSession.selectedMembership = membership
                                    
                                    // Got an access token!  Save it for later use.
                                    self.hideHudAsync()
                                    if let contacts = membership.contacts {
                                        Constant.MyClassConstants.membershipContactArray = contacts
                                    }
                                    
                                    // check force renewals here
                                    let forceRenewals = Constant.MyClassConstants.processStartResponse.view?.forceRenewals
                                    let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                                    if forceRenewals != nil {
                                        // Navigate to Renewals Screen
                                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                                        viewController.delegate = self
                                        self.present(viewController, animated: true)
                                    } else {
                                        // Navigate to Who Will Be Checking in Screen
                                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as? WhoWillBeCheckingInIPadViewController else { return }
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
                    }
                } else { // search both case
                    selectedSection = collectionView.superview?.superview?.tag ?? 0
                    selectedRow = collectionView.tag
                    Constant.MyClassConstants.selectedUnitIndex = indexPath.item
                    if collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty {
                        
                        if let combinedExchange = combinedExactSearchItems[collectionView.tag].exchangeAvailability {
                            if let resort = combinedExchange.resort {
                                Constant.MyClassConstants.selectedResort = resort
                            }
                            
                            if let bucket = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets[indexPath.row] {
                                if bucket.pointsCost != bucket.memberPointsRequired {
                                    showInfoIcon = true
                                }
                            }
                            
                        } else {
                            if let combinedRental = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                Constant.MyClassConstants.selectedResort = combinedRental
                            }
                        }
                        
                        if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil || combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil {
                            if let rentalAvailability = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                Constant.MyClassConstants.selectedResort = rentalAvailability
                            }
                            
                            if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability() {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory(), hasSearchAllAvailability: true)
                            } else if combinedExactSearchItems[collectionView.tag].hasRentalAvailability() {
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                            } else {
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                if let inventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory {
                                    getFilterRelinquishments(selectedInventoryUnit: Inventory(), selectedIndex: indexPath.item, selectedExchangeInventory: inventory, hasSearchAllAvailability: false)
                                }
                            }
                            
                        } else {
                            if let resort = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort {
                                Constant.MyClassConstants.selectedResort = resort
                            }
                        }
                    } else {
                        
                        if let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                            Constant.MyClassConstants.selectedResort = rentalAvailability
                        } else if let exchangeAvailabilityResort = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort {
                            Constant.MyClassConstants.selectedResort = exchangeAvailabilityResort
                        }
                        
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability != nil {
                            
                            if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability() {
                                
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                if let rentalInventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory {
                                    getFilterRelinquishments(selectedInventoryUnit: rentalInventory, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory(), hasSearchAllAvailability: true)
                                }
                                
                            } else if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() {
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                                
                            } else if let rentalInventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory {
                                Constant.MyClassConstants.filterRelinquishments.removeAll()
                                getFilterRelinquishments(selectedInventoryUnit: rentalInventory,
                                                         selectedIndex: indexPath.item,
                                                         selectedExchangeInventory: ExchangeInventory(),
                                                         hasSearchAllAvailability: false)
                            }
                            
                        } else {
                            self.navigateToWhatToUseViewController(hasSearchAllAvailability: false)
                        }
                    }
                }
            }
        }
    }
    
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
        
        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        
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
        processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        if let openWeek = Constant.MyClassConstants.filterRelinquishments[0].openWeek {
            processRequest.relinquishmentId = openWeek.relinquishmentId
        }
        
        if let pointsProgram = Constant.MyClassConstants.filterRelinquishments[0].pointsProgram {
            processRequest.relinquishmentId = pointsProgram.relinquishmentId
        }
        
        if let deposit = Constant.MyClassConstants.filterRelinquishments[0].deposit {
            processRequest.relinquishmentId = deposit.relinquishmentId
        }
        
        if let clubPoints = Constant.MyClassConstants.filterRelinquishments[0].clubPoints {
            processRequest.relinquishmentId = clubPoints.relinquishmentId
        }
        ExchangeProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { response in
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            if let exchangeView = response.view {
                Constant.MyClassConstants.exchangeViewResponse = exchangeView
            }
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            if let amenities = response.view?.destination?.resort?.amenities {
                for amenity in amenities {
                    if let amenityName = amenity.amenityName {
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
                }
            }
            UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
                Session.sharedSession.selectedMembership = membership
                
                // Got an access token!  Save it for later use.
                self.hideHudAsync()
                if let contacts = membership.contacts {
                    Constant.MyClassConstants.membershipContactArray = contacts
                }
                
                // check force renewals here
                if let forceRenewals = Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals {
                    
                    if forceRenewals != nil {
                        
                        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        
                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                        viewController.delegate = self
                        
                        viewController.forceRenewals = forceRenewals
                        self.present(viewController, animated: true)
                        return
                    }
                }
                
                let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as? WhoWillBeCheckingInIPadViewController else { return }
                viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[0]
                self.navigationController?.pushViewController(viewController, animated: true)
            }, onError: {[unowned self] error in
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
            
        }, onError: { [unowned self] error in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if loadFirst {
            loadFirst = false
        }
    }
}

// MARK: - Collection View Datasource
extension VacationSearchResultIPadController: UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == -1 {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == -1 {
            return Constant.MyClassConstants.calendarDatesArray.count
        } else {
            if section == 0 {
                return 1
            } else {
                if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                    if !exchangeExactMatchResortsArray.isEmpty {
                        return exchangeExactMatchResortsArray[collectionView.tag].inventory?.buckets.count ?? 0
                    } else {
                        return exchangeSurroundingMatchResortsArray[collectionView.tag].inventory?.buckets.count ?? 0
                    }
                    
                } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                    if !exactMatchResortsArray.isEmpty {
                        return exactMatchResortsArray[collectionView.tag].inventory?.units.count ?? 0
                    } else {
                        return surroundingMatchResortsArray[collectionView.tag].inventory?.units.count ?? 0
                    }
                    
                } else {
                    if !combinedExactSearchItems.isEmpty {
                        if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil {
                            return combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count ?? 0
                        } else {
                            return combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count ?? 0
                        }
                    } else {
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil {
                            return  combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count ?? 0
                        } else {
                            return  combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count ?? 0
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.layer.borderWidth = 0.5
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        
        if collectionView.tag == -1 {
            if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval == true {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.moreCell, for: indexPath) as! MoreCell
                if Constant.MyClassConstants.calendarDatesArray[indexPath.item].isIntervalAvailable == true {
                    cell.isUserInteractionEnabled = true
                    cell.backgroundColor = UIColor.white
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = UIColor(red: 233 / 255, green: 233 / 255, blue: 235 / 255, alpha: 1)
                }
                cell.setDateForBucket(index: indexPath.item, selectedIndex: collectionviewSelectedIndex, color: dateCellSelectionColor)
                return cell
            } else {
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell, for: indexPath) as? SearchResultCollectionCell else { return UICollectionViewCell() }
                if indexPath.item == collectionviewSelectedIndex {
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
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.RENTAL {
                
                var inventoryItem = Resort()
                if collectionView.superview?.superview?.tag == 0 && !exactMatchResortsArray.isEmpty {
                    inventoryItem = exactMatchResortsArray[collectionView.tag]
                } else {
                    inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                }
                
                if indexPath.section == 0 {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? AvailabilityCollectionViewCell else { return UICollectionViewCell() }
                    cell.setResortDetails(inventoryItem: inventoryItem)
                    return cell
                    
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RentalInventory", for: indexPath) as? RentalInventoryCVCell else { return UICollectionViewCell() }
                    cell.setDataForRentalInventory(invetoryItem: inventoryItem, indexPath: indexPath, code: currencyCode)
                    return cell
                }
            } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.EXCHANGE {
                
                if indexPath.section == 0 {
                    
                    var inventoryItem = Resort()
                    if collectionView.superview?.superview?.tag == 0 && !exchangeExactMatchResortsArray.isEmpty {
                        if let resort = exchangeExactMatchResortsArray[collectionView.tag].resort {
                            inventoryItem = resort
                        }
                    } else {
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as? AvailabilityCollectionViewCell else { return UICollectionViewCell() }
                    cell.setResortDetails(inventoryItem: inventoryItem)
                    return cell
                } else {
                    
                    var inventoryItem = ExchangeInventory()
                    if collectionView.superview?.superview?.tag == 0 && !exchangeExactMatchResortsArray.isEmpty {
                        if let inventory = exchangeExactMatchResortsArray[collectionView.tag].inventory {
                            inventoryItem = inventory
                        }
                    } else {
                        if let inventory = exchangeSurroundingMatchResortsArray[collectionView.tag].inventory {
                            inventoryItem = inventory
                        }
                    }
                    
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.exchangeInventoryCell, for: indexPath) as? ExchangeInventoryCVCell else { return UICollectionViewCell() }
                    cell.exchangeCellDelegate = self
                    cell.setUpExchangeCell(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            } else {
                
                if indexPath.section == 0 {
                    
                    var inventoryItem = Resort()
                    if collectionView.superview?.superview?.tag == 0 && !combinedExactSearchItems.isEmpty {
                        if combinedExactSearchItems[collectionView.tag].rentalAvailability != nil {
                            if let rentalInventory = combinedExactSearchItems[collectionView.tag].rentalAvailability {
                                inventoryItem = rentalInventory
                            }
                        } else {
                            if let exchangeResort = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.resort {
                                inventoryItem = exchangeResort
                            }
                        }
                    } else {
                        if combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil {
                            if let rentalResort = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {
                                inventoryItem = rentalResort
                            }
                        } else {
                            if let exchangeResort = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort {
                                inventoryItem = exchangeResort
                            }
                        }
                    }
                    
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as? AvailabilityCollectionViewCell else { return UICollectionViewCell() }
                    cell.setResortDetails(inventoryItem: inventoryItem)
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
                            
                            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RentalInventory", for: indexPath) as? RentalInventoryCVCell else { return UICollectionViewCell() }
                            if let rentalAvailability = combinedExactSearchItems[collectionView.tag].rentalAvailability {

                                cell.setDataForRentalInventory( invetoryItem: rentalAvailability, indexPath: indexPath, code: currencyCode)
                            }

                            return cell
                            
                        } else {
                            
                            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExchangeInventory", for: indexPath) as? ExchangeInventoryCVCell else { return UICollectionViewCell() }
                            cell.exchangeCellDelegate = self
                            if let inventory = combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory {
                                cell.setUpExchangeCell(invetoryItem: inventory, indexPath: indexPath)
                            }
                            return cell
                        }
                        
                    } else {
                        
                        if combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() {
                            
                            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortInventoryCell, for: indexPath) as? RentalInventoryCVCell else { return UICollectionViewCell() }
                            if let rentalAvailability = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability {

                                cell.setDataForRentalInventory( invetoryItem: rentalAvailability, indexPath: indexPath, code: currencyCode)
                            }
                             return cell

                            
                        } else {
                            
                            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExchangeInventory", for: indexPath) as? ExchangeInventoryCVCell else { return UICollectionViewCell() }
                            cell.exchangeCellDelegate = self
                            if let inventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.inventory {
                                cell.setUpExchangeCell(invetoryItem: inventory, indexPath: indexPath)
                            }
                            return cell
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Table View Delegate
extension VacationSearchResultIPadController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let heightForBaseView = 410 + 10 + 40
        let collectionviewCellInventoryHeight = 110.0
        if indexPath.section == 0 {
            
            if indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                return 110
                
            } else {
                
                if Constant.MyClassConstants.isShowAvailability == true {
                    let index = indexPath.row - 1
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        if !exchangeExactMatchResortsArray.isEmpty {
                            if let totalUnits = self.exchangeExactMatchResortsArray[index].inventory?.buckets.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                            return 0
                        } else {
                            if let totalUnits = self.exchangeSurroundingMatchResortsArray[index].inventory?.buckets.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                            return 0
                        }
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        
                        if !exactMatchResortsArray.isEmpty {
                            if let totalUnits = self.exactMatchResortsArray[index].inventory?.units.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                            return 0
                        } else {
                            if let totalUnits = self.surroundingMatchResortsArray[index].inventory?.units.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                            return 0
                        }
                        
                    } else {
                        if !combinedExactSearchItems.isEmpty {
                            if combinedExactSearchItems[index].hasRentalAvailability() {
                                
                                let rentalInventory = combinedExactSearchItems[index].rentalAvailability
                                if let totalUnits = rentalInventory?.inventory?.units.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                                
                            } else {
                                
                                let exchangeInventory = combinedExactSearchItems[index].exchangeAvailability
                                if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                                    return CGFloat(totalUnits*100 + heightForBaseView)
                                }
                            }
                            return 0
                        } else {
                            if combinedSurroundingSearchItems[index].hasRentalAvailability() {
                                
                                let rentalInventory = combinedSurroundingSearchItems[index].rentalAvailability
                                if let totalUnits = rentalInventory?.inventory?.units.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                            } else {
                                
                                let exchangeInventory = combinedSurroundingSearchItems[index].exchangeAvailability
                                if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                            }
                            return 0
                        }
                    }
                    
                } else {
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        
                        if !exchangeExactMatchResortsArray.isEmpty {
                            if let totalUnits = self.exchangeExactMatchResortsArray[indexPath.row].inventory?.buckets.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                        } else {
                            if let totalUnits = self.exchangeSurroundingMatchResortsArray[indexPath.row].inventory?.buckets.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                        }
                        return 0
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        
                        if !exactMatchResortsArray.isEmpty {
                            if let totalUnits = self.exactMatchResortsArray[indexPath.row].inventory?.units.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                            
                        } else {
                            if let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count {
                                return CGFloat(totalUnits * 110 + heightForBaseView)
                            }
                        }
                        return 0
                        
                    } else {
                        
                        if !combinedExactSearchItems.isEmpty {
                            
                            if combinedExactSearchItems[indexPath.row].hasRentalAvailability() {
                                
                                let rentalInventory = combinedExactSearchItems[indexPath.row].rentalAvailability
                                if let totalUnits = rentalInventory?.inventory?.units.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                                
                            } else {
                                
                                let exchangeInventory = combinedExactSearchItems[indexPath.row].exchangeAvailability
                                if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                            }
                            return 0
                            
                        } else {
                            if combinedSurroundingSearchItems[indexPath.row].hasRentalAvailability() {
                                
                                let rentalInventory = combinedSurroundingSearchItems[indexPath.row].rentalAvailability
                                if let totalUnits = rentalInventory?.inventory?.units.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                                
                            } else {
                                
                                let exchangeInventory = combinedSurroundingSearchItems[indexPath.row].exchangeAvailability
                                if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                                    return CGFloat(totalUnits * 110 + heightForBaseView)
                                }
                            }
                        }
                        return 0
                    }
                }
            }
            
        } else {
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.COMBINED {
                
                if combinedSurroundingSearchItems[indexPath.row].hasRentalAvailability() {
                    
                    let rentalInventory = combinedSurroundingSearchItems[indexPath.row].rentalAvailability
                    if let totalUnits = rentalInventory?.inventory?.units.count {
                        return CGFloat(totalUnits * 110 + heightForBaseView)
                    }
                    
                } else {
                    
                    let exchangeInventory = combinedSurroundingSearchItems[indexPath.row].exchangeAvailability
                    if let totalUnits = exchangeInventory?.inventory?.buckets.count {
                        return CGFloat(totalUnits * 110 + heightForBaseView)
                    }
                }
            } else {
                
                if let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count {
                    return CGFloat(totalUnits * 110 + heightForBaseView)
                }
            }
            return 0
        }
    }
}

// MARK: - Table View Datasource
extension VacationSearchResultIPadController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
        
        if indexPath.row == 0 && indexPath.section == 0 && Constant.MyClassConstants.isShowAvailability == true {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.novailabilityCell, for: indexPath)
            cell.tag = indexPath.section
            var deletedRowIndexPath = indexPath
            deletedRowIndexPath.row = 0
            deletedRowIndexPath.section = 0
            
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimer), userInfo: nil, repeats: false)
            return cell
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.availabilityCell, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
            cell.resortInfoCollectionView.reloadData()
            
            cell.tag = indexPath.section
            
            if Constant.MyClassConstants.isShowAvailability == true {
                
                cell.resortInfoCollectionView.tag = indexPath.row - 1
                
            } else {
                
                cell.resortInfoCollectionView.tag = indexPath.row
            }
            
            cell.resortInfoCollectionView.isScrollEnabled = false
            cell.selectionStyle = .none
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
            if section == 0 && exchangeExactMatchResortsArray.count == 0 || section == 1 {
                return exchangeSurroundingMatchResortsArray.count
            } else {
                
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exchangeExactMatchResortsArray.count + 1
                    
                } else {
                    
                    return exchangeExactMatchResortsArray.count
                }
                
            }
        } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
            if section == 0 && exactMatchResortsArray.count == 0 || section == 1 {
                return surroundingMatchResortsArray.count
            } else {
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArray.count + 1
                    
                } else {
                    return exactMatchResortsArray.count
                }
                
            }
        } else {
            
            if section == 0 && combinedExactSearchItems.count == 0 || section == 1 {
                return combinedSurroundingSearchItems.count
            } else {
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return combinedExactSearchItems.count + 1
                    
                } else {
                    return combinedExactSearchItems.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.resortDetailTBLView.frame.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.resortDetailTBLView.frame.width - 60, height: 40))
        headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
        let headerButton = UIButton(frame: CGRect(x: 20, y: 0, width: self.resortDetailTBLView.frame.width - 40, height: 40))
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
        
        let dropDownImgVw = UIImageView(frame: CGRect(x: self.resortDetailTBLView.frame.width - 40, y: 5, width: 30, height: 30))
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

// MARK: - Implementing custom delegate method definition
extension VacationSearchIPadViewController: ImageWithNameCellDelegate {
    
    func favratePressedAtIndex(_ Index: Int) {
        
    }
    
}

//Mark:- Extension for Helper
extension VacationSearchResultIPadController: HelperDelegate {
    
    func resortSearchComplete() {
        self.hideHudAsync()
        exchangeExactMatchResortsArray.removeAll()
        exchangeSurroundingMatchResortsArray.removeAll()
        exactMatchResortsArray.removeAll()
        exchangeExactMatchResortsArray.removeAll()
        self.createSections()
        self.searchedDateCollectionView.reloadData()
        self.resortDetailTBLView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        resortDetailTBLView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func resetCalendar() {
    }
}

// MARK: - Implementing RenewelViewControllerDelegate definition
extension VacationSearchResultIPadController: RenewelViewControllerDelegate {
    
    func dismissWhatToUse(renewalArray: [Renewal]) {
        self.dismiss(animated: false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInIPadViewController") as? WhoWillBeCheckingInIPadViewController else { return }
        viewController.renewalsArray = renewalArray
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RenewalOtherOptionsVC") as? RenewalOtherOptionsVC else { return }
        viewController.delegate = self
        
        viewController.forceRenewals = forceRenewals
        self.present(viewController, animated: true, completion: nil)
        return
        
    }
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalArray: [Renewal]) {
        self.dismiss(animated: false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInIPadViewController") as? WhoWillBeCheckingInIPadViewController else { return }
        viewController.renewalsArray = renewalArray
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func noThanks() {
        self.dismiss(animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInIPadViewController") as? WhoWillBeCheckingInIPadViewController else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

//Mark:- Other Options Delegate
extension VacationSearchResultIPadController: RenewalOtherOptionsVCDelegate {
    func selectedRenewal(selectedRenewal: String, forceRenewals: ForceRenewals) {
        var renewalArray = [Renewal]()
        renewalArray.removeAll()
        if selectedRenewal == Helper.renewalType(type: 0) {
            // Selected core renewal
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products {
                if renewal.term == lowestTerm {
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalArray.append(renewalItem)
                    break
                }
            }
        } else if selectedRenewal == Helper.renewalType(type: 2) {
            // Selected combo renewal
            
            for comboProduct in (forceRenewals.comboProducts) {
                let lowestTerm = comboProduct.renewalComboProducts[0].term
                for renewalComboProduct in comboProduct.renewalComboProducts where renewalComboProduct.term == lowestTerm {
                    let renewalItem = Renewal()
                    renewalItem.id = renewalComboProduct.id
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
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInIPadViewController") as? WhoWillBeCheckingInIPadViewController else { return }
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        viewController.isFromRenewals = true
        viewController.renewalsArray = renewalArray
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension VacationSearchResultIPadController: WhoWillBeCheckInDelegate {
    func navigateToWhoWillBeCheckIn(renewalArray: [Renewal], selectedRow: Int) {
        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInIPadViewController") as? WhoWillBeCheckingInIPadViewController else { return }
        viewController.renewalsArray = renewalArray
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension VacationSearchResultIPadController: ExchangeInventoryCVCellDelegate {
    func infoIconPressed() {
        self.performSegue(withIdentifier: "pointsInfoSegue", sender: self)
    }
}
