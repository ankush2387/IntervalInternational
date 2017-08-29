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
        
        self.title = Constant.ControllerTitles.sorting
        
        //***** Add the cancel button  as left bar button item *****//
        
        /*let cancelButton = UIBarButtonItem(title: Constant.buttonTitles.cancel, style: .plain, target: self, action: #selector(cancelButtonPressed(_:)))

        cancelButton.tintColor = UIColor.init(colorLiteralRed: 52.0/255.0, green: 152.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = cancelButton
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white*/
        
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
                       // Constant.MyClassConstants.initialVacationSearch = self.vacationSearch
                        Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                        
                        //Helper.showNotAvailabilityResults()
                    }
                    
                    let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Helper.helperDelegate = self
                    Helper.hideProgressBar(senderView: self)
                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch:vacationSearchFilter)
                    
                })
                    
                { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                    self.dismiss(animated: true, completion: nil)
                    //self.resortDetailTBLView.reloadData()
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
                    
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        
                        // Update active interval
                        vacationSearchFilter.updateActiveInterval(activeInterval: activeInterval)
                        Helper.showScrollingCalendar(vacationSearch: vacationSearchFilter)
                        
                        //Helper.showNotAvailabilityResults()
                    }
                    let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Helper.helperDelegate = self
                    Helper.hideProgressBar(senderView: self)
                    if initialSearchCheckInDate != nil {
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: initialSearchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)
                        
                    }
                    
                })
                    
                { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                    //self.dismiss(animated: true, completion: nil)
                    //self.resortDetailTBLView.reloadData()
                }
                
            } else{
                
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.relinquishmentsIds = ["Ek83chJmdS6ESNRpVfhH8XUt24BdWzaYpSIODLB0Scq6rxirAlGksihR1PCb1xSC"]//Constant.MyClassConstants.relinquishmentIdArray as? [String]
                bothSearchCriteria.relinquishmentsIds = ["Ek83chJmdS6ESNRpVfhH8XUt24BdWzaYpSIODLB0Scq6rxirAlGksihR1PCb1xSC"]
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
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: vacationSearchInitialDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: vacationSearchFilter)

                    }
                    
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    //sender.isEnabled = true
                    
                })
                    
                { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
                //self.createSections()
                //self.resortDetailTBLView.reloadData()
                //self.dismiss(animated: true, completion: nil)
                
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

        let storedData = Helper.getLocalStorageWherewanttoGo()
        
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
            case .Destination(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
               // self.delegate?.selectedOptionis(filteredValueIs: val.destinationName, indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
            case .Resort(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
                //self.delegate?.selectedOptionis(filteredValueIs: val.resortName, indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
            case .ResortList(let val):
                
                self.sortingAndFilterSelectedValue(indexPath: indexPath as NSIndexPath, isFromFiltered: true)
                
                //self.delegate?.selectedOptionis(filteredValueIs: val[indexPath.row].resortName, indexPath: indexPath as NSIndexPath, isFromFiltered: true)
            }
        } else {
            //self.delegate?.selectedOptionis(filteredValueIs: Constant.MyClassConstants.sortingSetValues[(indexPath.row)], indexPath: indexPath as NSIndexPath, isFromFiltered: false)
            
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
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.isFromSearchBoth{
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
