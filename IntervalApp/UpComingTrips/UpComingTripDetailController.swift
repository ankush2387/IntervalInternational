//
//  UpComingTripDetailController.swift
//  IntervalApp
//
//  Created by Chetu on 29/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import MessageUI
import SVProgressHUD

class UpComingTripDetailController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var upcomingTripDetailTbleview: UITableView!
    var isOpen:Bool = false
    var requiredRowsArray = NSMutableArray()
    var requiredRowsArrayRelinquishment = NSMutableArray()
    var unitDetialsCellHeight = 50
    var detailsView:UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDetailsTable), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadTripDetailsNotification), object: nil)
        self.requiredRowsForAdditionalProducts()
        self.requiredRowsForRelinquishment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***** register UnitDetailCell xib cells  with table *****//
        let cellNib = UINib(nibName:Constant.customCellNibNames.unitDetailCell, bundle: nil)
        self.upcomingTripDetailTbleview!.register(cellNib, forCellReuseIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitDetailCell)
        
        //***** register GuestCertificateCell xib  with table *****//
        let cellNib1 = UINib(nibName:Constant.customCellNibNames.guestCertificateCell, bundle: nil)
        self.upcomingTripDetailTbleview!.register(cellNib1, forCellReuseIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
        
        //***** register PaymentCell xib  with table *****//
        let cellNib2 = UINib(nibName:Constant.customCellNibNames.paymentCell, bundle: nil)
        self.upcomingTripDetailTbleview!.register(cellNib2, forCellReuseIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.paymentDetailCell)
        
        //***** register PolicyCell xib  with table *****//
        let cellNib3 = UINib(nibName:Constant.customCellNibNames.policyCell, bundle: nil)
        self.upcomingTripDetailTbleview!.register(cellNib3, forCellReuseIdentifier:Constant.upComingTripDetailControllerReusableIdentifiers.policyCell)
        
        
        self.title = Constant.ControllerTitles.upComingTripDetailController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(UpComingTripDetailController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        let moreButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(UpComingTripDetailController.moreButtonPressed(_:)))
        moreButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = moreButton
        
        
        // Omniture tracking with event 74
        
       /*  let userInfo: [String: String] = [
            
            Constant.omnitureEvars.eVar55 : "\(getdatediffrence())",
            Constant.omnitureEvars.eVar56 : ""
            
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event74, data: userInfo) */
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Function to get dynamic rows for additional products section. ******//
    func requiredRowsForAdditionalProducts() {
        
        self.requiredRowsArray.removeAllObjects()
        
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.guestCertificate != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.guestCertificate?.guest != nil) {
            
            self.requiredRowsArray.add(Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
        }
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus?.purchased == true) {
            
            self.requiredRowsArray.add(Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell)
        }
        
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance?.policyNumber != nil) {
            
            self.requiredRowsArray.add(Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell)
        }
        else if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance?.policyNumber == nil){
            
            self.requiredRowsArray.add(Constant.upComingTripDetailControllerReusableIdentifiers.purchasedInsuranceCell)
        }else if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil){
            self.requiredRowsArray.add(Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell)
        }
    }
    
    //***** Function to get dynamic rows for relinquishment. *****//
    func requiredRowsForRelinquishment(){
        self.requiredRowsArrayRelinquishment.removeAllObjects()
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit != nil){
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort != nil){
                self.requiredRowsArrayRelinquishment.add(Constant.upComingTripDetailControllerReusableIdentifiers.resortCell)
            }
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit != nil){
                self.requiredRowsArrayRelinquishment.add(Constant.upComingTripDetailControllerReusableIdentifiers.unitCell)
            }
        }
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.clubPoints != nil){
            self.requiredRowsArrayRelinquishment.add(Constant.upComingTripDetailControllerReusableIdentifiers.clubCell)
        }
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.pointsProgram != nil){
            self.requiredRowsArrayRelinquishment.add(Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell)
        }
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate != nil){
            self.requiredRowsArrayRelinquishment.add(Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell)
            self.requiredRowsArrayRelinquishment.add(Constant.upComingTripDetailControllerReusableIdentifiers.unitCell)
        }
    }
    
    //***** Reload table when notification for details fire. ******//
    func reloadDetailsTable(){
        upcomingTripDetailTbleview.reloadData()
    }
    
    //***** Action for left bar button item. *****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        if((self.navigationController?.viewControllers.count)! > 1) {
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
            
            //***** creating animation transition to show custom transition animation *****//
            let transition: CATransition = CATransition()
            let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.duration = 0.25
            transition.timingFunction = timeFunc
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
    }
    
    //***** Action for right bar button item. *****//
    func moreButtonPressed(_ sender:UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.optionTitle, message: "", preferredStyle: .actionSheet)
        
        //***** Create and add the View my recent search *****//
        let resendConfirmationAction: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.resendTitle, style: .default) { action -> Void in
            Helper.resendConfirmationInfoForUpcomingTrip(viewcontroller: self)
        }
        actionSheetController.addAction(resendConfirmationAction)
        //***** Present ActivityViewController for share options *****//
        let shareAction: UIAlertAction = UIAlertAction(title: "Share", style: .default) { action -> Void in
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
            
            let message = ShareActivityMessage()
            message.upcomingTripDetailsMessage()
            
            let shareActivityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            shareActivityViewController.completionWithItemsHandler = {(activityType, completed, returnItems, error) in
                if completed {
                    if activityType == UIActivityType.mail || activityType == UIActivityType.message {
                        //Display message to confirm Message and Mail have been sent
                         self.presentAlert(with: "Success".localized(), message: "Your Confirmation has been sent!".localized())
                    }
                }
                
                if error != nil {
                    if activityType == UIActivityType.mail || activityType == UIActivityType.message {
                        //Display message to let user know there was error
                        self.presentAlert(with: "Error".localized(), message: "The Confirmation could not be sent. Please try again.".localized())
                    }
                }
                
            }
            self.present(shareActivityViewController, animated: false, completion: nil)

        }
        actionSheetController.addAction(shareAction)
        
        //***** Purchase trip insurance *****//
        let insuranceAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.purchaseInsuranceTitle, style: .default) { action -> Void in
        }
        actionSheetController.addAction(insuranceAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    //***** Action for unit details toggle button *****//
    func toggleButtonPressed(){
        if(isOpen == true){
            isOpen = false
        }else{
            isOpen = true
        }
        
        self.upcomingTripDetailTbleview.reloadSections(IndexSet(integer: 1), with:.automatic)
    }
    
    func showMapDetail() {
        guard let coordinates = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.coordinates else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.resortName else { return }
        guard let cityName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address?.cityName else { return }
        showHudAsync()
        displayMapView(coordinates: coordinates, resortName: resortName, cityName: cityName, presentModal: true) { (response) in
            self.hideHudAsync()
        }
        
    }
    
    func showWeatherDetail() {
        guard let resortCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortCode else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.resortName else { return }
        guard let countryCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address?.countryCode else { return }
        showHudAsync()
        displayWeatherView(resortCode: resortCode, resortName: resortName, countryCode: countryCode, presentModal: true, completionHandler: { (response) in
            self.hideHudAsync()
        })
    }
}

//***** MARK: Extension classes starts from here *****//

extension UpComingTripDetailController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0) {
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise == nil){
                return 532
            }else{
                return 428
            }
        }else if(indexPath.section == 1) {
            if(self.isOpen == false){
                return 50
            }else{
                return CGFloat(unitDetialsCellHeight + 20)
            }
        }else if(indexPath.section == 2) {
            return 72
        }else if(indexPath.section == 3) {
            if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell){
                return 50
            }else if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell){
                return 80
            }else{
                return 280
            }
        }else if(indexPath.section == 4){
            return 176
        }else {
            return 216
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 1:
            toggleButtonPressed()
        default: break
            
        }
    }
    
    
}

extension UpComingTripDetailController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** Configuring prototype cell for UpComingtrip resort details *****//
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as! UpComingTripCell
            if (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil){
                cell.headerLabel.text = "Confirmation #\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber!)"
            }
            
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil) {
                
                var resortImage = Image()
                if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil){
                    let resortImages = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.images
                    for largeResortImage in resortImages!{
                        if(largeResortImage.size == Constant.MyClassConstants.imageSizeXL){
                            resortImage = largeResortImage
                        }else{
                            resortImage = (resortImages?[0])!
                        }
                    }
                    
                    cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.shipName!
                    cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.tripName!
                    
                    let checkInDate = Helper.convertStringToDate(dateString:(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.sailingDate!)!, format: Constant.MyClassConstants.dateFormat)
                    
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    
                    cell.checkinDayLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                    let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.year!)"
                    
                    cell.checkInDateLabel.text = "\(myComponents.day!)"
                    if(cell.checkInDateLabel.text?.characters.count == 1){
                        cell.checkInDateLabel.text = "0\(myComponents.day!)"
                    }
                    cell.checkInMonthYearLabel.text = formatedCheckInDate
            
                    cell.inDateHeading.text = Constant.upComingTripDetailControllerReusableIdentifiers.inHeadingString
                    
                    let checkOutDate = Helper.convertStringToDate(dateString: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise?.cabin?.returnDate!)!, format: Constant.MyClassConstants.dateFormat1)
                    
                    let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                    cell.checkoutDayLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                    let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.year!)"
                    cell.checkOutDateLabel.text = "\(myComponents1.day!)"
                    if(cell.checkOutDateLabel.text?.characters.count == 1){
                        cell.checkOutDateLabel.text = "0\(myComponents1.day!)"
                    }
                    cell.checkOutMonthYearLabel.text = formatedCheckOutDate
                    cell.outDateHeading.text = Constant.upComingTripDetailControllerReusableIdentifiers.outHeadingString
                    
                    
                }else{
                    let resortImages = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.images
                    for largeResortImage in resortImages!{
                        if(largeResortImage.size == Constant.MyClassConstants.imageSizeXL){
                            resortImage = largeResortImage
                        }else{
                            resortImage = (resortImages?[0])!
                        }
                    }
                    
                    cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.resortName
                    cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address!.countryCode!
                    if let unitSize = UnitSize.fromFriendlyName(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.unitSize!) {
                        cell.bedRoomKitechenType.text =  "\(unitSize) \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.kitchenType)!))"
                    }
                    
                    cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.privateSleepCapacity) Private"
                    
                    let checkInDate = Helper.convertStringToDate(dateString:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
                    
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    
                    cell.checkinDayLabel.text = Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!)
                    let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.year!)"
                    
                    cell.checkInDateLabel.text = "\(myComponents.day!)"
                    if(cell.checkInDateLabel.text?.characters.count == 1){
                        cell.checkInDateLabel.text = "0\(myComponents.day!)"
                    }
                    cell.checkInMonthYearLabel.text = formatedCheckInDate
                    
                    let checkOutDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat1)
                    
                    let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                    cell.checkoutDayLabel.text = Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!)
                    let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.year!)"
                    cell.checkOutDateLabel.text = "\(myComponents1.day!)"
                    if(cell.checkOutDateLabel.text?.characters.count == 1){
                        cell.checkOutDateLabel.text = "0\(myComponents1.day!)"
                    }
                    cell.checkOutMonthYearLabel.text = formatedCheckOutDate
                }
                if let image = resortImage.url {
                    cell.resortImageView.setImageWith(URL(string: image), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                        if (error != nil) {
                            cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        }
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                }
            }
           // cell.transactionType.text = ExchangeTransactionType.fromName(name: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType!).friendlyNameForUpcomingTrip()
            
            cell.transactionType.text = Constant.MyClassConstants.transactionType
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor.clear
            cell.resortNameBaseView.backgroundColor = UIColor.clear
            
            for layer in cell.resortNameBaseView.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            
            cell.showMapDetailButton.addTarget(self, action: #selector(UpComingTripDetailController.showMapDetail), for: .touchUpInside)
            cell.showWeatherDetailButton.addTarget(self, action: #selector(UpComingTripDetailController.showWeatherDetail), for: .touchUpInside)
            guard let addressDetails = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address else {
                return cell
            }
            var resortAddress = ""
            if let city = addressDetails.cityName {
                resortAddress = "\(city)"
            }
            if let state = addressDetails.territoryCode {
                resortAddress = "\(resortAddress),\(state)"
            }
            if let country = addressDetails.countryCode {
                resortAddress = "\(resortAddress),\(country)"
            }
            cell.resortLocationLabel.text = resortAddress

            return cell
        } else if(indexPath.section == 1) {
            
            //***** Configuring prototype cell for unit details with dynamic button to shwo unit details *****//
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as! CustomTableViewCell
            
            if self.isOpen == true {
                if(self.detailsView == nil) {
                    cell.addSubview(self.getDetails())
                    self.upcomingTripDetailTbleview.reloadData()
                }
            }
            
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            let horizontalSeprator = UIView(frame: CGRect(x: 0, y: 49, width: cell.contentView.frame.size.width, height: 1))
            horizontalSeprator.backgroundColor = UIColor.lightGray
            cell.addSubview(horizontalSeprator)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
            
        } else if(indexPath.section == 2) {
            
            if (self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.resortCell)
                
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.resortCell, for: indexPath) as! UpComingTripCell
                cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.resort!.resortName
                cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit?.resort!.address!.cityName
                cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit?.resort!.address!.territoryCode
                
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                return cell
            } else if(self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.unitCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitCell, for: indexPath) as! UpComingTripCell
                if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate != nil) {
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let checkInDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.travelWindow!.fromDate!, format: Constant.MyClassConstants.dateFormat1)
                    
                    let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    cell.checkInDateLabel.text = "\(myComponents1.day!)"
                    if(cell.checkInDateLabel.text?.characters.count == 1) {
                        cell.checkInDateLabel.text = "0\(myComponents1.day!)"
                    }
                    cell.checkInDateLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(cell.checkInDateLabel.text!)"
                    
                    cell.checkInMonthYearLabel.text = "\(myComponents1.year!)"
                    
                    cell.resortFixedWeekLabel.text = ""
                    
                    cell.bedRoomKitechenType.text =  "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.unit!.unitSize!) \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.unit!.kitchenType)!))"
                    
                    cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.unit!.privateSleepCapacity) Private"
                } else {
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let checkInDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.checkInDate!, format: Constant.MyClassConstants.dateFormat1)
                    
                    let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    cell.checkInDateLabel.text = "\(myComponents1.day!)"
                    if (cell.checkInDateLabel.text?.characters.count == 1) {
                        cell.checkInDateLabel.text = "0\(myComponents1.day!)"
                    }
                    cell.checkInDateLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(cell.checkInDateLabel.text!)"
                    
                    cell.checkInMonthYearLabel.text = String(describing:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.relinquishmentYear!)
                    
                    cell.resortFixedWeekLabel.text = Constant.getWeekNumber(weekType: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.weekNumber!)
                    
                    cell.bedRoomKitechenType.text =  "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.unitSize!) \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.kitchenType)!))"
                    
                    cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.privateSleepCapacity) Private"
                }
                return cell
            } else if (self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.availablePointCell, for: indexPath) as! AvailablePointCell
                cell.availablePointValueLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.pointsProgram!.pointsSpent!)"
                return cell
            } else if (self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell, for: indexPath) as! CustomTableViewCell
                cell.accomodationCertificateNumber.text = "#\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.certificateNumber!)"
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as! CustomTableViewCell
                return cell
            }
        } else if indexPath.section == 3 {
            
            if (self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell) {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell, for: indexPath) as! GuestCertificateCell
                
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                return cell
            }
            else if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell) {
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell, for: indexPath) as! EPlusTableViewCell
                
                return cell
            }
            else if (self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell, for: indexPath) as! CustomTableViewCell
                
                return cell
            } else if (self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell) {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell, for: indexPath) as! TransactionDetailsTableViewCell
                cell.travellingWithLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.adults) Adults"
                if((Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.children) > 0){
                    cell.travellingWithLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.adults) Adults, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.children) Children "
                }
                cell.cabinNumber.text = "\(String(describing: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.number))!"
                cell.cabinDetails.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.details!
                cell.transactionDate.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.transactionDate!
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as! CustomTableViewCell
                
                return cell
                
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.paymentDetailsCell, for: indexPath) as! PaymentCell
            cell.depositLabel.text = "$\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment!.depositAmount!.amount)"
            cell.balanceDueLabel.text = "$\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment!.balanceDueAmount!.amount)"
            cell.balanceDueDateLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment!.balanceDueDate!
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.policyCell, for: indexPath) as! PolicyCell
            
            let showPolicyButton : Bool? = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus?.purchased
            if let showPolicyButton = showPolicyButton, showPolicyButton {
                // Executes when booleanValue is true
                cell.purchasePolicyButton.isHidden = false
            } else {
                cell.purchasePolicyButton.isHidden = true
            }
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let headerTextLabel = UILabel(frame: CGRect(x: 10, y: 5, width: self.view.bounds.width - 200, height: 40))
     
        
        if section == 2 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.relinquishment
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
        else {
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.UpComingTripHeaderCellSting.additionalProducts
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 5 {
            
            if self.requiredRowsArray.count > 0 {
                
                return 40
            }
            else {
                return 0
            }
        } else if section == 2 {
            
            if requiredRowsArrayRelinquishment.count > 0 {
                return 40
            }
            else {
                return 0
            }
        } else {
            return 0
        }
    }
 
    func getDetails() -> UIView {
        
        let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit
        self.unitDetialsCellHeight = 50
        
        //sort array to show in this order: Sleeping, Bathroom, Kitchen and Other
        var sortedArrayAmenities = [InventoryUnitAmenity]()
        for am in unitDetils!.amenities {
            if am.category == "OTHER_FACILITIES" {
                sortedArrayAmenities.insert(am, at: 0)
            } else if am.category == "BATHROOM_FACILITIES" {
                sortedArrayAmenities.insert(am, at: 0)
            } else if am.category == "SLEEPING_ACCOMMODATIONS" {
                sortedArrayAmenities.insert(am, at: 0)
            } else {
                sortedArrayAmenities.insert(am, at: 2)
            }
        }
        
        self.detailsView = UIView()
        for amunities in sortedArrayAmenities {
            
            let sectionLabel = UILabel(frame: CGRect(x: 20,y:Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
            
            sectionLabel.text = Helper.getMappedStringForDetailedHeaderSection(sectonHeader: amunities.category!)
            sectionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
            sectionLabel.textColor = UIColor.lightGray
            
            self.detailsView?.addSubview(sectionLabel)
            
            self.unitDetialsCellHeight = unitDetialsCellHeight + 25
            
            for details in amunities.details {
                
                
                let detailSectionLabel = UILabel(frame: CGRect(x: 20, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
                detailSectionLabel.text = details.section!.capitalized
                detailSectionLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16.0)
                detailSectionLabel.sizeToFit()
                
                self.detailsView?.addSubview(detailSectionLabel)
                if((detailSectionLabel.text?.characters.count)! > 0) {
                    self.unitDetialsCellHeight = self.unitDetialsCellHeight + 20
                }
                
                for desc in details.descriptions {
                    
                    let detaildescLabel = UILabel(frame: CGRect(x: 20, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
                    if sectionLabel.text == "Other Facilities" || sectionLabel.text == "Kitchen Facilities" {
                        detaildescLabel.text = "\u{2022} \(desc)"
                    } else {
                        detaildescLabel.text = desc
                    }
                    detaildescLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
                    detaildescLabel.sizeToFit()
                    self.detailsView?.addSubview(detaildescLabel)
                    self.unitDetialsCellHeight = self.unitDetialsCellHeight + 20
                }
                self.unitDetialsCellHeight = self.unitDetialsCellHeight + 20
            }
        }
        detailsView?.frame = CGRect(x: 0, y: 20, width: Int(self.view.frame.size.width), height: self.unitDetialsCellHeight)
        
        return self.detailsView!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil {
                return 1
            } else {
                return 0
            }
        } else if section == 1{
            
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil){
                let cruiseInfo: String? = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.shipName
                guard let cruiseDetail = cruiseInfo, !cruiseDetail.isEmpty else {
                    return 0
                }
                let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.amenities
                if ((unitDetils?.count)! > 0) {
                    return 1
                } else {
                    return 0
                }
                
            } else {
                let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.amenities
                if unitDetils != nil{
                    return 1
                } else {
                    return 0
                }
            }
        }else if section == 2 {
            return self.requiredRowsArrayRelinquishment.count
        } else if section == 3 {
            return self.requiredRowsArray.count
        } else if section == 4 {
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment != nil) {
                return 1
            } else {
                return 0
            }
            
        } else if section == 5 {
            return 1
        } else {
            return 0
        }
    }
    
    // *** Get date diffrence for between checkindate and current date to send with omniture events.
    func getdatediffrence()-> Int {
        var checkDate :Int = 0
        
        if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil) {
            
            if let sailingDate = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.sailingDate {
                // TODO(Jhon): Error, found nil
                checkDate  = Helper.getUpcommingcheckinDatesDiffrence(date: Helper.convertStringToDate(dateString:sailingDate, format: Constant.MyClassConstants.dateFormat))
            }
        }
            
        else {
            checkDate = Helper.getUpcommingcheckinDatesDiffrence(date: Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.accommodationCertificate!.travelWindow!.fromDate!, format: Constant.MyClassConstants.dateFormat1))
        }
        return checkDate
    }
}
