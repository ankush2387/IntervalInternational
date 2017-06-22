//
//  VacationSearchResultIPadController.swift
//  IntervalApp
//
//  Created by Chetu on 11/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage
import SVProgressHUD

class VacationSearchResultIPadController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var searchedDateCollectionView: UICollectionView!
    @IBOutlet weak var resortDetailTBLView: UITableView!
    
    //***** Class variables *****//
    var unitSizeArray = [AnyObject]()
    var collectionviewSelectedIndex:Int = 0
    //var checkInDatesArray = Constant.MyClassConstants.checkInDates
    var loadFirst = true
    var enablePreviousMore = true
    var enableNextMore = true
    var alertView = UIView()
    let headerVw = UIView()
    let titleLabel = UILabel()
    var cellHeight = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Adding back button on menu bar.
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(VacationSearchResultIPadController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchedDateCollectionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
        self.title = Constant.ControllerTitles.searchResultViewController
        
        if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
            
            headerVw.frame = CGRect(x:0, y:0, width:300, height:40)
            headerVw.backgroundColor = UIColor.gray
            
            titleLabel.frame = CGRect(x:10, y:0, width:280, height:40)
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14)
            headerVw.addSubview(titleLabel)
            
            let dateValue = Constant.MyClassConstants.checkInDates[collectionviewSelectedIndex]
            if(Constant.MyClassConstants.surroundingCheckInDates.contains(dateValue)){
                headerVw.backgroundColor = UIColor(red: 170/255.0, green: 216/255.0, blue: 111/255.0, alpha: 1.0)
                titleLabel.text = Constant.MyClassConstants.surroundingAreaString
            }else{
                headerVw.backgroundColor = UIColor(rgb:IUIKColorPalette.primary1.rawValue)
                if(Constant.MyClassConstants.vacationSearchDestinationArray.count > 1){
                    titleLabel.text = "Resorts in \(Constant.MyClassConstants.vacationSearchDestinationArray[0]) and \(Constant.MyClassConstants.vacationSearchDestinationArray.count - 1) more"
                    
                }else{
                    titleLabel.text = "Resorts in \(Constant.MyClassConstants.whereTogoContentArray[0])"
                }
            }
            
            resortDetailTBLView.tableHeaderView = headerVw
    
        }
        
        self.enablePreviousMore = enableDisablePreviousMoreButtoniPad(Constant.MyClassConstants.left)
        self.enableNextMore = enableDisablePreviousMoreButtoniPad(Constant.MyClassConstants.right)
        self.searchedDateCollectionView.reloadData()
        
        if (Constant.MyClassConstants.showAlert == true) {
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            self.headerVw.isHidden = true
            self.view.bringSubview(toFront: self.alertView)
        }else{
            self.alertView.isHidden = true
            self.headerVw.isHidden = false
        }
        
        self.collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
    }
    
    
    // Function called to dismiss current controller when back button pressed.
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    //**** Function for orientation change for iPad ****//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.resortDetailTBLView.reloadData()
        if(alertView.isHidden == false){
            self.alertView.removeFromSuperview()
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*****Function for more button press *****//
    func moreButtonClicked(_ toDate: Date, fromDate: Date, index: String){
        let searchDateRequest = RentalSearchDatesRequest()
        searchDateRequest.checkInToDate = toDate
        searchDateRequest.checkInFromDate = fromDate
        
        Constant.MyClassConstants.currentToDate = toDate
        Constant.MyClassConstants.currentFromDate = fromDate
        
        searchDateRequest.destinations = Helper.getAllDestinationFromLocalStorage()
        searchDateRequest.resorts = Helper.getAllResortsFromLocalStorage()
        RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: searchDateRequest, onSuccess:{ (searchDates) in
            if(searchDates.checkInDates.count == 0){
                if(index == "First"){
                    self.enablePreviousMore = false
                }else{
                    self.enableNextMore = false
                }
                self.searchedDateCollectionView.reloadData()
            }
            for date in searchDates.checkInDates {
                
                Constant.MyClassConstants.checkInDates.append((date as NSDate) as Date)
            }
            
            Constant.MyClassConstants.checkInDates = (Constant.MyClassConstants.checkInDates) + (searchDates.checkInDates)
            
            Constant.MyClassConstants.checkInDates = Constant.MyClassConstants.checkInDates.sorted( by: { (first, second ) -> Bool in
                
                return first.timeIntervalSince1970 < second.timeIntervalSince1970
            })
            
            self.searchedDateCollectionView.reloadData()
            
        }) { (error) in
        }
    }
    
    //Function called when show resort details clicked.
    func getResortFromResortCode(_ toDate: Date) {
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
            Constant.MyClassConstants.resortsArray = response.resorts
            self.resortDetailTBLView.reloadData()
            }, onError: { (error) in
                
        })
        
    }
    
    //Function called when resort details button clicked.
    func resortDetailsClicked(_ toDate: Date){
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        
        Helper.addServiceCallBackgroundView(view: self.view)
        Constant.MyClassConstants.resortsArray.removeAll()
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
            Helper.removeServiceCallBackgroundView(view: self.view)
            Constant.MyClassConstants.resortsArray = response.resorts
            if(self.alertView.isHidden == false){
                self.alertView.isHidden = true
                self.headerVw.isHidden = false
            }
            self.resortDetailTBLView.reloadData()
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
            }, onError: { (error) in
                self.resortDetailTBLView.reloadData()
                self.alertView = Helper.noResortView(senderView: self.view)
                self.alertView.isHidden = false
                self.headerVw.isHidden = true
                Helper.removeServiceCallBackgroundView(view: self.view)
                SVProgressHUD.dismiss()
        })
    }
}

//Function to check whether more button should be enabled or disabled.
func enableDisablePreviousMoreButtoniPad(_ position : String) -> Bool {
    
    let currentDate = Date()
    var order = (Calendar.current as NSCalendar).compare(Constant.MyClassConstants.currentFromDate as Date, to: currentDate,toUnitGranularity: .hour)
    if (position.isEqual(Constant.MyClassConstants.right)) {
        let nextDate =  (Calendar.current as NSCalendar).date(byAdding: .month, value: +24, to: Constant.MyClassConstants.currentFromDate as Date, options: [])!
        order = (Calendar.current as NSCalendar).compare(currentDate, to: nextDate,toUnitGranularity: .hour)
    }
    
    switch order {
    case .orderedDescending:
        if (position == Constant.MyClassConstants.right) {
            return false
        }else{
            return true
        }
    case .orderedAscending:
        if (position == Constant.MyClassConstants.right) {
            return true
        }
        else {
            return false
        }
    case .orderedSame:
        return false
    }
}

//Extension for Collection View
extension VacationSearchResultIPadController:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 0:
            if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                
            let toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Constant.MyClassConstants.currentFromDate as Date, options: [])!
            let fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow), to: toDate, options: [])!
            moreButtonClicked(toDate, fromDate: fromDate, index: "First")
                
            }
            
            break
            
        case Constant.MyClassConstants.checkInDates.count+1:
            
            if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                
            let fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Constant.MyClassConstants.currentToDate as Date, options: [])!
            let toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: Constant.MyClassConstants.totalWindow, to: fromDate, options: [])!
            moreButtonClicked(toDate, fromDate: fromDate, index: "Last")
                
            }
            break
            
        default:
            if(self.collectionviewSelectedIndex != (indexPath as NSIndexPath).row){
                self.collectionviewSelectedIndex = (indexPath as NSIndexPath).row
                collectionView.reloadData()
                SVProgressHUD.show()
                if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
               
                if(Constant.MyClassConstants.vacationSearchDestinationArray.count > 1){
                    titleLabel.text = "Resorts in \(Constant.MyClassConstants.vacationSearchDestinationArray[0]) and \(Constant.MyClassConstants.vacationSearchDestinationArray.count - 1) more"
                }else{
                    titleLabel.text = "Resorts in \(Constant.MyClassConstants.vacationSearchDestinationArray[0])"
                 }
                }
                resortDetailsClicked(Constant.MyClassConstants.checkInDates[(indexPath as NSIndexPath).item - 1] as Date)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (loadFirst){
            
            let indexPath = IndexPath(row: Constant.MyClassConstants.searchResultCollectionViewScrollToIndex , section: 0)
            
            self.searchedDateCollectionView.scrollToItem(at: indexPath,at: .centeredHorizontally,animated: true)
            self.searchedDateCollectionView.contentOffset = CGPoint(x: 100, y: 0.0)
            loadFirst = false
        }
    }
}
extension VacationSearchResultIPadController:UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if ((indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.checkInDates.count+1){
            return CGSize(width: 160.0, height: 60.0)
        }else{
            return CGSize(width: 150.0, height: 60.0)
        }
    }
}

extension VacationSearchResultIPadController:UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.checkInDates.count + 2
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.resortDetailTBLView.frame.width, height: 20))
        footerView.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 246.0/255.0, alpha: 1)
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if ((indexPath as NSIndexPath).item == 0 || (indexPath as NSIndexPath).item == Constant.MyClassConstants.checkInDates.count+1) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.moreCell, for: indexPath) as! MoreCell
            cell.layer.cornerRadius = 7
            cell.layer.borderWidth = 2
            cell.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
            cell.layer.masksToBounds = true
            if (!self.enablePreviousMore && (indexPath as NSIndexPath).item == 0) {
                cell.isUserInteractionEnabled = false
            }
            else if(!self.enableNextMore && (indexPath as NSIndexPath).item == 1) {
                
                cell.isUserInteractionEnabled = false
            }
            else {
                
                cell.isUserInteractionEnabled = true
            }
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell, for: indexPath) as! SearchResultCollectionCell
            if((indexPath as NSIndexPath).row == collectionviewSelectedIndex) {
                
                cell.backgroundColor = IUIKColorPalette.primary1.color
                cell.dateLabel.textColor = UIColor.white
                cell.daynameWithyearLabel.textColor = UIColor.white
                cell.monthYearLabel.textColor = UIColor.white
            }
            else {
                cell.backgroundColor = UIColor.white
                cell.dateLabel.textColor = IUIKColorPalette.primary1.color
                cell.daynameWithyearLabel.textColor = IUIKColorPalette.primary1.color
                cell.monthYearLabel.textColor = IUIKColorPalette.primary1.color
            }
            cell.layer.cornerRadius = 7
            cell.layer.borderWidth = 2
            cell.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
            cell.layer.masksToBounds = true
            
            
            let dateValue = Constant.MyClassConstants.checkInDates[(indexPath as NSIndexPath).row - 1]
            cell.dateLabel.text = Helper.getWeekDay(dateString: dateValue as Date as Date as NSDate, getValue: Constant.MyClassConstants.date)
            cell.daynameWithyearLabel.text = Helper.getWeekDay(dateString: dateValue as Date as Date as NSDate, getValue: Constant.MyClassConstants.weekDay)
            cell.monthYearLabel.text = ((Helper.getWeekDay(dateString: dateValue as NSDate, getValue: Constant.MyClassConstants.month)) + " " + Helper.getWeekDay(dateString: dateValue as NSDate, getValue: Constant.MyClassConstants.year))
            
            return cell
        }
    }
}

//Extension for table view.
extension VacationSearchResultIPadController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if((indexPath as NSIndexPath).row == 0) {
            
            return (UIScreen.main.bounds.width - 40)/2 + 100
            //return 410
        }
        else {
            return CGFloat(cellHeight)
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath as NSIndexPath).row == 0) {
            
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: Constant.MyClassConstants.resortsArray[indexPath.section].resortCode!, onSuccess: { (response) in
                
                Constant.MyClassConstants.resortsDescriptionArray = response
                Constant.MyClassConstants.imagesArray.removeAllObjects()
                let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                for imgStr in imagesArray {
                    if(imgStr.size == Constant.MyClassConstants.imageSize) {
                        
                        Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                    }
                }
                Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = indexPath.section + 1
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                self.performSegue(withIdentifier: Constant.segueIdentifiers.vacationSearchDetailSegue, sender: nil)
                })
            { (error) in
                
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
            }
        }else{
            
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            
            Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[indexPath.section]
            
            var inventoryDict = [Inventory]()
            inventoryDict = Constant.MyClassConstants.resortsArray[indexPath.section].inventory
            let invent = inventoryDict[0]
            let units = invent.units
            
            Constant.MyClassConstants.inventoryPrice = invent.units[indexPath.row - 1].prices
            
            let processResort = RentalProcess()
            processResort.holdUnitStartTimeInMillis = Constant.holdingTime
            
            let processRequest = RentalProcessStartRequest()
            processRequest.resort = Constant.MyClassConstants.resortsArray[0]
            print(Constant.MyClassConstants.resortsArray[0].additionalCharges)
            if(Constant.MyClassConstants.resortsArray[0].allInclusive){
                Constant.MyClassConstants.hasAdditionalCharges = true
            }else{
                Constant.MyClassConstants.hasAdditionalCharges = false
            }
            processRequest.unit = units[0]
            
            let processRequest1 = RentalProcessStartRequest.init(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate, unitSize: UnitSize(rawValue: units[0].unitSize!)!, kitchenType: KitchenType(rawValue: units[0].kitchenType!)!)
            
            //API call for start process
            RentalProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
            
                let processResort = RentalProcess()
                processResort.processId = response.processId
                print(response.processId)
                Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
                
                
                Constant.MyClassConstants.processStartResponse = response
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                Constant.MyClassConstants.viewResponse = response.view!
                Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
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
                
                //API call for get membership current.
                UserClient.getCurrentMembership(UserContext.sharedInstance.accessToken, onSuccess: {(Membership) in
                    
                    // Got an access token!  Save it for later use.
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    Constant.MyClassConstants.membershipContactArray = Membership.contacts!
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as! WhoWillBeCheckingInIPadViewController
                    
                    let transitionManager = TransitionManager()
                    self.navigationController?.transitioningDelegate = transitionManager
                    self.navigationController!.pushViewController(viewController, animated: true)
                    
                    }, onError: { (error) in
                        
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                        SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
                        
                })
                
                }, onError: {(error) in
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
            })
            
        }
    }
}

extension VacationSearchResultIPadController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
        if((indexPath as NSIndexPath).row == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.imageWithNameCell, for: indexPath) as! ImageWithNameCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.lightGray.cgColor

            
            for layer in cell.bottomViewForResortName.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            
            let newFrame = CGRect(x: 0, y: UIScreen.main.bounds.width - 180, width: UIScreen.main.bounds.width - 40, height: 80)
            cell.bottomViewForResortName.frame = newFrame
            cell.bottomViewForResortName.backgroundColor = UIColor.clear
            Helper.addLinearGradientToView(view: cell.bottomViewForResortName, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.resotImageView.backgroundColor = UIColor.lightGray
            cell.backgroundColor = UIColor.orange
            if (Constant.MyClassConstants.resortsArray[indexPath.section].images.count>0){
                var url = URL(string: "")
                
                let imagesArray = Constant.MyClassConstants.resortsArray[indexPath.section].images
                for imgStr in imagesArray {
                    if(imgStr.size == Constant.MyClassConstants.imageSize) {
                        
                        url = URL(string: imgStr.url!)!
                        break
                    }
                }
                
                cell.resotImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }
            else {
                
            }
            cell.resortNameLabel.text = Constant.MyClassConstants.resortsArray[indexPath.section].resortName
            
            //TODO: (Jhon) - found nil on address, modified code
            if let resortAddress = Constant.MyClassConstants.resortsArray[indexPath.section].address {
                cell.resortLocation.text = resortAddress.cityName
                cell.resortLocation.text = cell.resortLocation.text?.appending(", \(resortAddress.countryCode)")
            }
//            let resortAddress = Constant.MyClassConstants.resortsArray[indexPath.section].address!
//            if let city = resortAddress.cityName {
//                
//                cell.resortLocation.text = city
//            }
//            if let Country = resortAddress.countryCode {
//                cell.resortLocation.text = cell.resortLocation.text?.appending(", \(Country)")
//            }
            
            cell.resortCode.text = Constant.MyClassConstants.resortsArray[indexPath.section].resortCode
            let tierImageName = Helper.getTierImageName(tier: Constant.MyClassConstants.resortsArray[indexPath.section].tier!)
            cell.tierImageView.image = UIImage(named: tierImageName)
            let status = Helper.isResrotFavorite(resortCode: Constant.MyClassConstants.resortsArray[indexPath.section].resortCode!)
            if(status) {
                cell.fevrateButton.isSelected = true
            }
            else {
                cell.fevrateButton.isSelected = false
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.getawayCell, for: indexPath) as! GetawayCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.lightGray.cgColor
            
            
            var inventoryDict = [Inventory]()
            inventoryDict = Constant.MyClassConstants.resortsArray[indexPath.section].inventory
            let invent = inventoryDict[0]
            let units = invent.units
            if let roomSize = UnitSize(rawValue: units[indexPath.row - 1].unitSize!) {
                cell.bedRoomType.text = Helper.getBrEnums(brType: roomSize.rawValue)
            }
            if let kitchenSize = KitchenType(rawValue: units[indexPath.row - 1].kitchenType!) {
                cell.kitchenType.text = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
            }
            
            cell.sleeps.text = String(units[indexPath.row - 1].publicSleepCapacity) + "Total, " + (String(units[indexPath.row - 1].privateSleepCapacity)) + "Private"
           
            cell.getawayPrice.text = String(Int(Float(invent.units[indexPath.row - 1].prices[0].price)))
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            let promotions = invent.units[indexPath.row - 1].promotions
            if promotions.count > 0 {
                for view in cell.promotionsView.subviews {
                    view.removeFromSuperview()
                }
                
                cellHeight = 55 + (14*promotions.count)
                var yPosition: CGFloat = 0
                for promotion in promotions {
                    print("Promotions: \(promotions)")
                    let imgV = UIImageView(frame: CGRect(x:10, y: yPosition, width: 15, height: 15))
                    imgV.image = UIImage(named: "ExchangeIcon")
                    let promLabel = UILabel(frame: CGRect(x:30, y: yPosition, width: cell.promotionsView.bounds.width, height: 15))
                    promLabel.text = promotion.offerName
                    promLabel.adjustsFontSizeToFitWidth = true
                    promLabel.minimumScaleFactor = 0.7
                    promLabel.numberOfLines = 0
                    promLabel.textColor = UIColor(red: 0, green: 119/255, blue: 190/255, alpha: 1)
                    promLabel.font = UIFont(name: "Helvetica", size: 18)
                    cell.promotionsView.addSubview(imgV)
                    cell.promotionsView.addSubview(promLabel)
                    yPosition += 15
                }
            }

            return cell
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        return Constant.MyClassConstants.resortsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        var inventoryDict = [Inventory]()
        inventoryDict = Constant.MyClassConstants.resortsArray[section].inventory
        let invent = inventoryDict[0]
        self.unitSizeArray = invent.units
        return self.unitSizeArray.count + 1
    }
}

// Implementing custom delegate method definition
extension VacationSearchIPadViewController:ImageWithNameCellDelegate {
    
    func favratePressedAtIndex(_ Index:Int) {
        
    }
    
}

