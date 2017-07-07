//
//  BookYourSelectionViewController.swift
//  IntervalApp
//
//  Created by Chetu on 07/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import SVProgressHUD

class BookYourSelectionViewController: UIViewController {
    
    var isCheckedBox = false
     var showUpgrade = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Get dynamic rows
        self.getNumberOfRows()
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
        
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkBoxPressed(_ sender: Any) {
        
        let cell = (sender as AnyObject).superview??.superview?.superview as? RelinquishmentSelectionOpenWeeksCell
        if self.isCheckedBox == false {
            cell?.mainView.layer.borderColor = UIColor.orange.cgColor
            self.isCheckedBox = true
        } else {
            cell?.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
            self.isCheckedBox = false
            
        }
        
        
        
        //Start process request
        
        //Exchange process request parameters
        Helper.showProgressBar(senderView: self)
        let processResort = ExchangeProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        
        let processRequest = ExchangeProcessStartRequest()
        
        processRequest.destination = Constant.MyClassConstants.exchangeDestination
        processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        if(Constant.MyClassConstants.filterRelinquishments[(cell?.tag)!].openWeek != nil){
            processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[(cell?.tag)!].openWeek?.relinquishmentId
        }
        
        ExchangeProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: {(response) in
            Helper.hideProgressBar(senderView: self)
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            Constant.MyClassConstants.exchangeViewResponse = response.view!
            //Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            /*for amenity in (response.view?.resort?.amenities)!{
                if(amenity.nearby == false){
                    Constant.MyClassConstants.onsiteArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                }else{
                    Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                }
            }*/
            
            
            UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                
                // Got an access token!  Save it for later use.
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                Constant.MyClassConstants.membershipContactArray = Membership.contacts!
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                
                let transitionManager = TransitionManager()
                self.navigationController?.transitioningDelegate = transitionManager
                self.navigationController!.pushViewController(viewController, animated: true)
                
            }, onError: { (error) in
                
                Helper.hideProgressBar(senderView: self)
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                
            })
            
        }, onError: {(error) in
            Helper.hideProgressBar(senderView: self)
            SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
        })
        
        
    }
    
    @IBAction func onClickDetailsButton(_ sender: Any) {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showDestinationResortsSegue, sender: nil)
    }
    
    // Function to get dynamic number of rows according to API response
    
    func getNumberOfRows(){
        
    }
}

//***** MARK: Extension classes starts from here *****//

extension BookYourSelectionViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
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
                            return 100
                        }
                //}else{
                //    return 70
                //}
    
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
                bottomLabel.text = "4 of the 6 relquishments are avialable for exchange"
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

extension BookYourSelectionViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
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
               
                if let image = Constant.MyClassConstants.selectedResort.images.first?.url{
                    cell.destinationImageView.setImageWith(URL(string: image) , completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                        if (error != nil) {
                            cell.destinationImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        }
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                }
                
                if let resortName = Constant.MyClassConstants.selectedResort.resortName{
                    cell.resortName.text = resortName
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                    
                    return cell
            }
        
            else if((indexPath as NSIndexPath).section == 1) {
            
               let exchange = Constant.MyClassConstants.filterRelinquishments[indexPath.row]
                
                if((exchange.pointsProgram) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.tag = indexPath.row
                    cell.contentBackgroundView.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                }else if((exchange.clubPoints) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.tag = indexPath.row
                    cell.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                }else if((exchange.openWeek) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    cell.tag = indexPath.row
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    

                    if showUpgrade == true {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell2, for: indexPath) as! RelinquishmentSelectionOpenWeeksCellWithUpgrade
                    
                        //Helper.applyShadowOnUIView(view: cell.contentView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
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
                        //Helper.applyShadowOnUIView(view: cell.contentView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
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
                    }
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.tag = indexPath.row
                    cell.contentBackgroundView.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
            }
            else {
                
                //***** Configure and return search vacation cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeCell0", for: indexPath) as! AvailablePointCell
                cell.tag = indexPath.row
                Helper.applyShadowOnUIView(view: cell, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
                
            }
    }
}
