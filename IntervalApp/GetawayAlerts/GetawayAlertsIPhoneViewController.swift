//
//  GetawayAlertsiPhoneViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 8/16/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class GetawayAlertsIPhoneViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var alertDisplayTableView: UITableView!
    var alertStatusId = 0
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    var individualActivityIndicatorNeedToShow = false
    var searchDateResponse = RentalSearchDatesResponse()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        
        if Constant.needToReloadAlert {
            Constant.needToReloadAlert = false
            needToReloadAlerts()
        }
        
        //***** Adding notification to reload table when all alerts have been fetched *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAlertsTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        //TODO-JHON: Forcing alertBadge to disappear, review after pushnotifications are working.
        
        if let alertID = Constant.MyClassConstants.redirect.alertID, let getAwayAlert = Constant.MyClassConstants.redirect.rentalAlert {
            
            if (Constant.MyClassConstants.searchDateResponse.filter { $0.0.alertId == Int64(alertID) }).isEmpty {
                alertDisplayTableView.reloadData()
            }
            
            pushRentalAlertView(alertID: alertID, getawayAlert: getAwayAlert)
            UIApplication.shared.applicationIconBadgeNumber = 0
            Constant.MyClassConstants.redirect = (nil, nil)
        }
    }
    
    // MARK: - Public functions
    func shouldRedirectToRentalAlertScreen(with alertID: Int, and rentalAlert: RentalAlert) {
        // When we implement the coordinator this won't be neccessary... yuck.. :'(
    }
    
    //***** Function for notification for all alerts *****//
    func reloadAlertsTableView() {
        self.individualActivityIndicatorNeedToShow = false
        alertDisplayTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***** Set general Nav attributes *****//
        self.title = Constant.ControllerTitles.getawayAlertsViewController
        
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** creating and adding right bar button for more option button *****//
            let moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(moreNavButtonPressed(sender:)))
            moreButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = moreButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
        alertDisplayTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }
    
    //**** Function for more button action ****//
    func moreNavButtonPressed(sender: UIBarButtonItem) {
        
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.getwayAlertOptions, message: "", preferredStyle: .actionSheet)
        
        let attributedText = NSMutableAttributedString(string: Constant.buttonTitles.getwayAlertOptions)
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16.0)!, range: range)
        actionSheetController.setValue(attributedText, forKey: Constant.actionSheetAttributedString.attributedTitle)
        //***** Create and add the View my recent search *****//
        let searchAllMyAlertsNow: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.searchAllMyAlertsNow, style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.needToReloadAlerts()
        }
        actionSheetController.addAction(searchAllMyAlertsNow)
        //***** Create and add the Reset my search *****//
        let aboutGetawayAlerts: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.aboutGetawayAlerts, style: .default) { action -> Void in
            let storyboard = UIStoryboard(name: "GetawayAlertsIphone", bundle: nil)
            let aboutNavigation = storyboard.instantiateViewController(withIdentifier: "AboutHelpNav") as! UINavigationController
            
            self.present(aboutNavigation, animated: true, completion: nil)
        }
        actionSheetController.addAction(aboutGetawayAlerts)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { _ -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        if Constant.RunningDevice.deviceIdiom == .pad {
            
            actionSheetController.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.size.width, y:0, width:100, height:60)
            actionSheetController.popoverPresentationController?.permittedArrowDirections = .up
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func needToReloadAlerts() {
        Constant.MyClassConstants.searchDateResponse.removeAll()
        individualActivityIndicatorNeedToShow = true
        self.alertDisplayTableView.reloadData()
        if let accessToken = Session.sharedSession.userAccessToken {
            readAllRentalAlerts(accessToken: accessToken)
        }
    }
    
    // MARK: - Getaway Alerts
    func readAllRentalAlerts(accessToken: DarwinAccessToken) {
        showHudAsync()
        ClientAPI.sharedInstance.readAllRentalAlerts(for: accessToken)
            .then { rentalAlertArray in
                
                Constant.MyClassConstants.getawayAlertsArray.removeAll()
                Constant.MyClassConstants.getawayAlertsArray = rentalAlertArray
                Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
                
                for alert in rentalAlertArray {
                    if let alertId = alert.alertId {
                        self.readRentalAlert(accessToken: accessToken, alertId: alertId)
                    }
                }
            }
            .onError { [weak self] error in
                self?.presentErrorAlert(UserFacingCommonError.handleError(error as NSError))
                
        }
    }
    
    func readRentalAlert(accessToken: DarwinAccessToken, alertId: Int64) {
        Constant.MyClassConstants.searchDateResponse.removeAll()
        ClientAPI.sharedInstance.readRentalAlert(for: accessToken, and: alertId)
            .then { rentalAlert in
                
                let rentalSearchDatesRequest = RentalSearchDatesRequest()
                if let checkInTodate = rentalAlert.latestCheckInDate {
                    rentalSearchDatesRequest.checkInToDate = Helper.convertStringToDate(dateString:checkInTodate, format:Constant.MyClassConstants.dateFormat)
                }
                if let checkInFromdate = rentalAlert.earliestCheckInDate {
                    rentalSearchDatesRequest.checkInFromDate = Helper.convertStringToDate(dateString:checkInFromdate, format:Constant.MyClassConstants.dateFormat)
                }
                rentalSearchDatesRequest.resorts = rentalAlert.resorts
                rentalSearchDatesRequest.destinations = rentalAlert.destinations
                
                Constant.MyClassConstants.dashBoardAlertsArray = Constant.MyClassConstants.getawayAlertsArray
                self.readDates(accessToken: accessToken, request: rentalSearchDatesRequest, rentalAlert: rentalAlert)
            }
            .onError { [weak self] error in
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
    }
    
    func readDates(accessToken: DarwinAccessToken, request: RentalSearchDatesRequest, rentalAlert: RentalAlert) {
        ClientAPI.sharedInstance.readDates(for: accessToken, and: request)
            .then { rentalSearchDatesResponse in
                self.hideHudAsync()
                intervalPrint("____-->\(rentalSearchDatesResponse)")
                Constant.MyClassConstants.searchDateResponse.append(rentalAlert, rentalSearchDatesResponse)
                Helper.performSortingForMemberNumberWithViewResultAndNothingYet()
                
            }
            .onError { [weak self] error in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
    }
    
    //***** Create a new alert button action. *****//
    @IBAction func createNewAlertButtonPressed(_ sender: AnyObject) {
        self.alertDisplayTableView.setEditing(false, animated: true)
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
        Constant.MyClassConstants.alertSelectedDestination.removeAll()
        Constant.MyClassConstants.alertSelectedBedroom = []
        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
        self.performSegue(withIdentifier: Constant.segueIdentifiers.createAlertSegue, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Function called when nothing yet button for an alert is clicked. *****//
    func nothingYetClicked() {
        
        let alertController = UIAlertController(title: title, message: Constant.AlertErrorMessages.getawayAlertMessage, preferredStyle: .alert)
        let startSearch = UIAlertAction(title: Constant.AlertPromtMessages.newSearch, style: .default) { (_:UIAlertAction)  in
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
            if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
        }
        
        let close = UIAlertAction(title: Constant.AlertPromtMessages.close, style: .default) { (_:UIAlertAction) in
            
        }
        //Add Custom Actions to Alert viewController
        alertController.addAction(startSearch)
        alertController.addAction(close)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    //***** Function called when view results for an active alerts is clicked ****//
    func viewResultsClicked(_ sender: UIButton) {
        
        // This is not correct. I refactored this code but why is getawayAlertsArray and alertsDictionary the same object type?
        // Also why is SDK sending Int64? This forces an unsual casting. Also our numbers are small, they dont need so many bits.
        // Need to revisit our models
        
        // Changed code so that values are always taken from Constant.MyClassConstants.searchDateResponse
        
        for (alert, searchDatesResponse) in Constant.MyClassConstants.searchDateResponse {
            intervalPrint(alert.alertId ?? -1, sender.tag)
            if String(describing: alert.alertId ?? -1) == String(sender.tag) {
                self.searchDateResponse = searchDatesResponse
                pushRentalAlertView(alertID: Int(alert.alertId ?? -1), getawayAlert: alert)
            }
        }
    }
    
    //Function for no results availability
    func noResultsAvailability() {
        Constant.MyClassConstants.noAvailabilityView = true
        self.navigateToSearchResults()
    }
    
    //Function for rental search availability
    func rentalSearchAvailability(activeInterval: BookingWindowInterval) {
        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
        Helper.helperDelegate = self
        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat), senderViewController: self)
        
    }
    
    //Function for navigating to search results
    func navigateToSearchResults() {
        
        if Constant.MyClassConstants.isRunningOnIphone {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? SearchResultViewController {
                viewController.alertFilterOptionsArray = alertFilterOptionsArray
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? VacationSearchResultIPadController {
                viewController.alertFilterOptionsArray = alertFilterOptionsArray
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func createSearchCriteriaFor(alert: RentalAlert) -> VacationSearchCriteria {
        // Split destinations and resorts to create multiples VacationSearchCriteria
        let checkInDate = alert.getCheckInDate()
        
        let searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.RENTAL)
        searchCriteria.checkInDate = Helper.convertStringToDate(dateString: checkInDate, format: Constant.MyClassConstants.dateFormat)
        if let earliestCheckInDate = alert.earliestCheckInDate {
            searchCriteria.checkInFromDate = Helper.convertStringToDate(dateString: earliestCheckInDate, format: Constant.MyClassConstants.dateFormat)
        }
        if let latestCheckInDate = alert.latestCheckInDate {
            searchCriteria.checkInToDate = Helper.convertStringToDate(dateString: latestCheckInDate, format: Constant.MyClassConstants.dateFormat)
        }
        getDestinationsResortsForAlert(alert:alert, searchCriteria: searchCriteria)
        alertFilterOptionsArray.removeAll()
        
        for destination in alert.destinations {
            let dest = AreaOfInfluenceDestination()
            if let destinationName = destination.destinationName {
                dest.destinationName = destinationName
            } else {
                dest.destinationName = "Cancun"
            }
            dest.aoiId = destination.aoiId
            dest.destinationId = destination.destinationId
            alertFilterOptionsArray
                .append(Constant.AlertResortDestination.Destination(dest))
        }
        for resort in alert.resorts {
            let alertResort = Resort()
            alertResort.resortName = resort.resortName
            alertResort.resortCode = resort.resortCode
            alertFilterOptionsArray
                .append(Constant.AlertResortDestination.Resort(resort))
        }
        return searchCriteria
    }
    
    // MARK: - Get data for an alert
    func getDestinationsResortsForAlert(alert: RentalAlert, searchCriteria: VacationSearchCriteria) {
        if !alert.destinations.isEmpty {
            let destination = AreaOfInfluenceDestination()
            if let destinationName = alert.destinations[0].destinationName {
                destination.destinationName = destinationName
            } else {
                destination.destinationName  = "Cancun"
            }
            destination.destinationId = alert.destinations[0].destinationId
            destination.aoiId = alert.destinations[0].aoiId
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if !alert.resorts.isEmpty {
            searchCriteria.resorts = alert.resorts
            if let resortName = alert.resorts[0].resortName {
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(resortName) + \(alert.resorts.count) more"
            }
        }
    }
    
    // MARK: - Private functions
    
    private func pushRentalAlertView(alertID: Int, getawayAlert: RentalAlert) {
        // Horrible code
        // Need to refactor this omg...
        
        //Changed code here. Please review
        
        showHudAsync()
        let searchCriteria = createSearchCriteriaFor(alert: getawayAlert)
        
        if let settings = Session.sharedSession.appSettings {
            Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
        }
 
        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = searchDateResponse
        
        // Get activeInterval
        let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
        
        // Update active interval
        Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
        
        Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
        
        // Check not available checkIn dates for the active interval
        if let activeInterval = activeInterval, activeInterval.hasCheckInDates() {
            self.rentalSearchAvailability(activeInterval: activeInterval)
        } else {
            self.noResultsAvailability()
        }
        
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.getawayAlerts
        Constant.MyClassConstants.resortsArray.removeAll()
        
    }
}

extension GetawayAlertsIPhoneViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here. *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let getawayAlert = Constant.MyClassConstants.searchDateResponse[indexPath.row].0
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: Constant.buttonTitles.remove) { [unowned self] (action, index) -> Void in
            if let alertID = getawayAlert.alertId {
                self.showHudAsync()
                //Remove Alert API call
                RentalClient.removeAlert(Session.sharedSession.userAccessToken, alertId: alertID, onSuccess: { () in
                    self.hideHudAsync()
                    Constant.MyClassConstants.searchDateResponse.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    tableView.beginUpdates()
                    tableView.reloadSections(NSIndexSet(index:indexPath.section) as IndexSet, with: .automatic)
                    tableView.endUpdates()
                    
                }) {[unowned self] error in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.handleError(error))
                }
            } else {
                self.presentErrorAlert(UserFacingCommonError.generic)
            }
        }
        delete.backgroundColor = UIColor(red: 224 / 255.0, green: 96.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        
        guard let alertStatus =  getawayAlert.enabled else {
            return []
        }
        
        guard let alertCheckInDate = getawayAlert.earliestCheckInDate?.dateFromFormat(Constant.MyClassConstants.dateFormat) else {
           return []
        }
        
        if !alertStatus && alertCheckInDate.isAfter(Date()) {
            let activate = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.activate) { (action, index) -> Void in
                self.showHudAsync()
                let editedAlert = getawayAlert
                editedAlert.enabled = true
                RentalClient.updateAlert(Session.sharedSession.userAccessToken, alert: editedAlert, onSuccess: { [weak self] _ in
                    self?.hideHudAsync()
                    self?.presentAlert(with: "", message: "Alert updated sucessfully".localized())
                }) { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                }
            }
            activate.backgroundColor = UIColor(red: 0 / 255.0, green: 119.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
            return [delete, activate]
            
        } else {
            
            let edit = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.edit) { (action, index) -> Void in
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
                
                Constant.selectedAlertToEdit = Constant.MyClassConstants.searchDateResponse[indexPath.row].0
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
                guard let alertToEdit = Constant.selectedAlertToEdit else { return }
                
                for destination in alertToEdit.destinations {
                    Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.destination(destination))
                }
                
                for resort in alertToEdit.resorts {
                 Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.resort(resort))
                }
                
                var selectedBedroomsizes = [String]()
                for unitSize in alertToEdit.unitSizes {
                    let friendlyName = unitSize.friendlyName()
                    let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: friendlyName)
                    selectedBedroomsizes.append(bedroomSize)
                }
                if selectedBedroomsizes.count == 5 {
                    Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.allBedrommSizes
                } else {
                    Constant.MyClassConstants.selectedBedRoomSize = selectedBedroomsizes.joined(separator: ", ")
                }
                self.performSegue(withIdentifier: Constant.segueIdentifiers.editAlertSegue, sender: self)
                
            }
            edit.backgroundColor = #colorLiteral(red: 0, green: 0.4666666667, blue: 0.7450980392, alpha: 1)
            return [delete, edit]
        }
    }
}

extension GetawayAlertsIPhoneViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.MyClassConstants.searchDateResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (getawayAlert, searchDateResponse) = Constant.MyClassConstants.searchDateResponse[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.getawayScreenReusableIdentifiers.getawayAlertCell, for: indexPath) as? AlertTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.alertNameLabel.text = getawayAlert.name
        
        let alertFromDate = Helper.convertStringToDate(dateString: getawayAlert.earliestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
        let fromDate = (Helper.getWeekDay(dateString: alertFromDate, getValue: "Month")).appendingFormat(". ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: "Date")).appending(", ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: "Year"))
        let alertToDate = Helper.convertStringToDate(dateString: getawayAlert.latestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
        let toDate = Helper.getWeekDay(dateString: alertToDate, getValue: "Month").appending(". ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: "Date")).appending(", ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: "Year"))
        
        let dateRange = fromDate.appending(" - " + toDate)
        
        cell.alertDateLabel.text = dateRange
        
        if getawayAlert.enabled ?? false {
            cell.alertStatusButton.isHidden = true
            cell.alertStatusButton.backgroundColor = UIColor(red: 240.0 / 255.0, green: 111.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
            cell.alertStatusButton.setTitleColor(UIColor.white, for: .normal)
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        } else {
            cell.alertStatusButton.isHidden = false
            cell.activityIndicator.isHidden = true
        }
        
        if !self.individualActivityIndicatorNeedToShow {
            if let alertId = getawayAlert.alertId {
                cell.alertStatusButton.tag = Int(alertId)
            }
            if searchDateResponse.checkInDates.isEmpty {
                
                cell.alertStatusButton.isHidden = false
                cell.alertStatusButton.setTitle(Constant.buttonTitles.noResultYet, for: .normal)
                cell.alertStatusButton.backgroundColor = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
                cell.alertStatusButton.setTitleColor(UIColor.lightGray, for: .normal)
                
                cell.alertNameLabel.textColor = UIColor.black
                cell.alertStatusButton.layer.borderColor = UIColor.lightGray.cgColor
                cell.alertStatusButton.removeTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
                cell.alertStatusButton.addTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
                cell.activityIndicator.isHidden = true
            } else {
                
                cell.alertStatusButton.isHidden = false
                cell.alertStatusButton.setTitle(Constant.buttonTitles.viewResults, for: .normal)
                cell.alertStatusButton.removeTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
                cell.alertStatusButton.addTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
                cell.alertNameLabel.textColor = IUIKColorPalette.primaryB.color
                cell.activityIndicator.isHidden = true
                cell.alertStatusButton.layer.borderColor = UIColor(red: 240.0 / 255.0, green: 111.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0).cgColor
            }
        } else {
            cell.alertStatusButton.isHidden = false
            cell.alertStatusButton.setTitle(Constant.buttonTitles.noResultYet, for: .normal)
            cell.alertStatusButton.backgroundColor = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
            cell.alertStatusButton.setTitleColor(UIColor.lightGray, for: .normal)
            
            cell.alertNameLabel.textColor = UIColor.black
            cell.alertStatusButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.alertStatusButton.removeTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
            cell.alertStatusButton.addTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
            cell.activityIndicator.isHidden = true
        }
        return cell
    }
    
    //***** Function to enable Swap deletion functionality *****//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension GetawayAlertsIPhoneViewController: HelperDelegate {
    func resortSearchComplete() {
        hideHudAsync()
        // Check if not has availability in the desired check-In date.
        if Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat) {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        navigateToSearchResults()
    }
}
