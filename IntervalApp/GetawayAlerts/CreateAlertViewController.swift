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
    @IBOutlet weak var leadingStartLabelConstraint:NSLayoutConstraint!
    @IBOutlet weak var leadingStartDateConstraint:NSLayoutConstraint!
    @IBOutlet weak var leadingEndLabelConstraint:NSLayoutConstraint!
    @IBOutlet weak var leadingEndDateConstraint:NSLayoutConstraint!
    
    
    var selectedIndex:Int = -1
    var anlyticsBedroomSize:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set return key on Keyboard to DONE
        nameTextField.returnKeyType = .done
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.createAnAlert
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)

        
        // omniture tracking with event 50
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.alert
        ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event50, data: userInfo)
        
        
        //**** Check for iPhone 4s and iPhone 5s to align travel window start and end date *****//
        if(UIScreen.main.bounds.width == 320){
            leadingStartDateConstraint.constant = 0
            leadingStartLabelConstraint.constant = 0
            leadingEndDateConstraint.constant = 0
            leadingEndLabelConstraint.constant = 0
            
        }
        self.title = Constant.ControllerTitles.creategetawayAlertsViewController
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAllObjects()
        Constant.MyClassConstants.selectedBedRoomSize = Constant.MyClassConstants.bedroomSizes
        Constant.MyClassConstants.vacationSearchShowDate = Date()
        Constant.MyClassConstants.alertWindowStartDate = nil
        Constant.MyClassConstants.alertWindowEndDate = nil
        
        //***** adding menu bar back button *****//
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed(sender:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.textfieldBorderView.layer.cornerRadius = 7
        self.textfieldBorderView.layer.borderWidth = 2
        self.textfieldBorderView.layer.borderColor = Constant.RGBColorCode.textFieldBorderRGB
        self.nameTextField.delegate = self
        
        
        var attributes = [
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeueBold, size: 25)! // Note the !
        ]
        
        if (Constant.RunningDevice.deviceIdiom == .phone){
            attributes = [
                NSForegroundColorAttributeName: UIColor.lightGray,
                NSFontAttributeName : UIFont(name: Constant.fontName.helveticaNeue, size: 15)! // Note the !
            ]
            
        }
        
        
        self.nameTextField.attributedPlaceholder =  NSAttributedString(string:Constant.textFieldTitles.alertNamePlaceholder, attributes:attributes)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.bedroomSize.text = Constant.MyClassConstants.selectedBedRoomSize
        if(Constant.MyClassConstants.alertWindowStartDate != nil) {
            
            self.travelWindowEndDateSelectionButton.isEnabled = true
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.alertWindowStartDate as Date)
            
            self.startDateDayLabel.text = String(describing: myComponents.day!)
            self.startDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
            self.startDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(myComponents.year!)"
            
        }
        else {
            
            self.travelWindowEndDateSelectionButton.isEnabled = false
        }
        if(Constant.MyClassConstants.alertWindowEndDate != nil){
            
            if(Constant.MyClassConstants.alertWindowStartDate .isLessThanDate(Constant.MyClassConstants.alertWindowEndDate)) {
                
                let myCalendar1 = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                let myComponents1 = myCalendar1.components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.alertWindowEndDate as Date)
                self.endDateDayLabel.text = String(describing: myComponents1.day!)
                self.endDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!))"
                self.endDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(myComponents1.year!)"
            }
            else {
                
                let myCalendar1 = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                let myComponents1 = myCalendar1.components([.day,.weekday,.month,.year], from: Constant.MyClassConstants.alertWindowStartDate as Date)
                self.endDateDayLabel.text = String(describing: myComponents1.day!)
                self.endDateDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!))"
                self.endDateMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(myComponents1.year!)"
            }
            
            
            
        }
        if(self.createAlertCollectionView != nil){
            self.createAlertCollectionView.reloadData()
        }else{
            self.createAlertTBLView.reloadData()
        }
    }
    
    //***** function to present modalview controller of selected resort detail screen *****//
    func detailButtonPressed(sender:UIButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
        viewController.selectedIndex = self.selectedIndex
        self.navigationController!.present(viewController, animated: true, completion: nil)
        
    }
    
    //***** function to create new alert *****//
    @IBAction func createAlertButtonPresseded(_ sender:AnyObject) {
        
        let trimmedUsername = self.nameTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if(trimmedUsername.characters.count != 0) {
            
            if(Constant.MyClassConstants.alertWindowStartDate != nil) {
                
                if(Constant.MyClassConstants.alertWindowEndDate != nil) {
                    
                    if(Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count > 0) {
                        
                        showHudAsync()
                        let rentalAlert = RentalAlert()
                        rentalAlert.earliestCheckInDate = Helper.convertDateToString(date: Constant.MyClassConstants.alertWindowStartDate, format: Constant.MyClassConstants.dateFormat)
                        rentalAlert.latestCheckInDate = Helper.convertDateToString(date: Constant.MyClassConstants.alertWindowEndDate, format: Constant.MyClassConstants.dateFormat)
                        
                        rentalAlert.name = nameTextField.text!
                        rentalAlert.enabled = true
                        print(Constant.MyClassConstants.alertSelectedResorts)
                        rentalAlert.resorts = Constant.MyClassConstants.alertSelectedResorts
                        rentalAlert.destinations = Constant.MyClassConstants.alertSelectedDestination
                        rentalAlert.selections = []
                        
                        var unitsizearray = [UnitSize]()
                        if(Constant.MyClassConstants.alertSelectedUnitSizeArray.count > 0) {
                            
                            for selectedSize in Constant.MyClassConstants.alertSelectedUnitSizeArray {
                                
                                
                                let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: selectedSize as! String )
                                self.anlyticsBedroomSize =  self.anlyticsBedroomSize.appending(bedroomSize)
                                let selectedUnitSize = UnitSize(rawValue: selectedSize as! String)
                                unitsizearray.append(selectedUnitSize!)
                            }
                            rentalAlert.unitSizes = unitsizearray
                        }
                        else {
                            
                            for unitsize in Constant.MyClassConstants.bedRoomSize {
                                let bedroomSize = Helper.bedRoomSizeToStringInteger(bedRoomSize: unitsize )
                                self.anlyticsBedroomSize =  self.anlyticsBedroomSize.appending("\(bedroomSize), ")
                                let selectedUnitSize = UnitSize(rawValue: unitsize )
                                unitsizearray.append(selectedUnitSize!)
                            }
                            rentalAlert.unitSizes = unitsizearray
                        }
                        
                        RentalClient.createAlert(Session.sharedSession.userAccessToken, alert: rentalAlert, onSuccess: { (response) in
                            var deststr:String = ""
                            for dest in Constant.MyClassConstants.alertSelectedDestination {
                                
                                deststr = deststr.appending("\(dest.destinationName), ")
                            }
                            let userInfo: [String: Any] = [
                                Constant.omnitureEvars.eVar43 : " - \(Date())",
                                Constant.omnitureCommonString.listItem: deststr,
                                Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.alert,
                                Constant.omnitureEvars.eVar57 : Constant.MyClassConstants.alertWindowStartDate,
                                Constant.omnitureEvars.eVar58 : Constant.MyClassConstants.alertWindowEndDate,
                                Constant.omnitureEvars.eVar59 : self.anlyticsBedroomSize,
                                Constant.omnitureEvars.eVar60 : Constant.MyClassConstants.alertOriginationPoint
                            ]
                            
                            ADBMobile.trackAction(Constant.omnitureEvents.event52, data: userInfo)
                            
                            self.hideHudAsync()
                            
                            Constant.MyClassConstants.getawayAlertsArray.insert(rentalAlert, at: Constant.MyClassConstants.getawayAlertsArray.count)
                            SimpleAlert.alertTodismissController(self, title:Constant.AlertPromtMessages.createAlertTitle , message: Constant.AlertMessages.createAlertMessage)
                            rentalAlert.alertId = response.alertId
                            
                        })
                        { (error) in
                            
                            self.hideHudAsync()
                            SimpleAlert.alert(self, title: Constant.AlertPromtMessages.createAlertTitle, message: error.description)
                            
                        }
                    }
                    else {
                        
                        SimpleAlert.alert(self, title: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages.editAlertdetinationrequiredMessage)
                    }
                    
                }
                else {
                    
                    SimpleAlert.alert(self, title: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
                        .editAlertEmptyWidowEndDateMessage)
                    
                }
            }
            else {
                
                SimpleAlert.alert(self, title: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
                    .editAlertEmptyWidowStartDateMessage)
                
            }
            
        }
        else {
            
            SimpleAlert.alert(self, title: Constant.AlertPromtMessages.createAlertTitle, message: Constant.AlertMessages
                .editAlertEmptyNameMessage)
        }
        
    }
    
    
    //***** function to dismiss present view controller on back button pressed *****//
    func menuBackButtonPressed(sender:UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    //***** function to call calendar screen to select travel start date *****//
    @IBAction func travelStartDateCalendarIconPressed(_ sender:AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as! CalendarViewController
        viewController.requestedDateWindow = Constant.MyClassConstants.start
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    //***** function to call calendar screen to select travel end date *****//
    @IBAction func travelEndDateCalendarIconPressed(_ sender:AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle:     nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as! CalendarViewController
        viewController.requestedDateWindow = Constant.MyClassConstants.end
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.pushViewController(viewController, animated: true)
        
    }
    
    //***** function to call bedroom size screen to select bedroom size *****//
    @IBAction func selectRoomSizePressed(_ sender:AnyObject) {
        
        Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.createAlertViewController
        var mainStoryboard = UIStoryboard()
        
        mainStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BedroomSizeNav") as! UINavigationController
        
        let transitionManager = TransitionManager()
        self.navigationController?.transitioningDelegate = transitionManager
        self.navigationController!.present(viewController, animated: true, completion: nil)
        
    }
    
    //***** function to call search destination  screen to search destination by name *****//
    @IBAction func addLocationPressed(_ sender: IUIKButton) {
        
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.createAlert
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as! GoogleMapViewController
            viewController.sourceController = Constant.MyClassConstants.createAlert
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        else {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVC) as! GoogleMapViewController
            viewController.sourceController = Constant.MyClassConstants.createAlert
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            self.navigationController!.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//***** extensiion class to define tableview delegate methods *****//
extension CreateAlertViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

//***** extensiion class to define collectionview delegate methods *****//
extension CreateAlertViewController:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == selectedIndex) {
            
            selectedIndex = -1
            collectionView.reloadData()
        }
        else {
            
            self.selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    
    
    
}

extension CreateAlertViewController:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.customCellNibNames.wereToGoTableViewCell, for: indexPath as IndexPath) as! WhereToGoCollectionViewCell
        if(indexPath.row == selectedIndex ) {
            let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] as AnyObject
            if(object.isKind(of:NSArray.self)) {
                
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = false
            }
            else {
                
                cell.deletebutton.isHidden = false
                cell.infobutton.isHidden = true
            }
        }
        else {
            
            cell.deletebutton.isHidden = true
            cell.infobutton.isHidden = true
        }
        
        let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] as AnyObject
        if(object.isKind(of:Resort.self)) {
            
            var resortNm = ""
            var resortCode = ""
            if let restName = (object as! Resort).resortName {
                resortNm = restName
            }
            
            if let restcode = (object as! Resort).resortCode {
                
                resortCode = restcode
            }
            cell.lblTitle.text = "\(resortNm) (\(resortCode))"
            
        }else if(object.isKind(of:NSArray.self)){
            
            var resortNm = ""
            var resortCode = ""
            if let restName = (object.firstObject as! Resort).resortName {
                resortNm = restName
            }
            
            if let restcode = (object.firstObject as! Resort).resortCode {
                
                resortCode = restcode
            }
            var resortNameString = "\(resortNm) (\(resortCode))"
            if(object.count > 1){
                resortNameString = resortNameString.appending(" and \(object.count - 1) more")
            }
            
            cell.lblTitle.text = resortNameString
            
        }else  {
            
            let destName = (object as! AreaOfInfluenceDestination).destinationName
            
            let terocode = (object as! AreaOfInfluenceDestination).address!.territoryCode!
            cell.lblTitle.text = "\(destName!), \(terocode)"
            
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
extension CreateAlertViewController:UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: Constant.buttonTitles.remove) { (action,index) -> Void in
            if(Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count > 0) {
                
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeObject(at: indexPath.row)
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeObject(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                tableView.reloadSections(NSIndexSet(index:indexPath.section) as IndexSet, with: .automatic)
                tableView.setEditing(false, animated: true)
            })
        }
        delete.backgroundColor = UIColor(red: 224/255.0, green: 96.0/255.0, blue: 84.0/255.0, alpha: 1.0)
        
        
        let details = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.details) { (action,index) -> Void in
            
            if(Constant.RunningDevice.deviceIdiom == .pad){
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIpad, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
                viewController.selectedIndex = indexPath.row
                self.navigationController!.present(viewController, animated: true, completion: nil)
            }else{
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.getawayAlertsIphone, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.infoDetailViewController) as! InfoDetailViewController
                viewController.selectedIndex = indexPath.row
                self.navigationController!.present(viewController, animated: true, completion: nil)
            }
        }
        details.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        
        if((Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] as AnyObject) .isKind(of:NSMutableArray.self)){
            return [delete,details]
        }else{
            return [delete]
        }
        
    }
    
    @nonobjc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
    }
    
}

extension CreateAlertViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** adding custom add button to search destination or resort *****//
        
        if(Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count == 0 || indexPath.row == Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath as IndexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            
            let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width/2 - (UIScreen.main.bounds.width/5)/2, y: 10, width: UIScreen.main.bounds.width/5, height: 30))
            addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
            addLocationButton.setTitleColor(IUIKColorPalette.primary3.color, for: UIControlState.normal)
            addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
            addLocationButton.layer.cornerRadius = 6
            addLocationButton.layer.borderWidth = 2
            addLocationButton.addTarget(self, action: #selector(addLocationPressed), for: .touchUpInside)
            
            cell.addSubview(addLocationButton)
            
            return cell
        }
        else {
            
            let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoContentCell, for: indexPath as IndexPath) as! WhereToGoContentCell
            
            
            //***** condition to check for show hide or and seprator on cell *****//
            if(indexPath.row == Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count - 1 || Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count == 0) {
                
                cell.sepratorOr.isHidden = true
                cell.sepratorView.isHidden = true
            }
            else {
                
                cell.sepratorOr.isHidden = false
                cell.sepratorView.isHidden = false
            }
            let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[indexPath.row] as AnyObject
            if(object.isKind(of:Resort.self)) {
                
                var resortNm = ""
                var resortCode = ""
                if let restName = (object as! Resort).resortName {
                    resortNm = restName
                }
                
                if let restcode = (object as! Resort).resortCode {
                    
                    resortCode = restcode
                }
                cell.whereTogoTextLabel.text = "\(resortNm) (\(resortCode))"
                
            }else if(object.isKind(of:NSArray.self)){
                
                var resortNm = ""
                var resortCode = ""
                if let restName = (object.firstObject as! Resort).resortName {
                    resortNm = restName
                }
                
                if let restcode = (object.firstObject as! Resort).resortCode {
                    
                    resortCode = restcode
                }
                var resortNameString = "\(resortNm) (\(resortCode))"
                if(object.count > 1){
                    resortNameString = resortNameString.appending(" and \(object.count - 1) more")
                }
                cell.whereTogoTextLabel.text = resortNameString
                
            }else  {
                
                let destName = (object as! AreaOfInfluenceDestination).destinationName!
                
                let terocode = (object as! AreaOfInfluenceDestination).address?.territoryCode ?? ""
                cell.whereTogoTextLabel.text = "\(destName), \(String(describing: terocode))"
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CreateAlertViewController:WhereToGoCollectionViewCellDelegate {
    
    func deleteButtonClickedAtIndex(_ Index: Int) {
        
        if(Constant.MyClassConstants.selectedGetawayAlertDestinationArray.count > 0) {
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeObject(at: Index)
            selectedIndex = -1
        }
        let deletionIndexPath = IndexPath(item: Index, section: 0)
        self.createAlertCollectionView.deleteItems(at: [deletionIndexPath])
        
    }
    
    func infoButtonClickedAtIndex(_ Index: Int) {
        
    }
}
