//
//  VacationSearchVC.swift
//  IntervalApp
//
//  Created by Chetu-macmini-26 on 01/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import QuartzCore
import RealmSwift
import DarwinSDK
import SVProgressHUD
import SDWebImage

class VacationSearchViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var searchVacationSegementControl: UISegmentedControl!
    @IBOutlet weak var searchVacationTableView: UITableView!
    @IBOutlet var vacationSearchCollectionView:UICollectionView!
    @IBOutlet var homeTableCollectionView:UICollectionView!
    @IBOutlet var getawayCollectionView:UICollectionView!
    
    //***** Class variables *****//
    var addButtonCellTag:Int?
    var childCounter = 0
    var adultCounter = 2
    var SegmentIndex = 0
    let headerCellIndexPath = NSMutableArray()
    var destinationOrResort = Helper.getLocalStorageWherewanttoGo()
    let allDest = Helper.getLocalStorageAllDest()
    var datePickerPopupView:UIView?
    let defaults = UserDefaults.standard
    var sourceViewController:UIViewController!
    var destinationViewController:UIViewController!
    var moreButton:UIBarButtonItem?
    var showExchange = false
    var showGetaways = true
    var vacationSearch = VacationSearch()
    var searchDateRequest = RentalSearchDatesRequest()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.searchVacationTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(Constant.MyClassConstants.selectionType == 0) {
            
            // omniture tracking with event 64
            let userInfo: [String: Any] = [
                Constant.omnitureEvars.eVar25 : Constant.MyClassConstants.destinationOrResortSelectedBy,
                
                ]
            Constant.MyClassConstants.selectionType = -1
            ADBMobile.trackAction(Constant.omnitureEvents.event64, data: userInfo)
        }
        else if(Constant.MyClassConstants.selectionType == 1){
            
            Constant.MyClassConstants.selectionType = -1
            ADBMobile.trackAction(Constant.omnitureEvents.event65, data: nil)
        }
        
        destinationOrResort = Helper.getLocalStorageWherewanttoGo()
        self.getVacationSearchDetails()
        
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.parent!.navigationItem.leftBarButtonItem = menuButton
            
            //***** Creating and adding right bar button for more option button *****//
            moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(MoreNavButtonPressed(_:)))
            moreButton!.tintColor = UIColor.white
            self.parent!.navigationItem.rightBarButtonItem = moreButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
            self.searchVacationTableView.reloadData()
        }
        
        
        Helper.InitializeArrayFromLocalStorage()
        Helper.InitializeOpenWeeksFromLocalStorage()
        
        self.searchVacationTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var isPrePopulatedData =  Constant.AlertPromtMessages.no
        self.searchVacationTableView.estimatedRowHeight = 100
        
        if(Constant.MyClassConstants.whereTogoContentArray.count > 0 || Constant.MyClassConstants.whatToTradeArray.count > 0) {
            
            isPrePopulatedData = Constant.AlertPromtMessages.yes
            
        }
        // omniture tracking with event 87
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar20 : isPrePopulatedData,
            Constant.omnitureEvars.eVar21 : Constant.MyClassConstants.selectedDestinationNames,
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event87, data: userInfo)
        
        Helper.getTopDeals(senderVC: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
        
        self.getVacationSearchDetails()
        
        
        if(SegmentIndex != 2) {
            
            //***** Registering the custom cell with UITabelview *****//
            let cellNib = UINib(nibName:Constant.customCellNibNames.whoIsTravelingCell, bundle: nil)
            self.searchVacationTableView!.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.whoIsTravelingCell)
        }
        
    }
    
    
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSearchCriteriaForCancunMex() -> VacationSearchCriteria{
        
        let cancunMEXDestination = AreaOfInfluenceDestination()
        cancunMEXDestination.destinationId = "7EEF0188E4DC4B45B4A757E3DF950E1F"
        cancunMEXDestination.aoiId = "2F8C1FBA1ADA41C49E3CFE0619795FD4"
        cancunMEXDestination.destinationName = Constant.MyClassConstants.selectedDestinationNames
        cancunMEXDestination.address = Address()
        cancunMEXDestination.address?.countryCode = "MEX"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        
        let searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
        searchCriteria.destination = cancunMEXDestination
        searchCriteria.checkInDate = searchDateRequest.checkInToDate
        
        return searchCriteria
    }
    
    func createAppSetting()-> AppSettings{
        
        let appSettings = AppSettings()
        appSettings.searchByBothEnable = false
        appSettings.collapseBookingIntervalEnable = true
        appSettings.checkInSelectorStrategy = CheckInSelectorStrategy.First.rawValue
        return appSettings
    }
    
    
    // function to get vacation search details from nsuser defaults local storage
    func getVacationSearchDetails() {
        
        if let selecteddate = defaults.object(forKey: Constant.MyClassConstants.selectedDate) as? Date{
            
            if (selecteddate.isLessThanDate(Constant.MyClassConstants.todaysDate as Date)) {
                Constant.MyClassConstants.vacationSearchShowDate = Constant.MyClassConstants.todaysDate
            } else {
                Constant.MyClassConstants.vacationSearchShowDate = selecteddate
            }
        }
        else {
            let date = Date()
            Constant.MyClassConstants.vacationSearchShowDate = date
            defaults.set(date, forKey: Constant.MyClassConstants.selectedDate)
        }
        
        if let childct = defaults.object(forKey: Constant.MyClassConstants.childCounterString) {
            
            self.childCounter = childct as! Int
        }
        if let adultct = defaults.object(forKey: Constant.MyClassConstants.adultCounterString) {
            
            self.adultCounter = adultct as! Int
        }
        
    }
    
    //**** UISegment Control value change. *****//
    
    @IBAction func searchVacationSelectedSegment(_ sender: UISegmentedControl) {
        self.SegmentIndex = sender.selectedSegmentIndex
        Constant.MyClassConstants.vacationSearchSelectedSegmentIndex = sender.selectedSegmentIndex
        
        // omniture tracking with event 63
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar24 : Helper.selectedSegment(index: sender.selectedSegmentIndex)
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event63, data: userInfo)
        self.searchVacationTableView.reloadData()
        
    }
    
    //***** Calendar icon pressed action to present calendar controller *****//
    func calendarIconClicked(_ sender:IUIKButton) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event66, data: nil)
        self.performSegue(withIdentifier: Constant.segueIdentifiers.CalendarViewSegue, sender: nil)
    }
    
    //***** Add location pressed action to show map screen with list of location to select *****//
    func addLocationInSection0Pressed(_ sender:IUIKButton) {
        
        Constant.MyClassConstants.selectionType = 0
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.resortDirectoryViewController) as! GoogleMapViewController
        viewController.sourceController = Constant.MyClassConstants.vacationSearch
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearch
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
        
        
    }
    
    //***** Add location pressed action to show map screen with list of location to select *****//
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
    
    func refreshTableView(){
        Helper.removeServiceCallBackgroundView(view: self.view)
        SVProgressHUD.dismiss()
        self.searchVacationTableView.reloadData()
    }
}

//***** MARK: Extension classes starts from here *****//

extension VacationSearchViewController:UICollectionViewDelegate {
    
    //***** UICollectonview delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.topTenGetawaySelected(selectedIndexPath: indexPath)
    }
    
    
}

extension VacationSearchViewController:UICollectionViewDataSource {
    
    //***** UICollectionview dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if((Constant.MyClassConstants.topDeals.count)>0){
            return (Constant.MyClassConstants.topDeals.count)
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (self.SegmentIndex == 0){
            
        }
        let deal = Constant.MyClassConstants.topDeals[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 180) )
        resortFlaxImageView.backgroundColor = UIColor.lightGray
        
        
        if(self.SegmentIndex == 0 || self.SegmentIndex == 1) {
            
            resortFlaxImageView.setImageWith(URL(string: (deal.images[0].url) ?? ""), completed: { (image:UIImage?, error:Swift.Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                if (error != nil) {
                    resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            
            cell.addSubview(resortFlaxImageView)
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 60))
            resortImageNameLabel.text = deal.header
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold,size: 16)
            cell.addSubview(resortImageNameLabel)
            
            let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
            centerView.center = resortFlaxImageView.center
            centerView.backgroundColor = UIColor(red: 176.0/255.0, green: 215.0/255.0, blue: 115.0/255.0, alpha: 1.0)
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 15, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = deal.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 12)
            unitLabel.textColor = UIColor.white
            unitLabel.backgroundColor = UIColor.clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 35, width: centerView.frame.size.width - 20, height: 20))
            priceLabel.text = "\(Constant.getDynamicString.fromString) $" + String(describing: deal.price!.fromPrice) + "\(Constant.getDynamicString.weekString)"
            priceLabel.numberOfLines = 2
            priceLabel.textAlignment = NSTextAlignment.center
            priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
            priceLabel.textColor = UIColor.white
            priceLabel.backgroundColor = UIColor.clear
            centerView.addSubview(priceLabel)
            
            cell.addSubview(centerView)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            
        }
        
        
        return cell
    }
}

extension VacationSearchViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** Checking number of sections in tableview *****//
        if(self.SegmentIndex != 1) {
            
            //***** Return height according to section cell requirement *****//
            switch((indexPath as NSIndexPath).section) {
            case 0 :
                if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whereTogoContentArray.count) {
                    return UITableViewAutomaticDimension
                }else {
                    return 60
                }
            case 1:
                if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whatToTradeArray.count) {
                    return UITableViewAutomaticDimension
                }
                else {
                    return 60
                }
            case 2:
                return 80
            case 3:
                return 100
            case 4:
                return 70
            case 5:
                return 290
                
            default :
                return 70
                
            }
        }else {
            
            //***** Return height according to section cell requirement *****//
            switch((indexPath as NSIndexPath).section) {
            case 0 :
                if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whereTogoContentArray.count) {
                    //return 70
                    return UITableViewAutomaticDimension
                }
                else {
                    return 60
                }
            case 1:
                return 80
            //return UITableViewAutomaticDimension
            case 2:
                return 120
            case 4:
                return CGFloat(Constant.MyClassConstants.topDeals.count) * 240
                
            default :
                return 70
            }
        }
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.view.bounds.width - 30, height: 50))
        
        if(self.SegmentIndex != 1) {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.fourSegmentHeaderTextArray[section]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
        else {
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.threeSegmentHeaderTextArray[section]
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(tableView.numberOfSections == 6) {
            
            if( section < 4) {
                
                return 55
            }
            else {
                
                return 0
            }
        }
        else {
            
            if(section < 3) {
                
                return 55
            }
            else {
                
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if(indexPath.section == 0){
            
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (action,index) -> Void in
                if((indexPath as NSIndexPath).section == 0) {
                    let realm = try! Realm()
                    if(self.destinationOrResort.count > 0){
                        try! realm.write {
                            realm.delete(self.destinationOrResort[(indexPath as NSIndexPath).row])
                        }
                    }
                    else {
                        Helper.deleteObjectFromAllDest()
                    }
                    if(Constant.MyClassConstants.whereTogoContentArray.count > 0) {
                        ADBMobile.trackAction(Constant.omnitureEvents.event7, data: nil)
                        Constant.MyClassConstants.whereTogoContentArray.removeObject(at: (indexPath as NSIndexPath).row)
                    }
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .automatic)
                        Helper.InitializeArrayFromLocalStorage()
                    }
                    
                }
                else {
                    Constant.MyClassConstants.checkInClosestContentArray.removeObject(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .automatic)
                    }
                    
                }
                
            }
            
            delete.backgroundColor = UIColor(red: 224/255.0, green: 96.0/255.0, blue: 84.0/255.0, alpha: 1.0)
            
            let details = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.details) { (action,index) -> Void in
                
                let resortsArray:NSMutableArray = []
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAllObjects()
                
                for resortsToShow in Constant.MyClassConstants.whereTogoContentArray[index.row] as! List<ResortByMap>{
                    
                    let resort = Resort()
                    resort.resortName = resortsToShow.resortName
                    resort.resortCode = resortsToShow.resortCode
                    resort.address?.cityName = resortsToShow.resortCityName
                    resort.address?.territoryCode = resortsToShow.territorrycode
                    
                    resortsArray.add(resort)
                    
                }
                
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(resortsArray)
                
                if(Constant.RunningDevice.deviceIdiom == .pad){
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
                    viewController.selectedIndex = 0
                    self.navigationController!.present(viewController, animated: true, completion: nil)
                    
                }else{
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
                    viewController.selectedIndex = 0
                    self.navigationController!.present(viewController, animated: true, completion: nil)
                    
                }
            }
            
            details.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            
            let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row]
            
            if((object as AnyObject) .isKind(of: List<ResortByMap>.self)){
                return [delete,details]
            }else{
                return [delete]
            }
        }else{
            
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
}

extension VacationSearchViewController:UITableViewDataSource {
    
    //***** Function to enable Swap deletion functionality *****//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(SegmentIndex == 0 || SegmentIndex == 2){
            if(indexPath.section == 0){
                if(Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count){
                    return false
                }else{
                    return true
                }
            }else if(indexPath.section == 1){
                if(Constant.MyClassConstants.whatToTradeArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whatToTradeArray.count){
                    return false
                }else{
                    return true
                }
            }else{
                return false
            }
        }else if(indexPath.section == 0){
            if(Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count){
                return false
            }else{
                return true
            }
        }else{
            return false
        }
    }
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(self.SegmentIndex == 2) {
            if(showExchange){
                return 6
            }else{
                return 5
            }
        }
        else if(self.SegmentIndex == 1) {
            if(showGetaways){
                return 5
            }else{
                return 4
            }
        }
        else {
            if(showGetaways && showExchange){
                return 7
            }else if(!showGetaways && !showExchange){
                return 5
            }else{
                return 6
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            
        case 0:
            return Constant.MyClassConstants.whereTogoContentArray.count + 1
            
        case 1:
            if(self.SegmentIndex != 1) {
                return Constant.MyClassConstants.whatToTradeArray.count + 1
            }
            else {
                
                return 1
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        //***** Checking number of sections in tableview *****//
        
        if(self.SegmentIndex != 1) {
            
            if((indexPath as NSIndexPath).section == 0 || (indexPath as NSIndexPath).section == 1) {
                
                //***** Configure and return cell according to sections in tableview *****//
                if((indexPath as NSIndexPath).section == 0) {
                    
                    if(Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count) {
                        
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
                        addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addLocationInSection0Pressed(_:)), for: .touchUpInside)
                        cell.backgroundColor = UIColor.clear
                        cell.addSubview(addLocationButton)
                        
                        return cell
                    }else {
                        
                        let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoCell, for: indexPath) as! WhereToGoContentCell
                        
                        
                        
                        if((indexPath as NSIndexPath).row == destinationOrResort.count - 1 || destinationOrResort.count == 0) {
                            
                            cell.sepratorOr.isHidden = true
                        }
                        else {
                            
                            cell.sepratorOr.isHidden = false
                        }
                        
                        let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as AnyObject
                        if(object.isKind(of:Resort.self)){
                            
                            var resortNm = ""
                            var resortCode = ""
                            if let restName = (object as! Resort).resortName {
                                resortNm = restName
                            }
                            
                            if let restcode = (object as! Resort).resortCode {
                                
                                resortCode = restcode
                            }
                            var resortNameString = "\(resortNm) (\(resortCode))"
                            if((object as AnyObject).count > 1){
                                resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \((object as AnyObject).count - 1) \(Constant.getDynamicString.moreString)"
                            }
                            cell.whereTogoTextLabel.text = resortNameString
                        }else if (object.isKind(of: List<ResortByMap>.self)){
                            
                            let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as! List<ResortByMap>
                            
                            let resort = object[0]
                            
                            var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
                            if(object.count > 1){
                                resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \(object.count - 1) \(Constant.getDynamicString.moreString)"
                            }
                            
                            cell.whereTogoTextLabel.text = resortNameString
                        }
                            
                        else {
                            print(Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as! String)
                            cell.whereTogoTextLabel.text = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as? String
                        }
                        
                        //cell.bedroomLabel.isHidden = true
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        cell.backgroundColor = UIColor.clear
                        return cell
                    }
                }
                else {
                    
                    //***** Checking array content to configure and return content cell or calendar cell *****//
                    
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
                        addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addRelinquishmentSectionButtonPressed(_:)), for: .touchUpInside)
                        
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
                }
                
            }
            else if((indexPath as NSIndexPath).section == 2) {
                
                //***** Configure and return calendar cell  *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.caledarDateCell, for: indexPath) as! CaledarDateCell
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.vacationSearchShowDate as Date)
                cell.dayDateLabel.text = String(describing: myComponents.day!)
                if(cell.dayDateLabel.text!.characters.count == 1){
                    cell.dayDateLabel.text = "0\(cell.dayDateLabel.text!)"
                }
                cell.dateWithDateFormatLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(myComponents.year!)"
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.calendarIconButton!.addTarget(self, action: #selector(VacationSearchIPadViewController.calendarIconClicked(_:)), for: .touchUpInside)
                cell.backgroundColor = UIColor.clear
                return cell
            }
            else if((indexPath as NSIndexPath).section == 3){
                
                //***** Configure and return cell according to sections in tableview *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whoIsTravelingCell, for: indexPath) as! WhoIsTravelingCell
                cell.adultCounterLabel.text = String(self.adultCounter)
                cell.childCounterLabel.text = String(self.childCounter)
                cell.delegate = self
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
                
                
            }
                
            else if((indexPath as NSIndexPath).section == 5 || indexPath.section == 6) {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                //header for top ten deals
                if(indexPath.section == 5) {
                    if(!showExchange){
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                        
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                        cell.addSubview(resortImageNameLabel)
                    }else{
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                        cell.addSubview(resortImageNameLabel)
                        
                    }
                }
                else {
                    
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    cell.addSubview(resortImageNameLabel)
                }
                
                //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
                
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                layout.itemSize = CGSize(width:280, height: 220 )
                layout.minimumInteritemSpacing = 1.0
                layout.minimumLineSpacing = 10.0
                layout.scrollDirection = .horizontal
                homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 230 ), collectionViewLayout: layout)
                
                homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
                homeTableCollectionView.backgroundColor = UIColor.clear
                homeTableCollectionView.delegate = self
                homeTableCollectionView.dataSource = self
                if(indexPath.section == 3) {
                    homeTableCollectionView.tag = 1
                }
                else {
                    homeTableCollectionView.tag = 2
                }
                
                homeTableCollectionView.isScrollEnabled = true
                cell.backgroundColor = UIColor(red: 240.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                cell.addSubview(homeTableCollectionView)
                
                return cell
            }else  {
                
                //***** Configure and return search vacation cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.SearchVacationCell, for: indexPath) as! SearchTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self
                cell.backgroundColor = UIColor.clear
                return cell
                
            }
        }
        else {
            
            if((indexPath as NSIndexPath).section == 0 ) {
                
                //***** Checking array content to configure and return content cell or add button cell *****//
                
                if(Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count) {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    for subview in cell.subviews {
                        subview.removeFromSuperview()
                    }
                    
                    let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width/2 - (cell.contentView.bounds.width/5)/2, y: 15, width: cell.contentView.bounds.width/5, height: 30))
                    addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                    addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
                    addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                    addLocationButton.layer.cornerRadius = 4
                    addLocationButton.layer.borderWidth = 2
                    cell.addSubview(addLocationButton)
                    cell.backgroundColor = UIColor.clear
                    addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addLocationInSection0Pressed(_:)), for: .touchUpInside)
                    return cell
                }
                else {
                    
                    
                    let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoCell, for: indexPath) as! WhereToGoContentCell
                    
                    if((indexPath as NSIndexPath).row == destinationOrResort.count - 1 || destinationOrResort.count == 0) {
                        
                        cell.sepratorOr.isHidden = true
                    }
                    else {
                        
                        cell.sepratorOr.isHidden = false
                    }
                    
                    
                    let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as AnyObject
                    if(object.isKind(of:Resort.self)){
                        
                        var resortNm = ""
                        var resortCode = ""
                        if let restName = (object as! Resort).resortName {
                            resortNm = restName
                        }
                        
                        if let restcode = (object as! Resort).resortCode {
                            
                            resortCode = restcode
                        }
                        var resortNameString = "\(resortNm) (\(resortCode))"
                        if((object as AnyObject).count > 1){
                            resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \((object as AnyObject).count - 1) \(Constant.getDynamicString.moreString)"
                        }
                        cell.whereTogoTextLabel.text = resortNameString
                    }else if (object.isKind(of: List<ResortByMap>.self)){
                        
                        let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as! List<ResortByMap>
                        
                        let resort = object[0]
                        
                        var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
                        if(object.count > 1){
                            resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \(object.count - 1) \(Constant.getDynamicString.moreString)"
                        }
                        
                        cell.whereTogoTextLabel.text = resortNameString
                    }
                        
                    else {
                        cell.whereTogoTextLabel.text = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as? String
                    }
                    //cell.bedroomLabel.isHidden = true
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
                
            }else if((indexPath as NSIndexPath).section == 1) {
                
                //***** Return calendar cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.caledarDateCell, for: indexPath) as! CaledarDateCell
                
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.vacationSearchShowDate as Date)
                
                cell.dayDateLabel.text = String(describing: myComponents.day!)
                if(cell.dayDateLabel.text!.characters.count == 1){
                    cell.dayDateLabel.text = "0\(cell.dayDateLabel.text!)"
                }
                cell.dateWithDateFormatLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(myComponents.year!)"
                cell.calendarIconButton.addTarget(self, action: #selector(VacationSearchViewController.calendarIconClicked(_:)), for: .touchUpInside)
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
            }else if((indexPath as NSIndexPath).section == 2) {
                
                //***** Return calendar cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whoIsTravelingCell, for: indexPath) as! WhoIsTravelingCell
                
                cell.adultCounterLabel.text = String(self.adultCounter)
                cell.childCounterLabel.text = String(self.childCounter)
                cell.delegate = self
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
                
            }else if((indexPath as NSIndexPath).section == 4) {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                //header for top ten deals
                if(indexPath.section == 4) {
                    if(!showExchange){
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                        
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                        cell.addSubview(resortImageNameLabel)
                    }else{
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                        cell.addSubview(resortImageNameLabel)
                        
                    }
                }
                else {
                    
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    cell.addSubview(resortImageNameLabel)
                }
                
                
                //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
                
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                layout.itemSize = CGSize(width:280, height: 220 )
                layout.minimumInteritemSpacing = 1.0
                layout.minimumLineSpacing = 10.0
                layout.scrollDirection = .vertical
                getawayCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: CGFloat(Constant.MyClassConstants.topDeals.count) * 280 ), collectionViewLayout: layout)
                
                getawayCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
                getawayCollectionView.backgroundColor = UIColor.clear
                getawayCollectionView.delegate = self
                getawayCollectionView.dataSource = self
                getawayCollectionView.tag = 2
                getawayCollectionView.isScrollEnabled = true
                cell.backgroundColor = UIColor(red: 240.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                cell.addSubview(getawayCollectionView)
                
                
                return cell
            }else {
                //***** Return traveling adults and children cell with counter *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.SearchVacationCell, for: indexPath) as! SearchTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self
                cell.backgroundColor = UIColor.clear
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            if((indexPath as NSIndexPath).section == 0) {
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(destinationOrResort[(indexPath as NSIndexPath).row])
                }
                if(Constant.MyClassConstants.whereTogoContentArray.count > 0) {
                    Constant.MyClassConstants.whereTogoContentArray.removeObject(at: (indexPath as NSIndexPath).row)
                    if(Constant.MyClassConstants.realmStoredDestIdOrCodeArray.count > 0){
                        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: (indexPath as NSIndexPath).row)
                    }
                }
                if(Constant.MyClassConstants.realmStoredDestIdOrCodeArray.count > 0){
                    Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: (indexPath as NSIndexPath).row)
                }
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .automatic)
                }
                
            }
            else {
                Constant.MyClassConstants.checkInClosestContentArray.removeObject(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .automatic)
                }
                
            }
        }
    }
    
    func MoreNavButtonPressed(_ sender:UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.searchOption, message: "", preferredStyle: .actionSheet)
        
        //***** Create and add the View my recent search *****//
        let viewMyRecentSearchAction: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.viewMyRecentSearches, style: .default) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(viewMyRecentSearchAction)
        //***** Create and add the Reset my search *****//
        let resetMySearchAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.resetMySearch, style: .default) { action -> Void in
            Constant.MyClassConstants.checkInClosestContentArray.removeAllObjects()
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
            let realm = try! Realm()
            let allDest = Helper.getLocalStorageWherewanttoGo()
            if (allDest.count > 0) {
                try! realm.write{
                    realm.deleteAll()
                }
            }
            self.searchVacationTableView.reloadData()
        }
        actionSheetController.addAction(resetMySearchAction)
        //***** Create and add help *****//
        let helpAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.help, style: .default) { action -> Void in
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
}

//***** Custom WhoIsTravelingCell delegate method implementation *****//

extension VacationSearchViewController:WhoIsTravelingCellDelegate {
    
    func adultChanged(_ value:Int) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event67, data: nil)
        //***** updating adult counter increment and decrement
        self.adultCounter = value
        if defaults.object(forKey: Constant.MyClassConstants.adultCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.adultCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        self.searchVacationTableView.reloadData()
    }
    func childrenChanged(_ value:Int) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event67, data: nil)
        
        //***** updating children counter increment and decrement
        self.childCounter = value
        if defaults.object(forKey: Constant.MyClassConstants.childCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.childCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        self.searchVacationTableView.reloadData()
    }
    
}

//***** Custom SearchTableViewCell delegate method implementation *****//


extension VacationSearchViewController:SearchTableViewCellDelegate {
    func searchButtonClicked(_ sender : IUIKButton) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event1, data: nil)
        
        if (self.SegmentIndex == 1 && (Helper.getAllDestinationFromLocalStorage().count>0 || Helper.getAllResortsFromLocalStorage().count>0)) {
            Helper.showProgressBar(senderView: self)
            SVProgressHUD.show()
            sender.isEnabled = false
            
            let destinations = Helper.getAllDestinationFromLocalStorage()
            let resorts = Helper.getAllResortsFromLocalStorage()
            

            if Reachability.isConnectedToNetwork() == true{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Constant.MyClassConstants.appSettings = appDelegate.createAppSetting()

                let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
                if(destinations.count > 0) {
                    rentalSearchCriteria.destination = destinations[0]
                } else if (resorts.count > 0) {
                    rentalSearchCriteria.resorts = resorts
                }

                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                
                self.vacationSearch = VacationSearch(Constant.MyClassConstants.appSettings, rentalSearchCriteria)
                Constant.MyClassConstants.initialVacationSearch = self.vacationSearch
            
                RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: self.vacationSearch.rentalSearch?.searchContext.request,
                    onSuccess: { (response) in
                        self.vacationSearch.rentalSearch?.searchContext.response = response

                        // Get activeInterval
                        let activeInterval = self.vacationSearch.bookingWindow.getActiveInterval()
                    
                        // Update active interval
                        self.vacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                        // Always show a fresh copy of the Scrolling Calendar
                        Helper.showScrollingCalendar(vacationSearch: self.vacationSearch)
                    
                        // Check not available checkIn dates for the active interval
                        if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                            self.showNotAvailabilityResults()
                        } else {
                            let initialSearchCheckInDate = Helper.convertStringToDate(dateString:self.vacationSearch.getCheckInDateForInitialSearch(),format:Constant.MyClassConstants.dateFormat)
                        
                            DarwinSDK.logger.info("Initial Rental Search using request payload:")
                            DarwinSDK.logger.info(" CheckInDate = \(initialSearchCheckInDate)")
                            DarwinSDK.logger.info(" ResortCodes = \(String(describing: activeInterval?.resortCodes))")
                        
                            Constant.MyClassConstants.checkInDates = response.checkInDates
                            sender.isEnabled = true
                            Helper.helperDelegate = self
                        
                            self.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: response.checkInDates[0])
                        }
                    },
                    onError:{ (error) in
                        SVProgressHUD.dismiss()
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                    }
                )
            } else{
                sender.isEnabled = true
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.networkError)
            }
            
            Constant.MyClassConstants.isFromExchange = false
 
        } else if(self.SegmentIndex == 2) {

            sender.isEnabled = false
            Helper.showProgressBar(senderView: self)
            
            let destinations = Helper.getAllDestinationFromLocalStorage()
            let resorts = Helper.getAllResortsFromLocalStorage()
            
            let travelPartyInfo = TravelParty()
            travelPartyInfo.adults = Int(self.adultCounter)
            travelPartyInfo.children = Int(self.childCounter)
            
            Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
            
            if Reachability.isConnectedToNetwork() == true {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Constant.MyClassConstants.appSettings = appDelegate.createAppSetting()
                
                let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
                exchangeSearchCriteria.resorts = resorts
                exchangeSearchCriteria.relinquishmentsIds = ["Ek83chJmdS6ESNRpVfhH8XUt24BdWzaYpSIODLB0Scq6rxirAlGksihR1PCb1xSC"]
                exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                exchangeSearchCriteria.searchType = VacationSearchType.Exchange
                
                Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Constant.MyClassConstants.appSettings, exchangeSearchCriteria)
                
                ExchangeClient.searchDates(UserContext.sharedInstance.accessToken, request:vacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                    sender.isEnabled = true
                    Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                    
                    // Get activeInterval (or initial search interval)
                    let activeInterval = BookingWindowInterval(interval: Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval())
                    
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    
                    // Check not available checkIn dates for the active interval
                    if (activeInterval.fetchedBefore && !activeInterval.hasCheckInDates()) {
                        Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                        self.showNotAvailabilityResults()
                    }
                    
                    
                    // Check not available checkIn dates for the active interval
                    if (activeInterval.fetchedBefore && !activeInterval.hasCheckInDates()) {
                        Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                        self.showNotAvailabilityResults()
                    }
                    
                    DarwinSDK.logger.info("Auto call to Search Availability")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if (activeInterval.hasCheckInDates()){
                        let initialSearchCheckInDate = self.vacationSearch.getCheckInDateForInitialSearch()
                        
                        DarwinSDK.logger.info("Initial Rental Search using request payload:")
                        DarwinSDK.logger.info(" CheckInDate = \(initialSearchCheckInDate)")
                        DarwinSDK.logger.info(" ResortCodes = \(String(describing: activeInterval.resortCodes))")
                        
                        self.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: dateFormatter.date(from: initialSearchCheckInDate))
                    }else{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        Helper.hideProgressBar(senderView: self)
                        self.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate:exchangeSearchCriteria.checkInDate)
                    }
                    
                }, onError: { (error) in
                    sender.isEnabled = true
                    Helper.hideProgressBar(senderView: self)
                    SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.noResultError)
                })
            }else{
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.networkError)
            }
            Constant.MyClassConstants.isFromExchange = true

            
           
        }
    }
    
    // Function to get to date and from date for search dates API calling
    func getSearchDates() -> (Date, Date){
        
        var fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow/2), to: Constant.MyClassConstants.vacationSearchShowDate, options: [])!
        
        var toDate:Date!
        if (fromDate.isGreaterThanDate(Constant.MyClassConstants.todaysDate)) {
            
            toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: (Constant.MyClassConstants.totalWindow/2), to: Constant.MyClassConstants.vacationSearchShowDate, options: [])!
        }
        else {
            _ = Helper.getDifferenceOfDates()
            fromDate = Constant.MyClassConstants.todaysDate
            toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: (Constant.MyClassConstants.totalWindow) + Helper.getDifferenceOfDates(), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
        }
        
        if (toDate.isGreaterThanDate(Constant.MyClassConstants.dateAfterTwoYear!)) {
            
            toDate = Constant.MyClassConstants.dateAfterTwoYear
            fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow) + Helper.getDifferenceOfDatesAhead(), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
        }
        Constant.MyClassConstants.currentFromDate = fromDate
        Constant.MyClassConstants.currentToDate = toDate
        return(toDate,fromDate)
    }
    
    //Function for search availability calling
    func searchAvailability(exchangeAvailabilityRequest:ExchangeSearchAvailabilityRequest, sender:IUIKButton){
        ExchangeClient.searchAvailability(UserContext.sharedInstance.accessToken, request: exchangeAvailabilityRequest, onSuccess: { (exchangeAvailability) in
            Helper.hideProgressBar(senderView: self)
            Constant.MyClassConstants.showAlert = false
            Constant.MyClassConstants.resortsArray.removeAll()
            Constant.MyClassConstants.exchangeInventory.removeAll()
            for exchangeResorts in exchangeAvailability{
                Constant.MyClassConstants.resortsArray.append(exchangeResorts.resort!)
                Constant.MyClassConstants.exchangeInventory.append(exchangeResorts.inventory!)
                
            }
            if(Constant.MyClassConstants.resortsArray.count == 0){
                Constant.MyClassConstants.showAlert = true
            }
            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
        }, onError: { (error) in
            Helper.hideProgressBar(senderView: self)
            sender.isEnabled = true
            Constant.MyClassConstants.showAlert = true
            self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
        })
    }

    
    func showNotAvailabilityResults() {
        DarwinSDK.logger.info("Show the Not Availability Screen.")
    }
    
    /*
     * Execute Exchange Search Availability
     */
    
    func executeExchangeSearchAvailability(activeInterval: BookingWindowInterval!, checkInDate:Date!) {
        
        let request = ExchangeSearchAvailabilityRequest()
        request.checkInDate = checkInDate
        //request.resortCodes = activeInterval.resortCodes!
        request.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as! [String]
        request.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        
        ExchangeClient.searchAvailability(UserContext.sharedInstance.accessToken, request: request, onSuccess: { (searchAvailabilityResponse) in
            
            print(searchAvailabilityResponse)
        }) { (error) in
            
        }
    }
    
    
    
    /*
     * Execute Rental Search Availability
     */
    func executeRentalSearchAvailability(activeInterval:BookingWindowInterval!, checkInDate:Date!) {
        DarwinSDK.logger.error("----- Waiting for search availability ... -----")
        
        let request = RentalSearchResortsRequest()
        request.checkInDate = checkInDate
        request.resortCodes = activeInterval.resortCodes
        
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: request,
                                   onSuccess: { (response) in
                                    // Update Rental inventory
                                    Constant.MyClassConstants.resortsArray = response.resorts
                                    self.vacationSearch.rentalSearch?.inventory = response.resorts
                                    
                                    // Check if not has availability in the desired check-In date.
                                    if (self.vacationSearch.searchCriteria.checkInDate != checkInDate) {
                                        self.showNearestCheckInDateSelectedMessage()
                                    }
                                    
                                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    
                                    self.showAvailabilityResults()
                                    Helper.hideProgressBar(senderView: self)
                                    self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
                                    //expectation.fulfill()
        },
                                   onError:{ (error) in
                                     Helper.hideProgressBar(senderView: self)
                                    DarwinSDK.logger.error("Error Code: \(error.code)")
                                    DarwinSDK.logger.error("Error Description: \(error.description)")
                                    
                                    let INVENTORY_NOT_AVAILABLE_CODE = "d67dc7030d7462db65465023262e704f"
                                    let sdkErrorCode = String(describing: error.userInfo["errorCode"])
                                    
                                    if (INVENTORY_NOT_AVAILABLE_CODE == sdkErrorCode) {
                                        // TODO: Define behavior for not available inventory
                                        DarwinSDK.logger.error("Define behavior for not available inventory.")
                                    } else {
                                        // TODO: Handle SDK/API errors
                                        DarwinSDK.logger.error("Handle SDK/API errors.")
                                    }
                                    
                                    //expectation.fulfill()
                                    //XCTAssert(false, "Not Pass")
                                    //XCTFail()
        }
        )
    }
    
    func showAvailabilityResults() {
        DarwinSDK.logger.info("-- Create Sections --")
        
        let sections = self.vacationSearch.createSections()
        
        // Show up the Availability Sections in UI
        DarwinSDK.logger.info("Sorting criteria is: \(String(describing: self.vacationSearch.sortType))")
        for section in sections {
            if (self.vacationSearch.sortType.isDefault()) {
                self.showAvailabilitySectionWithDefault(section: section)
            } else {
                self.showAvailabilitySection(section: section);
            }
        }
    }
    
    func showNearestCheckInDateSelectedMessage() {
        DarwinSDK.logger.info("NEAREST CHECK-IN DATE SELECTED - We found availability close to your desired Check-in Date")
    }
    
    func showAvailabilitySectionWithDefault(section:AvailabilitySection!) {
        if (section.hasDestination()) {
            if (section.exactMatch)! {
                // Show up Destination exact match as header
                DarwinSDK.logger.info("Header[D] - \(String(describing: self.resolveDestinationInfo(destination: section.destination!)))")
                Constant.MyClassConstants.searchAvailabilityHeader = "Resorts in \(String(describing: self.resolveDestinationInfo(destination: section.destination!)))"
            } else {
                // Show up Destination surrounding match as header
                DarwinSDK.logger.info("Header[D] - Surrounding to \(String(describing: self.resolveDestinationInfo(destination: section.destination!)))")
                Constant.MyClassConstants.searchAvailabilityHeader = "Resorts near \(String(describing: self.resolveDestinationInfo(destination: section.destination!)))"
            }
            
            for inventoryItem in (section.item?.rentalInventory)! {
                self.showAvailabilityBucket(inventoryItem: inventoryItem)
            }
            
            DarwinSDK.logger.info("===============================================================")
        } else {
            for inventoryItem in (section.item?.rentalInventory)! {
                // Show up only Resorts as header
                DarwinSDK.logger.info("Header[R] - \(String(describing: inventoryItem.resortName))")
                Constant.MyClassConstants.searchAvailabilityHeader = "\(String(describing: inventoryItem.resortName))"
                self.showAvailabilityBucket(inventoryItem: inventoryItem)
            }
            
            DarwinSDK.logger.info("===============================================================")
        }
    }
    
    func showAvailabilitySection(section:AvailabilitySection!) {
        if (section.exactMatch)! {
            // Show up exact match as header
            DarwinSDK.logger.info("Header - Exact Match")
        } else {
            // Show up surrounding match as header
            DarwinSDK.logger.info("Header - Surrounding Match")
        }
        
        for inventoryItem in (section.item?.rentalInventory)! {
            self.showAvailabilityBucket(inventoryItem: inventoryItem)
        }
        
        DarwinSDK.logger.info("===============================================================")
    }
    
    func showAvailabilityBucket(inventoryItem:Resort!) {
        DarwinSDK.logger.info("\(String(describing: self.resolveResortInfo(resort: inventoryItem)))")
        
        for unit in (inventoryItem.inventory?.units)! {
            DarwinSDK.logger.info("\(String(describing: self.resolveUnitInfo(unit: unit)))")
        }
    }
    
    func resolveResortInfo(resort:Resort!) -> String {
        var info = String()
        info.append(resort.resortCode!)
        info.append(" ")
        info.append(resort.resortName!)
        info.append(" ")
        
        if (resort.address?.cityName != nil) {
            info.append(" ")
            info.append((resort.address?.cityName)!)
        }
        
        if (resort.address?.territoryCode != nil) {
            info.append(" ")
            info.append((resort.address?.territoryCode)!)
        }
        
        if (resort.address?.countryCode != nil) {
            info.append(" ")
            info.append((resort.address?.countryCode)!)
        }
        
        return info
    }
    
    func resolveDestinationInfo(destination:AreaOfInfluenceDestination) -> String {
        var info = String()
        info.append(destination.destinationName)
        
        if (destination.address?.cityName != nil) {
            info.append(" ")
            info.append((destination.address?.cityName)!)
        }
        
        if (destination.address?.territoryCode != nil) {
            info.append(" ")
            info.append((destination.address?.territoryCode)!)
        }
        
        if (destination.address?.countryCode != nil) {
            info.append(" ")
            info.append((destination.address?.countryCode)!)
        }
        
        return info
    }
    
    func resolveUnitInfo(unit:InventoryUnit) -> String {
        var info = String()
        info.append("    ")
        info.append(unit.unitSize!)
        info.append(" ")
        info.append(unit.kitchenType!)
        info.append(" ")
        info.append("\(String(describing: unit.publicSleepCapacity))")
        info.append(" total ")
        info.append("\(String(describing: unit.privateSleepCapacity))")
        info.append(" private")
        return info
    }
}


extension VacationSearchViewController:HelperDelegate {
    func resortSearchComplete(){
        //self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)

    }
    func resetCalendar(){
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
    }
}
