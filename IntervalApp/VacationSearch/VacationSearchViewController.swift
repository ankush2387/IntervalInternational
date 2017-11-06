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
    var segmentTitle = ""
    let headerCellIndexPath = NSMutableArray()
    var destinationOrResort = Helper.getLocalStorageWherewanttoGo()
    let allDest = Helper.getLocalStorageAllDest()
    var datePickerPopupView:UIView?
    let defaults = UserDefaults.standard
    var sourceViewController:UIViewController!
    var destinationViewController:UIViewController!
    var moreButton:UIBarButtonItem?
    var showExchange = true
    var showGetaways = true
    var vacationSearch = VacationSearch()
    var selectedFlexchange: FlexExchangeDeal?
    var searchDateRequest = RentalSearchDatesRequest()
    var rentalHasNotAvailableCheckInDates : Bool = false
    var exchangeHasNotAvailableCheckInDates : Bool = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        searchVacationTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Constant.MyClassConstants.selectionType == 0 {
            
            // omniture tracking with event 64
            let userInfo: [String: Any] = [
                Constant.omnitureEvars.eVar25 : Constant.MyClassConstants.destinationOrResortSelectedBy,
                
                ]
            Constant.MyClassConstants.selectionType = -1
            ADBMobile.trackAction(Constant.omnitureEvents.event64, data: userInfo)
        }
        else if Constant.MyClassConstants.selectionType == 1 {
            
            Constant.MyClassConstants.selectionType = -1
            ADBMobile.trackAction(Constant.omnitureEvents.event65, data: nil)
        }
        
        destinationOrResort = Helper.getLocalStorageWherewanttoGo()
        // Get user's saved destinations and resort for search
        getVacationSearchDetails()
        
        if let rvc = revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            parent?.navigationItem.leftBarButtonItem = menuButton
            
            //***** Creating and adding right bar button for more option button *****//
            moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(MoreNavButtonPressed(_:)))
            moreButton?.tintColor = UIColor.white
            parent?.navigationItem.rightBarButtonItem = moreButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
            searchVacationTableView.reloadData()
        }
        
        
        Helper.InitializeArrayFromLocalStorage()
        Helper.InitializeOpenWeeksFromLocalStorage()
        
        searchVacationTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchVacationSegementControl.removeAllSegments()
        
        // updating segment control number of segment according to app settings response
        for (i,searchType) in (Session.sharedSession.appSettings?.vacationSearch?.vacationSearchTypes.enumerated())! {
            
            searchVacationSegementControl.insertSegment(withTitle: Helper.vacationSearchTypeSegemtStringToDisplay(vacationSearchType: searchType), at: i, animated: true)
            
            searchVacationSegementControl.selectedSegmentIndex = 0
            segmentTitle = searchVacationSegementControl.titleForSegment(at: 0)!
        }
        
        var isPrePopulatedData =  Constant.AlertPromtMessages.no
        searchVacationTableView.estimatedRowHeight = 100
        
        if Constant.MyClassConstants.whereTogoContentArray.count > 0 || Constant.MyClassConstants.whatToTradeArray.count > 0 {
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
        
        if SegmentIndex != 2 {
            
            //***** Registering the custom cell with UITabelview *****//
            let cellNib = UINib(nibName:Constant.customCellNibNames.whoIsTravelingCell, bundle: nil)
            searchVacationTableView?.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.whoIsTravelingCell)
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
            childCounter = childct as! Int
        }
        if let adultct = defaults.object(forKey: Constant.MyClassConstants.adultCounterString) {
            adultCounter = adultct as! Int
        }
        
    }
    
    //**** UISegment Control value change. *****//
    
    @IBAction func searchVacationSelectedSegment(_ sender: UISegmentedControl) {
        
        segmentTitle = searchVacationSegementControl.titleForSegment(at: sender.selectedSegmentIndex)!
        Constant.MyClassConstants.vacationSearchSelectedSegmentIndex = sender.selectedSegmentIndex
        Constant.segmentControlItems.selectedSearchSegment = segmentTitle
        
        SegmentIndex = sender.selectedSegmentIndex
        
        switch segmentTitle {
        case Constant.segmentControlItems.searchBoth:
            showGetaways = true
            showExchange = true
            break
        case Constant.segmentControlItems.getaways:
            showGetaways = true
            showExchange = false
            break
        case Constant.segmentControlItems.exchange:
            showGetaways = false
            showExchange = true
            break
        default:
            break
        }
        
        searchVacationTableView.reloadData()
        // omniture tracking with event 63
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar24 : Helper.selectedSegment(index: sender.selectedSegmentIndex)
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event63, data: userInfo)
        
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
        navigationController?.transitioningDelegate = transitionManager
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //***** Add location pressed action to show map screen with list of location to select *****//
    func addRelinquishmentSectionButtonPressed(_ sender:IUIKButton) {
        showHudAsync()
        ExchangeClient.getMyUnits(Session.sharedSession.userAccessToken, onSuccess: { (Relinquishments) in
            
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if let pointsProgram = Relinquishments.pointsProgram{
                Constant.MyClassConstants.relinquishmentProgram = pointsProgram
                if let availablePoints = pointsProgram.availablePoints{
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = availablePoints
                }
            }
            
            self.hideHudAsync()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as! RelinquishmentSelectionViewController
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }, onError: {(error) in
            self.hideHudAsync()
        })
        
    }
    
    func refreshTableView(){
        self.hideHudAsync()
        searchVacationTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.destination.isKind(of: FlexchangeSearchViewController.self)) {
            let selectedFlexchange = segue.destination as! FlexchangeSearchViewController
            selectedFlexchange.selectedFlexchange = self.selectedFlexchange
        }
        
    }
    
}

//***** MARK: Extension classes starts from here *****//

extension VacationSearchViewController:UICollectionViewDelegate {
    
    //***** UICollectonview delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            
            //Set travel PartyInfo
            //Set filter options
            Constant.MyClassConstants.noFilterOptions = false
            let travelPartyInfo = TravelParty()
            travelPartyInfo.adults = Int(adultCounter)
            travelPartyInfo.children = Int(childCounter)
            
            Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
            
            selectedFlexchange = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            self.performSegue(withIdentifier: "flexChangeViewController", sender: self)
        }else{
            self.topTenGetawaySelected(selectedIndexPath: indexPath)
        }
    }
    
    
}

extension VacationSearchViewController:UICollectionViewDataSource {
    
    //***** UICollectionview dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return Constant.MyClassConstants.flexExchangeDeals.count
        } else {
            return Constant.MyClassConstants.topDeals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 180) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            
            
            if let imgURL = flexDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                resortFlaxImageView.contentMode = .center
                }
                cell.addSubview(resortFlaxImageView)
                
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 60))
                resortImageNameLabel.text = flexDeal.name
                resortImageNameLabel.numberOfLines = 2
                resortImageNameLabel.textAlignment = NSTextAlignment.center
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold,size: 16)
                cell.addSubview(resortImageNameLabel)
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1.0
                cell.layer.cornerRadius = 7
                cell.layer.masksToBounds = true
            
            return cell
            
        } else {
            let deal = Constant.MyClassConstants.topDeals[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 180) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            
            
                
                resortFlaxImageView.setImageWith(URL(string: (deal.images[0].url) ?? ""), completed: { (image:UIImage?, error:Swift.Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
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
                if let dealPrice = deal.price{
                    priceLabel.text = "\(Constant.getDynamicString.fromString) $" + String(describing: dealPrice.fromPrice) + "\(Constant.getDynamicString.weekString)"
                    priceLabel.numberOfLines = 2
                    priceLabel.textAlignment = NSTextAlignment.center
                    priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    priceLabel.textColor = UIColor.white
                    priceLabel.backgroundColor = UIColor.clear
                    centerView.addSubview(priceLabel)
                }
                cell.addSubview(centerView)
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1.0
                cell.layer.cornerRadius = 7
                cell.layer.masksToBounds = true
                
            
            
            
            return cell
        }
    }
}

extension VacationSearchViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** Checking number of sections in tableview *****//
        if segmentTitle != Constant.segmentControlItems.getaways {
            
            //***** Return height according to section cell requirement *****//
            switch indexPath.section {
            case 0 :
                if indexPath.row < Constant.MyClassConstants.whereTogoContentArray.count {
                    return UITableViewAutomaticDimension
                }else {
                    return 60
                }
            case 1:
                if indexPath.row < Constant.MyClassConstants.whatToTradeArray.count {
                    return UITableViewAutomaticDimension
                }else {
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
                return 290
                
            }
        }else {
            
            //***** Return height according to section cell requirement *****//
            switch indexPath.section {
            case 0 :
                if indexPath.row < Constant.MyClassConstants.whereTogoContentArray.count {
                    return UITableViewAutomaticDimension
                }else {
                    return 60
                }
            case 1:
                return 80
            case 2:
                return 120
            case 4:
                return 290
                
            default :
                return 70
            }
        }
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.view.bounds.width - 30, height: 50))
        
        if segmentTitle != Constant.segmentControlItems.getaways {
            
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
        
        if tableView.numberOfSections == 6 || tableView.numberOfSections == 7 {
            if section < 4 {
                return 55
            }else {
                return 0
            }
        }else {
            if section < 3{
                return 55
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (action,index) -> Void in
                if indexPath.section == 0 {
                    do{
                        let realm = try Realm()
                        if self.destinationOrResort.count > 0 {
                            
                            try realm.write {
                                realm.delete(self.destinationOrResort[(indexPath as NSIndexPath).row])
                            }
                        }else {
                            Helper.deleteObjectFromAllDest()
                        }
                        if Constant.MyClassConstants.whereTogoContentArray.count > 0 {
                            ADBMobile.trackAction(Constant.omnitureEvents.event7, data: nil)
                            Constant.MyClassConstants.whereTogoContentArray.removeObject(at: (indexPath as NSIndexPath).row)
                        }
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            tableView.reloadSections(IndexSet(integer:(indexPath as NSIndexPath).section), with: .automatic)
                            Helper.InitializeArrayFromLocalStorage()
                        }
                    }catch{
                        self.presentErrorAlert(UserFacingCommonError.generic)
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
                
                if Constant.RunningDevice.deviceIdiom == .pad {
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
                    viewController.selectedIndex = 0
                    self.navigationController?.present(viewController, animated: true, completion: nil)
                    
                }else{
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
                    viewController.selectedIndex = 0
                    self.navigationController?.present(viewController, animated: true, completion: nil)
                    
                }
            }
            
            details.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            
            let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row]
            
            if (object as AnyObject) .isKind(of: List<ResortByMap>.self){
                return [delete,details]
            }else{
                return [delete]
            }
        }else{
            
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (action,index) -> Void in
                // var isFloat = true
                let storedData = Helper.getLocalStorageWherewanttoTrade()
                
                if storedData.count > 0 {
                    do{
                        let realm = try Realm()
                            try realm.write {
                                
                                if (Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject).isKind(of: OpenWeeks.self) {
                                    
                                    var floatWeekIndex = -1
                                    let dataSelected = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as! OpenWeeks
                                    if dataSelected.isFloat {
                                        
                                        
                                        for (index,object) in storedData.enumerated(){
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
                    }catch{
                        self.presentErrorAlert(UserFacingCommonError.generic)
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
        if segmentTitle == Constant.segmentControlItems.searchBoth || segmentTitle == Constant.segmentControlItems.exchange {
            if indexPath.section == 0 {
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count {
                    return false
                }else{
                    return true
                }
            }else if indexPath.section == 1 {
                if Constant.MyClassConstants.whatToTradeArray.count == 0 || indexPath.row == Constant.MyClassConstants.whatToTradeArray.count {
                    return false
                }else{
                    return true
                }
            }else{
                return false
            }
        }else if indexPath.section == 0 {
            if Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count {
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
        
        if segmentTitle == Constant.segmentControlItems.getaways {
            return 5
        } else if segmentTitle == Constant.segmentControlItems.exchange {
            return 6
        } else {
            return 7
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            
        case 0:
            return Constant.MyClassConstants.whereTogoContentArray.count + 1
            
        case 1:
            if segmentTitle != Constant.segmentControlItems.getaways {
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
        
        if segmentTitle != Constant.segmentControlItems.getaways {
            
            if indexPath.section == 0 || indexPath.section == 1 {
                
                //***** Configure and return cell according to sections in tableview *****//
                if indexPath.section == 0 {
                    
                    if Constant.MyClassConstants.whereTogoContentArray.count == 0 || indexPath.row == Constant.MyClassConstants.whereTogoContentArray.count {
                        
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
                        
                        if indexPath.row == destinationOrResort.count - 1 || destinationOrResort.count == 0 {
                            cell.sepratorOr.isHidden = true
                        }else {
                            
                            cell.sepratorOr.isHidden = false
                        }
                        
                        let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as AnyObject
                        if object.isKind(of:Resort.self) {
                            
                            var resortNm = ""
                            var resortCode = ""
                            if let restName = (object as! Resort).resortName {
                                resortNm = restName
                            }
                            
                            if let restcode = (object as! Resort).resortCode {
                                resortCode = restcode
                            }
                            var resortNameString = "\(resortNm) (\(resortCode))"
                            if (object as AnyObject).count > 1 {
                                resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \((object as AnyObject).count - 1) \(Constant.getDynamicString.moreString)"
                            }
                            cell.whereTogoTextLabel.text = resortNameString
                        }else if object.isKind(of: List<ResortByMap>.self){
                            
                            let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as! List<ResortByMap>
                            
                            let resort = object[0]
                            
                            var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
                            if object.count > 1 {
                                resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \(object.count - 1) \(Constant.getDynamicString.moreString)"
                            }
                            
                            cell.whereTogoTextLabel.text = resortNameString
                        }else {
                            cell.whereTogoTextLabel.text = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as? String
                        }
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        cell.backgroundColor = UIColor.clear
                        return cell
                    }
                }
                else {
                    
                    //***** Checking array content to configure and return content cell or calendar cell *****//
                    
                    if((Constant.MyClassConstants.whatToTradeArray.count == 0 && Constant.MyClassConstants.pointsArray.count == 0) || indexPath.row == (Constant.MyClassConstants.whatToTradeArray.count)) {
                        
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
                        
                        if indexPath.row == Constant.MyClassConstants.whatToTradeArray.count - 1 {
                            cell.sepratorOr.isHidden = true
                        }else{
                            cell.sepratorOr.isHidden = false
                        }
                        let object = Constant.MyClassConstants.whatToTradeArray[indexPath.row]
                        if (object as AnyObject).isKind(of: OpenWeek.self){
                            if let resortName = (object as! OpenWeek).resort?.resortName{
                                cell.whereTogoTextLabel.text = "\(resortName)"
                            }
                            if let relinquishmentYear = (object as! OpenWeek).relinquishmentYear{
                                cell.whereTogoTextLabel.text = "\(String(describing: cell.whereTogoTextLabel.text)), \(relinquishmentYear)"
                            }
                            if let weekNumber = (object as! OpenWeek).weekNumber{
                                cell.whereTogoTextLabel.text = "\(String(describing: cell.whereTogoTextLabel.text)), Week \(weekNumber)"
                            }
                            cell.bedroomLabel.isHidden = true
                        }else if((object as AnyObject).isKind(of: OpenWeeks.self)){
                            let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).weekNumber))
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
                            if weekNumber != ""{
                                cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName)/ \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).relinquishmentYear), Wk\(weekNumber)"
                            }else{
                                cell.whereTogoTextLabel.text = "\((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).resort[0].resortName)/ \((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! OpenWeeks).relinquishmentYear)"
                            }
                        } else if (object as AnyObject) .isKind(of: Deposits.self){
                            //Deposits
                            let weekNumber = Constant.getWeekNumber(weekType: ((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).weekNumber))
                            
                            if((Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isLockOff || (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).isFloat){
                                cell.bedroomLabel.isHidden = false
                                
                                let resortList = (Constant.MyClassConstants.whatToTradeArray[(indexPath as NSIndexPath).row] as! Deposits).unitDetails
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
                            
                            if let availablePoints = numberFormatter.string(from: availablePointsNumber){
                                cell.whereTogoTextLabel.text = "\(Constant.getDynamicString.clubInterValPointsUpTo) \(availablePoints)"
                            }
                            
                            
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
                if let day = myComponents.day{
                    if String(describing:day).count == 1{
                        cell.dayDateLabel.text = "0\(String(describing:day))"
                    }else{
                        cell.dayDateLabel.text = "\(String(describing:day))"
                    }
                }
                if let weekDay = myComponents.weekday{
                    cell.dateWithDateFormatLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber:weekDay))"
                }
                if let month = myComponents.month{
                    cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month))"
                    if let year = myComponents.year{
                       cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
                    }
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.calendarIconButton!.addTarget(self, action: #selector(VacationSearchIPadViewController.calendarIconClicked(_:)), for: .touchUpInside)
                cell.backgroundColor = UIColor.clear
                return cell
            }
            else if((indexPath as NSIndexPath).section == 3){
                
                //***** Configure and return cell according to sections in tableview *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whoIsTravelingCell, for: indexPath) as! WhoIsTravelingCell
                cell.adultCounterLabel.text = String(adultCounter)
                cell.childCounterLabel.text = String(childCounter)
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
                if(indexPath.section == 5) {
                    homeTableCollectionView.tag = 1
                }
                else {
                    homeTableCollectionView.tag = 2
                }
                
                homeTableCollectionView.isScrollEnabled = true
                cell.backgroundColor = UIColor(red: 240.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                cell.addSubview(homeTableCollectionView)
                homeTableCollectionView.reloadData()
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
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
                
            }else if((indexPath as NSIndexPath).section == 1) {
                
                //***** Return calendar cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.caledarDateCell, for: indexPath) as! CaledarDateCell
                
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.vacationSearchShowDate as Date)
                
                if let day = myComponents.day{
                    if(String(describing: day).count == 1){
                        cell.dayDateLabel.text = "0\(String(describing: day))"
                    }else{
                        cell.dayDateLabel.text = "\(String(describing: day))"
                    }
                }
                
                if let weekDay = myComponents.weekday{
                    cell.dateWithDateFormatLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber:weekDay))"
                }
                if let month = myComponents.month{
                    cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month))"
                    if let year = myComponents.year{
                        cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
                    }
                }
                
                cell.calendarIconButton.addTarget(self, action: #selector(VacationSearchViewController.calendarIconClicked(_:)), for: .touchUpInside)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
            }else if((indexPath as NSIndexPath).section == 2) {
                
                //***** Return calendar cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whoIsTravelingCell, for: indexPath) as! WhoIsTravelingCell
                
                cell.adultCounterLabel.text = String(adultCounter)
                cell.childCounterLabel.text = String(childCounter)
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
                layout.scrollDirection = .horizontal
                getawayCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 230 ), collectionViewLayout: layout)
                getawayCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
                getawayCollectionView.backgroundColor = UIColor.clear
                getawayCollectionView.delegate = self
                getawayCollectionView.dataSource = self
                getawayCollectionView.tag = 2
                getawayCollectionView.isScrollEnabled = true
                cell.backgroundColor = UIColor(red: 240.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                cell.addSubview(getawayCollectionView)
                getawayCollectionView.reloadData()
                
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
                do{
                    let realm = try Realm()
                        try realm.write {
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
                }catch{
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            }
            else {
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
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Helper.deleteObjectsFromLocalStorage()
            self.searchVacationTableView.reloadData()
        }
        actionSheetController.addAction(resetMySearchAction)
        
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
        adultCounter = value
        if defaults.object(forKey: Constant.MyClassConstants.adultCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.adultCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        else {
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        searchVacationTableView.reloadData()
    }
    func childrenChanged(_ value:Int) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event67, data: nil)
        
        //***** updating children counter increment and decrement
        childCounter = value
        if defaults.object(forKey: Constant.MyClassConstants.childCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.childCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        searchVacationTableView.reloadData()
    }
    
}

//***** Custom SearchTableViewCell delegate method implementation *****//

//MARK:- Search Button Click
extension VacationSearchViewController:SearchTableViewCellDelegate {
    
    func searchButtonClicked(_ sender : IUIKButton) {
        
        //Set filter options availability
        Constant.MyClassConstants.noFilterOptions = false
        
        //Set travel PartyInfo
        let travelPartyInfo = TravelParty()
        travelPartyInfo.adults = Int(adultCounter)
        travelPartyInfo.children = Int(childCounter)
        
        //Saving it locally for further screens
        Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
        
        Helper.helperDelegate = self
        ADBMobile.trackAction(Constant.omnitureEvents.event1, data: nil)
        
        // MARK: All Available Destinations Vacation Search
        if(Constant.MyClassConstants.whereTogoContentArray.contains(Constant.MyClassConstants.allDestinations)){
            
            let (_,fromDateTop) = getSearchDatesTop()
            var searchType: VacationSearchType
            let checkInDate = fromDateTop
            let bookingWindow = BookingWindow(checkInDate: checkInDate)
            let activeInterval = bookingWindow.getActiveInterval()
            let requestRental = RentalSearchRegionsRequest()
            let requestExchange = ExchangeSearchRegionsRequest()
            
            //Seprate exchange, rental and search both region search
            if (segmentTitle  == Constant.segmentControlItems.exchange) {
                requestExchange.checkInFromDate = activeInterval?.startDate
                requestExchange.checkInToDate = activeInterval?.endDate
                searchType = VacationSearchType.Exchange
            }else if (segmentTitle  == Constant.segmentControlItems.getaways){
                requestRental.checkInFromDate = activeInterval?.startDate
                requestRental.checkInToDate = activeInterval?.endDate
                searchType = VacationSearchType.Rental
            }else{
                requestRental.checkInFromDate = activeInterval?.startDate
                requestRental.checkInToDate = activeInterval?.endDate
                searchType = VacationSearchType.Combined
            }
            
            showHudAsync()
            sender.isEnabled = false
            
            Constant.MyClassConstants.regionArray.removeAll()
            Constant.MyClassConstants.regionAreaDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeArray.removeAllObjects()
            
            if ((searchType.isRental() || searchType.isCombined()) ) {
                
                if(Constant.MyClassConstants.relinquishmentIdArray.count == 0 && searchType.isCombined()){
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    self.hideHudAsync()
                    sender.isEnabled = true
                    
                }else{
                    RentalClient.searchRegions(Session.sharedSession.userAccessToken, request: requestRental, onSuccess: {(response)in
                        DarwinSDK.logger.debug(response)
                        
                        for rsregion in response {
                            let region = Region()
                            region.regionName = rsregion.regionName
                            region.regionCode = rsregion.regionCode
                            region.areas = rsregion.areas
                            Constant.MyClassConstants.regionArray.append(rsregion)
                            
                            
                        }
                        self.hideHudAsync()
                        sender.isEnabled = true
                        self.performSegue(withIdentifier:Constant.segueIdentifiers.allAvailableDestinations, sender: self)
                        Constant.MyClassConstants.isFromExchangeAllAvailable = false
                        if(searchType.isCombined()){
                            Constant.MyClassConstants.isFromRentalAllAvailable = false
                        }else{
                            Constant.MyClassConstants.isFromRentalAllAvailable = true
                        }
                        
                        
                    }, onError: { (error) in
                        self.presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                        self.hideHudAsync()
                        sender.isEnabled = true
                    })
                }
            }else{
                
                if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    self.hideHudAsync()
                    sender.isEnabled = true
                    
                }else{
                    
                    ExchangeClient.searchRegions(Session.sharedSession.userAccessToken, request: requestExchange, onSuccess: { (response) in
                        
                        for rsregion in response {
                            
                            let region = Region()
                            region.regionName = rsregion.regionName
                            region.regionCode = rsregion.regionCode
                            region.areas = rsregion.areas
                            Constant.MyClassConstants.regionArray.append(rsregion)
                            
                        }
                        self.hideHudAsync()
                        sender.isEnabled = true
                        Constant.MyClassConstants.isFromExchangeAllAvailable = true
                        Constant.MyClassConstants.isFromRentalAllAvailable = false
                        self.performSegue(withIdentifier:Constant.segueIdentifiers.allAvailableDestinations, sender: self)
                        
                        
                    }, onError: { (error) in
                        self.hideHudAsync()
                        self.presentErrorAlert(UserFacingCommonError.generic)
                        
                    })
                }
                
            }
        }else{
            if (segmentTitle == Constant.segmentControlItems.getaways && (Helper.getAllResortsFromLocalStorage().count>0 || Constant.MyClassConstants.whereTogoContentArray.count>0)) {
                
                showHudAsync()
                sender.isEnabled = false
                
                if Reachability.isConnectedToNetwork() == true{
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    
                    if(storedData.count > 0) {
                        
                        // MARK: Rental Vacation Search
                        
                        let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
                        getSavedDestinationsResorts(storedData:storedData, searchCriteria:rentalSearchCriteria)
                        
                        rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        
                        
                        vacationSearch = VacationSearch(Session.sharedSession.appSettings, rentalSearchCriteria)
                        Constant.MyClassConstants.initialVacationSearch = vacationSearch
                        
                        RentalClient.searchDates(Session.sharedSession.userAccessToken, request: vacationSearch.rentalSearch?.searchContext.request,
                         onSuccess: { (response) in
                            sender.isEnabled = true
                            self.vacationSearch.rentalSearch?.searchContext.response = response
                            
                            // Get activeInterval
                            let activeInterval = self.vacationSearch.bookingWindow.getActiveInterval()
                            
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            
                            // Always show a fresh copy of the Scrolling Calendar
                            
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            
                            // Check not available checkIn dates for the active interval
                            if (activeInterval?.fetchedBefore) != nil && activeInterval?.hasCheckInDates() != nil{
                                self.hideHudAsync()
                                self.createFilterOptions()
                                (activeInterval?.hasCheckInDates())! ? self.rentalSearchAvailability(activeInterval: activeInterval!) : self.noAvailabilityResults()
                            }
                        },
                         onError:{ (error) in
                            self.hideHudAsync()
                            sender.isEnabled = true
                            self.presentErrorAlert(UserFacingCommonError.generic)
                        }
                        )
                    }
                } else{
                    sender.isEnabled = true
                    self.hideHudAsync()
                    presentErrorAlert(UserFacingCommonError.noNetConnection)
                }
                Constant.MyClassConstants.isFromExchange = false
                
            }else if(segmentTitle == Constant.segmentControlItems.exchange && (Helper.getAllDestinationFromLocalStorage().count>0 || Helper.getAllResortsFromLocalStorage().count>0)) {
                
                // MARK: Exchange Vacation Search
                if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                    sender.isEnabled = true
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                }else{
                    sender.isEnabled = false
                    showHudAsync()
                    
                    if Reachability.isConnectedToNetwork() == true {
                        
                        let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Exchange)
                        
                        exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                        exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                        exchangeSearchCriteria.searchType = VacationSearchType.Exchange
                        
                        let storedData = Helper.getLocalStorageWherewanttoGo()
                        
                        if(storedData.count > 0) {
                            
                            //Get data for saved destinations and resorts
                            getSavedDestinationsResorts(storedData:storedData, searchCriteria:exchangeSearchCriteria)
                            
                            Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, exchangeSearchCriteria)
                            
                            ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { (response) in
                                sender.isEnabled = true
                                self.hideHudAsync()
                                Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                // Get activeInterval (or initial search interval)
                                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                
                                // Update active interval
                                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                
                                // Check not available checkIn dates for the active interval
                                if activeInterval?.fetchedBefore != nil {
                                    if activeInterval?.hasCheckInDates() != nil{
                                        (activeInterval?.hasCheckInDates())! ? () : Helper.showNotAvailabilityResults()
                                        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
                                    }
                                }else{
                                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                    if let searchDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate{
                                        Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate:  Helper.convertStringToDate(dateString: searchDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    }
                                }
                                
                            }, onError: { (error) in
                                sender.isEnabled = true
                                self.hideHudAsync()
                                self.presentErrorAlert(UserFacingCommonError.generic)
                            })
                        }
                        
                    }else{
                        self.hideHudAsync()
                        presentErrorAlert(UserFacingCommonError.noNetConnection)
                    }
                }
                
                Constant.MyClassConstants.isFromExchange = true
            } else {
                if(segmentTitle == Constant.segmentControlItems.getaways){
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                }else if(segmentTitle == Constant.segmentControlItems.exchange){
                    if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                        presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    }else{
                        presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                    }
                }else{
                    
                    if(Constant.MyClassConstants.relinquishmentIdArray.count == 0){
                        sender.isEnabled = true
                        presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    }else if((Helper.getAllDestinationFromLocalStorage().count == 0 && Helper.getAllResortsFromLocalStorage().count == 0)){
                        presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                    }else{
                        showHudAsync()
                        let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Combined)
                        let storedData = Helper.getLocalStorageWherewanttoGo()
                        
                        if(storedData.count > 0) {
                            getSavedDestinationsResorts(storedData:storedData, searchCriteria:rentalSearchCriteria)
                            rentalSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as? [String]
                            rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                            rentalSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                            rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                            
                            Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, rentalSearchCriteria)
                            
                            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
                            
                            
                            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                                
                                self.hideHudAsync()
                                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                                // Update active interval
                                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                                Helper.helperDelegate = self
                                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                // Check not available checkIn dates for the active interval
                                if activeInterval?.fetchedBefore != nil && activeInterval?.hasCheckInDates() != nil{
                                    if !((activeInterval?.hasCheckInDates()))!{
                                        self.hideHudAsync()
                                        self.rentalHasNotAvailableCheckInDates = true
                                        Helper.executeExchangeSearchDates(senderVC: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    }
                                    
                                }else{
                                    self.hideHudAsync()
                                    if(response.checkInDates.count>0){
                                        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                    }
                                    if let vacationSearchInitialDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate{
                                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: Helper.convertStringToDate(dateString: vacationSearchInitialDate, format: Constant.MyClassConstants.dateFormat), senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    }else if Constant.MyClassConstants.initialVacationSearch.rentalSearch != nil{
                                        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate:response.checkInDates[0], senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                    }
                                }
                                Constant.MyClassConstants.checkInDates = response.checkInDates
                                sender.isEnabled = true
                                Constant.MyClassConstants.isFromSearchBoth = true
                                
                            })
                            { (error) in
                                self.hideHudAsync()
                                self.presentErrorAlert(UserFacingCommonError.generic)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Function to present with no availability
    func noAvailabilityResults(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
    self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Function for rental search availability
    
    func rentalSearchAvailability(activeInterval: BookingWindowInterval){
                                Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                self.hideHudAsync()
                                if let initialSearchCheckInDate = self.vacationSearch.searchCheckInDate{
                                    let searchDate = Helper.convertStringToDate(dateString:initialSearchCheckInDate,format:Constant.MyClassConstants.dateFormat)
                                    Helper.helperDelegate = self
                                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: searchDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                                }
                            }

    // Mark:- Set options for filter
    func createFilterOptions(){
        
        Constant.MyClassConstants.filterOptionsArray.removeAll()
        let storedData = Helper.getLocalStorageWherewanttoGo()
        let allDest = Helper.getLocalStorageAllDest()
        
        if(storedData.count > 0) {
            Constant.MyClassConstants.filterOptionsArray.removeAll()
            for object in storedData {
                
                if(object.destinations.count > 0){
                    Constant.MyClassConstants.filterOptionsArray.append(
                        .Destination(object.destinations[0])
                    )
                    
                }else if(object.resorts.count > 0){
                    
                    if(object.resorts[0].resortArray.count > 0){
                        
                        var arrayOfResorts = List<ResortByMap>()
                        var reswortByMap = [ResortByMap]()
                        arrayOfResorts = object.resorts[0].resortArray
                        for resort in arrayOfResorts{
                            reswortByMap.append(resort)
                        }
                        
                        Constant.MyClassConstants.filterOptionsArray.append(.ResortList(reswortByMap))
                    }else{
                        Constant.MyClassConstants.filterOptionsArray.append(.Resort(object.resorts[0]))
                    }
                }
            }
        }else if(allDest.count > 0){
            for areaCode in Constant.MyClassConstants.selectedAreaCodeArray{
                let dictionaryArea = ["\(areaCode)": Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: areaCode as! String)]
                Constant.MyClassConstants.filterOptionsArray.append(.Area(dictionaryArea as! NSMutableDictionary))
            }
        }
    }
    
    // Get data from local storage
    func getSavedDestinationsResorts(storedData:Results <RealmLocalStorage>, searchCriteria:VacationSearchCriteria){
        Constant.MyClassConstants.filteredIndex = 0
        if let savedDestinations = storedData.first?.destinations{
            if savedDestinations.count > 0{
                let destination = AreaOfInfluenceDestination()
                destination.destinationName  = savedDestinations.first?.destinationName
                destination.destinationId = savedDestinations.first?.destinationId
                destination.aoiId = savedDestinations.first?.aoid
                searchCriteria.destination = destination
                Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            }
        }else if let savedResorts = storedData.first?.resorts{
            
            if let resortArrayList = savedResorts.first?.resortArray{
                if resortArrayList.count > 0{
                    var resorts = [Resort]()
                    for selectedResort in resortArrayList{
                        let resort = Resort()
                        resort.resortName = selectedResort.resortName
                        resort.resortCode = selectedResort.resortCode
                        resorts.append(resort)
                    }
                    searchCriteria.resorts = resorts
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(String(describing: savedResorts.first?.resortArray.first?.resortName)) + more"
                }else{
                    let resort = Resort()
                    resort.resortName = savedResorts.first?.resortName
                    resort.resortCode = savedResorts.first?.resortCode
                    searchCriteria.resorts = [resort]
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName ?? ""
                }
            }
        }
    }
}


extension VacationSearchViewController:HelperDelegate {
    
    //When search request completes
    func resortSearchComplete(){
        self.hideHudAsync()
        // Check if not has availability in the desired check-In date.
        if (Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat)) {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        createFilterOptions()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //Function to reset scrolling calendar to show latest dates
    func resetCalendar(){
        Constant.MyClassConstants.calendarDatesArray.removeAll()
        Constant.MyClassConstants.calendarDatesArray = Constant.MyClassConstants.totalBucketArray
    }
}

