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
        self.videoSeaarchBar.placeholder = "Search".localized()
        
      //***** handle hamberger menu button for prelogin and post login case *****//
    if Session.sharedSession.userAccessToken != nil && Constant.MyClassConstants.isLoginSuccessfull {
            
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
            
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(self.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
        self.videoCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHudAsync()
        Helper.getVideos(searchBy: Constant.MyClassConstants.areaString, senderViewcontroller: self)
        Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString, senderViewcontroller: self)
        Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString, senderViewcontroller: self)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVideos), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
        
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
    }
    
    //***** Notification after service is hit. *****//
    func reloadVideos() {
        videoCollectionView.reloadData()
    }
    
    //***** Notification to hit API when system access token gets available. *****//
    func getAllVideos() {
        Helper.getVideos(searchBy: Constant.MyClassConstants.areaString, senderViewcontroller: self)
        Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString, senderViewcontroller: self)
        Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString, senderViewcontroller: self)
    }
    
    //***** function called when back button pressed on navigation bar *****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //***** function called when play button pressed on video *****//
    func playButtonPressedAtIndex(_ sender: IUIKButton) {

        let video = Constant.MyClassConstants.intervalHDDestinations[sender.tag]
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.intervalHDIpad, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.ControllerTitles.intervalHDiPadControllerTitle) as? IntervalHDPlayerViewController {
            viewController.video = video
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
            self.videoCollectionView.collectionViewLayout.invalidateLayout()
            self.videoCollectionView.reloadData()
    }
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		if videoCollectionView != nil {
         videoCollectionView.collectionViewLayout.invalidateLayout()
         videoCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
//***** MARK: Extension classes starts from here *****//

extension IntervalHDIpadController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
}

extension IntervalHDIpadController: UICollectionViewDataSource {
 
	//***** Collection dataSource methods definition here *****//
	func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !searchResutlArray.isEmpty {
            return self.searchResutlArray.count
        } else {
            var searchBarText = ""
            if let text = videoSeaarchBar.text {
                searchBarText = text
            }
            if !searchBarText.isEmpty {
                return 0
            } else {
                switch collectionView.tag {
                case 0:
                    return Constant.MyClassConstants.intervalHDDestinations.count
                case 1:
                    return Constant.MyClassConstants.intervalHDResorts.count
                default:
                    return Constant.MyClassConstants.intervalHDTutorials.count
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.IntervalHDReusableIdentifiers.intervalHDCollectionViewCell, for: indexPath as IndexPath) as? IntervalHDCollectionViewCell else { return UICollectionViewCell() }
        var video = Video()
        
        if !searchResutlArray.isEmpty {
            video = self.searchResutlArray[indexPath.item]
        } else {
            
            switch collectionView.tag {
            case 0:
                video = Constant.MyClassConstants.intervalHDDestinations[indexPath.item]
            case 1:
                video = Constant.MyClassConstants.intervalHDResorts[indexPath.item]
            default:
                 video = Constant.MyClassConstants.intervalHDTutorials[indexPath.item]
            }
        }
        cell.thumbnailImageView.backgroundColor = UIColor.lightGray
		
		cell.thumbnailImageView.setImageWith(URL(string: video.images[0].url ?? ""), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
			if error != nil {
				cell.thumbnailImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                cell.thumbnailImageView.contentMode = .center
			}
		}, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		cell.thumbnailImageView.contentMode = .scaleToFill
		cell.nameLabel.text = video.name
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(self.playButtonPressedAtIndex(_:)), for: .touchUpInside)
        return cell
    }
    
}

//***** Search bar delegate methods to handle the search bar actions *****//
extension IntervalHDIpadController: UISearchBarDelegate {
    
    //**** Search bar controller delegate ****//
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
        
        var videos = [Video]()
        switch videoCollectionView.tag {
        case 0:
            videos = Constant.MyClassConstants.intervalHDDestinations
        case 1:
            videos = Constant.MyClassConstants.intervalHDResorts
        default:
             videos = Constant.MyClassConstants.intervalHDTutorials
        }
        self.searchResutlArray = LookupClient.filterVideos(videos, searchText: searchBar.text!)
        self.videoCollectionView.reloadData()
        
    }
}
