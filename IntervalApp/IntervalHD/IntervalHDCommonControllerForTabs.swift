//
//  IntervalHDCommonControllerForTabs.swift
//  IntervalApp
//
//  Created by Chetu on 13/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage

class IntervalHDCommonControllerForTabs: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var videoTBLView: UITableView!
    
    var searchResultArray = [Video]()
    
    override func viewWillAppear(_ animated: Bool) {
        
    // Handle hamburgur menu button for prelogin and post login case
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
            
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(menuBackButtonPressed))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.searchBar.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: 44)
        self.videoTBLView.frame = CGRect(x: videoTBLView.frame.origin.x, y: 108, width: videoTBLView.frame.width, height: self.videoTBLView.frame.height)
      
    }
    
    //***** Method for back button *****//
    func menuBackButtonPressed() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.searchBar.placeholder = Constant.MyClassConstants.searchPlaceHolder
        showHudAsync()
        if Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.magazinesFunctionalityCheck {
            Helper.getVideos(searchBy: Constant.MyClassConstants.areaString, senderViewcontroller: self)
            Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString, senderViewcontroller: self)
            Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString, senderViewcontroller: self)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVideos), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
    }
    
    func reloadVideos() {
        hideHudAsync()
        videoTBLView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func playButtonPressedAtIndex(sender: IUIKButton) {
        let video = Constant.MyClassConstants.intervalHDDestinations[sender.tag]
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.intervalHDIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.intervalHDPlayerViewController) as! IntervalHDPlayerViewController
        viewController.video = video
        self.present(viewController, animated: true, completion: nil)
    }
    
    //***** Notification to hit API when system access token gets available. *****//
    func getAllVideos() {
        
        if Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.magazinesFunctionalityCheck {
            
            Helper.getVideos(searchBy: Constant.MyClassConstants.areaString, senderViewcontroller: self)
            Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString, senderViewcontroller: self)
            Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString, senderViewcontroller: self)
        }
    }
}

//***** extension class to define tableview delegate methods *****//
extension IntervalHDCommonControllerForTabs: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //***** configure footerview for each section to show header labels *****//
        let  headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        return headerView
    }
}
//***** extension class to define tableview datasource methods *****//
extension IntervalHDCommonControllerForTabs: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.searchResultArray.count > 0 {
            return self.searchResultArray.count
        } else {
            var searchBarText = ""
            if let text = searchBar.text {
                searchBarText = text
            }
            if !searchBarText.isEmpty {
                return 0
            } else {
                switch tableView.tag {
                case 1:
                    return Constant.MyClassConstants.intervalHDDestinations.count
                case 2:
                     return Constant.MyClassConstants.intervalHDResorts.count
                default:
                    return Constant.MyClassConstants.intervalHDTutorials.count
                }
            }
        }
    }
    
    private func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 250
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.IntervalHDReusableIdentifiers.videoTBLCell, for: indexPath) as! VideoTBLCell
        
        cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.shadowView.layer.shadowColor = IUIKColorPalette.altState.color.cgColor
        cell.shadowView.layer.shadowRadius = 0.5
        cell.shadowView.layer.shadowOpacity = 1.0
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPath = UIBezierPath(rect: shadowFrame).cgPath
        cell.shadowView.layer.shadowPath = shadowPath
        cell.playButton.tag = indexPath.section
        cell.playButton.addTarget(self, action: #selector(playButtonPressedAtIndex), for: .touchUpInside)
        var video = Video()
        if !searchResultArray.isEmpty {
            video = self.searchResultArray[indexPath.section]
        } else {
            switch tableView.tag {
            case 1:
                video = Constant.MyClassConstants.intervalHDDestinations[indexPath.section]
            case 2:
                video = Constant.MyClassConstants.intervalHDResorts[indexPath.section]
            default:
                video = Constant.MyClassConstants.intervalHDTutorials[indexPath.section]
            }
        }
        
        cell.thumbnailimageView.backgroundColor = UIColor.lightGray
        cell.thumbnailimageView.setImageWith(URL(string: video.images[0].url ?? ""), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
            if error != nil {
                cell.thumbnailimageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                cell.thumbnailimageView.contentMode = .center
            }
        }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        cell.thumbnailimageView.contentMode = .scaleToFill
        cell.nameLabel.text = video.name
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return "123"
    }
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 30
    }
    
}

//***** Search bar delegate methods to handle the search bar actions *****//
extension IntervalHDCommonControllerForTabs: UISearchBarDelegate {
    
    //**** Search bar controller delegate ****//
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var videos = [Video]()
        switch videoTBLView.tag {
        case 1:
            videos = Constant.MyClassConstants.intervalHDDestinations
        case 2:
             videos = Constant.MyClassConstants.intervalHDResorts
        default:
             videos = Constant.MyClassConstants.intervalHDTutorials
        }
        self.searchResultArray = LookupClient.filterVideos(videos, searchText: searchBar.text!)
        self.videoTBLView.reloadData()
        
    }
}
