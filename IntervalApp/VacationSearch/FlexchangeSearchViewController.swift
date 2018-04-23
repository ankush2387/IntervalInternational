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
import then

class FlexchangeSearchViewController: UIViewController {
    
    //IBOutlets.
    
    var selectedFlexchange: FlexExchangeDeal?
    var destinationOrResort = Helper.getLocalStorageWherewanttoGo()
    private let entityStore: EntityDataStore = EntityDataSource.sharedInstance
    fileprivate var availableRelinquishmentIdArray = [String]()
    
    @IBOutlet weak var flexChangeTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adding controller title
        title = Constant.ControllerTitles.flexChangeSearch
        navigationController?.navigationBar.isHidden = false
        Helper.InitializeArrayFromLocalStorage()
        Helper.InitializeOpenWeeksFromLocalStorage()
        _ = Helper.getLocalStorageWherewanttoTrade()
        readSavedRelinquishments()
        flexChangeTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flexChangeTableView.estimatedRowHeight = 100
        flexChangeTableView.rowHeight = UITableViewAutomaticDimension
        
        // Adding navigation back button
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(FlexchangeSearchViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func readSavedRelinquishments() {
        
        availableRelinquishmentIdArray.removeAll()
        let membership = Session.sharedSession.selectedMembership
        let selectedMembershipNumber = membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = selectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let predicate = "contactID == '\(Session.sharedSession.contactID)'"
        entityStore.readObjectsFromDisk(type: OpenWeeksStorage.self, predicate: predicate, encoding: .decrypted)
            .then { openWeeksStorage in
                self.availableRelinquishmentIdArray.append(contentsOf: openWeeksStorage
                    .flatMap { $0.openWeeks }
                    .flatMap { $0.openWeeks }
                    .map { $0.relinquishmentID })
                self.availableRelinquishmentIdArray.append(contentsOf: openWeeksStorage
                    .flatMap { $0.openWeeks }
                    .flatMap { $0.deposits }
                    .map { $0.relinquishmentID })
                
                self.availableRelinquishmentIdArray.append(contentsOf: openWeeksStorage
                    .flatMap { $0.openWeeks }
                    .flatMap { $0.clubPoints }
                    .map { $0.relinquishmentId })
                
                self.availableRelinquishmentIdArray.append(contentsOf: openWeeksStorage
                    .flatMap { $0.openWeeks }
                    .flatMap { $0.pProgram }
                    .map { $0.relinquishmentId })
            }
            .onError { [unowned self] error in
                self.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
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
            
            if let pointsProgram = relinquishments.pointsProgram, let availablePoints = relinquishments.pointsProgram?.availablePoints {
                Constant.MyClassConstants.relinquishmentProgram = pointsProgram
                Constant.MyClassConstants.relinquishmentAvailablePointsProgram = availablePoints
            }
            
            self.hideHudAsync()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RelinquishmentViewController") as? RelinquishmentViewController else { return }
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }, onError: {(_) in
            self.hideHudAsync()
        })
        
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        Helper.helperDelegate = self
        if availableRelinquishmentIdArray.isEmpty {
            
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
                searchCriteria.relinquishmentsIds = availableRelinquishmentIdArray
                if let settings = Session.sharedSession.appSettings {
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
                }

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
                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate?.dateFromShortFormat(), senderViewController: self)

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
            
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = Constant.MyClassConstants.selectedAreaCodeDictionary[Constant.MyClassConstants.selectedAreaCodeArray[0]] ?? ""
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
        case 0:
            return 80
        case 1:
            if (Constant.MyClassConstants.whatToTradeArray.count == 0 && Constant.MyClassConstants.pointsArray.count == 0) || indexPath.row == Constant.MyClassConstants.whatToTradeArray.count {
                return 60
            }
            return UITableViewAutomaticDimension
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
            self.availableRelinquishmentIdArray.remove(at: indexPath.row)
            let storedData = Helper.getLocalStorageWherewanttoTrade()
            
            if !storedData.isEmpty {
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
                
                let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width / 2 - 40, y: 15, width: 80, height: 30))
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
                
                [cell.whereTogoTextLabel, cell.bedroomLabel].forEach {
                    $0?.numberOfLines = 0
                    $0?.lineBreakMode = .byWordWrapping
                }
                
                if indexPath.row == Constant.MyClassConstants.whatToTradeArray.count - 1 {
                    
                    cell.sepratorOr.isHidden = true
                } else {
                    
                    cell.sepratorOr.isHidden = false
                }
                let object = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject
                if object.isKind(of: OpenWeek.self) {
                    guard let openWk = object as? OpenWeek else { return cell }
                    let attributedTitle = NSMutableAttributedString()

                    if let resort = openWk.resort {
                        attributedTitle
                            .bold("\(resort.resortName.unwrappedString), \(resort.resortCode.unwrappedString)")
                            .normal("\n")
                    }
                    
                    if let relinquishmentYear = openWk.relinquishmentYear {
                        attributedTitle.normal("\(relinquishmentYear)")
                    }
                    if let weekNumber = openWk.weekNumber {
                        let formattedWeekNumber = Constant.getWeekNumber(weekType: weekNumber)
                        attributedTitle.normal("Week \(formattedWeekNumber)".localized())
                    }
                    
                    cell.whereTogoTextLabel.attributedText = attributedTitle
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
                                cell.bedroomLabel.text = "\(floatDetails[0].unitNumber), \(resortList[0].kitchenType), \(floatDetails[0].unitSize)"
                            } else {
                                cell.bedroomLabel.text = "\(resortList[0].kitchenType)\n\(floatDetails[0].unitSize)"
                            }
                        } else {
                            cell.bedroomLabel.text = "\(resortList[0].kitchenType)\n\(resortList[0].unitSize)"
                        }
                    } else {
                        cell.bedroomLabel.isHidden = true
                    }
                    if weekNumber != "" {
                        let attributedTitle = NSMutableAttributedString()
                        attributedTitle
                            .bold("\(openWk.resort[0].resortName), \(openWk.resort[0].resortCode)")
                            .normal("\n")
                            .normal("\(openWk.relinquishmentYear) Week \(weekNumber)".localized())
                        cell.whereTogoTextLabel.attributedText = attributedTitle
                    } else {
                        let attributedTitle = NSMutableAttributedString()
                        attributedTitle
                            .bold("\(openWk.resort[0].resortName), \(openWk.resort[0].resortCode)")
                            .normal("\n")
                            .normal("\(openWk.relinquishmentYear)")
                        cell.whereTogoTextLabel.attributedText = attributedTitle
                    }
                } else if object.isKind(of: Deposits.self) {
                    guard let deposits = object as? Deposits else { return cell }
                    
                    //Deposits
                    let weekNumber = Constant.getWeekNumber(weekType: (deposits.weekNumber))
                    
                    if deposits.isLockOff || deposits.isFloat {
                        cell.bedroomLabel.isHidden = false
                        
                        let resortList = deposits.unitDetails
                        let floatDetails = deposits.floatDetails
                        if floatDetails[0].showUnitNumber {
                            cell.bedroomLabel.text = "\(floatDetails[0].unitNumber), \(resortList[0].kitchenType), \(floatDetails[0].unitSize)"
                        } else {
                            cell.bedroomLabel.text = "\(resortList[0].kitchenType)\n\(floatDetails[0].unitSize)"
                        }
                        
                    } else {
                        cell.bedroomLabel.isHidden = true
                    }
                    if weekNumber != "" {
                        let attributedTitle = NSMutableAttributedString()
                        attributedTitle
                            .bold("\(deposits.resort[0].resortName), \(deposits.resort[0].resortCode)")
                            .normal("\n")
                            .normal("\(deposits.relinquishmentYear) Week \(weekNumber)".localized())
                        cell.whereTogoTextLabel.attributedText = attributedTitle
                    } else {
                        let attributedTitle = NSMutableAttributedString()
                        attributedTitle
                            .bold("\(deposits.resort[0].resortName), \(deposits.resort[0].resortCode)")
                            .normal("\n")
                            .normal("\(deposits.relinquishmentYear)")
                        cell.whereTogoTextLabel.attributedText = attributedTitle
                    }
                    
                } else if object.isKind(of: List<ClubPointsEntity>.self) {
                    
                    guard let clubPoints = object as? List<ClubPointsEntity> else { return cell }
                    
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
            cell.selectionStyle = .none
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
