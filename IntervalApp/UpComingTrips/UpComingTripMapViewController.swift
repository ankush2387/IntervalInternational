//
//  UpComingTripMapViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import GoogleMaps
import DarwinSDK
import IntervalUIKit

class UpComingTripMapViewController: UIViewController, GMSMapViewDelegate {
    
    var mapView = GMSMapView()
    var coordinates: Coordinates?
    var resortName: String?
    var cityName: String?
    var presentedModally = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presentedModally {
            setupNavigationForModalPresentation()
        } else {
            setupDoneButtonView()
        }
        self.setupMap()
    }
    
    func setupDoneButtonView() {
        
        let doneButtonView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64))
            doneButtonView.backgroundColor = UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
        let doneButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 60, y: 7, width: 50, height: 50))
            doneButton.setTitleColor(IUIKColorPalette.primary1.color, for: .normal)
            doneButton.setTitle("Done", for: .normal)
            doneButton.addTarget(self, action: #selector(UpComingTripMapViewController.doneButtonPressed(_:)), for: .touchUpInside)
        doneButtonView.addSubview(doneButton)
        view.addSubview(doneButtonView)
    }
    
    func setupNavigationForModalPresentation() {
        //Nav-bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UpComingTripMapViewController.menuBackButtonPressed(_:)))
        doneButton.tintColor = .white
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        view.layer.add(Helper.topToBottomTransition(), forKey: nil)
        dismiss(animated: false)
    }
    
    func doneButtonPressed(_ sender: UIButton) {
        Constant.MyClassConstants.showResortDetailsWhenClickedDone = true
        navigationController?.view.layer.add(Helper.topToBottomTransition(), forKey: nil)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presentedModally {
            tabBarController?.tabBar.isHidden = true
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         if !presentedModally {
            navigationController?.navigationBar.isHidden = false
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    func setupMap() {
        guard let latitude = coordinates?.latitude else { return }
        guard let longitude = coordinates?.longitude else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        let mapframe = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64)
        
        mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
        mapView.isUserInteractionEnabled = true

        //create Marker
        let  position = CLLocationCoordinate2DMake(latitude, longitude)
        let marker = GMSMarker()
        marker.position = position
        marker.title = resortName
        marker.snippet = cityName
        marker.isFlat = true
        marker.icon = UIImage(named: Constant.assetImageNames.pinActiveImage)
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = mapView

        mapView.settings.zoomGestures = true
        mapView.delegate = self
        view.addSubview(mapView)
    }
}

extension UIViewController {
    func displayMapView(coordinates: Coordinates, resortName: String, cityName: String, presentModal: Bool, completionHandler: @escaping(_ response: Bool) -> Void) {
                
        let storyboard = UIStoryboard(name: "MyUpcomingTripIphone", bundle: nil)
        let mapDetailsNav = storyboard.instantiateViewController(withIdentifier: "mapDetailNav") as! UINavigationController
        let mapVC = mapDetailsNav.viewControllers.first as! UpComingTripMapViewController
        mapVC.resortName = resortName
        mapVC.cityName = cityName
        mapVC.coordinates = coordinates
        
        if presentModal {
            self.present(mapDetailsNav, animated: true, completion: nil)
        } else {
        self.navigationController?.view.layer.add(Helper.bottomToTopTransition(), forKey: nil)
        self.navigationController?.pushViewController(mapVC, animated: false)
            mapVC.presentedModally = false
        }
        completionHandler(true)
    }
}
