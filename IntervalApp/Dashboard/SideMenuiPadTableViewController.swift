//
//  SideMenuiPadTableViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/20/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class SideMenuItemIPad {
    
    var menuTitle: String
    var image: UIImage
    var segueName: String?
    var selectorName: String?
    var storyboardId: String?
    
    init(title: String, image: UIImage, storyboardid: String) {
        self.menuTitle = title
        self.image = image
        self.storyboardId = storyboardid
    }
    
}

class SideMenuiPadTableViewController: UIViewController, UITableViewDataSource {
    
    var myMutableString = NSMutableAttributedString()
    
    //***** Define a global list os side menu items *****//
    static let SideMenuItems: [SideMenuItemIPad] = [
        
        SideMenuItemIPad(title: "", image: #imageLiteral(resourceName: "IntHD"), storyboardid: ""),
        SideMenuItemIPad(title: "", image: #imageLiteral(resourceName: "Member"), storyboardid: Constant.storyboardNames.membershipIPad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.home, image: #imageLiteral(resourceName: "Home"), storyboardid: Constant.storyboardNames.dashboardIPad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.searchVacation, image: #imageLiteral(resourceName: "Search"), storyboardid: Constant.storyboardNames.vacationSearchIPad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.upcomingTrips, image: #imageLiteral(resourceName: "Trips"), storyboardid: Constant.storyboardNames.myUpcomingTripIpad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.getawayAlerts, image: #imageLiteral(resourceName: "Alerts"), storyboardid: Constant.storyboardNames.getawayAlertsIpad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.favorites, image: #imageLiteral(resourceName: "Favorites"), storyboardid: Constant.storyboardNames.resortDirectoryIpad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.ownershipUnits, image: #imageLiteral(resourceName: "Ownership"), storyboardid: Constant.storyboardNames.ownershipIpad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.resortDirectory, image: #imageLiteral(resourceName: "Directory"), storyboardid: Constant.storyboardNames.resortDirectoryIpad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.intervalHD, image: #imageLiteral(resourceName: "IntHD"), storyboardid: Constant.storyboardNames.intervalHDIpad),
        SideMenuItemIPad(title: Constant.sideMenuTitles.magazines, image: #imageLiteral(resourceName: "Magazines"), storyboardid: Constant.storyboardNames.magazinesIpad),
        SideMenuItemIPad(title: "Settings".localized(),
                     image: #imageLiteral(resourceName: "Settings Icon"),
                     storyboardid: "SettingsiPad")
    ]
    
    var memberId = ""
    
    @IBOutlet fileprivate var sideMenuTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Constant.activeAlertCount = Constant.MyClassConstants.searchDateResponse.filter { $0.1.checkInDates.count > 0 }.count
        //***** Adding notification to reload alert badge *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgeView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: Constant.customCellNibNames.memberCell, bundle: nil)
        self.sideMenuTable.register(cellNib, forCellReuseIdentifier: Constant.customCellNibNames.memberCell)
        
        let cellNib1 = UINib(nibName: Constant.customCellNibNames.sideMenuBackgroundTableCell, bundle: nil)
        self.sideMenuTable.register(cellNib1, forCellReuseIdentifier: Constant.customCellNibNames.sideMenuBackgroundTableCell)
        let membership = Session.sharedSession.selectedMembership
        self.memberId = membership?.memberNumber ?? ""
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }

    //***** Function called when notification for getaway alerts is fired. *****//
    func reloadBadgeView() {
        sideMenuTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //***** return number of rows for each section in tableview *****//
        return SideMenuTableViewController.SideMenuItems.count
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //***** return height for  row in each section of tableview *****//
        var height = 0
        (indexPath.row == 0) ? (height = 100) :  (height = 70)
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring  and returned cell for each row *****//
        
        switch indexPath.row {
        case 0 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.headerCell, for: indexPath) as? SideMenuLogoCell else { return UITableViewCell() }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let imageview = UIImageView()
            let screenSize: CGRect = UIScreen.main.bounds
            let actualSizeRequired = CGFloat(screenSize.width / 2 - 50) - 250
            imageview.frame = CGRect(x: actualSizeRequired / 2, y: 0, width: 250, height: 88)
            imageview.image = UIImage(named: Constant.MyClassConstants.logoMenuImage)
            imageview.contentMode = UIViewContentMode.scaleAspectFit
            cell.contentView.addSubview(imageview)
            return cell
            
        case 1 :
            let smi = SideMenuTableViewController.SideMenuItems[indexPath.row ]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.memberCell, for: indexPath) as? MemberCell else { return UITableViewCell() }
            let membership = Session.sharedSession.selectedMembership
            let Product = membership?.getProductWithHighestTier()
            
            if let productName = Product?.productName {
                
                cell.customTextLabel.text = "Member #  \(memberId) \(productName)"
            }
            
            cell.iconImageView.image = smi.image
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        default :
                let smi = SideMenuTableViewController.SideMenuItems[indexPath.row]
                
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
extension SideMenuiPadTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 6 :
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.favoritesFunctionalityCheck
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.favoritesFunctionalityCheck
            
        case 8 :
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.resortFunctionalityCheck
            Constant.MyClassConstants.isFromSearchResult = false
        case 3 :
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
        default :
            Constant.MyClassConstants.runningFunctionality = ""
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        }
        let smi = SideMenuiPadTableViewController.SideMenuItems[indexPath.row]
        guard let storyboardName = smi.storyboardId else { return }
    
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
}
