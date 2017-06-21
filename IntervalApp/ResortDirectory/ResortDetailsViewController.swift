//
//  ResortDetailsViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/27/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import GoogleMaps
import IntervalUIKit
import DarwinSDK
import SVProgressHUD
import RealmSwift
import MessageUI
import Foundation

class ResortDetailsViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var tableViewResorts:UITableView!
    @IBOutlet weak var imageIndexLabel:UILabel!
    @IBOutlet weak var headerTextForShowingResortCounter: UILabel!
    
    
    //***** Class Variables *****//
    var bounds = GMSCoordinateBounds()
    var actionSheetTable:UITableView!
    var tableViewController = UIViewController()
    var mapView = GMSMapView()
    var locationManager = CLLocationManager()
    var nearbyArray : NSMutableArray = []
    var onsiteArray : NSMutableArray = []
    var amenityOnsiteString : String! = "Nearby" + "\n"
    var amenityNearbyString : String!  = "On-Site" + "\n"
    
    //***** Class private Variables *****//
    fileprivate var startIndex = 0
    fileprivate var arrayRunningIndex = 0
    fileprivate var resortDescriptionArrayContainer:NSMutableArray = []
    fileprivate var placeSelectionMainDictionary = [Int:[Int:Bool]]()
    fileprivate var tappedButtonDictionary = [Int:Bool]()
    fileprivate let moreNavArray = ["Share via email","Share via text","Tweet","Facebook","Pinterest"]
    
    var senderViewController : String? = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        }
        // Notification to perform vacation search after user pre-login
        NotificationCenter.default.addObserver(self, selector: #selector(showVacationSearch), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        
        
        if(self.headerTextForShowingResortCounter != nil) {
            
            self.headerTextForShowingResortCounter.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
        }
        if(Constant.MyClassConstants.resortsDescriptionArray.amenities.count>0) {
            
            Constant.MyClassConstants.amenitiesDictionary.removeAllObjects()
            
            nearbyArray.removeAllObjects()
            onsiteArray.removeAllObjects()
            print(Constant.MyClassConstants.resortsDescriptionArray.amenities.count)
            for amenity in Constant.MyClassConstants.resortsDescriptionArray.amenities{
                
                
                if(amenity.nearby == true){
                    
                    nearbyArray.add(amenity.amenityName!)
                    amenityOnsiteString = amenityOnsiteString + "\n" + "  " + amenity.amenityName!
                    
                }else{
                    
                    onsiteArray.add(amenity.amenityName!)
                    amenityNearbyString = amenityNearbyString + "\n" + "  " + amenity.amenityName!
                    
                }
                Constant.MyClassConstants.amenitiesDictionary.setValue(nearbyArray, forKey: Constant.MyClassConstants.nearbyDictKey)
                Constant.MyClassConstants.amenitiesDictionary.setValue(onsiteArray, forKey: Constant.MyClassConstants.onsiteDictKey)
            }
            
            self.tableViewResorts.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // omniture tracking with event 35
        if(Constant.MyClassConstants.resortsDescriptionArray.resortCode != nil){
            let userInfo: [String: String] = [
                Constant.omnitureCommonString.productItem : Constant.MyClassConstants.resortsDescriptionArray.resortCode!,
                Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
            ]
            
            ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
        }
        self.startIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex
        self.resortDescriptionArrayContainer.add(Constant.MyClassConstants.resortsDescriptionArray)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableViewResorts.reloadData()
    }
    
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tableViewResorts.reloadData()
        for collView in self.tableViewResorts.subviews{
            if(collView .isKind(of: UICollectionView.self)){
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(Constant.RunningDevice.deviceIdiom == .phone){
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //***** Function call for previous resort button *****//
    @IBAction func previousResortButtonPressed(_ sender: UIButton) {
        if(self.startIndex < Constant.MyClassConstants.vacationSearchContentPagerRunningIndex && arrayRunningIndex > 0) {
            
            Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1
            if(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex == 1){
                //sender.isEnabled = false
            }
            self.arrayRunningIndex = arrayRunningIndex - 1
            Constant.MyClassConstants.resortsDescriptionArray = self.resortDescriptionArrayContainer[ self.arrayRunningIndex] as! Resort
            Constant.MyClassConstants.imagesArray.removeAllObjects()
            let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
            for imgStr in imagesArray {
                if(imgStr.size == Constant.MyClassConstants.imageSize) {
                    
                    Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                }
            }
            self.headerTextForShowingResortCounter.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
            
            self.tableViewResorts.reloadData()
            // omniture tracking with event 35
            let userInfo: [String: String] = [
                Constant.omnitureCommonString.productItem : Constant.MyClassConstants.resortsDescriptionArray.resortCode!,
                Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
            ]
            
            ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
        }
        else {
            if(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex == 1){
                //sender.isEnabled = false
            }else{
                //sender.isEnabled = true
            }
            if(startIndex > 1) {
                Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1
                //sender.isEnabled = true
                self.startIndex = startIndex - 1
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()
                //Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1
                
                let resortCode = Constant.MyClassConstants.resortsArray[Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1].resortCode
                
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode:resortCode!, onSuccess: { (response) in
                    
                    
                    self.resortDescriptionArrayContainer.insert(response, at: 0)
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAllObjects()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray {
                        if(imgStr.size == Constant.MyClassConstants.imageSize) {
                            
                            Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                        }
                    }
                    self.headerTextForShowingResortCounter.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    self.tableViewResorts.reloadData()
                    })
                { (error) in
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SimpleAlert.alert(self, title:Constant.AlertErrorMessages.errorString, message: error.description)
                }
            }else{
                //sender.isEnabled = false
            }
        }
    }
    
    //***** Function call for next resort button *****//
    @IBAction func nextResortButtonPressed(_ sender: UIButton) {
        
        if(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex < Constant.MyClassConstants.resortsArray.count) {
            
            if(self.resortDescriptionArrayContainer.count - 1 < Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) {
                self.arrayRunningIndex = arrayRunningIndex + 1
                let resortCode = Constant.MyClassConstants.resortsArray[Constant.MyClassConstants.vacationSearchContentPagerRunningIndex].resortCode
                
                Helper.addServiceCallBackgroundView(view: self.view)
                SVProgressHUD.show()
                
                
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode:resortCode!, onSuccess: { (response) in
                    
                    
                    self.resortDescriptionArrayContainer.add(response)
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAllObjects()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray {
                        if(imgStr.size == Constant.MyClassConstants.imageSize) {
                            
                            Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                        }
                    }
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex + 1
                    if(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex == Constant.MyClassConstants.resortsArray.count){
                        //sender.isEnabled = false
                    }else{
                        //sender.isEnabled = true
                    }
                    self.headerTextForShowingResortCounter.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    self.tableViewResorts.reloadData()
                    // omniture tracking with event 35
                    let userInfo: [String: String] = [
                        Constant.omnitureCommonString.productItem : Constant.MyClassConstants.resortsDescriptionArray.resortCode!,
                        Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
                    ]
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
                    })
                { (error) in
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SimpleAlert.alert(self, title:"Error", message: error.description)
                }
                
            }
            else {
                Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex + 1
                if(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex == Constant.MyClassConstants.resortsArray.count){
                    //sender.isEnabled = false
                }else{
                    //sender.isEnabled = true
                }
                self.arrayRunningIndex = arrayRunningIndex + 1
                
                Constant.MyClassConstants.resortsDescriptionArray = self.resortDescriptionArrayContainer[ self.arrayRunningIndex] as! Resort
                Constant.MyClassConstants.imagesArray.removeAllObjects()
                let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                for imgStr in imagesArray {
                    if(imgStr.size == Constant.MyClassConstants.imageSize) {
                        
                        Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                    }
                }
                self.headerTextForShowingResortCounter.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
                
                self.tableViewResorts.reloadData()
                
            }
        }
    }
    //***** Function call for Done button *****//
    
    @IBAction func doneButtonClicked(_ sender: AnyObject){
        if(UIDevice().userInterfaceIdiom == .pad){
            
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
        }else{
            if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.vacationSearchFunctionalityCheck){
                
                self.dismiss(animated: true, completion: nil)
                
                
            }else{
                
                let transition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionReveal
                transition.subtype = kCATransitionFromBottom
                navigationController?.view.layer.add(transition, forKey: nil)
                _ = navigationController?.popViewController(animated: false)
            }
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    //***** Function call for search button pressed. *****//
    
    func searchVacationClicked(){
        if((UserContext.sharedInstance.accessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {
            let realm = try! Realm()
            let allDest = Helper.getLocalStorageWherewanttoGo()
            if (allDest.count > 0) {
                try! realm.write{
                    realm.deleteAll()
                }
            }
            let allavailabledest = AllAvailableDestination()
            allavailabledest.destination = Constant.MyClassConstants.allDestinations
            let dict = Constant.MyClassConstants.resortsDescriptionArray
            let address = dict.address
            
            //realm local storage for selected resort
            let storedata = RealmLocalStorage()
            let Membership = UserContext.sharedInstance.selectedMembership
            let resortList = ResortList()
            resortList.resortCityName = (address?.cityName)!
            resortList.resortCode = dict.resortCode!
            resortList.thumbnailurl = dict.images[0].url!
            resortList.resortName = "\(dict.resortName!) - \(dict.resortCode!)"
            resortList.territorrycode = (address?.territoryCode)!
            storedata.resorts.append(resortList)
            storedata.membeshipNumber = Membership!.memberNumber!
            try! realm.write {
                realm.add(storedata)
            }
            var storyboard = UIStoryboard()
            if(Constant.RunningDevice.deviceIdiom == .pad){
                storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            }else{
                storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            }
            self.present((storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController)!, animated: true, completion: nil)
        }else{
            var storyboard = UIStoryboard()
            var viewController = UIViewController()
            if(Constant.RunningDevice.deviceIdiom == .pad){
                storyboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
                viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginViewControlleriPad)
            }else{
                storyboard = UIStoryboard(name: Constant.storyboardNames.signInPreLoginController, bundle: nil)
                viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController)
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    //***** Function call for More button *****//
    
    @IBAction func moreButtonClicked(_ sender: AnyObject){
        if(UIDevice().userInterfaceIdiom == .pad){
        }else{
            createActionSheetForSharing(self)
        }
    }
    
    
    //Used to expand and contract sections
    @IBAction func toggleButtonIsTapped(_ sender: UIButton) {
        if let tag = tappedButtonDictionary[sender.tag]{
            if tag{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
            else{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
            
        }
        else{
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.tableViewResorts.reloadSections(IndexSet(integer: sender.tag), with:.automatic)
        
    }
    //Function for forward button
    @IBAction func forwardButtonClicked(_ sender:AnyObject){
        imageIndexLabel.text = "Resort of "
    }
    //Function for backward button
    @IBAction func backButtonClicked(_ sender:AnyObject){
        
    }
    
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func createActionSheetForSharing(_ viewController:UIViewController){
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            //            tableActionSheet.registerNib(UINib(nibName: Constant.customCellNibNames.actionSheetTblCell, bundle: nil), forCellReuseIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell)
            //            self.view.addSubview(self.viewActionSheet)
            //            self.viewActionSheet.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
            //            self.viewActionSheet.hidden = false
        }else{
            
            let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat(5 * 50))
            self.tableViewController.preferredContentSize = rect.size
            
            self.actionSheetTable = UITableView(frame: rect)
            
            actionSheetTable.register(UINib(nibName: Constant.customCellNibNames.actionSheetTblCell, bundle: nil), forCellReuseIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell)
            self.actionSheetTable.delegate = self
            self.actionSheetTable.dataSource = self
            self.actionSheetTable.separatorStyle = UITableViewCellSeparatorStyle.none
            self.actionSheetTable.isUserInteractionEnabled = true
            self.actionSheetTable.allowsSelection = true
            self.actionSheetTable.tag = 1
            
            tableViewController.view.addSubview(self.actionSheetTable)
            tableViewController.view.bringSubview(toFront: self.actionSheetTable)
            tableViewController.view.isUserInteractionEnabled = true
            
            let actionSheet:UIAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let attributedString = NSAttributedString(string: Constant.actionSheetAttributedString.sharingOptions, attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 20),
                NSForegroundColorAttributeName : UIColor.black
                ])
            
            let action:UIAlertAction = UIAlertAction(title: Constant.AlertPromtMessages.cancel, style: UIAlertActionStyle.cancel, handler: nil)
            
            actionSheet.setValue(attributedString, forKey: Constant.actionSheetAttributedString.attributedTitle)
            actionSheet.setValue(tableViewController, forKey: Constant.actionSheetAttributedString.contentViewController)
            actionSheet.addAction(action)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    /***** Function to call vacation search after pre login *****/
    
    func showVacationSearch(){
        //Added a delay to present vacation search view controller.
        if(self.senderViewController == Constant.MyClassConstants.searchResult){
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchVacationClicked), userInfo: nil, repeats: false)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//****** Extension for resort details table view****//
extension ResortDetailsViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(section == 3){
            return 44
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView.tag == 1){
            return 50
        }else{
            switch ((indexPath as NSIndexPath).section) {
            case 0:
                return tableView.frame.size.width/2 + 100
            case 1:
               
                if(Constant.MyClassConstants.resortsDescriptionArray.description != nil){
                    if((Constant.MyClassConstants.resortsDescriptionArray.description?.characters.count)! > 0){

                        var height:CGFloat
                        if(Constant.RunningDevice.deviceIdiom == .pad){
                            let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                            height = heightForView(Constant.MyClassConstants.resortsDescriptionArray.description!, font: font!, width: (Constant.MyClassConstants.runningDeviceWidth!/2) - 40)
                            return height + 60
                        }else{
                            let font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
                            height = heightForView(Constant.MyClassConstants.resortsDescriptionArray.description!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth! - 40)
                            return height + 40
                        }
                    }else{
                        return 60
                    }
                }else{
                    return 0
                }
            case 2:
                if(Constant.RunningDevice.deviceIdiom == .pad) {
                    
                    return 0
                }
                else {
                    
                    return 200
                }
                
                
            default:
                if let isOpen = tappedButtonDictionary[(indexPath as NSIndexPath).section]{
                    if isOpen && (indexPath as NSIndexPath).row>0{
                        
                        let count = nearbyArray.count + onsiteArray.count
                        if(count>0){
                            if((indexPath as NSIndexPath).section == 3){
                                return 50
                            }else if((indexPath as NSIndexPath).section == 4){
                                
                                let count = nearbyArray.count + onsiteArray.count
                                if(count>0){
                                    if((indexPath as NSIndexPath).section == 3){
                                        return 50
                                    }else if((indexPath as NSIndexPath).section == 4){
                                        if(count == 1){
                                            return CGFloat (count * 20 + 60)
                                        }else{
                                            return CGFloat (count * 20 + 120)
                                        }
                                        
                                    }else if((indexPath as NSIndexPath).section == 5){
                                        return 80
                                    }else{
                                        return 600
                                    }
                                    
                                }else{
                                    return 60
                                }
                            }else if((indexPath as NSIndexPath).section == 5){
                                return 80
                            }else{
                                return 600
                            }
                            
                        }else{
                            return 60
                        }
                    }else{
                        return 60
                    }
                }else{
                    if(indexPath.row == 0){
                        return 60
                    }else{
                        return 0
                    }
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if table is action sheet
        if(tableView.tag == 1){
            switch (indexPath as NSIndexPath).row {
            case 0:
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    
                    self.dismiss(animated: true, completion: {
                        self.present(mailComposeViewController, animated: true, completion: nil)
                    })
                } else {
                    self.showSendMailErrorAlert()
                }
            case 1:
                let txtComposeViewController = configuredMessageComposeViewController()
                if MFMessageComposeViewController.canSendText() {
                    
                    self.dismiss(animated: true, completion: {
                        self.present(txtComposeViewController, animated: true, completion: nil)
                    })
                } else {
                    SimpleAlert.alert(self, title: "Could Not Send Text Message" , message: "This device is not able/configured to send Text Messages.")
                }
                break
            default:
                break
            }
        }
        else {
            
            if((indexPath as NSIndexPath).section == 2) {
                
                self.performSegue(withIdentifier: Constant.segueIdentifiers.detailMapSegue, sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: Constant.MyClassConstants.runningDeviceWidth!, height: 44))
        viewHeader.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        let lineTop = UIView(frame: CGRect(x: 0, y: 0, width: Constant.MyClassConstants.runningDeviceWidth!, height: 1))
        lineTop.backgroundColor = UIColor.lightGray
        viewHeader.addSubview(lineTop)
        
        let lineBottom = UIView(frame: CGRect(x: 0, y: 43, width: Constant.MyClassConstants.runningDeviceWidth!, height: 1))
        lineBottom.backgroundColor = UIColor.lightGray
        viewHeader.addSubview(lineBottom)
        
        let labelHeader = UILabel(frame: CGRect(x: 20, y: 0, width: Constant.MyClassConstants.runningDeviceWidth!-40, height: 44))
        labelHeader.text = "Resort Info"
        labelHeader.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
        labelHeader.textColor = UIColor.black
        viewHeader.addSubview(labelHeader)
        return viewHeader
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["abc@gmail.com"])
        mailComposerVC.setSubject("Resort Details")
        
        var body: String = "<html><body><h1>My Image as below</h1> <br/>"
        
        if let imageData = UIImagePNGRepresentation(UIImage(named:"sanci_main01_r")!) // Get the image from ImageView and convert to NSData
        {
            let base64String: String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions())
            body = body + "<div><img src='data:image/png;base64,\(base64String)' height='100' width='150'/></div>"
        }
        body = body + "</body></html>"
        mailComposerVC.setMessageBody(body, isHTML: true)
        
        //mailComposerVC.setMessageBody("Have a look at this resort!", isHTML: false)
        
        return mailComposerVC
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposerVC = MFMessageComposeViewController()
        messageComposerVC.messageComposeDelegate = self
        var message = ""
        if let name = Constant.MyClassConstants.resortsDescriptionArray.resortName {
            message.append("Resort Name: \(name)/n")
        }
        
        if let code  = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
            message.append("Resort Code: \(code)")
        }
        
        messageComposerVC.body = message
        
        return messageComposerVC
    }
    
    func showSendMailErrorAlert() {
        SimpleAlert.alert(self, title: "Could Not Send Email" , message: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
    
}

extension ResortDetailsViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView.tag == 1){
            return 1
        }else{
            if(senderViewController == Constant.MyClassConstants.searchResult){
                return 8
            }else{
                return 7
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if table is action sheet
        if(tableView.tag == 1){
            return 5
        }else{
            if(Constant.MyClassConstants.resortsDescriptionArray.resortName != nil){
                
                if (section >= 3) {
                    if let isOpen = tappedButtonDictionary[section]{
                        if isOpen{
                            if(section == 5){
                                var resortCategory:[ResortRatingCategory]
                                if(Constant.MyClassConstants.resortsDescriptionArray.rating?.categories != nil){
                                    resortCategory = (Constant.MyClassConstants.resortsDescriptionArray.rating?.categories)!
                                    return resortCategory.count + 1
                                }else{
                                    return 1
                                }
                                
                            }else if(section == 3){
                                if(Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name != nil){
                                    
                                    return 2
                                }else{
                                    
                                    return 1
                                }
                            }else if(section == 6){
                                if Constant.MyClassConstants.resortsDescriptionArray.tdiUrl != nil{
                                     return 2
                                }else{
                                    return 1
                                }
                            }else{
                                return 2
                            }
                            
                        }else{
                            return 1
                        }
                    }else{
                        return 1
                    }
                }else if (section == 0){
                    if(Constant.MyClassConstants.resortsDescriptionArray.resortName != nil){
                        return 1
                    }else{
                        return 0
                    }
                }else{
                    return 1
                }
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Check if table is action sheet
        if(tableView.tag == 1){
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.actionSheetCell)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.actionSheetCell, for: indexPath)
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 49))
            
            titleLabel.text = moreNavArray[(indexPath as NSIndexPath).row]
            titleLabel.textAlignment = NSTextAlignment.center
            cell.contentView.addSubview(titleLabel)
            
            let bottomLine = UIView(frame: CGRect(x: 0, y: 49, width: tableView.bounds.width, height: 1))
            bottomLine.backgroundColor = UIColor.lightGray
            cell.contentView.addSubview(bottomLine)
            
            return cell
        }else{
            
            
            switch (indexPath as NSIndexPath).section {
            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.resortDirectoryResortCell, for: indexPath) as! ResortDirectoryResortCell
                
                for layer in cell.resortNameGradientView.layer.sublayers!{
                    if(layer.isKind(of: CAGradientLayer.self)) {
                        layer.removeFromSuperlayer()
                    }
                }
                let status = Helper.isResrotFavorite(resortCode: Constant.MyClassConstants.resortsDescriptionArray.resortCode!)
                if(status) {
                    cell.fevoriteButton.isSelected = true
                }else {
                    cell.fevoriteButton.isSelected = false
                }
                cell.resortNameGradientView.backgroundColor = UIColor.clear
                let frame = CGRect(x: 0, y: 300-68, width: cell.frame.size.width + 200, height: cell.resortNameGradientView.frame.size.height)
                cell.resortNameGradientView.frame = frame
                Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
                cell.resortCollectionView.collectionViewLayout.invalidateLayout()
                cell.resortCollectionView.reloadData()
                cell.resortName.text = Constant.MyClassConstants.resortsDescriptionArray.resortName
                cell.resortAddress.text = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName
                cell.resortCode.text = Constant.MyClassConstants.resortsDescriptionArray.resortCode
                let imageStr = Helper.getTierImageName(tier: Constant.MyClassConstants.resortsDescriptionArray.tier!)
                cell.tierImageView.image = UIImage(named: imageStr)
                cell.fevoriteButton.addTarget(self, action: #selector(favoritesButtonClicked(_:)), for: .touchUpInside)
                cell.backgroundColor = UIColor.clear
                
                return cell
            case 2 :
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.mapTableViewCell, for: indexPath)
                let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude)!, longitude: (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.longitude)!, zoom: 15)
                let mapframe = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.contentView.frame.height)
                
                mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
                mapView.isUserInteractionEnabled = false
                mapView.isMyLocationEnabled = true
                if (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude) != nil {
                    
                    let  position = CLLocationCoordinate2DMake((Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude)!,(Constant.MyClassConstants.resortsDescriptionArray.coordinates?.longitude)!)
                    let marker = GMSMarker()
                    marker.position = position
                    
                    marker.isFlat = false
                    marker.icon = UIImage(named:Constant.assetImageNames.pinSelectedImage)
                    marker.appearAnimation = GMSMarkerAnimation.pop
                    marker.map = mapView
                }
                mapView.settings.myLocationButton = true
                cell.contentView.addSubview(mapView)
                return cell
            case 1 :
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell, for: indexPath) as! ResortDirectoryResortCell
                cell.resortName.text = Constant.MyClassConstants.resortsDescriptionArray.description
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.vacationSearchCell, for: indexPath) as! ResortDirectoryResortCell
                cell.searchVacationButton?.addTarget(self, action: #selector(searchVacationClicked), for: .touchUpInside)
                return cell
            default :
                var availabledestionCountryOrContinentsCell :AvailableDestinationCountryOrContinentsTableViewCell?
                var availableCountryCell:AvailableDestinationPlaceTableViewCell?
                let ratingTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.ratingCell)
                
                availabledestionCountryOrContinentsCell?.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[(indexPath as NSIndexPath).section - 3]
                availabledestionCountryOrContinentsCell?.isUserInteractionEnabled = false
                availableCountryCell?.isUserInteractionEnabled = false
                
                if let isOpen = tappedButtonDictionary[(indexPath as NSIndexPath).section]{
                    availabledestionCountryOrContinentsCell?.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[(indexPath as NSIndexPath).section - 3]
                    if isOpen && (indexPath as NSIndexPath).row > 0 {
                        
                        if ((indexPath as NSIndexPath).section == 6) {
                            
                            if((indexPath as NSIndexPath).row > 0) {
                                availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.tdiCell) as? AvailableDestinationPlaceTableViewCell
                            }
                            
                        }else if ((indexPath as NSIndexPath).section == 5) {
                            if((indexPath as NSIndexPath).row > 0){
                                availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.ratingCell) as? AvailableDestinationPlaceTableViewCell
                                
                                
                            }
                        }else{
                            availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationPlaceTableViewCell) as? AvailableDestinationPlaceTableViewCell
                        }
                        
                        if let _ = placeSelectionMainDictionary[(indexPath as NSIndexPath).section]{
                            availableCountryCell?.getCell(indexPath,selectedPlaceDictionary:placeSelectionMainDictionary[(indexPath as NSIndexPath).section]!)
                        }
                        else{
                            availableCountryCell?.getCell(indexPath)
                        }
                        
                        if((indexPath as NSIndexPath).section == 3){
                            availableCountryCell?.infoLabel.isHidden = false
                           
                            if(Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name != nil){
                                var airportAdress = "Nearest Airport" + "\n" + (Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name)! + "/"
                                airportAdress = airportAdress + (Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.code)! + " /\(Constant.MyClassConstants.resortsDescriptionArray.nearestAiport!.distanceInMiles) Miles /\(Constant.MyClassConstants.resortsDescriptionArray.nearestAiport!.distanceInKilometers) KM"
                                availableCountryCell?.infoLabel.text = airportAdress
                            }else{
                                availableCountryCell?.infoLabel.text = ""
                            }
                            
                            
                        }else if((indexPath as NSIndexPath).section == 4){
                            availableCountryCell?.infoLabel.isHidden = false
                            availableCountryCell?.infoLabel.numberOfLines = 0
                            if(nearbyArray.count>0){
                                availableCountryCell?.infoLabel.text = amenityOnsiteString + " " + amenityNearbyString
                            }else{
                                availableCountryCell?.infoLabel.text = amenityNearbyString
                            }
                        }
                        else if ((indexPath as NSIndexPath).section == 6){
                            availableCountryCell?.tdiImageView.backgroundColor = UIColor.lightGray
                            if(Constant.MyClassConstants.resortsDescriptionArray.tdiUrl!.characters.count != 0){
                                let url = URL(string:  Constant.MyClassConstants.resortsDescriptionArray.tdiUrl!)
                                availableCountryCell?.tdiImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                            }else{
                              availableCountryCell?.tdiImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                            }
                        }else if((indexPath as NSIndexPath).section == 5){
                            var resortCategory:[ResortRatingCategory]
                            resortCategory = (Constant.MyClassConstants.resortsDescriptionArray.rating?.categories)!
                            
                            availableCountryCell?.infoLabel.text =  Helper.getRatingCategory(category: resortCategory[indexPath.row - 1].categoryCode!!) + "\n" + " \(resortCategory[indexPath.row - 1].rating)"
                            
                            
                            let resortRating = "\(resortCategory[indexPath.row - 1].rating)"
                            let ratingArray = resortRating.components(separatedBy: ".")
                            var image_X:CGFloat = 25.0
                            for _ in 0..<resortCategory[indexPath.row - 1].rating {
                                let imgVwRating = UIImageView()
                                imgVwRating.backgroundColor = UIColor.orange
                                imgVwRating.frame = CGRect(x:image_X, y:50, width:10, height:10)
                                imgVwRating.layer.cornerRadius = 5
                                availableCountryCell?.contentView.addSubview(imgVwRating)
                                image_X = image_X + 15
                                
                            }
                            if((ratingArray.last!.characters.count) > 1) {
                                let imgVwRating = UIImageView()
                                imgVwRating.backgroundColor = UIColor.orange
                                imgVwRating.frame = CGRect(x:image_X, y:50, width:20, height:20)
                                imgVwRating.layer.cornerRadius = 10
                                availableCountryCell?.contentView.addSubview(imgVwRating)
                                image_X = image_X + 25
                            }
                            
                            
                        }else{
                            var resortCategory:[ResortRatingCategory]
                            resortCategory = (Constant.MyClassConstants.resortsDescriptionArray.rating?.categories)!
                            
                            availableCountryCell?.infoLabel.text =  Helper.getRatingCategory(category: resortCategory[indexPath.row - 1].categoryCode!!) + "\n" + " \(resortCategory[indexPath.row - 1].rating)"
                            
                            
                            
                            var image_X:CGFloat = 0.0
                            for _ in 0..<resortCategory[indexPath.row - 1].rating {
                                let imgVwRating = availableCountryCell?.tdiImageView
                                imgVwRating!.backgroundColor = UIColor.orange
                                imgVwRating!.frame = CGRect(x:image_X, y:20, width:20, height:20)
                                ratingTableViewCell!.contentView.addSubview(imgVwRating!)
                                image_X = image_X + 30
                                
                            }
                            //return ratingTableViewCell!
                            
                        }
                        return availableCountryCell!
                    }
                    else{
                        availabledestionCountryOrContinentsCell  = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationCountryOrContinentsTableViewCell) as? AvailableDestinationCountryOrContinentsTableViewCell
                        availabledestionCountryOrContinentsCell?.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[(indexPath as NSIndexPath).section - 3]
                        if let selectedPlacedictionary = placeSelectionMainDictionary[(indexPath as NSIndexPath).section]{
                            availabledestionCountryOrContinentsCell?.getCell((indexPath as NSIndexPath).section,islistOfCountry:isOpen,selectedPlaceDictionary:selectedPlacedictionary)
                        }
                        else{
                            availabledestionCountryOrContinentsCell?.getCell((indexPath as NSIndexPath).section,islistOfCountry:isOpen)
                        }
                        
                        
                        return availabledestionCountryOrContinentsCell!
                    }
                }
                else{
                    availabledestionCountryOrContinentsCell  = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationCountryOrContinentsTableViewCell) as? AvailableDestinationCountryOrContinentsTableViewCell
                    
                    availabledestionCountryOrContinentsCell?.getCell((indexPath as NSIndexPath).section)
                    availabledestionCountryOrContinentsCell?.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[(indexPath as NSIndexPath).section - 3]
                    
                    return availabledestionCountryOrContinentsCell!
                    
                    
                }
            }
        }
    }
    
    func favoritesButtonClicked(_ sender:IUIKButton){
        
        if(UserContext.sharedInstance.accessToken != nil) {
            
            if (sender.isSelected == false){
                
                SVProgressHUD.show()
                Helper.addServiceCallBackgroundView(view: self.view)
                UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsDescriptionArray.resortCode!, onSuccess: {(response) in
                    
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(Constant.MyClassConstants.resortsDescriptionArray.resortCode!)
                    self.tableViewResorts.reloadData()
                     ADBMobile.trackAction(Constant.omnitureEvents.event48, data: nil)
                }, onError: {(error) in
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    print(error)
                })
            }
            else {
                SVProgressHUD.show()
                Helper.addServiceCallBackgroundView(view: self.view)
                UserClient.removeFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsDescriptionArray.resortCode!, onSuccess: {(response) in
                    
                  
                    sender.isSelected = false
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.dismiss()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(Constant.MyClassConstants.resortsDescriptionArray.resortCode!)
                    self.tableViewResorts.reloadData()
                    ADBMobile.trackAction(Constant.omnitureEvents.event51, data: nil)
                }, onError: {(error) in
                    
                    SVProgressHUD.dismiss()
                    Helper.removeServiceCallBackgroundView(view: self.view)
                    print(error)
                })
                
            }
            
          
        }
        else {
            let storyboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController)
            self.present(viewController, animated: true, completion: nil)
        }
        
    }
}
extension ResortDetailsViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.authorizedWhenInUse)
        {
            
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = true
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let newLocation = locations.last
        let northWestCoordinates = Coordinates()
        northWestCoordinates.latitude = (newLocation?.coordinate.latitude)!
        northWestCoordinates.longitude = (newLocation?.coordinate.longitude)!
        let rectRequest = GeoArea.init(northWestCoordinates, northWestCoordinates)
        let result = Helper.getResortsWithLatLongForShowingOnMap(request: rectRequest)
        if(result) {
            
        }
        else {
            locationManager.stopUpdatingLocation()
        }
        
    }
    
}

extension ResortDetailsViewController:MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        
        switch result.rawValue {
            
        case MFMailComposeResult.cancelled.rawValue:
            self.dismiss(animated: true, completion:nil)
            break
        case MFMailComposeResult.saved.rawValue:
            print("Email saved")
        case MFMailComposeResult.sent.rawValue:
            print("Email sent")
            
            let alertController = UIAlertController(title: "test", message: "test", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okButton)
            present(alertController, animated: true, completion: nil)
            
        case MFMailComposeResult.failed.rawValue:
            print("Email failed: %@", [error!.localizedDescription])
        default:
            break
        }
        
    }
}

extension ResortDetailsViewController:MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
