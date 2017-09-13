//
//  AllAvailableDestinationViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 01/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class AllAvailableDestinationViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var allAvailableDestinatontableview: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewButtonHeightConstraint: NSLayoutConstraint!
    
    
    //Class Varaiables
    var areaArray = [Area]()
    var regionAreaDictionary = NSMutableDictionary()
    var selectedAreaDictionary = NSMutableDictionary()
    var upDownArray = NSMutableArray()
    //var selectedAreaCodeDictionary = NSMutableDictionary()
    var moreButton:UIBarButtonItem?
    var selectedCheckBox = IUIKCheckbox()
    var senderButton = UIButton()
    var sectionCounter = 0
    var selectedSectionArray = NSMutableArray()
    var regionCounterDict = [Int:String]()
    let areaCode = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Creating and adding right bar button for more option button *****//
        moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(moreNavButtonPressed(_:)))
        moreButton!.tintColor = UIColor.white
        self.navigationController?.navigationItem.rightBarButtonItem = moreButton
        //allAvailableDestinatontableview.tableHeaderView?.frame = CGRectZero
        
        if(sectionCounter == 0){
            
            self.viewButtonHeightConstraint.constant = 0
            self.searchButtonHeightConstraint.constant = 0
            self.searchButton.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
        }
        
        allAvailableDestinatontableview.reloadData()
        self.resetCounter()
    }
    
    func resetCounter(){
        sectionCounter = 0
        
        for values in selectedAreaDictionary {
            
            print(values)
            let counter:[String]  = values.value as! [String]
            print(counter.count)
            self.sectionCounter = self.sectionCounter + counter.count
            
        }
        
        
    }
    
    
    func moreNavButtonPressed(_ sender:UIBarButtonItem) {
        
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        Helper.helperDelegate = self
        
        if(Constant.MyClassConstants.isFromExchangeAllAvailable == true){
            
            
                Helper.showProgressBar(senderView: self)
            if Reachability.isConnectedToNetwork() == true {
                
                let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
                
                exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                exchangeSearchCriteria.searchType = VacationSearchType.Exchange
                
                
                
                //let storedData = Helper.getLocalStorageWherewanttoGo()
                
                exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(UserContext.sharedInstance.appSettings, exchangeSearchCriteria)
                let area = Area()
                area.areaCode = Int(Constant.MyClassConstants.selectedAreaCodeArray[0] as! String)!
                area.areaName = Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: Constant.MyClassConstants.selectedAreaCodeArray[0] as! String) as? String
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.areas = [area]
                
                
                
                ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                    
                    Helper.hideProgressBar(senderView: self)
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    // Get activeInterval (or initial search interval)
                    let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                    
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        Helper.showNotAvailabilityResults()
                        //self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
                        self.navigateToSearchResults()
                    }else{
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    }
                    
                }, onError: { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                })
                
            
        }
 
            
            
        }else{
            
            let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
            let combinedSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Combined)
            var vacationSearch = VacationSearch()
            
            let area = Area()
            area.areaCode = Int(Constant.MyClassConstants.selectedAreaCodeArray[0] as! String)!
            area.areaName = Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: Constant.MyClassConstants.selectedAreaCodeArray[0] as! String) as? String
            
            if(!Constant.MyClassConstants.isFromRentalAllAvailable && !Constant.MyClassConstants.isFromExchangeAllAvailable){
                combinedSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                combinedSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                combinedSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                combinedSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                vacationSearch = VacationSearch(UserContext.sharedInstance.appSettings, combinedSearchCriteria)
                vacationSearch.rentalSearch?.searchContext.request.areas = [area]
                Constant.MyClassConstants.initialVacationSearch = vacationSearch
                
                
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                    
                    Helper.hideProgressBar(senderView: self)
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                    let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    Helper.helperDelegate = self
                    
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    // Check not available checkIn dates for the active interval
                    if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                        Helper.hideProgressBar(senderView: self)
                        Helper.executeExchangeSearchDates(senderVC: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    }else{
                        Helper.hideProgressBar(senderView: self)
                        if(response.checkInDates.count>0){
                            Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        }
                        let vacationSearchInitialDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: vacationSearchInitialDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    }
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Constant.MyClassConstants.isFromSearchBoth = true
                    
                })
                { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
                
                
                
            }else{
                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                vacationSearch = VacationSearch(UserContext.sharedInstance.appSettings, rentalSearchCriteria)
                vacationSearch.rentalSearch?.searchContext.request.areas = [area]
                Constant.MyClassConstants.initialVacationSearch = vacationSearch
                
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request:vacationSearch.rentalSearch?.searchContext.request,
                                         onSuccess: { (response) in
                                            vacationSearch.rentalSearch?.searchContext.response = response
                                            
                                            // Get activeInterval
                                            let activeInterval = vacationSearch.bookingWindow.getActiveInterval()
                                            
                                            // Update active interval
                                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                            Constant.MyClassConstants.initialVacationSearch = vacationSearch
                                            
                                            // Always show a fresh copy of the Scrolling Calendar
                                            
                                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            
                                            // Check not available checkIn dates for the active interval
                                            if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                                                
                                                Helper.showNotAvailabilityResults()
                                                self.navigateToSearchResults()
                                                
                                            } else {
                                                
                                                Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                                let initialSearchCheckInDate = Helper.convertStringToDate(dateString:vacationSearch.searchCheckInDate!,format:Constant.MyClassConstants.dateFormat)
                                                Constant.MyClassConstants.checkInDates = response.checkInDates
                                                //sender.isEnabled = true
                                                Helper.helperDelegate = self
                                                Helper.hideProgressBar(senderView: self)
                                                Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: initialSearchCheckInDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                            }
                },
                                         onError:{ (error) in
                                            Helper.hideProgressBar(senderView: self)
                                            //sender.isEnabled = true
                                            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                }
                )

            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewButtonHeightConstraint.constant = 0
        self.searchButtonHeightConstraint.constant = 0
        self.searchButton.isHidden = true
        searchButton.layer.cornerRadius = 4
        self.title = "Available Destinations"
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(AllAvailableDestinationsIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = menuButton
        
        let menuButtonleft = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(SearchResultViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButtonleft
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Back Button Pressed.
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    //Function for checkBox click
    @IBAction func checkBoxClicked(_ sender: Any) {
        
        self.viewButtonHeightConstraint.constant = 100
        self.searchButtonHeightConstraint.constant = 50
        self.searchButton.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
       
    }
    
    //Function to add and remove areas and destinations
    
    func addRemoveAreasInRegion(indexPathForSelectedRegion:IndexPath){
        
        let region = Constant.MyClassConstants.regionArray[indexPathForSelectedRegion.section]
        if(selectedAreaDictionary.value(forKey: region.regionName!) != nil){
            let selectedAreasArray = selectedAreaDictionary.value(forKey: region.regionName!) as! [String]
            let areaAtIndex = region.areas[indexPathForSelectedRegion.row]
            var newSelectedArray:[String] = selectedAreasArray
            if(selectedAreasArray.contains(areaAtIndex.areaName!)){
                let index1 = selectedAreasArray.index(of: areaAtIndex.areaName!)
                newSelectedArray.remove(at: index1!)
            }else{
                newSelectedArray.append(areaAtIndex.areaName!)
            }
            if(newSelectedArray.count != 0){
                selectedAreaDictionary.setValue(newSelectedArray, forKey: region.regionName!)
            }else{
                selectedAreaDictionary.removeObject(forKey: region.regionName!)
            }
            
            //Manage dictionary for performing search with area codes
            if(Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: "\(areaAtIndex.areaCode)") != nil){
                Constant.MyClassConstants.selectedAreaCodeDictionary.removeObject(forKey: "\(areaAtIndex.areaCode)")
                Constant.MyClassConstants.selectedAreaCodeArray.remove("\(areaAtIndex.areaCode)")
            }else{
                Constant.MyClassConstants.selectedAreaCodeDictionary.setValue(areaAtIndex.areaName!, forKey: "\(areaAtIndex.areaCode)")
                Constant.MyClassConstants.selectedAreaCodeArray.add("\(areaAtIndex.areaCode)")
            }
            
        }else{
            var areasArray = [String]()
            areasArray.append(region.areas[indexPathForSelectedRegion.row].areaName!)
            selectedAreaDictionary.setValue(areasArray, forKey: region.regionName!)
            Constant.MyClassConstants.selectedAreaCodeDictionary.setValue("\(String(describing: region.areas[indexPathForSelectedRegion.row].areaName!))", forKey: "\(region.areas[indexPathForSelectedRegion.row].areaCode)")
            Constant.MyClassConstants.selectedAreaCodeArray.add("\(region.areas[indexPathForSelectedRegion.row].areaCode)")
        }
        allAvailableDestinatontableview.reloadData()
       
    }
    
    func expandClicked(_ sender:UIButton){
        
        let rsregion = Constant.MyClassConstants.regionArray [sender.tag]
        print(Constant.MyClassConstants.regionAreaDictionary)
        if Constant.MyClassConstants.regionAreaDictionary.count == 0 {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: String(rsregion.regionCode))
            upDownArray.add("\(sender.tag)")
        }else if (Constant.MyClassConstants.regionAreaDictionary.value(forKey:"\(rsregion.regionCode)") == nil){
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: String(rsregion.regionCode))
            upDownArray.add("\(sender.tag)")
        }else{
            Constant.MyClassConstants.regionAreaDictionary.removeObject(forKey: String(rsregion.regionCode))
            upDownArray.remove("\(sender.tag)")
        }
        self.allAvailableDestinatontableview.reloadData()
    }
    
    func menuButtonClicked()  {
        
        
        if(selectedAreaDictionary.allKeys.count == 0){
            
            SimpleAlert.alert(self, title: "Alert!", message: "Select At least one Destination")
            
        }else{
            
            let optionMenu = UIAlertController(title: nil, message: "All Destinations Options", preferredStyle: .actionSheet)
            
            let viewSelectedResorts = UIAlertAction(title: "View Selected Destinations", style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                
                self.performSegue(withIdentifier: Constant.segueIdentifiers.showSelectedResortsIpad, sender: self)
            })
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(viewSelectedResorts)
            optionMenu.addAction(cancelAction)
            
            if(Constant.RunningDevice.deviceIdiom == .pad){
                optionMenu.popoverPresentationController?.sourceView = self.view
                optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width,y: 0, width: 100, height: 60)
                optionMenu.popoverPresentationController!.permittedArrowDirections = .up;
            }
            
            //Present the AlertController
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.destination.isKind(of: SelectedResortsIpadViewController.self)) {
            
            let selectedResort = segue.destination as! SelectedResortsIpadViewController
            selectedResort.areaDictionary = self.selectedAreaDictionary
            print(selectedResort.areaDictionary)
        
        }
     
    }
    
    //Function for navigating to search results
    func navigateToSearchResults(){
        Constant.MyClassConstants.vacationSearchResultHeaderLabel = (Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: Constant.MyClassConstants.selectedAreaCodeArray[0] as! String) as? String)!
        Constant.MyClassConstants.filteredIndex = 0
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }

}


extension AllAvailableDestinationViewController:UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return Constant.MyClassConstants.regionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let areas = Constant.MyClassConstants.regionAreaDictionary.value(forKey: String(Constant.MyClassConstants.regionArray[section].regionCode)){
            let areasInRegionArray = areas as! [Region]
            return areasInRegionArray.count
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.areaCell, for: indexPath) as! AvailableDestinationPlaceTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let areasInRegionArray = Constant.MyClassConstants.regionAreaDictionary.value(forKey: String(Constant.MyClassConstants.regionArray[indexPath.section].regionCode)) as! [Area]
        self.areaArray.removeAll()
        if(selectedAreaDictionary.count > 0){
            if let selectedAreas = selectedAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[indexPath.section].regionName!){
                let area = selectedAreas as! [String]
                print(area.count,area,area.count)
                
                let areaName = areasInRegionArray[indexPath.row].areaName
                if(area.contains(areaName!)){
                    cell.placeSelectionCheckBox.checked = true
                }else{
                    cell.placeSelectionCheckBox.checked = false
                }
            }else{
                cell.placeSelectionCheckBox.checked = false
            }
        }else{
            cell.placeSelectionCheckBox.checked = false
        }
        
        for areas in areasInRegionArray{
            self.areaArray.append(areas)
        }
        
        cell.setAllAvailableAreaCell(index:indexPath.row, area:self.areaArray[indexPath.row])
        
        return cell
    }
    
}

extension AllAvailableDestinationViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! AvailableDestinationPlaceTableViewCell
        
        // Only six items can be selected
        self.viewButtonHeightConstraint.constant = 70
        self.searchButtonHeightConstraint.constant = 50
        self.searchButton.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        
        if(selectedCell.placeSelectionCheckBox.checked){
            sectionCounter = sectionCounter - 1
            selectedSectionArray.remove(indexPath.section)
            self.addRemoveAreasInRegion(indexPathForSelectedRegion:indexPath)
            if(sectionCounter == 0){
                
                self.viewButtonHeightConstraint.constant = 0
                self.searchButtonHeightConstraint.constant = 0
                self.searchButton.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            }
        }else{
            if(sectionCounter == 6){
                
                DispatchQueue.main.async(execute: {
                    SimpleAlert.alert(self, title: "Alert!", message: "Maximum limit reached")
                })
                
            }else{
            selectedSectionArray.add(indexPath.section)
            sectionCounter = sectionCounter + 1
            self.addRemoveAreasInRegion(indexPathForSelectedRegion:indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.regionCell) as! AvailableDestinationCountryOrContinentsTableViewCell
        cell.setDataForAllAvailableDestinations(index: section)
        cell.expandRegionButton.tag = section
        if(sectionCounter == 0){
            cell.selectdDestinationCountLabel?.isHidden = true
            
            self.viewButtonHeightConstraint.constant = 0
            self.searchButtonHeightConstraint.constant = 0
            self.searchButton.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }else{
            let region = Constant.MyClassConstants.regionArray[section]
            for selectedRegion in selectedAreaDictionary.allKeys{
                if String(describing: selectedRegion) == region.regionName{
                    let totalAreas = selectedAreaDictionary.value(forKey: selectedRegion as! String) as! [String]
                    cell.selectdDestinationCountLabel?.text = String(totalAreas.count)
                    if(totalAreas.count > 0){
                        
                        cell.selectdDestinationCountLabel?.isHidden = false
                    }else{
                        
                        cell.selectdDestinationCountLabel?.isHidden = true
                    }
                    
                }
            }
            
        }
        cell.expandRegionButton.addTarget(self, action: #selector(AllAvailableDestinationViewController.expandClicked(_:)), for: .touchUpInside)
        
        if(upDownArray.contains("\(section)")){
            UIView.animate(withDuration:0.1, animations: {
                cell.imgIconPlus?.transform = CGAffineTransform.identity
                cell.imgIconPlus?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
        }
        
         return cell
    }
}

extension AllAvailableDestinationViewController:HelperDelegate{
    
    func resortSearchComplete(){
       self.navigateToSearchResults()
    }
    
    func resetCalendar(){
        
    }
}
