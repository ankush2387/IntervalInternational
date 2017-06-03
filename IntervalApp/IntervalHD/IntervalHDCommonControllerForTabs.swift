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
        
        //***** Handle hamburgur menu button for prelogin and post login case *****//
        if((UserContext.sharedInstance.accessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {
            
            if let rvc = self.revealViewController() {
                
                //***** Add the hamburger menu *****//
                let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                self.view.addGestureRecognizer( rvc.panGestureRecognizer())
            }
            
        }
        else {
            
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.searchBar.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: 44)
        self.videoTBLView.frame = CGRect(x: videoTBLView.frame.origin.x, y: 108, width: videoTBLView.frame.width, height:self.videoTBLView.frame.height)
      
    }
    
    //***** Method for back button *****//
    func menuBackButtonPressed() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.searchBar.placeholder = Constant.MyClassConstants.searchPlaceHolder
        if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.magazinesFunctionalityCheck){
        }else{
            Helper.getVideos(searchBy: Constant.MyClassConstants.areaString)
            Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString)
            Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVideos), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getAllVideos), name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
        
    }
    
    func reloadVideos(){
        videoTBLView.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func playButtonPressedAtIndex(sender:IUIKButton) {
        let video = Constant.MyClassConstants.intervalHDDestinations![sender.tag]
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.intervalHDIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.intervalHDPlayerViewController) as! IntervalHDPlayerViewController
        viewController.video = video
        self.present(viewController, animated: true, completion: nil)
    }
    
    //***** Notification to hit API when system access token gets available. *****//
    func getAllVideos(){
        
        if(Constant.MyClassConstants.runningFunctionality == Constant.MyClassConstants.magazinesFunctionalityCheck){
            
        }else{
            Helper.getVideos(searchBy: Constant.MyClassConstants.areaString)
            Helper.getVideos(searchBy: Constant.MyClassConstants.resortsString)
            Helper.getVideos(searchBy: Constant.MyClassConstants.tutorialsString)
        }
    }
    
}

//***** extension class to define tableview delegate methods *****//
extension IntervalHDCommonControllerForTabs:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //***** configure footerview for each section to show header labels *****//
        let  headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        
        return headerView
    }
    
}

//***** extension class to define tableview datasource methods *****//
extension IntervalHDCommonControllerForTabs:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(self.searchResultArray.count > 0) {
            
            return self.searchResultArray.count
        }
        else {
            
            if((self.searchBar.text?.characters.count)! > 0) {
                
                return 0
            }
            else {
                
                if(tableView.tag == 1) {
                    if(Constant.MyClassConstants.intervalHDDestinations!.count > 0){
                        return Constant.MyClassConstants.intervalHDDestinations!.count
                    }
                    else {
                        return 0
                    }
                }
                else if (tableView.tag == 2) {
                    return Constant.MyClassConstants.internalHDResorts!.count
                }
                else  {
                    return Constant.MyClassConstants.internalHDTutorials!.count
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
        if(self.searchResultArray.count > 0) {
            video = self.searchResultArray[indexPath.section]
        }
        else {
            if(tableView.tag == 1){
                video = Constant.MyClassConstants.intervalHDDestinations![indexPath.section]
            }else if(tableView.tag == 2){
                video = Constant.MyClassConstants.internalHDResorts![indexPath.section]
            }else{
                video = Constant.MyClassConstants.internalHDTutorials![indexPath.section]
            }
        }
        
        cell.thumbnailimageView.backgroundColor = UIColor.lightGray
        cell.thumbnailimageView.setImageWith(NSURL(string: video.images[0].url!) as URL!, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        cell.contentView.bringSubview(toFront: cell.playButton)
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
extension IntervalHDCommonControllerForTabs:UISearchBarDelegate {
    
    //**** Search bar controller delegate ****//
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
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
        if(self.videoTBLView.tag == 1) {
            videos = Constant.MyClassConstants.intervalHDDestinations!
        }
        else if(self.videoTBLView.tag == 2) {
            videos = Constant.MyClassConstants.internalHDResorts!
        }
        else {
            videos = Constant.MyClassConstants.internalHDTutorials!
        }
        
        self.searchResultArray = LookupClient.filterVideos(videos , searchText: searchBar.text!)
        
        self.videoTBLView.reloadData()
        
    }
}

