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
    
    var menuTitle : String
    var imageName : String
    var segueName : String?
    var selectorName : String?
    var storyboardId : String?
    var initialControllerName : String?
    
    init(title:String, image:String, segue:String) {
        self.menuTitle = title
        self.imageName = image
        self.segueName = segue
        self.selectorName = nil
    }
    
    init(title:String, image:String, selector:String) {
        self.menuTitle = title
        self.imageName = image
        self.segueName = nil
        self.selectorName = selector
    }
    
    init(title:String, image:String, storyboardid:String ,initialcontrollername:String) {
        self.menuTitle = title
        self.imageName = image
        self.storyboardId = storyboardid
        self.initialControllerName = initialcontrollername
    }
    
}


//******************* SideMenuTableViewController**************//

class SideMenuTableViewController: UIViewController
{
    
    var myMutableString = NSMutableAttributedString()
    
    //***** Define a global list os side menu items *****//
    static let SideMenuItems : [SideMenuItem] = [
        
        SideMenuItem(title:"",image:"", storyboardid:"",initialcontrollername: ""),
        SideMenuItem(title:"",image:Constant.assetImageNames.member,storyboardid:Constant.storyboardNames.membershipIphone,initialcontrollername:Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title: Constant.sideMenuTitles.home,image:Constant.assetImageNames.home, storyboardid: Constant.storyboardNames.dashboardIPhone,initialcontrollername:Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title: Constant.sideMenuTitles.searchVacation,image:Constant.assetImageNames.searchVacation,storyboardid:Constant.storyboardNames.vacationSearchIphone,initialcontrollername:Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title:Constant.sideMenuTitles.upcomingTrips,image:Constant.assetImageNames.upcomingTrips, storyboardid: Constant.storyboardNames.myUpcomingTripIphone,initialcontrollername:Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title: Constant.sideMenuTitles.getawayAlerts,image:Constant.assetImageNames.getawayAlerts, storyboardid: Constant.storyboardNames.getawayAlertsIphone,initialcontrollername: Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title:Constant.sideMenuTitles.favorites,image: Constant.assetImageNames.favorites,storyboardid: Constant.storyboardNames.iphone,initialcontrollername: Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title: Constant.sideMenuTitles.ownershipUnits,image:Constant.assetImageNames.ownershipUnits,storyboardid:Constant.storyboardNames.ownershipIphone,initialcontrollername: Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title:Constant.sideMenuTitles.resortDirectory,image:Constant.assetImageNames.resortDirectory, storyboardid:Constant.storyboardNames.iphone,initialcontrollername: Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title:Constant.sideMenuTitles.intervalHD,image:Constant.assetImageNames.intervalHD,storyboardid: Constant.storyboardNames.intervalHDIphone,initialcontrollername: Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title:Constant.sideMenuTitles.magazines,image:Constant.assetImageNames.magazines,storyboardid: Constant.storyboardNames.magazinesIphone,initialcontrollername: Constant.sideMenuTitles.sideMenuInitialController),
        SideMenuItem(title:Constant.sideMenuTitles.signOut, image: "", selector: Constant.MyClassConstants.signOutSelected )
    ]
    
    
    var memberId:String!
    var productCode:String!
    
    @IBOutlet var sideMenuTable: UITableView?
    
    override func viewWillAppear(_ animated: Bool) {
        //***** Adding notification to reload table when all alerts have been fetched *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgeView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // omniture tracking with event 40
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.sideMenuAppeared
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: userInfo)

        
        let cellNib = UINib(nibName:Constant.customCellNibNames.memberCell, bundle: nil)
        self.sideMenuTable!.register(cellNib, forCellReuseIdentifier:Constant.customCellNibNames.memberCell)
        
        let cellNib1 = UINib(nibName:Constant.customCellNibNames.sideMenuBackgroundTableCell, bundle: nil)
        self.sideMenuTable!.register(cellNib1, forCellReuseIdentifier: Constant.customCellNibNames.sideMenuBackgroundTableCell)
        let membership = Session.sharedSession.selectedMembership
        self.memberId = membership?.memberNumber
    }
    
    //***** MARK: - Actions *****//
    
    func signOutSelected() {
        Session.sharedSession.signOut()
        //Remove all favorites for a user.
        Constant.MyClassConstants.favoritesResortArray.removeAll()
        Constant.MyClassConstants.favoritesResortCodeArray.removeAllObjects()
        
        //Remove available points for relinquishment program
        Constant.MyClassConstants.relinquishmentProgram = PointsProgram()
        
        //Remove all saved alerts for a user.
        Constant.MyClassConstants.getawayAlertsArray.removeAll()
        Constant.MyClassConstants.isLoginSuccessfull = false
        Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        TouchID().deactivateTouchID()
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.loginIPhone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.loginViewController) as! OldLoginViewController
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        viewController.view.layer.add(transition, forKey:Constant.MyClassConstants.switchToView)
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
    }
    
    //***** Function called for getaway alerts notification *****//
    
    func reloadBadgeView(){
        self.sideMenuTable?.reloadData()
    }
}


//******************* Extension class starts from here **************//


extension SideMenuTableViewController:UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        let smi = SideMenuTableViewController.SideMenuItems[ (indexPath as NSIndexPath).row ]
        
        if((indexPath as NSIndexPath).row == 6) {
            
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.favoritesFunctionalityCheck
        }else if((indexPath as NSIndexPath).row == 8){
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.resortFunctionalityCheck
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        }
        else if(indexPath.row == 5) {
            
            Constant.MyClassConstants.alertOriginationPoint = Constant.omnitureCommonString.sideMenu
        }
        else {
            
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        }
        
        if(smi.storyboardId?.characters.count != 0 && (indexPath as NSIndexPath).row != SideMenuTableViewController.SideMenuItems.count - 1) {
            
            Constant.MyClassConstants.upcomingOriginationPoint = Constant.omnitureCommonString.sideMenu
            /*if((indexPath as NSIndexPath).row == 4){
                let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
                let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController) as? UpComingTripDetailController
                let navController = UINavigationController(rootViewController: resultController!)
                self.present(navController, animated:true, completion: nil)
            }else{*/
                let mainStoryboard: UIStoryboard = UIStoryboard(name: smi.storyboardId!, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: smi.initialControllerName!) as! SWRevealViewController
                
                //***** Creating animation transition to show custom transition animation *****//
                let transition: CATransition = CATransition()
                let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.duration = 0.25
                transition.timingFunction = timeFunc
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
                UIApplication.shared.keyWindow?.rootViewController = viewController
            
            
            //}
        }
        else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** return height for  row in each section of tableview *****//
        
        if((indexPath as NSIndexPath).row == 0) {
            return 100
        }
        else if((indexPath as NSIndexPath).row == 1) {
            return 50
        }
        else if((indexPath as NSIndexPath).row == SideMenuTableViewController.SideMenuItems.count - 1) {
            
            return 180
        }
        else {
            
            return 50
        }
        
    }
}

extension SideMenuTableViewController:UITableViewDataSource {
    
    
    //***** MARK: - Table view data source *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** return number of sections for tableview *****//
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** return number of rows for each section in tableview *****//
        return SideMenuTableViewController.SideMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        //***** configuring  and returned cell for each row *****//
        if((indexPath as NSIndexPath).row == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.headerCell, for: indexPath) as! HeaderTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let imageview = UIImageView()
            let screenSize: CGRect = UIScreen.main.bounds
            let actualSizeRequired = CGFloat(screenSize.width) - 300
            imageview.frame = CGRect(x: actualSizeRequired/2 , y: 0, width: 250, height: 88)
            imageview.image = UIImage(named: Constant.MyClassConstants.logoMenuImage)
            imageview.contentMode = UIViewContentMode.scaleAspectFit
            cell.contentView.addSubview(imageview)
            return cell
        }else if((indexPath as NSIndexPath).row == SideMenuTableViewController.SideMenuItems.count - 1 ) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.menuCell, for: indexPath)
            
            let SignOutButton = IUIKButton(frame: CGRect(x: 15, y: 80, width: self.view.bounds.width - 90, height: 40))
            SignOutButton.setTitle(Constant.sideMenuTitles.signOut, for: UIControlState.normal)
            SignOutButton.layer.borderWidth = 0.5
            SignOutButton.layer.borderColor = UIColor.lightGray.cgColor
            SignOutButton.layer.masksToBounds = true
            SignOutButton.layer.cornerRadius = 4
            SignOutButton.setTitleColor(UIColor(red: 0/255.0, green: 119/255.0, blue: 190/255.0, alpha: 1.0), for: UIControlState.normal)
            SignOutButton.titleLabel?.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 15)
            SignOutButton.addTarget(self, action: #selector(SideMenuTableViewController.signOutSelected), for: .touchUpInside)
            cell.addSubview(SignOutButton)
            
            let privacyLegalLabel = UILabel()
            privacyLegalLabel.frame = CGRect(x: 15, y: 120, width: self.view.bounds.width - 65, height: 20)
            
            myMutableString = NSMutableAttributedString(string: Constant.MyClassConstants.sidemenuIntervalInternationalCorporationLabel, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)])
            
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/256.0, green: 0.0/256.0, blue: 0.0/256.0, alpha: 1.0), range: NSRange(location:0,length:28))
            
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/256.0, green: 119.0/256.0, blue: 190.0/256.0, alpha: 1.0), range: NSRange(location:29,length:13))
            
            //***** set label Attribute *****//
            privacyLegalLabel.attributedText = myMutableString
            //cell.addSubview(privacyLegalLabel)
            let bundleLabel = UILabel()
            bundleLabel.frame = CGRect(x: 15, y: 140, width: self.view.bounds.width - 65, height: 20)
            bundleLabel.text = Helper.getBuildVersion()
            bundleLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 12)
            //cell.addSubview(bundleLabel)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
            
        }else if((indexPath as NSIndexPath).row == 1) {
            
            let smi = SideMenuTableViewController.SideMenuItems[ (indexPath as NSIndexPath).row ]
            
            let cell:MemberCell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.memberCell, for: indexPath) as! MemberCell
            
            let membership =  Session.sharedSession.selectedMembership
            let Product = membership?.getProductWithHighestTier()
            if let productname = Product?.productName {
                cell.customTextLabel!.text = "\(Constant.MyClassConstants.member)\(memberId!) \(productname)"
            }
            cell.iconImageView!.image = UIImage(named: smi.imageName)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }else{
            let smi = SideMenuTableViewController.SideMenuItems[ (indexPath as NSIndexPath).row ]
            
            let cell:SideMenuBackgroundTableCell = tableView.dequeueReusableCell( withIdentifier: Constant.customCellNibNames.sideMenuBackgroundTableCell, for: indexPath) as! SideMenuBackgroundTableCell
            
            cell.iconImageView.image = UIImage(named:smi.imageName)
            cell.customTextLabel.text = smi.menuTitle
            
            if((indexPath as NSIndexPath).row == 5) {
                
                let alertCounterLabel = UILabel()
                var activeAlertsCount = 0
                if(Constant.MyClassConstants.getawayAlertsArray.count > 0){
                    for activeAlert in Constant.MyClassConstants.activeAlertsArray{
                        let getAwayAlert:RentalAlert = activeAlert as! RentalAlert
                        if (getAwayAlert.enabled)!{
                            activeAlertsCount = activeAlertsCount + 1
                        }
                    }
                    if(activeAlertsCount>0){
                        alertCounterLabel.text = String(activeAlertsCount)
                    }else{
                        alertCounterLabel.isHidden = true
                    }
                }else{
                    alertCounterLabel.isHidden = true
                }
                alertCounterLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 10)
                alertCounterLabel.sizeToFit()
                alertCounterLabel.textColor = UIColor.white
                alertCounterLabel.backgroundColor = IUIKColorPalette.alert.color
                alertCounterLabel.frame = CGRect(x:35 , y: cell.contentView.frame.height/2 - 18 , width: alertCounterLabel.frame.width + 10, height: alertCounterLabel.frame.width + 10)
                alertCounterLabel.layer.cornerRadius = alertCounterLabel.frame.width/2
                alertCounterLabel.layer.masksToBounds = true
                alertCounterLabel.textAlignment = NSTextAlignment.center
                cell.addSubview(alertCounterLabel)
            }
            
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}
