//
//  FlexChangeSearchIpadViewController.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 9/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SVProgressHUD
import DarwinSDK
import QuartzCore
import RealmSwift

class FlexChangeSearchIpadViewController: UIViewController {
    
    //MARK:- clas  outlets
    @IBOutlet weak var flexchangeSearchTableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    //MARK:- class varibles
    
    var selectedFlexchange: FlexExchangeDeal?
    var destinationOrResort = Helper.getLocalStorageWherewanttoGo()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.title = Constant.ControllerTitles.flexChangeSearch
        
        //set corner radius
        
        self.searchButton.layer.cornerRadius = 7
  
        // set navigation right bar buttons
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(FlexChangeSearchIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = menuButton
        
        // custom back button
        
        let menuButtonleft = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(FlexChangeSearchIpadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButtonleft

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.flexchangeSearchTableView.reloadData()
        Helper.getLocalStorageWherewanttoTrade()
    }
    
    
    //*** Change frame layout while change iPad in Portrait and Landscape mode.***//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if(Constant.RunningDevice.deviceIdiom == .pad){
            frameChangeOnPortraitandLandscape()
        }
        
    }
    
    func frameChangeOnPortraitandLandscape(){
        
        if(UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight){
            self.flexchangeSearchTableView.reloadData()
            
        }
        
        self.flexchangeSearchTableView.reloadData()
    
    }

    func navigateToSearchResults(){
        
       // Constant.MyClassConstants.vacationSearchResultHeaderLabel = (Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: Constant.MyClassConstants.selectedAreaCodeArray[0] as! String) as? String)!
        Constant.MyClassConstants.filteredIndex = 0
        
        Constant.MyClassConstants.vacationSearchResultHeaderLabel = (selectedFlexchange?.name)!
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! VacationSearchResultIPadController
        
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- button events
    
    func menuButtonClicked() {
        print("menu button clicked")
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        
        if(Constant.MyClassConstants.relinquishmentIdArray.count == 0) {
            return SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
            
        }
        
        Helper.helperDelegate = self
        
        showHudAsync()
        if Reachability.isConnectedToNetwork() == true {
            
            let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
            
            exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
            exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
            exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
            exchangeSearchCriteria.searchType = VacationSearchType.Exchange
            
            
            //let storedData = Helper.getLocalStorageWherewanttoGo()
            
            exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
            Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, exchangeSearchCriteria)
            let area = Area()
            area.areaCode = (selectedFlexchange?.areaCode)!
            area.areaName = selectedFlexchange?.name
            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request.areas = [area]
            
            
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
                    
                }else{
                    
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                }
                
            }, onError: { (error) in
                
                self.hideHudAsync()
                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            })
            
            
        }
        
    }
    
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func addRelinquishmentSectionButtonPressed(_ sender:IUIKButton) {
        
        showHudAsync()
        ExchangeClient.getMyUnits(Session.sharedSession.userAccessToken, onSuccess: { (Relinquishments) in
            
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if(Relinquishments.pointsProgram != nil){
                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram!
                
                if (Relinquishments.pointsProgram!.availablePoints != nil) {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram!.availablePoints!
                }
                
            }
            
            
            SVProgressHUD.dismiss()
            self.hideHudAsync()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as! RelinquishmentSelectionViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            Constant.MyClassConstants.viewController = self
            self.navigationController!.pushViewController(viewController, animated: true)
            
        }, onError: {(error) in
            self.hideHudAsync()
        })
        
    }

}

//MARK:- table view datasource
extension FlexChangeSearchIpadViewController:UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            
            return Constant.MyClassConstants.whatToTradeArray.count + 1
            
        }else {
            
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.flexChangeDestinationCell, for: indexPath) as! FlexchangeDestinationCell
            cell.lblFlexchangeDestination.text = selectedFlexchange?.name
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else {
            
            if((Constant.MyClassConstants.whatToTradeArray.count == 0 && Constant.MyClassConstants.pointsArray.count == 0) || (indexPath as NSIndexPath).row == (Constant.MyClassConstants.whatToTradeArray.count)) {
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                
                let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width/2 - (cell.contentView.bounds.width/5)/2, y: 15, width: cell.contentView.bounds.width/5, height: 30))
                
                addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
                addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                addLocationButton.layer.cornerRadius = 6
                addLocationButton.layer.borderWidth = 2
                addLocationButton.addTarget(self, action: #selector(FlexChangeSearchIpadViewController.addRelinquishmentSectionButtonPressed(_:)), for: .touchUpInside)
                
                cell.addSubview(addLocationButton)
                cell.backgroundColor = UIColor.white
                return cell
            }
                
            else {
                
                let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoContentCell, for: indexPath) as! WhereToGoContentCell
                
                if((indexPath as NSIndexPath).row == Constant.MyClassConstants.whatToTradeArray.count - 1) {
                    
                    cell.sepratorOr.isHidden = true
                }
                else {
                    
                    cell.sepratorOr.isHidden = false
                }
                
                let object = Constant.MyClassConstants.whatToTradeArray[indexPath.row]
                if((object as AnyObject) .isKind(of: OpenWeek.self)){
                    let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeek).weekNumber)!)
                    cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeek).resort!.resortName!), \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeek).relinquishmentYear!) Week \(weekNumber)"
                    cell.bedroomLabel.isHidden = true
                    
                }else if((object as AnyObject).isKind(of: OpenWeeks.self)){
                    
                    let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).weekNumber))
                    print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isLockOff)
                    if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isLockOff || (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isFloat){
                        cell.bedroomLabel.isHidden = false
                        
                        let resortList = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).unitDetails
                        if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).isFloat){
                            let floatDetails = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).floatDetails
                            if(floatDetails[0].showUnitNumber){
                                cell.bedroomLabel.text = "\(floatDetails[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                            }else{
                                
                                cell.bedroomLabel.text = "\(floatDetails[0].unitSize), \(resortList[0].kitchenType)"
                            }
                            
                        }else{
                            
                            cell.bedroomLabel.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                        
                    }else{
                        cell.bedroomLabel.isHidden = true
                    }
                    
                    if(weekNumber != ""){
                        
                        cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName)/ \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).relinquishmentYear), Wk\(weekNumber)"
                        
                    }else{
                        
                        cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName)/ \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).relinquishmentYear)"
                    }
                    
                } else if((object as AnyObject) .isKind(of: Deposits.self)){
                    
                    //Deposits
                    let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).weekNumber))
                    
                    if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isLockOff || (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isFloat){
                        cell.bedroomLabel.isHidden = false
                        
                        let resortList = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).unitDetails
                        print((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).resort[0].resortName, resortList.count)
                        
                        if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isFloat){
                            
                            let floatDetails = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).floatDetails
                            cell.bedroomLabel.text = "\(resortList[0].unitSize), \(floatDetails[0].unitNumber), \(resortList[0].kitchenType)"
                        }else{
                            cell.bedroomLabel.text = "\(resortList[0].unitSize), \(resortList[0].kitchenType)"
                        }
                        
                    }else{
                        cell.bedroomLabel.isHidden = true
                    }
                    
                    if(weekNumber != ""){
                        
                        cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).resort[0].resortName)/ \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).relinquishmentYear), Wk\(weekNumber)"
                        
                    }else{
                        
                        cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).resort[0].resortName)/ \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).relinquishmentYear)"
                    }
                    
                } else{
                    
                    let availablePointsNumber = Constant.MyClassConstants.relinquishmentAvailablePointsProgram as NSNumber
                    
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    
                    let availablePoints = numberFormatter.string(from: availablePointsNumber)
                    
                    cell.whereTogoTextLabel.text = "\(Constant.getDynamicString.clubInterValPointsUpTo) \(availablePoints!)"
                    cell.bedroomLabel.isHidden = true
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.white
                return cell
            }
            
        }
    }
    
}

//MARK:- table view delegate
extension FlexChangeSearchIpadViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch((indexPath as NSIndexPath).section) {
        case 0 :
            if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whereTogoContentArray.count) {
                return 60
            }else {
                return 60
            }
            
        case 1:
            if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whatToTradeArray.count) {
                return 80
                //return UITableViewAutomaticDimension
            }
            else {
                return 60
            }
            
        default :
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
       // view.backgroundColor = UIColor.init(colorLiteralRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        
        view.backgroundColor = UIColor.clear

        let headerNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))

        if section == 0 {
            headerNameLabel.text = Constant.MyClassConstants.headerTextFlexchangeDestination
        } else {
            headerNameLabel.text = Constant.MyClassConstants.fourSegmentHeaderTextArray[1]
        }
        
        headerNameLabel.textAlignment = .center
        headerNameLabel.textColor = UIColor.lightGray
        headerNameLabel.font = UIFont(name:Constant.fontName.helveticaNeue, size:18)
        
        view.addSubview(headerNameLabel)
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1 && Constant.MyClassConstants.whatToTradeArray.count > 0) {
            if (indexPath.row == Constant.MyClassConstants.whatToTradeArray.count) {
                return false
            } else {
                return true
                
            }
            
            
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if (indexPath.section == 1 && Constant.MyClassConstants.whatToTradeArray.count > 0) {
            
                
                let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (action,index) -> Void in
                    // var isFloat = true
                    let storedData = Helper.getLocalStorageWherewanttoTrade()
                    
                    if(storedData.count > 0) {
                        
                        
                        let realm = try! Realm()
                        try! realm.write {
                            
                            if((Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject).isKind(of: OpenWeeks.self)){
                                
                                var floatWeekIndex = -1
                                let dataSelected = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as! OpenWeeks
                                if(dataSelected.isFloat){
                                    
                                    
                                    for (index,object) in storedData.enumerated(){
                                        let openWk1 = object.openWeeks[0].openWeeks[0]
                                        if(openWk1.relinquishmentID == dataSelected.relinquishmentID){
                                            floatWeekIndex = index
                                        }
                                    }
                                    
                                    storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloatRemoved = true
                                    storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloat = true
                                    storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFromRelinquishment = false
                                    
                                    if(Constant.MyClassConstants.whatToTradeArray.count > 0){
                                        
                                        ADBMobile.trackAction(Constant.omnitureEvents.event43, data: nil)
                                        Constant.MyClassConstants.whatToTradeArray.removeObject(at: indexPath.row)
                                        Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: indexPath.row)
                                        Constant.MyClassConstants.relinquishmentUnitsArray.removeObject(at: indexPath.row)
                                    }
                                }else{
                                    
                                    Constant.MyClassConstants.whatToTradeArray.removeObject(at: indexPath.row)
                                    Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: indexPath.row)
                                    realm.delete(storedData[indexPath.row])
                                }
                            }else{
                                Constant.MyClassConstants.whatToTradeArray.removeObject(at: indexPath.row)
                                Constant.MyClassConstants.relinquishmentIdArray.removeObject(at: indexPath.row)
                                realm.delete(storedData[indexPath.row])
                            }
                            
                            tableView.deleteRows(at: [indexPath], with: .none)
                            
                            tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .none)
                            Helper.InitializeOpenWeeksFromLocalStorage()
                        }
                    }
                }
                
                delete.backgroundColor = UIColor(red: 224/255.0, green: 96.0/255.0, blue: 84.0/255.0, alpha: 1.0)
                return [delete]
                
        } else {
            return nil
        }
        
    }
    
}


//MARK:- Helper delegate
extension FlexChangeSearchIpadViewController:HelperDelegate {
    
    func resortSearchComplete(){
        self.navigateToSearchResults()
        
    }
    
    func resetCalendar(){
        
    }
}


