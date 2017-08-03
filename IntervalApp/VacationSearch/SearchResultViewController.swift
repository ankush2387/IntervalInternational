//
//  SearchResultViewController.swift
//  IntervalApp
//
//  Created by Chetu on 09/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage
import SVProgressHUD
import RealmSwift

class SearchResultViewController: UIViewController, sortingOptionDelegate {
    
     var selectedIndex = -1
    
    //***** Outlets ****//
    @IBOutlet weak var searchResultColelctionView: UICollectionView!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    //***** variable declaration *****//
    var collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
    //var checkInDatesArray = Constant.MyClassConstants.checkInDates
    var loadFirst = true
    var enablePreviousMore = true
    var enableNextMore = true
    var unitSizeArray = [AnyObject]()
    var alertView = UIView()
    let headerVw = UIView()
    let titleLabel = UILabel()
    var offerString = String()
    var cellHeight = 50
    var selectedSection = 0
    var selectedRow = 0
    
    // sorting optionDelegate call
    
    func selectedOptionis(filteredValueIs:String, indexPath:NSIndexPath, isFromFiltered:Bool) {
        
        if isFromFiltered {
            Constant.MyClassConstants.filteredIndex = indexPath.row
        } else {
            Constant.MyClassConstants.sortingIndex = indexPath.row
        }
        
        print(filteredValueIs)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 70.0/255.0, green: 136.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        searchResultTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.estimatedRowHeight = 400
        //offerString = (Constant.MyClassConstants.promotionsArray[0].offerContentFragment!).html2String
        
        searchResultTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        Helper.removeServiceCallBackgroundView(view: self.view)
        //***** Register collection cell xib with collection view *****//
        let nib = UINib(nibName: Constant.customCellNibNames.searchResultCollectionCell, bundle: nil)
        searchResultColelctionView?.register(nib, forCellWithReuseIdentifier: Constant.customCellNibNames.searchResultCollectionCell)
        
        searchResultTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier:  Constant.customCellNibNames.searchResultContentTableCell)
        
        if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
            
            //Show header for table if search is from exchange
            let tableHeader = UIView(frame : CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:0))
            if(Constant.MyClassConstants.isFromExchange){
                tableHeader.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
                tableHeader.backgroundColor = IUIKColorPalette.primary1.color
                
                let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
                headerLabel.numberOfLines = 0
                headerLabel.textColor = UIColor.white
                headerLabel.textAlignment = NSTextAlignment.center
                headerLabel.font = UIFont(name:Constant.fontName.helveticaNeue, size:15)
                headerLabel.text = Constant.MyClassConstants.searchResultHeader
                tableHeader.addSubview(headerLabel)
            }
            
            headerVw.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:tableHeader.frame.size.height + 44)
            headerVw.backgroundColor = UIColor.white
            
            titleLabel.frame = CGRect(x:0, y:tableHeader.frame.size.height + 2, width:UIScreen.main.bounds.width, height:40)
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14)
            headerVw.addSubview(tableHeader)
            headerVw.addSubview(titleLabel)
            
            
            
            //Check if resort is in surrounding areas or within destination
//            let dateValue = Constant.MyClassConstants.checkInDates[collectionviewSelectedIndex]
//            titleLabel.textAlignment = NSTextAlignment.center
//            if(Constant.MyClassConstants.surroundingCheckInDates.contains(dateValue)){
//                titleLabel.backgroundColor = UIColor(red: 170/255.0, green: 216/255.0, blue: 111/255.0, alpha: 1.0)
//                titleLabel.text = Constant.MyClassConstants.surroundingAreaString
//            }else{
//                titleLabel.backgroundColor = UIColor(rgb:IUIKColorPalette.primary1.rawValue)
//                if(Constant.MyClassConstants.vacationSearchDestinationArray.count > 1){
//                    titleLabel.text = "Resorts in \(Constant.MyClassConstants.vacationSearchDestinationArray[0]) and \(Constant.MyClassConstants.vacationSearchDestinationArray.count - 1) more"
//                    
//                }else{
//                    titleLabel.text = "Resorts in \(Constant.MyClassConstants.whereTogoContentArray[0])"
//                }
//            }
            
            searchResultTableView.tableHeaderView = headerVw
        }
        
        self.title = Constant.ControllerTitles.searchResultViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(SearchResultViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        self.enablePreviousMore = enableDisablePreviousMoreButton(Constant.MyClassConstants.left as NSString)
        self.enableNextMore = enableDisablePreviousMoreButton(Constant.MyClassConstants.right as NSString)
        
        if (Constant.MyClassConstants.showAlert == true) {
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            headerVw.isHidden = true
            self.view.bringSubview(toFront: self.alertView)
        }else{
            headerVw.isHidden = false
            self.alertView.isHidden = true
        }
        
        self.collectionviewSelectedIndex = Constant.MyClassConstants.searchResultCollectionViewScrollToIndex
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func moreButtonClicked(_ toDate: Date, fromDate: Date, index: String){
        self.enablePreviousMore = enableDisablePreviousMoreButton(Constant.MyClassConstants.left as NSString)
        self.enableNextMore = enableDisablePreviousMoreButton(Constant.MyClassConstants.right as NSString)
        SVProgressHUD.show()
        let searchDateRequest = RentalSearchDatesRequest()
        searchDateRequest.checkInToDate = toDate
        searchDateRequest.checkInFromDate = fromDate
        
        Constant.MyClassConstants.currentToDate = toDate
        Constant.MyClassConstants.currentFromDate = fromDate
        searchDateRequest.destinations = Helper.getAllDestinationFromLocalStorage()
        searchDateRequest.resorts = Helper.getAllResortsFromLocalStorage()
        Helper.addServiceCallBackgroundView(view: self.view)
        RentalClient.searchDates(UserContext.sharedInstance.accessToken, request: searchDateRequest, onSuccess:{ (searchDates) in
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            if(searchDates.checkInDates.count == 0){
                if(index == Constant.MyClassConstants.first){
                    self.enablePreviousMore = false
                }else{
                    self.enableNextMore = false
                }
                self.searchResultColelctionView.reloadData()
            }
            Constant.MyClassConstants.checkInDates = Constant.MyClassConstants.checkInDates + searchDates.checkInDates
            
            Constant.MyClassConstants.checkInDates = Constant.MyClassConstants.checkInDates.sorted( by: { (first, second ) -> Bool in
                
                return first.timeIntervalSince1970 < second.timeIntervalSince1970
            })
            
            self.searchResultColelctionView.reloadData()
            
        }) { (error) in
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
        }
    }
    
    func resortDetailsClicked(_ toDate: Date){
        let searchResortRequest = RentalSearchResortsRequest()
        searchResortRequest.checkInDate = toDate
        
        if(Constant.MyClassConstants.surroundingCheckInDates.contains(Constant.MyClassConstants.checkInDates[collectionviewSelectedIndex - 1])){
            
            searchResortRequest.resortCodes = Constant.MyClassConstants.surroundingResortCodesArray
        }else{
            
            searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
        }
        
        Constant.MyClassConstants.resortsArray.removeAll()
        Helper.showProgressBar(senderView: self)
        
        RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
            Constant.MyClassConstants.resortsArray = response.resorts
            if(self.alertView.isHidden == false){
                self.alertView.isHidden = true
                self.headerVw.isHidden = false
            }
            self.searchResultTableView.reloadData()
            Helper.hideProgressBar(senderView: self)
        }, onError: { (error) in
            Constant.MyClassConstants.resortsArray.removeAll()
            self.searchResultTableView.reloadData()
            self.alertView = Helper.noResortView(senderView: self.view)
            self.alertView.isHidden = false
            self.headerVw.isHidden = true
            Helper.hideProgressBar(senderView: self)
        })
        
    }
    //Static Calling API for filterRelinquishments
    
    func getStaticFilterRelinquishments(){
        Helper.showProgressBar(senderView: self)
        let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
        exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        let relinquishmentIDArray = ["Ek83chJmdS6ESNRpVfhH8QaTBeXh5rpNm_2AJLhV_4jRTiVySvOk2NKFm4iHOtEK",
                                     "Ek83chJmdS6ESNRpVfhH8RFxFgvpS1HHCzYyrvzw42rRTiVySvOk2NKFm4iHOtEK",
                                     "Ek83chJmdS6ESNRpVfhH8SOcpMOEqw1KO8bsQKhjLZnRTiVySvOk2NKFm4iHOtEK",
                                     "Ek83chJmdS6ESNRpVfhH8YMAv0D39MaVmh75YJgm_IDRTiVySvOk2NKFm4iHOtEK"]
        exchangeSearchDateRequest.relinquishmentsIds = relinquishmentIDArray//Constant.MyClassConstants.relinquishmentIdArray as! [String]
        
        
        
        let exchangeDestination = ExchangeDestination()
        let currentFromDate = Helper.convertDateToString(date: Constant.MyClassConstants.currentFromDate, format: Constant.MyClassConstants.dateFormat)
        
        let currentToDate = Helper.convertDateToString(date: Constant.MyClassConstants.currentToDate, format: Constant.MyClassConstants.dateFormat)
        
        let resort = Resort()
        //resort.resortName = Constant.MyClassConstants.resortsArray[selectedIndex].resortName
        resort.resortCode = "CZP"//Constant.MyClassConstants.resortsArray[selectedIndex].resortCode
        
        exchangeDestination.resort = resort
        
        let unit = InventoryUnit()
        unit.kitchenType = "NO_KITCHEN"//Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[0].unit!.kitchenType!
        unit.unitSize = "STUDIO"//Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[0].unit!.unitSize!
        exchangeDestination.checkInDate = "2017-07-17"//currentFromDate
        exchangeDestination.checkOutDate = "2017-07-24"//currentToDate
        //unit.unitNumber = Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[0].unit!.unitNumber!
        unit.publicSleepCapacity = 4
        unit.privateSleepCapacity = 2
        
        exchangeDestination.unit = unit
        
        exchangeSearchDateRequest.destination = exchangeDestination
        
        ExchangeClient.filterRelinquishments(UserContext.sharedInstance.accessToken, request: exchangeSearchDateRequest, onSuccess: { (response) in
            Helper.hideProgressBar(senderView: self)
            for exchageDetail in response{
                Constant.MyClassConstants.filterRelinquishments.append(exchageDetail.relinquishment!)
            }
            
            Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[self.selectedSection]
            
            Constant.MyClassConstants.inventoryPrice = (Constant.MyClassConstants.exchangeInventory[self.selectedSection].buckets[0].unit?.prices)!
            Constant.MyClassConstants.exchangeDestination = exchangeDestination
            
            self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
        }, onError: { (error) in
            print(Error.self)
            Helper.hideProgressBar(senderView: self)
        })
    }
    
    //Dynamic API hit
    
    func getFilterRelinquishments(){
        Helper.showProgressBar(senderView: self)
        let exchangeSearchDateRequest = ExchangeFilterRelinquishmentsRequest()
        exchangeSearchDateRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
        exchangeSearchDateRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as! [String]
        
        let exchangeDestination = ExchangeDestination()
        let currentFromDate = Helper.convertDateToString(date: Constant.MyClassConstants.currentFromDate, format: Constant.MyClassConstants.dateFormat)
        
        let currentToDate = Helper.convertDateToString(date: Constant.MyClassConstants.currentToDate, format: Constant.MyClassConstants.dateFormat)
        
        let resort = Resort()
        resort.resortCode = Constant.MyClassConstants.resortsArray[selectedSection].resortCode
        
        exchangeDestination.resort = resort
        
        let unit = InventoryUnit()
        unit.kitchenType = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow - 1].unit!.kitchenType!
        unit.unitSize = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow - 1].unit!.unitSize!
        exchangeDestination.checkInDate = currentFromDate
        exchangeDestination.checkOutDate = currentToDate
        unit.publicSleepCapacity = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow - 1].unit!.publicSleepCapacity
        unit.privateSleepCapacity = Constant.MyClassConstants.exchangeInventory[selectedSection].buckets[selectedRow - 1].unit!.privateSleepCapacity
        
        exchangeDestination.unit = unit
        
        exchangeSearchDateRequest.destination = exchangeDestination
        Constant.MyClassConstants.exchangeDestination = exchangeDestination
        
        ExchangeClient.filterRelinquishments(UserContext.sharedInstance.accessToken, request: exchangeSearchDateRequest, onSuccess: { (response) in
            Helper.hideProgressBar(senderView: self)
            Constant.MyClassConstants.filterRelinquishments.removeAll()
            for exchageDetail in response{
                Constant.MyClassConstants.filterRelinquishments.append(exchageDetail.relinquishment!)
            }
            
            Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[self.selectedSection]
            
            Constant.MyClassConstants.inventoryPrice = (Constant.MyClassConstants.exchangeInventory[self.selectedSection].buckets[self.selectedRow - 1].unit?.prices)!
            if(Constant.MyClassConstants.filterRelinquishments.count > 1){
                self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
            }else if(response[0].destination?.upgradeCost != nil){
                self.performSegue(withIdentifier: Constant.segueIdentifiers.bookingSelectionSegue, sender: self)
            }else {
                self.startProcess()
            }
            
        }, onError: { (error) in
            Helper.hideProgressBar(senderView: self)
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.description)
        })
    }
    
    //Start process function call
    
    func startProcess(){
        
        
        //Start process request
        
        //Exchange process request parameters
        Helper.showProgressBar(senderView: self)
        let processResort = ExchangeProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        
        let processRequest = ExchangeProcessStartRequest()
        
        processRequest.destination = Constant.MyClassConstants.exchangeDestination
        processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.relinquishmentId
        
        ExchangeProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest, onSuccess: {(response) in
            let processResort = ExchangeProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
            Constant.MyClassConstants.exchangeProcessStartResponse = response
            Constant.MyClassConstants.exchangeViewResponse = response.view!
            //Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            //cell?.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
            
            
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
                var viewController = UIViewController()
                    viewController = WhoWillBeCheckingInViewController()
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                    viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                    (viewController as! WhoWillBeCheckingInViewController).filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[0]
                    
                    
                
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
  

    //Passing information while preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // function called when search result page map view button pressed
    @IBAction func mapViewButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultMapSegue , sender: nil)
    }
    
    @IBAction func sortByNameButtonPressed(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        viewController.delegate = self
        viewController.selectedSortingIndex = Constant.MyClassConstants.sortingIndex
        self.navigationController?.pushViewController(viewController, animated: true)
        
        //self.performSegue(withIdentifier: Constant.segueIdentifiers.sortingSegue , sender: nil)
    }
    
    //funciton called when search result page sort by name button pressed
    @IBAction func filterByNameButtonPressed(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.storyboardControllerID.sortingViewController) as! SortingViewController
        viewController.delegate = self
        viewController.isFilterClicked = true
        viewController.resortNameArray = Constant.MyClassConstants.resortsArray
        viewController.selectedIndex = Constant.MyClassConstants.filteredIndex
        self.navigationController?.pushViewController(viewController, animated: true)
        
        // self.performSegue(withIdentifier: Constant.segueIdentifiers.sortingSegue , sender: nil)
    }
    
}

func enableDisablePreviousMoreButton(_ position : NSString) -> Bool{
    let currentDate = Date()
    var order = (Calendar.current as NSCalendar).compare(Constant.MyClassConstants.currentFromDate as Date, to: currentDate,toUnitGranularity: .hour)
    if (position.isEqual(to: Constant.MyClassConstants.right)) {
        let nextDate =  (Calendar.current as NSCalendar).date(byAdding: .month, value: +24, to: Constant.MyClassConstants.currentFromDate as Date, options: [])!
        order = (Calendar.current as NSCalendar).compare(currentDate, to: nextDate,toUnitGranularity: .hour)
    }
    
    switch order {
    case .orderedDescending:
        if (position.isEqual(to: Constant.MyClassConstants.right)) {
            return false
        }else{
            return true
        }
    case .orderedAscending:
        if (position.isEqual(to: Constant.MyClassConstants.right)) {
            return true
        }else{
            return false
        }
    case .orderedSame:
        return false
    }
}


//***** MARK: Extension classes starts from here *****//

extension SearchResultViewController:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 0:
            
            if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                let toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Constant.MyClassConstants.currentFromDate as Date, options: [])!//Constant.MyClassConstants.currentFromDate
                let fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -90, to: toDate, options: [])!
                moreButtonClicked(toDate, fromDate: fromDate, index: Constant.MyClassConstants.first)
            }
            
            break
            
        case Constant.MyClassConstants.checkInDates.count+1:
            
            if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                let fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Constant.MyClassConstants.currentToDate as Date, options: [])!//Constant.MyClassConstants.currentToDate
                let toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: 90, to: fromDate, options: [])!
                moreButtonClicked(toDate, fromDate: fromDate, index: Constant.MyClassConstants.last)
            }
            break
            
        default:
            
            if(self.collectionviewSelectedIndex != (indexPath as NSIndexPath).row){
                self.collectionviewSelectedIndex = (indexPath as NSIndexPath).row
                collectionView.reloadData()
        
                let dateValue:Date!
                if(Constant.MyClassConstants.checkInDates.count > 0){
                    dateValue = Constant.MyClassConstants.checkInDates[collectionviewSelectedIndex - 1]
                }else{
                    dateValue = Constant.MyClassConstants.checkInDates[collectionviewSelectedIndex]
                }
                Constant.MyClassConstants.currentFromDate = dateValue
                if(Constant.MyClassConstants.surroundingCheckInDates.contains(dateValue) && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                    titleLabel.backgroundColor = UIColor(red: 170/255.0, green: 216/255.0, blue: 111/255.0, alpha: 1.0)
                    titleLabel.text = Constant.MyClassConstants.surroundingAreaString
                    
                }else{
                    
                    titleLabel.backgroundColor = UIColor(rgb:IUIKColorPalette.primary1.rawValue)
                    if(Constant.MyClassConstants.vacationSearchDestinationArray.count > 1 && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                        titleLabel.text = "Resorts in \(Constant.MyClassConstants.vacationSearchDestinationArray[0]) and \(Constant.MyClassConstants.vacationSearchDestinationArray.count - 1) more"
                    }else{
                        if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.getawayAlerts){
                            if Constant.MyClassConstants.vacationSearchDestinationArray.count > 0 {
                                titleLabel.text = "Resorts in \(Constant.MyClassConstants.vacationSearchDestinationArray[0])"
                            } else {
                                titleLabel.text = "Resorts in \(Constant.MyClassConstants.whereTogoContentArray[0])"
                            }

                        }
                    }
                }
                if(Constant.MyClassConstants.isFromExchange){
                    Helper.showProgressBar(senderView: self)
                    let exchangeAvailabilityRequest = ExchangeSearchAvailabilityRequest()
                    exchangeAvailabilityRequest.checkInDate = Constant.MyClassConstants.checkInDates[(indexPath as NSIndexPath).item - 1] as Date
                    exchangeAvailabilityRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
                    exchangeAvailabilityRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
                    exchangeAvailabilityRequest.relinquishmentsIds = Constant.MyClassConstants.relinquishmentIdArray as! [String]
                    ExchangeClient.searchAvailability(UserContext.sharedInstance.accessToken, request: exchangeAvailabilityRequest, onSuccess: { (exchangeAvailability) in
                        Helper.hideProgressBar(senderView: self)
                            self.alertView.isHidden = true
                            self.headerVw.isHidden = false
                        Constant.MyClassConstants.resortsArray.removeAll()
                        Constant.MyClassConstants.exchangeInventory.removeAll()
                        for exchangeResorts in exchangeAvailability{
                            Constant.MyClassConstants.resortsArray.append(exchangeResorts.resort!)
                            Constant.MyClassConstants.exchangeInventory.append(exchangeResorts.inventory!)
                        }

                        self.searchResultTableView.reloadData()
                    }, onError: { (error) in
                        Constant.MyClassConstants.resortsArray.removeAll()
                        self.searchResultTableView.reloadData()
                        Helper.hideProgressBar(senderView: self)
                        self.alertView.isHidden = false
                        self.headerVw.isHidden = true
                    })
                    
                }else{
                    resortDetailsClicked(Constant.MyClassConstants.checkInDates[(indexPath as NSIndexPath).item - 1] as Date)
                }
            }
            
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath){
        if (loadFirst){
            
            let indexPath = IndexPath(row: Constant.MyClassConstants.searchResultCollectionViewScrollToIndex , section: 0)
            self.searchResultColelctionView.scrollToItem(at: indexPath,at: .centeredHorizontally,animated: true)
            loadFirst = false
        }
    }
}
extension SearchResultViewController:UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 6.0, bottom: 0.0, right: 6.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if ((indexPath as NSIndexPath).item == 0 || (indexPath as NSIndexPath).item == Constant.MyClassConstants.checkInDates.count+1){
            return CGSize(width: 120.0, height: 50.0)
        }else{
            return CGSize(width: 150.0, height: 50.0)
        }
    }
}

extension SearchResultViewController:UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return Constant.MyClassConstants.checkInDates.count + 2
        return Constant.MyClassConstants.calendarCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if ((indexPath as NSIndexPath).item == 0 || (indexPath as NSIndexPath).item == Constant.MyClassConstants.checkInDates.count+1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.moreSearchResult, for: indexPath) as! MoreCell
            cell.layer.cornerRadius = 7
            cell.layer.borderWidth = 2
            cell.layer.masksToBounds = true
            if (!self.enablePreviousMore && (indexPath as NSIndexPath).item == 0) {
                cell.isUserInteractionEnabled = false
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.moreLabel.textColor = UIColor.lightGray
            }else if(!self.enableNextMore && (indexPath as NSIndexPath).item == Constant.MyClassConstants.checkInDates.count+1){
                cell.isUserInteractionEnabled = false
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.moreLabel.textColor = UIColor.lightGray
            }else{
                cell.isUserInteractionEnabled = true
                cell.layer.borderColor = IUIKColorPalette.primaryB.color.cgColor
                cell.moreLabel.textColor = IUIKColorPalette.primaryB.color
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
            
            //Check
            
            var dateValue = Date()
            if(Constant.MyClassConstants.checkInDates.count > 0){
                dateValue = Constant.MyClassConstants.checkInDates[indexPath.row - 1]
            }
            cell.dateLabel.text = Helper.getWeekDay(dateString: dateValue as Date as Date as NSDate, getValue: Constant.MyClassConstants.date)
            cell.daynameWithyearLabel.text = Helper.getWeekDay(dateString: dateValue as Date as Date as NSDate, getValue: Constant.MyClassConstants.weekDay)
            cell.monthYearLabel.text = ((Helper.getWeekDay(dateString: dateValue as NSDate, getValue: Constant.MyClassConstants.month)) + " " + Helper.getWeekDay(dateString: dateValue as NSDate, getValue: Constant.MyClassConstants.year))
            
            return cell
        }
    }
}

extension SearchResultViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*if((indexPath as NSIndexPath).row == 0) {
            
            return 252
        }
        else {
<<<<<<< HEAD
            if(indexPath.row > Constant.MyClassConstants.inventoryUnitsArray.count){
                return 120
            }else{
                return 50
            }
        }*/
        
        return UITableViewAutomaticDimension
        //return CGFloat(cellHeight)
        //}
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath as NSIndexPath).row == 0) {
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.vacationSearchFunctionalityCheck
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: Constant.MyClassConstants.resortsArray[indexPath.section].resortCode!, onSuccess: { (response) in
                
                Constant.MyClassConstants.resortsDescriptionArray = response
                Constant.MyClassConstants.imagesArray.removeAllObjects()
                let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                for imgStr in imagesArray {
                    if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                        
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
            
            if(Constant.MyClassConstants.isFromExchange){
                if(indexPath.row > Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets.count + 1)
                {
                    
                }else{
                selectedSection = indexPath.section
                selectedRow = indexPath.row
                Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[indexPath.section]
                self.getFilterRelinquishments()
                //self.getStaticFilterRelinquishments()

                }
              }else{
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            
            Constant.MyClassConstants.selectedResort = Constant.MyClassConstants.resortsArray[indexPath.section]
            
            var inventoryDict = Inventory()
            inventoryDict = Constant.MyClassConstants.resortsArray[indexPath.section].inventory!
            let invent = inventoryDict
            let units = invent.units
            
            Constant.MyClassConstants.inventoryPrice = invent.units[indexPath.row - 1].prices
            
            let processResort = RentalProcess()
            processResort.holdUnitStartTimeInMillis = Constant.holdingTime
            
            let processRequest = RentalProcessStartRequest()
            processRequest.resort = Constant.MyClassConstants.resortsArray[0]
            if(Constant.MyClassConstants.resortsArray[0].allInclusive){
                Constant.MyClassConstants.hasAdditionalCharges = true
            }else{
                Constant.MyClassConstants.hasAdditionalCharges = false
            }
            processRequest.unit = units[0]
            
            let processRequest1 = RentalProcessStartRequest.init(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate!, unitSize: UnitSize(rawValue: units[0].unitSize!)!, kitchenType: KitchenType(rawValue: units[0].kitchenType!)!)
            
            RentalProcessClient.start(UserContext.sharedInstance.accessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
                
                let processResort = RentalProcess()
                processResort.processId = response.processId
                Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
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
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                    
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
                SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.description)
            })
        }
      }
   }
}

extension SearchResultViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring prototype cell for UpComingtrip resort details *****//
        if((indexPath as NSIndexPath).row == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath) as! SearchResultContentTableCell
            
            for layer in cell.resortNameGradientView.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            
            Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            
            
            if(Constant.MyClassConstants.resortsArray.count != 0){
                if (Constant.MyClassConstants.resortsArray[indexPath.section].images.count>0){
                    var url = URL(string: "")
                    
                    let imagesArray = Constant.MyClassConstants.resortsArray[indexPath.section].images
                    for imgStr in imagesArray {
                        if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                            
                            url = URL(string: imgStr.url!)!
                            cell.resortImageView.contentMode = .scaleToFill
                            break
                        }
                    }
                    cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                }
                else {
                    
                }
            }
            cell.resortName.text = Constant.MyClassConstants.resortsArray[indexPath.section].resortName
            cell.delegate = self
            let resortAddress = Constant.MyClassConstants.resortsArray[indexPath.section].address
            if let city = resortAddress?.cityName! {
                
                cell.resortCountry.text = city
            }
            if let Country = resortAddress?.countryCode! {
                
                cell.resortCountry.text = cell.resortCountry.text?.appending(", \(Country)")
            }
            // resortAddress.country?.countryName
            cell.resortCode.text = Constant.MyClassConstants.resortsArray[indexPath.section].resortCode
            if(Constant.MyClassConstants.resortsArray[indexPath.section].tier != nil){
            let tierImageName = Helper.getTierImageName(tier: Constant.MyClassConstants.resortsArray[indexPath.section].tier!.uppercased())
            cell.tierImageView.image = UIImage(named: tierImageName)
            }
            let status = Helper.isResrotFavorite(resortCode: Constant.MyClassConstants.resortsArray[indexPath.section].resortCode!)
            if(status) {
                cell.favoriteButton.isSelected = true
            }
            else {
                cell.favoriteButton.isSelected = false
            }
            cell.favoriteButton.tag = indexPath.section
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else {
            if(!Constant.MyClassConstants.isFromExchange){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortBedroomDetails, for: indexPath) as! ResortBedroomDetails
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                var inventoryDict = Inventory()
                
                inventoryDict = Constant.MyClassConstants.resortsArray[indexPath.section].inventory!
                
                let invent = inventoryDict
                let units = invent.units
                
                if let roomSize = UnitSize(rawValue: units[indexPath.row - 1].unitSize!) {
                    
                    cell.numberOfBedroom.text =  Helper.getBrEnums(brType: roomSize.rawValue)
                }
                
                if let kitchenSize = KitchenType(rawValue: units[indexPath.row - 1].kitchenType!) {
                    cell.kitchenLabel.text = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
                }
                
                cell.totalPrivateLabel.text = String(units[indexPath.row - 1].publicSleepCapacity + units[indexPath.row - 1].privateSleepCapacity) + "Total, " + (String(units[indexPath.row - 1].privateSleepCapacity)) + "Private"
                
                //Change to currency symbol
                let currencySymbol : String?
                currencySymbol = Helper.currencyCodetoSymbol(code: invent.currencyCode!)
                cell.currencySymbol.text = currencySymbol
                let inventoryPrice:[InventoryPrice] = invent.units[indexPath.row - 1].prices
                cell.getawayPriceLabel.text = String(Int(Float(inventoryPrice[0].price)))
                cell.exchangeLabel.isHidden = true
                cell.sepratorOr.isHidden = true
                cell.exchangeButton.isHidden = true
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                //display promotions
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
                        imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
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
                
            }else{
                
                //Check for promotions
                
                var promotions = 0
                for bucket in Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets{
                    //for (index,promotion) in bucket.promotions.enumerated(){
                    promotions = bucket.promotions.count
                    //}
                }
                if(promotions != 0 && indexPath.row > Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets.count){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.promotionsCell, for: indexPath) as! PromotionsCell
                    
                    var promotions = 0
                    for bucket in Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets{
                        for (index,promotion) in bucket.promotions.enumerated(){
                            if (index == indexPath.row - Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets.count){
                                var promotionsString = Constant.MyClassConstants.htmlHeader.appending((Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].promotions[0].offerContentFragment)!)
                                for promotion in Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].promotions{
                                    promotionsString = promotion.offerContentFragment!
                                    promotionsString = promotionsString.appending(Constant.MyClassConstants.htmlFooter)
                                    cell.promotionWebView.loadHTMLString(promotionsString, baseURL: Bundle.main.bundleURL)
                                }

                            }
                        }
                    }
                    
                 return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortBedroomDetailexchange, for: indexPath) as! ResortBedroomDetails
                    cell.backgroundColor = IUIKColorPalette.contentBackground.color
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    if let roomSize = UnitSize(rawValue: Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.unitSize!) {
                        
                        cell.numberOfBedroom.text =  Helper.getBrEnums(brType: roomSize.rawValue)
                    }
                    
                    if let kitchenSize = KitchenType(rawValue: Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.kitchenType!) {
                        cell.kitchenLabel.text = Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue)
                    }
                    
                    cell.totalPrivateLabel.text = String(Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.publicSleepCapacity) + "Total, " + (String(Constant.MyClassConstants.exchangeInventory[indexPath.section].buckets[indexPath.row - 1].unit!.privateSleepCapacity)) + "Private"
                    return cell
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        return Constant.MyClassConstants.resortsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        if(Constant.MyClassConstants.isFromExchange){
            if(Constant.MyClassConstants.exchangeInventory[section].buckets.count > 0){
                self.unitSizeArray = [Constant.MyClassConstants.exchangeInventory[section].buckets[0].unit!]
                var promotions = 0
                for bucket in Constant.MyClassConstants.exchangeInventory[section].buckets{
                    //for (index,promotion) in bucket.promotions.enumerated(){
                        promotions = bucket.promotions.count
                    //}
                }
                return Constant.MyClassConstants.exchangeInventory[section].buckets.count + promotions + 1
            }else{
                return 1
            }
            
        }else{
            var inventoryDict = Inventory()
            inventoryDict = Constant.MyClassConstants.resortsArray[section].inventory!
            let invent = inventoryDict
            self.unitSizeArray = invent.units
            return self.unitSizeArray.count + 1
        }
        
    }
}

extension SearchResultViewController:SearchResultContentTableCellDelegate{
    func favoriteButtonClicked(_ sender: UIButton){
        if((UserContext.sharedInstance.accessToken) != nil) {
            
            if (sender.isSelected == false){
                
                print(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                SVProgressHUD.show()
                Helper.addServiceCallBackgroundView(view: self.view)
                UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                    
                    print(response)
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                    self.searchResultTableView.reloadData()
                    
                }, onError: {(error) in
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    print(error)
                })
            }
            else {
                SVProgressHUD.show()
                Helper.addServiceCallBackgroundView(view: self.view)
                UserClient.removeFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                    
                    print(response)
                    sender.isSelected = false
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                    self.searchResultTableView.reloadData()
                    
                }, onError: {(error) in
                    
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    print(error)
                })
                
            }
        }else{
            Constant.MyClassConstants.btnTag = sender.tag
            self.performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
        }
        
    }
    func unfavoriteButtonClicked(_ sender: UIButton){
        sender.isSelected = false
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
