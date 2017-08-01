//
//  UpComingTripDetailIPadViewController.swift
//  IntervalApp
//
//  Created by Chetu on 09/08/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import MessageUI
import SVProgressHUD

class UpComingTripDetailIPadViewController: UIViewController {
    
    var isOpen:Bool = false
    var detailsView:UIView?
    var unitDetialsCellHeight = 20
    var requiredRowsArray = NSMutableArray()
    var requiredRowsArrayRelinquishment = NSMutableArray()
    //***** Outlets *****//
    @IBOutlet weak var upcomingTripDetailTbleview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***** register GuestCertificateCell xib  with table *****//
        let cellNib1 = UINib(nibName:Constant.customCellNibNames.guestCertificateCell, bundle: nil)
        self.upcomingTripDetailTbleview!.register(cellNib1, forCellReuseIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
        
        //***** register PaymentCell xib  with table *****//
        let cellNib2 = UINib(nibName:Constant.customCellNibNames.paymentCell, bundle: nil)
        self.upcomingTripDetailTbleview!.register(cellNib2, forCellReuseIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.paymentDetailCell)
        
        self.title = Constant.ControllerTitles.upComingTripDetailController
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(UpComingTripDetailIPadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        let moreButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(UpComingTripDetailIPadViewController.moreButtonPressed(_:)))
        moreButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = moreButton
        
        self.requiredRowsForAdditionalProducts()
        self.requiredRowsForRelinquishment()
        
        
        // Omniture tracking with event 74
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar18 : "",
            //TODO (Jhon): error found in iPad with user bwilling
            //            Constant.omnitureEvars.eVar18 : Constant.MyClassConstants.upcomingOriginationPoint,
            Constant.omnitureEvars.eVar55 : ""
            
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event74, data: userInfo)
        
        
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
        }
    }
    
    //***** Action for left bar button item. *****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        if((self.navigationController?.viewControllers.count)! > 1){
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
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
        let viewMyRecentSearchAction: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.resendTitle, style: .default) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(viewMyRecentSearchAction)
         //***** Present ActivityViewController for share options *****//
        let shareAction: UIAlertAction = UIAlertAction(title: "Share", style: .default) { action -> Void in
            Constant.MyClassConstants.checkInClosestContentArray.removeAllObjects()
            Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
            
            let message = ShareActivityMessage()
            message.upcomingTripDetailsMessage()
            
            let shareActivityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            shareActivityViewController.completionWithItemsHandler = {(activityType, completed, returnItems, error) in
                if completed {
                    if activityType == UIActivityType.mail || activityType == UIActivityType.message {
                        //Display message to confirm Message and Mail have been sent
                        SimpleAlert.alert(self, title: "Success", message: "Your Confirmation has been sent!")
                    }
                }
                
                if error != nil {
                    if activityType == UIActivityType.mail || activityType == UIActivityType.message {
                        //Display message to let user know there was error
                        SimpleAlert.alert(self, title: "Error", message: "The Confirmation could not be sent. Please try again.")
                    }
                }
            }
            
            shareActivityViewController.popoverPresentationController?.sourceView = self.view
            shareActivityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width,y: 0, width: 100, height: 60)
            shareActivityViewController.popoverPresentationController!.permittedArrowDirections = .up;

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
        actionSheetController.popoverPresentationController?.sourceView = self.view
        actionSheetController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width,y: 0, width: 100, height: 60)
        actionSheetController.popoverPresentationController!.permittedArrowDirections = .up;
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    //***** Action for unit details toggle button *****//
    func toggleButtonPressed(_ sender:UIButton){
        if(isOpen == true){
            isOpen = false
        }else{
            isOpen = true
        }
        self.upcomingTripDetailTbleview.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPressMapDetailsButton() {
        guard let coordinates = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.coordinates else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.resortName else { return }
        guard let cityName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address?.cityName else { return }
        SVProgressHUD.show()
        displayMapView(coordinates: coordinates, resortName: resortName, cityName: cityName, presentModal: true) { (response) in
            SVProgressHUD.dismiss()
        }
    }
    
    func didPressWeatherDetailsButton() {
        guard let resortCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortCode else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.resortName else { return }
        guard let countryCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address?.countryCode else { return }
        SVProgressHUD.show()
        displayWeatherView(resortCode: resortCode, resortName: resortName, countryCode: countryCode, presentModal: true, completionHandler: { (response) in
            SVProgressHUD.dismiss()
        })
        
    }
}

//***** MARK: Extension classes starts from here *****//

extension UpComingTripDetailIPadViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section{
        case 0 :
            return 400
        case 1 :
            return 100
        case 2 :
            return 150
        case 3 :
            if((indexPath as NSIndexPath).row == 0){
                return 50
            }else{
                return CGFloat(unitDetialsCellHeight + 20)
            }
        case 4 :
            return 120
        case 5:
            return 120
        case 7 :
            return 200
        default :
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 3){
            
        }
    }
    
}

extension UpComingTripDetailIPadViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** Configuring prototype cell for UpComingtrip resort details *****//
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as! UpComingTripCell
            if (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil){
                cell.headerLabel.text = "Confirmation # \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber!)"
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
                    cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address?.cityName!
                    cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address?.countryCode!
                    //cell.bedRoomKitechenType.text =  "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.unitSize!) \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.kitchenType)!))"
                    
                    //cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.privateSleepCapacity) Private"
                    
                    /*let checkInDate = Helper.convertStringToDate(dateString:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
                     
                     let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                     let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                     
                     
                     let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.year!)"
                     
                     cell.checkInDateLabel.text = "\(myComponents.day!)"
                     if(cell.checkInDateLabel.text?.characters.count == 1){
                     cell.checkInDateLabel.text = "0\(myComponents.day!)"
                     }
                     cell.checkInMonthYearLabel.text = formatedCheckInDate
                     
                     let checkOutDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat1)
                     
                     let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                     
                     let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.year!)"
                     cell.checkOutDateLabel.text = "\(myComponents1.day!)"
                     if(cell.checkOutDateLabel.text?.characters.count == 1){
                     cell.checkOutDateLabel.text = "0\(myComponents1.day!)"
                     }
                     cell.checkOutMonthYearLabel.text = formatedCheckOutDate*/
                }
                cell.resortImageView.setImageWith(URL(string: resortImage.url!), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                
                //cell.transactionType.text = ExchangeTransactionType.fromName(name: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType!).friendlyNameForUpcomingTrip()
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor.clear
            cell.resortNameBaseView.backgroundColor = UIColor.clear
            cell.resortNameBaseView.frame = CGRect(x: 100, y: 0, width: 568, height: 100)
            
            for layer in cell.resortNameBaseView.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            
            cell.showMapDetailButton.addTarget(self, action: #selector(UpComingTripDetailIPadViewController.didPressMapDetailsButton), for: .touchUpInside)
            cell.showWeatherDetailButton.addTarget(self, action: #selector(UpComingTripDetailIPadViewController.didPressWeatherDetailsButton), for: .touchUpInside)
            
            return cell
        }else if((indexPath as NSIndexPath).section == 1) {
            
            //***** configuring prototype cell for unit details with dynamic button to shwo unit details *****//
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateCell, for: indexPath) as! UpComingTripCell
            
            let checkInDate = Helper.convertStringToDate(dateString:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
            
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
            
            
            let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.year!)"
            
            cell.checkInDateLabel.text = "\(myComponents.day!)"
            if(cell.checkInDateLabel.text?.characters.count == 1){
                cell.checkInDateLabel.text = "0\(myComponents.day!)"
            }
            cell.inDateHeading.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
            cell.checkInMonthYearLabel.text = formatedCheckInDate
            
            let checkOutDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat1)
            
            let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
            
            let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.year!)"
            cell.checkOutDateLabel.text = "\(myComponents1.day!)"
            if(cell.checkOutDateLabel.text?.characters.count == 1){
                cell.checkOutDateLabel.text = "0\(myComponents1.day!)"
            }
            cell.outDateHeading.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!))"
            cell.checkOutMonthYearLabel.text = formatedCheckOutDate
            
            
            return cell
            
        }else if((indexPath as NSIndexPath).section == 2) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitCell, for: indexPath) as! UpComingTripCell
            
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            
            
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil){
            }else{
                let unitsize = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.unitSize!
                print(unitsize)
                cell.bedRoomKitechenType.text =  "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.unitSize!) \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.kitchenType)!))"
                
                cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.privateSleepCapacity) Private"
            }
            return cell
        }else if((indexPath as NSIndexPath).section == 3) {
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitDetailCell, for: indexPath) as! UnitDetailCell
                
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                cell.toggleButton.addTarget(self, action: #selector(UpComingTripDetailIPadViewController.toggleButtonPressed(_:)), for: .touchUpInside)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.amenitiesCell, for: indexPath)
                
                
                if(self.detailsView == nil) {
                    cell.addSubview(self.getDetails())
                }
                return cell
            }
            
            
        }else if ((indexPath as NSIndexPath).section == 4){
            
            if(self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.resortCell)
                
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.resortCell, for: indexPath) as! UpComingTripCell
                cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.resort!.resortName
                cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit?.resort!.address!.cityName
                cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit?.resort!.address!.territoryCode
                
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                return cell
            }else if(self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.unitCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitCell, for: indexPath) as! UpComingTripCell
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let checkInDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.checkInDate!, format: Constant.MyClassConstants.dateFormat1)
                
                let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                cell.checkInDateLabel.text = "\(myComponents1.day!)"
                if(cell.checkInDateLabel.text?.characters.count == 1){
                    cell.checkInDateLabel.text = "0\(myComponents1.day!)"
                }
                cell.checkInDateLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(cell.checkInDateLabel.text!)"
                
                cell.checkInMonthYearLabel.text = String(describing:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.relinquishmentYear!)
                
                cell.resortFixedWeekLabel.text = Constant.getWeekNumber(weekType: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.weekNumber!)
                
                cell.bedRoomKitechenType.text =  "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.unitSize!) \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.kitchenType)!))"
                
                cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.unit!.privateSleepCapacity) Private"
                return cell
            }else if(self.requiredRowsArrayRelinquishment[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.availablePointCell, for: indexPath) as! AvailablePointCell
                cell.availablePointValueLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.pointsProgram!.pointsSpent!)"
                return cell
            }else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as! CustomTableViewCell
                
                return cell
                
            }
        }else if ((indexPath as NSIndexPath).section == 5) {
            if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
                
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GuestCertificate", for: indexPath) as! UpComingTripCell
                cell.resortNameLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts!.guestCertificate!.guest!.firstName!) \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts!.guestCertificate!.guest!.lastName!)"
                return cell
            }
            else if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell) {
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell, for: indexPath) as! EPlusTableViewCell
                
                return cell
            }
            else if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell, for: indexPath) as! CustomTableViewCell
                
                return cell
            }else if(self.requiredRowsArray[indexPath.row] as! String == Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell){
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell, for: indexPath) as! TransactionDetailsTableViewCell
                cell.travellingWithLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.adults) Adults"
                if((Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.children) > 0){
                    cell.travellingWithLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.adults) Adults, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.travelParty!.children) Children "
                }
                cell.cabinNumber.text = "\(String(describing: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.number))!"
                cell.cabinDetails.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise!.cabin!.details!
                cell.transactionDate.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.transactionDate!
                
                return cell
                
            }else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as! CustomTableViewCell
                
                return cell
                
            }
        }else if(indexPath.section == 6){
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.paymentDetailCell, for: indexPath) as! PaymentCell
            cell.depositLabel.text = "$\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment!.depositAmount!.amount)"
            cell.balanceDueLabel.text = "$\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment!.balanceDueAmount!.amount)"
            cell.balanceDueDateLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment!.balanceDueDate!
            return cell
        }else if(indexPath.section == 7){
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.policyCell, for: indexPath) as! PolicyCell
            let showPolicyButton : Bool? = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus?.purchased
            if let showPolicyButton = showPolicyButton, showPolicyButton {
                // Executes when booleanValue is true
                cell.purchasePolicyButton.isHidden = false
            }else{
                cell.purchasePolicyButton.isHidden = true
            }
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.bottomCell, for: indexPath)
            return cell
            
        }
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        let leftView = UIView(frame: CGRect(x: 100, y: 0, width: 1, height: 50))
        leftView.backgroundColor = UIColor.lightGray
        let rightView = UIView(frame: CGRect(x: self.view.bounds.width - 101, y: 0, width: 1, height: 50))
        rightView.backgroundColor = UIColor.lightGray
        let headerTextLabel = UILabel(frame: CGRect(x: 120, y: 5, width: self.view.bounds.width - 200, height: 50))
        headerView.addSubview(leftView)
        headerView.addSubview(rightView)
        
        if(section == 4) {
            
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
        
        if(section == 5) {
            
            if( self.requiredRowsArray.count > 0) {
                
                return 50
            }
            else {
                
                return 0
            }
        }else if(section == 4){
            
            if(requiredRowsArrayRelinquishment.count > 0) {
                
                return 50
            }
            else {
                
                return 0
            }
        }else{
            return 0
        }
    }
    
    func getDetails() -> UIView {
        
        let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit
        self.unitDetialsCellHeight = 20
        
        self.detailsView = UIView()
        for amunities in unitDetils!.amenities {
            
            let sectionLabel = UILabel(frame: CGRect(x: 120,y:Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 120), height: 20))
            
            sectionLabel.text = amunities.category!
            sectionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
            sectionLabel.textColor = UIColor.lightGray
            
            self.detailsView?.addSubview(sectionLabel)
            
            self.unitDetialsCellHeight = unitDetialsCellHeight + 30
            
            for details in amunities.details {
                
                
                let detailSectionLabel = UILabel(frame: CGRect(x: 120, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 120), height: 20))
                detailSectionLabel.text = details.section!
                detailSectionLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16.0)
                detailSectionLabel.sizeToFit()
                
                self.detailsView?.addSubview(detailSectionLabel)
                self.unitDetialsCellHeight = self.unitDetialsCellHeight + 20
                for desc in details.descriptions {
                    let detaildescLabel = UILabel(frame: CGRect(x: 120, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 120), height: 20))
                    detaildescLabel.text = desc
                    detaildescLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
                    detaildescLabel.sizeToFit()
                    self.detailsView?.addSubview(detaildescLabel)
                    self.unitDetialsCellHeight = unitDetialsCellHeight + 20
                    
                }
                
            }
            
        }
        detailsView?.frame = CGRect(x: 0, y: 20, width: Int(self.view.frame.size.width), height: self.unitDetialsCellHeight)
        
        return self.detailsView!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        switch section {
            
        case 0:
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil) {
                return 1
            }else{
                return 0
            }
            
        case 1:
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil) {
                return 1
            }else{
                return 0
            }
        case 2:
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil) {
                return 0
            }else{
                return 0
            }
        case 3:
            /*let cruiseInfo: String? = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.shipName
             guard let cruiseDetail = cruiseInfo, !cruiseDetail.isEmpty else {
             return 0
             }*/
            
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil){
                let cruiseInfo: String? = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.shipName
                guard let cruiseDetail = cruiseInfo, !cruiseDetail.isEmpty else {
                    return 0
                }
                
                
                let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.amenities
                if((unitDetils?.count)! > 0){
                    return 1
                }else{
                    return 0
                }
                
            }else{
                if let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.amenities{
                    if(isOpen){
                        return 2
                    }else{
                        return 1
                    }
                }else{
                    return 0
                }
            }
        case 4:
            return self.requiredRowsArrayRelinquishment.count
        case 5:
            return self.requiredRowsArray.count
        case 6:
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment != nil){
                return 1
            }else{
                return 0
            }
        case 7:
            return 1
        case 8:
            return 1
        default:
            return 0
        }
        
        //return 1
    }
}

extension UpComingTripDetailIPadViewController: MFMessageComposeViewControllerDelegate {
    
    func formatMessageforComposer() -> String {
        //format message to be sent for text and Email
        var message = ""
        var location = ""
        //confirmation Number
        if let confirmationNum = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber {
            message.append("Confirmation #: \(confirmationNum)\n")
        }
        //transaction Type
        let transactionType = ExchangeTransactionType.fromName(name: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType!).friendlyNameForUpcomingTrip()
        message.append("TransactionType: \(transactionType)\n")
        //Resort Name
        if let name = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.resortName {
            message.append("Resort: \(name)\n")
        }
        //city Name
        if let cityName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address!.cityName {
            location = "\(cityName), "
        }
        //Country Code
        if let countryCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.resort!.address!.countryCode {
            location.append("\(countryCode)")
        }
        message.append("Location: \(location)\n")
        
        //format checkIn Date
        let checkInDate = Helper.convertStringToDate(dateString:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
        let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!))/\(myComponents.day!)/\(myComponents.year!)"
        
        message.append("CheckIn: \(formatedCheckInDate)\n")
        
        //format CheckOut Date
        let checkOutDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat1)
        let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
        let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!))/\(myComponents1.day!)/\(myComponents1.year!)"
        message.append("CheckOut: \(formatedCheckOutDate)\n")
        
        return message
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //display alert message if message fails to be sent.
        switch result.rawValue {
        case MessageComposeResult.failed.rawValue:
            SimpleAlert.alert(self, title: "Error", message: "The text message could not be sent. Please try again.")
            break
        default:
            print("Text Result: \(result.rawValue)")
            break
        }
        
        //dissmis Text Composer
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension UpComingTripDetailIPadViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //display alert message if message fails to be sent.
        switch result.rawValue {
        case MFMailComposeResult.failed.rawValue:
            SimpleAlert.alert(self, title: "Error", message: "The Email could not be sent. Please try again.")
            break
        default:
            print("Email Result: \(result.rawValue)")
            break
        }
        
        //dissmis MailComposer
        self.dismiss(animated: true, completion: nil)
    }
}
