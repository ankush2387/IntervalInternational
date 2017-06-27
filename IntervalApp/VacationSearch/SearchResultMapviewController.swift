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
    //var selectedIndex = -1
    var selectedIndex = 0

    @IBOutlet weak var dragView: UIView!

    @IBOutlet weak var containorView: UIView!
    @IBOutlet weak var drarButton: UIButton!
    override func viewDidAppear(_ animated: Bool) {
        if(resortCollectionView != nil){
        resortCollectionView.reloadData()
        } 
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.view.bringSubview(toFront: dragView)
        }
        else{
            
        }
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

    
    override func viewWillAppear(_ animated: Bool) {
      
        
        let notificationNames = [Constant.notificationNames.closeButtonClickedNotification, Constant.notificationNames.closeButtonClickedNotification, ]
        
            NotificationCenter.default.addObserver(self, selector: #selector(closeDetailView), name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Method called when done button clicked on details page *****//
    
    func closeDetailView(){
        if(Constant.RunningDevice.deviceIdiom == .pad){
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                self.containorView.frame = CGRect(x: -self.containorView.frame.size.width, y: self.containorView.frame.origin.y, width: self.containorView.frame.size.width, height: self.containorView.frame.size.height)
                
            }, completion: { _ in
                self.containorView.isHidden = true
                //self.mapView.selectedMarker = nil
            })
        }else{
            //updateMapMarkers()
        }
    }
    
    
    
    //***** Creating map with resorts getting from current location when map screen landing first time *****//
    func addMarkersOnMapView() {
        
        Constant.MyClassConstants.googleMarkerArray.removeAll()
        
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
           // self.resortView.isHidden = false
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                     self.dragView.isHidden = false
                     self.resortView.backgroundColor = UIColor.white
                     self.resortView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width/2, height: self.view.frame.height - 44)
                     self.dragView.frame = CGRect(x: self.resortView.frame.width, y:self.dragView.frame.origin.y, width:self.dragView.frame.size.width, height: self.dragView.frame.size.height)
                }
                else {
                    
                    self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.bottomResortHeight ), width: self.view.frame.width, height: self.bottomResortHeight)
                }
                
                
                self.view.bringSubview(toFront: self.resortView)
            }, completion: { _ in
                
                self.drarButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                
            })
            self.view.bringSubview(toFront: self.resortView)
        }else{
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                 self.dragView.isHidden = false
                 self.resortView.backgroundColor = UIColor.white
                 self.resortView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width/2, height: self.view.frame.height - 44)
            }
             else {
                
                resortView.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.view.frame.height - (self.view.frame.height - self.bottomResortHeight))
            }
            
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
               
                layout.itemSize = CGSize(width:self.resortView.frame.width, height: self.view.frame.height/3)
                layout.scrollDirection = UICollectionViewScrollDirection.vertical
                resortCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.resortView.bounds.width, height:self.resortView.bounds.height), collectionViewLayout: layout)
            }
             else {
                
                layout.itemSize = CGSize(width:self.resortView.frame.width, height: self.resortView.frame.height)
                layout.scrollDirection = UICollectionViewScrollDirection.horizontal
                resortCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.resortView.bounds.width, height:self.resortView.bounds.height), collectionViewLayout: layout)
            }
            
           
            
            resortCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            resortCollectionView.backgroundColor = UIColor.clear
            resortCollectionView.delegate = self
            resortCollectionView.dataSource = self
            resortCollectionView.isPagingEnabled = true
            resortView.addSubview(resortCollectionView)
            
            /*** Subtracting tab bar default height - 49 ****/
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                    self.resortView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width/2, height: self.view.frame.height - 44)
                }
                else {
                    self.resortView.frame = CGRect(x: 0, y: self.view.frame.height - (self.bottomResortHeight), width: self.view.frame.width, height: self.bottomResortHeight)
                }
                
                
            }, completion: { _ in
                
            })
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                 self.view.addSubview(resortView)
            }
            else {
                
                let topSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                let bottomSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
                
                topSwipe.direction = .up
                bottomSwipe.direction = .down
                resortView.addGestureRecognizer(topSwipe)
                resortView.addGestureRecognizer(bottomSwipe)
                 self.view.addSubview(resortView)
                let indexPath = IndexPath(row: self.selectedIndex, section: 0)
                self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)

            }
            
           
        }
    }
    
    // ***** This method executes when we want to hide bottom resort view *****//
    func removeBottomView() {
        
        //self.selectedIndex = -1
        self.selectedIndex = 0

        for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
              
            selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
            selectedMarker.isFlat = false
            
        }
        self.gmsMapView.selectedMarker = nil
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                self.dragView.isHidden = false
                self.resortView.frame = CGRect(x: -self.view.frame.width/2, y: 44, width: self.view.frame.width/2, height: self.view.frame.height - 44)
                self.dragView.frame = CGRect(x: 0, y:self.dragView.frame.origin.y, width: self.dragView.frame.size.width, height: self.dragView.frame.size.height)
            }else {
                
                self.resortView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.bottomResortHeight)
                self.dragView.frame = CGRect(x: 0, y:self.dragView.frame.origin.y, width: self.dragView.frame.size.width, height: self.dragView.frame.size.height)
            }
            
            
        }, completion: { _ in
            
        })
        
    }
    
    // ***** Method to handle swipe gesture from bottom resort view *****//
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .up) {
            
               Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsArray[self.selectedIndex].resortCode!, viewcontroller: self)
 
        }
        else {
            self.removeBottomView()
        }
    }
    
    //***** This method executes when bottom resort view favorite button pressed *****//
    func bottomResortFavoritesButtonPressed(sender:UIButton) {
        
          if (sender.isSelected == false){
            
            SVProgressHUD.show()
            Helper.addServiceCallBackgroundView(view: self.view)
            UserClient.addFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
            
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
          else {
            
            SVProgressHUD.show()
            Helper.addServiceCallBackgroundView(view: self.view)
            UserClient.removeFavoriteResort(UserContext.sharedInstance.accessToken, resortCode: Constant.MyClassConstants.resortsArray[sender.tag].resortCode!, onSuccess: {(response) in
                
                sender.isSelected = false
                Helper.removeServiceCallBackgroundView(view: self.view)
                SVProgressHUD.dismiss()
                Constant.MyClassConstants.favoritesResortCodeArray.remove(Constant.MyClassConstants.resortsDescriptionArray.resortCode!)
                 self.resortCollectionView.reloadData()
                ADBMobile.trackAction(Constant.omnitureEvents.event51, data: nil)
            }, onError: {(error) in
                
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: self.view)
                print(error)
            })
            

        }
    }
    func doneButtonPressed(_ sender:UIBarButtonItem) {
        
           self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func drarButtonClicked(_ sender: Any) {
        
        
        if(self.dragView.frame.origin.x == 0) {

            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                self.resortView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width/2, height: self.view.frame.height - 44)
                self.dragView.frame = CGRect(x: self.resortView.frame.width, y:self.dragView.frame.origin.y, width:self.dragView.frame.size.width, height: self.dragView.frame.size.height)
            }, completion: { _ in
                
                self.drarButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.dragView.frame = CGRect(x: self.resortView.frame.width, y:self.dragView.frame.origin.y, width:self.dragView.frame.size.width, height: self.dragView.frame.size.height)
            })
            
        }
        else{

            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                
                self.resortView.frame = CGRect(x: -self.view.frame.width/2, y: 44, width: self.view.frame.width/2, height: self.view.frame.height - 44)
                self.dragView.frame = CGRect(x: 0, y:self.dragView.frame.origin.y, width: self.dragView.frame.size.width, height: self.dragView.frame.size.height)
                
            }, completion: { _ in
                
                self.drarButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
                self.dragView.frame = CGRect(x: 0, y:self.dragView.frame.origin.y, width:self.dragView.frame.size.width, height: self.dragView.frame.size.height)
            })
            
        }
    
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
                    self.selectedIndex = marker.userData as! Int

                    let indexPath = IndexPath(row: marker.userData as! Int, section: 0)
                    
                    if (UIDevice.current.userInterfaceIdiom == .pad) {
                        
                        
                        if(selectedIndex > marker.userData as! Int) {
                            self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
                        }
                        else {
                            self.resortCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
                        }

                        
                    } else {
                        
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
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
        self.view.bringSubview(toFront: self.containorView)
                       Helper.getResortWithResortCode(code: Constant.MyClassConstants.resortsArray[self.selectedIndex].resortCode!, viewcontroller: self)
        }
        
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
                if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {

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
        
        let resortNameGradientView = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.height - 73, width: cell.contentView.frame.width, height: 73))
        Helper.addLinearGradientToView(view: resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
        cell.addSubview(resortNameGradientView)
        
        let resortNameLabel = UILabel(frame: CGRect(x: 20, y: 0, width: cell.contentView.frame.width - 38, height: 38))
        resortNameLabel.numberOfLines = 0
        resortNameLabel.text = resort.resortName
        resortNameLabel.textColor = IUIKColorPalette.primary1.color
        resortNameLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
        resortNameGradientView.addSubview(resortNameLabel)
        
        let resortCountryLabel = UILabel(frame: CGRect(x: 20, y: 30, width: cell.contentView.frame.width - 20, height: 20))
        resortCountryLabel.text = resort.address?.cityName
        resortCountryLabel.textColor = UIColor.black
        resortCountryLabel.font = UIFont(name:Constant.fontName.helveticaNeue,size: 14)
        resortNameGradientView.addSubview(resortCountryLabel)
        
        let resortCodeLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 50, height: 20))
        resortCodeLabel.text = resort.resortCode
        resortCodeLabel.textColor = UIColor.orange
        resortCodeLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14)
        resortNameGradientView.addSubview(resortCodeLabel)
        
        if(resort.tier != nil){
            let tearImageView = UIImageView(frame: CGRect(x: 55, y: 52, width: 16, height: 16))
            let tierImageName = Helper.getTierImageName(tier: resort.tier!.uppercased())
            tearImageView.image = UIImage(named: tierImageName)
            resortNameGradientView.addSubview(tearImageView)
        }
        
        return cell
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visible: [AnyObject] = resortCollectionView.indexPathsForVisibleItems as [AnyObject]
        let indexpath: NSIndexPath = (visible[0] as! NSIndexPath)
        
        let index = indexpath.row
        self.selectedIndex = index
        for selectedMarker in Constant.MyClassConstants.googleMarkerArray {
            
            if(selectedMarker.userData as! Int == index) {
                
                selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinFocusImage)
                selectedMarker.isFlat = true
                self.gmsMapView.selectedMarker = selectedMarker
            }
            else {
                
                selectedMarker.icon = UIImage(named:Constant.assetImageNames.pinActiveImage)
                selectedMarker.isFlat = false
            }
        }
        
    }
    



}




