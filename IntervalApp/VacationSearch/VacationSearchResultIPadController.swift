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
    var isShowAvailability = true
    var alertView = UIView()
    let headerVw = UIView()
    let titleLabel = UILabel()
    var cellHeight = 80
    var selectedIndex = 0
    var selectedUnitIndex = 0
    var selectedSection = 0
    var selectedRow = 0
    var exactMatchResortsArray = [Resort]()
    var surroundingMatchResortsArray = [Resort]()
    var exchangeExactMatchResortsArray = [ExchangeAvailability]()
    var dateCellSelectionColor = Constant.CommonColor.blueColor
    var myActivityIndicator = UIActivityIndicatorView()
    

    // sorting optionDelegate call
    
    func selectedOptionis(filteredValueIs:String, indexPath:NSIndexPath, isFromFiltered:Bool) {
        
       let selectedvalue = Helper.returnFilteredValue(filteredValue: filteredValueIs)
        
        if isFromFiltered {
            Constant.MyClassConstants.filteredIndex = indexPath.row
            
            switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
            case .Destination(let destination):
                let areaOfInfluenceDestination = AreaOfInfluenceDestination()
                areaOfInfluenceDestination.destinationName = destination.destinationName
                areaOfInfluenceDestination.destinationId = destination.destinationId
                areaOfInfluenceDestination.aoiId = destination.aoid
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.destinations = [areaOfInfluenceDestination]
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.resorts.removeAll()
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            case .Resort(let resort):
                let resorts = Resort()
                resorts.resortName = resort.resortName
                resorts.resortCode = resort.resortCode
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.resorts =  [resorts]
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.destinations.removeAll()
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName
            
            case .ResortList(let resortList):
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.resorts.removeAll()
                for resorts in resortList{
                    let resort = Resort()
                    resort.resortName = resorts.resortName
                    resort.resortCode = resorts.resortCode
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.resorts.append(resort)
                }
                
            }
            
            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
            
            
            RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                
                // Check not available checkIn dates for the active interval
                if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    
                //Helper.showNotAvailabilityResults()
                }
                
                let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.getCheckInDateForInitialSearch()
                Constant.MyClassConstants.checkInDates = response.checkInDates
                Helper.helperDelegate = self
                Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                self.dismiss(animated: true, completion: nil)
                
            })
            { (error) in
                
                SVProgressHUD.dismiss()
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
                self.resortDetailTBLView.reloadData()
            }

        } else {
            Constant.MyClassConstants.sortingIndex = indexPath.row
            
            
            let vacationSearchForSorting = Constant.MyClassConstants.initialVacationSearch
            
            vacationSearchForSorting.sortType = AvailabilitySortType(rawValue: selectedvalue)!
            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: vacationSearchForSorting.bookingWindow.currentInterval)
            Constant.MyClassConstants.isFromSorting = true
            self.dismiss(animated: true, completion: nil)
            self.resortDetailTBLView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 70.0/255.0, green: 136.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        print(Constant.MyClassConstants.calendarDatesArray.count)
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
        print(Constant.MyClassConstants.calendarDatesArray.count)
        
        
    }
    
    func createSections(){
        let sections = Constant.MyClassConstants.initialVacationSearch.createSections()
            if Constant.MyClassConstants.isFromExchange {
                if(sections.count > 0) {
                    let resortsExact = sections[0].item?.exchangeInventory
                    exchangeExactMatchResortsArray = resortsExact!
                    if(sections.count > 1){
                        let resortsSurrounding = sections[1].item?.rentalInventory
                        surroundingMatchResortsArray = resortsSurrounding!
                    }
                }
           
            } else {
                let resortsExact = sections[0].item?.rentalInventory
                exactMatchResortsArray = resortsExact!
                if(sections.count > 1){
                    let resortsSurrounding = sections[1].item?.rentalInventory
                    surroundingMatchResortsArray = resortsSurrounding!
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
        
        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchedDateCollectionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
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
    
    // Mark: Function for bucket click

    func intervalBucketClicked(calendarItem:CalendarItem!, cell:UICollectionViewCell){
        Helper.hideProgressBar(senderView: self)
        Helper.helperDelegate = self
        
            myActivityIndicator.hidesWhenStopped = true
            // Resolve the next active interval based on the Calendar interval selected
            let activeInterval = Constant.MyClassConstants.initialVacationSearch.resolveNextActiveIntervalFor(intervalStartDate: calendarItem.intervalStartDate, intervalEndDate: calendarItem.intervalEndDate)
            
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
                                                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
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
                    }
            }else {

                myActivityIndicator.stopAnimating()
                cell.alpha = 1.0
            
        }
            
    }
    
    //*****Function for single date item press *****//
    func intervalDateItemClicked(_ toDate: Date){
        let activeInterval = BookingWindowInterval(interval: Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval())
        Helper.helperDelegate = self
        Helper.showProgressBar(senderView: self)
        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: toDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
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
        if(firstVisibleIndexPath?.section == 1){
            dateCellSelectionColor = Constant.CommonColor.greenColor
        }else{
            dateCellSelectionColor = Constant.CommonColor.blueColor
        }
        
        if(indexPath.row <= Constant.MyClassConstants.calendarDatesArray.count){
            searchedDateCollectionView.reloadItems(at: [indexPath])
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
        }
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
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 100.0)
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
                    if(Constant.MyClassConstants.isFromExchange){
                        return (exchangeExactMatchResortsArray[collectionView.tag].inventory?.buckets.count)!
                    }else{
                        return (exactMatchResortsArray[collectionView.tag].inventory?.units.count)!
                    }
                    
                }else{
                    return (surroundingMatchResortsArray[collectionView.tag].inventory?.units.count)!
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
        }else{
            
            if !Constant.MyClassConstants.isFromExchange {
                if(indexPath.section == 0){
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as! AvailabilityCollectionViewCell
                    for layer in cell.viewGradient.layer.sublayers!{
                        if(layer.isKind(of: CAGradientLayer.self)) {
                            layer.removeFromSuperlayer()
                        }
                    }
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0){
                        inventoryItem = exactMatchResortsArray[collectionView.tag]
                    }else{
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    var url = URL(string: "")
                    for imgStr in inventoryItem.images {
                        if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                            url = URL(string: imgStr.url!)!
                            break
                        }
                    }
                    Helper.addLinearGradientToView(view: cell.viewGradient, colour: UIColor.white, transparntToOpaque: true, vertical: false)
                    cell.resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                    cell.resortName.text = inventoryItem.resortName
                    cell.resortAddress.text = inventoryItem.address?.cityName
                    cell.resortCode.text = inventoryItem.resortCode
                    let tierImageName = Helper.getTierImageName(tier: inventoryItem.tier!.uppercased())
                    cell.tierImage.image = UIImage(named: tierImageName)
                    DarwinSDK.logger.info("\(String(describing: Helper.resolveResortInfo(resort: inventoryItem)))")
                    return cell
                }else{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortInventoryCell, for: indexPath) as! RentalInventoryCVCell
                    var invetoryItem = Resort()
                    print(invetoryItem)
                    if(collectionView.superview?.superview?.tag == 0){
                        invetoryItem = exactMatchResortsArray[collectionView.tag]
                    }else{
                        invetoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    // for unit in (invetoryItem.inventory?.units)! {
                    let unit = (invetoryItem.inventory?.units[indexPath.item])!
                    DarwinSDK.logger.info("\(String(describing: Helper.resolveUnitInfo(unit: unit)))")
                    
                    // price
                    let price = Int(unit.prices[0].price)
                    cell.getawayPrice.text = String(price)
                    
                    // bedroom details
                    
                    var bedRoomDetails = ""
                    if let bedType = unit.unitSize {
                        bedRoomDetails.append(" \(String(describing: Helper.getBrEnums(brType: bedType)))")
                    }
                    
                    cell.bedRoomType.text = bedRoomDetails
                    
                    var kitchenDetails = ""
                    if let kitchenType = unit.kitchenType {
                        kitchenDetails.append(" \(String(describing: Helper.getKitchenEnums(kitchenType: kitchenType)))")
                    }
                    
                    cell.kitchenType.text = kitchenDetails
                    
                    var totalSleepCapacity = String()
                    
                    if unit.publicSleepCapacity > 0 {
                        
                        totalSleepCapacity =  String(unit.publicSleepCapacity) + Constant.CommonLocalisedString.totalString
                        
                    }
                    
                    if unit.privateSleepCapacity > 0 {
                        
                        cell.sleeps.text =  totalSleepCapacity + String(unit.privateSleepCapacity) + Constant.CommonLocalisedString.privateString
                        
                    }
                    
                    
                    let promotions = invetoryItem.inventory?.units[indexPath.item].promotions
                    if (promotions?.count)! > 0 {
                        for view in cell.promotionsView.subviews {
                            view.removeFromSuperview()
                        }
                        
                        cellHeight = 55 + (14*(promotions?.count)!)
                        var yPosition: CGFloat = 0
                        for promotion in promotions! {
                            let imgV = UIImageView(frame: CGRect(x:10, y: yPosition, width: 15, height: 15))
                            imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
                            let promLabel = UILabel(frame: CGRect(x:30, y: yPosition, width: cell.promotionsView.bounds.width, height: 15))
                            promLabel.text = promotion.offerName
                            promLabel.adjustsFontSizeToFitWidth = true
                            promLabel.minimumScaleFactor = 0.7
                            promLabel.numberOfLines = 0
                            promLabel.textColor = UIColor(red: 0, green: 119/255, blue: 190/255, alpha: 1)
                            promLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 18)
                            cell.promotionsView.addSubview(imgV)
                            cell.promotionsView.addSubview(promLabel)
                            yPosition += 15
                        }
                    }
                    
                    return cell
                }
            } else {
                
                if(indexPath.section == 0){
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as! AvailabilityCollectionViewCell
                    for layer in cell.viewGradient.layer.sublayers!{
                        if(layer.isKind(of: CAGradientLayer.self)) {
                            layer.removeFromSuperlayer()
                        }
                    }
                    var inventoryItem = Resort()
                    if(collectionView.superview?.superview?.tag == 0){
                        inventoryItem = exchangeExactMatchResortsArray[collectionView.tag].resort!
                    }else{
                        inventoryItem = surroundingMatchResortsArray[collectionView.tag]
                    }
                    var url = URL(string: "")
                    for imgStr in inventoryItem.images {
                        if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                            url = URL(string: imgStr.url!)!
                            break
                        }
                    }
                    Helper.addLinearGradientToView(view: cell.viewGradient, colour: UIColor.white, transparntToOpaque: true, vertical: false)
                    cell.resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                    cell.resortName.text = inventoryItem.resortName
                    cell.resortAddress.text = inventoryItem.address?.cityName
                    cell.resortCode.text = inventoryItem.resortCode
                    let tierImageName = Helper.getTierImageName(tier: inventoryItem.tier!.uppercased())
                    cell.tierImage.image = UIImage(named: tierImageName)
                    DarwinSDK.logger.info("\(String(describing: Helper.resolveResortInfo(resort: inventoryItem)))")
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reUsableIdentifiers.resortDetailCell, for: indexPath) as! AvailabilityCollectionViewCell
                    
                    return cell
                    
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
            if indexPath.row == 0 && self.isShowAvailability == true {
                return 110
            } else {
                if self.isShowAvailability == true {
                    let index = indexPath.row - 1
                    if(Constant.MyClassConstants.isFromExchange){
                        let totalUnits = self.exchangeExactMatchResortsArray[index].inventory?.buckets.count
                        return CGFloat(totalUnits!*110 + 320 + cellHeight)
                    }else{
                        let totalUnits = self.exactMatchResortsArray[index].inventory?.units.count
                        return CGFloat(totalUnits!*110 + 320 + cellHeight)
                    }
                    
                } else {
                    
                    if(Constant.MyClassConstants.isFromExchange){
                        let totalUnits = self.exchangeExactMatchResortsArray[indexPath.row].inventory?.buckets.count
                        return CGFloat(totalUnits!*110 + 320 + cellHeight)

                    }else{
                        let totalUnits = self.exactMatchResortsArray[indexPath.row].inventory?.units.count
                        return CGFloat(totalUnits!*110 + 320 + cellHeight)

                    }
                    
                }
            }
        }else{
            let totalUnits = self.surroundingMatchResortsArray[indexPath.row].inventory?.units.count
            return CGFloat(totalUnits!*110 + 320)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectedIndex = indexPath.section
        //selectedUnitIndex = indexPath.row
        selectedSection = indexPath.section
        selectedRow = indexPath.row
        Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[indexPath.section]
        if((indexPath as NSIndexPath).row == 0) {
            
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: Constant.MyClassConstants.resortsArray[indexPath.section].resortCode!, onSuccess: { (response) in
                
                Constant.MyClassConstants.resortsDescriptionArray = response
                Constant.MyClassConstants.imagesArray.removeAllObjects()
                let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                for imgStr in imagesArray {
                    if(imgStr.size == Constant.MyClassConstants.imageSize) {
                        
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
            
            if(Constant.MyClassConstants.isFromExchange){
                Helper.showProgressBar(senderView: self)
                let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
                exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
                
                exchangeSearchDateRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as! [String]
                
                let exchangeDestination = ExchangeDestination()
                let currentFromDate = Helper.convertDateToString(date: Constant.MyClassConstants.currentFromDate, format: Constant.MyClassConstants.dateFormat)
                
                let currentToDate = Helper.convertDateToString(date: Constant.MyClassConstants.currentToDate, format: Constant.MyClassConstants.dateFormat)
                
                let resort = Resort()
                resort.resortCode = Constant.MyClassConstants.resortsArray[selectedSection].resortCode
                
                exchangeDestination.resort = resort
                
                let unit = InventoryUnit()
                unit.kitchenType = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow-1].unit!.kitchenType!
                unit.unitSize = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow-1].unit!.unitSize!
                exchangeDestination.checkInDate = currentFromDate
                exchangeDestination.checkOutDate = currentToDate
                unit.publicSleepCapacity = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow-1].unit!.publicSleepCapacity
                unit.privateSleepCapacity = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow-1].unit!.privateSleepCapacity
                
                exchangeDestination.unit = unit
                
                exchangeSearchDateRequest.destination = exchangeDestination
                Constant.MyClassConstants.exchangeDestination = exchangeDestination
                
                ExchangeClient.filterRelinquishments(UserContext.sharedInstance.accessToken, request: exchangeSearchDateRequest, onSuccess: { (response) in
                    Helper.hideProgressBar(senderView: self)
                    Constant.MyClassConstants.filterRelinquishments.removeAll()
                    for exchageDetail in response{
                        Constant.MyClassConstants.filterRelinquishments.append(exchageDetail.relinquishment!)
                    }
                    
                    Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[self.selectedSection]
                    
                    Constant.MyClassConstants.inventoryPrice = (Constant.MyClassConstants.exchangeInventory[self.selectedSection].buckets[self.selectedRow - 1].unit?.prices)!
                    // if(Constant.MyClassConstants.whatToTradeArray.count > 1 || String(describing: response[0].destination?.upgradeCost?.amount) != "0"){
                    self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                    // }else {
                    // self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
                    //}
                    
                }, onError: { (error) in
                    
                    
                    Helper.hideProgressBar(senderView: self)
                })
                
            }
            else{
                
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()
                
                Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[indexPath.section]
                
                var inventoryDict = Inventory()
                inventoryDict = Constant.MyClassConstants.resortsArray[indexPath.section].inventory!
                let invent = inventoryDict
                let units = invent.units
                
                Constant.MyClassConstants.inventoryPrice = invent.units[indexPath.row - 1].prices
                
                let processResort = RentalProcess()
                processResort.holdUnitStartTimeInMillis = Constant.holdingTime
                
                let processRequest = RentalProcessStartRequest()
                processRequest.resort = Constant.MyClassConstants.resortsArray[0]
                print(Constant.MyClassConstants.resortsArray[0].additionalCharges)
                if(Constant.MyClassConstants.resortsArray[0].allInclusive){
                    Constant.MyClassConstants.hasAdditionalCharges = true
                }else{
                    Constant.MyClassConstants.hasAdditionalCharges = false
                }
                processRequest.unit = units[0]
                
                let processRequest1 = RentalProcessStartRequest.init(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate, unitSize: UnitSize(rawValue: units[0].unitSize!)!, kitchenType: KitchenType(rawValue: units[0].kitchenType!)!)
                
                //API call for start process
                RentalProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
                    
                    let processResort = RentalProcess()
                    processResort.processId = response.processId
                    print(response.processId)
                    Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
                    
                    
                    Constant.MyClassConstants.processStartResponse = response
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    Constant.MyClassConstants.viewResponse = response.view!
                    Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                    Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
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
                    
                    //API call for get membership current.
                    UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                        
                        // Got an access token!  Save it for later use.
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        Constant.MyClassConstants.membershipContactArray = Membership.contacts!
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as! WhoWillBeCheckingInIPadViewController
                        
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
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
                })
                
            }
        }
    }
}

extension VacationSearchResultIPadController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
        if(!Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.isFromExchange) {
            
            if indexPath.row == 0 && indexPath.section == 0 && self.isShowAvailability == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.novailabilityCell, for: indexPath)
                var deletedRowIndexPath = indexPath
                deletedRowIndexPath.row = 0
                deletedRowIndexPath.section = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    
                    UIView.animate(withDuration: 5, delay: 2, options: UIViewAnimationOptions(rawValue: 0), animations: {
                        
                        self.isShowAvailability = false
                        //cell.contentView.frame.size.height = 50.0
                        self.resortDetailTBLView.reloadData()
                    }, completion: nil)
                })
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.availabilityCell, for: indexPath) as! SearchTableViewCell
                cell.tag = indexPath.section
                cell.resortInfoCollectionView.reloadData()
                
                if self.isShowAvailability == true {
                    cell.resortInfoCollectionView.tag = indexPath.row - 1
                } else {
                    cell.resortInfoCollectionView.tag = indexPath.row
                }
                cell.resortInfoCollectionView.isScrollEnabled = false
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = UIColor.lightGray.cgColor
                return cell
            }
        }else{
            
            if(!Constant.MyClassConstants.isFromExchange) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.getawayCell, for: indexPath) as! GetawayCell
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = UIColor.lightGray.cgColor
                
                let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
                let inventoryItem = sectionsInSearchResult[indexPath.section].item?.rentalInventory
                let units = inventoryItem?[0].inventory?.units
                if let roomSize = UnitSize(rawValue: (units?[0].unitSize!)!) {
                    cell.bedRoomType.text = Helper.getBrEnums(brType: roomSize.rawValue)
                }
                if let kitchenSize = KitchenType(rawValue: (units?[0].kitchenType!)!) {
                    cell.kitchenType.text = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
                }
                
                cell.sleeps.text = String(describing: units?[0].publicSleepCapacity) + Constant.CommonLocalisedString.totalString + (String(describing: units?[0].privateSleepCapacity)) + Constant.CommonLocalisedString.privateString
                
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell.getawayPrice.text = String(Int(Float((units?[0].prices[0].price)!)))
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                let promotions = units?[0].promotions
                if (promotions?.count)! > 0 {
                    for view in cell.promotionsView.subviews {
                        view.removeFromSuperview()
                    }
                    
                    cellHeight = 55 + (14*(promotions?.count)!)
                    var yPosition: CGFloat = 0
                    for promotion in promotions! {
                        let imgV = UIImageView(frame: CGRect(x:10, y: yPosition, width: 15, height: 15))
                        imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
                        let promLabel = UILabel(frame: CGRect(x:30, y: yPosition, width: cell.promotionsView.bounds.width, height: 15))
                        promLabel.text = promotion.offerName
                        promLabel.adjustsFontSizeToFitWidth = true
                        promLabel.minimumScaleFactor = 0.7
                        promLabel.numberOfLines = 0
                        promLabel.textColor = UIColor(red: 0, green: 119/255, blue: 190/255, alpha: 1)
                        promLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 18)
                        cell.promotionsView.addSubview(imgV)
                        cell.promotionsView.addSubview(promLabel)
                        yPosition += 15
                    }
                }
                
                return cell
                
            }else{
                
                var promotions = 0
                for bucket in (exchangeExactMatchResortsArray[indexPath.section].inventory?.buckets)!{
                    //for (index,promotion) in bucket.promotions.enumerated(){
                    promotions = bucket.promotions.count
                    //}
                }
                if(promotions != 0 && indexPath.row > (exchangeExactMatchResortsArray[indexPath.section].inventory?.buckets.count)!){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.promotionsCell, for: indexPath) as! PromotionsCell
                    
                    var promotions = 0
                    for bucket in (exchangeExactMatchResortsArray[indexPath.section].inventory?.buckets)!{
                        for (index,promotion) in bucket.promotions.enumerated(){
                            if (index == indexPath.row - (exchangeExactMatchResortsArray[indexPath.section].inventory?.buckets.count)!){
                                var promotionsString = Constant.MyClassConstants.htmlHeader.appending((exchangeExactMatchResortsArray[indexPath.section].inventory?.buckets[indexPath.row - 1].promotions[0].offerContentFragment)!)
                                for promotion in (exchangeExactMatchResortsArray[indexPath.section].inventory?.buckets[indexPath.row - 1].promotions)!{
                                    promotionsString = promotion.offerContentFragment!
                                    promotionsString = promotionsString.appending(Constant.MyClassConstants.htmlFooter)
                                    cell.promotionWebView.loadHTMLString(promotionsString, baseURL: Bundle.main.bundleURL)
                                }
                                
                            }
                        }
                    }
                    
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortBedroomDetailexchange, for: indexPath) as! ResortBedroomDetails
                    cell.backgroundColor = IUIKColorPalette.contentBackground.color
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    if let roomSize = UnitSize(rawValue: Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.unitSize!) {
                        
                        cell.numberOfBedroom.text =  Helper.getBrEnums(brType: roomSize.rawValue)
                    }
                    
                    if let kitchenSize = KitchenType(rawValue: Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.kitchenType!) {
                        cell.kitchenLabel.text = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
                    }
                    
                    cell.totalPrivateLabel.text = String(Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.publicSleepCapacity) + Constant.CommonLocalisedString.totalString + (String(Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.privateSleepCapacity)) + Constant.CommonLocalisedString.privateString
                    return cell
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
            let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
            return sectionsInSearchResult.count
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return 0
        
        //***** Return number of rows in section required in tableview *****//
        if(Constant.MyClassConstants.isFromExchange){
            if(section == 0 && exchangeExactMatchResortsArray.count == 0 || section == 1){
                return surroundingMatchResortsArray.count
            }else{
                if self.isShowAvailability == true && section == 0 {
                    return exchangeExactMatchResortsArray.count + 1
                    
                } else {
                    return exchangeExactMatchResortsArray.count
                }
                
            }
        }else{
            if(section == 0 && exactMatchResortsArray.count == 0 || section == 1){
                return surroundingMatchResortsArray.count
            }else{
                if self.isShowAvailability == true && section == 0 {
                    return exactMatchResortsArray.count + 1
                    
                } else {
                    return exactMatchResortsArray.count
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.resortDetailTBLView.frame.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.resortDetailTBLView.frame.width - 40, height: 40))
        let headerButton = UIButton(frame: CGRect(x: 20, y: 0, width: self.resortDetailTBLView.frame.width - 40, height: 40))
        headerButton.addTarget(self, action: #selector(VacationSearchResultIPadController.filterByNameButtonPressed(_:)), for: .touchUpInside)
        let sectionsInSearchResult = Constant.MyClassConstants.initialVacationSearch.createSections()
        if(Constant.MyClassConstants.isFromSorting){
            if(sectionsInSearchResult[section].exactMatch)!{
                headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                headerView.backgroundColor = IUIKColorPalette.primary1.color
            }else{
                headerLabel.text = Constant.CommonLocalisedString.surroundingString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                headerView.backgroundColor = Constant.CommonColor.headerGreenColor
            }
        }else{
        if(sectionsInSearchResult[section].hasItem() && sectionsInSearchResult[section].destination == nil){
           
            if(sectionsInSearchResult[section].item!.rentalInventory.count > 0){
                headerLabel.text = Constant.CommonLocalisedString.exactString + "\(String(describing:sectionsInSearchResult[section].item!.rentalInventory[0].resortName!))"
                headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
            }
                headerView.backgroundColor = IUIKColorPalette.primary1.color
        }else{
            if(sectionsInSearchResult[section].exactMatch)!{
                
                if sectionsInSearchResult[section].destination != nil {
                    
                   headerLabel.text = Constant.CommonLocalisedString.exactString + Constant.MyClassConstants.vacationSearchResultHeaderLabel
                    
                }
                headerView.backgroundColor = IUIKColorPalette.primary1.color
                
            }else{
                
                if sectionsInSearchResult[section].destination != nil {
                    headerLabel.text = Constant.CommonLocalisedString.surroundingString + "\(String(describing: Helper.resolveDestinationInfo(destination: sectionsInSearchResult[section].destination!)))"
                    headerView.backgroundColor = Constant.CommonColor.headerGreenColor
                    
                }
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.resortDetailTBLView.frame.width, height: 20))
        footerView.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 246.0/255.0, alpha: 1)
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(section == Constant.MyClassConstants.resortsArray.count){
            return 0
        }
        return 20
    }
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
        self.createSections()
        self.searchedDateCollectionView.reloadData()
        self.resortDetailTBLView.reloadData()
    }
    
    func resetCalendar(){
    }
}
