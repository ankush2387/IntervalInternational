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
    var moreButton: UIBarButtonItem?
    var selectedCheckBox = IUIKCheckbox()
    var senderButton = UIButton()
    var sectionCounter = 0
    var selectedSectionArray = NSMutableArray()
    var regionCounterDict = [Int: String]()
    let areaCode = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Creating and adding right bar button for more option button *****//
        moreButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action: #selector(moreNavButtonPressed(_:)))
        moreButton!.tintColor = UIColor.white
        self.navigationController?.navigationItem.rightBarButtonItem = moreButton
        //allAvailableDestinatontableview.tableHeaderView?.frame = CGRectZero
        
        allAvailableDestinatontableview.reloadData()
        self.resetCounter()
    }
    
    func resetCounter() {
        
        sectionCounter = 0
        for values in selectedAreaDictionary {
            let counter: [String]  = values.value as! [String]
            intervalPrint(counter.count)
            self.sectionCounter = self.sectionCounter + counter.count
        }
    }
    func moreNavButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        var isNetworkAbl: String?
        if Reachability.isConnectedToNetwork() { isNetworkAbl = "Yes" }
        guard let _ = isNetworkAbl else { return presentErrorAlert(UserFacingCommonError.noNetConnection) }
        
        Helper.helperDelegate = self
        showHudAsync()
        
        let area = Area()
            area.areaCode = Int(Constant.MyClassConstants.selectedAreaCodeArray[0]) ?? 0
            area.areaName = Constant.MyClassConstants.selectedAreaCodeDictionary[Constant.MyClassConstants.selectedAreaCodeArray[0]]
        
        if Constant.MyClassConstants.isFromExchangeAllAvailable == true {
            let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.EXCHANGE)
            exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
            exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
            exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
            exchangeSearchCriteria.area = area
            if let settings = Session.sharedSession.appSettings {
                Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, exchangeSearchCriteria)
            }
            ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: {[weak self](response) in
                guard let strongSelf = self else { return }
                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                // Get activeInterval (or initial search interval)
                guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return strongSelf.hideHudAsync() }
                
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                
                // Check not available checkIn dates for the active interval
                if activeInterval.fetchedBefore  && !activeInterval.hasCheckInDates() {
                    Helper.showNotAvailabilityResults()
                    strongSelf.navigateToSearchResults()
                } else {
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate?.dateFromFormat(Constant.MyClassConstants.dateFormat), senderViewController: strongSelf)
                }
                
            }, onError: {[weak self] _ in
                
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.generic)
            })
            
        } else if Constant.MyClassConstants.isFromRentalAllAvailable == true {
            
            let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.RENTAL)
                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                rentalSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                rentalSearchCriteria.area = area
            
            if let settings = Session.sharedSession.appSettings {
                Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, rentalSearchCriteria)
            }
            
            RentalClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
             onSuccess: { [weak self] (response) in
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                 guard let strongSelf = self else { return }
                // Get activeInterval
                guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else {return strongSelf.hideHudAsync()}
                
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                // Always show a fresh copy of the Scrolling Calendar
                
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                
                // Check not available checkIn dates for the active interval
                if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                    Helper.showNotAvailabilityResults()
                    strongSelf.navigateToSearchResults()
                    
                } else {
                    
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    let searchCheckInDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate?.dateFromFormat(Constant.MyClassConstants.dateFormat)
                    Helper.helperDelegate = self
                    strongSelf.hideHudAsync()
                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: searchCheckInDate, senderViewController: strongSelf)
                }
            },
             onError: {[weak self] _ in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.generic)
            }
            )
        } else {

            let combinedSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.COMBINED)
                combinedSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                combinedSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                combinedSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                combinedSearchCriteria.area = area
            if let settings = Session.sharedSession.appSettings {
                Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, combinedSearchCriteria)
            }
            
            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: {[weak self] (response) in
                
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                guard let strongSelf = self else { return }
                guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else {return strongSelf.hideHudAsync()}
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                Helper.helperDelegate = self
                
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                // Check not available checkIn dates for the active interval
                if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                    strongSelf.hideHudAsync()
                    Helper.executeExchangeSearchDates(senderVC: strongSelf)
                } else {
                    
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: strongSelf)
                }
                Constant.MyClassConstants.isFromSearchBoth = true
                
            }) { (_) in
                
                self.hideHudAsync()
                self.presentErrorAlert(UserFacingCommonError.generic)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewButtonHeightConstraint.constant = 0
        self.searchButtonHeightConstraint.constant = 0
        self.searchButton.isHidden = true
        searchButton.layer.cornerRadius = 4
        self.title = Constant.ControllerTitles.availableDestinations
        
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action: #selector(AllAvailableDestinationsIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = menuButton
        
        let menuButtonleft = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(SearchResultViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButtonleft
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Back Button Pressed.
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
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
    
    func addRemoveAreasInRegion(indexPathForSelectedRegion: IndexPath) {
        
        let region = Constant.MyClassConstants.regionArray[indexPathForSelectedRegion.section]
        if selectedAreaDictionary.value(forKey: region.regionName ?? "") != nil {
            let selectedAreasArray = selectedAreaDictionary.value(forKey: region.regionName!) as! [String]
            let areaAtIndex = region.areas[indexPathForSelectedRegion.row]
            var newSelectedArray: [String] = selectedAreasArray
            if selectedAreasArray.contains(areaAtIndex.areaName ?? "") {
                let index1 = selectedAreasArray.index(of: areaAtIndex.areaName ?? "")
                newSelectedArray.remove(at: index1 ?? 0)
            } else {
                newSelectedArray.append(areaAtIndex.areaName ?? "")
            }
            if !newSelectedArray.isEmpty {
                selectedAreaDictionary.setValue(newSelectedArray, forKey: region.regionName ?? "")
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
            Constant.MyClassConstants.selectedAreaCodeDictionary["\(region.areas[indexPathForSelectedRegion.row].areaCode)"] = "\(String(describing: region.areas[indexPathForSelectedRegion.row].areaName.unwrappedString))"
            Constant.MyClassConstants.selectedAreaCodeArray.append("\(region.areas[indexPathForSelectedRegion.row].areaCode)")
        }
        allAvailableDestinatontableview.reloadData()
    }
    
    func expandClicked(_ sender: UIButton) {
        
        let rsregion = Constant.MyClassConstants.regionArray [sender.tag]
        intervalPrint(Constant.MyClassConstants.regionAreaDictionary)

        if Constant.MyClassConstants.regionAreaDictionary.count == 0 {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: String(rsregion.regionCode))
            upDownArray.add("\(sender.tag)")
        } else if (Constant.MyClassConstants.regionAreaDictionary.value(forKey: "\(rsregion.regionCode)") == nil) {
            Constant.MyClassConstants.regionAreaDictionary.setValue(rsregion.areas, forKey: String(rsregion.regionCode))
            upDownArray.add("\(sender.tag)")
        } else {
            Constant.MyClassConstants.regionAreaDictionary.removeObject(forKey: String(rsregion.regionCode))
            upDownArray.remove("\(sender.tag)")
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
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? SearchResultViewController {
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            navigationController!.pushViewController(viewController, animated: true)
        }
    }
}

extension AllAvailableDestinationViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.areaCell, for: indexPath) as? AvailableDestinationPlaceTableViewCell else { return UITableViewCell() }
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

extension AllAvailableDestinationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? AvailableDestinationPlaceTableViewCell else {return}
        
        // Only six items can be selected
        self.viewButtonHeightConstraint.constant = 70
        self.searchButtonHeightConstraint.constant = 50
        self.searchButton.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        if selectedCell.placeSelectionCheckBox.checked {
            sectionCounter = sectionCounter - 1
            selectedSectionArray.remove(indexPath.section)
            self.addRemoveAreasInRegion(indexPathForSelectedRegion: indexPath)
            if sectionCounter == 0 {
                
                self.viewButtonHeightConstraint.constant = 0
                self.searchButtonHeightConstraint.constant = 0
                self.searchButton.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            }
        } else {
            if sectionCounter == 6 {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.regionCell) as! AvailableDestinationCountryOrContinentsTableViewCell
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
                    if !totalAreas.isEmpty {
                        cell.selectdDestinationCountLabel?.isHidden = false
                    } else {
                        cell.selectdDestinationCountLabel?.isHidden = true
                    }
                }
            }
            
        }
        cell.expandRegionButton.addTarget(self, action: #selector(AllAvailableDestinationViewController.expandClicked(_:)), for: .touchUpInside)
        
        if upDownArray.contains("\(section)") {
            UIView.animate(withDuration: 0.1, animations: {
                cell.imgIconPlus?.transform = CGAffineTransform.identity
                cell.imgIconPlus?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
        }
        
         return cell
    }
}

extension AllAvailableDestinationViewController: HelperDelegate {
    
    func resortSearchComplete() {
       self.navigateToSearchResults()
    }
}
