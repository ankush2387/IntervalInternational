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
    
    var isOpen: Bool = false
    var detailsView: UIView?
    var unitDetialsCellHeight = 20
    var requiredRowsArray = [String]()
    var requiredRowsArrayRelinquishment = [String]()
    //***** Outlets *****//
    @IBOutlet weak var upcomingTripDetailTbleview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNib()
        
        self.title = Constant.ControllerTitles.upComingTripDetailController
        
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(UpComingTripDetailIPadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MoreNav"), style: .plain, target: self, action: #selector(UpComingTripDetailIPadViewController.moreButtonPressed(_:)))
        moreButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = moreButton
        
        self.requiredRowsForAdditionalProducts()
        self.requiredRowsForRelinquishment()
        
    }
    
    func registerNib() {
        //***** register GuestCertificateCell xib  with table *****//
        let guestCertificateNib = UINib(nibName: Constant.customCellNibNames.guestCertificateCell, bundle: nil)
        upcomingTripDetailTbleview?.register(guestCertificateNib, forCellReuseIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
    }
    
    //***** Function to get dynamic rows for additional products section. ******//
    func requiredRowsForAdditionalProducts() {
        
        requiredRowsArray.removeAll()
        
        if let ancillaryProducts =  Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts {
            if let guest = ancillaryProducts.guestCertificate?.guest {
                requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell)
            }
            if let purchased = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus?.purchased {
                requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell)
            }
        
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance?.policyNumber != nil {
            
            requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell)
        } else if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance != nil && Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.insurance?.policyNumber == nil) {
            
            requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.purchasedInsuranceCell)
        } else if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise != nil) {
            requiredRowsArray.append(Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell)
        }
        }
    }
    
    //***** Function to get dynamic rows for relinquishment. *****//
    func requiredRowsForRelinquishment() {
        requiredRowsArrayRelinquishment.removeAll()
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit != nil {
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort != nil) {
                requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.resortCell)
            }
            if(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.unit != nil) {
                requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.unitCell)
            }
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.clubPoints != nil {
            requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.clubCell)
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.pointsProgram != nil {
            requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell)
        }
        if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.accommodationCertificate != nil {
            requiredRowsArrayRelinquishment.append(Constant.upComingTripDetailControllerReusableIdentifiers.accomodationCell)
        }
    }
    
    //***** Action for left bar button item. *****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        guard let controllersCount = navigationController?.viewControllers.count else { return }
        if controllersCount > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController else { return }
            
            //***** creating animation transition to show custom transition animation *****//
            let transition: CATransition = CATransition()
            let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.duration = 0.25
            transition.timingFunction = timeFunc
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    
    //***** Action for right bar button item. *****//
    func moreButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title: Constant.buttonTitles.optionTitle, message: "", preferredStyle: .actionSheet)
        
        //***** Create and add the View my recent search *****//
        let resendConfirmationAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.resendTitle, style: .default) { _ -> Void in
            Helper.resendConfirmationInfoForUpcomingTrip(viewcontroller: self)
        }
        actionSheetController.addAction(resendConfirmationAction)
        //***** Present ActivityViewController for share options *****//
        let shareAction: UIAlertAction = UIAlertAction(title: "Share", style: .default) { _ -> Void in
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
            
            shareActivityViewController.popoverPresentationController?.sourceView = self.view
            shareActivityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width, y: 0, width: 100, height: 60)
            shareActivityViewController.popoverPresentationController?.permittedArrowDirections = .up
            
            self.present(shareActivityViewController, animated: false, completion: nil)
            
        }
        actionSheetController.addAction(shareAction)
        
        //***** Purchase trip insurance *****//
        let insuranceAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.purchaseInsuranceTitle, style: .default) { _ -> Void in
        }
        actionSheetController.addAction(insuranceAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { _ -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        actionSheetController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width, y: 0, width: 100, height: 60)
        actionSheetController.popoverPresentationController?.permittedArrowDirections = .up
        
        //Present the AlertController
        present(actionSheetController, animated: true, completion: nil)
    }
    
    //***** Action for unit details toggle button *****//
    func toggleButtonPressed(_ sender: UIButton) {
        isOpen = !isOpen
        upcomingTripDetailTbleview.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPressMapDetailsButton() {
        guard let coordinates = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.coordinates else { return }
        guard let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName else { return }
        guard let cityName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.cityName else { return }
        showHudAsync()
        displayMapView(coordinates: coordinates, resortName: resortName, cityName: cityName, presentModal: true) { (_) in
            self.hideHudAsync()
        }
    }
    
    func didPressWeatherDetailsButton() {
        guard let resortCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortCode else { return }
        guard let resortCity = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.cityName else { return }
        guard let countryCode = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.countryCode else { return }
        showHudAsync()
        displayWeatherView(resortCode: resortCode, resortCity: resortCity, countryCode: countryCode, presentModal: true, completionHandler: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.hideHudAsync()
        })
        
    }
    
    // MARK: - Omniture Tracking
    
    func omnitureTrackingEvent74() {
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar18: "",
            //TODO (Jhon): error found in iPad with user bwilling
            //            Constant.omnitureEvars.eVar18 : Constant.MyClassConstants.upcomingOriginationPoint,
            Constant.omnitureEvars.eVar55: ""
            
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event74, data: userInfo)
    }
}

//***** MARK: Extension classes starts from here *****//

extension UpComingTripDetailIPadViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0 :
            return 400
        case 1 :
            return 100
        case 2 :
            return 150
        case 3 :
            if indexPath.row == 0 {
                return 50
            } else {
                return CGFloat(unitDetialsCellHeight + 20)
            }
        case 4 :
            return 120
        case 5:
            return 120
        case 6:
            return 176
        case 7 :
            return 200
        default :
            return 40
        }
    }
    
}

extension UpComingTripDetailIPadViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** Configuring prototype cell for UpComingtrip resort details *****//
        
        switch indexPath.section {
        case 0 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
            if let confirmationNumber = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber,
                let type = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.exchangeTransactionType {
                let transactionType = ExchangeTransactionType.fromName(name: type).friendlyNameForUpcomingTrip()
                
                cell.setConfirmationAndType(with: confirmationNumber, tripType: transactionType)
                
                var resortImage = Image()
                if let cruise = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise {
                    for largeResortImage in cruise.images where largeResortImage.size == Constant.MyClassConstants.imageSizeXL {
                            resortImage = largeResortImage
                    }
                    cell.resortNameLabel.text = cruise.shipName
                    cell.resortLocationLabel.text = cruise.tripName
                } else {
                    if let resortImages = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.images {
                        for largeResortImage in resortImages where largeResortImage.size == Constant.MyClassConstants.imageSizeXL {
                                resortImage = largeResortImage
                        }
                    }
                    cell.resortNameLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName ?? ""
                    cell.resortLocationLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.cityName ?? ""
                    cell.resortCodeLabel.text = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.countryCode ?? ""

                }
                
                if let url = resortImage.url {
                    cell.resortImageView.setImageWith(URL(string: url), completed: { (image:UIImage?, error:Error?, _:SDImageCacheType, _:URL?) in
                        if case .some = error {
                            cell.resortImageView.image = #imageLiteral(resourceName: "NoImageIcon")
                        }
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                } else {
                    cell.resortImageView.image = #imageLiteral(resourceName: "NoImageIcon")
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor.clear
            cell.resortNameBaseView.backgroundColor = UIColor.clear
            cell.resortNameBaseView.frame = CGRect(x: 100, y: 0, width: cell.frame.width - 200, height: 100)
            
            if let subViewsResortNameBaseView = cell.resortNameBaseView.layer.sublayers {
                for layer in subViewsResortNameBaseView {
                    if layer.isKind(of: CAGradientLayer.self) {
                        layer.removeFromSuperlayer()
                    }
                }
            }
            
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            
            cell.showMapDetailButton.addTarget(self, action: #selector(UpComingTripDetailIPadViewController.didPressMapDetailsButton), for: .touchUpInside)
            cell.showWeatherDetailButton.addTarget(self, action: #selector(UpComingTripDetailIPadViewController.didPressWeatherDetailsButton), for: .touchUpInside)
            
            return cell
        case 1 :
            
            //***** configuring prototype cell for unit details with dynamic button to shwo unit details *****//
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateCell, for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
            
            if let destination = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination {
                
                if let cruise = destination.cruise {
                    cell.setDateDetails(with: cruise.cabin?.sailingDate ?? "", checkOutDate: cruise.cabin?.returnDate ?? "")
                } else {
                    cell.setDateDetails(with: destination.unit?.checkInDate ?? "", checkOutDate: destination.unit?.checkOutDate ?? "")
                }
                
            }
            return cell
            
        case 2 :
            
            if let cruise = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell, for: indexPath) as? TransactionDetailsTableViewCell else { return UITableViewCell() }
                if let transactionDetails = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin {
                    cell.setTransactionDetails(with: transactionDetails)
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UnitCell", for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
                if let unitSize = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.unitSize,
                let kitchenType = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.kitchenType,
                let totalSleeps = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.publicSleepCapacity,
                let privateSleeps = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.privateSleepCapacity {
                let unit = (Helper.getBedroomNumbers(bedroomType: unitSize))
                let kitchen = Helper.getKitchenEnums(kitchenType: kitchenType)
                cell.bedRoomKitechenType.text =  "\(unit) \(kitchen)"
                cell.sleepsTotalOrPrivate.text = "Sleeps \(totalSleeps) total, \(privateSleeps) Private"
              
            }
                 return cell
            }
            
            case 3 :
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitDetailCell, for: indexPath) as? UnitDetailCell else { return UITableViewCell() }

                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                cell.toggleButton.addTarget(self, action: #selector(UpComingTripDetailIPadViewController.toggleButtonPressed(_:)), for: .touchUpInside)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.amenitiesCell, for: indexPath)
                
                if self.detailsView == nil {
                    cell.addSubview(self.getDetails())
                }
                return cell
            }
            
            case 4 :
            
            if requiredRowsArrayRelinquishment[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.resortCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.resortCell, for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
                cell.backgroundColor = IUIKColorPalette.contentBackground.color
                
                if let resortName = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort?.resortName {
                    cell.resortNameLabel.text = resortName
                }
                
                guard let address = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit?.resort?.address else { return cell }
                cell.resortLocationLabel.text = address.cityName
                cell.resortCodeLabel.text = address.territoryCode
                
                return cell
            } else if requiredRowsArrayRelinquishment[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.unitCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.unitCell, for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
                if let deposits = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.deposit {
                    cell.setDepositInformation(with: deposits)
                }
                return cell
            } else if requiredRowsArrayRelinquishment[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.pointsProgramCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.availablePointToolViewController.availablePointCell, for: indexPath) as? AvailablePointCell else { return UITableViewCell() }
                
                cell.availablePointValueLabel.text = "\(Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.relinquishment?.pointsProgram?.pointsSpent ?? 0)"
                return cell
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
                
                return cell
                
            }
            case 5 :
            if requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.guestCertificateCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "GuestCertificate", for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
                if let guestInfo = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.guestCertificate?.guest {
                    cell.setGuestDetails(with: guestInfo)
                }
                return cell
            } else if requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.insuranceCell, for: indexPath) as? EPlusTableViewCell else { return UITableViewCell() }
                
                return cell
            } else if requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.modifyInsuranceCell, for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
                
                return cell
            } else if requiredRowsArray[indexPath.row] == Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.transactionDetailsCell, for: indexPath) as? TransactionDetailsTableViewCell else { return UITableViewCell() }
                if let transactionDetails = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise?.cabin {
                    cell.setTransactionDetails(with: transactionDetails)
                }
                return cell
                
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.customTableViewCell, for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
                
                return cell
                
            }
            case 6 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.paymentDetailCell, for: indexPath) as? PaymentCell else { return UITableViewCell() }
            if let paymentInfo = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment {
                cell.setPayment(with: paymentInfo)
            }
            return cell
            case 7 :
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.policyCell, for: indexPath) as? PolicyCell else { return UITableViewCell() }
                if let showPolicyButton = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.ancillaryProducts?.eplus?.purchased {
                    cell.purchasePolicyButton.isHidden = !showPolicyButton
                }
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            return cell
        default :
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
        
        if section == 4 {
            
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.MyClassConstants.relinquishment
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        } else {
            headerView.backgroundColor = IUIKColorPalette.tertiary1.color
            headerTextLabel.text = Constant.UpComingTripHeaderCellSting.additionalProducts
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 4 :
            if !requiredRowsArrayRelinquishment.isEmpty {
                return 50
            } else {
                return 0
            }
        case 5 :
            if !requiredRowsArray.isEmpty {
                return 50
            } else {
                return 0
            }
        default :
            return 0
        }
    }
    
    func getDetails() -> UIView {
        guard let unitDetails = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit else { return UIView() }
        unitDetialsCellHeight = 20
        
        //sort array to show in this order: Sleeping, Bathroom, Kitchen and Other
        var sortedArrayAmenities = [InventoryUnitAmenity]()
        for am in unitDetails.amenities {
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
        for aminities in sortedArrayAmenities {
            
            let sectionLabel = UILabel(frame: CGRect(x: 120, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
            if let amenityCategory = aminities.category {
                sectionLabel.text = Helper.getMappedStringForDetailedHeaderSection(sectonHeader: amenityCategory)
            }
            sectionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
            sectionLabel.textColor = UIColor.lightGray
            
            self.detailsView?.addSubview(sectionLabel)
            
            self.unitDetialsCellHeight = unitDetialsCellHeight + 25
            
            for details in aminities.details {
                
                let detailSectionLabel = UILabel(frame: CGRect(x: 120, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
                detailSectionLabel.text = details.section?.capitalized
                detailSectionLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16.0)
                detailSectionLabel.sizeToFit()
                
                self.detailsView?.addSubview(detailSectionLabel)
                if let detailText = detailSectionLabel.text {
                    if !detailText.isEmpty {
                        self.unitDetialsCellHeight = self.unitDetialsCellHeight + 20
                    }
                }
                
                for desc in details.descriptions {
                    
                    let detaildescLabel = UILabel(frame: CGRect(x: 120, y: Int(unitDetialsCellHeight), width: Int(self.view.frame.width - 20), height: 20))
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
        
        return self.detailsView ?? UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        
        guard Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.confirmationNumber != nil else { return 0 }
        switch section {
            
        case 0:
            return 1
            
        case 1:
            return 1
            
        case 2:
            return 1
            
        case 3:
         if let cruiseInfo = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.cruise {
                guard let cruiseDetail = cruiseInfo.shipName, !cruiseDetail.isEmpty else {
                    return 0
                }
                
                if let unitDetails = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.amenities {
                    if !unitDetails.isEmpty {
                        return 1
                    } else {
                        return 0
                    }
                } else {
                    return 0
                }
                
            } else {
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.unit?.amenities != nil {
                    if isOpen {
                        return 2
                    } else {
                        return 1
                    }
                } else {
                    return 0
                }
            }
        case 4:
            return requiredRowsArrayRelinquishment.count
        case 5:
            return requiredRowsArray.count
        case 6:
            if Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.payment != nil {
                return 1
            } else {
                return 0
            }
        case 7:
            return 1
        case 8:
            return 1
        default:
            return 0
        }
    }
}

extension UpComingTripDetailIPadViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //display alert message if message fails to be sent.
        switch result.rawValue {
        case MessageComposeResult.failed.rawValue:
            self.presentAlert(with: "Error".localized(), message: "The text message could not be sent. Please try again.".localized())
            break
        default:
            intervalPrint("Text Result: \(result.rawValue)")
            break
        }
        
        //dissmis Text Composer
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension UpComingTripDetailIPadViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //display alert message if message fails to be sent.
        switch result.rawValue {
        case MFMailComposeResult.failed.rawValue:
            self.presentAlert(with: "Error".localized(), message: "The Email could not be sent. Please try again.".localized())
            break
        default:
            intervalPrint("Email Result: \(result.rawValue)")
            break
        }
        
        //dissmis MailComposer
        self.dismiss(animated: true, completion: nil)
    }
}
