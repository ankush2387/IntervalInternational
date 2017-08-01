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
        }
        self.setupMap()
    }
    
    func setupNavigationForModalPresentation() {
        // change Nav-bar tint color.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 229.0/255.0, green: 231.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        
        //Nav-bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UpComingTripMapViewController.menuBackButtonPressed(_:)))
        doneButton.tintColor = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = doneButton

    }
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupMap() {
        guard let latitude = coordinates?.latitude else { return }
        guard let longitude = coordinates?.longitude else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        let mapframe = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64)
        
        mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
        mapView.isUserInteractionEnabled = true
//        mapView.isMyLocationEnabled = true

        //create Marker
        let  position = CLLocationCoordinate2DMake(latitude,longitude)
        let marker = GMSMarker()
        marker.position = position
        marker.title = resortName
        marker.snippet = cityName
        marker.isFlat = true
        marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = mapView
        

        mapView.settings.zoomGestures = true
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        
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
            self.navigationController?.pushViewController(mapVC, animated: false)
            mapVC.presentedModally = false
        }
        
        completionHandler(true)

    }
}
