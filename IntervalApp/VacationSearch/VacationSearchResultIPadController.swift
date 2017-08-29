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

class VacationSearchResultIPadController: UIViewController, sortingOptionDelegate {
    
    //***** Outlets *****//
    @IBOutlet weak var searchedDateCollectionView: UICollectionView!
    @IBOutlet weak var resortDetailTBLView: UITableView!
    
    @IBOutlet weak var tabView: UIView!
    //***** Class variables *****//
    var unitSizeArray = [AnyObject]()
    var collectionviewSelectedIndex:Int = 0
    //var checkInDatesArray = Constant.MyClassConstants.checkInDates
    var loadFirst = true
    var enablePreviousMore = true
    var enableNextMore = true
    var alertView = UIView()
    let headerVw = UIView()
    let titleLabel = UILabel()
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
    
    //Button events
    @IBAction func searchBothRentalClicked(_ sender: UIControl) {
    }
    
    @IBAction func searchBothExchangeClicked(_ sender: UIControl) {
    }
    
    // sorting optionDelegate call
    
    func selectedOptionis(filteredValueIs:String, indexPath:NSIndexPath, isFromFiltered:Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 70.0/255.0, green: 136.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        print(Constant.MyClassConstants.calendarDatesArray.count)
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        print(Constant.MyClassConstants.calendarDatesArray.count)
        
        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchedDateCollectionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
        //create section
        self.createSections()
        self.searchedDateCollectionView.reloadData()
        self.resortDetailTBLView.reloadData()
        
    }
    
    func createSections(){
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
        
        if(sections.count == 0){
            resortDetailTBLView.tableHeaderView = Helper.noResortView(senderView: self.view)
        }else{
            let headerVw = UIView()
            resortDetailTBLView.tableHeaderView = headerVw
        }
        
        exactMatchResortsArray.removeAll()
        exchangeExactMatchResortsArray.removeAll()
        surroundingMatchResortsArray.removeAll()
        exchangeSurroundingMatchResortsArray.removeAll()
        
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Exchange){
            if(sections.count > 0){
                for section in sections{
                    
                    if(section.exactMatch == nil || section.exactMatch == true){
                        for exactResorts in (section.items)!{
                            if(exactResorts.exchangeAvailability != nil){
                                let resortsExact = exactResorts.exchangeAvailability
                                exchangeExactMatchResortsArray.append(resortsExact!)
                            }
                        }
                    }
                }
                
                if(sections.count > 1){
                    for section in sections{
                        if(section.exactMatch == nil || section.exactMatch == false){
                            for surroundingResorts in (section.items)!{
                                if(surroundingResorts.exchangeAvailability != nil){
                                    let resortsSurrounding = surroundingResorts.exchangeAvailability
                                    exchangeSurroundingMatchResortsArray.append(resortsSurrounding!)
                                }
                            }
                        }
                    }
                }
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
                print(section.items?.count)
                if(section.exactMatch == nil || section.exactMatch == true){
                   combinedExactSearchItems = section.items!
                }else{
                   combinedSurroundingSearchItems = section.items!
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        resortDetailTBLView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        //Adding back button on menu bar.
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(VacationSearchResultIPadController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        self.createSections()
        self.title = Constant.ControllerTitles.searchResultViewController
        
        //self.searchedDateCollectionView.reloadData()
        
        if (Constant.MyClassConstants.showAlert == true) {
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            self.headerVw.isHidden = true
            self.view.bringSubview(toFront: self.alertView)
        }else{
            self.alertView.isHidden = true
            self.headerVw.isHidden = false
        }
        
        self.collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
    }
    
    
    // Function called to dismiss current controller when back button pressed.
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //**** Function for orientation change for iPad ****//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.resortDetailTBLView.reloadData()
        if(alertView.isHidden == false){
            self.alertView.removeFromSuperview()
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: $$ Common Methods $$
    
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
    
    // Mark: Function for bucket click

    func intervalBucketClicked(calendarItem:CalendarItem!, cell:UICollectionViewCell){
        Helper.hideProgressBar(senderView: self)
        Helper.helperDelegate = self
        
            myActivityIndicator.hidesWhenStopped = true
        
            // Resolve the next active interval based on the Calendar interval selected
            let activeInterval = Constant.MyClassConstants.initialVacationSearch.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate, intervalEndDate: calendarItem.intervalEndDate)
        
            
            //Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
            
            // Fetch CheckIn dates only in the active interval doesn't have CheckIn dates
            if (activeInterval != nil && !(activeInterval?.hasCheckInDates())!) {
                
                // Execute Search Dates
                if (Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()) {
                    // Update CheckInFrom and CheckInTo dates
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString:calendarItem.intervalStartDate!,format:Constant.MyClassConstants.dateFormat)
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString:calendarItem.intervalEndDate!,format:Constant.MyClassConstants.dateFormat)
                
                    RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                             onSuccess: { (response) in
                                                
                                                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                                //let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                                // Update active interval
                                                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                                
                                                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                
                                                //expectation.fulfill()
                                                
                                                // Check not available checkIn dates for the active interval
                                                if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                                    //self.showNotAvailabilityResults()
                                                    
                                                } else {
                                                    //let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.getCheckInDateForInitialSearch()
                                                    
                                                    //Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self , vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                    
                                                   //Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:response.checkInDates[0], senderViewController: self , vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                }
                                                Constant.MyClassConstants.calendarDatesArray.removeAll()
                                                
                                                Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
                                                
                                                self.searchedDateCollectionView.reloadData()
                                                
                    },
                                             onError:{ (error) in
                                                
                                                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                                                DarwinSDK.logger.error("Error Code: \(error.code)")
                                                DarwinSDK.logger.error("Error Description: \(error.description)")
                                                
                                                // TODO: Handle SDK/API errors
                                                DarwinSDK.logger.error("Handle SDK/API errors.")
                                                
                                                //expectation.fulfill()
                    }
                    )
                }else{
                    // Update CheckInFrom and CheckInTo dates
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInFromDate = Helper.convertStringToDate(dateString:calendarItem.intervalStartDate!,format:Constant.MyClassConstants.dateFormat)
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.checkInToDate = Helper.convertStringToDate(dateString:calendarItem.intervalEndDate!,format:Constant.MyClassConstants.dateFormat)
                    //Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    
                    ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request,
                                             onSuccess: { (response) in
                                                
                                                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                               // let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                                // Update active interval
                                                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                                
                                                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                
                                                //expectation.fulfill()
                                                
                                                // Check not available checkIn dates for the active interval
                                                if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                                    //self.showNotAvailabilityResults()
                                                    
                                                } else {
                                                    //let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.getCheckInDateForInitialSearch()
                                                    
                                                    //Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self , vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                    
                                                    //Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:response.checkInDates[0], senderViewController: self , vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                                }
                                                Constant.MyClassConstants.calendarDatesArray.removeAll()
                                                
                                                Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
                                                
                                                self.searchedDateCollectionView.reloadData()
                                                
                    },
                                             onError:{ (error) in
                                                
                                                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                                               
                                                //expectation.fulfill()
                    }
                    )
                    
                    
                }
            }else {
                if(activeInterval != nil){
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                }
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                self.searchedDateCollectionView.reloadData()
                myActivityIndicator.stopAnimating()
                cell.alpha = 1.0
            
        }
            
    }
    
    //*****Function for single date item press *****//
    func intervalDateItemClicked(_ toDate: Date){
        let activeInterval = BookingWindowInterval(interval: Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval())
        Helper.helperDelegate = self
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        }else{
            Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        }
    }
    
    //Function called when show resort details clicked.
    func getResortFromResortCode(_ toDate: Date) {
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
            Constant.MyClassConstants.resortsArray = response.resorts
            self.resortDetailTBLView.reloadData()
        }, onError: { (error) in
            
        })
        
    }
    
    //Function called when resort details button clicked.
    func resortDetailsClicked(_ toDate: Date){
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        Helper.showProgressBar(senderView: self)
        Constant.MyClassConstants.resortsArray.removeAll()
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
            Helper.hideProgressBar(senderView: self)
            Constant.MyClassConstants.resortsArray = response.resorts
            if(self.alertView.isHidden == false){
                self.alertView.isHidden = true
                self.headerVw.isHidden = false
            }
            self.resortDetailTBLView.reloadData()
        }, onError: { (error) in
            self.resortDetailTBLView.reloadData()
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            self.headerVw.isHidden = true
            Helper.hideProgressBar(senderView: self)
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
    
    //funciton called when search result page sort by name button pressed
    @IBAction func sortByNameButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        
        let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        
        viewController.delegate = self
        viewController.selectedSortingIndex = Constant.MyClassConstants.sortingIndex
        
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    @IBAction func filterByNameButtonPressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        
        let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        viewController.delegate = self
        viewController.isFilterClicked = true
        
        //viewController.resortNameArray = Constant.MyClassConstants.resortsArray
        viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
        self.present(viewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let firstVisibleIndexPath = resortDetailTBLView.indexPathsForVisibleRows?.first
        let indexPath = IndexPath(item: collectionviewSelectedIndex, section: 0)
        print("---------->>>>\(collectionviewSelectedIndex)")
        if(firstVisibleIndexPath?.section == 1){
            dateCellSelectionColor = Constant.CommonColor.greenColor
        }else{
            dateCellSelectionColor = Constant.CommonColor.blueColor
        }
        
        if(indexPath.row <= Constant.MyClassConstants.calendarDatesArray.count){
           // searchedDateCollectionView.reloadItems(at: [indexPath])
        }
    }
    
}

//Function to check whether more button should be enabled or disabled.
func enableDisablePreviousMoreButtoniPad(_ position : String) -> Bool {
    
    let currentDate = Date()
    var order = (Calendar.current as NSCalendar).compare(Constant.MyClassConstants.currentFromDate as Date, to: currentDate,toUnitGranularity: .hour)
    if (position.isEqual(Constant.MyClassConstants.right)) {
        let nextDate =  (Calendar.current as NSCalendar).date(byAdding: .month, value: +24, to: Constant.MyClassConstants.currentFromDate as Date, options: [])!
        order = (Calendar.current as NSCalendar).compare(currentDate, to: nextDate,toUnitGranularity: .hour)
    }
    
    switch order {
    case .orderedDescending:
        if (position == Constant.MyClassConstants.right) {
            return false
        }else{
            return true
        }
    case .orderedAscending:
        if (position == Constant.MyClassConstants.right) {
            return true
        }
        else {
            return false
        }
    case .orderedSame:
        return false
    }
}

//Extension for Collection View
extension VacationSearchResultIPadController:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    //Collection view for calendar item. Top section collection view
    if(collectionView.tag == -1){
            
        let cell = collectionView.cellForItem(at: indexPath)
        let viewForActivity = UIView()
            
        if(cell?.isKind(of:MoreCell.self))!{
            
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
        if(Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)!{
            
            Helper.showProgressBar(senderView: self)
            intervalBucketClicked(calendarItem:Constant.MyClassConstants.calendarDatesArray[indexPath.item], cell: cell!)
            
        }else{
            let lastSelectedIndex = collectionviewSelectedIndex
            collectionviewSelectedIndex = indexPath.item
            dateCellSelectionColor = Constant.CommonColor.blueColor
            let lastIndexPath = IndexPath(item: lastSelectedIndex, section: 0)
            let currentIndexPath = IndexPath(item: collectionviewSelectedIndex, section: 0)
            searchedDateCollectionView.reloadItems(at: [lastIndexPath, currentIndexPath])
            intervalDateItemClicked(Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[indexPath.item].checkInDate!, format: Constant.MyClassConstants.dateFormat))
        }
        } else{
        
            //Collection for resorts
            //First section is for resort details
            
        if((indexPath as NSIndexPath).section == 0) {
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            var resortCode = ""
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                
                if(collectionView.superview?.superview?.tag == 0){
                    resortCode = exactMatchResortsArray[collectionView.tag].resortCode!
                }else{
                    resortCode = surroundingMatchResortsArray[collectionView.tag].resortCode!
                }
                
            }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                
                if(collectionView.superview?.superview?.tag == 0){
                    resortCode = (self.exchangeExactMatchResortsArray[indexPath.section].resort?.resortCode!)!
                }else{
                    resortCode = (self.exchangeSurroundingMatchResortsArray[indexPath.section].resort?.resortCode!)!
                }
            }else{
                if(collectionView.superview?.superview?.tag == 0){
                    if(combinedExactSearchItems[indexPath.section].rentalAvailability != nil){
                        resortCode = (combinedExactSearchItems[indexPath.section].rentalAvailability!.resortCode!)
                }else{
                resortCode = (combinedExactSearchItems[indexPath.section].exchangeAvailability?.resort?.resortCode!)!
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
            Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = indexPath.section + 1
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
            
            //Second section for inventory items
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                selectedSection = (collectionView.superview?.superview?.tag)!
                selectedRow = collectionView.tag
                if(collectionView.superview?.superview?.tag == 0){
                    Constant.MyClassConstants.selectedResort = self.exchangeExactMatchResortsArray[collectionView.tag].resort!
                    self.getFilterRelinquishments(selectedInventoryUnit:Inventory(), selectedIndex:indexPath.item, selectedExchangeInventory: self.exchangeExactMatchResortsArray[collectionView.tag].inventory!)
                }else{
                    Constant.MyClassConstants.selectedResort = self.exchangeSurroundingMatchResortsArray[collectionView.tag].resort!
                    self.getFilterRelinquishments(selectedInventoryUnit:Inventory(), selectedIndex:indexPath.item, selectedExchangeInventory: self.exchangeSurroundingMatchResortsArray[collectionView.tag].inventory!)
                }
                    
            }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()
                
                if(collectionView.superview?.superview?.tag == 0){
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
                        

                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].rentalAvailability!)
                        }else{
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }

                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil || combinedExactSearchItems[collectionView.tag].exchangeAvailability != nil){
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].rentalAvailability!)
                            self.getFilterRelinquishments(selectedInventoryUnit: (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                        }else{
                            Constant.MyClassConstants.selectedResort = (combinedExactSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }
                    }else{
                        
                        if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                            Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability!)
                        }else{
                            Constant.MyClassConstants.selectedResort = (combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability!.resort)!
                        }
                        
                        if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil || combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability != nil){
                            self.getFilterRelinquishments(selectedInventoryUnit: (combinedSurroundingSearchItems[collectionView.tag].rentalAvailability?.inventory!)!, selectedIndex: indexPath.item, selectedExchangeInventory: ExchangeInventory())
                        }else{
                            self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                        }

                    }
                }
            }
        }
    }
    
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
            /*if(self.selectedSection == 0){
             Constant.MyClassConstants.selectedResort = self.exactMatchResortsArray[self.selectedSection]
             Constant.MyClassConstants.inventoryPrice = (self.exactMatchResortsArray[self.selectedRow].inventory?.units[0].prices)!
             }else{
             Constant.MyClassConstants.selectedResort = self.surroundingMatchResortsArray[self.selectedRow]
             Constant.MyClassConstants.inventoryPrice = (self.surroundingMatchResortsArray[self.selectedRow].inventory?.units[0].prices)!
             }*/
            
            
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Combined){
                self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
            }else{
                if(Constant.MyClassConstants.filterRelinquishments.count > 1){
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                }else if(response[0].destination?.upgradeCost != nil){
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
        processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.relinquishmentId
        
        ExchangeProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: {(response) in
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            Constant.MyClassConstants.exchangeViewResponse = response.view!
            //Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            //cell?.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
            
            
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (loadFirst){
            let indexPath = IndexPath(row: Constant.MyClassConstants.searchResultCollectionViewScrollToIndex , section: 0)
            
            //self.searchedDateCollectionView.scrollToItem(at: indexPath,at: .centeredHorizontally,animated: true)
            //self.searchedDateCollectionView.contentOffset = CGPoint(x: 100, y: 0.0)
            loadFirst = false
        }
    }
}
extension VacationSearchResultIPadController:UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView.tag == -1){
            if (Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)!{
                return CGSize(width: 160.0, height: 80.0)
            }else{
                return CGSize(width: 80.0, height: 80.0)
            }
        }else{
            if(indexPath.section == 0){
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 320.0)
            }else{
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 80.0)
            }
        }
    }
}

extension VacationSearchResultIPadController:UICollectionViewDataSource {
    
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
                        return (exchangeExactMatchResortsArray[collectionView.tag].inventory?.buckets.count)!
                    }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        return (exactMatchResortsArray[collectionView.tag].inventory?.units.count)!
                    }else{
                        if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                            return (combinedExactSearchItems[collectionView.tag].rentalAvailability?.inventory?.units.count)!
                        }else{
                            return (combinedExactSearchItems[collectionView.tag].exchangeAvailability?.inventory?.buckets.count)!
                        }
                    }
                }else{
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        return (exchangeSurroundingMatchResortsArray[collectionView.tag].inventory?.buckets.count)!
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
        collectionView.layer.borderWidth = 0.5
        collectionView.layer.borderColor = UIColor.lightGray.cgColor

        if(collectionView.tag == -1){
            if (Constant.MyClassConstants.calendarDatesArray[indexPath.item].isInterval)! {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.moreCell, for: indexPath) as! MoreCell
                if(Constant.MyClassConstants.calendarDatesArray[indexPath.item].isIntervalAvailable)!{
                    cell.isUserInteractionEnabled = true
                    cell.backgroundColor = UIColor.white
                }else{
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 235/255, alpha: 1)
                }
                cell.setDateForBucket(index: indexPath.item, selectedIndex: collectionviewSelectedIndex, color: dateCellSelectionColor)
                return cell
            }else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell, for: indexPath) as! SearchResultCollectionCell
                if(indexPath.item == collectionviewSelectedIndex) {
                    if(dateCellSelectionColor == Constant.CommonColor.greenColor){
                        cell.backgroundColor = Constant.CommonColor.headerGreenColor
                    }else{
                        cell.backgroundColor = IUIKColorPalette.primary1.color
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
        }else {
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Rental {
                
                var inventoryItem = Resort()
                if(collectionView.superview?.superview?.tag == 0){
                    inventoryItem = exactMatchResortsArray[collectionView.tag]
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
                        inventoryItem = exchangeExactMatchResortsArray[collectionView.tag].resort!
                    }else{
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    
                    let cell = self.getResortInfoCollectionCell(indexPath: indexPath, collectionView: collectionView, resort: inventoryItem)
                    return cell
                } else {
                    
                    var inventoryItem = ExchangeInventory()
                    if(collectionView.superview?.superview?.tag == 0){
                        inventoryItem = exchangeExactMatchResortsArray[collectionView.tag].inventory!
                    }else{
                        inventoryItem = exchangeSurroundingMatchResortsArray[collectionView.tag].inventory!
                    }
                    
                    let cell = self.getExchangeCollectionCell(indexPath: indexPath, collectionView: collectionView)
                    cell.setUpExchangeCell(invetoryItem: inventoryItem, indexPath: indexPath)
                    return cell
                }
            }else{
                
                if(indexPath.section == 0){
                    
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0){
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
                    
                    if((collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems[collectionView.tag].hasRentalAvailability() && combinedExactSearchItems[collectionView.tag].hasExchangeAvailability()) || (collectionView.superview?.superview?.tag == 1 && combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability())){
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as! SearchBothInventoryCVCell
                        
                        if(collectionView.superview?.superview?.tag == 0){
                            if(combinedExactSearchItems[collectionView.tag].rentalAvailability != nil){
                                let inventory = combinedExactSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            }else{
                                let inventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            }
                        }else{
                            
                            //if(combinedSurroundingSearchItems[collectionView.tag].rentalAvailability != nil){
                                let inventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                                cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                            /*}else{
                                let exchangeInventory = combinedSurroundingSearchItems[collectionView.tag].exchangeAvailability?.resort
                                cell.setDataForBothInventoryType(invetoryItem: exchangeInventory!, indexPath: indexPath)
                            }*/

                        }
                        
                        return cell
                    }else if(collectionView.superview?.superview?.tag == 0 && combinedExactSearchItems.count == 0 && combinedSurroundingSearchItems[collectionView.tag].hasRentalAvailability() && combinedSurroundingSearchItems[collectionView.tag].hasExchangeAvailability()){
                        
                        
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.searchBothInventoryCell, for: indexPath) as! SearchBothInventoryCVCell
                        let inventory = combinedSurroundingSearchItems[collectionView.tag].rentalAvailability
                        cell.setDataForBothInventoryType(invetoryItem: inventory!, indexPath: indexPath)
                        
                        
                        return cell
                        
                        
                        
                    }else if(collectionView.superview?.superview?.tag == 0){
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
}


//Extension for table view.
extension VacationSearchResultIPadController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0){
            
            if indexPath.row == 0 && Constant.MyClassConstants.isShowAvailability == true {
                return 110
                
            } else {
                
                if Constant.MyClassConstants.isShowAvailability == true {
                    let index = indexPath.row - 1
                    
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        let totalUnits = self.exchangeExactMatchResortsArray[index].inventory?.buckets.count
                        return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                        
                    }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        let totalUnits = self.exactMatchResortsArray[index].inventory?.units.count
                        return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                        
                    }else{
                        if(combinedExactSearchItems[index].hasRentalAvailability()){
                            
                            let rentalInventory = combinedExactSearchItems[index].rentalAvailability
                            
                            let totalUnits = rentalInventory?.inventory?.units.count
                            return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                            
                        }else{
                            
                            let exchangeInventory = combinedExactSearchItems[index].exchangeAvailability
                            
                            let totalUnits = exchangeInventory?.inventory?.buckets.count
                            
                            return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                        }
                    }
                    
                } else {
                    
                    if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                        
                        let totalUnits = self.exchangeExactMatchResortsArray[indexPath.row].inventory?.buckets.count
                        return CGFloat(totalUnits!*100 + 320 + 10 + 25)

                    }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                        
                        let totalUnits = self.exactMatchResortsArray[indexPath.row].inventory?.units.count
                        
                        return CGFloat(totalUnits!*100 + 320 + 10 + 25)

                    }else{
                        
                        if(combinedExactSearchItems[indexPath.row].hasRentalAvailability()){
                            
                            let rentalInventory = combinedExactSearchItems[indexPath.row].rentalAvailability
                            
                            let totalUnits = rentalInventory?.inventory?.units.count
                            
                            return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                            
                        }else{
                            
                            let exchangeInventory = combinedExactSearchItems[indexPath.row].exchangeAvailability
                            
                            let totalUnits = exchangeInventory?.inventory?.buckets.count
                            
                            return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                        }
                    }
                    
                }
            }
        }else{
            
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Combined){
                
                if(combinedSurroundingSearchItems[indexPath.row].hasRentalAvailability()){
                    
                    let rentalInventory = combinedSurroundingSearchItems[indexPath.row].rentalAvailability
                    
                    let totalUnits = rentalInventory?.inventory?.units.count
                    
                    return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                }else{
                    
                    let exchangeInventory = combinedSurroundingSearchItems[indexPath.row].exchangeAvailability
                    
                    let totalUnits = exchangeInventory?.inventory?.buckets.count
                    
                    return CGFloat(totalUnits!*100 + 320 + 10 + 25)
                }
            }else{
                
                let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count
                
                return CGFloat(totalUnits!*100 + 320 + 10 + 25)
            }
        }
    }
}

extension VacationSearchResultIPadController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
            
            if indexPath.row == 0 && indexPath.section == 0 && Constant.MyClassConstants.isShowAvailability == true {

                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.novailabilityCell, for: indexPath)
                cell.tag = indexPath.section
                var deletedRowIndexPath = indexPath
                deletedRowIndexPath.row = 0
                deletedRowIndexPath.section = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    
                    UIView.animate(withDuration: 5, delay: 2, options: UIViewAnimationOptions(rawValue: 0), animations: {
                        
                        Constant.MyClassConstants.isShowAvailability = false
                        //cell.contentView.frame.size.height = 50.0
                        self.resortDetailTBLView.reloadData()
                    }, completion: nil)
                })
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.availabilityCell, for: indexPath) as! SearchTableViewCell
                    cell.resortInfoCollectionView.reloadData()
                
                cell.tag = indexPath.section
                

                if Constant.MyClassConstants.isShowAvailability == true {

                    cell.resortInfoCollectionView.tag = indexPath.row - 1
                    
                } else {
                    
                    cell.resortInfoCollectionView.tag = indexPath.row
                }
                
                cell.resortInfoCollectionView.isScrollEnabled = false
                cell.selectionStyle = .none
//                cell.layer.borderWidth = 0.5
//                cell.layer.borderColor = UIColor.lightGray.cgColor
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
            if(section == 0 && exchangeExactMatchResortsArray.count == 0 || section == 1){
                return exchangeSurroundingMatchResortsArray.count
            }else{
                
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exchangeExactMatchResortsArray.count + 1
                    
                } else {
                    
                    return exchangeExactMatchResortsArray.count
                }
                
            }
        }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
            if(section == 0 && exactMatchResortsArray.count == 0 || section == 1){
                return surroundingMatchResortsArray.count
            }else{
                if Constant.MyClassConstants.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArray.count + 1
                    
                } else {
                    return exactMatchResortsArray.count
                }
                
            }
        }else{
            
            if(section == 0 && combinedExactSearchItems.count == 0 || section == 1){
                return combinedSurroundingSearchItems.count
            }else{
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
        headerLabel.font = UIFont(name:Constant.fontName.helveticaNeue, size:15)
        let headerButton = UIButton(frame: CGRect(x: 20, y: 0, width: self.resortDetailTBLView.frame.width - 40, height: 40))
        headerButton.addTarget(self, action: #selector(SearchResultViewController.filterByNameButtonPressed(_:)), for: .touchUpInside)
        let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
        if(sectionsInSearchResult.count > 0){
            for sections in sectionsInSearchResult{
                if((sections.exactMatch == nil || sections.exactMatch == true) && section == 0){
                    headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    headerView.backgroundColor = IUIKColorPalette.primary1.color
                    //break
                }else if ((sections.exactMatch == nil || sections.exactMatch == false) && section == 1){
                    headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    headerView.backgroundColor = Constant.CommonColor.headerGreenColor
                }
            }
        }
        headerLabel.textColor = UIColor.white
        headerView.addSubview(headerLabel)
        
        let dropDownImgVw = UIImageView(frame: CGRect(x: self.resortDetailTBLView.frame.width - 40, y: 5, width: 30, height: 30))
        dropDownImgVw.image = UIImage(named: Constant.assetImageNames.dropArrow)
        headerView.addSubview(dropDownImgVw)
        headerView.addSubview(headerButton)
        return headerView
    }
    
    /*func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.resortDetailTBLView.frame.width, height: 20))
        footerView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
        
        footerView.backgroundColor = UIColor.red
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        /*if(section == Constant.MyClassConstants.resortsArray.count){
            return 30
        }*/
        return 30
    }*/
}

// Implementing custom delegate method definition
extension VacationSearchIPadViewController:ImageWithNameCellDelegate {
    
    func favratePressedAtIndex(_ Index:Int) {
        
    }
    
}

//Mark: Extension for Helper
extension VacationSearchResultIPadController:HelperDelegate {
    func resortSearchComplete(){
        print(Constant.MyClassConstants.calendarDatesArray.count)
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        print(Constant.MyClassConstants.calendarDatesArray.count)
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        print(Constant.MyClassConstants.calendarDatesArray.count)
        Helper.hideProgressBar(senderView: self)
        exchangeExactMatchResortsArray.removeAll()
        exchangeSurroundingMatchResortsArray.removeAll()
        exactMatchResortsArray.removeAll()
        exchangeExactMatchResortsArray.removeAll()
        self.createSections()
        self.searchedDateCollectionView.reloadData()
        self.resortDetailTBLView.reloadData()
    }
    
    
    
    func resetCalendar(){
    }
}

