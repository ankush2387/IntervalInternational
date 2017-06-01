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
    weak var unitDetails = InventoryUnit()
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
        unitDetails = Constant.MyClassConstants.relinquishmentSelectedWeek.unit!
        floatDetailsTableView.estimatedRowHeight = 200
        self.title = Constant.ControllerTitles.floatDetailViewController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(FloatDetailViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
        
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
//        Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.floatViewController
//        var mainStoryboard = UIStoryboard()
//        if(Constant.RunningDevice.deviceIdiom == .pad) {
//            mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIpad, bundle: nil)
//        }
//        else {
//            mainStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
//        }
//        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as! BedroomSizeViewController
//        viewController.delegate = self
//        let transitionManager = TransitionManager()
//        self.navigationController?.transitioningDelegate = transitionManager
//        self.navigationController!.present(viewController, animated: true, completion: nil)
        
        self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
                Constant.MyClassConstants.buttontitle = Constant.buttonId.bedroomselection

    }
    
    // Select check - in date action
    @IBAction func selectCheckInDate(){
        Helper.getCheckInDatesForCalendar(senderViewController: self, resortCode: floatResortDetails!.resortCode!, relinquishmentYear: 2018)
    }
    
    //Save Float Details
    @IBAction func saveFloatDetails(){
        let indexPath = IndexPath(row: 3, section: 0)
        var reservationNumber = ""
        var unitNumber = "#309"
        var noOfBedrooms = ""
        
        for subView in (self.floatDetailsTableView.cellForRow(at: indexPath)?.contentView.subviews)!{
            if(subView.isKind(of: UITextField.self )){
                let tf = subView as! UITextField
                if(tf.tag == 1){
                    reservationNumber = tf.text!
                }else if(tf.tag == 2){
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
        let resort = ResortList()
        resort.resortName = (floatResortDetails?.resortName)!
        
        let floatDetails = ResortFloatDetails()
        floatDetails.reservationNumber = reservationNumber
        floatDetails.unitNumber = unitNumber
        floatDetails.unitSize = noOfBedrooms
        selectedOpenWeek.floatDetails.append(floatDetails)
        
        let unitDetails = ResortUnitDetails()
        unitDetails.kitchenType = (Helper.getKitchenEnums(kitchenType: (self.unitDetails?.kitchenType!)!))
        unitDetails.unitSize = (Helper.getBedroomNumbers(bedroomType: (self.unitDetails?.unitSize!)!))//(self.unitDetails?.unitSize!)!
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
/** Extension for tableview data source */
extension FloatDetailViewController : UITableViewDataSource{
    /** number of rows in section */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    /** cell for an indexPath */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  resortcallCell:CallYourResortTableViewCell?
        var vacationdetailcell:ResortDirectoryResortCell?
        var selectClubresortcell:ReservationTableViewCell!
        var registrationNumbercell:ReservationTableViewCell!
        var saveandcancelCell:FloatSaveAndCancelButtonTableViewCell?
        switch (indexPath as NSIndexPath).row{
        case 0:
            resortcallCell  = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.resortcallidentifer) as? CallYourResortTableViewCell
            resortcallCell!.getCell()
            return resortcallCell!
        case 1:
            vacationdetailcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.vacationdetailcellIdentifier) as? ResortDirectoryResortCell
            vacationdetailcell!.getCell(resortDetails: floatResortDetails!)

            return vacationdetailcell!
        case 2:
            selectClubresortcell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.selectclubcellIdentifier) as! ReservationTableViewCell
            if(Constant.MyClassConstants.savedClubFloatResort != ""){
                selectClubresortcell.selectResortLabel.text = Constant.MyClassConstants.savedClubFloatResort
            }
            return selectClubresortcell!
        case 3:
            registrationNumbercell = tableView.dequeueReusableCell(withIdentifier: Constant.floatDetailViewController.registrationNumbercellIdentifier) as! ReservationTableViewCell
            registrationNumbercell.getCell()
            return registrationNumbercell
        case 4:
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
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 2
        {
            self.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)
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
