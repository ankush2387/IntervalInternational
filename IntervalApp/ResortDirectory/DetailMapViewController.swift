//
//  DetailMapViewController.swift
//  IntervalApp
//
//  Created by Chetu on 04/08/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import GoogleMaps

class DetailMapViewController: UIViewController {
    
    //***** class variables *****//
      var mapView = GMSMapView()
    
    override func viewDidLoad() {
        
        self.title = Constant.ControllerTitles.detailMapViewController
        
        //***** adding menu bar back button *****//
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(DetailMapViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.createMap()
        
    }
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    func createMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude)!, longitude: (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.longitude)!, zoom: 15)
        let mapframe = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64)
        
        mapView = GMSMapView.map(withFrame: mapframe, camera: camera)
        mapView.isUserInteractionEnabled = true
        mapView.isMyLocationEnabled = true
        if (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude) != nil {
            
            let  position = CLLocationCoordinate2DMake((Constant.MyClassConstants.resortsDescriptionArray.coordinates?.latitude)!, (Constant.MyClassConstants.resortsDescriptionArray.coordinates?.longitude)!)
            let marker = GMSMarker()
            marker.position = position
            marker.title = Constant.MyClassConstants.resortsDescriptionArray.resortName
            marker.snippet = Constant.MyClassConstants.resortsDescriptionArray.address?.cityName
            marker.isFlat = true
            marker.icon = UIImage(named: Constant.assetImageNames.pinSelectedImage)
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.map = mapView
        }
        mapView.animate(toZoom: 7)
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        self.view.addSubview(mapView)
        
    }
   
}

extension DetailMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
      
      return false
    }
    
}
