//
//  SortingViewController.swift
//  IntervalApp
//
//  Created by Chetu on 20/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import Realm
import RealmSwift

class SortingViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var sortingTBLview: UITableView!
    
    //class variables
    var selectedIndex = -1
    var selectedSortingIndex = -1
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    var isFilterClicked = false
    var resortNameArray = [Resort]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //remove extra separator of tableview
        sortingTBLview.tableFooterView = UIView()
        title = Constant.ControllerTitles.sorting
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func sortingAndFilterSelectedValue(indexPath: NSIndexPath, isFromFiltered: Bool) {
        
        if isFromFiltered {
            
            Constant.MyClassConstants.filteredIndex = indexPath.row
            if !alertFilterOptionsArray.isEmpty {
                
                switch alertFilterOptionsArray[indexPath.row] {
                    
                case .Destination(let destination):
                    let areaOfInfluenceDestination = AreaOfInfluenceDestination()
                    areaOfInfluenceDestination.destinationName = destination.destinationName
                    areaOfInfluenceDestination.destinationId = destination.destinationId
                    areaOfInfluenceDestination.aoiId = destination.aoiId
                    
                    let newSearchCriteria = Constant.MyClassConstants.initialVacationSearch.searchCriteria
                    newSearchCriteria.destination = areaOfInfluenceDestination
                    newSearchCriteria.resorts = nil
                    newSearchCriteria.area = nil
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, newSearchCriteria)
                
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
                    
                case .Resort(let resort):
                    let resorts = Resort()
                    resorts.resortName = resort.resortName
                    resorts.resortCode = resort.resortCode
                    
                    let newSearchCriteria = Constant.MyClassConstants.initialVacationSearch.searchCriteria
                    newSearchCriteria.destination = nil
                    newSearchCriteria.resorts = [resort]
                    newSearchCriteria.area = nil
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, newSearchCriteria)
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resorts.resortName ?? ""
                }
            } else {
                
                switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
                    
                case .Destination(let destination):
                    let areaOfInfluenceDestination = AreaOfInfluenceDestination()
                    areaOfInfluenceDestination.destinationName = destination.destinationName
                    areaOfInfluenceDestination.destinationId = destination.destinationId
                    areaOfInfluenceDestination.aoiId = destination.aoid
                    
                    let newSearchCriteria = Constant.MyClassConstants.initialVacationSearch.searchCriteria
                    newSearchCriteria.destination = areaOfInfluenceDestination
                    newSearchCriteria.resorts = nil
                    newSearchCriteria.area = nil
                    
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, newSearchCriteria)
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
                    
                case .Resort(let resort):
                    let resorts = Resort()
                    resorts.resortName = resort.resortName
                    resorts.resortCode = resort.resortCode
                    
                    let newSearchCriteria = Constant.MyClassConstants.initialVacationSearch.searchCriteria
                    newSearchCriteria.destination = nil
                    newSearchCriteria.resorts = [resorts]
                    newSearchCriteria.area = nil
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, newSearchCriteria)
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName
                    
                case .ResortList(let resortList):
                    var resortsArray = [Resort]()
                    for resorts in resortList {
                        
                        let resort = Resort()
                        resort.resortName = resorts.resortName
                        resort.resortCode = resorts.resortCode
                        resortsArray.append(resort)
                    }
                    
                    let newSearchCriteria = Constant.MyClassConstants.initialVacationSearch.searchCriteria
                    newSearchCriteria.destination = nil
                    newSearchCriteria.resorts = resortsArray
                    newSearchCriteria.area = nil
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, newSearchCriteria)
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(resortList[0].resortName) + \(resortList.count - 1) more"
                    
                case .Area(let areaList):
                    let area = Area()
                    area.areaName = areaList.allValues[0] as? String
                    area.areaCode = Int(areaList.allKeys[0] as! String)!
                   
                    let newSearchCriteria = Constant.MyClassConstants.initialVacationSearch.searchCriteria
                    newSearchCriteria.destination = nil
                    newSearchCriteria.resorts = nil
                    newSearchCriteria.area = area
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, newSearchCriteria)
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = area.areaName ?? ""
                }
            }
            
            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
            showHudAsync()
            
            switch Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType {
            case VacationSearchType.Rental:
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { (response) in
                    
                    Helper.helperDelegate = self
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore && !(activeInterval.hasCheckInDates()) {
                        self.hideHudAsync()
                        Helper.showNotAvailabilityResults()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
                    }
                    
                }) { (_) in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            case VacationSearchType.Exchange:

                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                    
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                    
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    // always show the fresh calendar
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    Helper.helperDelegate = self
                    
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                        self.hideHudAsync()
                        Helper.showNotAvailabilityResults()
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
                    }
                    
                }) { _ in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            case VacationSearchType.Combined:
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { (response) in
                    
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    Helper.helperDelegate = self
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    // Check not available checkIn dates for the active interval
                    if (activeInterval.fetchedBefore) && !(activeInterval.hasCheckInDates()) {
                        Helper.executeExchangeSearchDates(senderVC: self)
                    } else {
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
                        
                    }
                }) { (_) in
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
            default:
                break
            }
        } else {
            
            Constant.MyClassConstants.sortingIndex = indexPath.row
            if let availabilitySoryTypeValue = AvailabilitySortType(rawValue: Constant.MyClassConstants.sortingSetValues[indexPath.row]) {
                Constant.MyClassConstants.initialVacationSearch.sortType = availabilitySoryTypeValue
            }
            Constant.MyClassConstants.isFromSorting = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
        if isFilterClicked {
            if let cell = sender.superview?.superview?.superview as? FilterCell {
                
                if let indexPath = sortingTBLview.indexPath(for: cell) {
                    selectedIndex = (indexPath.row)
                    sortingTBLview.reloadData()
                    
                    switch Constant.MyClassConstants.filterOptionsArray[(indexPath.row)] {
                    case .Destination:
                        sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                        
                    case .Resort:
                        sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                        
                    case .ResortList:
                        sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                        
                    case .Area:
                        sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                    }
                }
            }
            
        } else { // sorting option clicked
            if let cell = sender.superview?.superview?.superview as? SortingOptionCell {
                
                if let indexPath = sortingTBLview.indexPath(for: cell) {
                    
                    selectedSortingIndex = (indexPath.row)
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: false)
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SortingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        selectedSortingIndex = indexPath.row
        sortingTBLview.reloadData()
        
        // set selected value here from array.
        if isFilterClicked {
            if !alertFilterOptionsArray.isEmpty {
                switch alertFilterOptionsArray[indexPath.row] {
                case .Destination( _):
                    
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                    
                case .Resort( _):
                    
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                }
            } else {
                switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
                case .Destination( _):
                    
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                    
                case .Resort( _):
                    
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                    
                case .ResortList( _):
                    
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                    
                case .Area( _):
                    
                    sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                }
            }
            
        } else {
            
            sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: false)
        }
    }
}

extension SortingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilterClicked {
            if !alertFilterOptionsArray.isEmpty {
                return alertFilterOptionsArray.count
            }
            return Constant.MyClassConstants.filterOptionsArray.count
            
        } else {
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined() {
                return Constant.MyClassConstants.exchangeSortingOptionArray.count
            } else {
                return Constant.MyClassConstants.rentalSortingOptionArray.count
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isFilterClicked { // filter option selected
            
            lblHeading.text = Constant.MyClassConstants.filterSearchResult
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.filterOptionCell, for: indexPath) as? FilterCell else {
                
                return UITableViewCell()
            }
            if !Constant.MyClassConstants.filterOptionsArray.isEmpty {
                switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
                case .Destination(let val):
                    cell.lblFilterOption.text = val.destinationName
                case .Resort(let val):
                    cell.lblFilterOption.text = val.resortName
                case .ResortList(let val):
                    cell.lblFilterOption.text = "\(val[0].resortName) + \(val.count - 1)  more"
                case .Area(let area):
                    cell.lblFilterOption.text = area.allValues[0] as? String
                }
            } else if !alertFilterOptionsArray.isEmpty {
                switch alertFilterOptionsArray[indexPath.row] {
                case .Destination(let val):
                    cell.lblFilterOption.text = val.destinationName
                case .Resort(let val):
                    cell.lblFilterOption.text = val.resortName
                }
            }
            
            if selectedIndex == indexPath.row {
                
                cell.lblFilterOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            } else {
                
                cell.lblFilterOption.textColor = UIColor.lightGray
                cell.checkBox.checked = false
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else { // sorting options
            lblHeading.text = Constant.MyClassConstants.sorting
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.sortingOptionCell, for: indexPath) as? SortingOptionCell else {
                
                return UITableViewCell()
            }
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined() || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                cell.lblSortingOption.text = Constant.MyClassConstants.exchangeSortingOptionArray[indexPath.row]
                cell.lblSortingRange.text = Constant.MyClassConstants.exchangeSortingRangeArray[indexPath.row]
            } else {
                cell.lblSortingOption.text = Constant.MyClassConstants.rentalSortingOptionArray[indexPath.row]
                cell.lblSortingRange.text = Constant.MyClassConstants.rentalSortingRangeArray[indexPath.row]
            }
            if selectedSortingIndex == -1 {
                selectedSortingIndex = 0
            }
            if selectedSortingIndex == indexPath.row {
                
                cell.lblSortingOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            } else {
                cell.lblSortingOption.textColor = UIColor.black
                cell.checkBox.checked = false
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}

//Mark: Extension for Helper
extension SortingViewController: HelperDelegate {
    
    func resortSearchComplete() {
        self.hideHudAsync()
        
        self.dismiss(animated: true, completion: nil)
    }
}
