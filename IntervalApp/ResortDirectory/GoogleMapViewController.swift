//
//  GoogleMapViewController.swift
//  IntervalApp
//
//  Created by Chetu on 22/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import DarwinSDK
import SDWebImage
import IntervalUIKit
import SVProgressHUD
import RealmSwift

class GoogleMapViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var searchDisplayTableView: UITableView!
    @IBOutlet weak var googleMapSearchBar: UISearchBar!
    @IBOutlet weak var mapSideView: UIView!
    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var dragButton: UIButton!
    @IBOutlet weak var draggingView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    //***** Class variables declaration *****//
    let searchController = UISearchController(searchResultsController: nil)
    var marker:GMSMarker! = nil
    var bounds = GMSCoordinateBounds()
    var location = CLLocationCoordinate2D()
    var resortView = UIView()
    var resortCollectionView:UICollectionView!
    var index:Int = 0
    var selectedFavButton:UIButton!
    var hideSideView:Bool! = false
    let bottomResortHeight:CGFloat = 206+49//added default tab bar height
    var sourceController = ""
    var selectedResortsArray:NSMutableArray = []
    var drawButton:IUIKButton!
    var clearButton:IUIKButton!
    var listButton:IUIKButton!
    var listView = UIView()
    var zoomIn = false
    var listTableView:UITableView!
    var drawButtonView:UIView!
    var applyButton:UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //***** Adding notifications so that it invoke the specific method when the notification is fired *****//
        let notificationNames = [Constant.notificationNames.closeButtonClickedNotification, Constant.notificationNames.closeButtonClickedNotification, ]
        //Helper.addNotifications(notificationNames: notificationNames, senderVC: self)
        NotificationCenter.default.addObserver(self, selector: #selector(closeButtonClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resortSelectedFromsearchResultWithlatlong), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addMarkerWithRactangleRequest), name: NSNotification.Name(rawValue: Constant.notificationNames.addMarkerWithRactangleRequestNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapMarkers), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapForApply), object: nil)
        self.googleMapSearchBar.placeholder = Constant.buttonTitles.searchVacation
        
        
        if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck) {
            
            
            //***** Creating and adding left  bar button for back button *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(GoogleMapViewController.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
            
            
            self.navigationItem.title = Constant.ControllerTitles.vacationSearchDestinationController
            self.bottomViewWithButtons()
        }
        else {
            self.navigationItem.title = Constant.MyClassConstants.resortDirectoryTitle
        }
        
        //***** Condition for maintaining the back button and hamberger menu according to logged in or pre login *****//
        if( Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortFunctionalityCheck && Constant.MyClassConstants.isLoginSuccessfull) {
            if let rvc = self.revealViewController() {
                
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                self.view.addGestureRecognizer( rvc.panGestureRecognizer())
            }
            
        }
        else {
            
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed(_:)))
            
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        Constant.MyClassConstants.btnTag = -1
        Constant.MyClassConstants.isgetResortFromGoogleSearch = false
        
        //**** Remove added observers ****//
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.addMarkerWithRactangleRequestNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapForApply), object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        self.searchDisplayTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 152)
        
        if(Constant.MyClassConstants.addResortSelectedIndex.count == 0 && self.navigationItem.rightBarButtonItem != nil) {
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }else{
            if(self.navigationItem.rightBarButtonItem != nil){
                self.navigationItem.rightBarButtonItem!.isEnabled = true
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        Constant.MyClassConstants.runningDeviceHeight = self.view.bounds.height
        Constant.MyClassConstants.runningDeviceHeight = self.view.bounds.width
        
        getScreenFrameForOrientation()
    }
    
    func updateMapMarkers(){
        if(Constant.MyClassConstants.googleMarkerArray.count > 0 && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck){
            for selectedMarker in Constant.MyClassConstants.googleMarkerArray{
                if(selectedMarker.userData as! Int == Constant.MyClassConstants.collectionVwCurrentIndex) {
                    
                    if( selectedMarker.isFlat == true ) {
                        
                        selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                        selectedMarker.isFlat = false
                        
                    }
                    else {
                        
                        selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                        self.mapView.selectedMarker = selectedMarker
                        selectedMarker.isFlat = true
                        
                    }
                }
            }
        }
        if(resortCollectionView != nil){
            resortCollectionView.reloadData()
        }
    }
    func bottomViewWithButtons() {
        
        if(drawButton == nil){
            
            drawButtonView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44))
            drawButtonView.backgroundColor = UIColor.white
            
            self.drawButton = IUIKButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 44))
            self.drawButton.isEnabled = false
            self.drawButton.setTitle(Constant.MyClassConstants.draw, for: UIControlState.normal)
            self.drawButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
            self.drawButton.setTitleColor(IUIKColorPalette.altState.color, for: UIControlState.disabled)
            self.drawButton.addTarget(self, action: #selector(drawButtonPressed(sender:)), for: .touchUpInside)
            drawButtonView.addSubview(drawButton)
            
            self.clearButton = IUIKButton(frame: CGRect(x: self.view.frame.width/2, y: 0, width: self.view.frame.width/2, height: 44))
            self.clearButton.isEnabled = false
            self.clearButton.setTitle(Constant.MyClassConstants.clear, for: UIControlState.normal)
            self.clearButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
            self.clearButton.setTitleColor(IUIKColorPalette.altState.color, for: UIControlState.disabled)
            drawButtonView.addSubview(clearButton)
            
            
            if(Constant.RunningDevice.deviceIdiom == .phone){
                
                self.drawButton.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width/3, height: 44)
                self.clearButton.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width/3, height: 44)
                self.listButton = IUIKButton(frame: CGRect(x: 2*(self.view.frame.width/3), y: 0, width: self.view.frame.width/3, height: 44))
                self.listButton.isEnabled = false
                self.listButton.setTitle(Constant.MyClassConstants.list, for: UIControlState.normal)
                self.listButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
                self.listButton.setTitleColor(IUIKColorPalette.altState.color, for: UIControlState.disabled)
                self.listButton.setTitleColor(IUIKColorPalette.altState.color, for: UIControlState.disabled)
                self.listButton.addTarget(self, action: #selector(listButtonPressed(sender:)), for: .touchUpInside)
                drawButtonView.addSubview(listButton)
                
            }
            
            self.view.addSubview(drawButtonView)
            self.view.bringSubview(toFront: drawButtonView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // condition check to send resort directory
        if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortFunctionalityCheck) {
            
             // omniture tracking with event 40
            Helper.trackOmnitureCallForPageView(name: Constant.omnitureCommonString.resortDirectoryHome)
            
        }
        
        
        mapView.delegate = self
        mapView.animate(toZoom: 8)
        
        self.searchDisplayTableView.isHidden = true
        
        //***** Register custom cell with map tale view with some validation check *****//
        if(mapTableView != nil){
            self.mapTableView.isHidden = true
            if(mapTableView.tag != 1){
                mapTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier:  Constant.customCellNibNames.searchResultContentTableCell)
            }
        }
        
        
        //***** Creating and adding right bar button for Apply selected resort button *****//
        if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck) {
            applyButton = UIBarButtonItem(title: Constant.AlertPromtMessages.applyButtonTitle, style:.plain, target: self, action: #selector(applyButtonPressed(_:)))
            applyButton.isEnabled = false
            applyButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = applyButton
        }
        
        if(mapSideView != nil){
            self.containerView.tag = 100
            containerView.isHidden = true
            self.view.bringSubview(toFront: mapSideView)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(loginNotification), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        self.googleMapSearchBar.delegate = self
    }
    //***** Method called when searched resort or destination selected and generate resort marker pin on map *****//
    func addMarkerWithRactangleRequest() {
        
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.latitude)!,longitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.longitude)!, zoom: self.mapView.camera.zoom)
        
        self.mapView.camera = camera
        var  position:CLLocationCoordinate2D!
        var tag = 0
        
        for resort in Constant.MyClassConstants.resortsArray {
            
            position = CLLocationCoordinate2DMake((resort.coordinates?.latitude)!,resort.coordinates!.longitude)
            marker = GMSMarker()
            marker.position = position
            marker.userData = tag
            tag = tag + 1
            marker.isFlat = false
            marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
            marker.appearAnimation = GMSMarkerAnimation.pop
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = self.mapView
            Constant.MyClassConstants.googleMarkerArray.append(marker)
            
        }
    }
    
    //***** Method called when search result map button pressed *****//
    
    func resortShowMapPressedAtIndex(sender:UIButton) {
        
           Constant.MyClassConstants.destinationOrResortSelectedBy = Constant.omnitureCommonString.mapSelection
        self.hidePopUpView()
        
        let senderButton = sender
        
        if (senderButton.superview!.superview!.tag == 1) {
            
            let selectedResort = Constant.MyClassConstants.resorts![sender.tag]
            Constant.MyClassConstants.isgetResortFromGoogleSearch = true
            self.googleMapSearchBar.resignFirstResponder()
            self.googleMapSearchBar.showsCancelButton = false
            Helper.getResortWithResortCode(code: selectedResort.resortCode!, viewcontroller: self)
            self.googleMapSearchBar.text = ""
            
        }
        else {
            
            Constant.MyClassConstants.isgetResortFromGoogleSearch = true
            self.googleMapSearchBar.resignFirstResponder()
            self.googleMapSearchBar.showsCancelButton = false
            Helper.addServiceCallBackgroundView(view: self.view)
            SVProgressHUD.show()
            DirectoryClient.getResortsWithinGeoArea(UserContext.sharedInstance.accessToken, geoArea: Constant.MyClassConstants.destinations![sender.tag].geoArea, onSuccess: { (response) in
                print(response)
                Constant.MyClassConstants.resortsArray.removeAll()
                Constant.MyClassConstants.resortsArray = response
                Constant.MyClassConstants.addResortSelectedIndex.removeAllObjects()
                
                var i = 0
                for _ in response{
                    Constant.MyClassConstants.addResortSelectedIndex.add(i)
                    i = i + 1
                }
                self.navigationItem.rightBarButtonItem!.isEnabled = true
                Constant.MyClassConstants.googleMarkerArray.removeAll()
                if(Constant.MyClassConstants.resortsArray.count > 0){
                let resort = Constant.MyClassConstants.resortsArray[0]
                let location = CLLocation.init(latitude: (resort.coordinates?.latitude)!, longitude: (resort.coordinates?.longitude)!)
                
                self.displaySearchedResort(location: location)
                if(self.mapTableView != nil){
                    self.mapTableView.reloadData()
                }
                }
                
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
            })
            { (error) in
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
            }
        }
    }
    //***** Method called when destination or resort selected from  *****//
    func destinationSelectedAtIndex(sender:UIButton) {
        
        
         Constant.MyClassConstants.destinationOrResortSelectedBy = Constant.omnitureCommonString.typedSelection
        if(self.sourceController != "" && self.sourceController == Constant.MyClassConstants.createAlert || self.sourceController == Constant.MyClassConstants.editAlert) {
            let senderButton = sender
            
            if (senderButton.superview!.superview!.tag == 0) {
                
                let dict = Constant.MyClassConstants.destinations![sender.tag]
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(dict)
                Constant.MyClassConstants.alertSelectedDestination.append(dict)
                
                print(Constant.MyClassConstants.alertSelectedDestination,dict)
                
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dict.destinationId!)
            }
            else {
                
                let dict = Constant.MyClassConstants.resorts![sender.tag]
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(dict)
                Constant.MyClassConstants.alertSelectedResorts.append(dict)
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dict.resortCode!)
            }
            
            sender.isSelected = true
            _ = self.navigationController?.popViewController(animated: true)
            
        }
        else {
            
            
            let senderButton = sender
            let realm = try! Realm()
            if (senderButton.superview!.superview!.tag == 0) {
                if ((Constant.MyClassConstants.destinations?.count)! > 0) {
                    let dict = Constant.MyClassConstants.destinations![sender.tag]
                    var areaOfInfluenceArray = [AreaOfInfluenceDestination]()
                    areaOfInfluenceArray.append(dict)
                    
                    //Realm local storage for selected destination
                    let storedata = RealmLocalStorage()
                    let Membership = UserContext.sharedInstance.selectedMembership
                    let desList = DestinationList()
                    desList.aoid = dict.aoiId
                    desList.countryCode = (dict.address?.countryCode)!
                    desList.destinationId = dict.destinationId
                    desList.destinationName = dict.destinationName
                    
                    if let teriCode = dict.address?.territoryCode {
                        desList.territorrycode = teriCode
                    }
                    else {
                        desList.territorrycode = ""
                    }
                    storedata.destinations.append(desList)
                    storedata.membeshipNumber = Membership!.memberNumber!
                    Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dict.destinationId)
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(storedata)
                    }
                    
                    let allDest = Helper.getLocalStorageAllDest()
                    if (allDest.count > 0) {
                        Constant.MyClassConstants.whereTogoContentArray.removeObject(at: 0)
                        Helper.deleteObjectFromAllDest()
                    }
                    
                }else{
                    let allDest = Helper.getLocalStorageAllDest()
                    if (allDest.count > 0) {
                        Helper.deleteObjectFromAllDest()
                    }
                }
            }
            else {
                
                let dict = Constant.MyClassConstants.resorts![sender.tag]
                let address = dict.address
                
                //Realm local storage for selected resort
                let storedata = RealmLocalStorage()
                let Membership = UserContext.sharedInstance.selectedMembership
                let resortList = ResortList()
                resortList.resortCityName = (address?.cityName)!
                resortList.resortCode = dict.resortCode!
                resortList.thumbnailurl = dict.images[0].url!
                resortList.resortName = "\(dict.resortName!) - \(dict.resortCode!)"
                
                resortList.territorrycode = (address?.territoryCode)!
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dict.resortCode!)
                storedata.resorts.append(resortList)
                storedata.membeshipNumber = Membership!.memberNumber!
                try! realm.write {
                    realm.add(storedata)
                }
                let allDest = Helper.getLocalStorageAllDest()
                if (allDest.count > 0) {
                    Helper.deleteObjectFromAllDest()
                }
            }
            sender.isSelected = true
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //***** Creating map with resorts getting from current location when map screen landing first time *****//
    func updateMapWithMarkers() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.latitude)!,longitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.longitude)!, zoom: self.mapView.camera.zoom)
        
        self.mapView.camera = camera
        var  position:CLLocationCoordinate2D!
        var tag = 0
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        
        for resort in Constant.MyClassConstants.resortsArray {
            
            position = CLLocationCoordinate2DMake((resort.coordinates?.latitude)!,resort.coordinates!.longitude)
            marker = GMSMarker()
            marker.position = position
            marker.userData = tag
            tag = tag + 1
            marker.isFlat = false
            if(Constant.MyClassConstants.addResortSelectedIndex.count > 0 &&  Constant.MyClassConstants.isgetResortFromGoogleSearch == true){
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
            }else{
                marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
            }
            marker.appearAnimation = GMSMarkerAnimation.pop
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = self.mapView
            Constant.MyClassConstants.googleMarkerArray.append(marker)
            
        }
        if(self.mapTableView != nil){
            self.mapTableView.reloadData()
        }
    }
    
    func apiCallWithRectangleRequest(request:GeoArea) {
        
        DirectoryClient.getResortsWithinGeoArea(Constant.MyClassConstants.systemAccessToken, geoArea: request, onSuccess: { (response) in
            
            Constant.MyClassConstants.resortsArray = response
            if(response.count > 0){
                self.updateMapWithMarkers()
            }
            if(Constant.RunningDevice.deviceIdiom == .pad && !self.hideSideView && self.containerView.isHidden == true){
                
                Constant.MyClassConstants.addResortSelectedIndex.removeAllObjects()
                self.mapTableView.reloadData()
            }
            
        }) {
            (error) in
        }
    }
    
    
    //***** Creating map with resorts getting from current location when map screen landing first time *****//
    func createMapViewWithMarkers(location:CLLocation) {
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 8.0)
        let mapframe = CGRect(x: 0, y: 108, width: self.view.frame.width, height: self.view.frame.height-108-49)
        mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        var  position:CLLocationCoordinate2D!
        var tag = 0
        
        for resort in Constant.MyClassConstants.resortsArray {
            
            position = CLLocationCoordinate2DMake((resort.coordinates?.latitude)!,resort.coordinates!.longitude)
            marker = GMSMarker()
            marker.position = position
            marker.userData = tag
            tag = tag + 1
            marker.isFlat = false
            if(Constant.MyClassConstants.addResortSelectedIndex.count > 0 &&  Constant.MyClassConstants.isgetResortFromGoogleSearch == true){
                self.navigationItem.rightBarButtonItem!.isEnabled = true
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
            }else{
                marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                marker.isFlat = false
            }
            marker.appearAnimation = GMSMarkerAnimation.pop
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = nil
            Constant.MyClassConstants.googleMarkerArray.append(marker)
            
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
        mapView.delegate = self
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        mapView.animate(toZoom: 8)
        for subView in self.view.subviews{
            if (subView.isKind(of: GMSMapView.self)){
                subView.removeFromSuperview()
            }
        }
        self.view.addSubview(self.mapView)
        if(mapSideView != nil){
            self.view.bringSubview(toFront: mapSideView)
            self.view.bringSubview(toFront: draggingView)
        }
    }
    //***** Updating map with resorts getting from map search bar from resorsts or destination *****//
    func displaySearchedResort(location:CLLocation) {
        
        let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.latitude)!,longitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.longitude)!, zoom: self.mapView.camera.zoom)
        
        self.mapView.camera = camera
        var  position:CLLocationCoordinate2D!
        var tag = 0
        
        for resort in Constant.MyClassConstants.resortsArray {
            
            position = CLLocationCoordinate2DMake((resort.coordinates?.latitude)!,resort.coordinates!.longitude)
            marker = GMSMarker()
            marker.position = position
            marker.userData = tag
            tag = tag + 1
            if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck){
                marker.isFlat = true
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
            }else{
                marker.isFlat = false
                marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
            }
            marker.appearAnimation = GMSMarkerAnimation.pop
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = self.mapView
            Constant.MyClassConstants.googleMarkerArray.append(marker)
            
        }
        if(self.mapTableView != nil){
            self.mapTableView.reloadData()
        }
        mapView.animate(toZoom: 10.0)
    }
    
    //***** This method executes when bottom resort view favorite button pressed *****//
    func bottomResortFavoritesButtonPressed(sender:UIButton) {
        
        selectedFavButton = sender
        if(UserContext.sharedInstance.accessToken == nil) {
            
            let storyboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController)
            self.present(viewController, animated: true, completion: nil)
        }
        else {
            if(sender.isSelected == true) {
                sender.isSelected = false
            }
            else {
                sender.isSelected = true
            }
        }
    }
    //***** Function to hold selected object and release on deselecton *****//
    func addResortPressedAtIndex(sender:UIButton) {
        if(sender.isSelected == true){
            sender.isSelected = false
            let objectAt = Constant.MyClassConstants.addResortSelectedIndex.index(of: sender.tag)
            Constant.MyClassConstants.addResortSelectedIndex.removeObject(at: objectAt)
        }else{
            sender.isSelected = true
            Constant.MyClassConstants.addResortSelectedIndex.add(sender.tag)
        }
        
        
        for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
            
            if(selectedMarker.userData as! Int == sender.tag) {
                
                if( selectedMarker.isFlat == true ) {
                    
                    selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                    selectedMarker.isFlat = false
                    
                }
                else {
                    
                    selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                    self.mapView.selectedMarker = selectedMarker
                    selectedMarker.isFlat = true
                    
                }
            }
            else {
                
            }
        }
        
        
        if(Constant.MyClassConstants.addResortSelectedIndex.count == 0) {
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        }
        if(Constant.RunningDevice.deviceIdiom == .phone && resortCollectionView != nil){
            resortCollectionView.reloadData()
        }
        if (mapTableView != nil){
            mapTableView.reloadData()
        }
        if (listTableView != nil){
            listTableView.reloadData()
        }
    }
    
    func checkNil(sender:AnyObject){
    }
    
    
    
    //***** This methods called when the added notification fired from notification center *****//
    func loginNotification() {
        if(selectedFavButton != nil){
            selectedFavButton.isSelected = true
        }
    }
    
    //***** need to work from piyush *****//
    func reloadView(){
        if (self.mapTableView != nil){
            self.mapTableView.reloadData()
        }
    }
    
    //***** This function called when navigation back button pressed *****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortDirectoryTitle){
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             Constant.MyClassConstants.selectionType = -1
            if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortFunctionalityCheck){
                self.dismiss(animated: true, completion: nil)
            }else{
                 _ = self.navigationController?.popViewController(animated: true)
            }
           
            
        }
        
    }
    //***** This function called when navigation back button pressed *****//
    func applyButtonPressed(_ sender:UIBarButtonItem) {
        
        if(self.sourceController == Constant.MyClassConstants.vacationSearch) {
            
            let storedata = RealmLocalStorage()
            let Membership = UserContext.sharedInstance.selectedMembership
            let resortList = ResortList()
            
            for index in  Constant.MyClassConstants.addResortSelectedIndex {
                
                
                let object = Constant.MyClassConstants.resortsArray[index as! Int]
                let resortbyMap = ResortByMap()
                
                resortbyMap.resortCode = object.resortCode!
                resortbyMap.resortName = object.resortName!
                if let territoryCode = object.address?.territoryCode{
                  resortbyMap.territorrycode = territoryCode
                }
                resortList.resortArray.append(resortbyMap)
            }
            Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(Constant.MyClassConstants.resortsArray[0].resortCode!)
            storedata.membeshipNumber = Membership!.memberNumber!
            
            storedata.resorts.append(resortList)
            let realm = try! Realm()
            try! realm.write {
                realm.add(storedata)
            }
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }
        else {
            
            let selectedResortsArray: NSMutableArray = []
            for index in  Constant.MyClassConstants.addResortSelectedIndex {
                selectedResortsArray.add(Constant.MyClassConstants.resortsArray[index as! Int])
            }
            Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(selectedResortsArray)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // ***** Method called when we performing the swipe functionality to see multiple resort from bottom view *****//
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(resortCollectionView != nil){
            
            let pageWidth = resortCollectionView.bounds.size.width
            let page = scrollView.contentOffset.x / pageWidth
            index = Int(page)
        }
    }
    
    // ***** Drag button function implementation *****//
    @IBAction func dragButtonClicked(_ sender: AnyObject?){
        let currentZoom = mapView.camera.zoom
        if(self.draggingView.frame.origin.x == 0){
            hideSideView = false
            self.mapSideView.isHidden = false
            if(currentZoom >= 10){
                self.view.endEditing(true)
                self.mapTableView.isHidden = false
                self.alertView.isHidden = true
            }
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                self.mapSideView.frame = CGRect(x: 0, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                self.draggingView.frame = CGRect(x: self.mapSideView.frame.size.width, y:self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                
            }, completion: { _ in
                
                self.dragButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
            })
        }else{
            self.view.endEditing(true)
            hideSideView = true
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                self.draggingView.frame = CGRect(x: 0, y:self.draggingView.frame.origin.y, width:self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
            }, completion: { _ in
                
                self.dragButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
        }
    }
    
    //***** List Button Pressed. *****//
    func listButtonPressed(sender:UIButton){
        
        if(Constant.MyClassConstants.addResortSelectedIndex.count > 0){
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        }
        
        if(listTableView == nil){
            listView.frame = CGRect(x: 0, y:UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (64+50))
            listTableView = UITableView()
            listTableView.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: listView.bounds.size.height)
            listTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier:  Constant.customCellNibNames.searchResultContentTableCell)
            listTableView.dataSource = self
            listTableView.delegate = self
            listView.addSubview(listTableView)
            self.view.addSubview(listView)
        }else{
            listTableView.reloadData()
        }
        
        self.view.bringSubview(toFront: drawButtonView)
        self.view.bringSubview(toFront: listView)
        animateListView(sender: sender)
    }
    
    // ***** Animate list view method *****//
    func animateListView(sender:UIButton){
        self.view.bringSubview(toFront: self.drawButtonView)
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            if(self.listView.frame.origin.y == UIScreen.main.bounds.height && sender.currentTitle == Constant.MyClassConstants.list){
                
                self.listButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
                self.drawButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
                self.clearButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
                self.listView.frame = CGRect(x: 0, y: 64, width: self.listView.frame.size.width, height: self.listView.frame.size.height)
                
            }else{
                
                self.listButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
                self.clearButton.setTitleColor(IUIKColorPalette.primary1.color, for: UIControlState.normal)
                sender.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
                self.listView.frame = CGRect(x: 0, y:UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (64+50))
                
            }
        }, completion: { _ in
        })
    }
    
    // ***** Draw button pressed *****//
    func drawButtonPressed(sender:UIButton){
        if(Constant.RunningDevice.deviceIdiom == .phone){
            animateListView(sender: sender)
        }
    }
    
    func hideMapSideView(flag:Bool) {
        
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            
            self.hideSideView = true
        }, completion: { _ in
            
            self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
            self.draggingView.frame = CGRect(x: 0, y:self.draggingView.frame.origin.y, width:self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
            self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            self.dragButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Method to create bottom resort view in collection view and pop up with custom animation *****//
    func createBottomResortView(marker :GMSMarker) {
        
        if(resortCollectionView != nil && Constant.MyClassConstants.resortsArray.count > 0){
            resortCollectionView.reloadData()
            self.resortView.isHidden = false
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.bottomResortHeight + 50), width: self.view.frame.width, height: self.bottomResortHeight)
                
                self.view.bringSubview(toFront: self.resortView)
            }, completion: { _ in
                
            })
            self.view.bringSubview(toFront: self.resortView)
        }else{
            
            if(self.navigationItem.rightBarButtonItem != nil && Constant.MyClassConstants.addResortSelectedIndex.count > 0){
                self.navigationItem.rightBarButtonItem!.isEnabled = true
            }
            
            resortView.frame = CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: self.view.frame.height - (self.view.frame.height - self.bottomResortHeight))
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = CGSize(width:self.resortView.frame.width, height: self.resortView.frame.height)
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            resortCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.resortView.bounds.width, height:self.resortView.bounds.height), collectionViewLayout: layout)
            
            resortCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            resortCollectionView.backgroundColor = UIColor.clear
            resortCollectionView.delegate = self
            resortCollectionView.dataSource = self
            resortCollectionView.isPagingEnabled = true
            resortView.addSubview(resortCollectionView)
            
            /*** Subtracting tab bar default height - 49 ****/
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.bottomResortHeight + 50), width: self.view.frame.width, height: self.bottomResortHeight)
                
            }, completion: { _ in
                
            })
            let topSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
            let bottomSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
            
            topSwipe.direction = .up
            bottomSwipe.direction = .down
            resortView.addGestureRecognizer(topSwipe)
            resortView.addGestureRecognizer(bottomSwipe)
            self.view.addSubview(resortView)
        }
    }
    
    // ***** This method executes when we want to hide bottom resort view *****//
    func removeBottomView() {
        if(self.navigationItem.rightBarButtonItem != nil){
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            self.resortView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.bottomResortHeight)
            
        }, completion: { _ in
            
        })
        
    }
    
    // ***** Method to handle swipe gesture from bottom resort view *****//
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .up) {
            
            if(Constant.MyClassConstants.systemAccessToken != nil) {
                let selectedResort = Constant.MyClassConstants.resortsArray[index]
                Constant.MyClassConstants.isgetResortFromGoogleSearch = false
                Helper.getUserFavorites()
                Helper.getResortWithResortCode(code: selectedResort.resortCode!,viewcontroller:self)
            }
        }
        
        if (sender.direction == .down) {
            self.removeBottomView()
        }else if (sender.direction == .left && Constant.RunningDevice.deviceIdiom == .pad) {
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                self.draggingView.frame = CGRect(x: 0, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                
            }, completion: { _ in
                self.dragButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            })
            
        }else if (sender.direction == .right){
            self.mapSideView.isHidden = false
            self.draggingView.isHidden = false
            self.containerView.isHidden = false
            self.view.bringSubview(toFront: self.containerView)
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                self.containerView.frame = CGRect(x: 0, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.self.containerView.frame.size.height)
            }, completion: { _ in
            })
        }
        
    }
    //***** Method called to close the detailed screen from ipad screen *****//
    func closeButtonClicked(){
        if(Constant.RunningDevice.deviceIdiom == .pad){
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
            }, completion: { _ in
                self.containerView.isHidden = true
                self.mapView.selectedMarker = nil
            })
        }else{
            updateMapMarkers()
        }
    }
    
    //***** Function to change zoom *****//
    func zoomChanged(){
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
            
            if(self.zoomIn == true) {
                
                if(self.navigationItem.rightBarButtonItem != nil) {
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                
                UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                    
                    self.mapSideView.frame = CGRect(x: 0, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                    self.draggingView.frame = CGRect(x: self.mapSideView.frame.size.width, y:self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                    
                }, completion: { _ in
                    
                    self.mapTableView.isHidden = false
                    self.mapSideView.isHidden = false
                    self.draggingView.isHidden = false
                    self.containerView.isHidden = true
                    self.alertView.isHidden = true
                })
            }
            else {
                
                if(self.navigationItem.rightBarButtonItem != nil && Constant.MyClassConstants.addResortSelectedIndex.count == 0) {
                    if(self.navigationItem.rightBarButtonItem != nil){
                        self.navigationItem.rightBarButtonItem!.isEnabled = false
                    }
                }else{
                    if(self.navigationItem.rightBarButtonItem != nil){
                        self.navigationItem.rightBarButtonItem!.isEnabled = true
                    }
                }
                self.mapSideView.isHidden = false
                self.draggingView.isHidden = false
                self.containerView.isHidden = true
                UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                    
                    if(self.mapView.camera.zoom >= 10){
                        self.mapTableView.isHidden = false
                    }else{
                        self.alertView.isHidden = false
                    }
                }, completion: { _ in
                    
                })
            }
        }
    }
    
    //***** Function to select all destinations *****//
    func selectAllDestinations(){
        if(Constant.MyClassConstants.whereTogoContentArray.count > 0) {
            
            SimpleAlert.searchAlert(self, title: Constant.AlertMessages.searchAlertTitle, message: Constant.AlertMessages.searchAlertMessage)
        }
        else {
            Helper.deleteObjectFromAllDest()
            let allavailabledest = AllAvailableDestination()
            allavailabledest.destination = Constant.MyClassConstants.allDestinations
            Constant.MyClassConstants.whereTogoContentArray.add(Constant.MyClassConstants.allDestinations)
            let realm = try! Realm()
            try! realm.write {
                realm.add(allavailabledest)
            }
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //***** Function for alert controller yes button click *****//
    func searchYesClicked(){
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        let allavailabledest = AllAvailableDestination()
        allavailabledest.destination = Constant.MyClassConstants.allDestinations
        try! realm.write {
            print(allavailabledest.destination)
            realm.add(allavailabledest)
        }
        Constant.MyClassConstants.destinationOrResortSelectedBy = Constant.omnitureCommonString.allDestination
        Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
        Constant.MyClassConstants.whereTogoContentArray.add(Constant.MyClassConstants.allDestinations)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //***** Method to show pop up with searched resort or destination on table view with custom animation *****//
    func showPopUpView() {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GoogleMapViewController.handleSwipes(sender:)))
        leftSwipe.direction = .left
        handleSwipes(sender: leftSwipe)
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
            removeBottomView()
        }
        if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.createAlert && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.editAlert){
            //**** Create table view header ****//
            let  headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.searchDisplayTableView.bounds.width, height: 40))
            let nameLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.searchDisplayTableView.bounds.width - 130, height: 30))
            
            nameLabel.text = Constant.HeaderViewConstantStrings.search
            nameLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
            headerView.addSubview(nameLabel)
            
            let selectButton = UIButton(type : UIButtonType.system) as UIButton
            let bounds = CGRect(x: self.view.bounds.width-68, y: 0, width: 60, height: 40)
            selectButton.frame = bounds
            selectButton.imageView?.contentMode = .scaleAspectFit
            selectButton.setImage(UIImage(named:Constant.assetImageNames.plusIcon), for: .normal)
            selectButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            selectButton.layer.cornerRadius = 5
            selectButton.addTarget(self, action: #selector(selectAllDestinations), for: .touchUpInside)
            headerView.addSubview(selectButton)
            if(Constant.MyClassConstants.whereTogoContentArray.contains(Constant.MyClassConstants.allDestinations)) {
                selectButton.isEnabled = false
            }
            else {
                selectButton.isEnabled = true
            }
            self.searchDisplayTableView.tableHeaderView = headerView
        }
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            self.searchDisplayTableView.frame = CGRect(x: 0, y: 108, width: self.view.frame.width,  height: UIScreen.main.bounds.height - 152)
            
            if(Constant.RunningDevice.deviceIdiom == .pad){
                if(self.containerView.frame.origin.x == 0){
                    self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                }
            }
            
        }, completion: { _ in
            self.searchDisplayTableView.isHidden = false
        })
        
    }
    
    //***** Method to hide pop up with searched resort or destination on table view with custom animation *****//
    func hidePopUpView() {
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            
            self.searchDisplayTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width,  height: UIScreen.main.bounds.height - 152)
            
        }, completion: { _ in
            self.searchDisplayTableView.isHidden = true
        })
    }
    
    //***** Function to get collection view visible index. *****//
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for collectionCell in resortCollectionView.visibleCells{
            let indexPath = resortCollectionView.indexPath(for: collectionCell)
            index = (indexPath?.item)!
        }
    }
    
    //***** Show screen in landscape/potrait mode. *****//
    func getScreenFrameForOrientation(){
        if(Constant.RunningDevice.deviceIdiom == .pad){
            if(self.containerView.isHidden == false){
                self.containerView.isHidden = true
            }else{
                self.mapSideView.isHidden = true
            }
            
            let containerVC = self.childViewControllers[0] as! ResortDetailsViewController
            containerVC.senderViewController = Constant.MyClassConstants.searchResult
            containerVC.viewWillAppear(true)
        }
        
    }
    
    
    //***** Method called when the added notification fired from other classes *****//
    func resortSelectedFromsearchResultWithlatlong() {
        
        Constant.MyClassConstants.addResortSelectedIndex.removeAllObjects()
        
        var i = 0
        for _ in Constant.MyClassConstants.resortsArray{
            Constant.MyClassConstants.addResortSelectedIndex.add(i)
            i = i + 1
        }
        
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        let resort = Constant.MyClassConstants.resortsArray[0]
        let location = CLLocation.init(latitude: (resort.coordinates?.latitude)!, longitude: (resort.coordinates?.longitude)!)
        self.displaySearchedResort(location: location)
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
            mapTableView.reloadData()
        }
    }
}

//***** Map view delegate methods to handle map *****//
extension GoogleMapViewController:GMSMapViewDelegate {
    
    //***** this method called when map will move *****//
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if(Constant.RunningDevice.deviceIdiom == .pad){
        }
    }
    
    //***** This method called when map tap on any place and give the tapped coordinates *****//
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    //***** this method called when map marker selected *****//
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            Constant.MyClassConstants.isgetResortFromGoogleSearch = false
            
            if(mapView.selectedMarker == nil){
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
                self.mapView.selectedMarker = marker
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[marker.userData as! Int]
                
                Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsDescriptionArray.resortCode!,viewcontroller:self)
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                self.handleSwipes(sender: rightSwipe)
                
            }else{
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[marker.userData as! Int]
                
                Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsDescriptionArray.resortCode!,viewcontroller:self)
                
                for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
                    
                    if(selectedMarker.userData as! Int == marker.userData as! Int) {
                        
                        if( marker.isFlat == true ) {
                            
                            marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                            marker.isFlat = false
                            
                        }
                        else {
                            
                            marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                            self.mapView.selectedMarker = marker
                            marker.isFlat = true
                            
                        }
                    }
                    else {
                        
                        selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                        selectedMarker.isFlat = false
                    }
                }
                
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                self.handleSwipes(sender: rightSwipe)
            }
        }else if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck){
            self.mapView.selectedMarker = marker
            self.createBottomResortView(marker: marker)
            
        }else{
            
            if(mapView.selectedMarker == nil) {
                
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
                self.mapView.selectedMarker = marker
                self.createBottomResortView(marker: marker)
                
            }else{
                if(marker == mapView.selectedMarker){
                    marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                    marker.isFlat = false
                    self.createBottomResortView(marker: marker)
                }else{
                    mapView.selectedMarker?.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                    mapView.selectedMarker?.isFlat = false
                    
                    marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                    marker.isFlat = true
                    self.mapView.selectedMarker = marker
                    self.createBottomResortView(marker: marker)
                }
            }
        }
        return true
    }
    
    //***** This method called when map camera position changes *****//
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let currentZoom = mapView.camera.zoom
        if (currentZoom >= 10) {
            //self.zoomIn = false
            self.zoomChanged()
            self.view.endEditing(true)
            if(self.sourceController == Constant.MyClassConstants.createAlert || self.sourceController == Constant.MyClassConstants.editAlert || self.sourceController == Constant.MyClassConstants.vacationSearch) {
                self.drawButton.isEnabled = true
                self.clearButton.isEnabled = true
                if((self.listButton) != nil) {
                    
                    self.listButton.isEnabled = true
                }
            }
            for markerInArray in Constant.MyClassConstants.googleMarkerArray {
                markerInArray.map = self.mapView
            }
            
        }
        else {
            for markerInArray in Constant.MyClassConstants.googleMarkerArray {
                markerInArray.map = nil
            }
            self.zoomIn = false
        }
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if(mapView.camera.zoom >= 10) {
            
            if(Constant.MyClassConstants.isgetResortFromGoogleSearch == false) {
                
                let bounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())
                let southWest = CLLocationCoordinate2D(latitude: bounds.southWest.latitude, longitude: bounds.southWest.longitude)
                let northEast = CLLocationCoordinate2D(latitude: bounds.northEast.latitude, longitude: bounds.northEast.longitude)
                let ractangleRequest = GeoArea.init(nwLat: northEast.latitude, nwLon: northEast.latitude, seLat: southWest.longitude, seLon: southWest.longitude)
                self.apiCallWithRectangleRequest(request: ractangleRequest)
                
            }
            else {
                
                Constant.MyClassConstants.isgetResortFromGoogleSearch = false
            }
        }
    }
    
}

//***** Collection view delegate methods to handle collection view *****//

extension GoogleMapViewController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.item
    }
}

//***** Collection view datasource methods to handle collection view *****//
extension GoogleMapViewController:UICollectionViewDataSource {
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.resortsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let resort = Constant.MyClassConstants.resortsArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath as IndexPath)
        
        let resortImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height) )
        resortImageView.backgroundColor = UIColor.lightGray
        
        if(resort.images.count > 1){
            var url = URL(string: "")
            let imagesArray = resort.images
            for imgStr in imagesArray {
                if(imgStr.size == Constant.MyClassConstants.imageSize) {
                    url = URL(string: imgStr.url!)!
                    break
                }
            }
            
        resortImageView.setImageWith(url , completed: { (image:UIImage?, error:Swift.Error?, cacheType:SDImageCacheType, imageURL:URL?) in
            if (error != nil) {
                resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
            }
        }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }else{
            var imageURL = ""
            if(resort.images.count > 0){
             imageURL = resort.images[resort.images.count].url!
            }
            
            resortImageView.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Swift.Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                if (error != nil) {
                    resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }
        cell.addSubview(resortImageView)
        
        
        let resortTierImageView = UIImageView(frame: CGRect(x:cell.contentView.frame.size.width/2 - 25, y: 0, width: 50, height: 30) )
        resortTierImageView.image = UIImage(named:Constant.assetImageNames.upArrowImage)
        cell.addSubview(resortTierImageView)
        
        let resortFavoritesButton = UIButton(frame: CGRect(x: cell.contentView.frame.width -  60, y: 10, width: 50, height: 50))
        resortFavoritesButton.tag = indexPath.row
        
        if(self.sourceController == Constant.MyClassConstants.createAlert || self.sourceController == Constant.MyClassConstants.editAlert || self.sourceController == Constant.MyClassConstants.vacationSearch) {
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.optOffImage), for: UIControlState.normal)
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.optOnImage), for: UIControlState.selected)
            if(Constant.MyClassConstants.addResortSelectedIndex.contains(indexPath.row)){
                resortFavoritesButton.isSelected = true
            }else{
                resortFavoritesButton.isSelected = false
            }
            
            resortFavoritesButton.addTarget(self, action: #selector(addResortPressedAtIndex(sender:)), for: .touchUpInside)
        }else{
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.favoritesOffImage), for: UIControlState.normal)
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.favoritesOnImage), for: UIControlState.selected)
            resortFavoritesButton.addTarget(self, action: #selector(
                bottomResortFavoritesButtonPressed(sender:)), for: .touchUpInside)
            let status = Helper.isResrotFavorite(resortCode: resort.resortCode!)
            if (status) {
                resortFavoritesButton.isSelected = true
            }
            else {
                resortFavoritesButton.isSelected = false
            }
        }
        resortFavoritesButton.tag = indexPath.row
        
        cell.addSubview(resortFavoritesButton)
        
        let resortNameGradientView = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.height - 63, width: cell.contentView.frame.width, height: 63))
        Helper.addLinearGradientToView(view: resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        cell.addSubview(resortNameGradientView)
        
        let resortNameLabel = UILabel(frame: CGRect(x: 20, y: 0, width: cell.contentView.frame.width - 40, height: 20))
        resortNameLabel.text = resort.resortName
        resortNameLabel.textColor = IUIKColorPalette.primary1.color
        resortNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
        resortNameGradientView.addSubview(resortNameLabel)
        
        let resortCountryLabel = UILabel(frame: CGRect(x: 20, y: 20, width: cell.contentView.frame.width - 20, height: 20))
        resortCountryLabel.text = resort.address?.cityName
        resortCountryLabel.textColor = UIColor.black
        resortCountryLabel.font = UIFont(name:Constant.fontName.helveticaNeue,size: 14)
        resortNameGradientView.addSubview(resortCountryLabel)
        
        let resortCodeLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 50, height: 20))
        resortCodeLabel.text = resort.resortCode
        resortCodeLabel.textColor = UIColor.orange
        resortCodeLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14)
        resortNameGradientView.addSubview(resortCodeLabel)
        
        if(resort.tier != nil){
            let tearImageView = UIImageView(frame: CGRect(x: 55, y: 42, width: 16, height: 16))
            let tierImageName = Helper.getTierImageName(tier: resort.tier!)
            tearImageView.image = UIImage(named: tierImageName)
            resortNameGradientView.addSubview(tearImageView)
        }
        
        return cell
        
    }
}

//***** Table view delegate methods to handle table view *****//
extension GoogleMapViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 1) {
            
            switch indexPath.section {
            case 0:
                return 56
            default:
                return 66
            }
            
        }
        else {
            
            return 252
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(self.sourceController != Constant.MyClassConstants.createAlert && self.sourceController != Constant.MyClassConstants.editAlert && self.sourceController != Constant.MyClassConstants.vacationSearch) {
            
            if(tableView.tag == 1) {
                if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortDirectoryTitle){
                    self.hidePopUpView()
                }
                if(indexPath.section == 1) {
                    
                    let selectedResort = Constant.MyClassConstants.resorts![indexPath.row]
                    Constant.MyClassConstants.isgetResortFromGoogleSearch = true
                    Helper.getResortWithResortCode(code: selectedResort.resortCode!, viewcontroller: self)
                    self.googleMapSearchBar.text = ""
                    
                }
                else {
                    
                    Constant.MyClassConstants.isgetResortFromGoogleSearch = true
                    Helper.addServiceCallBackgroundView(view: self.view)
                    SVProgressHUD.show()
                    DirectoryClient.getResortsWithinGeoArea(Constant.MyClassConstants.systemAccessToken, geoArea: Constant.MyClassConstants.destinations![indexPath.row].geoArea, onSuccess: { (response) in
                        if(response.count > 0){
                            Constant.MyClassConstants.resortsArray.removeAll()
                            Constant.MyClassConstants.resortsArray = response
                            Constant.MyClassConstants.googleMarkerArray.removeAll()
                            let resort = Constant.MyClassConstants.resortsArray[0]
                            let location = CLLocation.init(latitude: (resort.coordinates?.latitude)!, longitude: (resort.coordinates?.longitude)!)
                            
                            self.displaySearchedResort(location: location)
                        }
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                    })
                    { (error) in
                        SVProgressHUD.dismiss()
                        Helper.removeServiceCallBackgroundView(view: self.view)
                    }
                }
            }
            else {
                
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[indexPath.row]
                Constant.MyClassConstants.isgetResortFromGoogleSearch = false
                Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsDescriptionArray.resortCode!,viewcontroller:self)
                
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                self.handleSwipes(sender: rightSwipe)
            }
        }
    }
    
}
//***** Table view datasource methods to handle table view *****//
extension GoogleMapViewController:UITableViewDataSource {
    @available(iOS 2.0, *)
    
    //***** UITableview dataSource methods definition here *****//
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView.tag == 1) {
            
            return 2
        }
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView.tag == 1) {
            
            if (section == 0) {
                if(Constant.MyClassConstants.destinations?.count == nil){
                    return 0
                }else{
                    return (Constant.MyClassConstants.destinations?.count)!
                }
            }else{
                if(Constant.MyClassConstants.resorts?.count == nil){
                    return 0
                }else{
                    return (Constant.MyClassConstants.resorts?.count)!
                }
            }
            
        }
        else {
            
            return Constant.MyClassConstants.resortsArray.count
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constant.MyClassConstants.sectionHeaderArray[section]
    }
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView.tag == 1) {
            
            if (section == 0 && (Constant.MyClassConstants.destinations?.count)!>0){
                return 30
            }
            else if (section == 1 && (Constant.MyClassConstants.resorts?.count)!>0){
                
                return 30
            }
            else{
                
                return 0
            }
        }
        else {
            
            return 0
        }
    }
    //***** Implementing header and footer cell for all sections  *****//
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        sectionHeaderView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView.tag == 1) {
            
            if (indexPath.section == 0) {
                
                let cell:ResortDestinationCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.destinationCell, for: indexPath as IndexPath) as! ResortDestinationCell
                if(self.sourceController != Constant.MyClassConstants.createAlert && self.sourceController != Constant.MyClassConstants.editAlert && self.sourceController != Constant.MyClassConstants.vacationSearch) {
                    
                    cell.addDestinationButton.isHidden = true
                    cell.destinationMapIcon.isHidden = true
                }
                else {
                    
                    let dicValue = Constant.MyClassConstants.destinations![indexPath.row]
                    if (Constant.MyClassConstants.realmStoredDestIdOrCodeArray.contains(dicValue.destinationId!)) {
                        cell.addDestinationButton.isEnabled = false
                    }
                    else {
                        cell.addDestinationButton.isEnabled = true
                    }
                    
                    cell.destinationMapIcon.isHidden = false
                }
                cell.addDestinationButton.tag = indexPath.row
                cell.destinationMapIcon.tag = indexPath.row
                cell.addDestinationButton.addTarget(self, action: #selector(destinationSelectedAtIndex(sender:)), for: .touchUpInside)
                cell.destinationMapIcon.addTarget(self, action: #selector(resortShowMapPressedAtIndex(sender:)), for: .touchUpInside)
                cell.tag = indexPath.section
                let dicValue = Constant.MyClassConstants.destinations![indexPath.row]
                cell.resortLocationName.text = dicValue.destinationName
                guard ((dicValue.address?.territoryCode?.characters.count)! > 0)
                    else{
                        return cell
                }
                cell.resortCodeLabel.text =  dicValue.address?.territoryCode!
                
                return cell
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortCell, for: indexPath as IndexPath) as! ResortsTableViewCell
                
                if(self.sourceController != Constant.MyClassConstants.createAlert && self.sourceController != Constant.MyClassConstants.editAlert && self.sourceController != Constant.MyClassConstants.vacationSearch) {
                    
                    cell.addResortButton.isHidden = true
                    cell.showMapButton.isHidden = true
                }
                else {
                    let dicValue = Constant.MyClassConstants.resorts![indexPath.row]
                    if (Constant.MyClassConstants.realmStoredDestIdOrCodeArray.contains(dicValue.resortCode!)) {
                        cell.addResortButton.isEnabled = false
                    }
                    else {
                        cell.addResortButton.isEnabled = true
                    }
                    
                    cell.showMapButton.isHidden = false
                }
                
                cell.tag = indexPath.section
                cell.showMapButton.tag = indexPath.row
                cell.addResortButton.tag = indexPath.row
                cell.showMapButton.addTarget(self, action: #selector(resortShowMapPressedAtIndex(sender:)), for: .touchUpInside)
                cell.addResortButton.addTarget(self, action: #selector(destinationSelectedAtIndex(sender:)), for: .touchUpInside)
                let dicValue = Constant.MyClassConstants.resorts![indexPath.row]
                cell.resortLocationName.text = dicValue.resortName
                
                cell.resortCityName.text = dicValue.address?.cityName
                cell.resortCode.text = String(utf8String: dicValue.resortCode!)!
                return cell
            }
            
        }
        else {
            
            let resortDetails = Constant.MyClassConstants.resortsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath as IndexPath) as! SearchResultContentTableCell
            
            for layer in cell.resortNameGradientView.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            var frame = CGRect(x:0, y:0, width:Constant.MyClassConstants.runningDeviceWidth!, height:cell.resortNameGradientView.frame.size.height)
            if(Constant.RunningDevice.deviceIdiom == .pad){
                frame = CGRect(x:0, y:0, width:Constant.MyClassConstants.runningDeviceWidth! * 0.4 + 100, height:cell.resortNameGradientView.frame.size.height)
            }
            cell.resortNameGradientView.frame = frame
            Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            cell.favoriteButton.tag = indexPath.row
            
            
            if(self.sourceController == Constant.MyClassConstants.createAlert || self.sourceController == Constant.MyClassConstants.editAlert || self.sourceController == Constant.MyClassConstants.vacationSearch) {
                
                cell.favoriteButton.setImage(UIImage(named: Constant.assetImageNames.optOffImage), for: UIControlState.normal)
                cell.favoriteButton.setImage(UIImage(named: Constant.assetImageNames.optOnImage), for: UIControlState.selected)
                cell.favoriteButton.addTarget(self, action: #selector(addResortPressedAtIndex(sender:)), for: .touchUpInside)
                
                if(Constant.MyClassConstants.addResortSelectedIndex.contains(indexPath.row)){
                    cell.favoriteButton.isSelected = false
                    cell.favoriteButton.isSelected = true
                }else{
                    cell.favoriteButton.isSelected = false
                }
                
                //cell.favoriteButton.selected = false
            }
            else {
                
                let status = Helper.isResrotFavorite(resortCode: resortDetails.resortCode!)
                if(status) {
                    cell.favoriteButton.isSelected = false
                    cell.favoriteButton.isSelected = true
                }
                else {
                    cell.favoriteButton.isSelected = false
                }
            }
            cell.favoriteButton.tag = indexPath.row
            
            if (resortDetails.images.count>0){
                let url = NSURL(string: Constant.MyClassConstants.resortsArray[indexPath.row].images[Constant.MyClassConstants.resortsArray[indexPath.row].images.count - 1].url!)
                
                
                cell.resortImageView.setImageWith(url as URL!, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            }else{
            }
            cell.resortName.text = resortDetails.resortName
            let resortAddress = resortDetails.address!
            cell.resortCountry.text = resortAddress.cityName //resortAddress.country?.countryName
            cell.resortCode.text = resortDetails.resortCode
            cell.delegate = self
            
            guard ((resortDetails.tier) != nil)
                else{
                    return cell
            }
            let tierImageName = Helper.getTierImageName(tier: resortDetails.tier!)
            cell.tierImageView.image = UIImage(named:tierImageName)
            
            return cell
        }
    }
    
    
}

//***** Search bar delegate methods to handle the search bar actions *****//
extension GoogleMapViewController:UISearchBarDelegate {
    
    //**** Search bar controller delegate ****//
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        self.zoomIn = true
        self.googleMapSearchBar.showsCancelButton = true
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            self.hideMapSideView(flag: true)
        }
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.googleMapSearchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.googleMapSearchBar.resignFirstResponder()
        self.googleMapSearchBar.showsCancelButton = false
        self.hidePopUpView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
            self.hideMapSideView(flag: true)
        }
        if(searchBar.text!.characters.count >= 3) {
            
            DirectoryClient.searchDestinations(Constant.MyClassConstants.systemAccessToken, request: SearchDestinationsRequest.init(query: searchBar.text), onSuccess: { (response) in
                Constant.MyClassConstants.resorts = response.resorts
                Constant.MyClassConstants.destinations = response.destinations
                self.showPopUpView()
                self.searchDisplayTableView.reloadData()
                
            }) { (error) in
                
                logger.warning(error.description)
                SimpleAlert.alert(self, title:Constant.AlertErrorMessages.tryAgainError, message: "\(error.localizedDescription)")
                
            }
        }
    }
    
}

//***** Custom delegate methods with Extension for favorite unfavorite functionality *****//

extension GoogleMapViewController:SearchResultContentTableCellDelegate{
    func favoriteButtonClicked(_ sender: UIButton){
        if((UserContext.sharedInstance.accessToken) != nil) {
            if (sender.isSelected == false){
                
                print(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
                UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                    
                    print(response)
                    sender.isSelected = true
                    
                    
                }, onError: {(error) in
                    
                    print(error)
                })
            }
            else {
                sender.isSelected = false
            }
            
        }else{
            Constant.MyClassConstants.btnTag = sender.tag
            self.performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: self)
        }
        
    }
    func unfavoriteButtonClicked(_ sender: UIButton){
        
    }
}

