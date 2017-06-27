//
//  IntervalHDIpadController.swift
//  IntervalApp
//
//  Created by Chetu on 14/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK

class IntervalHDIpadController: UIViewController {
    
    //***** Outlets *****//
    
    @IBOutlet weak var videoSeaarchBar: UISearchBar!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    
    var searchResutlArray = [Video]()
    var videoSegmentIndex = 0

    
    override func viewWillAppear(_ animated: Bool) {
       
        self.videoSeaarchBar.delegate = self
        self.videoSeaarchBar.placeholder = Constant.MyClassConstants.searchPlaceHolder
        
      //***** handle hamberger menu button for prelogin and post login case *****//
    if((UserContext.sharedInstance.accessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {
            
            if let rvc = self.revealViewController() {
                
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                self.view.addGestureRecognizer( rvc.panGestureRecognizer())
            }
            
        }else {
            
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(self.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
        self.videoCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.getVideos(searchBy: Constant.MyClassConstants.areaString)
        Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString)
        Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVideos), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getAllVideos), name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
        
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
        
    }
    
    //***** Notification after service is hit. *****//
    func reloadVideos(){
        videoCollectionView.reloadData()
    }
    
    //***** Notification to hit API when system access token gets available. *****//
    func getAllVideos(){
        Helper.getVideos(searchBy: Constant.MyClassConstants.areaString)
        Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString)
        Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString)
    }
    
    //***** function called when back button pressed on navigation bar *****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //***** function called when play button pressed on video *****//
    func playButtonPressedAtIndex(_ sender:IUIKButton) {

        let video = Constant.MyClassConstants.intervalHDDestinations![sender.tag]
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.intervalHDIpad, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.ControllerTitles.intervalHDiPadControllerTitle) as! IntervalHDPlayerViewController
        viewController.video = video
        self.present(viewController, animated: true, completion: nil)

    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
            self.videoCollectionView.collectionViewLayout.invalidateLayout()
            self.videoCollectionView.reloadData()
    }
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		if(self.videoCollectionView != nil){
         self.videoCollectionView.collectionViewLayout.invalidateLayout()
         self.videoCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


//***** MARK: Extension classes starts from here *****//

extension IntervalHDIpadController:UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		
	}
}

extension IntervalHDIpadController:UICollectionViewDataSource {
 
	//***** Collection dataSource methods definition here *****//
	
	func numberOfSections(in collectionView: UICollectionView) -> Int
	{
        return 1
    }
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.searchResutlArray.count > 0) {
            return self.searchResutlArray.count
        }
        else {
            
            if((self.videoSeaarchBar.text?.characters.count)! > 0) {
                
                return 0
            }
            else {
                
                if(collectionView.tag == 0 && Constant.MyClassConstants.intervalHDDestinations?.count != 0){
                    return (Constant.MyClassConstants.intervalHDDestinations?.count)!
                    
                }else if(collectionView.tag == 1 && Constant.MyClassConstants.internalHDResorts?.count != 0){
                    return (Constant.MyClassConstants.internalHDResorts?.count)!
                    
                }else if(collectionView.tag == 2 && Constant.MyClassConstants.internalHDTutorials?.count != 0){
                    
                    return (Constant.MyClassConstants.internalHDTutorials?.count)!
                }else{
                    return 0
                }

            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.IntervalHDReusableIdentifiers.intervalHDCollectionViewCell, for: indexPath as IndexPath) as! IntervalHDCollectionViewCell
        var video = Video()
        
        if(self.searchResutlArray.count > 0) {
            
             video = self.searchResutlArray[indexPath.item]
        }
        else {
            if(collectionView.tag == 0){
                video = Constant.MyClassConstants.intervalHDDestinations![indexPath.item]
            }else if(collectionView.tag == 1){
                video = Constant.MyClassConstants.internalHDResorts![indexPath.item]
            }else{
                video = Constant.MyClassConstants.internalHDTutorials![indexPath.item]
            }
        }
        cell.thumbnailImageView.backgroundColor = UIColor.lightGray
		
		cell.thumbnailImageView.setImageWith(URL(string: video.images[0].url!), completed: { (image:UIImage?, error:Swift.Error?, cacheType:SDImageCacheType, imageURL:URL?) in
			if (error != nil) {
				cell.thumbnailImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
			}
		}, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		
		cell.nameLabel.text = video.name
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(self.playButtonPressedAtIndex(_:)), for: .touchUpInside)
        return cell
    }
    
}

//***** Search bar delegate methods to handle the search bar actions *****//
extension IntervalHDIpadController:UISearchBarDelegate {
    
    //**** Search bar controller delegate ****//
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.videoSeaarchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.videoSeaarchBar.resignFirstResponder()
        self.videoSeaarchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var videos = [Any]()
        if(self.videoCollectionView.tag == 0) {
            videos = Constant.MyClassConstants.intervalHDDestinations!
        }
        else if(self.videoCollectionView.tag == 1) {
            videos = Constant.MyClassConstants.internalHDResorts!
        }
        else {
            videos = Constant.MyClassConstants.internalHDTutorials!
        }
       
        self.searchResutlArray = LookupClient.filterVideos(videos as! [Video], searchText: searchBar.text!)
        
        self.videoCollectionView.reloadData()
        
    }
}


