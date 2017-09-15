//
//  DashboardIPadTableViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/20/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import SVProgressHUD

class DashboardIPadTableViewController: UITableViewController {
    
    // class outlets
    @IBOutlet var homeTableView: UITableView!
    @IBOutlet var homeTableCollectionView:UICollectionView!
    
    // class variables
    var showGetaways = false
    var showExchange = true
    var childCounter = 0
    var adultCounter = 2
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Adding notification to reload table when all alerts have been fetched *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgeView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopDestinations), name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUpcomingTrip), name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //***** Remove added notifications. *****//
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         Helper.showProgressBar(senderView: self)
        Helper.getTopDeals(senderVC: self)
        
        Helper.getFlexExchangeDeals(senderVC: self) { (success) in
            if success {
                self.homeTableView.reloadData()
                Helper.hideProgressBar(senderView: self)
            } else {
                Helper.hideProgressBar(senderView: self)
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
    
    //***** Function called when notification for top 10 deals is fired. *****//
    func reloadTopDestinations(){
        Helper.removeServiceCallBackgroundView(view: self.view)
        self.showGetaways = true
        homeTableView.reloadData()
    }
    
    //***** Function to show upcoming trip to user *****//
    
    func reloadUpcomingTrip(){
        Helper.removeServiceCallBackgroundView(view: self.view)
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
        let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as? UpComingTripDetailIPadViewController
        let navController = UINavigationController(rootViewController: resultController!)
        self.present(navController, animated:true, completion: nil)
    }
    
    
    //***** Function called when notification for getaway alerts is fired. *****//
    func reloadBadgeView(){
        homeTableView.reloadData()
    }
    
    //***** function to call alert list screen when view all alert button pressed *****//
    func viewAllAlertButtonPressed(_ sender:IUIKButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        Constant.MyClassConstants.activeAlertsArray.removeAllObjects()
        reloadBadgeView()

        
        self.present(viewController, animated: true, completion: nil)
    }
    
    func searchVacationButtonPressed(_ sender:IUIKButton) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchVacation, sender: nil)
        
        //        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
        //        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as! UpComingTripDetailIPadViewController
        //        self.present(viewController, animated: true, completion: nil)
    }
    
    
    
    //***** function to call trip list screen when view all trip button pressed *****//
    func viewAllTripButtonPressed(_ sender:IUIKButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.homeTableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if(showGetaways == true && showExchange == true){
            return 4
        }else if(showGetaways == true && showExchange == false){
            return 3
        }else if(showGetaways == false && showExchange == true) {
            return 3
        }
        else {
            
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section) {
        case 0:
            
            if(Constant.MyClassConstants.getawayAlertsArray.count >= 3){
                return 3
            }else{
                return Constant.MyClassConstants.getawayAlertsArray.count
            }
        default:
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return 60
        case 1:
            return 210
        default:
            return 320
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0 || section == 1) {
            
            return 50
        }
        else {
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
        headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        let titleLabel = UILabel()
        titleLabel.text = Constant.MyClassConstants.headerArray[section]
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 20, y: headerView.frame.height/2 - titleLabel.frame.height/2, width: titleLabel.frame.width, height: titleLabel.frame.height)
        titleLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
        titleLabel.textColor = IUIKColorPalette.primaryText.color
        headerView.addSubview(titleLabel)
        
        
        if(section == 0) {
            
            
            let alertCounterLabel = UILabel()
            if(Constant.MyClassConstants.activeAlertsArray.count > 0){
                alertCounterLabel.text = String(Constant.MyClassConstants.activeAlertsArray.count)
            }else{
                alertCounterLabel.isHidden = true
            }
            alertCounterLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 20)
            alertCounterLabel.sizeToFit()
            alertCounterLabel.textColor = UIColor.white
            alertCounterLabel.backgroundColor = IUIKColorPalette.alert.color
            alertCounterLabel.frame = CGRect(x: titleLabel.frame.width + 20, y: titleLabel.frame.origin.y , width: alertCounterLabel.frame.width + 10, height: alertCounterLabel.frame.width + 10)
            alertCounterLabel.layer.cornerRadius = alertCounterLabel.frame.width/2
            alertCounterLabel.layer.masksToBounds = true
            alertCounterLabel.textAlignment = NSTextAlignment.center
            
            
            headerView.addSubview(alertCounterLabel)
            
            let viewAllAlertButton = IUIKButton()
            viewAllAlertButton.frame = CGRect(x: headerView.frame.width - 170, y: 10, width: 150, height: 30)
            viewAllAlertButton.setTitle(Constant.buttonTitles.viewAllAlerts, for: UIControlState.normal)
            viewAllAlertButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
            viewAllAlertButton.addTarget(self, action: #selector(DashboardIPadTableViewController.viewAllAlertButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            headerView.addSubview(viewAllAlertButton)
        }
        else if(section == 1) {
            
            let viewAllTripButton = IUIKButton()
            viewAllTripButton.frame = CGRect(x: headerView.frame.width - 170, y: 10, width: 150, height: 30)
            viewAllTripButton.setTitle(Constant.buttonTitles.viewAllTrips, for: UIControlState.normal)
            viewAllTripButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
            viewAllTripButton.addTarget(self, action: #selector(DashboardIPadTableViewController.viewAllTripButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            headerView.addSubview(viewAllTripButton)
        }
        else {
            
            
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.reuseIdentifier, for: indexPath) as! HomeAlertTableViewCell
            
            if(Constant.MyClassConstants.getawayAlertsArray.count > 0){
                cell.alertTitleLabel.text = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name
                
                let alertFromDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].earliestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
                
                let fromDate = (Helper.getWeekDay(dateString: alertFromDate as NSDate, getValue: Constant.MyClassConstants.month)).appendingFormat(". ").appending(Helper.getWeekDay(dateString: alertFromDate as NSDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertFromDate as NSDate, getValue: Constant.MyClassConstants.year))
                
                let alertToDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].latestCheckInDate!, format: Constant.MyClassConstants.dateFormat)
                
                let toDate = Helper.getWeekDay(dateString: alertToDate as NSDate, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: alertToDate as NSDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: alertToDate as NSDate, getValue: Constant.MyClassConstants.year))
                
                let dateRange = fromDate.appending(" - " + toDate)
                
                cell.alertDateLabel.text = dateRange
                
            }
            
            
            return cell
            
        case 1:
            
            let cell: UpComingTripsTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.upComingTripsCell, for: indexPath) as! UpComingTripsTableViewCell
            
            cell.searchVacationButton.addTarget(self, action: #selector(DashboardIPadTableViewController.searchVacationButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            cell.vacationSearchCollectionView.reloadData()
            
            cell.vacationSearchContainerView.frame = CGRect(x: 20, y: 20, width: 200, height: 200)
            
            cell.vacationSearchCollectionView.reloadData()
            cell.vacationSearchCollectionView.delegate = self
            cell.vacationSearchCollectionView.dataSource = self
            cell.vacationSearchContainerView.layer.cornerRadius = 7
            cell.vacationSearchContainerView.layer.borderWidth = 4
            cell.vacationSearchContainerView.layer.borderColor = UIColor.orange.cgColor
            
            return cell
            
            
        default:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            
            if(indexPath.section == 3) {
                if(!showExchange){
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    cell.addSubview(resortImageNameLabel)
                }else{
                    let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                    resortImageNameLabel.text = Constant.segmentControlItems.getawaysLabelText
                    resortImageNameLabel.textColor = UIColor.black
                    resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                    cell.addSubview(resortImageNameLabel)
                    
                }
            }
            else {
                
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 20, height: 20))
                resortImageNameLabel.text = Constant.segmentControlItems.flexchangeLabelText
                
                resortImageNameLabel.textColor = UIColor.black
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 15)
                cell.addSubview(resortImageNameLabel)
            }
            
            //***** Creating collectionview and  layout for collectionView to show getaways and flexchange images on it *****//
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width:280, height: 260 )
            layout.minimumLineSpacing = 20.0
            layout.scrollDirection = .horizontal
            homeTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width , height: 260 ), collectionViewLayout: layout)
            
            homeTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            homeTableCollectionView.backgroundColor = UIColor.clear
            homeTableCollectionView.delegate = self
            homeTableCollectionView.dataSource = self
            if(indexPath.section == 3) {
                homeTableCollectionView.tag = 3
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
    //***** Search vacation button action *****//
    func  searchVactionPressed(_ sender:AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.vacationSearchIPad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.sideMenuTitles.sideMenuInitialController) as! SWRevealViewController
        let navController = UINavigationController(rootViewController: viewController)
        self.navigationController!.present(navController, animated: true)
    }
}

extension DashboardIPadTableViewController:UICollectionViewDelegate {
    
}

extension DashboardIPadTableViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView.tag == 1) {
            
            return Constant.MyClassConstants.upcomingTripsArray.count
        }
        else if(collectionView.tag == 2) {
            return Constant.MyClassConstants.flexExchangeDeals.count
        }
        else {
            return Constant.MyClassConstants.topDeals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 1){
            Constant.MyClassConstants.transactionNumber = "\(Constant.MyClassConstants.upcomingTripsArray[indexPath.row].exchangeNumber!)"
            Helper.getTripDetails(senderViewController: self)
        }
        
        if collectionView.tag == 3 {
            self.topTenGetawaySelected(selectedIndexPath: indexPath)
        }
        
        // navigate to flex chane screen
        if collectionView.tag == 2 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.flexChangeSearchIpadViewController) as! FlexChangeSearchIpadViewController
            
            // set travel party info
            let travelPartyInfo = TravelParty()
            travelPartyInfo.adults = Int(self.adultCounter)
            travelPartyInfo.children = Int(self.childCounter)
            
            Constant.MyClassConstants.travelPartyInfo = travelPartyInfo
            
            viewController.selectedFlexchange = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView.tag == 1){
            //Top 10 Getaway
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.upcomingCell, for: indexPath) as! VacationCollectionViewCell
            
            let upcomingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.row]
            
            cell.resortTitleLabel.text = upcomingTrip.resort!.resortName
            cell.resortAddressLabel.text = "\(upcomingTrip.resort!.address!.cityName!), \(upcomingTrip.resort!.address!.countryCode!)"
            cell.resortCodeLabel.text = upcomingTrip.resort!.address!.countryCode!
            
            let checkInDate = Helper.convertStringToDate(dateString:upcomingTrip.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat1)
            
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
            
            
            let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.day!), \(myComponents.year!)"
            
            let checkOutDate = Helper.convertStringToDate(dateString: upcomingTrip.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat1)
            
            let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
            
            let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.day!), \(myComponents1.year!)"
            
            
            
            cell.resortAvailabilityLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)"
            
            let imageUrls = upcomingTrip.resort!.images
            if(imageUrls.count > 0){
            let imageUrl = (imageUrls[(imageUrls.count) - 1].url)! as String
            
            cell.iconImageView.setImageWith(URL(string: imageUrl), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                if (error != nil) {
                    cell.iconImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    cell.iconImageView.contentMode = .center
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }else{
                cell.iconImageView.image = UIImage(named:Constant.MyClassConstants.noImage)
            }
            
            if(cell.gradientView.layer.sublayers != nil) {
                for layer in cell.gradientView.layer.sublayers!{
                    if(layer.isKind(of: CAGradientLayer.self)) {
                        layer.removeFromSuperlayer()
                    }
                }
            }
            cell.gradientView.frame = CGRect(x: cell.gradientView.frame.origin.x, y: cell.gradientView.frame.origin.y, width: cell.contentView.frame.width, height: cell.gradientView.frame.height)
            Helper.addLinearGradientToView(view: cell.gradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            
            return cell
            
            
        }else {
            //Flexxhange Deals
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath)
            
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            if(collectionView.tag == 2) {
                
                let flexDeal = Constant.MyClassConstants.flexExchangeDeals[indexPath.row]
                let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height) )
                resortFlaxImageView.backgroundColor = UIColor.lightGray
                if let imageURL = flexDeal.images.first?.url {
                    resortFlaxImageView.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
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

                
                let resortImageNameLabel = UILabel(frame: CGRect(x: 10, y: cell.contentView.frame.midY - 25, width: cell.contentView.frame.width - 20, height: 50))
                
                resortImageNameLabel.text = flexDeal.name
                resortImageNameLabel.numberOfLines = 2
                resortImageNameLabel.textAlignment = NSTextAlignment.center
                resortImageNameLabel.textColor = UIColor.white
                resortImageNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium,size: 20)
                resortImageNameLabel.backgroundColor = UIColor.clear
                cell.addSubview(resortImageNameLabel)
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1.0
//                cell.layer.cornerRadius = 7
                cell.layer.masksToBounds = true
                
            }
            else {
                let topTenDeals = Constant.MyClassConstants.topDeals[indexPath.row]
                let resortFlaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 220) )
                resortFlaxImageView.backgroundColor = UIColor.lightGray
                let rentalDeal:RentalDeal = Constant.MyClassConstants.topDeals[indexPath.row]
                if let imageURL = rentalDeal.images.first?.url {
                    resortFlaxImageView.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                        if (error != nil) {
                            resortFlaxImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        }
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                }
                
                cell.addSubview(resortFlaxImageView)
                
                
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
                
                cell.backgroundColor = UIColor.white
                cell.addSubview(centerView)
                
                
            }
            return cell
        }
        
    }
}

//extension DashboardIPadTableViewController:UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if(collectionView.tag == 1) {
//            return UIEdgeInsetsMake(0, 0, 0, 0)
//        }
//        else {
//            return UIEdgeInsetsMake(0, 0, 0, 0)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        if(collectionView.tag == 1) {
//            return 20
//        }
//        else {
//            return 2
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if(collectionView.tag == 1) {
//            return CGSize(width: Constant.MyClassConstants.runningDeviceWidth!/2-50 , height: Constant.MyClassConstants.runningDeviceWidth!/3-60)
//        }
//        else {
//            return CGSize(width: UIScreen.main.bounds.width/2-20 , height: UIScreen.main.bounds.width/3)
//        }
//    }
//}

