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
    
    @IBOutlet weak var floatDetailsTableView:UITableView!
    
    weak var floatResortDetails = Resort()
    weak var floatUnitDetails = InventoryUnit()
    var selectedTextField = false
    var floatAttributesArray = NSMutableArray()
    
    /**
     PopcurrentViewcontroller from NavigationController
     - parameter sender: UIButton reference.
     - returns : No return.
     */
    @IBAction func floatCancelButtonIsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: Constant.storyboardNames.availableDestinationsIphone , bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    override func viewWillAppear(_ animated: Bool){
        floatDetailsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floatUnitDetails = Constant.MyClassConstants.relinquishmentSelectedWeek.unit!
        floatDetailsTableView.estimatedRowHeight = 200
        self.title = Constant.ControllerTitles.floatDetailViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(FloatDetailViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        getOrderedSections()
        
    }
    /**
     Pop up current viewcontroller from Navigation stack
     - parameter sender : UIBarButton Reference
     - returns : No value is return
     */
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        Constant.MyClassConstants.savedClubFloatResort = ""
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Call your resort button action
    @IBAction func callYourResortTapped(_sender: IUIKButton){
        if let url = URL(string: "tel://\(floatResortDetails!.phone!)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    // Select bedroom button action
    @IBAction func bedroomButtonTapped(_ sender:UIButton){
        self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
                Constant.MyClassConstants.buttontitle = Constant.buttonId.bedroomselection

    }
    
    // Select check - in date action
    @IBAction func selectCheckInDate(){
        Helper.getCheckInDatesForCalendar(senderViewController: self, resortCode: "WPN", relinquishmentYear: 2018)
    }
    
    //Save Float Details
    @IBAction func saveFloatDetails(){
        let indexPath = IndexPath(row: 3, section: 0)
        var reservationNumber = ""
        var unitNumber = "Unit #307"
        var noOfBedrooms = ""
        
        for subView in (self.floatDetailsTableView.cellForRow(at: indexPath)?.contentView.subviews)!{
            if(subView.isKind(of: UITextField.self )){
                print(subView)
                let tf = subView as! UITextField
                if(subView.tag == 1){
                    reservationNumber = tf.text!
                }else if(subView.tag == 2){
                    unitNumber = tf.text!
                }else{
                    noOfBedrooms = tf.text!
                }
            }
        }
        
        //Realm local storage for selected relinquishment
        let storedata = OpenWeeksStorage()
        let Membership = UserContext.sharedInstance.selectedMembership
        let relinquishmentList = TradeLocalData()
        
        let selectedOpenWeek = OpenWeeks()
        selectedOpenWeek.isFloat=true
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
        floatDetails.unitSize = noOfBedrooms
        selectedOpenWeek.floatDetails.append(floatDetails)
        
        let unitDetails = ResortUnitDetails()
        unitDetails.kitchenType = (Helper.getKitchenEnums(kitchenType: (self.floatUnitDetails?.kitchenType!)!))
        unitDetails.unitSize = (Helper.getBedroomNumbers(bedroomType: (self.floatUnitDetails?.unitSize!)!))//(self.unitDetails?.unitSize!)!
        selectedOpenWeek.unitDetails.append(unitDetails)
        
        selectedOpenWeek.resort.append(resort)
        relinquishmentList.openWeeks.append(selectedOpenWeek)
        storedata.openWeeks.append(relinquishmentList)
        storedata.membeshipNumber = Membership!.memberNumber!
        let realm = try! Realm()
        try! realm.write {
            realm.add(storedata)
        }
        
        
        // Open vacation search view controller
        var viewcontroller:UIViewController
        if (Constant.RunningDevice.deviceIdiom == .phone) {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
        }
        else{
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
        }
        
        
        //***** creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.0
        transition.timingFunction = timeFunc
        viewcontroller.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        UIApplication.shared.keyWindow?.rootViewController = viewcontroller
        
    }
    
    //Function to get ordered sections
    func getOrderedSections(){
        floatAttributesArray.removeAllObjects()
        floatAttributesArray.add(Constant.MyClassConstants.callResortAttribute)
        floatAttributesArray.add(Constant.MyClassConstants.resortDetailsAttribute)
        if (Constant.MyClassConstants.relinquishmentSelectedWeek.reservationAttributes.contains(Constant.MyClassConstants.resortClubAttribute)){
            floatAttributesArray.add(Constant.MyClassConstants.resortClubAttribute)
        }
        if(Constant.MyClassConstants.relinquishmentSelectedWeek.reservationAttributes.contains(Constant.MyClassConstants.resortReservationAttribute)){
            floatAttributesArray.add(Constant.MyClassConstants.resortReservationAttribute)
        }
        if(Constant.MyClassConstants.relinquishmentSelectedWeek.reservationAttributes.contains(Constant.MyClassConstants.checkInDateAttribute)){
            floatAttributesArray.add(Constant.MyClassConstants.checkInDateAttribute)
        }
        if(Constant.MyClassConstants.relinquishmentSelectedWeek.reservationAttributes.contains(Constant.MyClassConstants.unitNumberAttribute)){
            floatAttributesArray.add(Constant.MyClassConstants.unitNumberAttribute)
        }
        floatAttributesArray.add(Constant.MyClassConstants.saveAttribute)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
/** Extension for tableview data source */
extension FloatDetailViewController : UITableViewDataSource{
    /** number of rows in section */
    func numberOfSections(in tableView: UITableView) -> Int {
        return floatAttributesArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    /** cell for an indexPath */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  resortcallCell:CallYourResortTableViewCell?
        var vacationdetailcell:ResortDirectoryResortCell?
        var selectClubresortcell:ReservationTableViewCell!
        var registrationNumbercell:ReservationTableViewCell!
        var saveandcancelCell:FloatSaveAndCancelButtonTableViewCell?
        switch (floatAttributesArray[indexPath.section] as! String){
        case Constant.MyClassConstants.callResortAttribute:
            resortcallCell  = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
            return resortcallCell!
        case Constant.MyClassConstants.resortDetailsAttribute:
            vacationdetailcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.vacationdetailcellIdentifier) as? ResortDirectoryResortCell
            vacationdetailcell!.getCell(resortDetails: floatResortDetails!)

            return vacationdetailcell!
        case Constant.MyClassConstants.resortClubAttribute:
            selectClubresortcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.selectclubcellIdentifier) as! ReservationTableViewCell
            if(Constant.MyClassConstants.savedClubFloatResort != ""){
                selectClubresortcell.selectResortLabel.text = "\(String(describing: "Select a club resort"))\n\(Constant.MyClassConstants.savedClubFloatResort)"
            }
            return selectClubresortcell!
        case Constant.MyClassConstants.unitNumberAttribute:
                registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.attributesCell) as! ReservationTableViewCell
                return registrationNumbercell
        case Constant.MyClassConstants.saveAttribute:
            saveandcancelCell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.saveandcancelcellIdentifier) as? FloatSaveAndCancelButtonTableViewCell
            return saveandcancelCell!
        default:
            resortcallCell  = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
            return resortcallCell!
        }
    }
}
/** Extension for table view delegate **/
extension FloatDetailViewController : UITableViewDelegate{
	/**Height of Row at index path */
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
	}
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 2 || section == 3){
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.lightGray
        
        let headerText = UILabel(frame:CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width - 30, height: 50))
        headerText.font = UIFont(name:Constant.fontName.helveticaNeue, size:15)
        
        if(section == 2){
            headerText.text = Constant.HeaderViewConstantStrings.resortUnitDetails
        }else{
            headerText.text = Constant.HeaderViewConstantStrings.reservationDetails
        }
        
        headerView.addSubview(headerText)
        return headerView
    }
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 2
        {
            Helper.getResortsByClubFloatDetails(resortCode:floatResortDetails!.resortCode!, senderViewController:self, floatResortDetails:floatResortDetails!)
            Constant.MyClassConstants.buttontitle =  Constant.buttonId.resortSelection
        }
    }
}
/** Extension for done button in Bedroom Size Selection **/
extension FloatDetailViewController : BedroomSizeViewControllerDelegate{
    
    func doneButtonClicked(selectedUnitsArray:NSMutableArray){
        let bedroomTextField = self.view.viewWithTag(3) as! UITextField!
        var bedroomString = ""
        for index in selectedUnitsArray{
            bedroomString = "\(bedroomString)\(UnitSize.forDisplay[index as! Int].friendlyName()) "
            bedroomTextField!.text = ""
            bedroomTextField!.text = bedroomString
        }
    }

}

/** Extension for text field **/
extension FloatDetailViewController : UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //selectedTextField = false
        //textField.resignFirstResponder()
        return true
    }
}
