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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButtonright = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(FlexchangeSearchViewController.menuButtonClicked))
        menuButtonright.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = menuButtonright
        
        
        // Adding navigation back button
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(FlexchangeSearchViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Adding controller title
        self.title = Constant.ControllerTitles.flexChangeSearch
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
     
        _ = self.navigationController?.popViewController(animated: true)
      
        
    }
    
     //**** Option to open menu from bottom ***//
    
    func menuButtonClicked()  {
        
        
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.searchOption, message: "", preferredStyle: .actionSheet)
        
        
        let helpAction: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.help, style: .default) { action -> Void in
            //Just dismiss the action sheet
        }
            
         actionSheetController.addAction(helpAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
        
    }
    
   
    
    func addRelinquishmentSectionButtonPressed(_ sender:IUIKButton) {
        Helper.showProgressBar(senderView: self)
        ExchangeClient.getMyUnits(UserContext.sharedInstance.accessToken, onSuccess: { (Relinquishments) in
            
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if(Relinquishments.pointsProgram != nil){
                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram!
                
                if (Relinquishments.pointsProgram!.availablePoints != nil) {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram!.availablePoints!
                }
                
            }
            
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as! RelinquishmentSelectionViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
            
        }, onError: {(error) in
            Helper.hideProgressBar(senderView: self)
        })
        
    }
    
    
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        Helper.helperDelegate = self
        if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
            
            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
            Helper.hideProgressBar(senderView: self)
            
        }else{
            
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
                area.areaCode = (selectedFlexchange?.areaCode)!
                area.areaName = selectedFlexchange?.name
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = area.areaName!
                
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
            
        }
        
        
    }
    

    
    func navigateToSearchResults(){
        
        //Constant.MyClassConstants.vacationSearchResultHeaderLabel = (Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: Constant.MyClassConstants.selectedAreaCodeArray[0] as! String) as? String)!
        Constant.MyClassConstants.filteredIndex = 0
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
}




extension FlexchangeSearchViewController:UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** return height for  row in each section of tableview *****//
        if(indexPath.section == 0){
           
            return 80
            
        }else if (indexPath.section == 1){
            
            return 80
            
        } else{
            
            return 60
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.flexChangeTableView.frame.size.width, height: 50))
                let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width, height: 50))
        
        if section == 1 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = "Where do you want to trade"
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
         
        }else if section == 0 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = "Your selected flexchange destination"
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
            
        }else{
            
            return nil
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            
            return 50
        }
        else if section == 0{
            
            return 50
            
        } else{
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1 && Constant.MyClassConstants.whatToTradeArray.count > 0) {
            if indexPath.row == 0 {
                return true
            }else {
                return false
            }
            
        }else {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
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
                    
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    
                    tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .automatic)
                    Helper.InitializeOpenWeeksFromLocalStorage()
                }
            }
        }
        
        delete.backgroundColor = UIColor(red: 224/255.0, green: 96.0/255.0, blue: 84.0/255.0, alpha: 1.0)
        return [delete]
    }
    
    
    


}


extension FlexchangeSearchViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
           
            return Constant.MyClassConstants.whatToTradeArray.count + 1
            
        }else {
            
            return 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FlexChangeDestination", for: indexPath) as! FlexchangeDestinationCell
            
            cell.lblFlexchangeDestination.text = selectedFlexchange?.name
            
            return cell
        }else if(indexPath.section == 1){
            
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
                addLocationButton.addTarget(self, action: #selector(FlexchangeSearchViewController.addRelinquishmentSectionButtonPressed(_:)), for: .touchUpInside)
                
                cell.addSubview(addLocationButton)
                cell.backgroundColor = UIColor.clear
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
                cell.backgroundColor = UIColor.clear
                return cell
            }
            
            
          
            
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FlexchangeSearchButtonCell", for: indexPath) as! SearchFlexchangeButtonCell
            
            cell.searchButton.layer.cornerRadius = 5
            return cell
        }
    
    }
    
    
}


extension FlexchangeSearchViewController:HelperDelegate {
    
    func resetCalendar() {
        
    }

 
    func resortSearchComplete(){
       
        self.navigateToSearchResults()
    }
    

}

