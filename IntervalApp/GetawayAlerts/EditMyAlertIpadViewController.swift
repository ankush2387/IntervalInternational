//
//  EditMyAlertIpadViewController.swift
//  IntervalApp
//
//  Created by Chetu on 23/08/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class EditMyAlertIpadViewController: UIViewController {
    
    //***** commom  outlets *****//
    @IBOutlet weak var createAlertCollectionView: UICollectionView!
    @IBOutlet weak var createAlertTBLView: UITableView!
    @IBOutlet weak var textfieldBorderView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var alertStatusButton: UISwitch!
    
    //***** start date labels outlets *****//
    @IBOutlet weak var startDateDayLabel: UILabel!
    @IBOutlet weak var startDateMonthYearLabel: UILabel!
    @IBOutlet weak var startDateDayNameLabel: UILabel!
    
    //***** end date labels outlets *****//
    @IBOutlet weak var endDateDayLabel: UILabel!
    @IBOutlet weak var endDateMonthYearLabel: UILabel!
    @IBOutlet weak var endDateDayNameLabel: UILabel!
    
    @IBOutlet weak var travelWindowEndDateSelectionButton: UIButton!
    //***** Bedroom size labels outlets *****//
    @IBOutlet weak var bedroomSize: UILabel!
    
    //***** class variable outlets *****//
    var editAlertName = ""
    var alertId = Int64()
    var selectedIndex: Int = -1
    var anlyticsBedroomSize: String = ""
    
    //***** Constraints outlets *****//
    @IBOutlet weak var leadingStartLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingStartDateConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingEndLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingEndDateConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set return key on Keyboard to DONE
        nameTextField.returnKeyType = .done
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAll()
       if let alert = Constant.selectedAlertToEdit {
            if let altId = alert.alertId {
                alertId = altId
            }
            if let alrtName = alert.name {
                editAlertName = alrtName
            }
        }
       
        showHudAsync()
        RentalClient.getAlert(Session.sharedSession.userAccessToken, alertId: alertId, onSuccess: { alert in
            
             let earlyDate = Helper.convertStringToDate(dateString: alert.earliestCheckInDate!, format: "yyyy-MM-dd")
            
            let lateDate = Helper.convertStringToDate(dateString: alert.latestCheckInDate!, format: "yyyy-MM-dd")
            
            Constant.MyClassConstants.alertWindowStartDate = earlyDate
            Constant.MyClassConstants.alertWindowEndDate = lateDate
            
            let destination = alert.destinations
            for dest in destination {
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.destination(dest))
            }
            let resorts = alert.resorts
            for resort in resorts {
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.resort(resort))
            }
            self.hideHudAsync()
            self.setupView()
        }) {  [weak self] error in self?.presentErrorAlert(UserFacingCommonError.serverError(error))
        }
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.editAnAlert
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        // omniture tracking with event 76
        let userInfo: [String: String] = [
           
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.alert
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event76, data: userInfo)
        
        //**** Check for iPhone 4s and iPhone 5s to align travel window start and end date *****//
        if UIScreen.main.bounds.width == 320 {
            leadingStartDateConstraint.constant = 0
            leadingStartLabelConstraint.constant = 0
            leadingEndDateConstraint.constant = 0
            leadingEndLabelConstraint.constant = 0
        }
        
        self.title = Constant.ControllerTitles.editgetawayAlertsViewController
        Constant.MyClassConstants.vacationSearchShowDate = Date()
        //***** adding menu bar back button *****//
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(menuBackButtonPressed(sender:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.textfieldBorderView.layer.cornerRadius = 7
        self.textfieldBorderView.layer.borderWidth = 2
        self.textfieldBorderView.layer.borderColor = Constant.RGBColorCode.textFieldBorderRGB
        self.nameTextField.delegate = self
        self.nameTextField.textColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        self.nameTextField.text = self.editAlertName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        intervalPrint(Constant.selectedAlertToEdit)
        Constant.MyClassConstants.isRunningOnIphone ? createAlertTBLView.reloadData() : createAlertCollectionView.reloadData()
    
        self.setupView()
        
        guard let alertToEdit = Constant.selectedAlertToEdit else { return }
        var selectedBedroomsizes = [String]()
        for unitSize in alertToEdit.unitSizes {
            let friendlyName = unitSize.friendlyName()
            let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: friendlyName)
            selectedBedroomsizes.append(bedroomSize)
        }
        self.bedroomSize.text = selectedBedroomsizes.joined(separator: ", ")
    }
    
    fileprivate func setupView() {
        
        if let startDate = Constant.MyClassConstants.alertWindowStartDate {
            self.travelWindowEndDateSelectionButton.isEnabled = true
            let calendar = Calendar.current
            let anchorComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: startDate)
            self.startDateDayLabel.text = "\(anchorComponents.day ?? 0)".localized()
            self.startDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: anchorComponents.weekday ?? 0))".localized()
            self.startDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: anchorComponents.month ?? 0)) \(anchorComponents.year ?? 0)".localized()
            
        } else {
            
            self.travelWindowEndDateSelectionButton.isEnabled = false
        }
        if let endDate = Constant.MyClassConstants.alertWindowEndDate {
            if let startDate = Constant.MyClassConstants.alertWindowStartDate {
                if endDate.isGreaterThanDate(startDate) {
                
                let calendar = Calendar.current
                let anchorComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: endDate)
                self.endDateDayLabel.text = "\(anchorComponents.day ?? 0)"
                self.endDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: anchorComponents.weekday ?? 0))".localized()
                self.endDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: anchorComponents.month ?? 0)) \(anchorComponents.year ?? 0)".localized()
            } else {
                
                let calendar = Calendar.current
                let anchorComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: startDate)
                self.endDateDayLabel.text = "\(anchorComponents.day ?? 0)".localized()
                self.endDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: anchorComponents.weekday ?? 0))".localized()
                self.endDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: anchorComponents.month ?? 0)) \(anchorComponents.year ?? 0)".localized()
            }
          }
        }
        if Constant.RunningDevice.deviceIdiom == .pad {
            self.createAlertCollectionView.reloadData()
        } else {
            self.createAlertTBLView.reloadData()
        }
    }
    
    //***** function to dismiss present view controller on back button pressed *****//
    func menuBackButtonPressed(sender: UIBarButtonItem) {
        
         dismiss(animated: true)
        
    }
    //***** function to call calendar screen to select travel start date *****//
    @IBAction func travelStartDateCalendarIconPressed(_ sender: AnyObject) {
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as? CalendarViewController {
            viewController.requestedDateWindow = Constant.MyClassConstants.start
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    //***** function to call calendar screen to select travel end date *****//
    @IBAction func travelEndDateCalendarIconPressed(_ sender: AnyObject) {
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as? CalendarViewController {
            viewController.requestedDateWindow = Constant.MyClassConstants.end
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //***** function to call bedroom size screen to select bedroom size *****//
    @IBAction func selectRoomSizePressed(_ sender: AnyObject) {
        
        var mainStoryboard = UIStoryboard()
        
        mainStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BedroomSizeNav") as? UINavigationController {
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
    //***** function to call search destination  screen to search destination by name *****//
    @IBAction func addLocationPressed(_ sender: AnyObject) {
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.iphone : Constant.storyboardNames.resortDirectoryIpad
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as? GoogleMapViewController {
            viewController.sourceController = Constant.MyClassConstants.createAlert
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func SaveMyAlertButtonPressed(_ sender: AnyObject) {
        
        let trimmedUsername = self.nameTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        guard let startDate = Constant.MyClassConstants.alertWindowStartDate else { return  presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
            .editAlertEmptyWidowStartDateMessage) }
        guard let endDate = Constant.MyClassConstants.alertWindowEndDate else { return presentAlert(with: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
            .editAlertEmptyWidowEndDateMessage) }
        if !trimmedUsername.isEmpty {
            if Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count > 0 {
                        
                showHudAsync()
                let rentalAlert = RentalAlert()
                rentalAlert.alertId = self.alertId
                rentalAlert.earliestCheckInDate = Helper.convertDateToString(date: startDate, format: Constant.MyClassConstants.dateFormat)
                rentalAlert.latestCheckInDate = Helper.convertDateToString(date: endDate, format: Constant.MyClassConstants.dateFormat)
                rentalAlert.enabled = true
                rentalAlert.name = trimmedUsername
                if self.alertStatusButton.isOn {
                    rentalAlert.enabled = true
                } else {
                    rentalAlert.enabled = false
                }
                
                rentalAlert.resorts = Constant.MyClassConstants.alertSelectedResorts
                rentalAlert.destinations = Constant.MyClassConstants.alertSelectedDestination
                rentalAlert.selections = []
                
                var unitsizearray = [UnitSize]()
                if !Constant.MyClassConstants.alertSelectedUnitSizeArray.isEmpty {
                    
                    for selectedSize in Constant.MyClassConstants.alertSelectedUnitSizeArray {
                        
                        let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: selectedSize as! String )
                        self.anlyticsBedroomSize = self.anlyticsBedroomSize.appending(bedroomSize)
                        
                        let selectedUnitSize = UnitSize(rawValue: selectedSize as! String)
                        unitsizearray.append(selectedUnitSize!)
                    }
                    
                    rentalAlert.unitSizes = unitsizearray
                } else {
                    
                    for unitsize in Constant.MyClassConstants.bedRoomSize {
                        
                        let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: unitsize )
                        self.anlyticsBedroomSize = self.anlyticsBedroomSize.appending("\(bedroomSize), ")
                        
                        let selectedUnitSize = UnitSize(rawValue: unitsize )
                        unitsizearray.append(selectedUnitSize!)
                    }
                    rentalAlert.unitSizes = unitsizearray
                }
                
                RentalClient.updateAlert(Session.sharedSession.userAccessToken, alert: rentalAlert, onSuccess: { (_) in
                    
                    self.hideHudAsync()
                    
                    var deststr: String = ""
                    for dest in Constant.MyClassConstants.alertSelectedDestination {
                        
                        deststr = deststr.appending("\(dest.destinationName), ")
                    }
                    
                    for resort in Constant.MyClassConstants.alertSelectedResorts {
                        
                        deststr = deststr.appending("\(resort.resortName!), ")
                    }
                    
                    // omniture tracking with event 53
                    let userInfo: [String: Any] = [
                        Constant.omnitureEvars.eVar43: " - \(Date())",
                        Constant.omnitureCommonString.listItem: deststr,
                        Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.alert,
                        Constant.omnitureEvars.eVar57: startDate,
                        Constant.omnitureEvars.eVar58: endDate,
                        Constant.omnitureEvars.eVar59: self.anlyticsBedroomSize,
                        Constant.omnitureEvars.eVar60: Constant.MyClassConstants.alertOriginationPoint,
                        Constant.omnitureEvars.eVar69: Constant.AlertPromtMessages.yes
                    ]
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event53, data: userInfo)
                    let alertController = UIAlertController(title: Constant.AlertPromtMessages.editAlertTitle, message: Constant.AlertMessages.editAlertMessage, preferredStyle: .alert)
                    
                    // Create OK button
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (_:UIAlertAction) in
                        Constant.needToReloadAlert = true
                        self.dismiss(animated: true)
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                    
                }) { (_) in
                    
                    // omniture tracking with event 53
                    let userInfo: [String: Any] = [
                        Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.alert,
                        Constant.omnitureEvars.eVar69: Constant.AlertPromtMessages.no
                    ]
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event53, data: userInfo)
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.generic)
                    
                }
            } else {
                self.presentAlert(with: Constant.AlertPromtMessages.editAlertTitle, message: Constant.AlertMessages.editAlertdetinationrequiredMessage)
            }
        } else {
            self.presentAlert(with: Constant.AlertPromtMessages.editAlertTitle, message: Constant.AlertMessages.editAlertEmptyNameMessage)
        }
        
    }
    
    //***** function to present modalview controller of selected resort detail screen *****//
    func detailButtonPressed() {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
        viewController.selectedIndex = self.selectedIndex
        self.navigationController!.present(viewController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//***** extensiion class to define tableview delegate methods *****//
extension EditMyAlertIpadViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
//***** extensiion class to define collectionview delegate methods *****//
extension EditMyAlertIpadViewController: UICollectionViewDelegate {
    
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

extension EditMyAlertIpadViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.wereToGoTableViewCell, for: indexPath as IndexPath) as! WhereToGoCollectionViewCell
        if indexPath.row == selectedIndex {
            let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] as AnyObject
            if object.isKind(of: NSArray.self) {
                
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = false
            } else {
                
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = true
            }
        } else {
            
            cell.deletebutton.isHidden = true
            cell.infobutton.isHidden = true
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
            cell.lblTitle.text = "\(resortNm) (\(resortCode))".localized()
            
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
            cell.lblTitle.text = resortNameString.localized()
            
        case .destination(let dest):
            var destinationName = ""
            var teritorycode = ""
            
            if let destName = dest.destinationName {
                destinationName = destName
            }
            if let terocode = dest.address?.territoryCode {
                teritorycode = terocode
            }
            
            if !destinationName.isEmpty && !teritorycode.isEmpty {
                cell.lblTitle.text = "\(destinationName), \(teritorycode)".localized()
            } else {
                if !destinationName.isEmpty {
                    cell.lblTitle.text = destinationName
                } else {
                    cell.lblTitle.text = ""
                }
            }
        }
        
        cell.deletebutton.tag = indexPath.row
        cell.delegate = self
        cell.layer.borderWidth = 2
        cell.layer.borderColor = IUIKColorPalette.border.color.cgColor
        cell.layer.cornerRadius = 5
        cell.updateConstraintsIfNeeded()
        return cell
    }
}

//***** extensiion class to define tableview datasource methods *****//
extension EditMyAlertIpadViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension EditMyAlertIpadViewController: UITableViewDataSource {
    
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
            addLocationButton.addTarget(self, action: #selector(addLocationPressed(_:)), for: .touchUpInside)
            
            cell.addSubview(addLocationButton)
            
            return cell
        } else {
            
            guard let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoContentCell, for: indexPath as IndexPath) as? WhereToGoContentCell else { return UITableViewCell() }
            
            //condition to check for show hide or and seprator on cell
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
                cell.whereTogoTextLabel.text = "\(resortNm) (\(resortCode))".localized()
                
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
                cell.whereTogoTextLabel.text = resortNameString.localized()
                
            case .destination(let dest):
                var destinationName = ""
                var teritorycode = ""
                
                if let destName = dest.destinationName {
                    destinationName = destName
                }
                if let terocode = dest.address?.territoryCode {
                    teritorycode = terocode
                }
                if !destinationName.isEmpty && !teritorycode.isEmpty {
                    cell.whereTogoTextLabel.text = "\(destinationName), \(teritorycode)".localized()
                } else {
                    if !destinationName.isEmpty {
                        cell.whereTogoTextLabel.text = destinationName
                    } else {
                        cell.whereTogoTextLabel.text = ""
                    }
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: Constant.buttonTitles.remove) { (_, index) in
            if Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count > 0 {
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
                //tableView.reloadData()
                tableView.setEditing(false, animated: true)
                
            })
          }
        }
        delete.backgroundColor = UIColor(red: 224 / 255.0, green: 96.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        
        let details = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.details) { (_, _) -> Void in
            
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            let storyboardName = isRunningOnIphone ? Constant.storyboardNames.getawayAlertsIphone : Constant.storyboardNames.getawayAlertsIpad
            let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as? InfoDetailViewController {
                viewController.selectedIndex = indexPath.row
                self.navigationController?.present(viewController, animated: true, completion: nil)
            }
        }
        details.backgroundColor = UIColor(red: 0 / 255.0, green: 119.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
            switch Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] {
            case .resorts(_):
                return [delete, details]
                
            default:
                return [delete]
            }
        }
    }

extension EditMyAlertIpadViewController: WhereToGoCollectionViewCellDelegate {
    
    func deleteButtonClickedAtIndex(_ Index: Int) {
        
        if Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count > 0 {
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.remove(at: Index)
            selectedIndex = -1
        }
        let deletionIndexPath = IndexPath(item: Index, section: 0)
        self.createAlertCollectionView.deleteItems(at: [deletionIndexPath])
        
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        self.selectedIndex = Index
        self.detailButtonPressed()
    }
}
