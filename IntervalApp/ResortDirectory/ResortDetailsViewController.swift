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
    var amenityOnsiteString = ""
    var amenityNearbyString = ""
    var presentViewModally = false
    var mapcell : UITableViewCell?
    var resortInfoHeight:CGFloat = 60.0

    //***** Class private Variables *****//
    fileprivate var startIndex = 0
    fileprivate var arrayRunningIndex = 0
    fileprivate var resortDescriptionArrayContainer = [Resort]()
    fileprivate var placeSelectionMainDictionary = [Int: [Int: Bool]]()
    fileprivate var tappedButtonDictionary = [Int: Bool]()
    fileprivate let moreNavArray = ["Share via email", "Share via text", "Tweet", "Facebook", "Pinterest"]
    
    var senderViewController: String? = ""
    var showSearchResults = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideHudAsync()
        if Constant.RunningDevice.deviceIdiom == .phone {
            navigationController?.navigationBar.isHidden = true
            self.navigationController?.isNavigationBarHidden = true
        } else {
            navigationController?.navigationBar.isHidden = false
        }
        if !Constant.MyClassConstants.isFromSearchResult {

            cancelButton?.setTitle("Done".localized(), for: .normal)
            if Constant.MyClassConstants.isFromExchange && Constant.RunningDevice.deviceIdiom == .phone {
                previousButton?.isHidden = true
                forwordButton?.isHidden = true
                headerTextForShowingResortCounter?.isHidden = true
            }
            previousButton?.isHidden = true
            forwordButton?.isHidden = true
            headerTextForShowingResortCounter?.isHidden = true
            
            if Constant.RunningDevice.deviceIdiom == .phone {
                tabBarController?.tabBar.isHidden = true
                self.navigationController?.isNavigationBarHidden = true
            } else {
               navigationController?.navigationBar.isHidden = false
            }
            
        } else {
            navigationController?.navigationBar.isHidden = true
        }

        // Notification to perform vacation search after user pre-login
        NotificationCenter.default.addObserver(self, selector: #selector(showVacationSearch), name: NSNotification.Name(rawValue: Constant.MyClassConstants.showVacationSearchNotification), object: nil)
        if headerTextForShowingResortCounter != nil {
            
            headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)".localized()
        }
        if !Constant.MyClassConstants.resortsDescriptionArray.amenities.isEmpty {
            
            Constant.MyClassConstants.amenitiesDictionary.removeAllObjects()
            
            nearbyArray.removeAllObjects()
            onsiteArray.removeAllObjects()
            amenityOnsiteString = "Nearby" + "\n"
            amenityNearbyString = "On-Site" + "\n"
            intervalPrint(Constant.MyClassConstants.resortsDescriptionArray.amenities.count)
            for amenity in Constant.MyClassConstants.resortsDescriptionArray.amenities {
                if let amenityName = amenity.amenityName {
                    if amenity.nearby == true {
                        // use unicode character to add bullets
                        nearbyArray.add(amenityName)
                        amenityOnsiteString = amenityOnsiteString + "\n" + "  " + "\u{2022}" + " " + amenityName
                        
                    } else {
                        onsiteArray.add(amenityName)
                        amenityNearbyString = amenityNearbyString + "\n" + "  " + "\u{2022}" + " " + amenityName
                        
                    }
                }
                Constant.MyClassConstants.amenitiesDictionary.setValue(nearbyArray, forKey: Constant.MyClassConstants.nearbyDictKey)
                Constant.MyClassConstants.amenitiesDictionary.setValue(onsiteArray, forKey: Constant.MyClassConstants.onsiteDictKey)
            }
            
            tableViewResorts.estimatedRowHeight = 100
            tableViewResorts.reloadData()
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
        startIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex
        resortDescriptionArrayContainer.append(Constant.MyClassConstants.resortsDescriptionArray)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableViewResorts.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tableViewResorts.reloadData()
        for collView in tableViewResorts.subviews {
            if collView .isKind(of: UICollectionView.self) {
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if Constant.RunningDevice.deviceIdiom == .phone {
            navigationController?.navigationBar.isHidden = showSearchResults
            tabBarController?.tabBar.isHidden = false
        }
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Function call for previous resort button *****//
    @IBAction func previousResortButtonPressed(_ sender: UIButton) {
        if startIndex < Constant.MyClassConstants.vacationSearchContentPagerRunningIndex && arrayRunningIndex > 0 {
            
            Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex - 1
            arrayRunningIndex = arrayRunningIndex - 1
            Constant.MyClassConstants.resortsDescriptionArray = resortDescriptionArrayContainer[arrayRunningIndex]
            Constant.MyClassConstants.imagesArray.removeAll()
            let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
            for imgStr in imagesArray where imgStr.size == Constant.MyClassConstants.imageSize {
                if let imgUrl = imgStr.url {
                    Constant.MyClassConstants.imagesArray.append(imgUrl)
                }
            }

            headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)".localized()
            tableViewResorts.reloadData()
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
                startIndex = startIndex - 1
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
                    self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)".localized()
                    self.hideHudAsync()
                    self.tableViewResorts.reloadData()
                }) { [weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                }
            }
        }
    }
    
    //***** Function call for next resort button *****//
    @IBAction func nextResortButtonPressed(_ sender: UIButton) {
        
        if Constant.MyClassConstants.vacationSearchContentPagerRunningIndex < Constant.MyClassConstants.resortsArray.count {
            
            if resortDescriptionArrayContainer.count - 1 < Constant.MyClassConstants.vacationSearchContentPagerRunningIndex {
                arrayRunningIndex = arrayRunningIndex + 1
                guard let resortCode = Constant.MyClassConstants.resortsArray[Constant.MyClassConstants.vacationSearchContentPagerRunningIndex].resortCode else { return }
                
                showHudAsync()
                
                DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { response in
                    self.resortDescriptionArrayContainer.append(response)
                    Constant.MyClassConstants.resortsDescriptionArray = response
                    Constant.MyClassConstants.imagesArray.removeAll()
                    let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                    for imgStr in imagesArray where imgStr.size == Constant.MyClassConstants.imageSize {
                        if let url = imgStr.url {
                            Constant.MyClassConstants.imagesArray.append(url)
                        }
                    }
                    
                    Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex + 1
                    self.headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)".localized()
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
                    self.presentErrorAlert(UserFacingCommonError.handleError(error))
                }
                
            } else {
                Constant.MyClassConstants.vacationSearchContentPagerRunningIndex = Constant.MyClassConstants.vacationSearchContentPagerRunningIndex + 1
                arrayRunningIndex = arrayRunningIndex + 1

                Constant.MyClassConstants.resortsDescriptionArray = resortDescriptionArrayContainer[arrayRunningIndex]
                Constant.MyClassConstants.imagesArray.removeAll()
                let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
                for imgStr in imagesArray {
                    if imgStr.size == Constant.MyClassConstants.imageSize {
                        if let imgURL = imgStr.url {
                            Constant.MyClassConstants.imagesArray.append(imgURL)
                        }
                    }
                }
                headerTextForShowingResortCounter?.text = "Resort \(Constant.MyClassConstants.vacationSearchContentPagerRunningIndex) of  \(Constant.MyClassConstants.resortsArray.count)".localized()
                tableViewResorts.reloadData()
            }
        }
    }
    //***** Function call for Done button *****//
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if Constant.MyClassConstants.isFromSearchResult {
                navigationController?.popViewController(animated: false)
            } else {
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
            }
        } else {
            navigationController?.view.layer.add(Helper.topToBottomTransition(), forKey: nil)
            navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: AnyObject) {
        navigationController?.view.layer.add(Helper.topToBottomTransition(), forKey: nil)
        navigationController?.popViewController(animated: false)
        //navigationController?.dismiss(animated: true)
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
                let allAvailableDest = AllAvailableDestination()
                allAvailableDest.destination = Constant.MyClassConstants.allDestinations
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
                storedata.contactID = Session.sharedSession.contactID
                
                try realm.write {
                    realm.add(storedata)
                }
                
                var storyboard = UIStoryboard()
                if Constant.RunningDevice.deviceIdiom == .pad {
                    storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                } else {
                    storyboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                }
                
                if let initialViewController = storyboard.instantiateInitialViewController() {
                   showSearchResults = true
                    navigationController?.pushViewController(initialViewController, animated: true)
                }
            } catch {
                presentErrorAlert(UserFacingCommonError.generic)
            }
            
        } else {
            var storyboard = UIStoryboard()
            if Constant.RunningDevice.deviceIdiom == .pad {
                storyboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginViewControlleriPad) as? SignInPreLoginViewController {
                    navigationController?.pushViewController(viewController, animated: true)
                }
            } else {
                storyboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController) as? SignInPreLoginViewController {
                    viewController.isForSearchVacation = true
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
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
        
        present(shareActivityViewController, animated: false, completion: nil)
    }
    
    //Used to expand and contract sections
    @IBAction func toggleButtonIsTapped(_ sender: UIButton) {
        if let tag = tappedButtonDictionary[sender.tag] {
            tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
        } else {
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        tableViewResorts.reloadData()
    }
    //Function for forward button
    @IBAction func forwardButtonClicked(_ sender: AnyObject) {
        imageIndexLabel.text = "Resort of ".localized()
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
        showHudAsync()
        displayWeatherView(resortCode: resortCode, resortName: resortName, countryCode: countryCode, presentModal: presentViewModally, completionHandler: { (_) in
            self.hideHudAsync()
        })
    }
    
    func showLocationButtonPressed() {
        Constant.MyClassConstants.goingToMapOrWeatherView = true
        guard let coordinates = Constant.MyClassConstants.resortsDescriptionArray.coordinates else { return }
        guard let resortName = Constant.MyClassConstants.resortsDescriptionArray.resortName else { return }
        guard let cityName = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName else { return }
        showHudAsync()
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
                return UITableViewAutomaticDimension
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
                            if Constant.RunningDevice.deviceIdiom == .pad {
                                return resortInfoHeight + 40
                            } else {
                                return resortInfoHeight
                            }
                            
                        case 4 :
                            let count = nearbyArray.count + onsiteArray.count
                            if count > 0 {
                            if count == 1 {
                                if Constant.RunningDevice.deviceIdiom == .pad {
                                    return CGFloat (count * 20 + 60)
                                } else {
                                    return CGFloat (count * 20 + 30)
                                }
                                
                            } else {
                                if Constant.RunningDevice.deviceIdiom == .pad {
                                    return CGFloat (count * 20 + 160)
                                } else {
                                    return CGFloat (count * 20 + 60)
                                }
                            }
                                
                            } else { return 60 }

                        case 5 :
                            return 50
                        case 6 :
                            if Constant.MyClassConstants.resortsDescriptionArray.tdiUrl != nil {
                                return 600
                            } else {
                                return 0
                            }
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
                    
                    dismiss(animated: true, completion: {
                        self.present(mailComposeViewController, animated: true, completion: nil)
                    })
                } else {
                    showSendMailErrorAlert()
                }
            case 1:
                let txtComposeViewController = configuredMessageComposeViewController()
                if MFMessageComposeViewController.canSendText() {
                    dismiss(animated: true, completion: {
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
                navigationController?.pushViewController(detailMapViewController, animated: true)
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
            if senderViewController == Constant.MyClassConstants.showSearchResultButton {
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
                            return 2
                            
                        case 5 :
                            if let categories = Constant.MyClassConstants.resortsDescriptionArray.rating?.categories {
                                return categories.count > 0  ? categories.count + 1 : 0
                            } else { return  0 }
                            
                        case 6 :
                            return 2
                            
                        default :
                            return 2
                            
                        }
                    } else {
                        return 1
                    }
                } else {
                    switch section {
                    case 3 :
                        if Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name != nil {
                            return 1
                        } else {
                            return 0
                        }
                    case 5 :
                        
                        if !(Constant.MyClassConstants.resortsDescriptionArray.rating?.categories.isEmpty ?? true) {
                            return  1
                        } else {
                            return 0
                        }
                    case 6 :
                        if Constant.MyClassConstants.resortsDescriptionArray.tdiUrl != nil {
                            return 1
                        } else {
                            return 0
                        }
                    default :
                        return 1
                    }
                }
            default :
                return 1
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
                    cell.favoriteButton.isSelected = Helper.isResrotFavorite(resortCode: resortCode)
                }
                cell.resortNameGradientView.backgroundColor = UIColor.clear
                let frame = CGRect(x: 0, y: 300 - 68, width: cell.frame.size.width + 200, height: cell.resortNameGradientView.frame.size.height)
                cell.resortNameGradientView.frame = frame
                Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
                cell.resortCollectionView.collectionViewLayout.invalidateLayout()
                
                
                cell.detailsPageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                cell.detailsPageControl.activeImage = UIImage(named: "selected")
                
                cell.detailsPageControl.inactiveImage = UIImage(named: "unselected")
                
                cell.resortCollectionView.reloadData()
                if Constant.MyClassConstants.imagesArray.isEmpty {
                    cell.detailsPageControl.isHidden = true
                } else {
                    cell.detailsPageControl.isHidden = false
                }
                cell.detailsPageControl.numberOfPages = Constant.MyClassConstants.imagesArray.count
                cell.resortName.text = Constant.MyClassConstants.resortsDescriptionArray.resortName
                cell.resortAddress.text = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName
                cell.resortCode.text = Constant.MyClassConstants.resortsDescriptionArray.resortCode
                if let tier = Constant.MyClassConstants.resortsDescriptionArray.tier {
                    let imageStr = Helper.getTierImageName(tier:tier.uppercased())
                    if imageStr == "" {
                        cell.tierImageView.isHidden = true
                    } else {
                        cell.tierImageView.image = UIImage(named: imageStr)
                        cell.tierImageView.isHidden = false
                    }
                } else {
                    cell.tierImageView.isHidden = true
                }
                cell.allInclusiveImageView.image = #imageLiteral(resourceName: "Resort_All_Inclusive")
                cell.allInclusiveImageView.isHidden = !Constant.MyClassConstants.resortsDescriptionArray.allInclusive
                cell.favoriteButton.addTarget(self, action: #selector(favoritesButtonClicked(_:)), for: .touchUpInside)
                cell.backgroundColor = UIColor.clear
                cell.showResortWeatherbutton?.addTarget(self, action: #selector(showWeatherButtonPressed), for: .touchUpInside)
                cell.showResortLocationButton?.addTarget(self, action: #selector(showLocationButtonPressed), for: .touchUpInside)
                return cell
            case 2 :
                guard let cell =  mapcell else { mapcell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.mapTableViewCell, for: indexPath)
                    if let latitude = Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude, let longitude = Constant.MyClassConstants.resortsDescriptionArray.coordinates?.longitude {
                        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
                        let mapframe = CGRect(x: 0, y: 0, width: (mapcell?.frame.width) ?? 0 , height: (mapcell?.contentView.frame.height) ?? 0)
                        
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
                    mapcell?.contentView.addSubview(mapView)
                    return mapcell ?? UITableViewCell()  }
                
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
                            var airportArray = [String]()
                            if let airportName = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.name {
                               
                                let airportAdress = "Nearest Airport" + "\n" + airportName + "/"
                                airportArray.append(airportAdress)
                                if let airportCode = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.code {
                                    airportArray.append(airportCode)
                                }
                                if let miles = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.distanceInMiles {
                                    airportArray.append(" \(miles) Miles")
                                }
                                if let kms = Constant.MyClassConstants.resortsDescriptionArray.nearestAiport?.distanceInKilometers {
                                    airportArray.append(" \(kms) KM")
                                }
                               
                            }
                            var completeAddress = ""
                            if let address = Constant.MyClassConstants.resortsDescriptionArray.address {
                                let addressLine = address.addressLines[0]
                                completeAddress = "\n\nContact Information\n\(addressLine)\n\(address.cityName ?? ""),  \(address.territoryCode ?? "") \(address.postalCode ?? "")\n\n\(Constant.MyClassConstants.resortsDescriptionArray.phone ?? "")\n\(Constant.MyClassConstants.resortsDescriptionArray.webUrl ?? "")".localized()
                                airportArray.append(completeAddress)
                            }
                            
                            availableCountryCell?.infoLabel.text = airportArray.count > 0 ? airportArray.joined(separator: "").localized() : "".localized()
                            
                            // calculate cell height here
                            var height: CGFloat = 0.0
                            if let strHeight = availableCountryCell?.infoLabel.text {
                                if let font = UIFont(name: Constant.fontName.helveticaNeue, size: 15.0) {
                                    height = heightForView(strHeight, font: font, width: (view.frame.size.width) - 40)
                                    
                                }
                            }
                            resortInfoHeight = height + 30
                            let indexPath = NSIndexPath(item: indexPath.row, section: indexPath.section)
                            //tableViewResorts.reloadData()
                            tableViewResorts.reloadRows(at: [indexPath as IndexPath], with: .automatic)
                            
                        case 4 :
                            availableCountryCell?.infoLabel.isHidden = false
                            availableCountryCell?.infoLabel.numberOfLines = 0
                            if nearbyArray.count > 0 {
                                availableCountryCell?.infoLabel.text = amenityNearbyString  + "\n" + "\n" + " " +    amenityOnsiteString.localized()
                            } else {
                                availableCountryCell?.infoLabel.text = amenityNearbyString.localized()
                            }
                        case 5 :
                            let ratingCell = UITableViewCell()
                            let resortCategory = Constant.MyClassConstants.resortsDescriptionArray.rating?.categories ?? []
                            let categoryCode = resortCategory[indexPath.row - 1].categoryCode ?? ""
                             ratingCell.textLabel?.text = Helper.getRatingCategory(category: categoryCode)
                            
                            // to set cell background color
                            if indexPath.row % 2 != 0 {
                                ratingCell.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                            }
                            
                            let resortRating = resortCategory[indexPath.row - 1].rating
                            var image_X: CGFloat = view.frame.size.width / 2 + 40
                            var ratingImageArray = [UIImageView]()
                            let startRatingIndex = 1, endRatingIndex = 5
                            
                            // to show empty circle image
                            for _ in startRatingIndex...endRatingIndex {
                                let ratingImageView = UIImageView(image: #imageLiteral(resourceName: "empty_circle"))
                                ratingImageView.frame.origin.x = image_X
                                ratingCell.contentView.addSubview(ratingImageView)
                                image_X = image_X + ratingImageView.frame.size.width + 5
                                ratingImageView.center.y = ratingCell.center.y + 3
                                ratingImageArray.append(ratingImageView)
                            }

                            // show full rating here
                            let fullRating = Int(resortCategory[indexPath.row - 1].rating)
                            var index = 0
                            for _ in 0..<fullRating {
                                ratingImageArray[index].image = #imageLiteral(resourceName: "full_filled_circle")
                                index = index + 1
                            }
                            
                            // show hakf rating here
                            let hasHalfrating = resortRating.truncatingRemainder(dividingBy: 1.0)
                            if hasHalfrating > 0 {
                                ratingImageArray[fullRating].image = #imageLiteral(resourceName: "half_filled_circle")
                            }
                            return ratingCell
        
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
                                    availableCountryCell?.infoLabel.text = Helper.getRatingCategory(category: categoryCode ?? "") + "\n" + " \(resortCategory[indexPath.row - 1].rating)".localized()
                                }
                                var image_X: CGFloat = 0.0
                                
                                // Jira https://jira.iilg.com/browse/MOBI-1569
                                // Change to account for Int to Float change introduced in DarwinSDK commit
                                // https://bitbucket.iilg.com/projects/IIMOB/repos/darwin-sdk-ios/commits/87bb2a9b9b747993939022a87c2cb1297577e362
                                let castedInt = Int(resortCategory[indexPath.row - 1].rating)
                                for _ in 0..<castedInt {
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
        Constant.MyClassConstants.btnTag = -1
        guard let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode else { return }
        if Session.sharedSession.userAccessToken != nil {
            if sender.isSelected == false {
                
                showHudAsync()
                
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { _ in
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.append(resortCode)
                    self.tableViewResorts.reloadData()
                    ADBMobile.trackAction(Constant.omnitureEvents.event48, data: nil)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: sender)
                }, onError: {[weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
            } else {
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { _ in
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray = Constant.MyClassConstants.favoritesResortCodeArray.filter { $0 != resortCode }
                    self.tableViewResorts.reloadData()
                    ADBMobile.trackAction(Constant.omnitureEvents.event51, data: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: sender)
                }, onError: {[weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
            }
            
        } else {
            if Constant.RunningDevice.deviceIdiom == .pad {
                let storyboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginViewControlleriPad)
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                let storyboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController)
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
    }
}
extension ResortDetailsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = false
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
            dismiss(animated: true)
            break
        case MFMailComposeResult.saved.rawValue:
            intervalPrint("Email saved")
            break
        case MFMailComposeResult.sent.rawValue:
            intervalPrint("Email sent")
            let alertController = UIAlertController(title: "test".localized(), message: "test".localized(), preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Okay".localized(), style: .default, handler: nil)
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
        dismiss(animated: true)
    }
}

//******* For iPad add to favorites functionality ******//
extension ResortDetailsViewController: ResortDirectoryResortCellDelegate {
    func favoritesButtonSelectedAtIndex(_ index: Int) {
        
    }
}

