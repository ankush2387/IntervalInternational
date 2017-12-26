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
import RealmSwift
import MessageUI
import Foundation

class ResortDetailsViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var tableViewResorts: UITableView!
    @IBOutlet weak var imageIndexLabel: UILabel!
    @IBOutlet weak var headerTextForShowingResortCounter: UILabel?
    
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var previousButton: UIButton?
    
    @IBOutlet weak var forwordButton: UIButton?
    //***** Class Variables *****//
    var bounds = GMSCoordinateBounds()
    var actionSheetTable = UITableView()
    var tableViewController = UIViewController()
    var mapView = GMSMapView()
    var locationManager = CLLocationManager()
    var nearbyArray: NSMutableArray = []
    var onsiteArray: NSMutableArray = []
    var amenityOnsiteString = "Nearby" + "\n"
    var amenityNearbyString = "On-Site" + "\n"
    var presentViewModally = false
    
    //***** Class private Variables *****//
    fileprivate var startIndex = 0
    fileprivate var arrayRunningIndex = 0
    fileprivate var resortDescriptionArrayContainer = [Resort]()
    fileprivate var placeSelectionMainDictionary = [Int: [Int: Bool]]()
    fileprivate var tappedButtonDictionary = [Int: Bool]()
    fileprivate let moreNavArray = ["Share via email", "Share via text", "Tweet", "Facebook", "Pinterest"]
    
    var senderViewController: String? = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if !Constant.MyClassConstants.isFromSearchResult {
             self.cancelButton?.setTitle("Done", for: .normal)
            if Constant.MyClassConstants.isFromExchange && Constant.RunningDevice.deviceIdiom == .phone {
                self.previousButton?.isHidden = true
                self.forwordButton?.isHidden = true
                self.headerTextForShowingResortCounter?.isHidden = true
            }
            self.previousButton?.isHidden = true
            self.forwordButton?.isHidden = true
            self.headerTextForShowingResortCounter?.isHidden = true
            
            if Constant.RunningDevice.deviceIdiom == .phone {
                self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
            }

        }
        // Notification to perform vacation search after user pre-login
        NotificationCenter.default.addObserver(self, selector: #selector(showVacationSearch), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        
        if self.headerTextForShowingResortCounter != nil {
            
            self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
        }
        if !Constant.MyClassConstants.resortsDescriptionArray.amenities.isEmpty {
            
            Constant.MyClassConstants.amenitiesDictionary.removeAllObjects()
            
            nearbyArray.removeAllObjects()
            onsiteArray.removeAllObjects()
            intervalPrint(Constant.MyClassConstants.resortsDescriptionArray.amenities.count)
            for amenity in Constant.MyClassConstants.resortsDescriptionArray.amenities {
                if let amenityName = amenity.amenityName {
                    if amenity.nearby == true {
                        
                        nearbyArray.add(amenityName)
                        amenityOnsiteString = amenityOnsiteString + "\n" + "  " + amenityName
                        
                    } else {
                        
                        onsiteArray.add(amenityName)
                        amenityNearbyString = amenityNearbyString + "\n" + "  " + amenityName
                        
                    }
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
        if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
            let userInfo: [String: String] = [
                Constant.omnitureCommonString.productItem: resortCode,
                Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch
            ]
            
            ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
        }
        self.startIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex
        self.resortDescriptionArrayContainer.append(Constant.MyClassConstants.resortsDescriptionArray)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableViewResorts.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tableViewResorts.reloadData()
        for collView in self.tableViewResorts.subviews {
            if collView .isKind(of: UICollectionView.self) {
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if Constant.RunningDevice.deviceIdiom == .phone {
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
        if self.startIndex < Constant.MyClassConstants.vacationSearchContentPagerRunningIndex && arrayRunningIndex > 0 {
            
            Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1
            self.arrayRunningIndex = arrayRunningIndex - 1
            Constant.MyClassConstants.resortsDescriptionArray = self.resortDescriptionArrayContainer[ self.arrayRunningIndex]
            Constant.MyClassConstants.imagesArray.removeAll()
            let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
            for imgStr in imagesArray where imgStr.size == Constant.MyClassConstants.imageSize {
                if let imgUrl = imgStr.url {
                    Constant.MyClassConstants.imagesArray.append(imgUrl)
                }
            }
            self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
            
            self.tableViewResorts.reloadData()
            // omniture tracking with event 35
            if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
                let userInfo: [String: String] = [
                    Constant.omnitureCommonString.productItem: resortCode,
                    Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch
                ]
                
                ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
            }
        } else {
            if startIndex > 1 {
                Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1
                self.startIndex = startIndex - 1
                
                showHudAsync()
                
                guard let resortCode = Constant.MyClassConstants.resortsArray[Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1].resortCode else { return }
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { response in
                    
                    self.resortDescriptionArrayContainer.insert(response, at: 0)
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAll()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray where imgStr.size == Constant.MyClassConstants.imageSize {
                        if let imgUrl = imgStr.url {
                            Constant.MyClassConstants.imagesArray.append(imgUrl)
                        }
                    }
                    self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
                    self.hideHudAsync()
                    self.tableViewResorts.reloadData()
                }) { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.serverError(error))
                }
            }
        }
    }
    
    //***** Function call for next resort button *****//
    @IBAction func nextResortButtonPressed(_ sender: UIButton) {
        
        if Constant.MyClassConstants.vacationSearchContentPagerRunningIndex < Constant.MyClassConstants.resortsArray.count {
            
            if self.resortDescriptionArrayContainer.count - 1 < Constant.MyClassConstants.vacationSearchContentPagerRunningIndex {
                self.arrayRunningIndex = arrayRunningIndex + 1
                guard let resortCode = Constant.MyClassConstants.resortsArray[Constant.MyClassConstants.vacationSearchContentPagerRunningIndex].resortCode else { return }
                
                showHudAsync()
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { response in
                    
                    self.resortDescriptionArrayContainer.append(response)
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAll()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray {
                        if imgStr.size == Constant.MyClassConstants.imageSize {
                            if let imgURL = imgStr.url {
                            Constant.MyClassConstants.imagesArray.append(imgURL)
                            }
                        }
                    }
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex + 1
                    self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
                    self.hideHudAsync()
                    self.tableViewResorts.reloadData()
                    
                    if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
                    // omniture tracking with event 35
                    let userInfo: [String: String] = [
                        Constant.omnitureCommonString.productItem: resortCode,
                        Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch
                    ]
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
                    }
                }) { [unowned self] error in
                    self.hideHudAsync()
                    self.presentErrorAlert(UserFacingCommonError.serverError(error))
                }
                
            } else {
                Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex + 1
                self.arrayRunningIndex = arrayRunningIndex + 1
                
                Constant.MyClassConstants.resortsDescriptionArray = self.resortDescriptionArrayContainer[ self.arrayRunningIndex]
                Constant.MyClassConstants.imagesArray.removeAll()
                let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                for imgStr in imagesArray {
                    if imgStr.size == Constant.MyClassConstants.imageSize {
                        if let imgURL = imgStr.url {
                        Constant.MyClassConstants.imagesArray.append(imgURL)
                        }
                    }
                }
                self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)"
                
                self.tableViewResorts.reloadData()
                
            }
        }
    }
    //***** Function call for Done button *****//
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.popViewController(animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
            
        } else {
                _ = navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //***** Function call for search button pressed. *****//
    
    func searchVacationClicked() {
        if Session.sharedSession.userAccessToken != nil && Constant.MyClassConstants.isLoginSuccessfull {
            do {
                
            let realm = try Realm()
            let allDest = Helper.getLocalStorageWherewanttoGo()
            if !allDest.isEmpty {
                try realm.write {
                    realm.deleteAll()
                }
            }
            let allavailabledest = AllAvailableDestination()
            allavailabledest.destination = Constant.MyClassConstants.allDestinations
            let dict = Constant.MyClassConstants.resortsDescriptionArray
            let address = dict.address
            
            //realm local storage for selected resort
            let storedata = RealmLocalStorage()
            guard let membership = Session.sharedSession.selectedMembership else { return }
            let resortList = ResortList()
            if let cityName = (address?.cityName) {
                resortList.resortCityName = cityName
            }
                if let resortName = dict.resortName, let resortCode = dict.resortCode {
                resortList.resortCode = resortCode
                resortList.resortName = "\(resortName) - \(resortCode)"
            }
            if let url = dict.images[0].url {
            resortList.thumbnailurl = url
            }
            
            if let territoryCode = (address?.territoryCode) {
                resortList.territorrycode = territoryCode
            }
            
            storedata.resorts.append(resortList)
            storedata.membeshipNumber = membership.memberNumber ?? ""
            
                try realm.write {
                    realm.add(storedata)
            }
                
                var storyboard = UIStoryboard()
                if Constant.RunningDevice.deviceIdiom == .pad {
                    storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                } else {
                    storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                }
                guard let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as? SWRevealViewController else { return }
                self.present(viewController, animated: true, completion: nil)
            } catch {
                presentErrorAlert(UserFacingCommonError.generic)
            }
           
        } else {
            var storyboard = UIStoryboard()
            var viewController = UIViewController()
            if Constant.RunningDevice.deviceIdiom == .pad {
                storyboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
                viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginViewControlleriPad)
            } else {
                storyboard = UIStoryboard(name: Constant.storyboardNames.signInPreLoginController, bundle: nil)
                viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController)
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    //***** Function call for More button *****//
    
    @IBAction func moreButtonClicked(_ sender: AnyObject) {
        guard let name = Constant.MyClassConstants.resortsDescriptionArray.resortName else { return }
        guard let address = Constant.MyClassConstants.resortsDescriptionArray.address?.addressLines[0] else { return }
        guard let description = Constant.MyClassConstants.resortsDescriptionArray.description else { return }
        guard let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode else { return }
        
        let message = ShareActivityMessage()
        message.resortInformationMessage(resortName: name, address: address, description: description, resortCode: resortCode)
        let resortImage = ShareActivityImage()
        let resortURL = ShareActivityURL(activityURL: resortCode)
        resortImage.getResrtImage(strURL: Constant.MyClassConstants.imagesArray[0])
        
        let shareActivityViewController = UIActivityViewController(activityItems: [message, resortImage, resortURL], applicationActivities: nil)
        
        if UIDevice().userInterfaceIdiom == .pad {
            //ipad has to present as Popover
            shareActivityViewController.modalPresentationStyle = .popover
            if let presenter = shareActivityViewController.popoverPresentationController {
                let pView = sender as? UIView
                presenter.sourceView = pView
                if let bounds = pView?.bounds {
                presenter.sourceRect = bounds
                }
            }
        }
        
        self.present(shareActivityViewController, animated: false, completion: nil)
    }
    
    //Used to expand and contract sections
    @IBAction func toggleButtonIsTapped(_ sender: UIButton) {
        if let tag = tappedButtonDictionary[sender.tag] {
            tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
        } else {
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.tableViewResorts.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }
    //Function for forward button
    @IBAction func forwardButtonClicked(_ sender: AnyObject) {
        imageIndexLabel.text = "Resort of "
    }
    //Function for backward button
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
    }
    
    func heightForView(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    /***** Function to call vacation search after pre login *****/
    
    func showVacationSearch() {
        //Added a delay to present vacation search view controller.
        
        //Changed line self.senderViewController == Constant.MyClassConstants.searchResult
        if Constant.MyClassConstants.loginOriginationPoint == "Resort Directory - Sign In Modal" {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchVacationClicked), userInfo: nil, repeats: false)
        }
    }
    
    func showWeatherButtonPressed() {
        Constant.MyClassConstants.goingToMapOrWeatherView = true
        guard let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode else { return }

        guard let resortName = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName else { return }
        
        guard let countryCode = Constant.MyClassConstants.resortsDescriptionArray.address?.countryCode else { return }
        self.showHudAsync()
        displayWeatherView(resortCode: resortCode, resortName: resortName, countryCode: countryCode, presentModal: presentViewModally, completionHandler: { (_) in
            self.hideHudAsync()
        })
    }
    
    func showLocationButtonPressed() {
        Constant.MyClassConstants.goingToMapOrWeatherView = true
        guard let coordinates = Constant.MyClassConstants.resortsDescriptionArray.coordinates else { return }
        guard let resortName = Constant.MyClassConstants.resortsDescriptionArray.resortName else { return }
        guard let cityName = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName else { return }
        self.showHudAsync()
        displayMapView(coordinates: coordinates, resortName: resortName, cityName: cityName, presentModal: presentViewModally) { (_) in
            self.hideHudAsync()
        }
    }
    
}
//****** Extension for resort details table view****//
extension ResortDetailsViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 44
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 1 {
            return 50
        } else {
            switch indexPath.section {
            case 0:
                return tableView.frame.size.width / 2 + 100
            case 1:
                
                if let description = Constant.MyClassConstants.resortsDescriptionArray.description {
                    if description.isEmpty {
                        
                        var height: CGFloat = 0.0
                        if Constant.RunningDevice.deviceIdiom == .pad {
                            guard let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0) else { return 0 }
                            if let description = Constant.MyClassConstants.resortsDescriptionArray.description {
                                height = heightForView(description, font: font, width: (view.frame.size.width / 2) - 40)
                            }
                            return height + 60
                        } else {
                            guard let font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0) else { return 0 }
                            if let description = Constant.MyClassConstants.resortsDescriptionArray.description {
                                height = heightForView(description, font: font, width: view.frame.size.width - 40)
                            }
                            return height + 40
                        }
                    } else {
                        return 60
                    }
                } else {
                    return 0
                }
            case 2:
                if Constant.RunningDevice.deviceIdiom == .pad {
                    return 0
                } else {
                    return 200
                }
                
            default:
                if let isOpen = tappedButtonDictionary[indexPath.section] {
                    if isOpen && indexPath.row > 0 {
                        switch indexPath.section {
                        case 3 :
                            return 50
                        case 4 :
                            let count = nearbyArray.count + onsiteArray.count
                            if count > 0 {
                            if count == 1 {
                                return CGFloat (count * 20 + 60)
                            } else {
                                return CGFloat (count * 20 + 120)
                            }
                            } else { return 60 }
                        case 5 :
                            return 80
                        default :
                            return 600
                        }
                    } else {
                        return 60
                    }
                } else {
                    if indexPath.row == 0 {
                        return 60
                    } else {
                        return 0
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if table is action sheet
        if tableView.tag == 1 {
            switch indexPath.row {
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
                    presentAlert(with: "Could Not Send Text Message".localized(), message: "This device is not able/configured to send Text Messages.".localized())
                }
                break
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 2 :
                let detailMapViewController = DetailMapViewController()
                detailMapViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(detailMapViewController, animated: true)
            case let indexedSection where indexedSection >= 3 :
                let button = UIButton()
                button.tag = indexPath.section
                toggleButtonIsTapped(button)
            default :
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        viewHeader.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        let lineTop = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 1))
        lineTop.backgroundColor = UIColor.lightGray
        viewHeader.addSubview(lineTop)
        
        let lineBottom = UIView(frame: CGRect(x: 0, y: 43, width: view.frame.size.width, height: 1))
        lineBottom.backgroundColor = UIColor.lightGray
        viewHeader.addSubview(lineBottom)
        
        let labelHeader = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.size.width - 40, height: 44))
        labelHeader.text = "Resort Info".localized()
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
        
        if let imageData = UIImagePNGRepresentation(UIImage(named: "sanci_main01_r")!) // Get the image from ImageView and convert to NSData
        {
            let base64String: String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions())
            body = body + "<div><img src='data:image/png;base64,\(base64String)' height='100' width='150'/></div>"
        }
        body = body + "</body></html>"
        mailComposerVC.setMessageBody(body, isHTML: true)
        return mailComposerVC
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposerVC = MFMessageComposeViewController()
        messageComposerVC.messageComposeDelegate = self
        var message = ""
        if let name = Constant.MyClassConstants.resortsDescriptionArray.resortName {
            message.append("Resort Name: \(name)/n")
        }
        
        if let code = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
            message.append("Resort Code: \(code)")
        }
        
        messageComposerVC.body = message
        
        return messageComposerVC
    }
    
    func showSendMailErrorAlert() {
        presentAlert(with: "Could Not Send Email".localized(), message: "Your device could not send e-mail.  Please check e-mail configuration and try again.".localized())
    }
    
}

extension ResortDetailsViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            return 1
        } else {
            if senderViewController == Constant.MyClassConstants.searchResult {
                return 8
            } else {
                return 7
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if table is action sheet
        if tableView.tag == 1 {
            return 5
        } else {
            if Constant.MyClassConstants.resortsDescriptionArray.resortName != nil {
                
                switch section {
                case 0 :
                    if Constant.MyClassConstants.resortsDescriptionArray.resortName != nil {
                        return 1
                    } else {
                        return 0
                    }
                case let indexedSection where indexedSection >= 3 :
                    if let isOpen = tappedButtonDictionary[section] {
                        if isOpen {
                            switch section {
                            case 3 :
                                if Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name != nil {
                                    return 2
                                } else {
                                    return 1
                                }
                            case 5 :
                                
                                if let resortCategory = Constant.MyClassConstants.resortsDescriptionArray.rating?.categories {
                                    return resortCategory.count + 1
                                } else {
                                    return 1
                                }
                            case 6 :
                                if Constant.MyClassConstants.resortsDescriptionArray.tdiUrl != nil {
                                    return 2
                                } else {
                                    return 1
                                }
                            default :
                                return 2
                                
                            }
                        } else {
                            return 1
                        }
                    } else {
                        return 1
                    }
                default :
                    return 1
                }
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if table is action sheet
        if tableView.tag == 1 {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.actionSheetCell)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.actionSheetCell, for: indexPath)
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 49))
            
            titleLabel.text = moreNavArray[indexPath.row]
            titleLabel.textAlignment = NSTextAlignment.center
            cell.contentView.addSubview(titleLabel)
            
            let bottomLine = UIView(frame: CGRect(x: 0, y: 49, width: tableView.bounds.width, height: 1))
            bottomLine.backgroundColor = UIColor.lightGray
            cell.contentView.addSubview(bottomLine)
            
            return cell
        } else {
            
            switch indexPath.section {
            case 0 :
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.resortDirectoryResortCell, for: indexPath) as? ResortDirectoryResortCell else { return UITableViewCell () }
                
                if let subLayers = cell.resortNameGradientView.layer.sublayers {
                    for layer in subLayers {
                        if layer.isKind(of: CAGradientLayer.self) {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
                if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
                let status = Helper.isResrotFavorite(resortCode: resortCode)
                if status {
                    cell.favoriteButton.isSelected = true
                } else {
                    cell.favoriteButton.isSelected = false
                }
                }
                cell.resortNameGradientView.backgroundColor = UIColor.clear
                let frame = CGRect(x: 0, y: 300 - 68, width: cell.frame.size.width + 200, height: cell.resortNameGradientView.frame.size.height)
                cell.resortNameGradientView.frame = frame
                Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
                cell.resortCollectionView.collectionViewLayout.invalidateLayout()
                cell.resortCollectionView.reloadData()
                cell.resortName.text = Constant.MyClassConstants.resortsDescriptionArray.resortName
                cell.resortAddress.text = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName
                cell.resortCode.text = Constant.MyClassConstants.resortsDescriptionArray.resortCode
                if let tier = Constant.MyClassConstants.resortsDescriptionArray.tier {
                    let imageStr = Helper.getTierImageName(tier:tier.uppercased())
                    cell.tierImageView.image = UIImage(named: imageStr)
                }
                cell.favoriteButton.addTarget(self, action: #selector(favoritesButtonClicked(_:)), for: .touchUpInside)
                cell.backgroundColor = UIColor.clear
                cell.showResortWeatherbutton?.addTarget(self, action: #selector(self.showWeatherButtonPressed), for: .touchUpInside)
                cell.showResortLocationButton?.addTarget(self, action: #selector(self.showLocationButtonPressed), for: .touchUpInside)
                return cell
            case 2 :
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.mapTableViewCell, for: indexPath)
                if let latitude = Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude, let longitude = Constant.MyClassConstants.resortsDescriptionArray.coordinates?.longitude {
                    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
                    let mapframe = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.contentView.frame.height)
                    
                    mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
                    mapView.isUserInteractionEnabled = false
                    mapView.isMyLocationEnabled = true
            
                    let  position = CLLocationCoordinate2DMake(latitude, longitude)
                    let marker = GMSMarker()
                    marker.position = position
                    
                    marker.isFlat = false
                    marker.icon = UIImage(named: Constant.assetImageNames.pinSelectedImage)
                    marker.appearAnimation = GMSMarkerAnimation.pop
                    marker.map = mapView
                }
                
                mapView.settings.myLocationButton = false
                cell.contentView.addSubview(mapView)
                return cell
            case 1 :
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.CustomCell, for: indexPath) as? ResortDirectoryResortCell else { return UITableViewCell() }
                cell.resortName.text = Constant.MyClassConstants.resortsDescriptionArray.description
                return cell
            case 7:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.vacationSearchCell, for: indexPath) as? ResortDirectoryResortCell else { return UITableViewCell() }
                cell.searchVacationButton?.addTarget(self, action: #selector(searchVacationClicked), for: .touchUpInside)
                return cell
            default :
                var availabledestionCountryOrContinentsCell: AvailableDestinationCountryOrContinentsTableViewCell?
                var availableCountryCell: AvailableDestinationPlaceTableViewCell?
                let ratingTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.ratingCell)
                
                availabledestionCountryOrContinentsCell?.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[indexPath.section - 3]
                availabledestionCountryOrContinentsCell?.isUserInteractionEnabled = false
                availableCountryCell?.isUserInteractionEnabled = false
                
                if let isOpen = tappedButtonDictionary[indexPath.section] {
                    availabledestionCountryOrContinentsCell?.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[indexPath.section - 3]
                    if isOpen && indexPath.row > 0 {
                        switch indexPath.section {
                        case 6 :
                            if indexPath.row > 0 {
                                availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.tdiCell) as? AvailableDestinationPlaceTableViewCell
                            }
                        case 5 :
                        if indexPath.row > 0 {
                            availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.ratingCell) as? AvailableDestinationPlaceTableViewCell
                            
                        }
                        default :
                        availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationPlaceTableViewCell) as? AvailableDestinationPlaceTableViewCell
                    }
                        
                    switch indexPath.section {
                    case 3 :
                        availableCountryCell?.infoLabel.isHidden = false
                        if let airportName = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name {
                            var airportArray = [String]()
                            let airportAdress = "Nearest Airport" + "\n" + airportName + "/"
                            airportArray.append(airportAdress)
                            if let airportCode = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.code {
                                airportArray.append(airportCode)
                            }
                            if let miles = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.distanceInMiles {
                                airportArray.append("\(miles) Miles")
                            }
                            if let kms = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.distanceInKilometers {
                                airportArray.append("\(kms) KM")
                            }
                            availableCountryCell?.infoLabel.text = airportArray.joined(separator: "").localized()
                        } else {
                            availableCountryCell?.infoLabel.text = ""
                        }
                    case 4 :
                        availableCountryCell?.infoLabel.isHidden = false
                        availableCountryCell?.infoLabel.numberOfLines = 0
                        if nearbyArray.count > 0 {
                            availableCountryCell?.infoLabel.text = amenityOnsiteString + "\n" + "\n" + " " + amenityNearbyString
                        } else {
                            availableCountryCell?.infoLabel.text = amenityNearbyString
                        }
                    case 5 :
                    if let resortCategory = Constant.MyClassConstants.resortsDescriptionArray.rating?.categories, let categoryCode = resortCategory[indexPath.row - 1].categoryCode {
                        availableCountryCell?.infoLabel.text = Helper.getRatingCategory(category: categoryCode ?? "") + "\n" + " \(resortCategory[indexPath.row - 1].rating)"
                        
                        let resortRating = "\(resortCategory[indexPath.row - 1].rating)"
                        let ratingArray = resortRating.components(separatedBy: ".")
                        var image_X: CGFloat = 35.0
                        for _ in 0..<resortCategory[indexPath.row - 1].rating {
                            let imgVwRating = UIImageView()
                            imgVwRating.backgroundColor = UIColor.orange
                            imgVwRating.frame = CGRect(x: image_X, y: 50, width: 10, height: 10)
                            imgVwRating.layer.cornerRadius = 5
                            availableCountryCell?.contentView.addSubview(imgVwRating)
                            image_X = image_X + 15
                            
                        }
                        if let rating = ratingArray.last?.characters.count, rating > 1 {
                            let imgVwRating = UIImageView()
                            imgVwRating.backgroundColor = UIColor.orange
                            imgVwRating.frame = CGRect(x: image_X, y: 50, width: 20, height: 20)
                            imgVwRating.layer.cornerRadius = 10
                            availableCountryCell?.contentView.addSubview(imgVwRating)
                            image_X = image_X + 25
                        }
                        }
                        case 6 :
                        availableCountryCell?.tdiImageView.backgroundColor = UIColor.lightGray
                        if let urlString = Constant.MyClassConstants.resortsDescriptionArray.tdiUrl {
                            let url = URL(string: urlString)
                            availableCountryCell?.tdiImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                        } else {
                            availableCountryCell?.tdiImageView.image = #imageLiteral(resourceName: "NoImageIcon")
                        }
                        default :

                            if let resortCategory = Constant.MyClassConstants.resortsDescriptionArray.rating?.categories {
                                if let categoryCode = resortCategory[indexPath.row - 1].categoryCode {
                                    availableCountryCell?.infoLabel.text = Helper.getRatingCategory(category: categoryCode ?? "") + "\n" + " \(resortCategory[indexPath.row - 1].rating)"
                                }
                                var image_X: CGFloat = 0.0
                                for _ in 0..<resortCategory[indexPath.row - 1].rating {
                                    if let imgVwRating = availableCountryCell?.tdiImageView {
                                        imgVwRating.backgroundColor = UIColor.orange
                                        imgVwRating.frame = CGRect(x: image_X, y: 20, width: 20, height: 20)
                                        ratingTableViewCell?.contentView.addSubview(imgVwRating)
                                        image_X = image_X + 30
                                    }
                                }
                            }
                        }
                        return availableCountryCell ?? UITableViewCell()
                    } else {
                        guard let availabledestionCountryOrContinentsCell = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationCountryOrContinentsTableViewCell) as? AvailableDestinationCountryOrContinentsTableViewCell else { return UITableViewCell() }
                        availabledestionCountryOrContinentsCell.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[indexPath.section - 3]
                        if let selectedPlacedictionary = placeSelectionMainDictionary[indexPath.section] {
                            availabledestionCountryOrContinentsCell.getCell(indexPath.section, islistOfCountry: isOpen, selectedPlaceDictionary: selectedPlacedictionary)
                        } else {
                            availabledestionCountryOrContinentsCell.getCell(indexPath.section, islistOfCountry: isOpen)
                        }
                        
                        return availabledestionCountryOrContinentsCell
                    }
                } else {
                    guard let availabledestionCountryOrContinentsCell = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationCountryOrContinentsTableViewCell) as? AvailableDestinationCountryOrContinentsTableViewCell else { return UITableViewCell() }
                    
                    availabledestionCountryOrContinentsCell.getCell(indexPath.section)
                    availabledestionCountryOrContinentsCell.countryOrContinentLabel.text = Constant.MyClassConstants.arrayResortInfo[indexPath.section - 3]
                    return availabledestionCountryOrContinentsCell
                }
            }
        }
    }
    
    func favoritesButtonClicked(_ sender: IUIKButton) {
        guard let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode else { return }
        if Session.sharedSession.userAccessToken != nil {
            if sender.isSelected == false {
                
                showHudAsync()
                
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: {(_) in
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                    self.tableViewResorts.reloadData()
                    ADBMobile.trackAction(Constant.omnitureEvents.event48, data: nil)
                }, onError: {[weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.serverError(error))
                })
            } else {
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: {(_) in
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                    self.tableViewResorts.reloadData()
                    ADBMobile.trackAction(Constant.omnitureEvents.event51, data: nil)
                }, onError: {[weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.serverError(error))
                })
            }
            
        } else {
            if Constant.RunningDevice.deviceIdiom == .pad {
                let storyboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginViewControlleriPad)
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let storyboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
    }
}
extension ResortDetailsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = false
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        let northWestCoordinates = Coordinates()
        if let latitude = newLocation?.coordinate.latitude, let longitude = newLocation?.coordinate.longitude {
            northWestCoordinates.latitude = latitude
            northWestCoordinates.longitude = longitude
        }
        let rectRequest = GeoArea(northWestCoordinates, northWestCoordinates)
        let result = Helper.getResortsWithLatLongForShowingOnMap(request: rectRequest)
        if !result {
            locationManager.stopUpdatingLocation()
        }
    }
    
}

extension ResortDetailsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        
        switch result.rawValue {
            
        case MFMailComposeResult.cancelled.rawValue:
            self.dismiss(animated: true, completion: nil)
            break
        case MFMailComposeResult.saved.rawValue:
            intervalPrint("Email saved")
            break
        case MFMailComposeResult.sent.rawValue:
            intervalPrint("Email sent")
            let alertController = UIAlertController(title: "test", message: "test", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okButton)
            present(alertController, animated: true, completion: nil)
            
        case MFMailComposeResult.failed.rawValue:
            intervalPrint("Email failed: %@", [error!.localizedDescription])
            break
        default:
            break
        }
        
    }
}

extension ResortDetailsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

//******* For iPad add to favorites functionality ******//
extension ResortDetailsViewController: ResortDirectoryResortCellDelegate {
    func favoritesButtonSelectedAtIndex(_ index: Int) {
        
    }
}
