//
//  FloatDetailViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/2/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import Realm
import RealmSwift

class FloatDetailViewController: UIViewController {
    
    //IBOutlets
    
    @IBOutlet weak var floatDetailsTableView: UITableView!
    
    // variable declaration
    var isKeyBoardOpen = false
    var detailsStatusForFloat: Bool = false
    var moved: Bool = false
    var activeField: UITextField?
    var isFromLockOff = false
    weak var floatResortDetails = Resort()
    weak var floatUnitDetails = InventoryUnit()
    var selectedTextField = false
    var floatAttributesArray = NSMutableArray()
    var atrributesRowArray = NSMutableArray()
    var checkInDate = ""
    var proceedStatus = false
    
    /**
     PopcurrentViewcontroller from NavigationController
     - parameter sender: UIButton reference.
     - returns : No return.
     */
    @IBAction func floatCancelButtonIsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: Constant.storyboardNames.availableDestinationsIphone, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //adding keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(true)
         floatDetailsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.floatDetails
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        if(Constant.MyClassConstants.selectedFloatWeek.floatDetails.count > 0) {
            
            if Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].unitNumber != "" {
            Constant.FloatDetails.unitNumber = Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].unitNumber
            }
            if Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].reservationNumber != "" {
                Constant.FloatDetails.unitNumber = Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].reservationNumber
            }
            if Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].unitSize != "" {
                Constant.MyClassConstants.savedBedroom = Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].unitSize
            }
        }
        
        floatUnitDetails = Constant.MyClassConstants.relinquishmentSelectedWeek.unit!
        floatDetailsTableView.estimatedRowHeight = 200
        self.title = Constant.ControllerTitles.floatDetailViewController
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(FloatDetailViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        Constant.AdditionalUnitDetailsData.bedroomUnit.removeAll()
        
    }
    
    //show keyboard
    func keyboardWasShown(aNotification: NSNotification) {
        
        isKeyBoardOpen = true
        
        if(self.moved) {
            let info = aNotification.userInfo as! [String: AnyObject],
            kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
            contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            
            self.floatDetailsTableView.contentInset = contentInsets
            self.floatDetailsTableView.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= kbSize.height
            
            if !aRect.contains(activeField!.frame.origin) {
                
                self.floatDetailsTableView.scrollRectToVisible(activeField!.frame, animated: true)
                
            }
        }
    }
    
    // hiding keyboard
    func keyboardWillBeHidden(aNotification: NSNotification) {
        isKeyBoardOpen = false
        
        if(self.moved) {
            self.moved = false
            let contentInsets = UIEdgeInsets.zero
            self.floatDetailsTableView.contentInset = contentInsets
            self.floatDetailsTableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    // Check for FloatDetails.
    
    func checkForFloatDetails() -> Bool {
        
        var count = 0
        for attribute in atrributesRowArray {
            if(attribute as! String == Constant.MyClassConstants.resortReservationAttribute && Constant.FloatDetails.reservationNumber != "") {
                count = count + 1
            }
            if(attribute as! String == Constant.MyClassConstants.noOfBedroomAttribute && Constant.MyClassConstants.savedBedroom != "") {
                count = count + 1
            }
            if(attribute as! String == Constant.MyClassConstants.checkInDateAttribute && Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate != nil) {
                count = count + 1
            }
            if(attribute as! String == Constant.MyClassConstants.unitNumberAttribute && Constant.FloatDetails.unitNumber != "") {
                count = count + 1
            }
            if(attribute as! String == Constant.MyClassConstants.resortClubAttribute && Constant.MyClassConstants.savedClubFloatResort != "") {
                count = count + 1
            }
        }
        
        if(count == atrributesRowArray.count) {
            proceedStatus = true
        } else {
            proceedStatus = false
        }
        
        return proceedStatus
    
    }
    
    //adding done button on keyboard type numberPad
    func addDoneButtonOnNumpad(textField: UITextField) {
        
        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        // add a toolbar with a done button above the number pad
        textField.inputAccessoryView = keypadToolbar
    }
    
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        Constant.MyClassConstants.savedClubFloatResort = ""
        self.resetFloatGlobalVariables()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Call your resort button action
    @IBAction func callYourResortTapped(_sender: IUIKButton) {
        if let url = URL(string: "tel://\(floatResortDetails!.phone!)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    // Select bedroom button action
    @IBAction func bedroomButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
        Constant.MyClassConstants.buttontitle = Constant.buttonId.bedroomselection
        
    }
    
    // Select check - in date action
    @IBAction func selectCheckInDate(_sender: UIButton) {
        
        Helper.getCheckInDatesForCalendar(senderViewController: self, resortCode: (floatResortDetails?.resortCode)!, relinquishmentYear: Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!)
    }
    
    //Select bedroom
    func selectBedroom(_sender: UIButton) {
        self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
        Constant.MyClassConstants.buttontitle = Constant.buttonId.bedroomselection
    }
    
    //Save Float Details
    @IBAction func saveFloatDetails() {
        
        var tableViewCell = UITableViewCell()
        if(isFromLockOff) {
            Constant.FloatDetails.unitNumber = Constant.MyClassConstants.unitNumberLockOff
        }
        if(atrributesRowArray.contains(Constant.MyClassConstants.checkInDateAttribute)) {
            
            tableViewCell = floatDetailsTableView.cellForRow(at: IndexPath(row: atrributesRowArray.index(of: Constant.MyClassConstants.checkInDateAttribute), section: floatAttributesArray.index(of: Constant.MyClassConstants.resortAttributes)))!
            checkInDate = getTableViewCellSubviews(tableViewCell: tableViewCell)
        }
        
        //API call for update fix week reservation
        let fixedWeekReservation = FixWeekReservation()
        var myComponents: DateComponents
        if(Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate == nil) {
            
        } else {
            if let fltDetailsSelectedDate = Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate {
                let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: fltDetailsSelectedDate)
                let year = String(describing: myComponents.year!)
                var  month = String(describing: myComponents.month!)
                if(month.characters.count == 1) {
                    month = ("0").appending("\(month)")
                }
                let day = myComponents.day!
                    fixedWeekReservation.checkInDate = "\(year)-\(month)-\(day)"
            if(Constant.MyClassConstants.floatDetailsCalendarDateArray.contains(fltDetailsSelectedDate)) {
                let index = Constant.MyClassConstants.floatDetailsCalendarDateArray.index(of: fltDetailsSelectedDate)
                fixedWeekReservation.weekNumber = String(describing: Constant.MyClassConstants.floatDetailsCalendarWeekArray[index!])
            }
        }
    }
        if(atrributesRowArray.contains(Constant.MyClassConstants.resortReservationAttribute)) {
            fixedWeekReservation.reservationNumber = Constant.FloatDetails.reservationNumber
        }
        let unit = InventoryUnit()
        if(atrributesRowArray.contains(Constant.MyClassConstants.unitNumberAttribute)) {
          unit.unitNumber = Constant.FloatDetails.unitNumber
          unit.unitSize = Constant.MyClassConstants.savedBedroom
          fixedWeekReservation.unit = unit
        }
        
        if(floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute)) {
            let resort = Resort()
            resort.resortCode = Constant
                .MyClassConstants.savedClubFloatResortCode
            fixedWeekReservation.resort = resort
        }
        
        updateFixWeekReservation(relinqishmentID: Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!, fixedWeekReservation: fixedWeekReservation, viewController: self)
    }
    
    //Function to update fix week reservation
     func updateFixWeekReservation(relinqishmentID: String, fixedWeekReservation: FixWeekReservation, viewController: UIViewController) {
        ExchangeClient.updateFixWeekReservation(Session.sharedSession.userAccessToken, relinquishmentId: relinqishmentID, reservation: fixedWeekReservation, onSuccess: {
            
            //Check if float is already saved in database
            if(Constant.MyClassConstants.selectedFloatWeek.floatDetails.count > 0) {
                
                let storedData = Helper.getLocalStorageWherewanttoTrade()
                
                if(storedData.count > 0) {
                    let realm = try! Realm()
                    try! realm.write {
                        let floatWeek = OpenWeeks()
                        var floatWeekIndex = -1
                        
                        for (index, object) in storedData.enumerated() {
                            let openWk1 = object.openWeeks[0].openWeeks[0]
                            if(openWk1.relinquishmentID == Constant.MyClassConstants.selectedFloatWeek.relinquishmentID && (openWk1.isFloatRemoved || openWk1.isLockOff)) {
                                if(openWk1.isLockOff) {
                                    if(openWk1.floatDetails[0].unitNumber == Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].unitNumber) {
                                        floatWeekIndex = index
                                    }
                                } else {
                                    floatWeekIndex = index
                                }
                            }
                        }
                        
                        if(floatWeekIndex > 0) {
                            
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloatRemoved = false
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFloat = true
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isFromRelinquishment = true
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].floatDetails[0].reservationNumber = Constant.FloatDetails.reservationNumber
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].floatDetails[0].unitNumber = Constant.FloatDetails.unitNumber
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].floatDetails[0].unitSize = Constant.MyClassConstants.savedBedroom
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].floatDetails[0].checkInDate = self.checkInDate
                            storedData[floatWeekIndex].openWeeks[0].openWeeks[0].floatDetails[0].clubResortDetails = Constant.MyClassConstants.savedClubFloatResort
                            if(floatWeek.isLockOff) {
                                storedData[floatWeekIndex].openWeeks[0].openWeeks[0].isLockOff = true
                            }
                            if(!self.atrributesRowArray.contains(Constant.MyClassConstants.unitNumberAttribute)) {
                                storedData[floatWeekIndex].openWeeks[0].openWeeks[0].floatDetails[0].showUnitNumber = false
                            }
                        }
                        //Pop to vacation search screen
                        self.popToVacationSearch()
                        
                    }
                }
            } else {
                
                self.addFloatToDatabase(reservationNumber: Constant.FloatDetails.reservationNumber, unitNumber: Constant.FloatDetails.unitNumber, unitSize: Constant.MyClassConstants.savedBedroom, checkInDate: self.checkInDate)
            }
            
        }) { error in
            //Pop to vacation search screen
            self.popToVacationSearch()
            self.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
    }
    
    func resetFloatGlobalVariables() {
        
        Constant.FloatDetails.reservationNumber = ""
        Constant.FloatDetails.unitNumber = ""
        //Constant.MyClassConstants.savedBedroom = ""
        Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate = nil

    }
    
    //Function to cancel float detail view
    @IBAction func cancelButtonPressed(_:IUIKButton) {
        self.resetFloatGlobalVariables()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Fucntion to get subview
    
    func getTableViewCellSubviews(tableViewCell: UITableViewCell) -> String {
        for subView in (tableViewCell.contentView.subviews) {
            if subView .isKind(of: UIView.self) {
                for textField in subView.subviews {
                    let unitTextField = textField as! UITextField
                    return unitTextField.text!
                }
            } else {
                return ""
            }
        }
        return ""
    }
    
    //Function to save float week to database
    func addFloatToDatabase(reservationNumber: String, unitNumber: String, unitSize: String, checkInDate: String) {
        //Realm local storage for selected relinquishment
        let storedata = OpenWeeksStorage()
        let Membership = Session.sharedSession.selectedMembership
        let relinquishmentList = TradeLocalData()
        
        let selectedOpenWeek = OpenWeeks()
        selectedOpenWeek.isFloat = true
        if isFromLockOff {
            selectedOpenWeek.isLockOff = true
        }
        selectedOpenWeek.weekNumber = Constant.MyClassConstants.relinquishmentSelectedWeek.weekNumber!
        selectedOpenWeek.relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId!
        selectedOpenWeek.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear!
        selectedOpenWeek.isFloatRemoved = false
        selectedOpenWeek.isFromRelinquishment = true
        let resort = ResortList()
        resort.resortName = (floatResortDetails?.resortName)!
        
        let floatDetails = ResortFloatDetails()
        floatDetails.reservationNumber = reservationNumber
        floatDetails.unitNumber = unitNumber
        floatDetails.unitSize = unitSize
        floatDetails.checkInDate = checkInDate
        intervalPrint(Constant.MyClassConstants.savedClubFloatResort)
        floatDetails.clubResortDetails = Constant.MyClassConstants.savedClubFloatResort
        if(!atrributesRowArray.contains(Constant.MyClassConstants.unitNumberAttribute)) {
            floatDetails.showUnitNumber = false
        }
        selectedOpenWeek.floatDetails.append(floatDetails)
        
        let unitDetails = ResortUnitDetails()
        unitDetails.kitchenType = (Helper.getKitchenEnums(kitchenType: (self.floatUnitDetails?.kitchenType!)!))
        unitDetails.unitSize = unitSize //(self.unitDetails?.unitSize!)!
        selectedOpenWeek.unitDetails.append(unitDetails)
        
        selectedOpenWeek.resort.append(resort)
        relinquishmentList.openWeeks.append(selectedOpenWeek)
        storedata.openWeeks.append(relinquishmentList)
        storedata.membeshipNumber = Membership!.memberNumber!
            let realm = try! Realm()
    
            try! realm.write {
                realm.add(storedata)
                if let relinquishmentId = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId {
                    Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentId)
                }
                
                //Pop to vacation search screen
                popToVacationSearch()
            }
    }
    
    //Function to pop to vacation search
    
    func popToVacationSearch() {
        //Pop to vacation search screen
        
        // Open vacation search view controller
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
        self.resetFloatGlobalVariables()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
/** Extension for tableview data source */
extension FloatDetailViewController: UITableViewDataSource {
    /** number of rows in section */
    func numberOfSections(in tableView: UITableView) -> Int {
        return floatAttributesArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && section == 3 {
            return atrributesRowArray.count
        } else if !floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && section == 2 {
            return atrributesRowArray.count
        } else {
            return 1
        }
    }
    /** cell for an indexPath */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch floatAttributesArray[indexPath.section] as? String ?? "" {
        case Constant.MyClassConstants.callResortAttribute:
            let resortcallCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
            return resortcallCell!
        case Constant.MyClassConstants.resortDetailsAttribute:
            let vacationdetailcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.vacationdetailcellIdentifier) as? ResortDirectoryResortCell
            vacationdetailcell!.getCell(resortDetails: floatResortDetails!)
            
            return vacationdetailcell!
        case Constant.MyClassConstants.resortClubAttribute:
            let selectClubresortcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.selectclubcellIdentifier) as! ReservationTableViewCell
            if Constant.MyClassConstants.savedClubFloatResort != "" {
                
                let firstStringAttributes = [NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeue, size: 15)]
                
                let secondStringAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeue, size: 15)]
                
                let placeholderString = NSMutableAttributedString(string: Constant.MyClassConstants.selectClubResort, attributes: firstStringAttributes as Any as? [String: Any])
                
                let textValueString = NSMutableAttributedString(string: "\n\(Constant.MyClassConstants.savedClubFloatResort)", attributes: secondStringAttributes as Any as? [String: Any])
                
                let combination = NSMutableAttributedString()
                
                combination.append(placeholderString)
                combination.append(textValueString)
                
                selectClubresortcell.selectResortLabel.attributedText = combination
                Constant.AdditionalUnitDetailsData.clubresort = "Club Resort"
                detailsStatusForFloat = checkForFloatDetails()
            
            }
            return selectClubresortcell
            
        case Constant.MyClassConstants.resortAttributes:
            
            switch atrributesRowArray[indexPath.row] as? String ?? "" {
    
            case Constant.MyClassConstants.unitNumberAttribute:
                let registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.attributesCell) as! ReservationTableViewCell
                registrationNumbercell.textFieldView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                registrationNumbercell.resortAttributeLabel.delegate = self
                if Constant.FloatDetails.unitNumber != "" {
                    registrationNumbercell.resortAttributeLabel.text = Constant.FloatDetails.unitNumber
                } else {
                    registrationNumbercell.resortAttributeLabel.placeholder = Constant.textFieldTitles.unitNumber
                }
                
                registrationNumbercell.resortAttributeLabel.tag = 1
                return registrationNumbercell
                
            case Constant.MyClassConstants.noOfBedroomAttribute:
                guard let registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.buttonCell) as? ReservationTableViewCell else { return UITableViewCell() }
                registrationNumbercell.textFieldView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                if !Constant.MyClassConstants.selectedFloatWeek.floatDetails.isEmpty {
                    registrationNumbercell.resortAttributeLabel.text = Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].unitSize
                }
                registrationNumbercell.resortAttributeLabel.text = Constant.MyClassConstants.savedBedroom
                if Constant.MyClassConstants.savedBedroom != "" {
                    
                    registrationNumbercell.resortAttributeLabel.text = Constant.MyClassConstants.savedBedroom
                    Constant.AdditionalUnitDetailsData.bedroomUnit = Constant.MyClassConstants.savedBedroom
                }
                
                registrationNumbercell.resortAttributeLabel.placeholder = Constant.textFieldTitles.numberOfBedrooms
                
                if Constant.ControllerTitles.selectedControllerTitle != Constant.storyboardControllerID.floatViewController {
                    registrationNumbercell.viewButton.addTarget(self, action: #selector(self.selectBedroom(_sender:)), for: .touchUpInside)
                }
                detailsStatusForFloat = checkForFloatDetails()
                return registrationNumbercell
                
            case Constant.MyClassConstants.checkInDateAttribute:
                guard let registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: "DatesCell") as? ReservationTableViewCell else { return UITableViewCell() }
                registrationNumbercell.textFieldView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                registrationNumbercell.resortAttributeLabel.placeholder = Constant.textFieldTitles.checkInDate
                if !Constant.MyClassConstants.selectedFloatWeek.floatDetails.isEmpty {
                    registrationNumbercell.resortAttributeLabel.text = Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].checkInDate
                }
                if let selectedDate = Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate {
                    let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                    let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: selectedDate)
                    if let year = myComponents.year, let weekDayComp = myComponents.weekday, let monthComp = myComponents.month, let dayComp = myComponents.day {
                        
                        let weekDay = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDayComp))"
                        let month =   "\(Helper.getMonthnameFromInt(monthNumber: monthComp))"
                        let day = String(describing: dayComp)
                        registrationNumbercell.resortAttributeLabel.text =     "\(weekDay), \(month). \(" ")\(day)\("th") \(year)"

                    }
                    
                }
                registrationNumbercell.viewButton.addTarget(self, action: #selector(self.selectCheckInDate(_sender:)), for: .touchUpInside)
                return registrationNumbercell
            
            case Constant.MyClassConstants.resortReservationAttribute:
                
                guard let registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.attributesCell) as? ReservationTableViewCell else { return UITableViewCell() }
                registrationNumbercell.textFieldView.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
                if !Constant.MyClassConstants.selectedFloatWeek.floatDetails.isEmpty {
                    registrationNumbercell.resortAttributeLabel.text = Constant.MyClassConstants.selectedFloatWeek.floatDetails[0].reservationNumber
                }
                registrationNumbercell.resortAttributeLabel.placeholder = Constant.textFieldTitles.reservationNumber
                registrationNumbercell.resortAttributeLabel.tag = 0
                return registrationNumbercell
                
            default:
                guard let resortcallCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell else { return UITableViewCell() }
                resortcallCell.getCell()
                return resortcallCell
            }
            
        case Constant.MyClassConstants.saveAttribute:
    
            let saveandcancelCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.saveandcancelcellIdentifier) as? FloatSaveAndCancelButtonTableViewCell
            
            if proceedStatus {
                saveandcancelCell?.saveFloatDetailButton.alpha = 1.0
                saveandcancelCell?.saveFloatDetailButton.isEnabled = true
                return saveandcancelCell!

            } else {
                saveandcancelCell?.saveFloatDetailButton.alpha = 0.35
                return saveandcancelCell!
            }
            
        default:
            let resortcallCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
            return resortcallCell!
        }
    }
}
/** Extension for table view delegate **/
extension FloatDetailViewController: UITableViewDelegate {
    /**Height of Row at index path */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if floatAttributesArray.count == indexPath.section {
            return 200
        }
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && section == 3) || (!floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && section == 2) {
            return 50
        } else if section == 2 {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        let headerText = UILabel(frame: CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width - 30, height: 50))
        headerText.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
        
        if !floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && section == 2 {
            headerText.text = Constant.HeaderViewConstantStrings.reservationDetails
        } else if floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && section == 2 {
            headerText.text = Constant.HeaderViewConstantStrings.resortUnitDetails
        } else {
            headerText.text = Constant.HeaderViewConstantStrings.reservationDetails
        }
        
        headerView.addSubview(headerText)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && indexPath.section == 3) || (!floatAttributesArray.contains(Constant.MyClassConstants.resortClubAttribute) && indexPath.section == 2) {
            
            if indexPath.row == 1 {
                
                self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
                Constant.MyClassConstants.buttontitle = Constant.buttonId.bedroomselection
                
            } else if(indexPath as NSIndexPath).row == 2 {
                //selectCheckInDate()
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            Helper.getResortsByClubFloatDetails(resortCode: floatResortDetails!.resortCode!, senderViewController: self, floatResortDetails: floatResortDetails!)
            Constant.MyClassConstants.buttontitle = Constant.buttonId.resortSelection
        }
    }
}
/** Extension for done button in Bedroom Size Selection **/
extension FloatDetailViewController: BedroomSizeViewControllerDelegate {
    
    func doneButtonClicked(selectedUnitsArray: NSMutableArray) {
        let bedroomTextField = self.view.viewWithTag(3) as! UITextField!
        var bedroomString = ""
        for index in selectedUnitsArray {
            bedroomString = "\(bedroomString)\(UnitSize.forDisplay[index as! Int].friendlyName()) "
            bedroomTextField!.text = ""
            bedroomTextField!.text = bedroomString
        }
    }
    
}

/** Extension for text field **/
extension FloatDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeField?.resignFirstResponder()
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField?.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
            if(textField.tag == 0) {
                    
                if (range.length == 1 && string.characters.count == 0) {
                    Constant.FloatDetails.reservationNumber.characters.removeLast()
                    if(Constant.FloatDetails.reservationNumber.characters.count == 0) {
                        self.proceedStatus = false
                        let indexPath = NSIndexPath(row: 0, section: floatAttributesArray.index(of: Constant.MyClassConstants.saveAttribute))
                        floatDetailsTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)

                    }
                } else {
                    Constant.FloatDetails.reservationNumber = "\(textField.text!)\(string)"
                    intervalPrint(Constant.FloatDetails.reservationNumber)
                }
               let status = checkForFloatDetails()
                
                if(status) {
                    
                    let indexPath = NSIndexPath(row: 0, section: floatAttributesArray.index(of: Constant.MyClassConstants.saveAttribute))
                    floatDetailsTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
                }
                
                return true
                
            } else {
                
                if (range.length == 1 && string.characters.count == 0) {
                    
                    Constant.FloatDetails.unitNumber.characters.removeLast()
                    if(Constant.FloatDetails.unitNumber.characters.count == 0) {
                        
                        self.proceedStatus = false
                        let indexPath = NSIndexPath(row: 0, section: floatAttributesArray.index(of: Constant.MyClassConstants.saveAttribute))
                        floatDetailsTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
                        
                    }
                   
                } else {
                    
                    Constant.FloatDetails.unitNumber = "\(textField.text!)\(string)"
                }
                
               let status = checkForFloatDetails()
                
                if(status) {
                    
                    let indexPath = NSIndexPath(row: 0, section: floatAttributesArray.index(of: Constant.MyClassConstants.saveAttribute))
                    floatDetailsTableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)

                }
                
                return true
            }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
            self.activeField = textField
        
            if(textField.tag == 0 ) {
                
                self.moved = true
                textField.keyboardType = .numberPad
                 self.addDoneButtonOnNumpad(textField: textField)
            } else {
                self.moved = true
                textField.keyboardType = .numberPad
                self.addDoneButtonOnNumpad(textField: textField)
               
            }
        }

}
