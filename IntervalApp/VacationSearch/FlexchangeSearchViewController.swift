//
//  FlexchangeSearchViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 13/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import RealmSwift
import SVProgressHUD

class FlexchangeSearchViewController: UIViewController {
    
    //IBOutlets.
    
    var selectedFlexchange: FlexExchangeDeal?
    var destinationOrResort = Helper.getLocalStorageWherewanttoGo()
    
    @IBOutlet weak var flexChangeTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        _ = Helper.getLocalStorageWherewanttoTrade()
        flexChangeTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding navigation back button
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(FlexchangeSearchViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Adding controller title
        self.title = Constant.ControllerTitles.flexChangeSearch
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func addRelinquishmentSectionButtonPressed(_ sender: IUIKButton) {
        Constant.MyClassConstants.viewController = self
        showHudAsync()
        ExchangeClient.getMyUnits(Session.sharedSession.userAccessToken, onSuccess: { relinquishments in
            
            Constant.MyClassConstants.relinquishmentDeposits = relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = relinquishments.openWeeks
            
            if let pointsProgram = relinquishments.pointsProgram, let availablePoints =  relinquishments.pointsProgram?.availablePoints {
                Constant.MyClassConstants.relinquishmentProgram = pointsProgram
                Constant.MyClassConstants.relinquishmentAvailablePointsProgram = availablePoints
            }
            
            self.hideHudAsync()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RelinquishmentSelectionViewController") as? RelinquishmentSelectionViewController else { return }
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }, onError: {(_) in
            self.hideHudAsync()
        })
        
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        Helper.helperDelegate = self
        if Constant.MyClassConstants.relinquishmentIdArray.isEmpty {
            
            presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
            self.hideHudAsync()
            
        } else {
            
            showHudAsync()
            if Reachability.isConnectedToNetwork() == true {
                
                let deal = FlexExchangeDeal()
                
                deal.name = selectedFlexchange?.name
                if let areaCode = selectedFlexchange?.areaCode {
                    deal.areaCode = areaCode
                }
                Constant.MyClassConstants.isFromExchange = true
                
                let searchCriteria = Helper.createSearchCriteriaFor(deal: deal)
                
                let settings = Helper.createSettings()
                Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
                
                if let flexchangeName = selectedFlexchange?.name {
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = flexchangeName
                }
                ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { response in
                    
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    // Get activeInterval (or initial search interval)
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                    
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    // Check not available checkIn dates for the active interval
                    if activeInterval.fetchedBefore && !activeInterval.hasCheckInDates() {
                        Helper.showNotAvailabilityResults()
                        self.hideHudAsync()
                        self.navigateToSearchResults()
                    } else {
                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)

                    }
                    
                }, onError: { [weak self] error  in
                    
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            }
            
        }
    }
    
    func navigateToSearchResults() {
        
        if Constant.MyClassConstants.selectedAreaCodeArray.count > 0 {
            
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: Constant.MyClassConstants.selectedAreaCodeArray[0] as? String ?? "") as? String ?? ""
        }
        
        Constant.MyClassConstants.filteredIndex = 0
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? SearchResultViewController else { return }
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension FlexchangeSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** return height for  row in each section of tableview *****//
        switch indexPath.section {
        case 0, 1 :
            return 80
        default :
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.flexChangeTableView.frame.size.width, height: 50))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width, height: 50))
        
        if section == 1 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.fourSegmentHeaderTextArray[1]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
            
        } else if section == 0 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.headerTextFlexchangeDestination
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
            
        } else {
            
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            
            return 50
        } else if section == 0 {
            
            return 50
            
        } else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1 && Constant.MyClassConstants.whatToTradeArray.count > 0) {
            if indexPath.row == Constant.MyClassConstants.whatToTradeArray.count {
                return false
            } else {
                return true
            }
            
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (_, index) -> Void in
            // var isFloat = true
            let storedData = Helper.getLocalStorageWherewanttoTrade()
            
            if storedData.count > 0 {
                do {
                    let realm = try Realm()
                    try realm.write {
                        
                        if (Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject).isKind(of: OpenWeeks.self) {
                            
                            var floatWeekIndex = -1
                            guard let dataSelected = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as? OpenWeeks else { return }
                            if dataSelected.isFloat {
                                
                                for (index, object) in storedData.enumerated() {
                                    let openWk1 = object.openWeeks[0].openWeeks[0]
                                    if openWk1.relinquishmentID == dataSelected.relinquishmentID {
                                        floatWeekIndex = index
                                    }
                                }
                                
                                storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloatRemoved = true
                                storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloat = true
                                storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFromRelinquishment = false
                                
                                if Constant.MyClassConstants.whatToTradeArray.count > 0 {
                                    
                                    ADBMobile.trackAction(Constant.omnitureEvents.event43, data: nil)
                                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: indexPath.row)
                                    Constant.MyClassConstants.relinquishmentIdArray.remove(at: indexPath.row)
                                    Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: indexPath.row)
                                }
                            } else {
                                Constant.MyClassConstants.whatToTradeArray.removeObject(at: indexPath.row)
                                Constant.MyClassConstants.relinquishmentIdArray.remove(at: indexPath.row)
                                realm.delete(storedData[indexPath.row])
                            }
                        } else {
                            Constant.MyClassConstants.whatToTradeArray.removeObject(at: indexPath.row)
                            Constant.MyClassConstants.relinquishmentIdArray.remove(at: indexPath.row)
                            realm.delete(storedData[indexPath.row])
                        }
                        
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                        Helper.InitializeOpenWeeksFromLocalStorage()
                    }
                } catch {
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
            }
        }
        
        delete.backgroundColor = UIColor(red: 224 / 255.0, green: 96.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        return [delete]
    }
    
}

extension FlexchangeSearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            
            return Constant.MyClassConstants.whatToTradeArray.count + 1
            
        } else {
            
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.flexChangeDestinationCell, for: indexPath) as? FlexchangeDestinationCell else { return UITableViewCell() }
            
            cell.lblFlexchangeDestination.text = selectedFlexchange?.name
            
            return cell
        } else if indexPath.section == 1 {
            
            if (Constant.MyClassConstants.whatToTradeArray.count == 0 && Constant.MyClassConstants.pointsArray.count == 0) || indexPath.row == Constant.MyClassConstants.whatToTradeArray.count {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width / 2 - (cell.contentView.bounds.width / 5) / 2, y: 15, width: cell.contentView.bounds.width / 5, height: 30))
                addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
                addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                addLocationButton.layer.cornerRadius = 6
                addLocationButton.layer.borderWidth = 2
                addLocationButton.addTarget(self, action: #selector(FlexchangeSearchViewController.addRelinquishmentSectionButtonPressed(_:)), for: .touchUpInside)
                
                cell.addSubview(addLocationButton)
                cell.backgroundColor = UIColor.clear
                return cell
            } else {
                
                guard let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoContentCell, for: indexPath) as? WhereToGoContentCell else { return UITableViewCell() }
                
                if indexPath.row == Constant.MyClassConstants.whatToTradeArray.count - 1 {
                    
                    cell.sepratorOr.isHidden = true
                } else {
                    
                    cell.sepratorOr.isHidden = false
                }
                let object = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject
                if object.isKind(of: OpenWeek.self) {
                    guard let openWk = object as? OpenWeek else { return cell }
                    if let resortName = openWk.resort?.resortName {
                        cell.whereTogoTextLabel.text = "\(resortName)"
                    }
                    if let relinquishmentYear = openWk.relinquishmentYear {
                        cell.whereTogoTextLabel.text = "\(String(describing: cell.whereTogoTextLabel.text)), \(relinquishmentYear)"
                    }
                    if let weekNumber = openWk.weekNumber {
                        cell.whereTogoTextLabel.text = "\(String(describing: cell.whereTogoTextLabel.text)), Week \(weekNumber)".localized()
                    }
                    cell.bedroomLabel.isHidden = true
                } else if object.isKind(of: OpenWeeks.self) {
                    guard let openWk = object as? OpenWeeks else { return cell }
                    let weekNumber = Constant.getWeekNumber(weekType: (openWk.weekNumber))
                    if  openWk.isLockOff || openWk.isFloat {
                        cell.bedroomLabel.isHidden = false
                        
                        let resortList = openWk.unitDetails
                        if openWk.isFloat {
                            let floatDetails = openWk.floatDetails
                            if floatDetails[0].showUnitNumber {
                                cell.bedroomLabel.text = "\(floatDetails[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                            } else {
                                cell.bedroomLabel.text = "\(floatDetails[0].unitSize), \(resortList[0].kitchenType)"
                            }
                        } else {
                            cell.bedroomLabel.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                    } else {
                        cell.bedroomLabel.isHidden = true
                    }
                    if weekNumber != ""{
                        cell.whereTogoTextLabel.text = "\(openWk.resort[0].resortName)/ \(openWk.relinquishmentYear), Wk\(weekNumber)".localized()
                    } else {
                        cell.whereTogoTextLabel.text = "\(openWk.resort[0].resortName)/ \(openWk.relinquishmentYear)"
                    }
                } else if object.isKind(of: Deposits.self) {
                    guard let deposits = object as? Deposits else { return cell }
                    
                    //Deposits
                    let weekNumber = Constant.getWeekNumber(weekType: (deposits.weekNumber))
                    
                    if deposits.isLockOff || deposits.isFloat {
                        cell.bedroomLabel.isHidden = false
                        
                        let resortList = deposits.unitDetails
                        if deposits.isFloat {
                            let floatDetails = deposits.floatDetails
                            cell.bedroomLabel.text = "\(resortList[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                        } else {
                            cell.bedroomLabel.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                    } else {
                        cell.bedroomLabel.isHidden = true
                    }
                    if weekNumber != "" {
                        cell.whereTogoTextLabel.text = "\(deposits.resort[0].resortName)/ \(deposits.relinquishmentYear), Wk\(weekNumber)".localized()
                    } else {
                        cell.whereTogoTextLabel.text = "\(deposits.resort[0].resortName)/ \(deposits.relinquishmentYear)"
                    }
                    
                } else if object.isKind(of: List<ClubPoints>.self) {
                    
                    guard let clubPoints = object as? List<ClubPoints> else { return cell }
                    
                    if clubPoints[0].isPointsMatrix == false {
                        let resortNameWithYear = "\(clubPoints[0].resort[0].resortName)/\(clubPoints[0].relinquishmentYear)"
                        cell.whereTogoTextLabel.text = "\(resortNameWithYear)"
                    } else {
                        let pointsSpent = clubPoints[0].pointsSpent
                        cell.whereTogoTextLabel.text = "Club Points upto \(String(describing: pointsSpent))".localized()
                    }
                    cell.bedroomLabel.isHidden = true
                    return cell
                } else {
                    
                    let availablePointsNumber = Constant.MyClassConstants.relinquishmentAvailablePointsProgram as NSNumber
                    
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    
                    if let availablePoints = numberFormatter.string(from: availablePointsNumber) {
                        cell.whereTogoTextLabel.text = "\(Constant.getDynamicString.clubInterValPointsUpTo) \(availablePoints)".localized()
                    }
                    
                    cell.bedroomLabel.isHidden = true
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
            }
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.flexchangeSearchButtonCell, for: indexPath) as? SearchFlexchangeButtonCell else { return UITableViewCell() }
            
            cell.searchButton.layer.cornerRadius = 5
            return cell
        }
        
    }
    
}

extension FlexchangeSearchViewController: HelperDelegate {
    
    func resetCalendar() {
        
    }
    
    func resortSearchComplete() {
        self.hideHudAsync()
        self.navigateToSearchResults()
    }
    
}

