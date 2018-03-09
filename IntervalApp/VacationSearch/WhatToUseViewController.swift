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

protocol WhoWillBeCheckInDelegate: class {
    func navigateToWhoWillBeCheckIn(renewalArray: [Renewal], selectedRow: Int, selectedRelinquishment: ExchangeRelinquishment)
}

class WhatToUseViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Delegate
    weak var delegate: WhoWillBeCheckInDelegate?
    
    // Class variables
    var isCheckedBox = false
    var showUpgrade = false
    var selectedUnitIndex = 0
    var selectedRow = -1
    var selectedRowSection = -1
    var showInfoIcon = false
    var hasbothSearchAvailability = true
    var currencyCode = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Get dynamic rows
        selectedRow = -1
        tableView.reloadData()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 75
        self.title = Constant.ControllerTitles.bookYourSelectionController
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action:#selector(AccomodationCertsDetailController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        guard let currencycode = Constant.MyClassConstants.selectedResort.inventory?.currencyCode else { return }
        let currencyHelper = CurrencyHelper()
        currencyCode = currencyHelper.getCurrencyFriendlySymbol(currencyCode: currencycode)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
        // self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkBoxPressed(_ sender: IUIKCheckbox) {
        
        Constant.MyClassConstants.searchBothExchange = true
        selectedRow = sender.tag
        selectedRowSection = sender.accessibilityElements?.first as? Int ?? 0
        let indexPath = NSIndexPath(row:selectedRow, section:selectedRowSection)
        tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
       
       if showInfoIcon {
            self.performSegue(withIdentifier: "pointsInfoSegue", sender: self)
        } else {
        
            //Exchange process request parameters
            showHudAsync()
            let processResort = ExchangeProcess()
            processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
            let processRequest = ExchangeProcessStartRequest()
            processRequest.destination = Constant.MyClassConstants.exchangeDestination
            processRequest.travelParty = Constant.MyClassConstants.travelPartyInfo
        
            let count = Constant.MyClassConstants.filterRelinquishments.count
            if count > 1 {
                if Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].openWeek != nil {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].openWeek?.relinquishmentId
                    
                } else if  Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].deposit != nil {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].deposit?.relinquishmentId
                    
                } else if  Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].clubPoints != nil  {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].clubPoints?.relinquishmentId
                    
                } else if Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].pointsProgram != nil {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1].pointsProgram?.relinquishmentId
                }
            } else {
                if Constant.MyClassConstants.filterRelinquishments[self.selectedRow].openWeek != nil {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].openWeek?.relinquishmentId
                    
                } else if  Constant.MyClassConstants.filterRelinquishments[self.selectedRow].deposit != nil {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].deposit?.relinquishmentId
                    
                } else if  Constant.MyClassConstants.filterRelinquishments[self.selectedRow].clubPoints != nil  {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].clubPoints?.relinquishmentId
                    
                } else if Constant.MyClassConstants.filterRelinquishments[self.selectedRow].pointsProgram != nil {
                    processRequest.relinquishmentId = Constant.MyClassConstants.filterRelinquishments[self.selectedRow].pointsProgram?.relinquishmentId
                }
            }
        
            ExchangeProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest, onSuccess: { [weak self] response in
                
                // store response
                Constant.MyClassConstants.exchangeProcessStartResponse = response
                
                let processResort = ExchangeProcess()
                processResort.processId = response.processId
                Constant.MyClassConstants.exchangeBookingLastStartedProcess = processResort
                Constant.MyClassConstants.exchangeProcessStartResponse = response
                Constant.MyClassConstants.exchangeViewResponse = response.view!
                Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
                Constant.MyClassConstants.onsiteArray.removeAllObjects()
                Constant.MyClassConstants.nearbyArray.removeAllObjects()
                
                if let exchangeFees = response.view?.fees {
                    Constant.MyClassConstants.exchangeFees = [exchangeFees]
                }
                if let resortAmenities = response.view?.destination?.resort?.amenities {
                    for amenity in resortAmenities {
                        if let amentityName = amenity.amenityName {
                            if amenity.nearby == false {
                                Constant.MyClassConstants.onsiteArray.add(amentityName)
                                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amentityName)
                                Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                            } else {
                                Constant.MyClassConstants.nearbyArray.add(amenity.amenityName!)
                                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName!)
                                Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                            }
                        }
                    }
                }
                
                // check force renewals here
                if let forceRenewals = Constant.MyClassConstants.exchangeProcessStartResponse.view?.forceRenewals {
                    
                    if Constant.RunningDevice.deviceIdiom == .phone {
                        
                        //self.dismiss(animated: true, completion: nil)
                        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        // Navigate to Renewals Screen
                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                        viewController.delegate = self
                        if let selectedRow = self?.selectedRow {
                            if Constant.MyClassConstants.filterRelinquishments.count > 1 {
                                viewController.filterRelinquishment = Constant.MyClassConstants.filterRelinquishments[selectedRow - 1]
                            } else {
                                viewController.filterRelinquishment = Constant.MyClassConstants.filterRelinquishments[selectedRow]
                            }
                        }
                        Constant.MyClassConstants.isFromWhatToUse = true
                        self?.present(viewController, animated:true)
                        
                        return
                    } else {
                        
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        // Navigate to Who Will Be Checking in Screen
                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as? RenewelViewController else { return }
                        viewController.delegate = self
                        Constant.MyClassConstants.isFromWhatToUse = true
                        self?.present(viewController, animated:true)
                        
                        return
                    }
                    
                } else {
                    
                    if Constant.RunningDevice.deviceIdiom == .phone {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInViewController") as? WhoWillBeCheckingInViewController else { return }
                        if let selectedRow = self?.selectedRow {
                            if count > 1 {
                                viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[selectedRow - 1]
                            } else {
                                viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[selectedRow]
                            }
                        }
                        
                        self?.isCheckedBox = false
                        self?.navigationController?.pushViewController(viewController, animated: true)
                        
                    } else {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInIPadViewController") as? WhoWillBeCheckingInIPadViewController else { return }
                        if let selectedRow = self?.selectedRow {
                            if Constant.MyClassConstants.filterRelinquishments.count > 1 {
                                viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[selectedRow - 1]
                            } else {
                                viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[selectedRow]
                            }
                        }
                        self?.isCheckedBox = false
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }, onError: { [weak self] error in
                self?.hideHudAsync()
                self?.selectedRow = -1
                self?.selectedRowSection = -1
                self?.tableView.reloadData()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
            })
        }
    }
    
    @IBAction func checkBoxGetawayPressed(_ sender: IUIKCheckbox) {
        
        Constant.MyClassConstants.searchBothExchange = false
        selectedRow = sender.tag
        selectedRowSection = sender.accessibilityElements?.first as? Int ?? 0
        
        let indexPath = NSIndexPath(row:selectedRow, section:selectedRowSection)
        tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
        
        showHudAsync()
        var inventoryDict = Inventory()
        inventoryDict = Constant.MyClassConstants.selectedResort.inventory!
        let invent = inventoryDict
        let units = invent.units
        Constant.MyClassConstants.inventoryPrice = invent.units[indexPath.item].prices
        
        let processResort = RentalProcess()
        processResort.holdUnitStartTimeInMillis = Constant.holdingTime
        
        let processRequest = RentalProcessStartRequest()
        processRequest.resort = Constant.MyClassConstants.selectedResort
        if Constant.MyClassConstants.selectedResort.allInclusive {
            Constant.MyClassConstants.hasAdditionalCharges = true
        } else {
            Constant.MyClassConstants.hasAdditionalCharges = false
        }
        processRequest.unit = units[indexPath.item]
        
        let processRequest1 = RentalProcessStartRequest.init(resortCode: Constant.MyClassConstants.selectedResort.resortCode!, checkInDate: invent.checkInDate!, checkOutDate: invent.checkOutDate!, unitSize: UnitSize(rawValue: units[indexPath.item].unitSize!)!, kitchenType: KitchenType(rawValue: units[indexPath.item].kitchenType!)!)
        RentalProcessClient.start(Session.sharedSession.userAccessToken, process: processResort, request: processRequest1, onSuccess: {(response) in
            
            self.hideHudAsync()
            let processResort = RentalProcess()
            processResort.processId = response.processId
            Constant.MyClassConstants.getawayBookingLastStartedProcess = processResort
            
            // store response
            Constant.MyClassConstants.processStartResponse = response
            
            self.hideHudAsync()
            Constant.MyClassConstants.viewResponse = response.view!
            Constant.MyClassConstants.rentalFees = [(response.view?.fees)!]
            Constant.MyClassConstants.guestCertificate = response.view?.fees?.guestCertificate
            Constant.MyClassConstants.onsiteArray.removeAllObjects()
            Constant.MyClassConstants.nearbyArray.removeAllObjects()
            
            for amenity in (response.view?.resort?.amenities)! {
                if amenity.nearby == false {
                    Constant.MyClassConstants.onsiteArray.add(amenity.amenityName ?? "")
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending(amenity.amenityName ?? "")
                    Constant.MyClassConstants.onsiteString = Constant.MyClassConstants.onsiteString.appending("\n")
                } else {
                    Constant.MyClassConstants.nearbyArray.add(amenity.amenityName ?? "")
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending(amenity.amenityName ?? "")
                    Constant.MyClassConstants.nearbyString = Constant.MyClassConstants.nearbyString.appending("\n")
                }
            }
            UserClient.updateSessionAndGetCurrentMembership(Session.sharedSession.userAccessToken, membershipNumber: Session.sharedSession.selectedMembership?.memberNumber ?? "", onSuccess: { membership in
                Session.sharedSession.selectedMembership = membership
                
                // Got an access token!  Save it for later use.
                self.hideHudAsync()
                Constant.MyClassConstants.membershipContactArray = membership.contacts!
                
                // check force renewals here
                let forceRenewals = Constant.MyClassConstants.processStartResponse.view?.forceRenewals
                
                if forceRenewals != nil {
                    
                    if Constant.RunningDevice.deviceIdiom == .phone {
                    
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        
                        // Navigate to Renewals Screen
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.RenewelViewController) as! RenewelViewController
                        viewController.delegate = self
                        Constant.MyClassConstants.isFromWhatToUse = true
                        self.present(viewController, animated:true, completion: nil)
                        
                        return
                    } else {
                        
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
                    
                } else {
                    if Constant.RunningDevice.deviceIdiom == .phone {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name:  Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInViewController) as! WhoWillBeCheckingInViewController
                        
                        let transitionManager = TransitionManager()
                        self.navigationController?.transitioningDelegate = transitionManager
                        self.navigationController!.pushViewController(viewController, animated: true)
                    } else {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.whoWillBeCheckingInIpadViewController) as? WhoWillBeCheckingInIPadViewController else { return }
                        
                        let transitionManager = TransitionManager()
                        self.navigationController?.transitioningDelegate = transitionManager
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    
                }
                
            }, onError: { [weak self] error in
                
                self?.hideHudAsync()
                self?.selectedRow = -1
                self?.selectedRowSection = -1
                self?.tableView.reloadData()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                
            })
            
        }, onError: { [weak self] error in
            
            self?.selectedRow = -1
            self?.selectedRowSection = -1
            self?.tableView.reloadData()
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
        
    }
    
    func pushLikeModalViewController(controller: UIViewController) {
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
        showHudAsync()
        if let resortCode = Constant.MyClassConstants.selectedResort.resortCode {
            Helper.getResortWithResortCode(code:resortCode, viewcontroller:self)
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "pointsInfoSegue", sender: nil)
    }
    
    func selectedRenewal(selectedRenewal: String, forceRenewals: ForceRenewals, filterRelinquishment: ExchangeRelinquishment) {
        var renewalArray = [Renewal]()
        renewalArray.removeAll()
        if selectedRenewal == "Core" {
            // Selected core renewal
            let lowestTerm = forceRenewals.products[0].term
            for renewal in forceRenewals.products where renewal.term == lowestTerm {
                let renewalItem = Renewal()
                renewalItem.id = renewal.id
                renewalArray.append(renewalItem)
                break
            }
        } else {
            // Selected non core renewal
            let lowestTerm = forceRenewals.crossSelling[0].term
            for renewal in forceRenewals.crossSelling where renewal.term == lowestTerm {
                let renewalItem = Renewal()
                renewalItem.id = renewal.id
                renewalArray.append(renewalItem)
                break
            }
        }
        
        // Selected single renewal from other options. Navigate to WhoWillBeCheckingIn screen
        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInViewController") as? WhoWillBeCheckingInViewController else { return }
        
        viewController.isFromRenewals = true
        viewController.renewalsArray = renewalArray
        viewController.filterRelinquishments = filterRelinquishment
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//***** MARK: Extension classes starts from here *****//

extension WhatToUseViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let checkBox = IUIKCheckbox()
        checkBox.tag = indexPath.row
        checkBox.accessibilityElements = [indexPath.section]
        
        if indexPath.section == 1 {
            self.checkBoxPressed(checkBox)
        } else if indexPath.section == 2 {
            self.checkBoxGetawayPressed(checkBox)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width - 30, height: 30))
        
        if section == 0 {
            return nil
        } else if section == 1 {
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerTextLabel.text = Constant.HeaderViewConstantStrings.exchange
            headerTextLabel.textColor = UIColor(red: 156.0/255.0, green: 156.0/255.0, blue: 162.0/255.0, alpha: 1.0)
            headerView.addSubview(headerTextLabel)
            
            return headerView
        } else {
            
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerTextLabel.text = Constant.HeaderViewConstantStrings.getaways
            headerTextLabel.textColor = UIColor(red: 156.0/255.0, green: 156.0/255.0, blue: 162.0/255.0, alpha: 1.0)
            headerView.addSubview(headerTextLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section != 0 {
            if section == 1 && Constant.MyClassConstants.filterRelinquishments.count == 0 {
                return 0
            } else if section == 2 && !hasbothSearchAvailability && Constant.MyClassConstants.filterRelinquishments.count > 0 {
                return 0
            }
            return 30
        } else {
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

extension WhatToUseViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == VacationSearchType.COMBINED {
            return 3
        } else {
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        let count = Constant.MyClassConstants.filterRelinquishments.count
        
        switch section {
        case 0:
            return 1
        case 1:
            if (Constant.MyClassConstants.initialVacationSearch.searchCriteria.searchType == .COMBINED && hasbothSearchAvailability) || count > 0 {
                return count > 1 ? count + 1 : count
            } else {
                return 0
            }
        case 2:
            if !hasbothSearchAvailability && count > 0 {
                return 0
            } else {
                return 1
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            
            //***** Configure and return cell according to sections in tableview *****//
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationResortDetailCell", for: indexPath) as? DestinationResortDetailCell else { return UITableViewCell() }
            
            cell.destinationImageView.image = #imageLiteral(resourceName: "RST_CO")
            
            if let resortName = Constant.MyClassConstants.selectedResort.resortName {
                cell.resortName.text = resortName
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        case 1 :
            
            let count = Constant.MyClassConstants.filterRelinquishments.count
            if count > 1 && indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "\(Constant.MyClassConstants.filterRelinquishments.count) of \(Constant.MyClassConstants.whatToTradeArray.count) relinquishments are available for Exchange".localized()
                cell.textLabel?.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
                cell.textLabel?.textColor = UIColor(red: 159.0/255.0, green: 159.0/255.0, blue: 163.0/255.0, alpha: 1.0)
                cell.textLabel?.textAlignment = .center
                return cell
            }
            let exchange = count > 1 ?
                Constant.MyClassConstants.filterRelinquishments[indexPath.row - 1] : Constant.MyClassConstants.filterRelinquishments[indexPath.row]
            if exchange.pointsProgram != nil {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeCell0", for: indexPath) as? AvailablePointCell else { return UITableViewCell() }
                
                cell.pointsInfoLabel.text = "Use Club Interval Gold Points".localized()
                cell.tag = indexPath.row
                cell.checkBOx.tag = indexPath.row
                cell.checkBOx.isUserInteractionEnabled = false
                cell.checkBOx.accessibilityElements = [indexPath.section]
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                
                //let availablePointsNumber = Constant.MyClassConstants.selectedExchangeCigPoints as NSNumber
                if let pointsCost = Constant.MyClassConstants.selectedExchangePointsCost, let availablePoints = numberFormatter.string(from: pointsCost) {
                    cell.availablePointValueLabel.text = "\(availablePoints)".localized()
                } else {
                    cell.availablePointValueLabel.text = "\(0)".localized()
                }
                
                if showInfoIcon {
                    cell.infoButton.isHidden = false
                    cell.checkBOx.isHidden = true
                } else {
                    cell.infoButton.isHidden = true
                    cell.checkBOx.isHidden = false
                }
                
                if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBOx.checked = true
                } else {
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBOx.checked = false
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
                
            } else if (exchange.clubPoints) != nil {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as? AvailablePointCell else { return UITableViewCell() }
                
                cell.tag = indexPath.row
                cell.checkBOx.tag = indexPath.row
                cell.checkBOx.isUserInteractionEnabled = false
                cell.pointsInfoLabel.text = exchange.clubPoints?.resort?.resortName
                
                guard let points = exchange.clubPoints?.pointsSpent else {
                    return cell
                }
                
                cell.availablePointValueLabel.text = String(points)
                
                cell.checkBOx.accessibilityElements = [indexPath.section]
                
                if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBOx.checked = true
                } else {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBOx.checked = false
                }
                cell.layer.cornerRadius = 7
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
                
            } else if (exchange.openWeek) != nil {
                
                if showUpgrade == true {
                    
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeCell2", for: indexPath) as? RelinquishmentSelectionOpenWeeksCellWithUpgrade else { return UITableViewCell() }
                    cell.tag = indexPath.row
                    cell.checkBox.tag = indexPath.row
                    cell.checkBox.accessibilityElements = [indexPath.section]
                    cell.checkBox.isUserInteractionEnabled = false
                    if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = UIColor.orange.cgColor
                        cell.checkBox.checked = true
                    } else {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                        cell.checkBox.checked = false
                    }
                    
                    cell.resortName.text = exchange.openWeek?.resort?.resortName ?? "".localized()
                    cell.yearLabel.text = "\(String(describing: exchange.openWeek?.relinquishmentYear ?? 0))".localized()
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: exchange.openWeek?.weekNumber ?? ""))".localized()
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:exchange.openWeek?.unit?.unitSize ?? ""))), \(Helper.getKitchenEnums(kitchenType:exchange.openWeek?.unit?.kitchenType ?? ""))".localized()
                    if let unit = exchange.openWeek?.unit {
                        cell.totalSleepAndPrivate.text = "Sleeps \(unit.publicSleepCapacity) total, \(unit.privateSleepCapacity) Private".localized()
                    }
                    guard let dateString = exchange.openWeek?.checkInDate else {
                        return cell
                    }
                    guard let date = dateString.dateFromString(for: Constant.MyClassConstants.dateFormat) else {
                        cell.dayAndDateLabel.text = nil
                        return cell
                    }
                    let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                    let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: date)
                    let day = myComponents.day ?? 0
                    var month = ""
                    if day < 10 {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) 0\(day)"
                    } else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) \(day)"
                    }
                    
                    cell.dayAndDateLabel.text = month.uppercased()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                } else {
                    
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as? RelinquishmentSelectionOpenWeeksCell else { return UITableViewCell() }
                    
                    cell.tag = indexPath.row
                    cell.checkBox.tag = indexPath.row
                    cell.checkBox.accessibilityElements = [indexPath.section]
                    if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = UIColor.orange.cgColor
                        cell.checkBox.checked = true
                    } else {
                        
                        cell.mainView.layer.cornerRadius = 7
                        cell.mainView.layer.borderWidth = 2
                        cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                        cell.checkBox.checked = false
                    }
                    
                    cell.resortName.text = exchange.openWeek?.resort?.resortName ?? ""
                    cell.yearLabel.text = "\(String(describing: exchange.openWeek?.relinquishmentYear ?? 0))".localized()
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: exchange.openWeek?.weekNumber ?? ""))".localized()
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:exchange.openWeek?.unit?.unitSize ?? ""))), \(Helper.getKitchenEnums(kitchenType:exchange.openWeek?.unit?.kitchenType ?? ""))".localized()
                    if let unit = exchange.openWeek?.unit {
                        cell.totalSleepAndPrivate.text = "Sleeps \(unit.publicSleepCapacity) total, \(unit.privateSleepCapacity) Private".localized()
                    }
                    
                    guard let dateString = exchange.openWeek?.checkInDate else {
                        return cell
                    }
                    guard let date = dateString.dateFromString(for: Constant.MyClassConstants.dateFormat) else {
                        cell.dayAndDateLabel.text = nil
                        return cell
                    }
                    let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                    let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: date)
                    let day = myComponents.day ?? 0
                    var month = ""
                    if day < 10 {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) 0\(day)"
                    } else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) \(day)"
                    }
                    
                    //display Promotion
                    if let promotion = exchange.openWeek?.promotion {
                        cell.promLabel.text = promotion.offerName
                        cell.promImgView.image = UIImage(named: "PromoImage")
                    } else {
                        cell.promLabel.text = ""
                        cell.promImgView.image = nil
                    }
                    cell.dayAndDateLabel.text = month.uppercased()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
            } else if let deposits = exchange.deposit {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                cell.tag = indexPath.row
                cell.setupDepositedCell(deposit: deposits)
                
                if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBox.checked = true
                } else {
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBox.checked = false
                }
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! AvailablePointCell
                
                cell.tag = indexPath.row
                cell.checkBOx.tag = indexPath.row
                cell.checkBOx.accessibilityElements = [indexPath.section]
                cell.checkBOx.isUserInteractionEnabled = false
                
                cell.availablePointValueLabel.text = ""
                
                if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = UIColor.orange.cgColor
                    cell.checkBOx.checked = true
                } else {
                    
                    cell.mainView.layer.cornerRadius = 7
                    cell.mainView.layer.borderWidth = 2
                    cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                    cell.checkBOx.checked = false
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        default :
            
            //***** Configure and return search vacation cell *****//
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GetawaysCell", for: indexPath) as? GetawayCell else { return UITableViewCell() }
            cell.tag = indexPath.row
            cell.checkbox.tag = indexPath.row
            cell.checkbox.accessibilityElements = [indexPath.section]
            if self.selectedRow == indexPath.row && self.selectedRowSection == indexPath.section {
                
                cell.mainView.layer.cornerRadius = 7
                cell.mainView.layer.borderWidth = 2
                cell.mainView.layer.borderColor = UIColor.orange.cgColor
                cell.checkbox.checked = true
            } else {
                cell.mainView.layer.cornerRadius = 7
                cell.mainView.layer.borderWidth = 2
                cell.mainView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                cell.checkbox.checked = false
            }
            
            cell.bedRoomType.text = Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].unitSize
            
            if let roomSize = (Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].unitSize) {
                cell.bedRoomType.text = Helper.getBrEnums(brType: UnitSize(rawValue: roomSize)!.rawValue)
            }
            
            if let kitchenSize = (Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].kitchenType) {
                let kitchenType = KitchenType(rawValue: kitchenSize)
                cell.kitchenType.text = Helper.getKitchenEnums(kitchenType: kitchenType!.rawValue)
            }
            
            if let publicSleep = Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].publicSleepCapacity {
                
                if let privateSleep = Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].privateSleepCapacity {
                    cell.sleeps.text = "\(publicSleep) Total, \(privateSleep) Private".localized()
                }
            }
            if let price = Constant.MyClassConstants.selectedResort.inventory?.units[Constant.MyClassConstants.selectedUnitIndex].prices[0].price {
                cell.setGetawayPrice(with: currencyCode, and: price)
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        }
    }
}

// MARK : - Delegate Methods

// Implementing custom delegate method definition
extension WhatToUseViewController: RenewelViewControllerDelegate {
    
    func selectedRenewalFromWhoWillBeCheckingIn(renewalArray: [Renewal], selectedRelinquishment: ExchangeRelinquishment) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInViewController") as? WhoWillBeCheckingInViewController else { return }
        if Constant.MyClassConstants.filterRelinquishments.count > 1 {
            viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1]
        } else {
             viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[self.selectedRow]
        }
        viewController.renewalsArray = renewalArray
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func noThanks() {
        self.dismiss(animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WhoWillBeCheckingInViewController") as? WhoWillBeCheckingInViewController else { return }
        if Constant.MyClassConstants.filterRelinquishments.count > 1 {
            viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[self.selectedRow - 1]
        } else {
            viewController.filterRelinquishments = Constant.MyClassConstants.filterRelinquishments[self.selectedRow]
        }
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func dismissWhatToUse(renewalArray: [Renewal]) {
        self.dismiss(animated: true, completion: nil)
        if Constant.MyClassConstants.filterRelinquishments.count > 1 {
            self.delegate?.navigateToWhoWillBeCheckIn(renewalArray: renewalArray, selectedRow: self.selectedRow, selectedRelinquishment: Constant.MyClassConstants.filterRelinquishments[selectedRow - 1])
        } else {
            self.delegate?.navigateToWhoWillBeCheckIn(renewalArray: renewalArray, selectedRow: self.selectedRow, selectedRelinquishment: Constant.MyClassConstants.filterRelinquishments[selectedRow])
        }
    }
    
    func otherOptions(forceRenewals: ForceRenewals) {
        
        intervalPrint("other options")
        if Constant.RunningDevice.deviceIdiom == .phone {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RenewalOtherOptionsVC") as? RenewalOtherOptionsVC else { return }
            viewController.selectAction = { [weak self] (selectedType, renewal, relinquishment) in
                self?.selectedRenewal(selectedRenewal: selectedType, forceRenewals: renewal, filterRelinquishment: relinquishment)
            }
            viewController.forceRenewals = forceRenewals
            if Constant.MyClassConstants.filterRelinquishments.count > 1 {
                viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[selectedRow - 1]
            } else {
                viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[selectedRow]
            }
            self.present(viewController, animated:true, completion: nil)
            return
            
        } else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RenewalOtherOptionsVC") as? RenewalOtherOptionsVC else { return }
            viewController.selectAction = { [weak self] (selectedType, renewal, relinquishment) in
                self?.selectedRenewal(selectedRenewal: selectedType, forceRenewals: renewal, filterRelinquishment: relinquishment)
            }
            viewController.forceRenewals = forceRenewals
            if Constant.MyClassConstants.filterRelinquishments.count > 1 {
                viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[selectedRow - 1]
            } else {
                viewController.selectedRelinquishment = Constant.MyClassConstants.filterRelinquishments[selectedRow]
            }
            self.present(viewController, animated:true)
            return
            
        }
    }
}
