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
    var requiredRowsArray = [String]()
    var requiredRowsArrayRelinquishment = [String]()
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
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar55 : "\(getdatediffrence())",
            Constant.omnitureEvars.eVar56 : ""
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event74, data: userInfo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Function to get dynamic rows for additional products section. ******//
    func requiredRowsForAdditionalProducts() {
        
        self.requiredRowsArray.removeAll()
        
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.guestCertificate != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.guestCertificate?.guest != nil {
            
            self.requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus?.purchased == true {
            
            self.requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell)
        }
        
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance?.policyNumber != nil {
            
            self.requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell)
        }
        else if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance?.policyNumber == nil {
            
            self.requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.purchasedInsuranceCell)
        } else if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil {
            self.requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell)
        }
    }
    
    //***** Function to get dynamic rows for relinquishment. *****//
    func requiredRowsForRelinquishment(){
        self.requiredRowsArrayRelinquishment.removeAll()
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit != nil {
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort != nil {
                self.requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.resortCell)
            }
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit != nil {
                self.requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.unitCell)
            }
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.clubPoints != nil {
            self.requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.clubCell)
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.pointsProgram != nil {
                 self.requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell)
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate != nil {
               self.requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell)
               self.requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.unitCell)
            
        }
    }
    
    //***** Reload table when notification for details fire. ******//
    func reloadDetailsTable(){
        upcomingTripDetailTbleview.reloadData()
    }
    
    //***** Action for left bar button item. *****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        if let navigationCount = self.navigationController?.viewControllers.count {
            if navigationCount > 1 {
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
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
    func toggleButtonPressed() {
        if isOpen == true {
            isOpen = false
        } else {
            isOpen = true
        }
        
        self.upcomingTripDetailTbleview.reloadSections(IndexSet(integer: 1), with:.automatic)
    }
    
    func showMapDetail() {
        guard let coordinates = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.coordinates else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName else { return }
        guard let cityName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.cityName else { return }
        showHudAsync()
        displayMapView(coordinates: coordinates, resortName: resortName, cityName: cityName, presentModal: true) { (response) in
            self.hideHudAsync()
        }
        
    }
    
    func showWeatherDetail() {
        guard let resortCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortCode else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName else { return }
        guard let countryCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.countryCode else { return }
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
        
        if indexPath.section == 0 {
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise == nil {
                return 532
            } else {
                return 428
            }
        } else if indexPath.section == 1 {
            if self.isOpen == false {
                return 50
            } else {
                return CGFloat(unitDetialsCellHeight + 20)
            }
        } else if indexPath.section == 2 {
            return 72
        } else if indexPath.section == 3 {
            if self.requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell {
                return 50
            } else if self.requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell {
                return 80
            } else {
                return 280
            }
        } else if indexPath.section == 4 {
            return 176
        } else {
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
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as? UpComingTripCell else {
                
                return UITableViewCell()
            }

            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil {
                
                if let confirmationNumber = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber {
                    cell.headerLabel.text = "Confirmation #\(confirmationNumber)"
                }
                var resortImage = Image()
                if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil {
                    
                    if let resortImages = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.images {
                        
                        for largeResortImage in resortImages {
                            if largeResortImage.size == Constant.MyClassConstants.imageSizeXL {
                                resortImage = largeResortImage
                            } else {
                                resortImage = (resortImages[0])
                            }
                        }
                    }

                    cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.shipName
                    cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.tripName
                    
                    if let sailingDate = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.sailingDate {
                         let checkInDate = Helper.convertStringToDate(dateString:sailingDate, format: Constant.MyClassConstants.dateFormat)
                         let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                        
                         let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                        
                         if let day =  myComponents.day, let weekday = myComponents.weekday, let month = myComponents.month, let year = myComponents.year {
                            cell.checkinDayLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday))"
                            let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: month)). \(year)"
                            cell.checkInDateLabel.text = "\(day)"
                            
                            if cell.checkInDateLabel.text?.characters.count == 1 {
                                cell.checkInDateLabel.text = "0\(day)"
                            }
                            cell.checkInMonthYearLabel.text = formatedCheckInDate
                        }
                        
                        cell.inDateHeading.text = Constant.upComingTripDetailControllerReusableIdentifiers.inHeadingString
                        if let returnDate = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.cruise?.cabin?.returnDate {
                            let checkOutDate = Helper.convertStringToDate(dateString: returnDate, format: Constant.MyClassConstants.dateFormat1)
                            let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                            if let day = myComponents1.day, let weekday = myComponents1.weekday, let month = myComponents1.month, let year = myComponents1.year {
                                cell.checkoutDayLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday))"
                                let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: month)). \(year)"
                                cell.checkOutDateLabel.text = "\(day)"
                                if cell.checkOutDateLabel.text?.characters.count == 1 {
                                    cell.checkOutDateLabel.text = "0\(day)"
                                }
                                cell.checkOutMonthYearLabel.text = formatedCheckOutDate
                            }
                        }
                        cell.outDateHeading.text = Constant.upComingTripDetailControllerReusableIdentifiers.outHeadingString
                    }
                    
                } else {
                    
                    if let resortImages = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.images {
                        
                        for largeResortImage in resortImages{
                            if largeResortImage.size == Constant.MyClassConstants.imageSizeXL {
                                resortImage = largeResortImage
                            } else {
                                resortImage = (resortImages[0])
                            }
                        }
                    }
                    cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName
                    cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.countryCode
                    if let unitSize = UnitSize.fromFriendlyName(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.unitSize!) {
                        if let kitchenType = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.kitchenType {
                            
                           cell.bedRoomKitechenType.text =  "\(unitSize) \(Helper.getKitchenEnums(kitchenType: kitchenType))"
                        }
                    }
                    
                    cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.publicSleepCapacity) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.privateSleepCapacity) Private"
                    
                    let checkInDate = Helper.convertStringToDate(dateString:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
                    
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    
                    if let weekday = myComponents.weekday {
                        cell.checkinDayLabel.text = Helper.getWeekdayFromInt(weekDayNumber: weekday)
                    }
                    if let day = myComponents.day, let month = myComponents.month, let year = myComponents.year {
                        let formatedCheckInDate = "\(Helper.getMonthnameFromInt(monthNumber: month)). \(year)"
                        cell.checkInMonthYearLabel.text = formatedCheckInDate
                        cell.checkInDateLabel.text = "\(day)"
                        if cell.checkInDateLabel.text?.characters.count == 1 {
                            cell.checkInDateLabel.text = "0\(day)"
                        }
                    }
                    if let checkOutDate = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.checkOutDate {
                        let checkOutDate = Helper.convertStringToDate(dateString: checkOutDate, format: Constant.MyClassConstants.dateFormat1)
                        let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                        if let weekday = myComponents1.weekday {
                            cell.checkoutDayLabel.text = Helper.getWeekdayFromInt(weekDayNumber: weekday)
                        }
                        if let day = myComponents1.day, let month = myComponents1.month, let year = myComponents1.year {
                            let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: month)). \(year)"
                            cell.checkOutDateLabel.text = "\(day)"
                            if cell.checkOutDateLabel.text?.characters.count == 1 {
                                cell.checkOutDateLabel.text = "0\(day)"
                            }
                            cell.checkOutMonthYearLabel.text = formatedCheckOutDate
                        }
                    }
                }
                if let image = resortImage.url {
                    cell.resortImageView.setImageWith(URL(string: image), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                        if error != nil {
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
            
            for layer in cell.resortNameBaseView.layer.sublayers! {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            
            cell.showMapDetailButton.addTarget(self, action: #selector(UpComingTripDetailController.showMapDetail), for: .touchUpInside)
            cell.showWeatherDetailButton.addTarget(self, action: #selector(UpComingTripDetailController.showWeatherDetail), for: .touchUpInside)
            guard let addressDetails = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address else {
                return cell
            }
            
            var resortAddress = [String]()
            if let city = addressDetails.cityName {
                resortAddress.append(city)
            }
            if let state = addressDetails.territoryCode {
                resortAddress.append(state)
            }
            if let countryCode = addressDetails.countryCode {
                resortAddress.append(countryCode)
            }
            cell.resortLocationLabel.text = resortAddress.joined(separator: ",")

            return cell
        } else if indexPath.section == 1 {
            
            //***** Configuring prototype cell for unit details with dynamic button to shwo unit details *****//
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as? UpComingTripCell else {
                
                return UITableViewCell()
            }
            if self.isOpen == true {
                if self.detailsView == nil {
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
            
        } else if indexPath.section == 2 {
            
            if self.requiredRowsArrayRelinquishment[indexPath.row]  == Constant.upComingTripDetailControllerReusableIdentifiers.resortCell
                
            {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.resortCell, for: indexPath) as? UpComingTripCell else {
                    
                    return UITableViewCell()
                }
                cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort?.resortName
                cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort?.address?.cityName
                cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort?.address?.territoryCode
                
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                return cell
            } else if self.requiredRowsArrayRelinquishment[indexPath.row]  == Constant.upComingTripDetailControllerReusableIdentifiers.unitCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitCell, for: indexPath) as? UpComingTripCell else {
                    
                    return UITableViewCell()
                }
                if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate != nil {
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    if let fromDate = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.travelWindow?.fromDate {
                        
                        let checkInDate = Helper.convertStringToDate(dateString: fromDate, format: Constant.MyClassConstants.dateFormat1)
                        let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                        if let day = myComponents1.day, let month = myComponents1.month, let year = myComponents1.year {
                            cell.checkInDateLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(cell.checkInDateLabel.text))"
                            
                            cell.checkInMonthYearLabel.text = "\(year)"
                            cell.checkInDateLabel.text = "\(day)"
                            if cell.checkInDateLabel.text?.characters.count == 1 {
                                cell.checkInDateLabel.text = "0\(day)"
                            }
                        }
                        
                        cell.resortFixedWeekLabel.text = ""
                        
                    }
                    
                    if let unitSize = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.unit?.unitSize, let kitchen = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.unit?.kitchenType {
                         cell.bedRoomKitechenType.text =  "\(unitSize) \(Helper.getKitchenEnums(kitchenType: kitchen))"
                    }
                   
                    cell.sleepsTotalOrPrivate.text = "Sleeps \((Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.unit?.publicSleepCapacity) ?? 0) total, \((Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.unit?.privateSleepCapacity) ?? 0) Private"
                } else {
                    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let checkInDate = Helper.convertStringToDate(dateString: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment!.deposit!.checkInDate!, format: Constant.MyClassConstants.dateFormat1)
                    
                    let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    cell.checkInDateLabel.text = "\(myComponents1.day!)"
                    if cell.checkInDateLabel.text?.characters.count == 1 {
                        cell.checkInDateLabel.text = "0\(myComponents1.day!)"
                    }
                    cell.checkInDateLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(cell.checkInDateLabel.text!)"
                    
                    cell.checkInMonthYearLabel.text = String(describing:Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.relinquishmentYear ?? 0)
                    
                    cell.resortFixedWeekLabel.text = Constant.getWeekNumber(weekType: Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.weekNumber ?? "")
                    
                    cell.bedRoomKitechenType.text =  "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit?.unitSize ?? "") \(Helper.getKitchenEnums(kitchenType: (Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit?.kitchenType) ?? ""))"
                    
                    cell.sleepsTotalOrPrivate.text = "Sleeps \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit?.publicSleepCapacity ?? 0) total, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit?.privateSleepCapacity ?? 0) Private"
                }
                return cell
            } else if self.requiredRowsArrayRelinquishment[indexPath.row]  == Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier:  Constant.availablePointToolViewController.availablePointCell, for: indexPath) as? AvailablePointCell else {
                   
                    return UITableViewCell()
                }
                cell.availablePointValueLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.pointsProgram?.pointsSpent ?? 0)"
                return cell
            } else if self.requiredRowsArrayRelinquishment[indexPath.row]  == Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell, for: indexPath) as? CustomTableViewCell else {
                    
                    return UITableViewCell()
                }
                cell.accomodationCertificateNumber.text = "#\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.certificateNumber ?? 0)"
                return cell
                
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as? CustomTableViewCell else {
                    
                    return UITableViewCell()
                }
                return cell
            }
        } else if indexPath.section == 3 {
            
            if self.requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell, for: indexPath) as? GuestCertificateCell else {
                    
                    return UITableViewCell()
                }
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                return cell
            }
            else if self.requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell, for: indexPath) as? EPlusTableViewCell else {
                    
                    return UITableViewCell()
                }
                
                return cell
            }
            else if self.requiredRowsArray[indexPath.row]  == Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell, for: indexPath) as? CustomTableViewCell else {
                    
                    return UITableViewCell()
                }
                
                return cell
            } else if self.requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell, for: indexPath) as? TransactionDetailsTableViewCell else {
                    
                    return UITableViewCell()
                }
                cell.travellingWithLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise!.cabin?.travelParty?.adults ?? 0) Adults"
                if let childrenCount = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.travelParty?.children {
                    
                    if childrenCount > 0 {
                        cell.travellingWithLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.travelParty?.adults ?? Int(0.0)) Adults, \(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.travelParty?.children ?? Int(0.0)) Children "
                    }
                }
              
                cell.cabinNumber.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.number ?? "")"
                cell.cabinDetails.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.details
                cell.transactionDate.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.transactionDate
                
                return cell
                
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as? CustomTableViewCell else {
                    
                    return UITableViewCell()
                }
                return cell
                
            }
        } else if indexPath.section == 4 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.paymentDetailsCell, for: indexPath) as? PaymentCell else {
                
                return UITableViewCell()
            }
            cell.depositLabel.text = "$\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment?.depositAmount?.amount ?? 0.0)"
            cell.balanceDueLabel.text = "$\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment?.balanceDueAmount?.amount ?? 0.0)"
            cell.balanceDueDateLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment?.balanceDueDate
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.policyCell, for: indexPath) as? PolicyCell else {
                
                return UITableViewCell()
            }
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
        
        var sortedArrayAmenities = [InventoryUnitAmenity]()
        if let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit {
            self.unitDetialsCellHeight = 50
            
            //sort array to show in this order: Sleeping, Bathroom, Kitchen and Other
            for am in unitDetils.amenities {
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
        }
        self.detailsView = UIView()
        for amunities in sortedArrayAmenities {
            
            let sectionLabel = UILabel(frame: CGRect(x: 20,y:Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
            if let category =  amunities.category {
               sectionLabel.text = Helper.getMappedStringForDetailedHeaderSection(sectonHeader: category)
            }
            sectionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
            sectionLabel.textColor = UIColor.lightGray
            
            self.detailsView?.addSubview(sectionLabel)
            
            self.unitDetialsCellHeight = unitDetialsCellHeight + 25
            
            for details in amunities.details {
                
                let detailSectionLabel = UILabel(frame: CGRect(x: 20, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
                if let  section = details.section {
                   detailSectionLabel.text = section.capitalized
                }
                detailSectionLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16.0)
                detailSectionLabel.sizeToFit()
                
                self.detailsView?.addSubview(detailSectionLabel)
                if let detailString = detailSectionLabel.text {
                    if detailString.count > 0 {
                        self.unitDetialsCellHeight = self.unitDetialsCellHeight + 20
                    }
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
        if section == 0 {
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil {
                return 1
            } else {
                return 0
            }
        } else if section == 1{
            
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil {
                let cruiseInfo: String? = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.shipName
                guard let cruiseDetail = cruiseInfo, !cruiseDetail.isEmpty else {
                    return 0
                }
                let unitDetils = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination!.unit?.amenities
                if let unitDetails = unitDetils?.count {
                    if unitDetails > 0 {
                        return 1
                    } else {
                        return 0
                    }
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
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment != nil {
                return 1
            } else {
                return 0
            }
            
        } else if section == 5 {
            return 1
        } else {
            return 0
        }
        return 0
    }
    
    // *** Get date diffrence for between checkindate and current date to send with omniture events.
    func getdatediffrence()-> Int {
        var checkDate :Int = 0
        
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil {
            
            if let sailingDate = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin?.sailingDate {
                // TODO(Jhon): Error, found nil
                checkDate  = Helper.getUpcommingcheckinDatesDiffrence(date: Helper.convertStringToDate(dateString:sailingDate, format: Constant.MyClassConstants.dateFormat))
            }
        }
        else {
            if let fromDate =   Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate?.travelWindow?.fromDate {
                  checkDate = Helper.getUpcommingcheckinDatesDiffrence(date: Helper.convertStringToDate(dateString: fromDate, format: Constant.MyClassConstants.dateFormat1))
            }
          
        }
        return checkDate
    }
}
