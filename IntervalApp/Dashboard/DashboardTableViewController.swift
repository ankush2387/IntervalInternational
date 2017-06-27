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
    var showExchange = false
    var dashboardArray = NSMutableArray()
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Adding notification to reload alert badge *****//
        //Helper.removeServiceCallBackgroundView(view: self.view)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgeView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopDestinations), name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUpcomingTrip), name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        self.getNumberOfSections()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //***** Removing notification to reload alert badge *****//
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event40
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.homeDashboard
        ]

        ADBMobile.trackState( Constant.omnitureEvents.event40, data: userInfo)
        
        self.getNumberOfSections()
        Helper.getTopDeals(senderVC: self)
        //***** Set general Nav attributes *****//
        self.title = Constant.ControllerTitles.dashboardTableViewController
        
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = self.revealViewController() {
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
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
        if(Constant.MyClassConstants.getawayAlertsArray.count > 0){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.alert)
        }
        if(Constant.MyClassConstants.upcomingTripsArray.count > 0){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.upcoming)
        }
        if(showExchange && showGetaways){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.search)
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.exchange)
            if((Constant.MyClassConstants.topDeals.count) > 0){
                self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.getaway)
            }
        }
        if(!showExchange && !showGetaways){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.search)
        }
        if(showExchange){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.search)
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.exchange)
        }
        if(showGetaways){
            self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.search)
            if((Constant.MyClassConstants.topDeals.count) > 0){
                self.dashboardArray.add(Constant.dashboardTableScreenReusableIdentifiers.getaway)
            }
        }
    }
    
    //***** Function called when notification for top 10 deals is fired. *****//
    func reloadTopDestinations(){
        self.getNumberOfSections()
        self.homeTableView.reloadData()
        Helper.removeServiceCallBackgroundView(view: self.view)
        SVProgressHUD.dismiss()
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
            return 280
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
            if(Constant.MyClassConstants.getawayAlertsArray.count > 0){
                return 1
            }else{
                return 0
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
            
            cell.alertTitleLabel.text = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name
            
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
            
            cell.resortNameLabel.text = upcomingTrip.resort!.resortName
            cell.resortLocationLabel.text = "\(upcomingTrip.resort!.address!.cityName!), \(upcomingTrip.resort!.address!.countryCode!)"
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
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            //header for top ten deals
            if(indexPath.section == 3) {
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
        
        //let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
        //let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        
        
        //let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as! UpComingTripDetailController
        //self.present(viewController, animated: true, completion: nil)
        
        //
        //        let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as? UpComingTripDetailController
        //        let navController = UINavigationController(rootViewController: resultController!) // Creating a navigation controller with resultController at the root of the navigation stack.
        //        self.present(navController, animated:true, completion: nil)
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
        return (Constant.MyClassConstants.topDeals.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
        let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 180) )
        resortFlaxImageView.backgroundColor = UIColor.lightGray
        let rentalDeal:RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
        
        
        resortFlaxImageView.setImageWith(URL(string: (rentalDeal.image?.url) ?? ""), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
            if (error != nil) {
                resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
            }
        }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        cell.addSubview(resortFlaxImageView)
        
        
        if(collectionView.tag == 1) {
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 50))
            
            resortImageNameLabel.text = topTenDeals.header!
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
        }
        else {
            
            
            
            let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.height - 50, width: cell.contentView.frame.width - 20, height: 50))
            
            resortImageNameLabel.text = topTenDeals.header!
            resortImageNameLabel.numberOfLines = 2
            resortImageNameLabel.textAlignment = NSTextAlignment.center
            resortImageNameLabel.textColor = UIColor.black
            resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 20)
            resortImageNameLabel.backgroundColor = UIColor.clear
            cell.addSubview(resortImageNameLabel)
            
            
            let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
            centerView.center = resortFlaxImageView.center
            centerView.backgroundColor = Constant.RGBColorCode.centerViewRgb
            
            let unitLabel = UILabel(frame: CGRect(x: 10, y: 10, width: centerView.frame.size.width - 20, height: 25))
            unitLabel.text = topTenDeals.details
            unitLabel.numberOfLines = 2
            unitLabel.textAlignment = NSTextAlignment.center
            unitLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 12)
            unitLabel.textColor = UIColor.white
            unitLabel.backgroundColor = UIColor.clear
            centerView.addSubview(unitLabel)
            
            let priceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: centerView.frame.size.width - 20, height: 20))
            priceLabel.text = "From " + String(describing: topTenDeals.price!.fromPrice) + " Wk."
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
}
