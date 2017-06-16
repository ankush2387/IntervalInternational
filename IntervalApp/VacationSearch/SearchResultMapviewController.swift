//
//  SearchResultMapviewController.swift
//  IntervalApp
//
//  Created by Chetu on 14/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import GoogleMaps
import IntervalUIKit
import DarwinSDK
import SDWebImage
import SVProgressHUD

class SearchResultMapviewController: UIViewController {
    
    
    //Oultlets
    @IBOutlet weak var gmsMapView: GMSMapView!
    
    
    //class variables
    var bottomResortHeight:CGFloat!
    var resortView = UIView()
    var resortCollectionView:UICollectionView!
    var marker:GMSMarker! = nil
    var bounds = GMSCoordinateBounds()
    var selectedIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.searchResultViewController
        bottomResortHeight = self.view.frame.height/3 + 50
        let menuButton = UIBarButtonItem(title: Constant.AlertPromtMessages.done, style: .plain, target: self, action: #selector(SearchResultMapviewController.doneButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = menuButton
        if(Constant.MyClassConstants.resortsArray.count > 0) {
            self.addMarkersOnMapView()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Creating map with resorts getting from current location when map screen landing first time *****//
    func addMarkersOnMapView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.latitude)!,longitude: (Constant.MyClassConstants.resortsArray[0].coordinates?.longitude)!, zoom: 8)
        
        self.gmsMapView.camera = camera
        gmsMapView.isMyLocationEnabled = true
        gmsMapView.settings.myLocationButton = true
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
            marker.map = self.gmsMapView
            Constant.MyClassConstants.googleMarkerArray.append(marker)
            
        }
        gmsMapView.animate(with: GMSCameraUpdate.fit(bounds))
        gmsMapView.delegate = self
        gmsMapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        gmsMapView.animate(toZoom: 8)
        
    }

    
    //***** Method to create bottom resort view in collection view and pop up with custom animation *****//
    func createBottomResortView(marker :GMSMarker) {
        
        if(resortCollectionView != nil && Constant.MyClassConstants.resortsArray.count > 0){
            resortCollectionView.reloadData()
            self.resortView.isHidden = false
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.bottomResortHeight ), width: self.view.frame.width, height: self.bottomResortHeight)
                
                self.view.bringSubview(toFront: self.resortView)
            }, completion: { _ in
                
            })
            self.view.bringSubview(toFront: self.resortView)
        }else{
            
            
            resortView.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.view.frame.height - (self.view.frame.height - self.bottomResortHeight))
            
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
                
                self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.bottomResortHeight), width: self.view.frame.width, height: self.bottomResortHeight)
                
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
        
        self.selectedIndex = -1
        for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
            
            selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
            selectedMarker.isFlat = false
            
        }
        self.gmsMapView.selectedMarker = nil
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            self.resortView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.bottomResortHeight)
            
        }, completion: { _ in
            
        })
        
    }
    
    // ***** Method to handle swipe gesture from bottom resort view *****//
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .up) {
            
            
        }
        else {
            self.removeBottomView()
        }
    }
    
    //***** This method executes when bottom resort view favorite button pressed *****//
    func bottomResortFavoritesButtonPressed(sender:UIButton) {
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: self.view)
        UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
            
            print(response)
            Helper.removeServiceCallBackgroundView(view: self.view)
            SVProgressHUD.dismiss()
            sender.isSelected = true
            Constant.MyClassConstants.favoritesResortCodeArray.add(Constant.MyClassConstants.resortsArray[sender.tag].resortCode!)
            self.resortCollectionView.reloadData()
            
        }, onError: {(error) in
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            print(error)
        })
    }
    func doneButtonPressed(_ sender:UIBarButtonItem) {
        
          self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

//***** Map view delegate methods to handle map *****//
extension SearchResultMapviewController:GMSMapViewDelegate {
    
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
            
            if(mapView.selectedMarker == nil) {
                
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
                self.gmsMapView.selectedMarker = marker
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[marker.userData as! Int]
                
                Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsDescriptionArray.resortCode!,viewcontroller:self)
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                self.handleSwipes(sender: rightSwipe)
                
            }else {
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
                            self.gmsMapView.selectedMarker = marker
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
        }else{
            
            if(mapView.selectedMarker == nil) {
                
                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                marker.isFlat = true
                self.selectedIndex = marker.userData as! Int
                self.gmsMapView.selectedMarker = marker
                self.createBottomResortView(marker: marker)
                
            }else{
                if(marker == mapView.selectedMarker){
                    marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                    marker.isFlat = false
                    self.removeBottomView()
                }else{
                    for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
                        
                        if(selectedMarker.userData as! Int == marker.userData as! Int) {
                            
                            if( marker.isFlat == true ) {
                                
                                marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                                marker.isFlat = false
                                
                            }
                            else {
                                
                                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                                self.gmsMapView.selectedMarker = marker
                                marker.isFlat = true
                                
                            }
                        }
                        else {
                            
                            selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                            selectedMarker.isFlat = false
                        }
                    }
                    self.gmsMapView.selectedMarker = marker
                    let indexPath = IndexPath(row: marker.userData as! Int, section: 0)
                    if(selectedIndex > marker.userData as! Int) {
                        self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
                    }
                    else {
                       self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
                    }
                    

                }
            }
        }
        return true
    }
    
}

//***** Collection view delegate methods to handle collection view *****//

extension SearchResultMapviewController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//***** Collection view datasource methods to handle collection view *****//
extension SearchResultMapviewController:UICollectionViewDataSource {
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.resortsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
      
//        for marker in Constant.MyClassConstants.googleMarkerArray {
//            
//            if(marker.userData as! Int == indexPath.row) {
//                
//                marker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
//                marker.isFlat = true
//                  self.selectedIndex = indexPath.row
//                self.gmsMapView.selectedMarker = marker
//            }
//            else {
//              
//                marker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
//                marker.isFlat = false
//            }
//           
//            
//        }
        
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
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.favoritesOffImage), for: UIControlState.normal)
            resortFavoritesButton.setImage(UIImage(named: Constant.assetImageNames.favoritesOnImage), for: UIControlState.selected)
            let status = Helper.isResrotFavorite(resortCode: resort.resortCode!)
            if (status) {
                resortFavoritesButton.isSelected = true
            }
            else {
                resortFavoritesButton.isSelected = false
            }

            resortFavoritesButton.addTarget(self, action: #selector(bottomResortFavoritesButtonPressed(sender:)), for: .touchUpInside)
    
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


