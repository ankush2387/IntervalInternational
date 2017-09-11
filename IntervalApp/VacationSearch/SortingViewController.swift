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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.createFilterOptions()
        
        
        //remove extra separator of tableview
        self.sortingTBLview.tableFooterView = UIView()
        //selectedIndex = 0
        self.title = Constant.ControllerTitles.sorting
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func sortingAndFilterSelectedValue(indexPath:NSIndexPath, isFromFiltered:Bool)  {
        
        if isFromFiltered {
            
            Constant.MyClassConstants.filteredIndex = indexPath.row
            let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
            let exchangeSearchCriteria = VacationSearchCriteria(searchType:VacationSearchType.Exchange)
            let bothSearchCriteria = VacationSearchCriteria(searchType:VacationSearchType.Combined)
            
            switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
                
            case .Destination(let destination):
                
                let areaOfInfluenceDestination = AreaOfInfluenceDestination()
                areaOfInfluenceDestination.destinationName = destination.destinationName
                areaOfInfluenceDestination.destinationId = destination.destinationId
                areaOfInfluenceDestination.aoiId = destination.aoid
                
                if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                    
                    rentalSearchCriteria.destination = areaOfInfluenceDestination
                    
                }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                    
                    exchangeSearchCriteria.destination = areaOfInfluenceDestination
                    
                }else{
                    
                    bothSearchCriteria.destination = areaOfInfluenceDestination
                }
                
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
                
            case .Resort(let resort):
                
                let resorts = Resort()
                resorts.resortName = resort.resortName
                resorts.resortCode = resort.resortCode
                
                if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                    rentalSearchCriteria.resorts = [resorts]
                    
                }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                    exchangeSearchCriteria.resorts =  [resorts]
                }else{
                    bothSearchCriteria.resorts =  [resorts]
                }
                
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName
                
            case .ResortList(let resortList):
                
                var resortsArray = [Resort]()
                for resorts in resortList{
                    
                    let resort = Resort()
                    resort.resortName = resorts.resortName
                    resort.resortCode = resorts.resortCode
                    resortsArray.append(resort)
                }
                
                if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                    
                    rentalSearchCriteria.resorts = resortsArray
                    
                }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                    
                    exchangeSearchCriteria.resorts = resortsArray
                    
                }else{
                    
                    bothSearchCriteria.resorts = resortsArray
                }
                
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(resortList[0].resortName) + \(resortList.count - 1) more"
                
            case .Area(let areaList):
                print(areaList)
                let area = Area()
                area.areaName = (areaList.allValues[0] as! String)
                area.areaCode = Int(areaList.allKeys[0] as! String)!
                
                if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                    rentalSearchCriteria.area = area
                    
                }else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                    exchangeSearchCriteria.area = area

                }else{
                    bothSearchCriteria.area = area
                }
                
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = area.areaName!
                
            }
            
            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
            
            if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isRental()){
                
                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                
                let vacationSearchFilter = VacationSearch(UserContext.sharedInstance.appSettings,rentalSearchCriteria)
                
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: vacationSearchFilter.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                
                    vacationSearchFilter.rentalSearch?.searchContext.response = response
                    
                    let activeInterval = vacationSearchFilter.bookingWindow.getActiveInterval()
                    
                    // Update active interval
                    vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                    
                    Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                    
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                        
                        Helper.showNotAvailabilityResults()
                    }
                    
                    let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Constant.MyClassConstants.initialVacationSearch = vacationSearchFilter
                    Helper.helperDelegate = self
                    Helper.hideProgressBar(senderView: self)
                    
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        
                        Helper.showNotAvailabilityResults()
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                    
                    if(response.checkInDates.count > 0){
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0], senderViewController: self, vacationSearch:vacationSearchFilter)
                    }else{
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch:vacationSearchFilter)
                    }
                }
                    
                    
                }){ (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
                
            } else if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange()){
                
                exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                
                
                exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                
                Helper.helperDelegate = self
                
                let vacationSearchFilter = VacationSearch(UserContext.sharedInstance.appSettings,exchangeSearchCriteria)
                
                ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request: vacationSearchFilter.exchangeSearch?.searchContext.request, onSuccess:{ (response) in
                    
                    vacationSearchFilter.exchangeSearch?.searchContext.response = response
                    let activeInterval = vacationSearchFilter.bookingWindow.getActiveInterval()
                    
                    // Update active interval
                    vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                    
                    Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                    Constant.MyClassConstants.initialVacationSearch = vacationSearchFilter
                    
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        Helper.showNotAvailabilityResults()
                    }
                    let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Helper.helperDelegate = self
                    Helper.hideProgressBar(senderView: self)
                    
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        
                        Helper.showNotAvailabilityResults()
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {

                    if response.checkInDates.count > 0 {
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0], senderViewController: self, vacationSearch: vacationSearchFilter)
                    }else{
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)
                    }
                    }
                    
                }){ (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
                
            } else{
                
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.relinquishmentsIds = (Constant.MyClassConstants.relinquishmentIdArray as? [String])!
                bothSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                bothSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                bothSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                Helper.helperDelegate = self
                let vacationSearchFilter = VacationSearch(UserContext.sharedInstance.appSettings,bothSearchCriteria)
                
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: vacationSearchFilter.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                    
                    Helper.hideProgressBar(senderView: self)
                    vacationSearchFilter.rentalSearch?.searchContext.response = response
                    
                    let activeInterval = vacationSearchFilter.bookingWindow.getActiveInterval()
                    
                    // Update active interval
                    vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                    
                    Helper.helperDelegate = self
                    
                    Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        
                        Helper.hideProgressBar(senderView: self)
                        //self.rentalHasNotAvailableCheckInDates = true
                        Helper.executeExchangeSearchDates(senderVC: self, vacationSearch: vacationSearchFilter)
                        
                    }else{
                        
                        Helper.hideProgressBar(senderView: self)
                        let vacationSearchInitialDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                        if(response.checkInDates.count > 0){
                            Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0], senderViewController: self, vacationSearch: vacationSearchFilter)
                        }else{
                           Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: vacationSearchInitialDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)
                        }
                        

                    }
                    
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    //sender.isEnabled = true
                    
                }){ (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
            }
            
        } else {
            
            Constant.MyClassConstants.sortingIndex = indexPath.row
            
            let vacationSearchForSorting = Constant.MyClassConstants.initialVacationSearch
            vacationSearchForSorting.sortType = AvailabilitySortType(rawValue: Constant.MyClassConstants.sortingSetValues[indexPath.row])!
            Constant.MyClassConstants.isFromSorting = false
            //self.createSections()
            self.dismiss(animated: true, completion: nil)
            
            //resortDetailTBLView.reloadData()
            
        }
        
    }
    
    // Set options for filter
    func createFilterOptions(){
        
        Constant.MyClassConstants.filterOptionsArray.removeAll()
        let storedData = Helper.getLocalStorageWherewanttoGo()
        let allDest = Helper.getLocalStorageAllDest()
        
        if(storedData.count > 0) {
            
            let realm = try! Realm()
            try! realm.write {
                Constant.MyClassConstants.filterOptionsArray.removeAll()
                for (index,object) in storedData.enumerated(){
                    
                    if(object.destinations.count > 0){
                        Constant.MyClassConstants.filterOptionsArray.append(
                            .Destination(object.destinations[0])
                            )
                       
                    }else if(object.resorts.count > 0){
                        
                        if(object.resorts[0].resortArray.count > 0){
                            
                            print(object.resorts[0].resortArray, object.resorts[0])
                            
                            var araayOfResorts = List<ResortByMap>()
                            var reswortByMap = [ResortByMap]()
                            araayOfResorts = object.resorts[0].resortArray
                            for resort in araayOfResorts{
                                reswortByMap.append(resort)
                            }
                            
                            Constant.MyClassConstants.filterOptionsArray.append(.ResortList(reswortByMap))
                        }else{
                            
                            Constant.MyClassConstants.filterOptionsArray.append(.Resort(object.resorts[0]))
                        }
                    }
                }
            }
        }else if(allDest.count > 0){
            for areaCode in Constant.MyClassConstants.selectedAreaCodeArray{
                let dictionaryArea = ["\(areaCode)": Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: areaCode as! String)]
                Constant.MyClassConstants.filterOptionsArray.append(.Area(dictionaryArea as! NSMutableDictionary))
            }
        }
    }
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
        if self.isFilterClicked {
            
            let cell = sender.superview?.superview?.superview as? FilterCell
            let indexPath = self.sortingTBLview.indexPath(for: cell!)
            
             self.selectedIndex = (indexPath?.row)!
             self.sortingTBLview.reloadData()
            
            switch Constant.MyClassConstants.filterOptionsArray[(indexPath?.row)!] {
            case .Destination(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
                
               // self.delegate?.selectedOptionis(filteredValueIs: val.destinationName, indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
                
            case .Resort(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
                
                 //self.delegate?.selectedOptionis(filteredValueIs: val.resortName, indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
                
            case .ResortList(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
                
                //self.delegate?.selectedOptionis(filteredValueIs: val[0].resortName, indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
                
            case .Area(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath! as NSIndexPath, isFromFiltered: true)
            }
            
            
            
            
        } else { // sorting option clicked
            let cell = sender.superview?.superview?.superview as? SortingOptionCell
            
            let indexPath = self.sortingTBLview.indexPath(for: cell!)
            
            self.selectedSortingIndex = (indexPath?.row)!
            
            self.sortingAndFilterSelectedValue(indexPath: indexPath! as NSIndexPath, isFromFiltered: false)

           // self.delegate?.selectedOptionis(filteredValueIs: Constant.MyClassConstants.sortingSetValues[(indexPath?.row)!], indexPath: indexPath! as NSIndexPath, isFromFiltered: false)
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SortingViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        self.selectedSortingIndex = indexPath.row
        self.sortingTBLview.reloadData()
        
        // set selected value here from array.
        if self.isFilterClicked {
            switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
            case .Destination( _):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
            case .Resort( _):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
            case .ResortList( _):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
            case .Area( _):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
            }
        } else {
            
            
            self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: false)
        }
    }
}

extension SortingViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFilterClicked {
//            print(Constant.MyClassConstants.filterOptionsArray.count)
//            switch(Constant.MyClassConstants.filterOptionsArray[section]){
//            case .Area(let areas):
//                return areas.count
//            case .Destination( _): break
//            case .Resort( _): break
//            case .ResortList( _): break
//            }
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
        
        if self.isFilterClicked  { // filter option selected
            
             self.lblHeading.text = Constant.MyClassConstants.filterSearchResult
             let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.filterOptionCell, for: indexPath) as! FilterCell
            switch Constant.MyClassConstants.filterOptionsArray[indexPath.row] {
            case .Destination(let val):
                cell.lblFilterOption.text = val.destinationName
            case .Resort(let val):
                cell.lblFilterOption.text = val.resortName
            case .ResortList(let val):
                cell.lblFilterOption.text = "\(val[0].resortName) + \(val.count - 1)  more"
            case .Area(let area):
                let array = area.allKeys
                
                print(array)
                cell.lblFilterOption.text = area.allValues[0] as! String
            }
            
            if(self.selectedIndex == indexPath.row) {
                
                cell.lblFilterOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            }else {
                
                cell.lblFilterOption.textColor = UIColor.lightGray
                cell.checkBox.checked = false
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else { // sorting options
            self.lblHeading.text = Constant.MyClassConstants.sorting
             let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.sortingOptionCell, for: indexPath) as! SortingOptionCell
            
            if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isCombined() || Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType.isExchange(){
                cell.lblSortingOption.text = Constant.MyClassConstants.exchangeSortingOptionArray[indexPath.row]
                cell.lblSortingRange.text = Constant.MyClassConstants.exchangeSortingRangeArray[indexPath.row]
            } else {
                cell.lblSortingOption.text = Constant.MyClassConstants.rentalSortingOptionArray[indexPath.row]
                cell.lblSortingRange.text = Constant.MyClassConstants.rentalSortingRangeArray[indexPath.row]
            }
        
            if(self.selectedSortingIndex == indexPath.row) {
                
                cell.lblSortingOption.textColor = IUIKColorPalette.secondaryB.color
                cell.checkBox.checked = true
            }else {
                
                cell.lblSortingOption.textColor = UIColor.black
                cell.checkBox.checked = false
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        
    }
    
}

//Mark: Extension for Helper
extension SortingViewController:HelperDelegate {
    
    func resortSearchComplete(){
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func resetCalendar(){
        
    }
}
