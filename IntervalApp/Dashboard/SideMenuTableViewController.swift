//
//  SideMenuTableViewController.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

//***** SideMenuItem This class is a convenience for storing details about the side menu.  Note that the menu should have a segue or a selector. *****//

class SideMenuItem {
    
    var menuTitle: String
    var image: UIImage
    var storyboardId: String?
    
    init(title: String, image: UIImage, storyboardid: String) {
        self.menuTitle = title
        self.image = image
        self.storyboardId = storyboardid
    }
    
}

//******************* SideMenuTableViewController**************//

class SideMenuTableViewController: UIViewController {
    
    var myMutableString = NSMutableAttributedString()
    
    //***** Define a global list os side menu items *****//
    static let SideMenuItems: [SideMenuItem] = [
        
        SideMenuItem(title: "", image:  #imageLiteral(resourceName: "IntHD"), storyboardid: ""),
        SideMenuItem(title: "", image:  #imageLiteral(resourceName: "Member"), storyboardid: Constant.storyboardNames.membershipIphone),
        SideMenuItem(title: Constant.sideMenuTitles.home, image: #imageLiteral(resourceName: "Home"), storyboardid: Constant.storyboardNames.dashboardIPhone),
        SideMenuItem(title: Constant.sideMenuTitles.searchVacation, image: #imageLiteral(resourceName: "Search"), storyboardid: Constant.storyboardNames.vacationSearchIphone),
        SideMenuItem(title: Constant.sideMenuTitles.upcomingTrips, image: #imageLiteral(resourceName: "Trips"), storyboardid: Constant.storyboardNames.myUpcomingTripIphone),
        SideMenuItem(title: Constant.sideMenuTitles.getawayAlerts, image: #imageLiteral(resourceName: "Alerts"), storyboardid: Constant.storyboardNames.getawayAlertsIphone),
        SideMenuItem(title: Constant.sideMenuTitles.favorites, image: #imageLiteral(resourceName: "Favorites"), storyboardid: Constant.storyboardNames.iphone),
        SideMenuItem(title: Constant.sideMenuTitles.ownershipUnits, image: #imageLiteral(resourceName: "Ownership"), storyboardid: Constant.storyboardNames.ownershipIphone),
        SideMenuItem(title: Constant.sideMenuTitles.resortDirectory, image: #imageLiteral(resourceName: "Directory"), storyboardid: Constant.storyboardNames.iphone),
        SideMenuItem(title: Constant.sideMenuTitles.intervalHD, image: #imageLiteral(resourceName: "IntHD"), storyboardid: Constant.storyboardNames.intervalHDIphone),
        SideMenuItem(title: Constant.sideMenuTitles.magazines, image: #imageLiteral(resourceName: "Magazines"), storyboardid: Constant.storyboardNames.magazinesIphone),
        
        // This is not a good design...
        // And the cell row calculations are hard coded
        // Forces storyboard
        SideMenuItem(title: "Settings".localized(),
                     image: #imageLiteral(resourceName: "Settings Icon"),
                     storyboardid: "Settings")
    ]
    
    var memberId = ""
    var productCode: String!
    
    @IBOutlet var sideMenuTable: UITableView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Constant.activeAlertCount = Constant.MyClassConstants.searchDateResponse.filter { $0.1.checkInDates.count > 0 }.count
        //***** Adding notification to reload table when all alerts have been fetched *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgeView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        sideMenuTable?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.sideMenuAppeared
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: userInfo)
        
        let cellNib = UINib(nibName: Constant.customCellNibNames.memberCell, bundle: nil)
        self.sideMenuTable!.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.memberCell)
        
        let cellNib1 = UINib(nibName: Constant.customCellNibNames.sideMenuBackgroundTableCell, bundle: nil)
        self.sideMenuTable!.register(cellNib1, forCellReuseIdentifier: Constant.customCellNibNames.sideMenuBackgroundTableCell)
        let membership = Session.sharedSession.selectedMembership
        self.memberId = membership?.memberNumber ?? ""
    }
    
    //***** Function called for getaway alerts notification *****//
    
    func reloadBadgeView() {
        sideMenuTable?.reloadData()
    }
}

//******************* Extension class starts from here **************//

extension SideMenuTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        let smi = SideMenuTableViewController.SideMenuItems[indexPath.row ]
        switch indexPath.row {
        case 4:
            Constant.MyClassConstants.upcomingOriginationPoint = "sideMenu"
        case 6 :
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.favoritesFunctionalityCheck
        case 8 :
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.resortFunctionalityCheck
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        case 5 :
            Constant.MyClassConstants.alertOriginationPoint = Constant.omnitureCommonString.sideMenu
        default :
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        }
        
       
        
        guard let storyboardName = smi.storyboardId, !storyboardName.isEmpty else { return }
        
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** return height for  row in each section of tableview *****//
        var height = 0
        (indexPath.row == 0) ? (height = 100) : (height = 50)
        return CGFloat(height)
    }
    
    
}

extension SideMenuTableViewController: UITableViewDataSource {
    
    //***** MARK: - Table view data source *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** return number of sections for tableview *****//
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** return number of rows for each section in tableview *****//
        return SideMenuTableViewController.SideMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring  and returned cell for each row *****//
        switch indexPath.row {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.headerCell, for: indexPath) as! HeaderTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let imageview = UIImageView()
            let screenSize: CGRect = UIScreen.main.bounds
            let actualSizeRequired = CGFloat(screenSize.width) - 300
            imageview.frame = CGRect(x: actualSizeRequired / 2, y: 0, width: 250, height: 88)
            imageview.image = UIImage(named: Constant.MyClassConstants.logoMenuImage)
            imageview.contentMode = UIViewContentMode.scaleAspectFit
            cell.contentView.addSubview(imageview)
            return cell
        case 1 :
            
            let smi = SideMenuTableViewController.SideMenuItems[ (indexPath as NSIndexPath).row ]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.memberCell, for: indexPath) as? MemberCell else { return UITableViewCell() }
            
            let membership = Session.sharedSession.selectedMembership
            let Product = membership?.getProductWithHighestTier()
            if let productname = Product?.productName {
                cell.customTextLabel.text = "\(Constant.MyClassConstants.member)\(memberId) \(productname)"
            }
            cell.iconImageView.image = smi.image
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        default :
            let smi = SideMenuTableViewController.SideMenuItems[indexPath.row ]
            
            guard let cell = tableView.dequeueReusableCell( withIdentifier: Constant.customCellNibNames.sideMenuBackgroundTableCell, for: indexPath) as? SideMenuBackgroundTableCell else { return UITableViewCell() }
            
            cell.iconImageView.image = smi.image
            cell.customTextLabel.text = smi.menuTitle
            
            if indexPath.row == 5 {
                
                let alertCounterLabel = UILabel()
                
                if Constant.activeAlertCount > 0 {
                    alertCounterLabel.text = "\(Constant.activeAlertCount)"
                    alertCounterLabel.isHidden = false
                } else {
                    alertCounterLabel.isHidden = true
                }
                alertCounterLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 10)
                alertCounterLabel.sizeToFit()
                alertCounterLabel.textColor = UIColor.white
                alertCounterLabel.backgroundColor = IUIKColorPalette.alert.color
                alertCounterLabel.frame = CGRect(x: 35, y: cell.contentView.frame.height / 2 - 18, width: alertCounterLabel.frame.width + 10, height: alertCounterLabel.frame.width + 10)
                alertCounterLabel.layer.cornerRadius = alertCounterLabel.frame.width / 2
                alertCounterLabel.layer.masksToBounds = true
                alertCounterLabel.textAlignment = NSTextAlignment.center
                cell.addSubview(alertCounterLabel)
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}

