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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constant.MyClassConstants.signInRequestedController = self
        //***** Register custom cell with map tale view with some validation check *****//
        resortTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.searchResultContentTableCell)
        
        //***** Register delegate and data source with tableview *****//
        resortTableView.dataSource = datasource
        resortTableView.delegate = datasource
        datasource.delegate = self
        datasource.unfavHandler = { [weak self] rowNumber in
            guard let strongSelf = self else { return }
            strongSelf.unfavClicked(rowNumber: rowNumber)
            strongSelf.resortTableView.reloadData()
        }
    }
    override func viewWillLayoutSubviews() {
        mapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if Constant.RunningDevice.deviceIdiom == .pad && resortTableView != nil {
            if containerView != nil {
                containerView.isHidden = true
                if emptyFavoritesMessageView != nil {
                    emptyFavoritesMessageView.isHidden = false
                    backgroundView.isHidden = true
                    
                    var count = 0
                    for subView in view.subviews {
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
        
        super.viewWillAppear(animated)
        if Session.sharedSession.userAccessToken != nil {
            showHudAsync()
            UserClient.getFavoriteResorts(Session.sharedSession.userAccessToken, onSuccess: { response in
                Constant.MyClassConstants.favoritesResortArray.removeAll()
                for item in response {
                    if let resort = item.resort, let resortCode = resort.resortCode {
                        Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                        Constant.MyClassConstants.favoritesResortArray.append(resort)
                    }
                }
                self.setupView()
                self.hideHudAsync()
            }) { [weak self] _ in
                self?.setupView()
                self?.hideHudAsync()
            }
        } else {
            setupView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    fileprivate func setupView() {
        if Session.sharedSession.userAccessToken == nil {
            self.hideHudAsync()
            signInView.isHidden = false
            resortTableBaseView.isHidden = true
        } else {
            resortTableBaseView.isHidden = true
            if resortTableBaseView != nil {
                resortTableBaseView.isHidden = false
            }
            
            self.signInView.isHidden = true
            if UIDevice().userInterfaceIdiom == .pad {
                createMapWithMarkers()
            }
            
            resortTableView.reloadData()
            if !Constant.MyClassConstants.favoritesResortArray.isEmpty {
                
                if emptyFavoritesMessageView != nil {
                    emptyFavoritesMessageView.removeFromSuperview()
                }
            } else {
                
                if UIDevice().userInterfaceIdiom == .pad {
                    if Constant.MyClassConstants.favoritesResortArray.isEmpty {
                        backgroundView.frame = CGRect(x: 0, y: 0, width: resortTableView.frame.size.width - 20, height: UIScreen.main.bounds.height)
                        backgroundView.backgroundColor = UIColor.white
                        view.addSubview(backgroundView)
                        let messageView = UIView()
                        
                        messageView.frame = CGRect(x: 20, y: 60, width: resortTableView.frame.size.width - 20, height: 600)
                        
                        emptyFavoritesMessageView = Helper.displayEmptyFavoritesMessage(requestedView: messageView)
                        backgroundView.addSubview(self.emptyFavoritesMessageView)
                        
                        if containerView != nil {
                            containerView.isHidden = true
                        }
                    }
                } else {
                    emptyFavoritesMessageView = Helper.displayEmptyFavoritesMessage(requestedView: self.view)
                    view.superview?.addSubview(emptyFavoritesMessageView)
                }
            }
        }
        
        navigationItem.title = Constant.ControllerTitles.favoritesViewController
        
        //***** Condition for maintaining the back button and hamberger menu according to logged in or pre login *****//
        if Session.sharedSession.userAccessToken != nil && Constant.MyClassConstants.isLoginSuccessfull {
            if let rvc = revealViewController() {
                //set SWRevealViewController's Delegate
                rvc.delegate = self
                
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                view.addGestureRecognizer( rvc.panGestureRecognizer())
            }
            
        } else {
            let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(FevoritesResortController.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = menuButton
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
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.showHelp), object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.showUnfavorite), object: nil)
    }
    //****** Function to create map for iPad with markers *****//
    
    func createMapWithMarkers() {
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        if Constant.MyClassConstants.favoritesResortArray.isEmpty {
            var mapCount = 0
            for subView in resortTableBaseView.subviews {
                if subView .isKind(of: GMSMapView.self) {
                    mapCount = mapCount + 1
                    let mapView = subView as? GMSMapView
                    mapView?.clear()
                }
            }
            if mapCount == 0 {
                let mapframe = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
                let camera = GMSCameraPosition.camera(withLatitude: 4.739001, longitude: -74.059616, zoom: 8)
                mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
                resortTableBaseView.addSubview(mapView)
            }
            backgroundView.isHidden = false
            
        } else if !Constant.MyClassConstants.favoritesResortArray.isEmpty {
            backgroundView.isHidden = true
            if let latitude = Constant.MyClassConstants.favoritesResortArray.last?.coordinates?.latitude, let longitude = Constant.MyClassConstants.favoritesResortArray.last?.coordinates?.longitude {
                camera = GMSCameraPosition.camera(withLatitude:latitude, longitude:longitude, zoom: 8)
                
                let mapframe = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
                mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
            }
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.delegate = self
            for subView in resortTableBaseView.subviews {
                if subView .isKind(of: GMSMapView.self) {
                    subView.removeFromSuperview()
                }
            }
            resortTableBaseView.addSubview(mapView)
            var tag = 0
            
            for resort in Constant.MyClassConstants.favoritesResortArray {
                
                if let latitude = resort.coordinates?.latitude, let longitude = resort.coordinates?.longitude {
                    let  position = CLLocationCoordinate2DMake(latitude, longitude)
                    let marker = GMSMarker()
                    marker.position = position
                    marker.isFlat = false
                    marker.userData = tag
                    tag = tag + 1
                    marker.icon = #imageLiteral(resourceName: "PinActive")
                    marker.appearAnimation = GMSMarkerAnimation.pop
                    bounds = bounds.includingCoordinate(marker.position)
                    marker.map = mapView
                    if !Constant.MyClassConstants.googleMarkerArray.contains(marker) {
                        Constant.MyClassConstants.googleMarkerArray.append(marker)
                    }
                }
                
            }
            mapView.animate(with: GMSCameraUpdate.fit(bounds))
            mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
            mapView.animate(toZoom: 8.0)
            
            if resortTableBaseView != nil && resortTableBaseView.isHidden == false {
                resortTableBaseView.backgroundColor = UIColor.clear
                resortTableBaseView.bringSubview(toFront: resortTableView)
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
        super.viewWillDisappear(animated)
        if emptyFavoritesMessageView != nil {
            emptyFavoritesMessageView.removeFromSuperview()
        }
    }
    @IBAction func signInButtonPressed(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.segueSignInForPreLogin, sender: nil)
        
    }
    //***** method called when notification fired with reloadFavoritesTab *****//
    func reloadView() {
        viewWillAppear(true)
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
        navigationController?.setViewControllers([viewController], animated: false)
    }
    
    //***** method called when resort favorites button clicked to make resort unfavorite *****//
    @objc private func unfavClicked(rowNumber: Int) {

        if let userAccessToken = Session.sharedSession.userAccessToken,
            let resortCode = Constant.MyClassConstants.favoritesResortArray[rowNumber].resortCode {
            
            let onSuccess = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.hideHudAsync()
                Constant.MyClassConstants.favoritesResortArray.remove(at: rowNumber)
                Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                
                strongSelf.resortTableView.beginUpdates()
                strongSelf.resortTableView.deleteRows(at: [IndexPath(row: rowNumber, section: 0)], with: .automatic)
                ADBMobile.trackAction(Constant.omnitureEvents.event51, data: nil)
                
                if Constant.RunningDevice.deviceIdiom == .pad {
                    Constant.MyClassConstants.googleMarkerArray.remove(at: rowNumber)
                    strongSelf.createMapWithMarkers()
                }
                
                if Constant.MyClassConstants.favoritesResortArray.isEmpty {
                    strongSelf.setupView()
                }
                
                strongSelf.resortTableView.endUpdates()
            }
            
            let onError = { [weak self] (error: NSError) in
                self?.hideHudAsync()
                self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                return
            }
            self.showHudAsync()
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
            
            if Constant.MyClassConstants.googleMarkerArray.count == 0 {
                
            } else {
                if containerView != nil {
                containerView.isHidden = false
                view.bringSubview(toFront: self.containerView)
                }
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.favoritesResortArray[marker.userData as? Int ?? 0]
                if let resortCode = Constant.MyClassConstants.resortsDescriptionArray.resortCode {
                    Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
                }
                
                guard let containerVC = childViewControllers[0] as? ResortDetailsViewController else { return false }
                containerVC.senderViewController = Constant.MyClassConstants.showSearchResultButton

                containerVC.viewWillAppear(true)
                
                if containerView != nil {
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
            containerView.isHidden = false
            let selectedResort = Constant.MyClassConstants.favoritesResortArray[index]
            if let resortCode = selectedResort.resortCode {
                Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
            }
            
            guard let containerVC = childViewControllers[0] as? ResortDetailsViewController else { return }
            containerVC.senderViewController = Constant.MyClassConstants.showSearchResultButton

            containerVC.viewWillAppear(true)
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.containerView.frame = CGRect(x: 0, y: 64, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
            }, completion: { _ in
                
            })
        } else {
            let selectedResort = Constant.MyClassConstants.favoritesResortArray[index]
            if let resortCode = selectedResort.resortCode {
                Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
                showHudAsync()
            }
        }
    }

}
