//
//  DashboardTableViewController.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD
import SDWebImage

class DashboardTableViewController: UITableViewController {
    
    //***** Outlets *****//
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var homeTableCollectionView:UICollectionView!
    @IBOutlet var homeTableView: UITableView!
    
    //***** Variables *****//
    var segmentSelectedIndex:Int = 0
    var noUpcomingTrip = false
    var showGetaways = true
    var showExchange = true
    var dashboardArray = NSMutableArray()
    var alertWithResultsArray = [RentalAlert]()
    var isRunningOnIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    override func viewWillAppear(_ animated: Bool) {
        //***** Adding notification to reload alert badge *****//
        //self.hideHudAsync()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgeView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopDestinations), name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUpcomingTrip), name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        self.getNumberOfSections()
        Helper.InitializeOpenWeeksFromLocalStorage()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //***** Removing notification to reload alert badge *****//
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Remove
        // The singleton anti pattern has several race conditions. This is a temporary workaround until we get rid of it.
        showHudAsync()
        let delayInSeconds = 1.5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            // omniture tracking with event40
            let userInfo: [String: String] = [
                Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.homeDashboard
            ]
            
            ADBMobile.trackState( Constant.omnitureEvents.event40, data: userInfo)
            
            self.getNumberOfSections()
            Helper.getTopDeals(senderVC: self)
            
            
            Helper.getFlexExchangeDeals(senderVC: self) { (success) in
                if success {
                    self.getNumberOfSections()
                    self.homeTableView.reloadData()
                    
                } else {
                    
                }
            }
            
            //***** Set general Nav attributes *****//
            self.title = Constant.ControllerTitles.dashboardTableViewController
            
            //***** Setup the hamburger menu.  This will reveal the side menu. *****//
            if let rvc = self.revealViewController() {
                //set SWRevealViewController's Delegate
                rvc.delegate = self
                
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                
                self.navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
            }
        }
    }
    
    //***** Function called when notification for upcoming trips details is fired. *****//
    func reloadUpcomingTrip(){
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil){
            let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
            let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as? UpComingTripDetailController
            let navController = UINavigationController(rootViewController: resultController!)
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    //***** Function called when notification for getaway alerts is fired. *****//
    func reloadBadgeView(){
        self.getNumberOfSections()
        homeTableView.reloadData()
    }
    
    //***** Function to calculate number of sections. *****//
    
    func getNumberOfSections(){
        self.dashboardArray.removeAllObjects()
        if(Constant.MyClassConstants.dashBoardAlertsArray.count > 0){
            self.getDashBoardAlertsWithSearchResults()
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.alert)
        }
        if(Constant.MyClassConstants.upcomingTripsArray.count > 0){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.upcoming)
        }
        if(showExchange && showGetaways){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.search)
            
            if Constant.MyClassConstants.flexExchangeDeals.count > 0 {
                self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.exchange)
            }
            
            if((Constant.MyClassConstants.topDeals.count) > 0){
                self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.getaway)
            }
        }
        if(!showExchange && !showGetaways){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.search)
        }
    }
    
    func getDashBoardAlertsWithSearchResults(){
        self.alertWithResultsArray.removeAll()
        for resultAlerts in Constant.MyClassConstants.alertsResortCodeDictionary{
            if((resultAlerts.value as AnyObject).count > 0){
                for alertWithDates in Constant.MyClassConstants.getawayAlertsArray{
                    if(alertWithDates.alertId == Int64("\(resultAlerts.key)")){
                      alertWithResultsArray.append(alertWithDates)
                    }
                }
            }
        }
    }
    
    //***** Function called when notification for top 10 deals is fired. *****//
    func reloadTopDestinations(){
        self.getNumberOfSections()
        self.homeTableView.reloadData()
    }
    
    //***** MARK: - Table view delegate methods *****//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(dashboardArray[indexPath.section] as! String == Constant.dashboardTableScreenReusableIdentifiers.upcoming){
            
            Constant.MyClassConstants.transactionNumber = "\(Constant.MyClassConstants.upcomingTripsArray[indexPath.row].exchangeNumber!)"
            Helper.getTripDetails(senderViewController: self)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //***** return row height according to section cell *****//
        if(dashboardArray[indexPath.section] as! String == Constant.dashboardTableScreenReusableIdentifiers.upcoming || dashboardArray[indexPath.section] as! String == Constant.dashboardTableScreenReusableIdentifiers.alert || dashboardArray[indexPath.section] as! String == Constant.dashboardTableScreenReusableIdentifiers.search){
            return 70
        }else{
            return 290
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //***** Configure header cell for each section to show header labels *****//
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.headerCell) as! CustomHeaderCell
        
        if(dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.alert){
            headerCell.headerLabel.text = Constant.dashboardTableViewControllerHeaderText.gatewayAlerts
            headerCell.alertCounterLabel.isHidden = false
            
            var activeAlertsCount = 0
            if(Constant.MyClassConstants.getawayAlertsArray.count > 0){
                for activeAlert in Constant.MyClassConstants.activeAlertsArray{
                    let getAwayAlert:RentalAlert = activeAlert as! RentalAlert
                    if (getAwayAlert.enabled)!{
                        activeAlertsCount = activeAlertsCount + 1
                    }
                }
                if(activeAlertsCount>0){
                    headerCell.alertCounterLabel.text = String(activeAlertsCount)
                }else{
                    headerCell.alertCounterLabel.isHidden = true
                }
            }else{
                headerCell.alertCounterLabel.isHidden = true
            }
            
            headerCell.alertCounterLabel.textAlignment = NSTextAlignment.center
            headerCell.alertCounterLabel.layer.masksToBounds = true
            headerCell.alertCounterLabel.layer.cornerRadius = 8
            headerCell.headerDetailButton.setTitle(Constant.buttonTitles.viewAllAlerts, for: UIControlState.normal)
            headerCell.headerDetailButton.addTarget(self, action: #selector(DashboardTableViewController.viewAllAlertButtonPressed(_:)), for: .touchUpInside)
        }else if(dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.upcoming){
            headerCell.headerLabel.text = Constant.dashboardTableViewControllerHeaderText.myUpcomingTrips
            headerCell.alertCounterLabel.isHidden = true
            headerCell.headerDetailButton.setTitle(Constant.buttonTitles.viewAllTrips, for: UIControlState.normal)
            headerCell.headerDetailButton.addTarget(self, action: #selector(DashboardTableViewController.viewAllTripButtonPressed(_:)), for: .touchUpInside)
        }else if(dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.search){
            headerCell.headerLabel.text = Constant.dashboardTableViewControllerHeaderText.planVacation
            headerCell.alertCounterLabel.isHidden = true
        }else{
            headerCell.headerLabel.text = nil
            headerCell.alertCounterLabel.isHidden = true
        }
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.getaway || dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.exchange){
            return 0
        }else{
            return 50
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dashboardArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.alert){
            if(self.alertWithResultsArray.count >= 3){
                return 3
            }else{
                return self.alertWithResultsArray.count
            }
        }else if(dashboardArray[section] as! String == Constant.dashboardTableScreenReusableIdentifiers.upcoming){
            if( Constant.MyClassConstants.upcomingTripsArray.count <= 2) {
                
                return Constant.MyClassConstants.upcomingTripsArray.count
            }else {
                return 2
            }
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(dashboardArray[indexPath.section])
        let cell = getTableViewContents(indexPath, type: dashboardArray[indexPath.section] as! String)
        return cell
        
    }
    
    func getTableViewContents(_ indexPath:IndexPath, type:String) -> UITableViewCell{
        
        if(type == Constant.dashboardTableScreenReusableIdentifiers.alert){
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell, for: indexPath) as! HomeAlertTableViewCell

            cell.alertTitleLabel.text = self.alertWithResultsArray[indexPath.row].name
            
            let alertFromDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].earliestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
            
            let fromDate = (Helper.getWeekDay(dateString: alertFromDate as NSDate, getValue: Constant.MyClassConstants.month)).appendingFormat(". ").appending(Helper.getWeekDay(dateString: alertFromDate as NSDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertFromDate as NSDate, getValue: Constant.MyClassConstants.year))
            
            let alertToDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].latestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
            
            let toDate = Helper.getWeekDay(dateString: alertToDate as NSDate, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: alertToDate as NSDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertToDate as NSDate, getValue: Constant.MyClassConstants.year))
            
            let dateRange = fromDate.appending(" - " + toDate)
            
            cell.alertDateLabel.text = dateRange
            return cell
        }else if(type == Constant.dashboardTableScreenReusableIdentifiers.upcoming){
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.sectionCell, for: indexPath) as! UpcomingTripSegmentCell
            
            let upcomingTrip  =  Constant.MyClassConstants.upcomingTripsArray[indexPath.row]
            let statename = upcomingTrip.resort?.address?.territoryCode
            print(statename as Any)
            cell.resortNameLabel.text = upcomingTrip.resort!.resortName
            cell.resortLocationLabel.text = "\(upcomingTrip.resort!.address!.cityName!), \(String(describing: upcomingTrip.resort?.address?.territoryCode)), \(upcomingTrip.resort!.address!.countryCode!)"
            let upcomingTripDate = Helper.convertStringToDate(dateString: upcomingTrip.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
            cell.dayDateLabel.text = Helper.getWeekDay(dateString: upcomingTripDate as NSDate, getValue: Constant.MyClassConstants.date)
            
            var dayNameYearText = "\(Helper.getWeekDay(dateString: upcomingTripDate as NSDate, getValue: Constant.MyClassConstants.weekDay))\n\(Helper.getWeekDay(dateString: upcomingTripDate as NSDate, getValue: Constant.MyClassConstants.month))"
            dayNameYearText = "\(dayNameYearText) \(Helper.getWeekDay(dateString: upcomingTripDate as NSDate, getValue: Constant.MyClassConstants.year))"
            cell.dayNameYearLabel.text = dayNameYearText
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }else if(type == Constant.dashboardTableScreenReusableIdentifiers.search){
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            let searchVacation = IUIKButton()
            searchVacation.frame = CGRect(x: 10, y: 10, width: self.view.frame.width - 20, height: 50)
            searchVacation.backgroundColor =  UIColor(red: 240/255.0, green: 111/255.0, blue: 54/255.0, alpha: 1.0)
            searchVacation.setTitle(Constant.buttonTitles.searchVacation, for: UIControlState.normal)
            searchVacation.addTarget(self, action:#selector(DashboardTableViewController.searchVactionPressed(_:)), for:UIControlEvents.touchUpInside)
            searchVacation.layer.cornerRadius = 4
            cell.addSubview(searchVacation)
            
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            //header for top ten deals
            if(type == "Exchange") {
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
            layout.minimumLineSpacing = 10.0
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 230 ), collectionViewLayout: layout)
            
            homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            homeTableCollectionView.backgroundColor = UIColor.clear
            homeTableCollectionView.delegate = self
            homeTableCollectionView.dataSource = self
            if(type == "Exchange") {
                homeTableCollectionView.tag = 1
            }
            else {
                homeTableCollectionView.tag = 2
            }
            
            homeTableCollectionView.isScrollEnabled = true
            cell.backgroundColor = UIColor(red: 240.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            cell.addSubview(homeTableCollectionView)
            
            return cell
        }
    }
    
    //***** Segment control selected item action *****//
    func segmentedControlAction(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            self.segmentSelectedIndex = sender.selectedSegmentIndex
            self.homeTableView.reloadData()
        }
        else {
            self.segmentSelectedIndex = sender.selectedSegmentIndex
            self.homeTableView.reloadData()
        }
    }
    //***** View all alerts button pressed *****//
    func viewAllAlertButtonPressed(_ sender:IUIKButton){
        Constant.MyClassConstants.alertOriginationPoint = Constant.CommonStringIdentifiers.alertOriginationPoint
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        reloadBadgeView()
        
        self.present(viewController, animated: true, completion: nil)
    }
    //***** View all trip button action *****//
    func viewAllTripButtonPressed(_ sender:IUIKButton) {
        
        Constant.MyClassConstants.upcomingOriginationPoint = Constant.omnitureCommonString.homeDashboard
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        
        self.present(viewController, animated: true, completion: nil)
        
    }
    //***** Search vacation button action *****//
    func  searchVactionPressed(_ sender:AnyObject) {
        
        Constant.MyClassConstants.searchOriginationPoint = Constant.omnitureCommonString.homeDashboard
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        self.present(viewController, animated: true, completion: nil)

    }
}

//***** MARK: Extension classes starts from here *****//

extension DashboardTableViewController:UICollectionViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
}

extension DashboardTableViewController:UICollectionViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return Constant.MyClassConstants.flexExchangeDeals.count
        } else {
            return (Constant.MyClassConstants.topDeals.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }

        
        if(collectionView.tag == 1) {
            //flexDeals
            let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 180) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            
            
            if let imgURL = flexDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                resortFlaxImageView.image = UIImage(named: "\(Constant.MyClassConstants.noImage)")
                resortFlaxImageView.contentMode = .center
            }
            
            cell.addSubview(resortFlaxImageView)
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 60))
            
            resortImageNameLabel.text = flexDeal.name
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 16)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
        }
        else {
            //TOP10GETAWAY
            let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
            let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 180) )
            resortFlaxImageView.backgroundColor = UIColor.lightGray
            let rentalDeal:RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
            
            if let imgURL = rentalDeal.images.first?.url {
                resortFlaxImageView.setImageWith(URL(string: imgURL ), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        resortFlaxImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                resortFlaxImageView.image = UIImage(named: "\(Constant.MyClassConstants.noImage)")
                resortFlaxImageView.contentMode = .center
            }
            
            cell.addSubview(resortFlaxImageView)
            
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 60))
            
            resortImageNameLabel.text = topTenDeals.header!
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.backgroundColor = UIColor.orange
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 16)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            
            
            let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
            centerView.center = resortFlaxImageView.center
            centerView.backgroundColor = Constant.RGBColorCode.centerViewRgb
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 15, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = topTenDeals.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 12)
            unitLabel.textColor = UIColor.white
            unitLabel.backgroundColor = UIColor.clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 35, width: centerView.frame.size.width - 20, height: 20))
            priceLabel.text = "From $" + String(describing: topTenDeals.price!.fromPrice) + " Wk."
            priceLabel.numberOfLines = 2
            priceLabel.textAlignment = NSTextAlignment.center
            priceLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
            priceLabel.textColor = UIColor.white
            priceLabel.backgroundColor = UIColor.clear
            centerView.addSubview(priceLabel)
            
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            
            
            cell.addSubview(centerView)
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 1){
            Constant.MyClassConstants.viewController = self
            self.flexchangeSelected(selectedIndexPath: indexPath)
        }else{
            self.topTenGetawaySelected(selectedIndexPath: indexPath)
            
        }
    }
}

extension UIViewController {
    func topTenGetawaySelected(selectedIndexPath: IndexPath) {
        let topTenDeals = Constant.MyClassConstants.topDeals[selectedIndexPath.row]
        Constant.MyClassConstants.vacationSearchResultHeaderLabel = topTenDeals.header!
        
        ADBMobile.trackAction(Constant.omnitureEvents.event1, data: nil)
        
        /*let areas = Area()
        areas.areaCode = Constant.MyClassConstants.topDeals[selectedIndexPath.row].areaCodes.first!
        Constant.MyClassConstants.vacationSearchShowDate = Constant.MyClassConstants.topDeals[selectedIndexPath.row].fromDate
        Constant.MyClassConstants.vacationSearchResultHeaderLabel = Constant.MyClassConstants.topDeals[selectedIndexPath.row].header!
        //Constant.MyClassConstants.whereTogoContentArray = [Constant.MyClassConstants.topDeals[selectedIndexPath.row].header!]
        let rentalSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
        
        rentalSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
        rentalSearchCriteria.searchType = VacationSearchType.Rental
        Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(Session.sharedSession.appSettings, rentalSearchCriteria)
        
        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.areas = [areas]*/
        
        
        // latest changes
        let deal = RentalDeal()
        deal.header = Constant.MyClassConstants.topDeals[selectedIndexPath.row].header!
        deal.fromDate = Constant.MyClassConstants.topDeals[selectedIndexPath.row].fromDate
        deal.areaCodes = [Constant.MyClassConstants.topDeals[selectedIndexPath.row].areaCodes.first!]
        
        let searchCriteria = Helper.createSearchCriteriaForRentalDeal(deal: deal)
        
        let settings = Helper.createSettings()
        Constant.MyClassConstants.initialVacationSearch = VacationSearch(settings, searchCriteria)
        
        if Reachability.isConnectedToNetwork() == true {
            
            ADBMobile.trackAction(Constant.omnitureEvents.event9, data: nil)
            showHudAsync()
            RentalClient.searchDates(Session.sharedSession.userAccessToken, request: Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request, onSuccess:{ (response) in
                
                ADBMobile.trackAction(Constant.omnitureEvents.event18, data: nil)
                // omniture tracking with event 9
                /*let userInfo: [String: Any] = [
                    Constant.omnitureCommonString.listItem: Constant.MyClassConstants.selectedDestinationNames,
                    Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch,
                    Constant.omnitureEvars.eVar19 : Constant.MyClassConstants.vacationSearchShowDate,
                    Constant.omnitureEvars.eVar23 : Constant.omnitureCommonString.primaryAlternateDateAvailable,
                    Constant.omnitureEvars.eVar26 : "",
                    Constant.omnitureEvars.eVar28: "" ,
                    Constant.omnitureEvars.eVar33: "" ,
                    Constant.omnitureEvars.eVar34: "" ,
                    Constant.omnitureEvars.eVar36:"\(Helper.omnitureSegmentSearchType(index:  Constant.MyClassConstants.searchForSegmentIndex))-\(Constant.MyClassConstants.resortsArray.count)" ,
                    Constant.omnitureEvars.eVar39: "" ,
                    Constant.omnitureEvars.eVar45: "\(Constant.MyClassConstants.vacationSearchShowDate)-\(Date())",
                    Constant.omnitureEvars.eVar47: "\(Constant.MyClassConstants.checkInDates.count)" ,
                    Constant.omnitureEvars.eVar53: "\(Constant.MyClassConstants.resortsArray.count)",
                    Constant.omnitureEvars.eVar61:Constant.MyClassConstants.searchOriginationPoint,
                    ]
                
                ADBMobile.trackAction(Constant.omnitureEvents.event9, data: userInfo)*/
                
                
                Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.response = response
                
                // Get activeInterval
                let activeInterval = Constant.MyClassConstants.initialVacationSearch.bookingWindow.getActiveInterval()
                
                // Update active interval
                Constant.MyClassConstants.initialVacationSearch.updateActiveInterval(activeInterval: activeInterval)
                
                // Always show a fresh copy of the Scrolling Calendar
                
                Helper.showScrollingCalendar(vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                
                Helper.hideProgressBar(senderView: self)
                
                // Check not available checkIn dates for the active interval
                if ((activeInterval?.fetchedBefore)! && !(activeInterval?.hasCheckInDates())!) {
                    Helper.showNotAvailabilityResults()
                    self.navigateToSearchResultsScreen()
                    
                } else {
                    
                    Constant.MyClassConstants.initialVacationSearch.resolveCheckInDateForInitialSearch()
                    let initialSearchCheckInDate = Helper.convertStringToDate(dateString:Constant.MyClassConstants.initialVacationSearch.searchCheckInDate!,format:Constant.MyClassConstants.dateFormat)
                    Constant.MyClassConstants.checkInDates = response.checkInDates
                    //sender.isEnabled = true
                    Helper.helperDelegate = self as? HelperDelegate
                    self.hideHudAsync()
                    Helper.executeRentalSearchAvailability(activeInterval: activeInterval, checkInDate: initialSearchCheckInDate, senderViewController: self, vacationSearch: Constant.MyClassConstants.initialVacationSearch)
                }
            })
            { (error) in
                self.hideHudAsync()
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            }
        } else {
            self.hideHudAsync()
            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: Constant.AlertErrorMessages.networkError)
        }
    }
    
    func flexchangeSelected(selectedIndexPath: IndexPath) {
        
       /* let areas = Area()
        areas.areaCode = Constant.MyClassConstants.topDeals[selectedIndexPath.row].areaCodes.first!
        //Constant.MyClassConstants.vacationSearchShowDate = Constant.MyClassConstants.flexExchangeDeals[selectedIndexPath.row].fromDate
        Constant.MyClassConstants.whereTogoContentArray = [Constant.MyClassConstants.flexExchangeDeals[selectedIndexPath.row].name!]
        let exchangeSearchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
        
        exchangeSearchCriteria.checkInDate = Constant.MyClassConstants.vacationSearchShowDate
        exchangeSearchCriteria.searchType = VacationSearchType.Exchange
        Constant.MyClassConstants.initialVacationSearch = VacationSearch.init(UserContext.sharedInstance.appSettings, exchangeSearchCriteria)
        
        Constant.MyClassConstants.initialVacationSearch.rentalSearch?.searchContext.request.areas = [areas]*/
        
        
        let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexchangeViewController) as! FlexchangeSearchViewController
        viewController.selectedFlexchange = Constant.MyClassConstants.flexExchangeDeals[selectedIndexPath.row]
        self.navigationController!.pushViewController(viewController, animated: true)
        
    }
    
    func navigateToSearchResultsScreen(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController)
            self.navigationController!.pushViewController(viewController, animated: true)
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            let storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController)
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        
        /*let storyboardName = Constant.MyClassConstants.isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            show(initialViewController, sender: self)
        }*/
        
    }
    
    // Function to get to date and from date for search dates API calling
    func getSearchDatesTop() -> (Date, Date){
        
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
}

extension DashboardTableViewController:HelperDelegate{
    func resortSearchComplete() {
        self.navigateToSearchResultsScreen()
    }
    func resetCalendar() {
        
    }
}
