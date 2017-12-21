//
//  CreateAlertViewController.swift
//  IntervalApp
//
//  Created by Chetu on 18/08/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class CreateAlertViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var createAlertCollectionView: UICollectionView!
    @IBOutlet weak var textfieldBorderView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var createAlertTBLView: UITableView!
    
    //***** start date labels outlets *****//
    @IBOutlet weak var startDateDayLabel: UILabel!
    @IBOutlet weak var startDateMonthYearLabel: UILabel!
    @IBOutlet weak var startDateDayNameLabel: UILabel!
    
    //***** end date labels outlets *****//
    @IBOutlet weak var endDateDayLabel: UILabel!
    @IBOutlet weak var endDateMonthYearLabel: UILabel!
    @IBOutlet weak var endDateDayNameLabel: UILabel!
    
    //***** Bedroom size labels outlets *****//
    @IBOutlet weak var bedroomSize: UILabel!
    
    //***** Bedroom size window end date selection button outlet *****//
    @IBOutlet weak var travelWindowEndDateSelectionButton: UIButton!
    //***** Constraints outlets *****//
    @IBOutlet weak var leadingStartLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingStartDateConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingEndLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingEndDateConstraint: NSLayoutConstraint!
    
    var selectedIndex: Int = -1
    var anlyticsBedroomSize: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set return key on Keyboard to DONE
        nameTextField.returnKeyType = .done
        
        //Omniture Tracking
        omnitureTrackEvent40()
        omnitureTrackEvent50()
        
        //**** Check for iPhone 4s and iPhone 5s to align travel window start and end date *****//
        if UIScreen.main.bounds.width == 320 {
            leadingStartDateConstraint.constant = 0
            leadingStartLabelConstraint.constant = 0
            leadingEndDateConstraint.constant = 0
            leadingEndLabelConstraint.constant = 0
            
        }
        title = Constant.ControllerTitles.creategetawayAlertsViewController
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
        Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.bedroomSizes
        Constant.MyClassConstants.vacationSearchShowDate = Date()
        Constant.MyClassConstants.alertWindowStartDate = nil
        Constant.MyClassConstants.alertWindowEndDate = nil
        
        //***** adding menu bar back button *****//
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(menuBackButtonPressed(sender:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.textfieldBorderView.layer.cornerRadius = 7
        self.textfieldBorderView.layer.borderWidth = 2
        self.textfieldBorderView.layer.borderColor = Constant.RGBColorCode.textFieldBorderRGB
        self.nameTextField.delegate = self
        
        guard let iPadFont = UIFont(name: Constant.fontName.helveticaNeueBold, size: 25) else { return }
        var attributes = [
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSFontAttributeName: iPadFont
        ]
        
        if Constant.RunningDevice.deviceIdiom == .phone {
            guard let iPhoneFont = UIFont(name: Constant.fontName.helveticaNeueBold, size: 15) else { return }
            attributes = [
                NSForegroundColorAttributeName: UIColor.lightGray,
                NSFontAttributeName: iPhoneFont
            ]
            
        }
        
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: Constant.textFieldTitles.alertNamePlaceholder, attributes: attributes)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.bedroomSize.text = Constant.MyClassConstants.selectedBedRoomSize
        guard let startDate = Constant.MyClassConstants.alertWindowStartDate else {
            self.travelWindowEndDateSelectionButton.isEnabled = false
            reloadView()
            return
        }
        
        let endDate = Constant.MyClassConstants.alertWindowEndDate ?? Date()
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let startDateComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: startDate)
        let endDateComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: endDate)
        
        self.travelWindowEndDateSelectionButton.isEnabled = true
        if let day = startDateComponents.day {
            self.startDateDayLabel.text = String(describing: day)
        }
        
        if let weekDay = startDateComponents.weekday {
            self.startDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))"
        }
        
        if let month = startDateComponents.month, let year = startDateComponents.year {
            self.startDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
        }
        
        if startDate.isLessThanDate(endDate) {
            if let day = endDateComponents.day {
                self.endDateDayLabel.text = String(describing: day)
            }
            if let weekDay = endDateComponents.weekday {
                self.endDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))"
            }
            if let month = endDateComponents.month, let year = endDateComponents.year {
                self.endDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
            }
        } else {
            if let day = startDateComponents.day {
                self.endDateDayLabel.text = String(describing: day)
            }
            if let weekDay = startDateComponents.weekday {
                self.endDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))"
            }
            if let month = startDateComponents.month, let year = startDateComponents.year {
                self.endDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
            }
        }
        reloadView()
    }
    
    private func reloadView() {
        if case .some = createAlertCollectionView {
            createAlertCollectionView.reloadData()
        } else {
            self.createAlertTBLView.reloadData()
        }
    }
    
    //***** function to present modalview controller of selected resort detail screen *****//
    func detailButtonPressed(sender: UIButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as? InfoDetailViewController {
            viewController.selectedIndex = self.selectedIndex
            navigationController?.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    //***** function to create new alert *****//
    @IBAction func createAlertButtonPresseded(_ sender: AnyObject) {
        
        let trimmedUsername = self.nameTextField.text?.trimmingCharacters(in: .whitespaces)
        guard let startDate = Constant.MyClassConstants.alertWindowStartDate else { return  presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
            .editAlertEmptyWidowStartDateMessage) }
        guard let endDate = Constant.MyClassConstants.alertWindowEndDate else { return presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
            .editAlertEmptyWidowEndDateMessage) }
        if !Constant.MyClassConstants.selectedGetawayAlertDestinationArray.isEmpty {
            if let alertName = trimmedUsername {
                
                showHudAsync()
                let rentalAlert = RentalAlert()
                rentalAlert.earliestCheckInDate = Helper.convertDateToString(date: startDate, format: Constant.MyClassConstants.dateFormat)
                rentalAlert.latestCheckInDate = Helper.convertDateToString(date: endDate, format: Constant.MyClassConstants.dateFormat)
                
                rentalAlert.name = alertName
                rentalAlert.enabled = true
                intervalPrint(Constant.MyClassConstants.alertSelectedResorts)
                rentalAlert.resorts = Constant.MyClassConstants.alertSelectedResorts
                rentalAlert.destinations = Constant.MyClassConstants.alertSelectedDestination
                rentalAlert.selections = []
                
                var unitsizearray = [UnitSize]()
                if !Constant.MyClassConstants.alertSelectedUnitSizeArray.isEmpty {
                    
                    for selectedSize in Constant.MyClassConstants.alertSelectedUnitSizeArray {
                        
                        let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: selectedSize)
                        self.anlyticsBedroomSize = self.anlyticsBedroomSize.appending(bedroomSize)
                        if let selectedUnitSize = UnitSize(rawValue: selectedSize) {
                            unitsizearray.append(selectedUnitSize)
                        }
                    }
                    rentalAlert.unitSizes = unitsizearray
                } else {
                    
                    for unitsize in Constant.MyClassConstants.bedRoomSize {
                        let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: unitsize )
                        self.anlyticsBedroomSize = self.anlyticsBedroomSize.appending("\(bedroomSize), ")
                        if let selectedUnitSize = UnitSize(rawValue: unitsize ) {
                            unitsizearray.append(selectedUnitSize)
                        }
                    }
                    rentalAlert.unitSizes = unitsizearray
                }
                
                RentalClient.createAlert(Session.sharedSession.userAccessToken, alert: rentalAlert, onSuccess: { response in
                    self.omintureTrackEvent52(startDate:startDate, endDate:endDate)
                    self.hideHudAsync()
                    let rentalSearchDateResponse = RentalSearchDatesResponse()
                    Constant.MyClassConstants.searchDateResponse.append((rentalAlert, rentalSearchDateResponse))
                    self.presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages.createAlertMessage, hideCancelButton: true, cancelButtonTitle: "", acceptButtonTitle: "Ok".localized(), acceptButtonStyle: .default, cancelHandler: nil, acceptHandler: {
                        Constant.needToReloadAlert = true
                        self.dismiss(animated: true, completion: nil)
                    })
                    rentalAlert.alertId = response.alertId
                    
                }) { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.serverError(error))
                }
            } else {
                presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
                    .editAlertEmptyNameMessage)
            }
        } else {
            self.presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages.editAlertdetinationrequiredMessage)
        }
        
    }
    
    //***** function to dismiss present view controller on back button pressed *****//
    func menuBackButtonPressed(sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    //***** function to call calendar screen to select travel start date *****//
    @IBAction func travelStartDateCalendarIconPressed(_ sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as? CalendarViewController {
            viewController.requestedDateWindow = Constant.MyClassConstants.start
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    //***** function to call calendar screen to select travel end date *****//
    @IBAction func travelEndDateCalendarIconPressed(_ sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as? CalendarViewController {
            viewController.requestedDateWindow = Constant.MyClassConstants.end
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //***** function to call bedroom size screen to select bedroom size *****//
    @IBAction func selectRoomSizePressed(_ sender: AnyObject) {
        
        Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.createAlertViewController
        let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BedroomSizeNav") as? UINavigationController {
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            navigationController?.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    //***** function to call search destination  screen to search destination by name *****//
    @IBAction func addLocationPressed(_ sender: IUIKButton) {
        
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.createAlert
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.iphone : Constant.storyboardNames.resortDirectoryIpad
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as? GoogleMapViewController {
            viewController.sourceController = Constant.MyClassConstants.createAlert
            let transitionManager = TransitionManager()
            navigationController?.transitioningDelegate = transitionManager
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    // MARK: - Omniture Tracking functions
    
    //Function to track event 40
    func omnitureTrackEvent40() {
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.createAnAlert
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
    }
    
    //Function to track event 50
    func omnitureTrackEvent50() {
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.alert
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event50, data: userInfo)
    }
    
    //Function to track event 52
    func omintureTrackEvent52(startDate: Date, endDate: Date) {
        let userInfo: [String: Any] = [
            Constant.omnitureEvars.eVar43: " - \(Date())",
            Constant.omnitureCommonString.listItem: Constant.MyClassConstants.alertSelectedDestination,
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.alert,
            Constant.omnitureEvars.eVar57: startDate,
            Constant.omnitureEvars.eVar58: endDate,
            Constant.omnitureEvars.eVar59: self.anlyticsBedroomSize,
            Constant.omnitureEvars.eVar60: Constant.MyClassConstants.alertOriginationPoint
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event52, data: userInfo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//***** extensiion class to define tableview delegate methods *****//
extension CreateAlertViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

//***** extensiion class to define collectionview delegate methods *****//
extension CreateAlertViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == selectedIndex {
            selectedIndex = -1
            collectionView.reloadData()
        } else {
            self.selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    
}

extension CreateAlertViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.wereToGoTableViewCell, for: indexPath as IndexPath) as? WhereToGoCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.row == selectedIndex {
            
            switch Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] {
            case .resorts(_):
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = false
                
            case .resort(_):
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = true
                
            case .destination(_):
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = true
                
            }
        } else {
            
            cell.deletebutton.isHidden = true
            cell.infobutton.isHidden = true
        }
        
        switch Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] {
        case .resort( let resort):
            
            var resortNm = ""
            var resortCode = ""
            if let restName = resort.resortName {
                resortNm = restName
            }
            if let restcode = resort.resortCode {
                resortCode = restcode
            }
            cell.lblTitle.text = "\(resortNm) (\(resortCode))".localized()
            
        case .destination(let destination):
            var name = ""
            var trcode = ""
            if let destName = destination.destinationName {
                name = destName
            }
            if let terocode = destination.address?.territoryCode {
                trcode = terocode
            }
            cell.lblTitle.text = "\(name), \(trcode)".localized()
            
        case .resorts(let resorts):
            var resortNm = ""
            var resortCode = ""
            if let restName = resorts[0].resortName {
                resortNm = restName
            }
            if let restcode = resorts[0].resortCode {
                resortCode = restcode
            }
            var resortNameString = "\(resortNm) (\(resortCode))".localized()
            if resorts.count > 1 {
                resortNameString = resortNameString.appending(" and \(resorts.count - 1) more")
            }
            
            cell.lblTitle.text = resortNameString.localized()
        }
        
        cell.deletebutton.tag = indexPath.row
        cell.infobutton.addTarget(self, action: #selector(detailButtonPressed(sender:)), for: .touchUpInside)
        cell.delegate = self
        cell.layer.borderWidth = 2
        cell.layer.borderColor = IUIKColorPalette.border.color.cgColor
        cell.layer.cornerRadius = 5
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
}

//***** extensiion class to define tableview datasource methods *****//
extension CreateAlertViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: Constant.buttonTitles.remove) { (_, index) -> Void in
            if !Constant.MyClassConstants.selectedGetawayAlertDestinationArray.isEmpty {
                
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.remove(at: indexPath.row)
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
                tableView.setEditing(false, animated: true)
            })
        }
        delete.backgroundColor = UIColor(red: 224 / 255.0, green: 96.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        
        let details = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.details) { (_, _) -> Void in
            
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            let storyboardName = isRunningOnIphone ? Constant.storyboardNames.iphone : Constant.storyboardNames.resortDirectoryIpad
            let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as? InfoDetailViewController {
                viewController.selectedIndex = indexPath.row
                self.navigationController?.present(viewController, animated: true, completion: nil)
            }
        }
        details.backgroundColor = UIColor(red: 0 / 255.0, green: 119.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
        
        if (Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] as AnyObject).isKind(of: NSMutableArray.self) {
            return [delete, details]
        } else {
            return [delete]
        }
    }
}

extension CreateAlertViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** adding custom add button to search destination or resort *****//
        
        if Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count == 0 || indexPath.row == Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath as IndexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width / 2 - (UIScreen.main.bounds.width / 5) / 2, y: 10, width: UIScreen.main.bounds.width / 5, height: 30))
            addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
            addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
            addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
            addLocationButton.layer.cornerRadius = 6
            addLocationButton.layer.borderWidth = 2
            addLocationButton.addTarget(self, action: #selector(addLocationPressed), for: .touchUpInside)
            
            cell.addSubview(addLocationButton)
            
            return cell
        } else {
            
            guard let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoContentCell, for: indexPath ) as? WhereToGoContentCell else { return UITableViewCell() }
            
            //***** condition to check for show hide or and seprator on cell *****//
            if indexPath.row == Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count - 1 || Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count == 0 {
                
                cell.sepratorOr.isHidden = true
                cell.sepratorView.isHidden = true
            } else {
                
                cell.sepratorOr.isHidden = false
                cell.sepratorView.isHidden = false
            }
            
            switch Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] {
            case .resort(let resort):
                var resortNm = ""
                var resortCode = ""
                if let restName = resort.resortName {
                    resortNm = restName
                }
                if let restcode = resort.resortCode {
                    resortCode = restcode
                }
                cell.whereTogoTextLabel.text = "\(resortNm) (\(resortCode))"
                
            case .destination(let dest):
                let destName = dest.destinationName ?? ""
                let terocode = dest.address?.territoryCode ?? ""
                cell.whereTogoTextLabel.text = "\(destName), \(String(describing: terocode))"
                
            case .resorts(let resorts):
                var resortNm = ""
                var resortCode = ""
                if let restName = resorts[0].resortName {
                    resortNm = restName
                }
                if let restcode = resorts[0].resortCode {
                    resortCode = restcode
                }
                var resortNameString = "\(resortNm) (\(resortCode))"
                if resorts.count > 1 {
                    resortNameString = resortNameString.appending(" and \(resorts.count - 1) more")
                }
                cell.whereTogoTextLabel.text = resortNameString
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CreateAlertViewController: WhereToGoCollectionViewCellDelegate {
    
    func deleteButtonClickedAtIndex(_ Index: Int) {
        
        if !Constant.MyClassConstants.selectedGetawayAlertDestinationArray.isEmpty {
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.remove(at: Index)
            selectedIndex = -1
        }
        let deletionIndexPath = IndexPath(item: Index, section: 0)
        self.createAlertCollectionView.deleteItems(at: [deletionIndexPath])
        
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        
    }
}

