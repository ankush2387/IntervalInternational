//
//  FevoritesResortController.swift
//  IntervalApp
//
//  Created by Chetu on 14/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import GoogleMaps
import DarwinSDK

class FevoritesResortController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var resortTableBaseView: UIView!
    @IBOutlet var resortTableView: UITableView!
    @IBOutlet var containerView: UIView!
    
    //***** class variables *****//
    let datasource = ResortDetails()
    var emptyFavoritesMessageView: UIView!
    var mapView = GMSMapView()
    var bounds = GMSCoordinateBounds()
    var camera: GMSCameraPosition!
    let backgroundView = UIView()
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constant.MyClassConstants.signInRequestedController = self
        
        //***** Register custom cell with map tale view with some validation check *****//
        resortTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.searchResultContentTableCell)
        
        //***** Register delegate and data source with tableview *****//
        resortTableView.dataSource = datasource
        resortTableView.delegate = datasource
        datasource.unfavHandler = { [weak self] (rowNumber) in
            guard let strongSelf = self else { return }
            strongSelf.unfavClicked(rowNumber: rowNumber)
            strongSelf.resortTableView.reloadData()
        }
    }
    override func viewWillLayoutSubviews() {
        self.mapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if Constant.RunningDevice.deviceIdiom == .pad && resortTableView != nil {
            if self.containerView != nil {
                self.containerView.isHidden = true
                if self.emptyFavoritesMessageView != nil {
                    self.emptyFavoritesMessageView.isHidden = false
                    self.backgroundView.isHidden = true
                    
                    var count = 0
                    for subView in self.view.subviews {
                        if subView .isKind(of: GMSMapView.self) {
                            count = count + 1
                        }
                    }
                    if count == 0 {
                        createMapWithMarkers()
                    }
                }
                resortTableView.reloadData()
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if Session.sharedSession.userAccessToken != nil {
            showHudAsync()
            UserClient.getFavoriteResorts(Session.sharedSession.userAccessToken, onSuccess: { (response) in
                Constant.MyClassConstants.favoritesResortArray.removeAll()
                for item in [response][0] {
                    if let resortFav = item as? ResortFavorite {
                        if let resort = resortFav.resort {
                            let code = resort.resortCode
                            Constant.MyClassConstants.favoritesResortCodeArray.add(code)
                            Constant.MyClassConstants.favoritesResortArray.append(resort)
                            
                        }
                        
                    }
                    
                }
                self.setupView()
                self.hideHudAsync()
            }) { (_) in
                self.setupView()
                self.hideHudAsync()
            }
        } else {
            setupView()
        }
    }
    
    fileprivate func setupView() {
        if Session.sharedSession.userAccessToken == nil {
            self.hideHudAsync()
            self.signInView.isHidden = false
            self.resortTableBaseView.isHidden = true
        } else {
            
            self.resortTableBaseView.isHidden = true
            if self.resortTableBaseView != nil {
                
                self.resortTableBaseView.isHidden = false
            }
            
            self.signInView.isHidden = true
            if UIDevice().userInterfaceIdiom == .pad {
                createMapWithMarkers()
            }
            if Constant.MyClassConstants.favoritesResortArray.count > 0 {
                
                self.resortTableView.reloadData()
                if self.emptyFavoritesMessageView != nil {
                    self.emptyFavoritesMessageView.removeFromSuperview()
                }
                
            } else {
                
                if UIDevice().userInterfaceIdiom == .pad {
                    if Constant.MyClassConstants.favoritesResortArray.count == 0 {
                        backgroundView.frame = CGRect(x: 0, y: 0, width: self.resortTableView.frame.size.width - 20, height: UIScreen.main.bounds.height)
                        backgroundView.backgroundColor = UIColor.white
                        self.view.addSubview(backgroundView)
                        let messageView = UIView()
                        
                        messageView.frame = CGRect(x: 20, y: 60, width: self.resortTableView.frame.size.width - 20, height: 600)
                        
                        self.emptyFavoritesMessageView = Helper.displayEmptyFavoritesMessage(requestedView: messageView)
                        backgroundView.addSubview(self.emptyFavoritesMessageView)
                        
                        if self.containerView != nil {
                            self.containerView.isHidden = true
                        }
                    }
                } else {
                    self.emptyFavoritesMessageView = Helper.displayEmptyFavoritesMessage(requestedView: self.view)
                    self.view.superview?.addSubview(self.emptyFavoritesMessageView)
                }
            }
        }
        
        self.navigationItem.title = Constant.ControllerTitles.favoritesViewController
        
        //***** Condition for maintaining the back button and hamberger menu according to logged in or pre login *****//
        if (Session.sharedSession.userAccessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull {
            if let rvc = self.revealViewController() {
                //set SWRevealViewController's Delegate
                rvc.delegate = self
                
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                self.view.addGestureRecognizer( rvc.panGestureRecognizer())
            }
            
        } else {
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(FevoritesResortController.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
        }
        
        if UIDevice().userInterfaceIdiom == .pad {
            createMapWithMarkers()
        }
        
        //***** adding notifications to call specific method when notification fired *****//
        NotificationCenter.default.addObserver(self, selector: #selector(closeButtonClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(helpClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.showHelp), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(unfavClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.showUnfavorite), object: nil)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        /*NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.showHelp), object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.showUnfavorite), object: nil)*/
    }
    //****** Function to create map for iPad with markers *****//
    
    func createMapWithMarkers() {
        if Constant.MyClassConstants.favoritesResortArray.count == 0 {
            let camera = GMSCameraPosition.camera(withLatitude: 4.739001, longitude: -74.059616, zoom: 17)
            let mapframe = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64 - 49)
            let myGSMMap = GMSMapView.map(withFrame: mapframe, camera: camera)
            myGSMMap.isMyLocationEnabled = true
            myGSMMap.settings.myLocationButton = true
            myGSMMap.delegate = self
            for subView in resortTableBaseView.subviews {
                if (subView .isKind(of: GMSMapView.self)) {
                    subView.removeFromSuperview()
                }
            }
            resortTableBaseView.addSubview(mapView)
            self.backgroundView.isHidden = false
            
        } else if Constant.MyClassConstants.favoritesResortArray.count > 0 {
            backgroundView.isHidden = true
            camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.favoritesResortArray.last!.coordinates?.latitude)!, longitude: (Constant.MyClassConstants.favoritesResortArray.last!.coordinates?.longitude)!, zoom: 12)
            
            let mapframe = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64 - 49)
            mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.delegate = self
            for subView in resortTableBaseView.subviews {
                if (subView .isKind(of: GMSMapView.self)) {
                    subView.removeFromSuperview()
                }
            }
            resortTableBaseView.addSubview(mapView)
            var tag = 0
            
            for resort in Constant.MyClassConstants.favoritesResortArray {
                
                if let latitude = resort.coordinates?.latitude {
                    let  position = CLLocationCoordinate2DMake((latitude), resort.coordinates!.longitude)
                    let marker = GMSMarker()
                    marker.position = position
                    marker.isFlat = false
                    marker.userData = tag
                    tag = tag + 1
                    marker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
                    marker.appearAnimation = GMSMarkerAnimation.pop
                    bounds = bounds.includingCoordinate(marker.position)
                    marker.map = mapView
                    Constant.MyClassConstants.googleMarkerArray.append(marker)
                }
                
            }
            mapView.animate(with: GMSCameraUpdate.fit(bounds))
            mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
            mapView.animate(toZoom: 12.0)
            
            if self.resortTableBaseView != nil && self.resortTableBaseView.isHidden == false {
                resortTableBaseView.backgroundColor = UIColor.clear
                resortTableBaseView.bringSubview(toFront: self.resortTableView)
            }
        }
    }
    
    //***** this function called when navigation back button pressed *****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.emptyFavoritesMessageView != nil {
            self.emptyFavoritesMessageView.removeFromSuperview()
        }
    }
    @IBAction func signInButtonPressed(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.segueSignInForPreLogin, sender: nil)
        
    }
    //***** method called when notification fired with reloadFavoritesTab *****//
    func reloadView() {
        self.viewWillAppear(true)
    }
    
    //***** method called login help button pressed and redirect to webView *****//
    func helpClicked() {
        
        Constant.MyClassConstants.requestedWebviewURL = ""
        Constant.MyClassConstants.webviewTtile = ""
        
        Constant.MyClassConstants.webviewTtile = Constant.ControllerTitles.loginHelpViewController
        Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.loginHelpURL
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.loginIPhone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.webViewController)
        
        //***** creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        self.navigationController?.setViewControllers([viewController], animated: false)
    }
    
    //***** method called when resort favorites button clicked to make resort unfavorite *****//
    @objc private func unfavClicked(rowNumber: Int) {

        if let userAccessToken = Session.sharedSession.userAccessToken,
            let resortCode = Constant.MyClassConstants.favoritesResortArray[rowNumber].resortCode {
            
            let onSuccess = { [weak self] in
                guard let strongSelf = self else { return }
                Constant.MyClassConstants.favoritesResortArray.remove(at: rowNumber)
                Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                
                strongSelf.resortTableView.beginUpdates()
                strongSelf.resortTableView.deleteRows(at: [IndexPath(row: rowNumber, section: 0)], with: .automatic)
                ADBMobile.trackAction(Constant.omnitureEvents.event51, data: nil)
                
                if Constant.RunningDevice.deviceIdiom == .pad {
                    Constant.MyClassConstants.googleMarkerArray.flatMap {
                        Constant.MyClassConstants.googleMarkerArray.index(of: $0)
                        }.forEach {
                            Constant.MyClassConstants.googleMarkerArray.remove(at: $0)
                            strongSelf.createMapWithMarkers()
                    }
                }
                
                if Constant.MyClassConstants.favoritesResortArray.isEmpty {
                    strongSelf.setupView()
                }
                
                strongSelf.resortTableView.endUpdates()
            }
            
            let onError = { [weak self] (error: NSError?) in
                intervalPrint(error as Any)
                self?.presentErrorAlert(UserFacingCommonError.serverError(error))
            }
            
            UserClient.removeFavoriteResort(userAccessToken,
                                            resortCode: resortCode,
                                            onSuccess: onSuccess,
                                            onError: onError)
        } else {
            presentErrorAlert(UserFacingCommonError.generic)
        }
    }
    
    //***** Function is called when done button is clicked in details side menu *****/
    func closeButtonClicked() {
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.containerView.frame = CGRect(x: -(self.containerView.frame.size.width), y: 64, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
            }, completion: { _ in
                
            })
            
        }, completion: { _ in
            
        })
    }
}

//***** map view delegate methods to handle map *****//
extension FevoritesResortController: GMSMapViewDelegate {
    
    //***** this method called when map marker selected *****//
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if (Constant.MyClassConstants.googleMarkerArray.count == 0) {
                
            } else {
                if self.containerView != nil {
                self.containerView.isHidden = false
                self.view.bringSubview(toFront: self.containerView)
                }
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.favoritesResortArray[marker.userData as! Int]
                
                Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsDescriptionArray.resortCode!, viewcontroller: self)
                
                let containerVC = self.childViewControllers[0] as! ResortDetailsViewController
                containerVC.senderViewController = Constant.MyClassConstants.searchResult
                containerVC.viewWillAppear(true)
                
                if self.containerView != nil {
                UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    
                    self.containerView.frame = CGRect(x: 0, y: 64, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                    
                }, completion: { _ in
                    
                })
                }
                
            }
        }
        return true
    }
}
//***** custom delegate methods extension class implementation  *****//
extension FevoritesResortController: ResortDetailsDelegate {
    
    func tableViewSelected(_ index: Int) {
        if Constant.RunningDevice.deviceIdiom == .pad {
            self.containerView.isHidden = false
            let selectedResort = Constant.MyClassConstants.favoritesResortArray[index]
            Helper.getResortWithResortCode(code: selectedResort.resortCode!, viewcontroller: self)
            
            let containerVC = self.childViewControllers[0] as! ResortDetailsViewController
            containerVC.senderViewController = Constant.MyClassConstants.searchResult
            containerVC.viewWillAppear(true)
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.containerView.frame = CGRect(x: 0, y: 64, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
            }, completion: { _ in
                
            })
        } else {
            let selectedResort = Constant.MyClassConstants.favoritesResortArray[index]
            Helper.getResortWithResortCode(code: selectedResort.resortCode!, viewcontroller: self)
        }
    }
}
