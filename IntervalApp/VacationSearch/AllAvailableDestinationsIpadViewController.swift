//
//  AllAvailableDestinationsIpadViewController.swift
//  IntervalApp
//
//  Created by Chetu on 01/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class AllAvailableDestinationsIpadViewController: UIViewController {
    
    // class outlet
    @IBOutlet weak var allAvailableDestinatontableview: UITableView!
    @IBOutlet weak var searchButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var viewSearchButton: UIView!
    
    //Class Varaiables
    var areaArray = [Area]()
    var regionAreaDictionary = NSMutableDictionary()
    var selectedAreaDictionary = NSMutableDictionary()
    var moreButton: UIBarButtonItem?
    var senderButton = UIButton()
    var selectedCheckBox = IUIKCheckbox()
    var mainCounter = 0
    var sectionCounter = 0
    var selectedSectionArray = NSMutableArray()
    var regionCounterDict = [Int: String]()
    let areaCode = [String]()
    var isExpandCellIndex = -1
    var expand = false
    var sectionSelected = 0
    var upDownArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewButtonHeightConstraint.constant = 0
        self.searchButtonHeightConstraint.constant = 0
        self.searchButton.isHidden = true
        
        // set corneer radius of search button
        self.searchButton.layer.cornerRadius = 5
        
        //set title
        self.title = Constant.ControllerTitles.availableDestinations
        
        // set navigation right bar buttons
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action: #selector(AllAvailableDestinationsIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = menuButton
        
        // custom back button
        
        let menuButtonleft = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(SearchResultViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButtonleft

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.allAvailableDestinatontableview.reloadData()
        self.resetCounter()
        
    }
    
    func resetCounter() {
        
        sectionCounter = 0
        for values in selectedAreaDictionary {

            intervalPrint(values)
            let counter: [String]  = values.value as! [String]
            intervalPrint(counter.count)
            self.sectionCounter = self.sectionCounter + counter.count
        }
    }

    //Function to add and remove areas and destinations
    
    func addRemoveAreasInRegion(indexPathForSelectedRegion: IndexPath) {
        
        let region = Constant.MyClassConstants.regionArray[indexPathForSelectedRegion.section]
        if selectedAreaDictionary.value(forKey: region.regionName ?? "") != nil {
            let selectedAreasArray = selectedAreaDictionary.value(forKey: region.regionName ?? "") as! [String]
            let areaAtIndex = region.areas[indexPathForSelectedRegion.row]
            var newSelectedArray: [String] = selectedAreasArray
            if selectedAreasArray.contains(areaAtIndex.areaName ?? "") {
                let index1 = selectedAreasArray.index(of: areaAtIndex.areaName ?? "")
                newSelectedArray.remove(at: index1!)
            } else {
                newSelectedArray.append(areaAtIndex.areaName ?? "")
            }
            if newSelectedArray.count != 0 {
                selectedAreaDictionary.setValue(newSelectedArray, forKey: region.regionName!)
            } else {
                selectedAreaDictionary.removeObject(forKey: region.regionName!)
            }
            
            //Manage dictionary for performing search with area codes
            if Constant.MyClassConstants.selectedAreaCodeDictionary["\(areaAtIndex.areaCode)"] != nil {
                 Constant.MyClassConstants.selectedAreaCodeDictionary.removeValue(forKey: "\(areaAtIndex.areaCode)")
                if let index = Constant.MyClassConstants.selectedAreaCodeArray.index(of: "\(areaAtIndex.areaCode)") {
                     Constant.MyClassConstants.selectedAreaCodeArray.remove(at: index)
                }
               
            } else {
                Constant.MyClassConstants.selectedAreaCodeDictionary["\(areaAtIndex.areaCode)"] = areaAtIndex.areaName.unwrappedString
                 Constant.MyClassConstants.selectedAreaCodeArray.append("\(areaAtIndex.areaCode)")
            }
            
        } else {
            var areasArray = [String]()
            areasArray.append(region.areas[indexPathForSelectedRegion.row].areaName.unwrappedString)
            selectedAreaDictionary.setValue(areasArray, forKey: region.regionName.unwrappedString)
            Constant.MyClassConstants.selectedAreaCodeDictionary["\(region.areas[indexPathForSelectedRegion.row].areaCode)"] = region.areas[indexPathForSelectedRegion.row].areaName.unwrappedString
             Constant.MyClassConstants.selectedAreaCodeArray.append("\(region.areas[indexPathForSelectedRegion.row].areaCode)")

        }
        allAvailableDestinatontableview.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination.isKind(of: SelectedResortsIpadViewController.self) {
            let selectedResort = segue.destination as! SelectedResortsIpadViewController
            selectedResort.areaDictionary = self.selectedAreaDictionary
            intervalPrint(selectedResort.areaDictionary)
        }
    }
    
    //Function for navigating to search results
    func navigateToSearchResults() {
        
        Constant.MyClassConstants.vacationSearchResultHeaderLabel = Constant.MyClassConstants.selectedAreaCodeDictionary[Constant.MyClassConstants.selectedAreaCodeArray[0]] ?? ""
        Constant.MyClassConstants.filteredIndex = 0
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? VacationSearchResultIPadController {
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // MARK: - Buttons  Clicked
    
    @IBAction func headerButtonClicked(_ sender: UIButton) {
        
        sectionSelected = sender.tag
        let rsregion = Constant.MyClassConstants.regionArray [sender.tag]
        intervalPrint(Constant.MyClassConstants.regionAreaDictionary)

        if Constant.MyClassConstants.regionAreaDictionary.count == 0 {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: String(rsregion.regionCode))
            self.upDownArray.add("\(sender.tag)")
        } else if Constant.MyClassConstants.regionAreaDictionary.value(forKey: "\(rsregion.regionCode)") == nil {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: String(rsregion.regionCode))
            self.upDownArray.add("\(sender.tag)")
        } else {
            Constant.MyClassConstants.regionAreaDictionary.removeObject(forKey: String(rsregion.regionCode))
            self.upDownArray.remove("\(sender.tag)")
        }
        self.allAvailableDestinatontableview.reloadData()
    }
    
    func menuButtonClicked() {
        
        if selectedAreaDictionary.allKeys.count == 0 {
            presentAlert(with: Constant.dashboardTableScreenReusableIdentifiers.alert, message: Constant.AlertMessages.editAlertdetinationMessage)
            
        } else {
            
            let optionMenu = UIAlertController(title: nil, message: Constant.MyClassConstants.allDestinationsOption, preferredStyle: .actionSheet)
            
            let viewSelectedResorts = UIAlertAction(title: Constant.MyClassConstants.viewSelectedDestination, style: .default, handler: {
                (_: UIAlertAction!) -> Void in
                
                self.performSegue(withIdentifier: Constant.segueIdentifiers.showSelectedResortsIpad, sender: self)
            })
            
            let cancelAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .default, handler: {
                (_: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(viewSelectedResorts)
            optionMenu.addAction(cancelAction)
            
            if Constant.RunningDevice.deviceIdiom == .pad {
                optionMenu.popoverPresentationController?.sourceView = self.view
                optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width, y: 0, width: 100, height: 60)
                optionMenu.popoverPresentationController!.permittedArrowDirections = .up
            }
            
            //Present the AlertController
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        
        var isNetworkAbl: String?
        if Reachability.isConnectedToNetwork() { isNetworkAbl = "Yes" }
        guard let _ = isNetworkAbl else { return presentErrorAlert(UserFacingCommonError.noNetConnection) }
        Helper.helperDelegate = self
        
        if Constant.MyClassConstants.isFromExchangeAllAvailable == true {
            
            showHudAsync()
            //use later
            let checkInDate = Constant.MyClassConstants.vacationSearchShowDate
            let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.EXCHANGE)
            exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
            //set check in date
            exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
            exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
            exchangeSearchCriteria.searchType = VacationSearchType.EXCHANGE
            
            //let storedData = Helper.getLocalStorageWherewanttoGo()
            let area = Area()
            area.areaCode = Int(Constant.MyClassConstants.selectedAreaCodeArray[0]) ?? 0
            area.areaName = Constant.MyClassConstants.selectedAreaCodeDictionary[Constant.MyClassConstants.selectedAreaCodeArray[0]]
            
            exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
            
            if let settings = Session.sharedSession.appSettings {
                Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, exchangeSearchCriteria)
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.areas = [area]
            }
            
            ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                
                self.hideHudAsync()
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
                } else {
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate?.dateFromShortFormat(), senderViewController: self)
                }
                
            }, onError: { (_) in
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.generic)
            })
            
        } else {
            
            let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.RENTAL)
            let combinedSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.COMBINED)
            var vacationSearch = VacationSearch()
            
            let area = Area()
            area.areaCode = Int(Constant.MyClassConstants.selectedAreaCodeArray[0]) ?? 0
            area.areaName = Constant.MyClassConstants.selectedAreaCodeDictionary[Constant.MyClassConstants.selectedAreaCodeArray[0]]
            
            if(!Constant.MyClassConstants.isFromRentalAllAvailable && !Constant.MyClassConstants.isFromExchangeAllAvailable) {
                combinedSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                combinedSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                combinedSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                combinedSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate

                if let settings = Session.sharedSession.appSettings {
                    vacationSearch = VacationSearch(settings, combinedSearchCriteria)
                    vacationSearch.rentalSearch?.searchContext.request.areas = [area]
                    Constant.MyClassConstants.initialVacationSearch = vacationSearch
                }

                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { (response) in
                    self.hideHudAsync()
                    
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return self.hideHudAsync() }
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    Helper.helperDelegate = self
                    
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                        self.hideHudAsync()
                        Helper.executeExchangeSearchDates(senderVC: self)
                    } else {
                        self.hideHudAsync()
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate?.dateFromShortFormat(), senderViewController: self)
                    }
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    Constant.MyClassConstants.isFromSearchBoth = true
                    
                }) { (_) in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            } else {
                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                
                if let settings = Session.sharedSession.appSettings {
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, rentalSearchCriteria)
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.areas = [area]
                }
                
                RentalClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                 onSuccess: { (response) in
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                    // Get activeInterval
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                    
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    // Always show a fresh copy of the Scrolling Calendar
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                        Helper.showNotAvailabilityResults()
                        self.navigateToSearchResults()
                        
                    } else {
                        
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        let initialSearchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate?.dateFromShortFormat()
                        Constant.MyClassConstants.checkInDates = response.checkInDates
                        
                        self.hideHudAsync()
                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: initialSearchCheckInDate, senderViewController: self)
                    }
                },
                 onError: { (_) in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                )
                
            }
        }
    }
}

extension AllAvailableDestinationsIpadViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constant.MyClassConstants.regionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let areas = Constant.MyClassConstants.regionAreaDictionary.value(forKey: String(Constant.MyClassConstants.regionArray[section].regionCode)) {
            let areasInRegionArray = areas as! [Region]
            return areasInRegionArray.count
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.areaCell, for: indexPath) as! AvailableDestinationPlaceTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let areasInRegionArray = Constant.MyClassConstants.regionAreaDictionary.value(forKey: String(Constant.MyClassConstants.regionArray[indexPath.section].regionCode)) as! [Area]
        self.areaArray.removeAll()
        if selectedAreaDictionary.count > 0 {
            if let selectedAreas = selectedAreaDictionary.value(forKey: Constant.MyClassConstants.regionArray[indexPath.section].regionName ?? "") {

                let area = selectedAreas as! [String]
                intervalPrint(area.count, area, area.count)

                let areaName = areasInRegionArray[indexPath.row].areaName
                if area.contains(areaName ?? "") {
                    cell.placeSelectionCheckBox.checked = true
                } else {
                    cell.placeSelectionCheckBox.checked = false
                }
            } else {
                cell.placeSelectionCheckBox.checked = false
            }
        } else {
            cell.placeSelectionCheckBox.checked = false
        }
        
        for areas in areasInRegionArray {
            self.areaArray.append(areas)
        }
        cell.setAllAvailableAreaCell(index: indexPath.row, area: self.areaArray[indexPath.row])
        
        return cell
    }
    
}

extension AllAvailableDestinationsIpadViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         let selectedCell = tableView.cellForRow(at: indexPath) as? AvailableDestinationPlaceTableViewCell
        
        // Only six items can be selected
        self.viewButtonHeightConstraint.constant = 100
        self.searchButtonHeightConstraint.constant = 50
        self.searchButton.isHidden = false
        self.viewSearchButton.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        if selectedCell?.placeSelectionCheckBox.checked ?? false {
            sectionCounter = sectionCounter - 1
            selectedSectionArray.remove(indexPath.section)
            self.addRemoveAreasInRegion(indexPathForSelectedRegion: indexPath)
            if(sectionCounter == 0) {
                
                self.viewButtonHeightConstraint.constant = 0
                self.searchButtonHeightConstraint.constant = 0
                self.searchButton.isHidden = true
                self.viewSearchButton.isHidden = true
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
            
        } else {
            if sectionCounter == 6 {
                
                // show alert when maximum limit is reached
                DispatchQueue.main.async(execute: {
                    self.presentAlert(with: Constant.dashboardTableScreenReusableIdentifiers.alert, message: Constant.AlertMessages.maximumLimitReachedMessage)
                })
                
            } else {
                
                selectedSectionArray.add(indexPath.section)
                sectionCounter = sectionCounter + 1
                self.addRemoveAreasInRegion(indexPathForSelectedRegion: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.regionCell) as? AvailableDestinationCountryOrContinentsTableViewCell else { return UITableViewCell() }
        cell.setDataForAllAvailableDestinations(index: section)
        cell.expandRegionButton.tag = section
        
        if sectionCounter == 0 {
            cell.selectdDestinationCountLabel?.isHidden = true
            
            self.viewButtonHeightConstraint.constant = 0
            self.searchButtonHeightConstraint.constant = 0
            self.searchButton.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
        } else {
            
            let region = Constant.MyClassConstants.regionArray[section]
            for selectedRegion in selectedAreaDictionary.allKeys {
                
                if String(describing: selectedRegion) == region.regionName {
                    let totalAreas = selectedAreaDictionary.value(forKey: selectedRegion as! String) as! [String]
                    cell.selectdDestinationCountLabel?.text = String(totalAreas.count)
                    cell.selectdDestinationCountLabel?.isHidden = false
                }
            }
        }
        if upDownArray.contains("\(section)") {
            UIView.animate(withDuration: 0.1, animations: {
                
                cell.imgIconPlus?.transform = CGAffineTransform.identity
                cell.imgIconPlus?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
        }
        return cell
    }
}

extension AllAvailableDestinationsIpadViewController: HelperDelegate {
    
    func resortSearchComplete() {
     self.navigateToSearchResults()
    }
}
