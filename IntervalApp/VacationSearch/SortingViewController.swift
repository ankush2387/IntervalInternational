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
    
    var isFilterClicked = false
    @IBOutlet weak var lblHeading: UILabel!
    var resortNameArray = [Resort]()
    
    //Outlets
    @IBOutlet weak var sortingTBLview: UITableView!
    
    //class variables
    var selectedIndex = -1
    var selectedSortingIndex = -1
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    
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
            let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
            let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
            let bothSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Combined)
            
            if !alertFilterOptionsArray.isEmpty {
                switch alertFilterOptionsArray[indexPath.row] {
                    
                case .Destination(let destination):
                    
                    let areaOfInfluenceDestination = AreaOfInfluenceDestination()
                    areaOfInfluenceDestination.destinationName = destination.destinationName
                    areaOfInfluenceDestination.destinationId = destination.destinationId
                    areaOfInfluenceDestination.aoiId = destination.aoiId
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        
                        rentalSearchCriteria.destination = areaOfInfluenceDestination
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        
                        exchangeSearchCriteria.destination = areaOfInfluenceDestination
                        
                    } else {
                        
                        bothSearchCriteria.destination = areaOfInfluenceDestination
                    }
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
                    
                case .Resort(let resort):
                    
                    let resorts = Resort()
                    resorts.resortName = resort.resortName
                    resorts.resortCode = resort.resortCode
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        rentalSearchCriteria.resorts = [resorts]
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        exchangeSearchCriteria.resorts =  [resorts]
                    } else {
                        bothSearchCriteria.resorts =  [resorts]
                    }
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resorts.resortName ?? ""
                }
            } else {
                switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
                    
                case .Destination(let destination):
                    
                    let areaOfInfluenceDestination = AreaOfInfluenceDestination()
                    areaOfInfluenceDestination.destinationName = destination.destinationName
                    areaOfInfluenceDestination.destinationId = destination.destinationId
                    areaOfInfluenceDestination.aoiId = destination.aoid
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        
                        rentalSearchCriteria.destination = areaOfInfluenceDestination
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        
                        exchangeSearchCriteria.destination = areaOfInfluenceDestination
                        
                    } else {
                        
                        bothSearchCriteria.destination = areaOfInfluenceDestination
                    }
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
                    
                case .Resort(let resort):
                    
                    let resorts = Resort()
                    resorts.resortName = resort.resortName
                    resorts.resortCode = resort.resortCode
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        rentalSearchCriteria.resorts = [resorts]
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        exchangeSearchCriteria.resorts =  [resorts]
                    } else {
                        bothSearchCriteria.resorts =  [resorts]
                    }
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName
                    
                case .ResortList(let resortList):
                    
                    var resortsArray = [Resort]()
                    for resorts in resortList {
                        
                        let resort = Resort()
                        resort.resortName = resorts.resortName
                        resort.resortCode = resorts.resortCode
                        resortsArray.append(resort)
                    }
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        
                        rentalSearchCriteria.resorts = resortsArray
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        
                        exchangeSearchCriteria.resorts = resortsArray
                        
                    } else {
                        
                        bothSearchCriteria.resorts = resortsArray
                    }
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(resortList[0].resortName) + \(resortList.count - 1) more"
                    
                case .Area(let areaList):
                    
                    let area = Area()
                    area.areaName = areaList.allValues[0] as? String
                    area.areaCode = Int(areaList.allKeys[0] as! String)!
                    
                    if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                        rentalSearchCriteria.area = area
                        
                    } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                        exchangeSearchCriteria.area = area
                        
                    } else {
                        bothSearchCriteria.area = area
                    }
                    
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = area.areaName ?? ""
                    
                }
            }
            
            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
            showHudAsync()
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental() {
                
                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                
                let vacationSearchFilter = VacationSearch(Session.sharedSession.appSettings, rentalSearchCriteria)
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearchFilter.rentalSearch?.searchContext.request, onSuccess: { (response) in
                    
                    vacationSearchFilter.rentalSearch?.searchContext.response = response
                    
                    if let activeInterval = vacationSearchFilter.bookingWindow.getActiveInterval() {
                        
                        // Update active interval
                        vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                        
                        Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                        
                        // Check not available checkIn dates for the active interval
                        if (activeInterval.fetchedBefore) && !((activeInterval.hasCheckInDates())) {
                            Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                            
                            Helper.showNotAvailabilityResults()
                        }
                        
                        if let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
                            
                            Constant.MyClassConstants.checkInDates = response.checkInDates
                            Constant.MyClassConstants.initialVacationSearch = vacationSearchFilter
                            Helper.helperDelegate = self
                            
                            if (activeInterval.fetchedBefore) && !(activeInterval.hasCheckInDates()) {
                                self.hideHudAsync()
                                Helper.showNotAvailabilityResults()
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                
                                if !response.checkInDates.isEmpty {
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0], senderViewController: self, vacationSearch: vacationSearchFilter)
                                } else {
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)
                                }
                            }
                        }

                    }

                }) { (_) in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            } else if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange() {
                
                exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                
                exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                
                Helper.helperDelegate = self
                
                let vacationSearchFilter = VacationSearch(Session.sharedSession.appSettings, exchangeSearchCriteria)
                
                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearchFilter.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                    
                    vacationSearchFilter.exchangeSearch?.searchContext.response = response
                    guard let activeInterval = vacationSearchFilter.bookingWindow.getActiveInterval() else { return }
                    
                    // Update active interval
                    vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                    
                    Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                    Constant.MyClassConstants.initialVacationSearch = vacationSearchFilter
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Helper.helperDelegate = self
                    
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                        self.hideHudAsync()
                        Helper.showNotAvailabilityResults()
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        self.hideHudAsync()
                        if let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
                            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)
                        } else {
                            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0], senderViewController: self, vacationSearch: vacationSearchFilter)
                        }
                    }
                    
                }) { _ in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            } else {
                
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                bothSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                bothSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                bothSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                Helper.helperDelegate = self
                let vacationSearchFilter = VacationSearch(Session.sharedSession.appSettings, bothSearchCriteria)
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearchFilter.rentalSearch?.searchContext.request, onSuccess: { (response) in
                    
                    vacationSearchFilter.rentalSearch?.searchContext.response = response
                    
                    if let activeInterval = vacationSearchFilter.bookingWindow.getActiveInterval() {
                        
                        
                        // Update active interval
                        vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                        
                        Helper.helperDelegate = self
                        
                        Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                        // Check not available checkIn dates for the active interval
                        if (activeInterval.fetchedBefore) && !(activeInterval.hasCheckInDates()) {
                            Helper.executeExchangeSearchDates(senderVC: self, vacationSearch: vacationSearchFilter)
                        } else {
                            if let vacationSearchInitialDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
                                
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: vacationSearchInitialDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)
                            } else {
                                if !response.checkInDates.isEmpty {
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0], senderViewController: self, vacationSearch: vacationSearchFilter)
                                }
                            }
                        }
                        
                        Constant.MyClassConstants.checkInDates = response.checkInDates
                    }

                    //sender.isEnabled = true
                    
                }) { (_) in
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
            }
            
        } else {
            
            Constant.MyClassConstants.sortingIndex = indexPath.row
            let vacationSearchForSorting = Constant.MyClassConstants.initialVacationSearch
            if let availabilitySoryTypeValue = AvailabilitySortType(rawValue: Constant.MyClassConstants.sortingSetValues[indexPath.row]) {
                vacationSearchForSorting.sortType = availabilitySoryTypeValue
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
    
    func resetCalendar() {
        
    }
}
