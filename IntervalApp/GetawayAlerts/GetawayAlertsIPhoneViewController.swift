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
    
    private var alertsDictionary:NSMutableDictionary = [:]
    var alertsSearchDates:NSMutableDictionary = [:]
    private var alertsResortCodeDictionary:NSMutableDictionary = [:]
    var alertName : String!
    var alertId : Int64!
    var alertStatusId = 0
    var alertFilterOptionsArray = [Constant.AlertResortDestination]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        //***** Adding notification to reload table when all alerts have been fetched *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAlertsTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        //TODO-JHON: Forcing alertBadge to disappear, review after pushnotifications are working.
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        alertDisplayTableView.reloadData()
    }
    
    //***** Function for notification for all alerts *****//
    
    func reloadAlertsTableView(){
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constant.segueIdentifiers.editAlertSegue){
            let viewController = segue.destination as! EditMyAlertIpadViewController
            viewController.editAlertName = self.alertName
            viewController.alertId = self.alertId
        }
    }
    
    //**** Function for vacation search for an alert ****//
    
    //**** Function for more button action ****//
    func moreNavButtonPressed(sender:UIBarButtonItem){
        
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.getwayAlertOptions, message: "", preferredStyle: .actionSheet)
        
        let attributedText = NSMutableAttributedString(string: Constant.buttonTitles.getwayAlertOptions)
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16.0)!, range: range)
        actionSheetController.setValue(attributedText, forKey: Constant.actionSheetAttributedString.attributedTitle)
        //***** Create and add the View my recent search *****//
        let searchAllMyAlertsNow: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.searchAllMyAlertsNow, style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.alertDisplayTableView.reloadData()
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
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        if(Constant.RunningDevice.deviceIdiom == .pad){
            
            actionSheetController.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.size.width,y:0, width:100, height:60)
            actionSheetController.popoverPresentationController?.permittedArrowDirections = .up;
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    //***** Create a new alert button action. *****//
    @IBAction func createNewAlertButtonPressed(_ sender: AnyObject){
        self.alertDisplayTableView.setEditing(false, animated: true)
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
        Constant.MyClassConstants.alertSelectedBedroom = []
        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
        self.performSegue(withIdentifier: Constant.segueIdentifiers.createAlertSegue, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Function called when nothing yet button for an alert is clicked. *****//
    func nothingYetClicked(){
        
        let alertController = UIAlertController(title: title, message: Constant.AlertErrorMessages.getawayAlertMessage, preferredStyle: .alert)
        let startSearch = UIAlertAction(title: Constant.AlertPromtMessages.newSearch, style: .default) { (action:UIAlertAction!) in
            
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
            if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
        }
        
        let close = UIAlertAction(title: Constant.AlertPromtMessages.close, style: .default) { (action:UIAlertAction!) in
            
        }
        
        //Add Custom Actions to Alert viewController
        alertController.addAction(startSearch)
        alertController.addAction(close)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    
    //***** Function called when view results for an active alerts is clicked ****//
    func viewResultsClicked(_ sender:UIButton) {
        
        for alertWithDates in Constant.MyClassConstants.getawayAlertsArray{
            if let clickedAlertId = alertWithDates.alertId{
                if(Int(clickedAlertId) == sender.tag){
                    
                    var getawayAlert = RentalAlert()
                    getawayAlert = Constant.MyClassConstants.alertsDictionary.value(forKey: String(describing: clickedAlertId)) as! RentalAlert
                    
                    let searchCriteria = createSearchCriteriaFor(alert: getawayAlert)
                    let settings = Helper.createSettings()
                    
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
                    
                    RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request,
                                             onSuccess
                        : { (response) in
                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                            
                            // Get activeInterval
                            let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                            
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            
                            // Check not available checkIn dates for the active interval
                            if (activeInterval?.fetchedBefore) != nil && activeInterval?.hasCheckInDates() != nil{
                                (activeInterval?.hasCheckInDates())! ? () : Helper.showNotAvailabilityResults()
                                self.navigateToSearchResults()
                            }else {
                                Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                Helper.helperDelegate = self
                                if let searchDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate{
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: searchDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                }
                            }
                            
                    },
                                             onError
                        :{ (error) in
                            
                            
                    }
                    )
                }
            }
            
        }
        
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.getawayAlerts
        Constant.MyClassConstants.resortCodesArray = Constant.MyClassConstants.alertsResortCodeDictionary.value(forKey: String(sender.tag)) as! [String]
        Constant.MyClassConstants.checkInDates = self.alertsSearchDates.value(forKey: String(sender.tag)) as! [Date]
        Constant.MyClassConstants.resortsArray.removeAll()
        Constant.MyClassConstants.searchResultCollectionViewScrollToIndex = 1
        
        showHudAsync()
        let checkInDates:NSArray = self.alertsSearchDates.value(forKey: String(sender.tag)) as! NSArray
        if(checkInDates.count > 0){
            Constant.MyClassConstants.currentFromDate = checkInDates[0] as! Date
        }else{
            Constant.MyClassConstants.currentFromDate =  Date()
        }
    }
    
    //Function for navigating to search results
    func navigateToSearchResults(){
        if Constant.MyClassConstants.isRunningOnIphone {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            self.navigationController?.pushViewController(viewController, animated: true)
            
        } else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! VacationSearchResultIPadController
            viewController.alertFilterOptionsArray = alertFilterOptionsArray
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    func createSearchCriteriaFor(alert:RentalAlert) -> VacationSearchCriteria {
        // Split destinations and resorts to create multiples VacationSearchCriteria
        let checkInDate = alert.getCheckInDate()
        
        let searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
        searchCriteria.checkInDate = Helper.convertStringToDate(dateString: checkInDate, format: Constant.MyClassConstants.dateFormat)
        if let earliestCheckInDate = alert.earliestCheckInDate{
            searchCriteria.checkInFromDate = Helper.convertStringToDate(dateString: earliestCheckInDate, format: Constant.MyClassConstants.dateFormat)
        }
        if let latestCheckInDate = alert.latestCheckInDate{
            searchCriteria.checkInToDate = Helper.convertStringToDate(dateString: latestCheckInDate, format: Constant.MyClassConstants.dateFormat)
        }
        getDestinationsResortsForAlert(alert:alert, searchCriteria: searchCriteria)
        alertFilterOptionsArray.removeAll()
        
        for destination in alert.destinations{
            let dest = AreaOfInfluenceDestination()
            if let destinationName = destination.destinationName{
                dest.destinationName = destinationName
            }else{
                dest.destinationName = "Cancun"
            }
            dest.aoiId = destination.aoiId
            dest.destinationId = destination.destinationId
            alertFilterOptionsArray
                .append(Constant.AlertResortDestination.Destination(dest))
        }
        
        for resort in alert.resorts{
            let alertResort = Resort()
            alertResort.resortName = resort.resortName
            alertResort.resortCode = resort.resortCode
            alertFilterOptionsArray
                .append(Constant.AlertResortDestination.Resort(resort))
        }
        return searchCriteria
    }
    
    //MARK:- Get data for an alert
    func getDestinationsResortsForAlert(alert:RentalAlert, searchCriteria:VacationSearchCriteria){
        if((alert.destinations.count) > 0){
            let destination = AreaOfInfluenceDestination()
            if let destinationName = alert.destinations[0].destinationName{
                destination.destinationName  = destinationName
            }else{
                destination.destinationName  = "Cancun"
            }
            destination.destinationId = alert.destinations[0].destinationId
            destination.aoiId = alert.destinations[0].aoiId
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        }else if((alert.resorts.count) > 0){
            Constant.MyClassConstants.initialVacationSearch.searchCriteria.resorts = alert.resorts
        }
    }
}

extension GetawayAlertsIPhoneViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here. *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: Constant.buttonTitles.remove) { (action,index) -> Void in
            
            
        //Remove Alert API call
        RentalClient.removeAlert(Session.sharedSession.userAccessToken, alertId: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId!, onSuccess: { () in
            
        Constant.MyClassConstants.getawayAlertsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                tableView.reloadSections(NSIndexSet(index:indexPath.section) as IndexSet, with: .automatic)
            })
        }) { (error) in
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
        }   
        }
        delete.backgroundColor = UIColor(red: 224/255.0, green: 96.0/255.0, blue: 84.0/255.0, alpha: 1.0)
        
        if(Constant.MyClassConstants.getawayAlertsArray[indexPath.row].enabled == false){
            let activate = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.activate) { (action,index) -> Void in
                
            }
            activate.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            return [delete,activate]
            
        }else{
            
            let edit = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.edit) { (action,index) -> Void in
                Constant.MyClassConstants.selectedBedRoomSize = "All Bedroom Sizes"
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAllObjects()
                
                let destination = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].destinations
                for dest in destination {
                    
                    Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(dest)
                }
                let resorts = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].resorts
                for resort in resorts {
                    
                    Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(resort)
                }
                
                self.alertName = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name
                self.alertId = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                self.performSegue(withIdentifier: Constant.segueIdentifiers.editAlertSegue, sender: self)
                
            }
            edit.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            return [delete,edit]
        }
    }
}

extension GetawayAlertsIPhoneViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.MyClassConstants.getawayAlertsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.getawayScreenReusableIdentifiers.getawayAlertCell, for: indexPath as IndexPath) as! AlertTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.alertNameLabel.text = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name
        
        if let stringAlertFromDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].earliestCheckInDate{
            let alertFromDate = Helper.convertStringToDate(dateString: stringAlertFromDate, format: Constant.MyClassConstants.dateFormat)
            let fromDate = (Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.month)).appendingFormat(". ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertFromDate, getValue: Constant.MyClassConstants.year))
            let alertToDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].latestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
            let toDate = Helper.getWeekDay(dateString: alertToDate, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertToDate, getValue: Constant.MyClassConstants.year))
            
            let dateRange = fromDate.appending(" - " + toDate)
            
            cell.alertDateLabel.text = dateRange
        }
        
        if Constant.MyClassConstants.getawayAlertsArray[indexPath.row].enabled == true{
            cell.alertStatusButton.isHidden = true
            cell.alertStatusButton.backgroundColor = UIColor(red: 240.0/255.0, green: 111.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            cell.alertStatusButton.setTitleColor(UIColor.white, for: .normal)
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }else{
            cell.alertStatusButton.isHidden = false
            cell.activityIndicator.isHidden = true
        }
        
        if let alertId = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId{
            cell.alertStatusButton.tag = Int(alertId)
            let value = Constant.MyClassConstants.alertsSearchDatesDictionary.value(forKey: String(describing: alertId))
            if value != nil{
                var checkInDates = NSArray()
                if Constant.MyClassConstants.alertsSearchDatesDictionary.count > 0 {
                    checkInDates = value as! NSArray
                    if checkInDates.count == 0 {
                        
                        cell.alertStatusButton.isHidden = false
                        cell.alertStatusButton.setTitle(Constant.buttonTitles.nothingYet, for: .normal)
                        cell.alertStatusButton.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                        cell.alertStatusButton.setTitleColor(UIColor.lightGray, for: .normal)
                        
                        cell.alertNameLabel.textColor = UIColor.black
                        cell.alertStatusButton.layer.borderColor = UIColor.lightGray.cgColor
                        cell.alertStatusButton.removeTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
                        cell.alertStatusButton.addTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
                        cell.activityIndicator.isHidden = true
                    }
                    else {
                        
                        cell.alertStatusButton.isHidden = false
                        cell.alertStatusButton.setTitle(Constant.buttonTitles.viewResults, for: .normal)
                        self.alertsSearchDates.setValue(checkInDates, forKey: String(cell.alertStatusButton.tag))
                        cell.alertStatusButton.removeTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
                        cell.alertStatusButton.addTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
                        cell.alertNameLabel.textColor = IUIKColorPalette.primaryB.color
                        cell.activityIndicator.isHidden = true
                        cell.alertStatusButton.layer.borderColor = UIColor(red: 240.0/255.0, green: 111.0/255.0, blue: 54.0/255.0, alpha: 1.0).cgColor
                    }
                }else{
                    cell.alertStatusButton.isHidden = false
                    cell.alertStatusButton.setTitle(Constant.buttonTitles.nothingYet, for: .normal)
                    cell.alertStatusButton.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                    cell.alertStatusButton.setTitleColor(UIColor.lightGray, for: .normal)
                    
                    cell.alertNameLabel.textColor = UIColor.black
                    cell.alertStatusButton.layer.borderColor = UIColor.lightGray.cgColor
                    cell.alertStatusButton.removeTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
                    cell.alertStatusButton.addTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
                    cell.activityIndicator.isHidden = true
                }
            }
        }
        return cell
    }
    
    //***** Function to enable Swap deletion functionality *****//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension GetawayAlertsIPhoneViewController:HelperDelegate {
    func resortSearchComplete(){
        hideHudAsync()
        // Check if not has availability in the desired check-In date.
        if Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat) {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
        viewController.alertFilterOptionsArray = alertFilterOptionsArray
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func resetCalendar(){
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
    }
}

