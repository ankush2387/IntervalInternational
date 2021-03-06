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
    var marker: GMSMarker! = nil
    var bounds = GMSCoordinateBounds()
    var location = CLLocationCoordinate2D()
    var resortView = UIView()
    var resortCollectionView: UICollectionView!
    var currentIndex: Int = 0
    var selectedFavButton: UIButton!
    var hideSideView = false
    let bottomResortHeight: CGFloat = 206 + 49//added default tab bar height
    var sourceController = ""
    var selectedResortsArray: NSMutableArray = []
    var zoomIn = false
    var listTableView: UITableView!
    var drawButtonView: UIView!
    var applyButton: UIBarButtonItem!
    var locationManager = CLLocationManager()
    var needCameraChange = false
    var selectedDestination = AreaOfInfluenceDestination()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //used to not remove observers if going to map or weather view
        Constant.MyClassConstants.goingToMapOrWeatherView = false

        navigationController?.navigationBar.isHidden = false
        // Adding notifications so that it invoke the specific method when the notification is fired
        NotificationCenter.default.addObserver(self, selector: #selector(closeButtonClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addRemoveFavorite), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resortSelectedFromsearchResultWithlatlong), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displaySearchedResort), name: NSNotification.Name(rawValue: Constant.notificationNames.addMarkerWithRactangleRequestNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapMarkers), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapForApply), object: nil)
        
        if Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck {
            navigationItem.title = Constant.ControllerTitles.vacationSearchDestinationController
            googleMapSearchBar.placeholder = Constant.buttonTitles.searchVacationVs
        } else {
            navigationItem.title = Constant.MyClassConstants.resortDirectoryTitle
            googleMapSearchBar.placeholder = Constant.buttonTitles.searchVacationRd
        }

        //***** Condition for maintaining the back button and hamberger menu according to logged in or pre login *****//
        if Constant.MyClassConstants.isLoginSuccessfull && Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortFunctionalityCheck {
            if let rvc = revealViewController() {
                rvc.delegate = self
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                view.addGestureRecognizer( rvc.panGestureRecognizer())
            }

        } else {

            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(menuBackButtonPressed(_:)))

            menuButton.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = menuButton
        }
        
        if resortCollectionView != nil {
            resortCollectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
        googleMapSearchBar.layoutIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if Constant.MyClassConstants.goingToMapOrWeatherView == false {
            //**** Remove added observers ****//
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)

            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)

            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapNotification), object: nil)

            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.addMarkerWithRactangleRequestNotification), object: nil)

            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapForApply), object: nil)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        if searchDisplayTableView.frame.origin.y == UIScreen.main.bounds.height {
            searchDisplayTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 152)
        } else {

            searchDisplayTableView.frame = CGRect(x: 0, y: 120, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 152)
        }

        if Constant.MyClassConstants.addResortSelectedIndex.count == 0 && navigationItem.rightBarButtonItem != nil {
            navigationItem.rightBarButtonItem!.isEnabled = false

        } else {
            if navigationItem.rightBarButtonItem != nil {
                navigationItem.rightBarButtonItem!.isEnabled = true
            }
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //getScreenFrameForOrientation()
    }
    
    func updateMapMarkers() {
        
        if !Constant.MyClassConstants.googleMarkerArray.isEmpty && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck {
            for selectedMarker in Constant.MyClassConstants.googleMarkerArray  where selectedMarker.userData as! Int == Constant.MyClassConstants.collectionVwCurrentIndex {
                    if selectedMarker.isFlat == true {
                        
                        selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                        selectedMarker.isFlat = false
                        
                    } else {
                        
                        selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                        mapView.selectedMarker = selectedMarker
                        selectedMarker.isFlat = true
                        
                    }
            }
        }
        if resortCollectionView != nil {
            resortCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       //hide map current location button
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = false
    
        // condition check to send resort directory
        if Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortFunctionalityCheck {

            // omniture tracking with event 40
            Helper.trackOmnitureCallForPageView(name: Constant.omnitureCommonString.resortDirectoryHome)

        }
        //Location Manager code to fetch current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        searchDisplayTableView.isHidden = true

        // Register custom cell with map tale view with some validation check
        if mapTableView != nil {
            mapTableView.isHidden = true
            if mapTableView.tag != 1 {

                mapTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.searchResultContentTableCell)
            }
        }

        //***** Creating and adding right bar button for Apply selected resort button *****//
        if Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck {
            applyButton = UIBarButtonItem(title: Constant.AlertPromtMessages.applyButtonTitle, style: .plain, target: self, action: #selector(applyButtonPressed(_:)))
            applyButton.isEnabled = false
            applyButton.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = applyButton
        }

        if mapSideView != nil && containerView != nil {
            containerView.tag = 100
            containerView.isHidden = true
            view.bringSubview(toFront: mapSideView)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(loginNotification), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        googleMapSearchBar.delegate = self
    }
    // MARK: -***** Method called when search result map button pressed *****//
    
    func resortShowMapPressedAtIndex(sender: UIButton) {
        
        Constant.MyClassConstants.destinationOrResortSelectedBy = Constant.omnitureCommonString.mapSelection
        hidePopUpView()
        
        let senderButton = sender
        
        if senderButton.superview!.superview!.tag == 1 {
            let selectedResort = Constant.MyClassConstants.resorts![sender.tag]
            googleMapSearchBar.resignFirstResponder()
            googleMapSearchBar.showsCancelButton = false
            Helper.getResortWithResortCode(code: selectedResort.resortCode!, viewcontroller: self)
            googleMapSearchBar.text = nil
        } else {
            googleMapSearchBar.resignFirstResponder()
            googleMapSearchBar.showsCancelButton = false
            showHudAsync()
            DirectoryClient.getResortsWithinGeoArea(Session.sharedSession.userAccessToken, geoArea: Constant.MyClassConstants.destinations![sender.tag].geoArea, onSuccess: { response in
                self.needCameraChange = true
                Constant.MyClassConstants.resortsArray.removeAll()
                Constant.MyClassConstants.resortsArray = response
                Constant.MyClassConstants.googleMarkerArray.removeAll()
                Constant.MyClassConstants.addResortSelectedIndex.removeAll()
                var i = 0
                for _ in response {
                    Constant.MyClassConstants.addResortSelectedIndex.append(i)
                    i = i + 1
                }
                if !Constant.MyClassConstants.resortsArray.isEmpty {
                   self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                Constant.MyClassConstants.googleMarkerArray.removeAll()
                if !Constant.MyClassConstants.resortsArray.isEmpty {
                    
                    self.mapView.clear()
                    self.displaySearchedResort()
                    if self.mapTableView != nil {
                        self.mapTableView.reloadData()
                    }
                } else {
                    
                    if let destination = Constant.MyClassConstants.destinations?[sender.tag] {
                        self.selectedDestination = destination
                    }
                    self.mapView.clear()
                    self.showDestinationWithoutResorts()
                }
                
                self.hideHudAsync()
            }) {[unowned self] error in
                self.hideHudAsync()
                self.presentAlert(with: "Error".localized(), message: error.localizedDescription)
            }
        }
    }
    //***** Method called when destination or resort selected from  *****//
    func destinationSelectedAtIndex(sender: UIButton) {
        
        Constant.MyClassConstants.destinationOrResortSelectedBy = Constant.omnitureCommonString.typedSelection
        if sourceController != "" && sourceController == Constant.MyClassConstants.createAlert || sourceController == Constant.MyClassConstants.editAlert {
            let senderButton = sender
            
            if senderButton.superview!.superview!.tag == 0 {
                
                let dict = Constant.MyClassConstants.destinations?[sender.tag]
                if let dictValue = dict {
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.destination(dictValue))
                    Constant.MyClassConstants.alertSelectedDestination.append(dictValue)
                    Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dictValue.destinationId ?? "")
                }
            } else {
                
                let dict = Constant.MyClassConstants.resorts?[sender.tag]
                if let dictValue = dict {
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.resort(dictValue))
                    Constant.MyClassConstants.alertSelectedResorts.append(dictValue)
                    Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dictValue.resortCode ?? "")
                }
            }
            sender.isSelected = true
            _ = navigationController?.popViewController(animated: true)
            
        } else {
            
            let senderButton = sender
            if senderButton.superview!.superview!.tag == 0 {
                
                if  !Constant.MyClassConstants.destinations!.isEmpty {
                    let dict = Constant.MyClassConstants.destinations?[sender.tag]
                    if let dictValue = dict {
                        var areaOfInfluenceArray = [AreaOfInfluenceDestination]()
                        areaOfInfluenceArray.append(dictValue)
                        //Realm local storage for selected destination
                        let storedata = RealmLocalStorage()
                        let Membership = Session.sharedSession.selectedMembership
                        let desList = DestinationList()
                        desList.aoid = dictValue.aoiId ?? ""
                        desList.countryCode = dictValue.address?.countryCode ?? ""
                        desList.destinationId = dictValue.destinationId
                        desList.destinationName = dictValue.destinationName
                        
                        if let teriCode = dictValue.address?.territoryCode {
                            desList.territorrycode = teriCode
                        } else {
                            desList.territorrycode = ""
                        }
                        storedata.destinations.append(desList)
                        storedata.contactID = Session.sharedSession.contactID
                        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dictValue.destinationId)
                        
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(storedata)
                        }
                        
                        let allDest = Helper.getLocalStorageAllDest()
                        if allDest.count > 0 {
                            Constant.MyClassConstants.whereTogoContentArray.removeObject(at: 0)
                            Helper.deleteObjectFromAllDest()
                        }
                    }
                } else {
                    let allDest = Helper.getLocalStorageAllDest()
                    if allDest.count > 0 {
                        Helper.deleteObjectFromAllDest()
                    }
                }
            } else {
                
                let dict = Constant.MyClassConstants.resorts![sender.tag]
                let address = dict.address
                
                //Realm local storage for selected resort
                let storedata = RealmLocalStorage()
                let Membership = Session.sharedSession.selectedMembership
                let resortList = ResortList()
                resortList.resortCityName = address?.cityName ?? ""
                resortList.resortCode = dict.resortCode ?? ""
                resortList.thumbnailurl = dict.images[0].url ?? ""
                resortList.resortName = "\(dict.resortName ?? "") - \(dict.resortCode ?? "")"
                
                resortList.territorrycode = address?.territoryCode ?? ""
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(dict.resortCode ?? "")
                storedata.resorts.append(resortList)
                storedata.contactID = Session.sharedSession.contactID
                let realm = try! Realm()
                try! realm.write {
                    realm.add(storedata)
                }
                let allDest = Helper.getLocalStorageAllDest()
                if allDest.count > 0 {
                    Helper.deleteObjectFromAllDest()
                }
            }
            sender.isSelected = true
                _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    func apiCallWithRectangleRequest(request: GeoArea) {
        DirectoryClient.getResortsWithinGeoArea(Constant.MyClassConstants.systemAccessToken, geoArea: request, onSuccess: { response in
            
            if !response.isEmpty {
                Constant.MyClassConstants.googleMarkerArray.removeAll()
                Constant.MyClassConstants.resortsArray.removeAll()
                Constant.MyClassConstants.resortsArray = response
                self.mapView.clear()
                self.displaySearchedResort()
            } else {
                Constant.MyClassConstants.googleMarkerArray.removeAll()
                Constant.MyClassConstants.resortsArray.removeAll()
                Constant.MyClassConstants.resortsArray = response
                self.mapView.clear()
                self.showDestinationWithoutResorts()
            }
            if Constant.RunningDevice.deviceIdiom == .pad && !self.hideSideView && self.containerView != nil && self.containerView.isHidden == true {
                Constant.MyClassConstants.addResortSelectedIndex.removeAll()
                self.alertView.isHidden = true
                self.mapTableView.isHidden = false
                self.mapTableView.reloadData()
            }
            self.hideHudAsync()
        }) { [weak self] _ in
            self?.hideHudAsync()
        }
    }
    
    func showDestinationWithoutResorts() {
        if needCameraChange {
            needCameraChange = false
            if let latitude = selectedDestination.geoArea?.southEastCoordinate?.latitude, let longitude = selectedDestination.geoArea?.northWestCoordinate?.longitude {
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10)
                mapView.animate(to: camera)
            }
        }
        
        if !Constant.MyClassConstants.isRunningOnIphone && self.mapTableView != nil {
            mapTableView.isHidden = false
            alertView.isHidden = true
            mapTableView.reloadData()
        }
    }
    
    //***** Updating map with resorts getting from map search bar from resorsts or destination *****//
    func displaySearchedResort() {
        
        if needCameraChange {
            needCameraChange = false
            let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.latitude)!, longitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.longitude)!, zoom: 10)
           
            mapView.camera = camera
        }
        
        var  position: CLLocationCoordinate2D!
        var tag = 0
        
        for resort in Constant.MyClassConstants.resortsArray {
            
            position = CLLocationCoordinate2DMake((resort.coordinates?.latitude)!, resort.coordinates!.longitude)
            marker = GMSMarker()
            marker.position = position
            marker.userData = tag
            tag = tag + 1
            marker.isFlat = false
            marker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
            marker.appearAnimation = GMSMarkerAnimation.pop
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = mapView
            Constant.MyClassConstants.googleMarkerArray.append(marker)
            
        }
        
        if !Constant.MyClassConstants.isRunningOnIphone && mapTableView != nil {
                mapTableView.isHidden = false
                alertView.isHidden = true
                mapTableView.reloadData()
        }
        
    }
    
    //***** This method executes when bottom resort view favorite button pressed *****//
    func bottomResortFavoritesButtonPressed(sender: UIButton) {
            guard let resortCode = Constant.MyClassConstants.resortsArray[sender.tag].resortCode else { return }
            if Session.sharedSession.userAccessToken != nil {
                
                if !sender.isSelected {
                    showHudAsync()
                    UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode:resortCode, onSuccess: { response in
                        self.hideHudAsync()
                        sender.isSelected = true
                        Constant.MyClassConstants.favoritesResortCodeArray.append(resortCode)
                        if case .some = self.mapTableView {
                            self.mapTableView.reloadData()
                        } else if case .some = self.resortCollectionView {
                            self.resortCollectionView.reloadData()
                        }
                    }, onError: { [weak self] error in
                        self?.hideHudAsync()
                        self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    })
                } else {
                    
                    showHudAsync()
                    UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { _ in
                        sender.isSelected = false
                        self.hideHudAsync()
                        Constant.MyClassConstants.favoritesResortCodeArray = Constant.MyClassConstants.favoritesResortCodeArray.filter { $0 != resortCode }
                        if case .some = self.mapTableView {
                            self.mapTableView.reloadData()
                        } else if case .some = self.resortCollectionView {
                            self.resortCollectionView.reloadData()
                        }
                        
                    }, onError: { [weak self] error in
                        self?.hideHudAsync()
                        self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    })
                    
                }
            } else {
                Constant.MyClassConstants.btnTag = sender.tag
                performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: nil)
            }
    }
    //***** Function to hold selected object and release on deselecton *****//
    func addResortPressedAtIndex(sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            if let index = Constant.MyClassConstants.addResortSelectedIndex.index(of: sender.tag) {
               Constant.MyClassConstants.addResortSelectedIndex.remove(at: index)
            }
            
        } else {
            sender.isSelected = true
            Constant.MyClassConstants.addResortSelectedIndex.append(sender.tag)
        }
        
        for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
            
            if selectedMarker.userData as! Int == sender.tag {
                
                if selectedMarker.isFlat == true {
                    
                    selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                    selectedMarker.isFlat = false
                    
                } else {
                    
                    selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                    mapView.selectedMarker = selectedMarker
                    selectedMarker.isFlat = true
                    
                }
            } else {
                
            }
        }
        
        if Constant.MyClassConstants.addResortSelectedIndex.count == 0 {
            navigationItem.rightBarButtonItem!.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem!.isEnabled = true
        }
        if Constant.RunningDevice.deviceIdiom == .phone && resortCollectionView != nil {
            resortCollectionView.reloadData()
        }
        if mapTableView != nil {
            mapTableView.reloadData()
        }
        if listTableView != nil {
            listTableView.reloadData()
        }
    }
    
    func checkNil(sender: AnyObject) {
    }
    
    //***** This methods called when the added notification fired from notification center *****//
    func loginNotification() {
        if selectedFavButton != nil {
            selectedFavButton.isSelected = true
        }
    }
    
    // MARK: - Fuction to add remove favorite after Pre-Login
    func addRemoveFavorite() {
        if Constant.MyClassConstants.btnTag != -1 {
        guard let resortCode = Constant.MyClassConstants.resortsArray[Constant.MyClassConstants.btnTag].resortCode else { return }
        let isFavorite = Helper.isResrotFavorite(resortCode: resortCode)
        let favoriteTempButton = UIButton()
        favoriteTempButton.tag = Constant.MyClassConstants.btnTag
        favoriteTempButton.isSelected = isFavorite
        Constant.MyClassConstants.btnTag = -1
        bottomResortFavoritesButtonPressed(sender: favoriteTempButton)
        }
    }
    
    //***** This function called when navigation back button pressed *****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        if let navController = navigationController {
            if navController.viewControllers.count > 1 {
                navController.popViewController(animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
            }
        }
        
    }
    //***** This function called when navigation back button pressed *****//
    func applyButtonPressed(_ sender: UIBarButtonItem) {
        
        if sourceController == Constant.MyClassConstants.vacationSearch {
            
            let storedata = RealmLocalStorage()
            let resortList = ResortList()
            
            for object in  Constant.MyClassConstants.resortsArray {
                
                let resortbyMap = ResortByMap()
                resortbyMap.resortCode = object.resortCode.unwrappedString
                resortbyMap.resortName = object.resortName.unwrappedString
                if let territoryCode = object.address?.territoryCode {
                    resortbyMap.territorrycode = territoryCode
                }
                resortList.resortArray.append(resortbyMap)
            }
            if Constant.MyClassConstants.resortsArray.count > 0 {
                Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(Constant.MyClassConstants.resortsArray[0].resortCode as Any)
                storedata.contactID = Session.sharedSession.contactID
            }
            
            storedata.resorts.append(resortList)
            let realm = try! Realm()
            try! realm.write {
                realm.add(storedata)
            }
            
            if Constant.RunningDevice.deviceIdiom == .phone {
                _ = navigationController?.popViewController(animated: true)
            } else {
                navigationController?.dismiss(animated: true, completion: nil)
            }
            
        } else {
            
            var selectedResortsArray = [Resort]()
            for object in  Constant.MyClassConstants.resortsArray {
      
                selectedResortsArray.append(object)
                
            }
        Constant.MyClassConstants.selectedGetawayAlertDestinationArray.append(Constant.selectedDestType.resorts(selectedResortsArray))
            
            if Constant.RunningDevice.deviceIdiom == .phone {
                _ = navigationController?.popViewController(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    // ***** Method called when we performing the swipe functionality to see multiple resort from bottom view *****//
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if resortCollectionView != nil {
            
            let pageWidth = resortCollectionView.bounds.size.width
            let page = scrollView.contentOffset.x / pageWidth
            currentIndex = Int(page)
        }
    }
    
    // ***** Drag button function implementation *****//
    @IBAction func dragButtonClicked(_ sender: AnyObject?) {
        let currentZoom = mapView.camera.zoom
        if draggingView.frame.origin.x == 0 {
            hideSideView = false
            mapSideView.isHidden = false
            if currentZoom >= 10 {
                view.endEditing(true)
                mapTableView.isHidden = false
                alertView.isHidden = true
            }
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.mapSideView.frame = CGRect(x: 0, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                self.draggingView.frame = CGRect(x: self.mapSideView.frame.size.width, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                
            }, completion: { _ in
                
                self.dragButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
            })
        } else {
            self.view.endEditing(true)
            hideSideView = true
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                self.draggingView.frame = CGRect(x: 0, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
            }, completion: { _ in
                
                self.dragButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
        }
    }
    
    func hideMapSideView(flag: Bool) {
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.hideSideView = true
        }, completion: { _ in
            
            self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
            self.draggingView.frame = CGRect(x: 0, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
            if self.containerView != nil {
                self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            }
            self.dragButton.transform = CGAffineTransform(rotationAngle: .pi)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Method to create bottom resort view in collection view and pop up with custom animation *****//
    func createBottomResortView(marker: GMSMarker) {
        
        if resortCollectionView != nil && !Constant.MyClassConstants.resortsArray.isEmpty {
            resortCollectionView.reloadData()
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.currentIndex, section: 0)
                self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
            }
            resortView.isHidden = false
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.self.bottomResortHeight + 50), width: self.view.frame.width, height: self.self.bottomResortHeight)
                
                self.view.bringSubview(toFront: self.resortView)
            }, completion: { _ in
                
            })
               view.bringSubview(toFront: resortView)
        } else {
            
            if navigationItem.rightBarButtonItem != nil && Constant.MyClassConstants.addResortSelectedIndex.count > 0 {
                navigationItem.rightBarButtonItem!.isEnabled = true
            }
            
            if Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck {
                resortView.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: view.frame.height - (view.frame.height - bottomResortHeight - 50))
            } else {
                let tabBarHeight = tabBarController?.tabBar.bounds.size.height ?? 0
                if tabBarHeight == 83.0 {
                    resortView.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: view.frame.height - (view.frame.height - bottomResortHeight + 32))
                } else {
                    resortView.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: view.frame.height - (view.frame.height - bottomResortHeight))
                }
            }
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: self.resortView.frame.width, height: resortView.frame.height)
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            resortCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: resortView.bounds.width, height: self.resortView.bounds.height), collectionViewLayout: layout)
            
            resortCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            resortCollectionView.backgroundColor = UIColor.clear
            resortCollectionView.delegate = self
            resortCollectionView.dataSource = self
            resortCollectionView.isPagingEnabled = true
            resortView.addSubview(resortCollectionView)
            
            /*** Subtracting tab bar default height - 49 ****/
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
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
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.currentIndex, section: 0)
                self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
            }
        }
    }
    
    // ***** This method executes when we want to hide bottom resort view *****//
    func removeBottomView() {
        
        currentIndex = 0
        if navigationItem.rightBarButtonItem != nil {
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.resortView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.bottomResortHeight)
            DispatchQueue.main.async {
                for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
                    
                    selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                    selectedMarker.isFlat = false
                    
                }
                self.mapView.selectedMarker = nil
            }
            
        }, completion: { _ in
            
        })
        
    }
    
    // ***** Method to handle swipe gesture from bottom resort view *****//
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .up {
            
            if Constant.MyClassConstants.systemAccessToken != nil {
                let selectedResort = Constant.MyClassConstants.resortsArray[self.currentIndex]
                
                //***** Favorites resort API call after successfull call *****//
                Helper.getUserFavorites {[unowned self] error in
                    if case .some = error {
                        self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                    }
                }
                if let resortCode = selectedResort.resortCode {
                    Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
                }
            }
        }
        
        if sender.direction == .down {
            removeBottomView()
        } else if sender.direction == .left && Constant.RunningDevice.deviceIdiom == .pad {
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                self.draggingView.frame = CGRect(x: 0, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                
            }, completion: { _ in
                self.dragButton.transform = CGAffineTransform(rotationAngle: .pi)
            })
            
        } else if sender.direction == .right {
            mapSideView.isHidden = false
            draggingView.isHidden = false
            if containerView != nil {
                containerView.isHidden = false
                view.bringSubview(toFront: containerView)
                UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.containerView.frame = CGRect(x: 0, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.self.containerView.frame.size.height)
                }, completion: { _ in
                })
            }
        }
        
    }
    //***** Method called to close the detailed screen from ipad screen *****//
    func closeButtonClicked() {
        if Constant.RunningDevice.deviceIdiom == .pad {
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
            }, completion: { _ in
                self.containerView.isHidden = true
                DispatchQueue.main.async {
                    for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
                        
                        selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                        selectedMarker.isFlat = false
                        
                    }
                    self.mapView.selectedMarker = nil
                }
            })
        } else {
            updateMapMarkers()
        }
    }
    
    //***** Function to change zoom *****//
    func zoomChanged() {
        
        if Constant.RunningDevice.deviceIdiom == .pad {
            
            if zoomIn == true {
                
                if navigationItem.rightBarButtonItem != nil {
                    
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
                
                UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    
                    self.mapSideView.frame = CGRect(x: 0, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                    self.draggingView.frame = CGRect(x: self.mapSideView.frame.size.width, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                    
                }, completion: { _ in
                    
                    self.mapTableView.isHidden = false
                    self.mapSideView.isHidden = false
                    self.draggingView.isHidden = false
                    if self.containerView != nil {
                        self.containerView.isHidden = true
                    }
                    self.alertView.isHidden = true
                })
            } else {
                
                if navigationItem.rightBarButtonItem != nil && Constant.MyClassConstants.addResortSelectedIndex.isEmpty {
                    if navigationItem.rightBarButtonItem != nil {
                        navigationItem.rightBarButtonItem!.isEnabled = false
                    }
                } else {
                    if navigationItem.rightBarButtonItem != nil {
                        navigationItem.rightBarButtonItem!.isEnabled = true
                    }
                }
                mapSideView.isHidden = false
                draggingView.isHidden = false
                if containerView != nil {
                    containerView.isHidden = true
                }
                UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    
                    if self.mapView.camera.zoom >= 10 {
                        self.mapTableView.isHidden = false
                    } else {
                        self.alertView.isHidden = false
                    }
                }, completion: { _ in
                    
                })
            }
        }
    }
    
    //***** Function to select all destinations *****//
    func selectAllDestinations() {
        if Constant.MyClassConstants.whereTogoContentArray.count > 0 {
            
            presentAlert(with: "Search All Available Destinations".localized(),
                         message: "Selecting this option will remove all other currently selected destinations/resorts . Are you sure you want to do this?".localized(),
                         hideCancelButton: false,
                         acceptButtonTitle: "OK".localized(),
                         acceptHandler: searchYesClicked)
        } else {
            
            Helper.deleteObjectFromAllDest()
            let allavailabledest = AllAvailableDestination()
            allavailabledest.destination = Constant.MyClassConstants.allDestinations
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(allavailabledest)
            }
            
            if Constant.RunningDevice.deviceIdiom == .pad {
                navigationController?.dismiss(animated: true, completion: nil)
            } else {
                _ = navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    //***** Function for alert controller yes button click *****//
   func searchYesClicked() {
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        let allAvailableDest = AllAvailableDestination()
        allAvailableDest.destination = Constant.MyClassConstants.allDestinations
        try! realm.write {
            realm.add(allAvailableDest)
        }
        Constant.MyClassConstants.destinationOrResortSelectedBy = Constant.omnitureCommonString.allDestination
        Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
        Constant.MyClassConstants.whereTogoContentArray.add(Constant.MyClassConstants.allDestinations)
        if Constant.RunningDevice.deviceIdiom == .pad {
            navigationController?.dismiss(animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    //***** Method to show pop up with searched resort or destination on table view with custom animation *****//
    func showPopUpView() {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GoogleMapViewController.handleSwipes(sender:)))
        leftSwipe.direction = .left
        handleSwipes(sender: leftSwipe)
        
        if Constant.RunningDevice.deviceIdiom == .phone {
            removeBottomView()
        }
        if Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.createAlert && Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.editAlert {
            //**** Create table view header ****//
            var  headerView = UIView(frame: CGRect(x: 0, y: 0, width: searchDisplayTableView.bounds.width, height: 40))
            let nameLabel = UILabel(frame: CGRect(x: 15, y: 5, width: searchDisplayTableView.bounds.width - 130, height: 30))
            
            nameLabel.text = "All Available Destinations".localized()
            nameLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
            headerView.addSubview(nameLabel)
            
            let selectButton = UIButton(type: UIButtonType.system) as UIButton
            let bounds = CGRect(x: view.bounds.width - 68, y: 0, width: 60, height: 40)
            selectButton.frame = bounds
            selectButton.setImage(UIImage(named: Constant.assetImageNames.plusIcon), for: .normal)
            selectButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            selectButton.layer.cornerRadius = 5
            selectButton.addTarget(self, action: #selector(selectAllDestinations), for: .touchUpInside)
            headerView.addSubview(selectButton)
            if Constant.MyClassConstants.whereTogoContentArray.contains(Constant.MyClassConstants.allDestinations) {
                selectButton.isEnabled = false
                headerView = UIView(frame: CGRect(x: 0, y: 0, width: searchDisplayTableView.bounds.width, height: 0))
            } else {
                selectButton.isEnabled = true
            }
               searchDisplayTableView.tableHeaderView = headerView
        }
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
        
            self.searchDisplayTableView.frame = CGRect(x: 0, y: self.mapView.frame.minY, width: self.view.frame.width, height: self.mapView.frame.height)
            if Constant.RunningDevice.deviceIdiom == .pad && self.containerView != nil {
                if self.containerView.frame.origin.x == 0 {
                    self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: self.containerView.frame.origin.y, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                }
            }
            
        }, completion: { _ in
            self.searchDisplayTableView.isHidden = false
        })
        
    }
    
    //***** Method to hide pop up with searched resort or destination on table view with custom animation *****//
    func hidePopUpView() {
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.searchDisplayTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 152)
            
        }, completion: { _ in
            self.searchDisplayTableView.isHidden = true
        })
    }
    
    //***** Show screen in landscape/potrait mode. *****//
    func getScreenFrameForOrientation() {
        if Constant.RunningDevice.deviceIdiom == .pad {
            if containerView != nil {
                if containerView.isHidden == false {
                    containerView.isHidden = true
                } else {
                    if mapSideView.frame.origin.x != 0 {
                        mapSideView.isHidden = true
                        //TODO
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                            self.draggingView.frame = CGRect(x: 0, y: self.draggingView.frame.origin.y, width: self.draggingView.frame.size.width, height: self.draggingView.frame.size.height)
                            self.mapSideView.frame = CGRect(x: -self.mapSideView.frame.size.width, y: self.mapSideView.frame.origin.y, width: self.mapSideView.frame.size.width, height: self.mapSideView.frame.size.height)
                        }
                        
                    } else {
                        self.mapSideView.isHidden = false
                    }
                }
                
                let containerVC = childViewControllers[0] as! ResortDetailsViewController
                containerVC.senderViewController = Constant.MyClassConstants.showSearchResultButton
                containerVC.viewWillAppear(true)
            }
        }
    }
    
    //***** Method called when the added notification fired from other classes *****//
    func resortSelectedFromsearchResultWithlatlong() {
        
        Constant.MyClassConstants.addResortSelectedIndex.removeAll()
        
        var i = 0
        for _ in Constant.MyClassConstants.resortsArray {
            Constant.MyClassConstants.addResortSelectedIndex.append(i)
            i = i + 1
        }
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        mapView.clear()
        needCameraChange = true

        displaySearchedResort()
        
        if Constant.RunningDevice.deviceIdiom == .pad {
            mapTableView.reloadData()
        }
    }
    
    func nameLabelPressed(_ sender: UITapGestureRecognizer) {
        
        if Constant.MyClassConstants.systemAccessToken != nil {
            let selectedResort = Constant.MyClassConstants.resortsArray[currentIndex]
            
            //***** Favorites resort API call after successfull call *****//
            Helper.getUserFavorites {[unowned self] error in
                if case .some = error {
                    self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                }
            }
            if let resortCode = selectedResort.resortCode {
               Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
            }
        }
    }
    
}

// **** To Show user current location on map. **** //
extension GoogleMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // According to MOBI-879 changes made for centre map on cuurent location of user.
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
        } else {
            let latitude = 40.68
            let longitude = -97.83
            mapView.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 8.0)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 8.0, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
            
        }
    }
    
}

//***** Map view delegate methods to handle map *****//
extension GoogleMapViewController: GMSMapViewDelegate {
    
    //***** this method called when map will move *****//
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        view.endEditing(true)
    }
    
    //***** This method called when map tap on any place and give the tapped coordinates *****//
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        view.endEditing(true)
    }
    //***** this method called when map marker selected *****//
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        view.endEditing(true)
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if mapView.selectedMarker == nil {
                marker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
                mapView.selectedMarker = marker
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[marker.userData as! Int]
                if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
                    Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
                }
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                handleSwipes(sender: rightSwipe)
                
            } else {
                
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[marker.userData as! Int]
                if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
                    Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
                }
                DispatchQueue.main.async {
                    for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
                        
                        if selectedMarker.userData as! Int == marker.userData as! Int {
                            
                            if marker.isFlat == true {
                                
                                marker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                                marker.isFlat = false
                                
                            } else {
                                
                                marker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                                self.mapView.selectedMarker = marker
                                marker.isFlat = true
                                
                            }
                        } else {
                            
                            selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                            selectedMarker.isFlat = false
                        }
                    }
                }
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                self.handleSwipes(sender: rightSwipe)
            }
        } else {
            
            if mapView.selectedMarker == nil {
                
                marker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
                currentIndex = marker.userData as! Int
                mapView.selectedMarker = marker
                createBottomResortView(marker: marker)
                
            } else if marker.userData as! Int == mapView.selectedMarker?.userData as! Int {
                
                marker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                marker.isFlat = false
                removeBottomView()
                
            } else {
                
                DispatchQueue.main.async {
                    for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
                        
                        if selectedMarker.userData as! Int == marker.userData as! Int {
                            selectedMarker.isFlat = true
                            selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                        } else {
                            
                             selectedMarker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                            selectedMarker.isFlat = false
                        }
                    }
                    mapView.selectedMarker = marker
                    self.currentIndex = marker.userData as! Int
                    
                    let indexPath = IndexPath(row: self.currentIndex, section: 0)
                    if self.currentIndex > marker.userData as! Int {
                        
                        self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
                    } else {
                        
                        self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
                    }
                }
                
            }
        }
        return true
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if mapView.camera.zoom >= 10 {
            
            let bounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())
            
            let southEast = CLLocationCoordinate2D(latitude: bounds.southWest.latitude, longitude: bounds.northEast.longitude)
            let northWest = CLLocationCoordinate2D(latitude: bounds.northEast.latitude, longitude: bounds.southWest.longitude)
            
            let seCordinates = Coordinates()
            seCordinates.latitude = southEast.latitude
            seCordinates.longitude = southEast.longitude
            
            let nwCordinates = Coordinates()
            nwCordinates.latitude = northWest.latitude
            nwCordinates.longitude = northWest.longitude
            
            let geoAreaReq = GeoArea(nwCordinates, seCordinates)
            apiCallWithRectangleRequest(request: geoAreaReq)
            
        } else {
            
            if !Constant.MyClassConstants.isRunningOnIphone {
                
                alertView.isHidden = false
                mapTableView.isHidden = true
            }
            
        }
    }
}

//***** Collection view delegate methods to handle collection view *****//

extension GoogleMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
    }
}

//***** Collection view datasource methods to handle collection view *****//
extension GoogleMapViewController: UICollectionViewDataSource {
    
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
        
        if resort.images.count > 1 {
            var url = URL(string: "")
            let imagesArray = resort.images
            for imgStr in imagesArray where imgStr.size == Constant.MyClassConstants.imageSize {
                    url = URL(string: imgStr.url ?? "")
                    break
            }
            
            resortImageView.setImageWith(url, completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                if error != nil {
                    resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        } else {
            var imageURL = ""
            if resort.images.count > 0 {
                imageURL = resort.images[resort.images.count - 1].url!
            }
            
            resortImageView.setImageWith(URL(string: imageURL), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                if error != nil {
                    resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }
        cell.addSubview(resortImageView)
        
        let resortTierImageView = UIImageView(frame: CGRect(x: cell.contentView.frame.size.width / 2 - 25, y: 0, width: 50, height: 30) )
        resortTierImageView.image = UIImage(named: Constant.assetImageNames.upArrowImage)
        cell.addSubview(resortTierImageView)
        
        let resortFavoritesButton = UIButton(frame: CGRect(x: cell.contentView.frame.width - 60, y: 10, width: 50, height: 50))
        resortFavoritesButton.tag = indexPath.row
        
        if sourceController == Constant.MyClassConstants.createAlert || sourceController == Constant.MyClassConstants.editAlert || sourceController == Constant.MyClassConstants.vacationSearch {
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.optOffImage), for: UIControlState.normal)
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.optOnImage), for: UIControlState.selected)
            if Constant.MyClassConstants.addResortSelectedIndex.contains(indexPath.row) {
                resortFavoritesButton.isSelected = true
            } else {
                resortFavoritesButton.isSelected = false
            }
            
            resortFavoritesButton.addTarget(self, action: #selector(addResortPressedAtIndex(sender:)), for: .touchUpInside)
        } else {
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.favoritesOffImage), for: UIControlState.normal)
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.favoritesOnImage), for: UIControlState.selected)
            resortFavoritesButton.addTarget(self, action: #selector(
                bottomResortFavoritesButtonPressed(sender:)), for: .touchUpInside)
            if let resortCode = resort.resortCode {
                let status = Helper.isResrotFavorite(resortCode: resortCode)
                if status {
                    resortFavoritesButton.isSelected = true
                } else {
                    resortFavoritesButton.isSelected = false
                }
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
        resortNameLabel.isUserInteractionEnabled = true
        let resortNamePressed = UITapGestureRecognizer(target: self, action: #selector(self.nameLabelPressed(_:)))
        resortNameLabel.addGestureRecognizer(resortNamePressed)
        resortNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
        resortNameGradientView.addSubview(resortNameLabel)
        
        let resortCountryLabel = UILabel(frame: CGRect(x: 20, y: 20, width: cell.contentView.frame.width - 20, height: 20))
        resortCountryLabel.text = resort.address?.cityName
        resortCountryLabel.textColor = UIColor.black
        resortCountryLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14)
        resortNameGradientView.addSubview(resortCountryLabel)
        
        let resortCodeLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 50, height: 20))
        resortCodeLabel.text = resort.resortCode
        resortCodeLabel.textColor = UIColor.orange
        resortCodeLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14)
        resortNameGradientView.addSubview(resortCodeLabel)
        
        var allInclusive_X = 55
        if resort.tier != nil {
            let tierImageView = UIImageView(frame: CGRect(x: 55, y: 42, width: 16, height: 16))
            let tierImageName = Helper.getTierImageName(tier: resort.tier!.uppercased())
            if tierImageName != "" {
                tierImageView.image = UIImage(named: tierImageName)
                resortNameGradientView.addSubview(tierImageView)
                allInclusive_X = allInclusive_X + 19
            }
        }
        
        if resort.allInclusive {
            let allInclusiveImageView = UIImageView(frame: CGRect(x: allInclusive_X, y: 42, width: 16, height: 16))
            allInclusiveImageView.image = #imageLiteral(resourceName: "Resort_All_Inclusive")
            resortNameGradientView.addSubview(allInclusiveImageView)
        }
        
        return cell
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if Constant.MyClassConstants.isRunningOnIphone && resortCollectionView != nil {
            var visible: [AnyObject] = resortCollectionView.indexPathsForVisibleItems as [AnyObject]
            let indexpath: NSIndexPath = (visible[0] as! NSIndexPath)
            
            currentIndex = indexpath.row
            DispatchQueue.main.async {
                
                for marker in Constant.MyClassConstants.googleMarkerArray {
                    
                    if marker.userData as! Int == self.currentIndex {
                        marker.icon = UIImage(named: Constant.assetImageNames.pinFocusImage)
                        marker.isFlat = true
                        self.mapView.selectedMarker = marker
                    } else {
                        marker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                        marker.isFlat = false
                    }
                }
            }
        }
        
    }
}

//***** Table view delegate methods to handle table view *****//
extension GoogleMapViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 1 {
            
            switch indexPath.section {
            case 0:
                return 56
            default:
                return 66
            }
        } else {
            return 252
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if sourceController != Constant.MyClassConstants.createAlert && sourceController != Constant.MyClassConstants.editAlert && sourceController != Constant.MyClassConstants.vacationSearch {
            
            if tableView.tag == 1 {
                
                if Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.resortDirectoryTitle {
                    self.hidePopUpView()
                }
                if indexPath.section == 1 {
                    
                    let selectedResort = Constant.MyClassConstants.resorts?[indexPath.row]
                    
                    Helper.getResortWithResortCode(code: selectedResort?.resortCode ?? "", viewcontroller: self)
                    googleMapSearchBar.text = ""
                    hidePopUpView()
                } else {
                    
                    showHudAsync()
                    needCameraChange = true
                    if let geoArea = Constant.MyClassConstants.destinations?[indexPath.row].geoArea {
                        if let destination = Constant.MyClassConstants.destinations?[indexPath.row] {
                            self.selectedDestination = destination
                        }
                        self.apiCallWithRectangleRequest(request: geoArea)
                    }
                    hidePopUpView()
                }
            } else {
                
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[indexPath.row]
                
                Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsDescriptionArray.resortCode!, viewcontroller: self)
                
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                handleSwipes(sender: rightSwipe)
            }
        }
    }
    
}
//***** Table view datasource methods to handle table view *****//
extension GoogleMapViewController: UITableViewDataSource {
    @available(iOS 2.0, *)
    
    //***** UITableview dataSource methods definition here *****//
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            
            return 2
        } else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1 {
            
            if section == 0 {
                if Constant.MyClassConstants.destinations?.count == nil {
                    return 0
                } else {
                    return Constant.MyClassConstants.destinations?.count ?? 0
                }
            } else {
                if Constant.MyClassConstants.resorts?.count == nil {
                    return 0
                } else {
                    return  Constant.MyClassConstants.resorts?.count ?? 0
                }
            }
            
        } else {
            
            return Constant.MyClassConstants.resortsArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constant.MyClassConstants.sectionHeaderArray[section]
    }
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 {
            
            if section == 0 && Constant.MyClassConstants.destinations!.count > 0 {
                return 30
            } else if section == 1 && Constant.MyClassConstants.resorts!.count > 0 {
                
                return 30
            } else {
                return 0
            }
        } else {
            
            return 0
        }
    }
    //***** Implementing header and footer cell for all sections  *****//
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 30))
        sectionHeaderView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            
            if indexPath.section == 0 {
                
                guard let cell: ResortDestinationCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.destinationCell, for: indexPath as IndexPath) as? ResortDestinationCell else { return UITableViewCell() }
                if sourceController != Constant.MyClassConstants.createAlert && sourceController != Constant.MyClassConstants.editAlert && sourceController != Constant.MyClassConstants.vacationSearch {
                    
                    cell.addDestinationButton.isHidden = true
                    cell.destinationMapIcon.isHidden = true
                } else {
                    
                    if let dicValue = Constant.MyClassConstants.destinations?[indexPath.row] {
                    if Constant.MyClassConstants.realmStoredDestIdOrCodeArray.contains(dicValue.destinationId ?? "") {
                        cell.addDestinationButton.isEnabled = false
                        cell.addDestinationButton.alpha = 0.5
                    } else {
                        cell.addDestinationButton.isEnabled = true
                        cell.addDestinationButton.alpha = 1
                    }
                    
                    cell.destinationMapIcon.isHidden = false
                  }
                }
                cell.addDestinationButton.tag = indexPath.row
                cell.destinationMapIcon.tag = indexPath.row
                cell.addDestinationButton.addTarget(self, action: #selector(destinationSelectedAtIndex(sender:)), for: .touchUpInside)
                cell.destinationMapIcon.addTarget(self, action: #selector(resortShowMapPressedAtIndex(sender:)), for: .touchUpInside)
                cell.tag = indexPath.section
                if let dicValue = Constant.MyClassConstants.destinations?[indexPath.row] {
                    cell.resortLocationName.text = dicValue.destinationName
                    if let address = dicValue.address {
                       cell.resortLocationName.text = [dicValue.destinationName, address.postalAddresAsString()].flatMap { $0 }.joined(separator: ", ")
                    }
                
                //TODO (jhon) - aplication was crashing when lookin for resort name (Paris, Cancun)
                if let territoryCode = dicValue.address?.territoryCode {
                    cell.resortCodeLabel.text = territoryCode
                } else {
                    cell.resortCodeLabel.text = dicValue.address?.countryCode
                }
                }
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortCell, for: indexPath as IndexPath) as? ResortsTableViewCell else { return UITableViewCell() }
                
                if sourceController != Constant.MyClassConstants.createAlert && sourceController != Constant.MyClassConstants.editAlert && sourceController != Constant.MyClassConstants.vacationSearch {
                    
                    cell.addResortButton.isHidden = true
                    cell.showMapButton.isHidden = true
                } else {
                    let dicValue = Constant.MyClassConstants.resorts![indexPath.row]
                    if Constant.MyClassConstants.realmStoredDestIdOrCodeArray.contains(dicValue.resortCode ?? "") {
                        cell.addResortButton.isEnabled = false
                        cell.addResortButton.alpha = 0.5
                    } else {
                        cell.addResortButton.alpha = 1
                        cell.addResortButton.isEnabled = true
                    }
                    
                    cell.showMapButton.isHidden = false
                }
                
                cell.tag = indexPath.section
                cell.showMapButton.tag = indexPath.row
                cell.addResortButton.tag = indexPath.row
                cell.showMapButton.addTarget(self, action: #selector(resortShowMapPressedAtIndex(sender:)), for: .touchUpInside)
                cell.addResortButton.addTarget(self, action: #selector(destinationSelectedAtIndex(sender:)), for: .touchUpInside)
                let dicValue = Constant.MyClassConstants.resorts?[indexPath.row]
                cell.resortLocationName.text = dicValue?.resortName
                
                cell.resortCityName.text = dicValue?.address?.cityName
                cell.resortCode.text = dicValue?.resortCode ?? ""
                return cell
            }
            
        } else {
            
            let resortDetails = Constant.MyClassConstants.resortsArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath as IndexPath) as? SearchResultContentTableCell else { return UITableViewCell() }
            
            for layer in cell.resortNameGradientView.layer.sublayers! {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
            var frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: cell.resortNameGradientView.frame.size.height)
            if Constant.RunningDevice.deviceIdiom == .pad {
                frame = CGRect(x: 0, y: 0, width: view.frame.size.width * 0.4 + 100, height: cell.resortNameGradientView.frame.size.height)
            }
            cell.resortNameGradientView.frame = frame
            Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            cell.favoriteButton.tag = indexPath.row
            
            if sourceController == Constant.MyClassConstants.createAlert || sourceController == Constant.MyClassConstants.editAlert || sourceController == Constant.MyClassConstants.vacationSearch {
                
                cell.favoriteButton.setImage(UIImage(named: Constant.assetImageNames.optOffImage), for: UIControlState.normal)
                cell.favoriteButton.setImage(UIImage(named: Constant.assetImageNames.optOnImage), for: UIControlState.selected)
                cell.favoriteButton.addTarget(self, action: #selector(addResortPressedAtIndex(sender:)), for: .touchUpInside)
                
                if Constant.MyClassConstants.addResortSelectedIndex.contains(indexPath.row) {
                    cell.favoriteButton.isSelected = true
                } else {
                    cell.favoriteButton.isSelected = false
                }
            } else {
                
                let status = Helper.isResrotFavorite(resortCode: resortDetails.resortCode ?? "")
                if status {
                    cell.favoriteButton.isSelected = true
                } else {
                    cell.favoriteButton.isSelected = false
                }
            }
            cell.favoriteButton.tag = indexPath.row
            
            if resortDetails.images.count > 0 {
                let url = NSURL(string: Constant.MyClassConstants.resortsArray[indexPath.row].images[Constant.MyClassConstants.resortsArray[indexPath.row].images.count - 1].url ?? "")
                
                cell.resortImageView.setImageWith(url as URL!, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
            }
            cell.resortName.text = resortDetails.resortName
            let resortAddress = resortDetails.address
            cell.resortCountry.text = resortAddress?.cityName
            cell.resortCode.text = resortDetails.resortCode
            cell.delegate = self
            
            if let tier = resortDetails.tier {
                let tierImageName = Helper.getTierImageName(tier: tier.uppercased())
                if tierImageName != "" {
                    cell.tierImageView.image = UIImage(named: tierImageName)
                    cell.tierImageView.isHidden = false
                } else {
                    cell.tierImageView.isHidden = true
                }
            }
            
            cell.allIncImageView.image = #imageLiteral(resourceName: "Resort_All_Inclusive")
            cell.allIncImageView.isHidden = !resortDetails.allInclusive
            return cell
        }
    }
    
}

//***** Search bar delegate methods to handle the search bar actions *****//
extension GoogleMapViewController: UISearchBarDelegate {
    
    //**** Search bar controller delegate ****//
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        zoomIn = true
        googleMapSearchBar.showsCancelButton = true
        if Constant.RunningDevice.deviceIdiom == .pad {
            hideMapSideView(flag: true)
        }
        
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        googleMapSearchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        googleMapSearchBar.resignFirstResponder()
        googleMapSearchBar.showsCancelButton = false
        hidePopUpView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if Constant.RunningDevice.deviceIdiom == .pad {
            hideMapSideView(flag: true)
        }
        if let searchBarText = searchBar.text, searchBarText.count >= 3 {

                DirectoryClient.searchDestinations(Constant.MyClassConstants.systemAccessToken, request: SearchDestinationsRequest(query: searchBar.text), onSuccess: { [weak self] response in
                    if !response.resorts.isEmpty {
                        Constant.MyClassConstants.resorts = response.resorts
                        Constant.MyClassConstants.resortsArray = response.resorts
                    }
                    
                    Constant.MyClassConstants.destinations = response.destinations
                    self?.showPopUpView()
                    self?.searchDisplayTableView.reloadData()
                    
                }) { [weak self] error in
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                }
        }
    }
    
}

//***** Custom delegate methods with Extension for favorite unfavorite functionality *****//

extension GoogleMapViewController: SearchResultContentTableCellDelegate {
    
    func favoriteButtonClicked(_ sender: UIButton) {
        bottomResortFavoritesButtonPressed(sender: sender)
    }
}
