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
    @IBOutlet private weak var searchVacationSegementControl: UISegmentedControl!
    @IBOutlet weak var searchVacationTableView: UITableView!
    var homeTableCollectionView: UICollectionView!
    var getawayCollectionView: UICollectionView!
    
    //***** Class variables *****//
    var addButtonCellTag: Int?
    var childCounter = 0
    var adultCounter = 2
    var segmentIndex = 0
    var segmentTitle = ""
    let headerCellIndexPath = NSMutableArray()
    var destinationOrResort = Helper.getLocalStorageWherewanttoGo()
    let allDest = Helper.getLocalStorageAllDest()
    var datePickerPopupView: UIView?
    let defaults = UserDefaults.standard
    var sourceViewController: UIViewController?
    var destinationViewController: UIViewController?
    var moreButton: UIBarButtonItem?
    var showExchange = true
    var showGetaways = true
    //var vacationSearch = VacationSearch()
    var selectedFlexchange: FlexExchangeDeal?
    var searchDateRequest = RentalSearchDatesRequest()
    var rentalHasNotAvailableCheckInDates: Bool = false
    var exchangeHasNotAvailableCheckInDates: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isHidden = false
        searchVacationTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Constant.MyClassConstants.selectionType == 0 {
            
            // omniture tracking with event 64
            let userInfo: [String: Any] = [
                Constant.omnitureEvars.eVar25: Constant.MyClassConstants.destinationOrResortSelectedBy
                
                ]
            Constant.MyClassConstants.selectionType = -1
            ADBMobile.trackAction(Constant.omnitureEvents.event64, data: userInfo)
        } else if Constant.MyClassConstants.selectionType == 1 {
            
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
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            parent?.navigationItem.leftBarButtonItem = menuButton
            
            //***** Creating and adding right bar button for more option button *****//
            moreButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action: #selector(moreNavButtonPressed(_:)))
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

        // set font of sement control
        let font = UIFont(name: Constant.fontName.helveticaNeue, size: 18)
        searchVacationSegementControl.setTitleTextAttributes([NSFontAttributeName: font ?? 18],
                                                             for: .normal)
        searchVacationSegementControl.removeAllSegments()
        
        // updating segment control number of segment according to app settings response
        if let searchTypes = Session.sharedSession.appSettings?.vacationSearch?.vacationSearchTypes {
            for (i, searchType) in searchTypes.enumerated() {
                
                searchVacationSegementControl.insertSegment(withTitle: Helper.vacationSearchTypeSegemtStringToDisplay(vacationSearchType: searchType), at: i, animated: true)
                
                searchVacationSegementControl.selectedSegmentIndex = 0
                segmentTitle = searchVacationSegementControl.titleForSegment(at: 0)!
            }
        }
        
        var isPrePopulatedData = Constant.AlertPromtMessages.no
        searchVacationTableView.estimatedRowHeight = 100
        
        if Constant.MyClassConstants.whereTogoContentArray.count > 0 || Constant.MyClassConstants.whatToTradeArray.count > 0 {
            isPrePopulatedData = Constant.AlertPromtMessages.yes
        }
        // omniture tracking with event 87
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar20: isPrePopulatedData,
            Constant.omnitureEvars.eVar21: Constant.MyClassConstants.selectedDestinationNames,
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event87, data: userInfo)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
        
        if segmentIndex != 2 {
            
            //***** Registering the custom cell with UITabelview *****//
            let cellNib = UINib(nibName: Constant.customCellNibNames.whoIsTravelingCell, bundle: nil)
            searchVacationTableView?.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.whoIsTravelingCell)
        }
        
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // function to get vacation search details from nsuser defaults local storage
    func getVacationSearchDetails() {
        
        if let selecteddate = defaults.object(forKey: Constant.MyClassConstants.selectedDate) as? Date {
            
            if selecteddate.isLessThanDate(Constant.MyClassConstants.todaysDate) {
                Constant.MyClassConstants.vacationSearchShowDate = Constant.MyClassConstants.todaysDate
            } else {
                Constant.MyClassConstants.vacationSearchShowDate = selecteddate
            }
        } else {
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
        
        segmentIndex = sender.selectedSegmentIndex
        
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
            Constant.omnitureEvars.eVar24: Helper.selectedSegment(index: sender.selectedSegmentIndex)
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event63, data: userInfo)
        
    }
    
    //***** Calendar icon pressed action to present calendar controller *****//
    func calendarIconClicked(_ sender: IUIKButton) {
        ADBMobile.trackAction(Constant.omnitureEvents.event66, data: nil)
        self.performSegue(withIdentifier: Constant.segueIdentifiers.CalendarViewSegue, sender: nil)
    }
    
    //***** Add location pressed action to show map screen with list of location to select *****//
    func addLocationInSection0Pressed(_ sender: IUIKButton) {
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
    func addRelinquishmentSectionButtonPressed(_ sender: IUIKButton) {
        showHudAsync()
        ExchangeClient.getMyUnits(Session.sharedSession.userAccessToken, onSuccess: { relinquishments in
            
            Constant.MyClassConstants.relinquishmentDeposits = relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = relinquishments.openWeeks
            
            if let pointsProgram = relinquishments.pointsProgram {
                Constant.MyClassConstants.relinquishmentProgram = pointsProgram
                if let availablePoints = pointsProgram.availablePoints {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = availablePoints
                }
            }
            
            self.hideHudAsync()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RelinquishmentViewController") as? RelinquishmentViewController {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
                   
        }, onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
        
    }
    
    func refreshTableView() {
        self.hideHudAsync()
        searchVacationTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination.isKind(of: FlexchangeSearchViewController.self) {
            let selectedFlexchange = segue.destination as! FlexchangeSearchViewController
            selectedFlexchange.selectedFlexchange = self.selectedFlexchange
        }
        
    }
    
}

// MARK: - Extension classes starts from here

extension VacationSearchViewController: UICollectionViewDelegate {
    
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
        } else {
            self.topTenGetawaySelected(selectedIndexPath: indexPath)
        }
    }
    
}

extension VacationSearchViewController: UICollectionViewDataSource {
    
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
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, _:SDImageCacheType, _:URL?) in
                    if error != nil {
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
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16)
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
                
                resortFlaxImageView.setImageWith(URL(string: (deal.images[0].url) ?? ""), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                    if error != nil {
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
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16)
                cell.addSubview(resortImageNameLabel)
                
                let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
                centerView.center = resortFlaxImageView.center
                centerView.backgroundColor = UIColor(red: 176.0 / 255.0, green: 215.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
                
                let unitLabel = UILabel(frame: CGRect(x: 10, y: 15, width: centerView.frame.size.width - 20, height: 25))
                unitLabel.text = deal.details?.localized()
                unitLabel.numberOfLines = 2
                unitLabel.textAlignment = NSTextAlignment.center
                unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 12)
                unitLabel.textColor = UIColor.white
                unitLabel.backgroundColor = UIColor.clear
                centerView.addSubview(unitLabel)
                
                let priceLabel = UILabel(frame: CGRect(x: 10, y: 35, width: centerView.frame.size.width - 20, height: 20))
                if let pricefrom = deal.price?.fromPrice, let currencyCode = deal.price?.currencySymbol {
                    if let attributedAmount = pricefrom.currencyFormatter(for: currencyCode, baseLineOffSet: 0) {
                        let fromAttributedString = NSMutableAttributedString(string: "From ", attributes: nil)
                        let wkAttributedString = NSAttributedString(string: " Wk.", attributes: nil)
                        fromAttributedString.append(attributedAmount)
                        fromAttributedString.append(wkAttributedString)
                        priceLabel.attributedText = fromAttributedString
                    }
                    priceLabel.numberOfLines = 2
                    priceLabel.textAlignment = NSTextAlignment.center
                    priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
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

extension VacationSearchViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** Checking number of sections in tableview *****//
        if segmentTitle != Constant.segmentControlItems.getaways {
            
            //***** Return height according to section cell requirement *****//
            switch indexPath.section {
            case 0 :
                if indexPath.row < Constant.MyClassConstants.whereTogoContentArray.count {
                    return UITableViewAutomaticDimension
                } else {
                    return 60
                }
            case 1:
                if indexPath.row < Constant.MyClassConstants.whatToTradeArray.count {
                    return UITableViewAutomaticDimension
                } else {
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
        } else {
            
            //***** Return height according to section cell requirement *****//
            switch indexPath.section {
            case 0 :
                if indexPath.row < Constant.MyClassConstants.whereTogoContentArray.count {
                    return UITableViewAutomaticDimension
                } else {
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
        } else {
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
            } else {
                return 0
            }
        } else {
            if section < 3 {
                return 55
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (_, _) -> Void in
                if indexPath.section == 0 {
                    do {
                        let realm = try Realm()
                        if self.destinationOrResort.count > 0 {

                            let distinationID = self.destinationOrResort[indexPath.row].destinations.first?.destinationId ?? ""
                            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.remove(distinationID)

                            try realm.write {
                                realm.delete(self.destinationOrResort[indexPath.row])
                            }
                        } else {
                            Helper.deleteObjectFromAllDest()
                        }
                        if Constant.MyClassConstants.whereTogoContentArray.count > 0 {
                            ADBMobile.trackAction(Constant.omnitureEvents.event7, data: nil)
                            Constant.MyClassConstants.whereTogoContentArray.removeObject(at: indexPath.row)

                        }
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

                    } catch {
                        self.presentErrorAlert(UserFacingCommonError.generic)
                    }
                }
            }
            
            delete.backgroundColor = UIColor(red: 224 / 255.0, green: 96.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
            
            let details = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.details) { (_, index) -> Void in
                
                var resortsArray = [Resort]()
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
                
                for resortsToShow in Constant.MyClassConstants.whereTogoContentArray[index.row] as! List<ResortByMap> {
                    
                    let resort = Resort()
                    resort.resortName = resortsToShow.resortName
                    resort.resortCode = resortsToShow.resortCode
                    resort.address?.cityName = resortsToShow.resortCityName
                    resort.address?.territoryCode = resortsToShow.territorrycode
                    
                    resortsArray.append(resort)
                    
                }
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.resorts(resortsArray))
                
                   let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
                   let storyboardName = isRunningOnIphone ? Constant.storyboardNames.getawayAlertsIphone : Constant.storyboardNames.getawayAlertsIpad
                   let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
                   if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as? InfoDetailViewController {
                        viewController.selectedIndex = 0
                        self.navigationController?.present(viewController, animated: true, completion: nil)
                    }
            }
            
            details.backgroundColor = UIColor(red: 0 / 255.0, green: 119.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
            
            let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row]
            
            if (object as AnyObject) .isKind(of: List<ResortByMap>.self) {
                return [delete, details]
            } else {
                return [delete]
            }
        } else {
            
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.delete) { (_, index) -> Void in
                // var isFloat = true
                let storedData = Helper.getLocalStorageWherewanttoTrade()
                
                if storedData.count > 0 {
                    do {
                        let realm = try Realm()
                            try realm.write {
                                
                                if (Constant.MyClassConstants.whatToTradeArray[indexPath.row] as AnyObject).isKind(of: OpenWeeks.self) {
                                    
                                    var floatWeekIndex = -1
                                    let dataSelected = Constant.MyClassConstants.whatToTradeArray[indexPath.row] as! OpenWeeks
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
                                tableView.reloadSections(IndexSet(integer:indexPath.section), with: .automatic)
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
}

extension VacationSearchViewController: UITableViewDataSource {
    
    //***** Function to enable Swap deletion functionality *****//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if segmentTitle == Constant.segmentControlItems.searchBoth || segmentTitle == Constant.segmentControlItems.exchange {
            if indexPath.section == 0 {
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 || indexPath.row == Constant.MyClassConstants.whereTogoContentArray.count {
                    return false
                } else {
                    return true
                }
            } else if indexPath.section == 1 {
                if Constant.MyClassConstants.whatToTradeArray.count == 0 || indexPath.row == Constant.MyClassConstants.whatToTradeArray.count {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        } else if indexPath.section == 0 {
            if Constant.MyClassConstants.whereTogoContentArray.count == 0 || indexPath.row == Constant.MyClassConstants.whereTogoContentArray.count {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch segmentTitle {
        case Constant.segmentControlItems.getaways :
            if Constant.MyClassConstants.topDeals.isEmpty {
                return 4
            } else {
                return 5
            }
        case Constant.segmentControlItems.exchange :
            if Constant.MyClassConstants.flexExchangeDeals.isEmpty {
                return 5
            } else {
                return 6
            }
        default :
            if !Constant.MyClassConstants.flexExchangeDeals.isEmpty && !Constant.MyClassConstants.topDeals.isEmpty {
                return 7
            } else if !Constant.MyClassConstants.flexExchangeDeals.isEmpty || !Constant.MyClassConstants.topDeals.isEmpty {
                return 6
            } else {
                return 5
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return Constant.MyClassConstants.whereTogoContentArray.count + 1
            
        case 1:
            if segmentTitle != Constant.segmentControlItems.getaways {
                return Constant.MyClassConstants.whatToTradeArray.count + 1
            } else {
                return 1
            }
            
        default:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
                        let cell_width = cell.contentView.bounds.width
                        let addLocationButton = IUIKButton(frame: CGRect(x: cell_width / 2 - (cell_width / 5) / 2, y: 15, width: cell_width / 5, height: 30))
                        addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                        addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
                        addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                        addLocationButton.layer.cornerRadius = 6
                        addLocationButton.layer.borderWidth = 2
                        addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addLocationInSection0Pressed(_:)), for: .touchUpInside)
                        cell.backgroundColor = UIColor.clear
                        cell.addSubview(addLocationButton)
                        
                        return cell
                    } else {
                        
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WhereToGoCell", for: indexPath) as? WhereToGoContentCell else { return UITableViewCell() }
                        
                        if indexPath.row == destinationOrResort.count - 1 || destinationOrResort.count == 0 {
                            cell.sepratorOr.isHidden = true
                        } else {
                            
                            cell.sepratorOr.isHidden = false
                        }
                        
                        let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as AnyObject
                        if object.isKind(of: Resort.self) {
                            
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
                        } else if object.isKind(of: List<ResortByMap>.self) {
                            
                            let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as! List<ResortByMap>
                            
                            let resort = object[0]
                            
                            var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
                            if object.count > 1 {
                                resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \(object.count - 1) \(Constant.getDynamicString.moreString)"
                            }
                            
                            cell.whereTogoTextLabel.text = resortNameString
                        } else {
                            cell.whereTogoTextLabel.text = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as? String
                        }
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        cell.backgroundColor = UIColor.clear
                        return cell
                    }
                } else {
                    
                    //***** Checking array content to configure and return content cell or calendar cell *****//
                    
                    if Constant.MyClassConstants.whatToTradeArray.count == 0 || indexPath.row == Constant.MyClassConstants.whatToTradeArray.count {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        for subview in cell.subviews {
                            subview.removeFromSuperview()
                        }
                        let cell_width = cell.contentView.bounds.width
                        let addLocationButton = IUIKButton(frame: CGRect(x: cell_width / 2 - (cell_width / 5) / 2, y: 15, width: cell_width / 5, height: 30))
                        addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                        addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
                        addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                        addLocationButton.layer.cornerRadius = 6
                        addLocationButton.layer.borderWidth = 2
                        addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addRelinquishmentSectionButtonPressed(_:)), for: .touchUpInside)
                        
                        cell.addSubview(addLocationButton)
                        cell.backgroundColor = UIColor.clear
                        return cell
                    } else {
                        
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WhereToGoContentCell", for: indexPath) as? WhereToGoContentCell else { return UITableViewCell() }
                        
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
                            if weekNumber != "" {
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
                                cell.whereTogoTextLabel.text = "Club Points up to \(String(describing: pointsSpent))".localized()
                            }
                            cell.bedroomLabel.isHidden = true
                            return cell
                        } else {
                            
                            let availablePointsNumber = Constant.MyClassConstants.relinquishmentAvailablePointsProgram as NSNumber
                            let numberFormatter = NumberFormatter()
                            numberFormatter.numberStyle = .decimal
                            
                            if let availablePoints = numberFormatter.string(from: availablePointsNumber) {
                                cell.whereTogoTextLabel.text = "\(Constant.getDynamicString.clubInterValPointsUpTo) \(availablePoints)"
                            }
                            
                            cell.bedroomLabel.isHidden = true
                        }
                        
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        cell.backgroundColor = UIColor.clear
                        return cell
                    }
                }
            } else if indexPath.section == 2 {
                
                //***** Configure and return calendar cell  *****//
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.caledarDateCell, for: indexPath) as? CaledarDateCell else { return UITableViewCell() }
                
                debugPrint(Constant.MyClassConstants.vacationSearchShowDate)

                let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: Constant.MyClassConstants.vacationSearchShowDate)
                debugPrint(myComponents.year, myComponents.month, myComponents.day)
                
                if let day = myComponents.day {
                    if day < 10 {
                        cell.dayDateLabel.text = "0\(String(describing: day))".localized()
                    } else {
                        cell.dayDateLabel.text = "\(String(describing: day))".localized()
                    }
                }
                if let weekDay = myComponents.weekday {
                    cell.dateWithDateFormatLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))".localized()
                }
                if let month = myComponents.month {
                    cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month))".localized()
                    if let year = myComponents.year {
                       cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)".localized()
                    }
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.calendarIconButton.addTarget(self, action: #selector(VacationSearchIPadViewController.calendarIconClicked(_:)), for: .touchUpInside)
                cell.backgroundColor = UIColor.clear
                return cell
            } else if indexPath.section == 3 {
                
                //***** Configure and return cell according to sections in tableview *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whoIsTravelingCell, for: indexPath) as! WhoIsTravelingCell
                cell.adultCounterLabel.text = String(adultCounter)
                cell.childCounterLabel.text = String(childCounter)
                cell.delegate = self
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
            } else if indexPath.section == 5 || indexPath.section == 6 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                //header for top ten deals
                if indexPath.section == 5 {
                    if !showExchange {
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                        
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                        cell.addSubview(resortImageNameLabel)
                    } else {
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                        cell.addSubview(resortImageNameLabel)
                        
                    }
                } else {
                    
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                    cell.addSubview(resortImageNameLabel)
                }
                
                //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
                
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                layout.itemSize = CGSize(width: 280, height: 220 )
                layout.minimumInteritemSpacing = 1.0
                layout.minimumLineSpacing = 10.0
                layout.scrollDirection = .horizontal
                homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 230 ), collectionViewLayout: layout)
                
                homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
                homeTableCollectionView.backgroundColor = UIColor.clear
                homeTableCollectionView.delegate = self
                homeTableCollectionView.dataSource = self
                if indexPath.section == 5 {
                    homeTableCollectionView.tag = 1
                } else {
                    homeTableCollectionView.tag = 2
                }
                
                homeTableCollectionView.isScrollEnabled = true
                cell.backgroundColor = UIColor(red: 240.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
                cell.addSubview(homeTableCollectionView)
                homeTableCollectionView.reloadData()
                return cell
            } else {
                
                //***** Configure and return search vacation cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.SearchVacationCell, for: indexPath) as! SearchTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self
                cell.backgroundColor = UIColor.clear
                return cell
                
            }
        } else {
            
            if indexPath.section == 0 {
                
                //***** Checking array content to configure and return content cell or add button cell *****//
                
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 || indexPath.row == Constant.MyClassConstants.whereTogoContentArray.count {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    for subview in cell.subviews {
                        subview.removeFromSuperview()
                    }
                    
                    let cell_width = cell.contentView.bounds.width
                    let addLocationButton = IUIKButton(frame: CGRect(x: cell_width / 2 - (cell_width / 5) / 2, y: 15, width: cell_width / 5, height: 30))
                    addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                    addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
                    addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                    addLocationButton.layer.cornerRadius = 4
                    addLocationButton.layer.borderWidth = 2
                    cell.addSubview(addLocationButton)
                    cell.backgroundColor = UIColor.clear
                    addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addLocationInSection0Pressed(_:)), for: .touchUpInside)
                    return cell
                } else {
                    
                    guard let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: "WhereToGoCell", for: indexPath) as? WhereToGoContentCell else { return UITableViewCell() }
                    
                    if indexPath.row == destinationOrResort.count - 1 || destinationOrResort.count == 0 {
                        
                        cell.sepratorOr.isHidden = true
                    } else {
                        
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
                    } else if object.isKind(of: List<ResortByMap>.self) {
                        
                        let object = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as! List<ResortByMap>
                        
                        let resort = object[0]
                        
                        var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
                        if object.count > 1 {
                            resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \(object.count - 1) \(Constant.getDynamicString.moreString)"
                        }
                        
                        cell.whereTogoTextLabel.text = resortNameString
                    } else {
                        cell.whereTogoTextLabel.text = Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as? String
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
                
            } else if indexPath.section == 1 {
                
                //***** Return calendar cell *****//
               guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.caledarDateCell, for: indexPath) as? CaledarDateCell else { return UITableViewCell() }
                
                let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: Constant.MyClassConstants.vacationSearchShowDate)
                
                if let day = myComponents.day {
                    if String(describing: day).count == 1 {
                        cell.dayDateLabel.text = "0\(String(describing: day))"
                    } else {
                        cell.dayDateLabel.text = "\(String(describing: day))"
                    }
                }
                
                if let weekDay = myComponents.weekday {
                    cell.dateWithDateFormatLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))"
                }
                if let month = myComponents.month {
                    cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month))"
                    if let year = myComponents.year {
                        cell.dateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
                    }
                }
                
                cell.calendarIconButton.addTarget(self, action: #selector(VacationSearchViewController.calendarIconClicked(_:)), for: .touchUpInside)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
            } else if indexPath.section == 2 {
                
                //***** Return calendar cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whoIsTravelingCell, for: indexPath) as! WhoIsTravelingCell
                
                cell.adultCounterLabel.text = String(adultCounter)
                cell.childCounterLabel.text = String(childCounter)
                cell.delegate = self
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
                
            } else if indexPath.section == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                //header for top ten deals
                if indexPath.section == 4 {
                    if !showExchange {
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                        
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                        cell.addSubview(resortImageNameLabel)
                    } else {
                        let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                        resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                        resortImageNameLabel.textColor = UIColor.black
                        resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                        cell.addSubview(resortImageNameLabel)
                    }
                } else {
                    
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                    cell.addSubview(resortImageNameLabel)
                }
                
                //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
                
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                layout.itemSize = CGSize(width: 280, height: 220 )
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
                cell.backgroundColor = UIColor(red: 240.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
                cell.addSubview(getawayCollectionView)
                getawayCollectionView.reloadData()
                
                return cell
            } else {
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
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            if indexPath.section == 0 {
                do {
                    let realm = try Realm()
                        try realm.write {
                            realm.delete(destinationOrResort[indexPath.row])
                        }
                        if Constant.MyClassConstants.whereTogoContentArray.count > 0 {
                            Constant.MyClassConstants.whereTogoContentArray.removeObject(at: indexPath.row)
                            if Constant.MyClassConstants.realmStoredDestIdOrCodeArray.count > 0 {
                                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: indexPath.row)
                            }
                        }
                        if Constant.MyClassConstants.realmStoredDestIdOrCodeArray.count > 0 {
                            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: indexPath.row)
                        }
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            tableView.reloadSections(IndexSet(integer:indexPath.section), with: .automatic)
                        }
                } catch {
                    self.presentErrorAlert(UserFacingCommonError.generic)
                }
                
            } else {
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    tableView.reloadSections(IndexSet(integer:indexPath.section), with: .automatic)
                }
            }
        }
    }
    
    func moreNavButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: Constant.buttonTitles.searchOption, preferredStyle: .actionSheet)
        
        let attributedText = NSMutableAttributedString(string: Constant.buttonTitles.searchOption)
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSKernAttributeName, value: 1.5, range: range)
        if let font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 18.0) {
            attributedText.addAttribute(NSFontAttributeName, value: font, range: range)
            actionSheetController.setValue(attributedText, forKey: "attributedMessage")
        }
        
        //***** Create and add the Reset my search *****//
        let resetMySearchAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.resetMySearch, style: .default) { _ -> Void in
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Helper.deleteObjectsFromLocalStorage()
            self.searchVacationTableView.reloadData()
        }
        actionSheetController.addAction(resetMySearchAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { _ -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Present the AlertController
        present(actionSheetController, animated: true)
    }
}

//***** Custom WhoIsTravelingCell delegate method implementation *****//

extension VacationSearchViewController: WhoIsTravelingCellDelegate {
    
    func adultChanged(_ value: Int) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event67, data: nil)
        //***** updating adult counter increment and decrement
        adultCounter = value
        if defaults.object(forKey: Constant.MyClassConstants.adultCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.adultCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        } else {
            defaults.set(value, forKey: Constant.MyClassConstants.adultCounterString)
            defaults.synchronize()
        }
        searchVacationTableView.reloadData()
    }
    func childrenChanged(_ value: Int) {
        
        ADBMobile.trackAction(Constant.omnitureEvents.event67, data: nil)
        
        //***** updating children counter increment and decrement
        childCounter = value
        if defaults.object(forKey: Constant.MyClassConstants.childCounterString) != nil {
            
            defaults.removeObject(forKey: Constant.MyClassConstants.childCounterString)
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        } else {
            
            defaults.set(value, forKey: Constant.MyClassConstants.childCounterString)
            defaults.synchronize()
        }
        searchVacationTableView.reloadData()
    }
    
}

//***** Custom SearchTableViewCell delegate method implementation *****//

// MARK: - Search Button Click
extension VacationSearchViewController: SearchTableViewCellDelegate {
    
    func searchButtonClicked(_ sender: IUIKButton) {
        
        var isNetworkAbl: String?
        if Reachability.isConnectedToNetwork() { isNetworkAbl = "Yes" }
        guard let _ = isNetworkAbl else { return presentErrorAlert(UserFacingCommonError.noNetConnection) }
        
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
        if Constant.MyClassConstants.whereTogoContentArray.contains(Constant.MyClassConstants.allDestinations) {
            
            let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
            let dateComp = calendar.dateComponents([.day], from: Constant.MyClassConstants.vacationSearchShowDate)
            let checkInToDate = dateComp.day ?? 0
            var searchType: VacationSearchType
            let requestRental = RentalSearchRegionsRequest()
            let requestExchange = ExchangeSearchRegionsRequest()
            
            //Seprate exchange, rental and search both region search
            switch segmentTitle {
                case Constant.segmentControlItems.exchange:
                    requestExchange.setCheckInToDate(checkInToDate)
                    searchType = VacationSearchType.EXCHANGE
                
                case Constant.segmentControlItems.getaways:
                    requestRental.setCheckInToDate(checkInToDate)
                    searchType = VacationSearchType.RENTAL

                default:
                    requestRental.setCheckInToDate(checkInToDate)
                    searchType = VacationSearchType.COMBINED
            }
            
            showHudAsync()
            sender.isEnabled = false
            Constant.MyClassConstants.regionArray.removeAll()
            Constant.MyClassConstants.regionAreaDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeDictionary.removeAllObjects()
            Constant.MyClassConstants.selectedAreaCodeArray.removeAllObjects()
            
            if searchType.isRental() || searchType.isCombined() {
                
                if Constant.MyClassConstants.relinquishmentIdArray.isEmpty && searchType.isCombined() {
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    self.hideHudAsync()
                    sender.isEnabled = true
                    
                } else {
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
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.allAvailableDestinations, sender: self)
                        Constant.MyClassConstants.isFromExchangeAllAvailable = false
                        if searchType.isCombined() {
                            Constant.MyClassConstants.isFromRentalAllAvailable = false
                        } else {
                            Constant.MyClassConstants.isFromRentalAllAvailable = true
                        }
                        
                    }, onError: { _ in
                        self.presentErrorAlert(UserFacingCommonError.generic)
                        self.hideHudAsync()
                        sender.isEnabled = true
                    })
                }
            } else {
                
                if Constant.MyClassConstants.relinquishmentIdArray.isEmpty {
                    presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                    self.hideHudAsync()
                    sender.isEnabled = true
                    
                } else {
                    
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
                        self.performSegue(withIdentifier: Constant.segueIdentifiers.allAvailableDestinations, sender: self)
                        
                    }, onError: { _ in
                        sender.isEnabled = true
                        self.hideHudAsync()
                        self.presentErrorAlert(UserFacingCommonError.generic)
                        
                    })
                }
                
            }
        } else {
            
            switch segmentTitle {
            case Constant.segmentControlItems.getaways:
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 {
                     presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                } else {
               
                sender.isEnabled = false
                let storedData = Helper.getLocalStorageWherewanttoGo()
                if !storedData.isEmpty {
                 showHudAsync()
                // MARK: Rental Vacation Search
                let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.RENTAL)
                getSavedDestinationsResorts(storedData: storedData, searchCriteria: rentalSearchCriteria)
                rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                rentalSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo

                if let settings = Session.sharedSession.appSettings {
                    Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, rentalSearchCriteria)
                }

                RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { (response) in
                   
                    sender.isEnabled = true
                    Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                    // Get activeInterval
                    guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                    // Update active interval
                    Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                    // Always show a fresh copy of the Scrolling Calendar
                    Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                    Helper.helperDelegate = self
                    // Check not available checkIn dates for the active interval
                    (activeInterval.hasCheckInDates()) ? self.rentalSearchAvailability(activeInterval: activeInterval) : self.noAvailabilityResults()
                                                    
                    },
                     onError: { (_) in
                        self.hideHudAsync()
                        sender.isEnabled = true
                        self.presentErrorAlert(UserFacingCommonError.generic)
                    }
                )}
                Constant.MyClassConstants.isFromExchange = false
                }
              
            case Constant.segmentControlItems.exchange:
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 {
                     presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                } else if Constant.MyClassConstants.relinquishmentIdArray.isEmpty {
                     presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                } else {
                    sender.isEnabled = false
                    showHudAsync()
                    let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.EXCHANGE)
                        exchangeSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                        exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        exchangeSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                    
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    if !storedData.isEmpty {
                        
                        //Get data for saved destinations and resorts
                        getSavedDestinationsResorts(storedData: storedData, searchCriteria: exchangeSearchCriteria)
                        
                        if let settings = Session.sharedSession.appSettings {
                            Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, exchangeSearchCriteria)
                        }
                        
                        ExchangeClient.searchDates(Session.sharedSession.userAccessToken, request:Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.request, onSuccess: { response in
                            
                            sender.isEnabled = true
                            Constant.MyClassConstants.initialVacationSearch.exchangeSearch?.searchContext.response = response
                    
                            // Get activeInterval (or initial search interval)
                            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            // Check not available checkIn dates for the active interval
                            activeInterval.hasCheckInDates() ? self.exchangeSearchAvailability(activeInterval: activeInterval) : self.noAvailabilityResults()
                            
                        }, onError: { _ in
                            sender.isEnabled = true
                            self.hideHudAsync()
                            self.presentErrorAlert(UserFacingCommonError.generic)
                        })
                    }
                    hideHudAsync()
                  Constant.MyClassConstants.isFromExchange = true
                }

            case Constant.segmentControlItems.searchBoth:
                if Constant.MyClassConstants.whereTogoContentArray.count == 0 {
                     presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.searchVacationMessage)
                } else if Constant.MyClassConstants.relinquishmentIdArray.isEmpty {
                     presentAlert(with: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.tradeItemMessage)
                } else {
                    showHudAsync()
                    let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.COMBINED)
                    let storedData = Helper.getLocalStorageWherewanttoGo()
                    
                    if storedData.count > 0 {
                        getSavedDestinationsResorts(storedData: storedData, searchCriteria: rentalSearchCriteria)
                        rentalSearchCriteria.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray
                        rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
                        rentalSearchCriteria.travelParty = Constant.MyClassConstants.travelPartyInfo
                        
                        if let settings = Session.sharedSession.appSettings {
                            Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, rentalSearchCriteria)
                        }
                         
                        ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
                        RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess: { response in
                            
                            Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                            guard let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval() else { return }
                            // Update active interval
                            Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                            Helper.helperDelegate = self
                            Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                            
                            // Check not available checkIn dates for the active interval
                            if !activeInterval.hasCheckInDates() {
                                self.rentalHasNotAvailableCheckInDates = true
                                Helper.executeExchangeSearchDates(senderVC: self)
                            } else {
                            Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                                let checkInDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat)
                                Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: checkInDate, senderViewController: self)
                                
                                sender.isEnabled = true
                                Constant.MyClassConstants.isFromSearchBoth = true
                            }
                            
                        }) { _ in
                            self.hideHudAsync()
                            self.presentErrorAlert(UserFacingCommonError.generic)
                        }
                    }
                    hideHudAsync()
                }

            default:
                break
            }
        }
    }
    
    // Function to present with no availability

    func noAvailabilityResults() {
        hideHudAsync()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Function for rental search availability
    
    func rentalSearchAvailability(activeInterval: BookingWindowInterval) {
        
        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
        let searchDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.initialVacationSearch.searchCheckInDate ?? "", format: Constant.MyClassConstants.dateFormat)
        debugPrint(searchDate)
        Helper.helperDelegate = self
        Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: searchDate, senderViewController: self)
     }
    
    // MARK: Function for exchange search availability
    
    func exchangeSearchAvailability(activeInterval: BookingWindowInterval) {

        Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
        if let searchDate = Constant.MyClassConstants.initialVacationSearch.searchCheckInDate {
            let checkInDate = Helper.convertStringToDate(dateString: searchDate, format: Constant.MyClassConstants.dateFormat)
            Helper.executeExchangeSearchAvailability(activeInterval: activeInterval, checkInDate: checkInDate, senderViewController: self)
        }

    }

    // MARK: Set options for filter
    func createFilterOptions() {
        Constant.MyClassConstants.filterOptionsArray.removeAll()
        let storedData = Helper.getLocalStorageWherewanttoGo()
        let allDest = Helper.getLocalStorageAllDest()
        
        if storedData.count > 0 {
            Constant.MyClassConstants.filterOptionsArray.removeAll()
            for object in storedData {
                
                if object.destinations.count > 0 {
                    Constant.MyClassConstants.filterOptionsArray.append(
                        .Destination(object.destinations[0])
                    )
                    
                } else if object.resorts.count > 0 {
                    
                    if object.resorts[0].resortArray.count > 0 {
                        
                        var arrayOfResorts = List<ResortByMap>()
                        var reswortByMap = [ResortByMap]()
                        arrayOfResorts = object.resorts[0].resortArray
                        for resort in arrayOfResorts {
                            reswortByMap.append(resort)
                        }
                        
                        Constant.MyClassConstants.filterOptionsArray.append(.ResortList(reswortByMap))
                    } else {
                        Constant.MyClassConstants.filterOptionsArray.append(.Resort(object.resorts[0]))
                    }
                }
            }
        } else if allDest.count > 0 {
            for areaCode in Constant.MyClassConstants.selectedAreaCodeArray {
                let dictionaryArea = ["\(areaCode)": Constant.MyClassConstants.selectedAreaCodeDictionary.value(forKey: areaCode as! String)]
                Constant.MyClassConstants.filterOptionsArray.append(.Area(dictionaryArea as! NSMutableDictionary))
            }
        }
    }
    
    // Get data from local storage
    func getSavedDestinationsResorts(storedData: Results <RealmLocalStorage>, searchCriteria: VacationSearchCriteria) {
        Constant.MyClassConstants.filteredIndex = 0
        if storedData.first?.destinations.count ?? 0 > 0 {
           
            let destination = AreaOfInfluenceDestination()
            destination.destinationName = storedData.first?.destinations.first?.destinationName
            destination.destinationId = storedData.first?.destinations.first?.destinationId
            destination.aoiId = storedData.first?.destinations.first?.aoid
            searchCriteria.destination = destination
            Constant.MyClassConstants.vacationSearchResultHeaderLabel = destination.destinationName
            
        } else if storedData.first?.resorts.count ?? 0 > 0 {
            
            if let resortArrayList = storedData.first?.resorts.first?.resortArray {
                if resortArrayList.count > 0 {
                    var resorts = [Resort]()
                    for selectedResort in resortArrayList {
                        let resort = Resort()
                        resort.resortName = selectedResort.resortName
                        resort.resortCode = selectedResort.resortCode
                        resorts.append(resort)
                    }
                    searchCriteria.resorts = resorts
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = "\(String(describing: storedData.first?.resorts.first?.resortArray.first?.resortName)) + more"
                } else {
                    let resort = Resort()
                    resort.resortName = storedData.first?.resorts.first?.resortName
                    resort.resortCode = storedData.first?.resorts.first?.resortCode
                    searchCriteria.resorts = [resort]
                    Constant.MyClassConstants.vacationSearchResultHeaderLabel = resort.resortName ?? ""
                }
            }
        }
        createFilterOptions()
    }
}

extension VacationSearchViewController: HelperDelegate {
    
    //When search request completes
    func resortSearchComplete() {
        self.hideHudAsync()
        // Check if not has availability in the desired check-In date.
        let userSelectedCheckInDate = Helper.convertDateToString(date: Constant.MyClassConstants.vacationSearchShowDate, format: Constant.MyClassConstants.dateFormat)
        if Constant.MyClassConstants.initialVacationSearch.searchCheckInDate != userSelectedCheckInDate {
            Helper.showNearestCheckInDateSelectedMessage()
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
       if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as? SearchResultViewController {
             navigationController?.pushViewController(viewController, animated: true)
        }
       
    }
}
