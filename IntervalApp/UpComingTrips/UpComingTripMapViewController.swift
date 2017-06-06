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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change Nav-bar tint color.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 229.0/255.0, green: 231.0/255.0, blue: 228.0/255.0, alpha: 1.0)

        //Nav-bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DetailMapViewController.menuBackButtonPressed(_:)))
        doneButton.tintColor = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.setupMap()
    }
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupMap() {
        guard let latitude = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.coordinates?.latitude else { return }
        guard let longitude = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.coordinates?.longitude else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        let mapframe = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64)
        
        mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
        mapView.isUserInteractionEnabled = true
        mapView.isMyLocationEnabled = true

        //create Marker
        let  position = CLLocationCoordinate2DMake(latitude,longitude)
        let marker = GMSMarker()
        marker.position = position
        marker.title = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.resortName
        marker.snippet = Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails.destination?.resort?.address?.cityName
        marker.isFlat = true
        marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = mapView
        

        mapView.settings.zoomGestures = true
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        
    }
}
