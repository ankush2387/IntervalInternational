//
//  WhatToUseViewController.swift
//  IntervalApp
//
//  Created by Chetu on 12/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//


import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import SVProgressHUD

protocol WhoWillBeCheckInDelegate {
    func navigateToWhoWillBeCheckIn(renewalArray:[Renewal])
    
}

class WhatToUseViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Delegate
    var delegate: WhoWillBeCheckInDelegate?
    
    // Class variables
    var isCheckedBox = false
    var showUpgrade = false
    var selectedUnitIndex = 0
    var selectedRow = -1
    var selectedRowSection = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Get dynamic rows
        tableView.reloadData()
        self.getNumberOfRows()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.bookYourSelectionController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(AccomodationCertsDetailController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
       // self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkBoxPressed(_ sender: IUIKCheckbox) {
        Constant.MyClassConstants.searchBothExchange = true
        
        self.selectedRow = sender.tag
        self.selectedRowSection = sender.accessibilityElements?.first as! Int
        
        
        let indexPath = NSIndexPath(row: self.selectedRow, section: self.selectedRowSection)
        tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
        //Start process request
        
        //Exchange process request parameters
        Helper.showProgressBar(senderView: self)
        let processResort = ExchangeProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        
        let processRequest = ExchangeProcessStartRequest()
        
        processRequest.destination = Constant.MyClassConstants.exchangeDestination
        processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        if(Constant.MyClassConstants.filterRelinquishments[self.selectedRow].openWeek != nil){
            
            processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].openWeek?.relinquishmentId
        }else if(Constant.MyClassConstants.filterRelinquishments[self.selectedRow].deposit != nil){
            
            processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].deposit?.relinquishmentId
        }else if(Constant.MyClassConstants.filterRelinquishments[self.selectedRow].pointsProgram != nil){
            
            processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].pointsProgram?.relinquishmentId
        }
            
        ExchangeProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: {(response) in
            
            // store response
            Constant.MyClassConstants.exchangeProcessStartResponse = response
        
        self.selectedRow = -1
        self.selectedRowSection = -1
        let processResort = ExchangeProcess()
        processResort.processId = response.processId
        Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
        Constant.MyClassConstants.exchangeProcessStartResponse = response
        Constant.MyClassConstants.exchangeViewResponse = response.view!
        Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
        Constant.MyClassConstants.onsiteArray.removeAllObjects()
        Constant.MyClassConstants.nearbyArray.removeAllObjects()
        
        for amenity in (response.view?.destination?.resort?.amenities)!{
            if(amenity.nearby == false){
                Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
            }else{
                Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
            }
        }
                UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                    
                    // Got an access token!  Save it for later use.
                    Helper.hideProgressBar(senderView: self)
                    Constant.MyClassConstants.membershipContactArray = Membership.contacts!
    
                    // check force renewals here
                    let forceRenewals = Constant.MyClassConstants.processStartResponse.view?.forceRenewals
                    
                    if (forceRenewals != nil) {
                        
                        if(Constant.RunningDevice.deviceIdiom == .phone){
                            
                            //self.dismiss(animated: true, completion: nil)
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                            let transitionManager = TransitionManager()
                            self.navigationController?.transitioningDelegate = transitionManager
                            
                            // Navigate to Renewals Screen
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
                            viewController.delegate = self
                            Constant.MyClassConstants.isFromWhatToUse = true
                            self.present(viewController, animated:true, completion: nil)
                            
                            return
                        }else{
                            
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                            let transitionManager = TransitionManager()
                            self.navigationController?.transitioningDelegate = transitionManager
                            
                            // Navigate to Who Will Be Checking in Screen
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
                            viewController.delegate = self
                            Constant.MyClassConstants.isFromWhatToUse = true
                            self.present(viewController, animated:true, completion: nil)
                            
                            return
                        }
                        
                    }
  
                    var viewController = UIViewController()
                    if Constant.RunningDevice.deviceIdiom == .phone {
                        viewController = WhoWillBeCheckingInViewController()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                        
                        
                    } else {
                        viewController = WhoWillBeCheckingInIPadViewController()
                        
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as! WhoWillBeCheckingInIPadViewController
                    }
                    
                    self.isCheckedBox = false
                    let transitionManager = TransitionManager()
                    self.navigationController?.transitioningDelegate = transitionManager
                    self.navigationController!.pushViewController(viewController, animated: true)
                    
                    if self.showUpgrade == true {
                        if let cell = (sender as AnyObject).superview??.superview?.superview as? RelinquishmentSelectionOpenWeeksCellWithUpgrade {
                            let indexPath = self.tableView.indexPath(for: cell)
                            let objFilterRelinquishment = Constant.MyClassConstants.filterRelinquishments[(indexPath?.row)!]
                            if Constant.RunningDevice.deviceIdiom == .phone {
                                (viewController as! WhoWillBeCheckingInViewController).filterRelinquishments = objFilterRelinquishment
                            } else {
                                (viewController as! WhoWillBeCheckingInIPadViewController).filterRelinquishments = objFilterRelinquishment
                            }
                        }
                        
                    } else {
                        if let cell = (sender as AnyObject).superview??.superview?.superview as? RelinquishmentSelectionOpenWeeksCell {
                            let indexPath = self.tableView.indexPath(for: cell)
                            let objFilterRelinquishment = Constant.MyClassConstants.filterRelinquishments[(indexPath?.row)!]
                            if Constant.RunningDevice.deviceIdiom == .phone {
                                (viewController as! WhoWillBeCheckingInViewController).filterRelinquishments = objFilterRelinquishment
                            } else {
                                (viewController as! WhoWillBeCheckingInIPadViewController).filterRelinquishments = objFilterRelinquishment
                            }
                        }
                    }
                }, onError: { (error) in
                    
                    Helper.hideProgressBar(senderView: self)
                    self.selectedRow = -1
                    self.selectedRowSection = -1
                    self.tableView.reloadData()
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                    
                })
                
            }, onError: {(error) in
                Helper.hideProgressBar(senderView: self)
                self.selectedRow = -1
                self.selectedRowSection = -1
                self.tableView.reloadData()
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            })
        
        
    }
    
    
    @IBAction func checkBoxGetawayPressed(_ sender: IUIKCheckbox) {
        
        Constant.MyClassConstants.searchBothExchange = false
        self.selectedRow = sender.tag
        self.selectedRowSection = sender.accessibilityElements?.first as! Int
       
       
        let indexPath = NSIndexPath(row: self.selectedRow, section: self.selectedRowSection)
        tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
        
        Helper.showProgressBar(senderView: self)
        var inventoryDict = Inventory()
        inventoryDict = Constant.MyClassConstants.selectedResort.inventory!
        let invent = inventoryDict
        let units = invent.units
        
        Constant.MyClassConstants.inventoryPrice = invent.units[indexPath.item].prices
        
        let processResort = RentalProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        let processRequest = RentalProcessStartRequest()
        processRequest.resort = Constant.MyClassConstants.selectedResort
        if(Constant.MyClassConstants.selectedResort.allInclusive){
            Constant.MyClassConstants.hasAdditionalCharges = true
        }else{
            Constant.MyClassConstants.hasAdditionalCharges = false
        }
        processRequest.unit = units[indexPath.item]
        
        let processRequest1 = RentalProcessStartRequest.init(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate!, unitSize: UnitSize(rawValue: units[indexPath.item].unitSize!)!, kitchenType: KitchenType(rawValue: units[indexPath.item].kitchenType!)!)
        RentalProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
            
            self.selectedRow = -1
            self.selectedRowSection = -1
            Helper.hideProgressBar(senderView: self)
            let processResort = RentalProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
            
            // store response
            Constant.MyClassConstants.processStartResponse = response
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            Constant.MyClassConstants.viewResponse = response.view!
            Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            
            for amenity in (response.view?.resort?.amenities)!{
                if(amenity.nearby == false){
                    Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                }else{
                    Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                }
            }
            
            
            UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                
                // Got an access token!  Save it for later use.
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                Constant.MyClassConstants.membershipContactArray = Membership.contacts!

                // check force renewals here
                let forceRenewals = Constant.MyClassConstants.processStartResponse.view?.forceRenewals
                
                if (forceRenewals != nil) {
                    
                    if(Constant.RunningDevice.deviceIdiom == .phone){
                        
                        //self.dismiss(animated: true, completion: nil)
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        let transitionManager = TransitionManager()
                        self.navigationController?.transitioningDelegate = transitionManager
                        
                        // Navigate to Renewals Screen
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
                        viewController.delegate = self
                        Constant.MyClassConstants.isFromWhatToUse = true
                        self.present(viewController, animated:true, completion: nil)
                        
                        return
                    }else{
                        
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        let transitionManager = TransitionManager()
                        self.navigationController?.transitioningDelegate = transitionManager
                        
                        // Navigate to Who Will Be Checking in Screen
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
                        viewController.delegate = self
                        Constant.MyClassConstants.isFromWhatToUse = true
                        self.present(viewController, animated:true, completion: nil)
                        
                        return
                    }
                    
                   // return  self.performSegue(withIdentifier: Constant.segueIdentifiers.showRenewelSegue, sender: nil)
                    
                    
                } else {
                    if(Constant.RunningDevice.deviceIdiom == .phone){
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                        
                        let transitionManager = TransitionManager()
                        self.navigationController?.transitioningDelegate = transitionManager
                        self.navigationController!.pushViewController(viewController, animated: true)
                    }else{
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as! WhoWillBeCheckingInIPadViewController
                        
                        let transitionManager = TransitionManager()
                        self.navigationController?.transitioningDelegate = transitionManager
                        self.navigationController!.pushViewController(viewController, animated: true)
                    }
                    
                }
                
            }, onError: { (error) in
                
                Helper.hideProgressBar(senderView: self)
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                self.selectedRow = -1
                self.selectedRowSection = -1
                self.tableView.reloadData()
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
                
            })
            
        }, onError: {(error) in
            
            self.selectedRow = -1
            self.selectedRowSection = -1
            self.tableView.reloadData()
            Helper.hideProgressBar(senderView: self)
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.description)
        })

        
    }
  
    
    func pushLikeModalViewController(controller : UIViewController)  {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    
    @IBAction func onClickDetailsButton(_ sender: Any) {
        // set isFrom Search false
        Constant.MyClassConstants.isFromSearchResult = false
        
        Helper.getResortWithResortCode(code:Constant.MyClassConstants.selectedResort.resortCode! , viewcontroller:self)
        //self.performSegue(withIdentifier: Constant.segueIdentifiers.showResortDetailsSegue, sender: nil)
    }
    
    // Function to get dynamic number of rows according to API response
    
    func getNumberOfRows(){
        
    }
}

//***** MARK: Extension classes starts from here *****//

extension WhatToUseViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 1) {
            
                let checkBox = IUIKCheckbox()
                checkBox.tag = indexPath.row
                checkBox.accessibilityElements = [indexPath.section]
                self.checkBoxPressed(checkBox)
        }
        else if (indexPath.section == 2){
            
            let checkBox = IUIKCheckbox()
            checkBox.tag = indexPath.row
            checkBox.accessibilityElements = [indexPath.section]
            self.checkBoxGetawayPressed(checkBox)
           
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** Return height according to section cell requirement *****//
        switch((indexPath as NSIndexPath).section) {
        case 0 :
            return 70
        case 1:
            //if((indexPath as NSIndexPath).row == 0) {
            if showUpgrade == true {
                return 150
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 80
                } else {
                    return 80
                }
            }
            
        case 2:
            return 70
        default :
            return 70
        }
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width - 30, height: 30))
        
        if(section == 0) {
            
            headerView.backgroundColor = UIColor.yellow
            headerTextLabel.text = ""
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
            
        }
        else if(section == 1) {
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerTextLabel.text = Constant.HeaderViewConstantStrings.exchange
            headerTextLabel.textColor = UIColor.black
            headerView.addSubview(headerTextLabel)
            
            
            let bottomLabel = UILabel(frame: CGRect(x: 15, y: 30, width: self.view.bounds.width - 30, height: 30))
            bottomLabel.textColor = UIColor.gray
            bottomLabel.text = "\(Constant.MyClassConstants.filterRelinquishments.count) of the \(Constant.MyClassConstants.whatToTradeArray.count) relquishments are avialable for exchange"
            return headerView
        }
        else {
            
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerTextLabel.text = Constant.HeaderViewConstantStrings.getaways
            headerTextLabel.textColor = UIColor.black
            headerView.addSubview(headerTextLabel)
            return headerView
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(section != 0){
            if(section == 1 && Constant.MyClassConstants.filterRelinquishments.count == 0){
                return 0
            }else if (section == 2 && Constant.MyClassConstants.selectedResort.resortCode == ""){
                return 0
            }
            return 30
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let shadowView = UIView()
        
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        shadowView.layer.shadowOffset = CGSize(width: -1, height: 1)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowRadius = 0.0
        shadowView.layer.masksToBounds = false
        
        return shadowView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
}

extension WhatToUseViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.Combined){
             return 3
        }else{
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            
        case 0:
            return 1
        case 1:
            return Constant.MyClassConstants.filterRelinquishments.count
        case 2:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if((indexPath as NSIndexPath).section == 0 ) {
            
        //***** Configure and return cell according to sections in tableview *****//
            
        let cell: DestinationResortDetailCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.destinationResortDetailCell, for: indexPath) as! DestinationResortDetailCell
            
            cell.destinationImageView.image = UIImage(named: Constant.assetImageNames.resortImage)
            
            if let resortName = Constant.MyClassConstants.selectedResort.resortName {
                
                cell.resortName.text = resortName
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
            
        else if((indexPath as NSIndexPath).section == 1) {
            
            let exchange = Constant.MyClassConstants.filterRelinquishments[indexPath.row]
            
            if((exchange.pointsProgram) != nil){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! AvailablePointCell
                
                cell.tag = indexPath.row
                cell.checkBOx.tag = indexPath.row
                cell.checkBOx.accessibilityElements = [indexPath.section]
           
                let points:Int = (exchange.pointsProgram?.availablePoints)!
                
                cell.availablePointValueLabel.text = String(points)
                
                if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBOx.checked = true
                }
                else {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBOx.checked = false
                }

                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
                
            }else if((exchange.clubPoints) != nil){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! AvailablePointCell
                
                cell.tag = indexPath.row
                cell.checkBOx.tag = indexPath.row
                let points:Int = (exchange.clubPoints?.pointsSpent)!
                
                cell.availablePointValueLabel.text = String(points)
                
                cell.checkBOx.accessibilityElements = [indexPath.section]
                
                if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBOx.checked = true
                }
                else {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBOx.checked = false
                }
                cell.layer.cornerRadius = 7
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
                
            }else if((exchange.openWeek) != nil){
               
                if showUpgrade == true {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell2, for: indexPath) as! RelinquishmentSelectionOpenWeeksCellWithUpgrade
                    cell.tag = indexPath.row
                    cell.checkBox.tag = indexPath.row
                    cell.checkBox.accessibilityElements = [indexPath.section]
                    if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = UIColor.orange.cgColor
                        cell.checkBox.checked = true
                    }
                    else {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                        cell.checkBox.checked = false
                    }
                    
                    cell.resortName.text = exchange.openWeek?.resort?.resortName!
                    cell.yearLabel.text = "\(String(describing: (exchange.openWeek?.relinquishmentYear!)!))"
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: (exchange.openWeek?.weekNumber!)!))"
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:(exchange.openWeek?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType:(exchange.openWeek?.unit!.kitchenType!)!))"
                    cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: exchange.openWeek!.unit!.publicSleepCapacity)), \(String(describing: exchange.openWeek!.unit!.privateSleepCapacity)) Private"
                    let dateString = exchange.openWeek!.checkInDate
                    let date =  Helper.convertStringToDate(dateString: dateString!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: date)
                    let day = myComponents.day!
                    var month = ""
                    if(day < 10) {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                    }
                    else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                    }
                    
                    cell.dayAndDateLabel.text = month.uppercased()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    
                    cell.tag = indexPath.row
                    cell.checkBox.tag = indexPath.row
                    cell.checkBox.accessibilityElements = [indexPath.section]
                    if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = UIColor.orange.cgColor
                        cell.checkBox.checked = true
                    }
                    else {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                        cell.checkBox.checked = false
                    }

                    cell.resortName.text = exchange.openWeek?.resort?.resortName!
                    cell.yearLabel.text = "\(String(describing: (exchange.openWeek?.relinquishmentYear!)!))"
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: (exchange.openWeek?.weekNumber!)!))"
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:(exchange.openWeek?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType:(exchange.openWeek?.unit!.kitchenType!)!))"
                    cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: exchange.openWeek!.unit!.publicSleepCapacity)), \(String(describing: exchange.openWeek!.unit!.privateSleepCapacity)) Private"
                    let dateString = exchange.openWeek!.checkInDate
                    let date =  Helper.convertStringToDate(dateString: dateString!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: date)
                    let day = myComponents.day!
                    var month = ""
                    if(day < 10) {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                    }
                    else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                    }
                    
                   //display Promotion
                    if let promotion = exchange.openWeek?.promotion {
                        cell.promLabel.text = promotion.offerName
                    } else {
                        cell.promLabel.isHidden = true
                        cell.promImgView.isHidden = true
                    }

                    cell.dayAndDateLabel.text = month.uppercased()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
            }else if(exchange.deposit != nil){
                
                if showUpgrade == true {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell2, for: indexPath) as! RelinquishmentSelectionOpenWeeksCellWithUpgrade
                    cell.tag = indexPath.row
                    cell.checkBox.tag = indexPath.row
                    cell.checkBox.accessibilityElements = [indexPath.section]
                    if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = UIColor.orange.cgColor
                        cell.checkBox.checked = true
                    }
                    else {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                        cell.checkBox.checked = false
                    }
                    
                    cell.resortName.text = exchange.deposit?.resort?.resortName!
                    cell.yearLabel.text = "\(String(describing: (exchange.deposit?.relinquishmentYear!)!))"
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: (exchange.deposit?.weekNumber!)!))"
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:(exchange.deposit?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType:(exchange.deposit?.unit!.kitchenType!)!))"
                    cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: exchange.deposit!.unit!.publicSleepCapacity)), \(String(describing: exchange.deposit!.unit!.privateSleepCapacity)) Private"
                    let dateString = exchange.deposit!.checkInDate
                    let date =  Helper.convertStringToDate(dateString: dateString!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: date)
                    let day = myComponents.day!
                    var month = ""
                    if(day < 10) {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                    }
                    else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                    }
                    
                    cell.dayAndDateLabel.text = month.uppercased()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    
                    cell.tag = indexPath.row
                    cell.checkBox.tag = indexPath.row
                    cell.checkBox.accessibilityElements = [indexPath.section]
                    if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = UIColor.orange.cgColor
                        cell.checkBox.checked = true
                    }
                    else {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                        cell.checkBox.checked = false
                    }
                    
                    cell.resortName.text = exchange.deposit?.resort?.resortName!
                    cell.yearLabel.text = "\(String(describing: (exchange.deposit?.relinquishmentYear!)!))"
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: (exchange.deposit?.weekNumber!)!))"
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:(exchange.deposit?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType:(exchange.deposit?.unit!.kitchenType!)!))"
                    cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: exchange.deposit!.unit!.publicSleepCapacity)), \(String(describing: exchange.deposit!.unit!.privateSleepCapacity)) Private"
                    let dateString = exchange.deposit!.checkInDate
                    let date =  Helper.convertStringToDate(dateString: dateString!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: date)
                    let day = myComponents.day!
                    var month = ""
                    if(day < 10) {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                    }
                    else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                    }
                    
                    //display Promotion
                    /*if let promotion = exchange.deposit?.promotion {
                        cell.promLabel.text = promotion.offerName
                    } else {
                        cell.promLabel.isHidden = true
                        cell.promImgView.isHidden = true
                    }*/
                    
                    cell.dayAndDateLabel.text = month.uppercased()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! AvailablePointCell
                
                cell.tag = indexPath.row
                cell.checkBOx.tag = indexPath.row
                cell.checkBOx.accessibilityElements = [indexPath.section]
                
                
                cell.availablePointValueLabel.text = ""
                
                if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBOx.checked = true
                }
                else {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBOx.checked = false
                }

                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        }
        else {
            
            //***** Configure and return search vacation cell *****//
            let cell:GetawayCell = tableView.dequeueReusableCell(withIdentifier: "GetawaysCell", for: indexPath) as! GetawayCell
            cell.tag = indexPath.row
            cell.checkbox.tag = indexPath.row
            cell.checkbox.accessibilityElements = [indexPath.section]
            if(self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section) {
                
                cell.mainView.layer.cornerRadius = 7
                cell.mainView.layer.borderWidth = 2
                cell.mainView.layer.borderColor = UIColor.orange.cgColor
                cell.checkbox.checked = true
            }
                
            else {
                
                cell.mainView.layer.cornerRadius = 7
                cell.mainView.layer.borderWidth = 2
                cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                cell.checkbox.checked = false
            }
          
            cell.bedRoomType.text = Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].unitSize
            
            if let roomSize = UnitSize(rawValue: (Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].unitSize)!) {
                
                cell.bedRoomType.text = Helper.getBrEnums(brType: roomSize.rawValue)
                
                if let kitchenSize = KitchenType(rawValue: (Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].kitchenType)!) {
                    cell.kitchenType.text = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
                }
            }
            
            var totalSleepCapacity = String()
            
            if (Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].publicSleepCapacity)! > 0 {
                
                totalSleepCapacity =  String(describing: Constant.MyClassConstants.selectedResort.inventory!.units[Constant.MyClassConstants.selectedUnitIndex].publicSleepCapacity) + Constant.CommonLocalisedString.totalString
                
            }
            
            if (Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].privateSleepCapacity)! > 0 {
                
                cell.sleeps.text =  totalSleepCapacity + String(describing: Constant.MyClassConstants.selectedResort.inventory!.units[Constant.MyClassConstants.selectedUnitIndex].privateSleepCapacity) + Constant.CommonLocalisedString.privateString
                
            }
            
            cell.getawayPrice.text = String(Int((Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].prices[0].price)!))
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        }
        
    }
}


//MARK:- Delegate Methods

// Implementing custom delegate method definition
extension WhatToUseViewController:RenewelViewControllerDelegate {
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalArray:[Renewal]){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
        viewController.renewalsArray = renewalArray
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        //let navController = UINavigationController(rootViewController: viewController)
        
        //self.dismiss(animated: true, completion: nil)
        //self.present(navController, animated: true, completion: nil)
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func noThanks(){
        self.dismiss(animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        
        /*let navController = UINavigationController(rootViewController: viewController)
         
         self.present(viewController, animated:true, completion: nil)*/
        self.navigationController!.pushViewController(viewController, animated: true)

    }
    
    func dismissWhatToUse(renewalArray:[Renewal]) {
        //self.dismiss(animated: true, completion: nil)
        self.delegate?.navigateToWhoWillBeCheckIn(renewalArray: renewalArray)
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        
        print("other options")
        
        if(Constant.RunningDevice.deviceIdiom == .phone) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.renewalOtherOptionsVC) as! RenewalOtherOptionsVC
            viewController.delegate = self
            
            viewController.forceRenewals = forceRenewals
            self.present(viewController, animated:true, completion: nil)
            
            return
            
        } else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.renewalOtherOptionsVC) as! RenewalOtherOptionsVC
            viewController.delegate = self
            
            viewController.forceRenewals = forceRenewals
            self.present(viewController, animated:true, completion: nil)
            
            return
            
        }
        
    }
    
}


//Mark:- Delegate
extension WhatToUseViewController:RenewalOtherOptionsVCDelegate{
    func selectedRenewal(selectedRenewal: String, forceRenewals: ForceRenewals) {
        var renewalArray = [Renewal]()
        renewalArray.removeAll()
        if(selectedRenewal == "Core"){
            // Selected core renewal
            for renewal in forceRenewals.products{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalArray.append(renewalItem)
                    break
                }
            }
        }else{
            // Selected non core renewal
            for renewal in forceRenewals.crossSelling{
                if(renewal.term == 12){
                    let renewalItem = Renewal()
                    renewalItem.id = renewal.id
                    renewalArray.append(renewalItem)
                    break
                }
            }
        }
        
        // Selected single renewal from other options. Navigate to WhoWillBeCheckingIn screen
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        viewController.isFromRenewals = true
        viewController.renewalsArray = renewalArray
        //let navController = UINavigationController(rootViewController: viewController)
        self.navigationController!.pushViewController(viewController, animated: true)
        //self.present(navController, animated: true, completion: nil)
    }
}
