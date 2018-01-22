//
//  ResortDirectoryViewController.swift
//  IntervalApp
//
//  Created by Chetu on 08/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage
import SVProgressHUD

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ResortDirectoryViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var resortTableView: UITableView!
    @IBOutlet weak var resortCollectionView: UICollectionView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var regionTableView: UITableView!
    
    //***** class variables *****//
    var resort = Resort()
    var notifiy: Bool = true
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.containerView != nil {
            self.containerView.isHidden = true
        }
        setNavigationBar()
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        getScreenFrameForOrientation()
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.view.tag == 3 {
            
            //***** register custom cell nib files to show data on tablevew with custom cell *****//
            resortTableView.register(UINib(nibName: Constant.customCellNibNames.searchResultContentTableCell, bundle: nil), forCellReuseIdentifier: Constant.customCellNibNames.searchResultContentTableCell)
        }
        
        func viewWillAppear(_ animated: Bool) {
            navigationController?.navigationBar.isHidden = false
        }
        
        if backgroundImageView != nil && Constant.MyClassConstants.resortDirectoryAreaListArray.count > 0 {
            
            if Constant.MyClassConstants.resortDirectoryAreaListArray[0].images.count > 0 {
                self.backgroundImageView.setImageWith(URL(string: Constant.MyClassConstants.resortDirectoryAreaListArray[0].images[1].url!), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                    if (error != nil) {
                        self.backgroundImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                
            }
        }
        
        if self.containerView != nil {
            
            self.containerView.isHidden = true
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.containerView.frame = CGRect(x: -self.containerView.frame.size.width, y: 64, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
            }, completion: { _ in
            })
            self.view.bringSubview(toFront: self.containerView)
        }
        Constant.MyClassConstants.resortDirectoryTitle = Constant.MyClassConstants.resortDirectoryTitle
        self.navigationItem.title = Constant.MyClassConstants.resortDirectoryTitle
        
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeue, size: 15)!, NSForegroundColorAttributeName: IUIKColorPalette.primary1.color]
        appearance.setTitleTextAttributes(attributes, for: UIControlState())
        setNavigationBar()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        self.view.subviews.last?.frame = CGRect(x: -(self.view.subviews.last?.frame.width)!, y: 64, width: (self.view.subviews.last?.frame.width)!, height: (self.view.subviews.last?.frame.height)!)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        //***** adding notifications so that it invock the specific method when the notification is fired *****//
        NotificationCenter.default.addObserver(self, selector: #selector(helpClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.showHelp), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadTableNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeButtonClicked), name: NSNotification.Name(rawValue: Constant.notificationNames.closeButtonClickedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRegionTable), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadRegionNotification), object: nil)
        setNavigationBar()
    }
    
    func setNavigationBar() {
        //***** handle hamberger menu button for prelogin and post login case *****//
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0 / 255, green: 119.0 / 255, blue: 190.0 / 255, alpha: 1.0)
      
        if Session.sharedSession.userAccessToken != nil && Constant.MyClassConstants.isLoginSuccessfull {
            if self.navigationController?.viewControllers.count > 1 {
                
                let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(ResortDirectoryViewController.menuBackButtonPressed(_:)))
                menuButton.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = menuButton
                
            } else {
                
                if let rvc = self.revealViewController() {
                    
                    //***** Add the hamburger menu *****//
                    let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
                    menuButton.tintColor = UIColor.white
                    self.navigationItem.leftBarButtonItem = menuButton
                    
                    //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                    self.view.addGestureRecognizer( rvc.panGestureRecognizer())
                    //Allow user to tap anywhere to dismiss reveal menu
                    self.view.addGestureRecognizer(rvc.tapGestureRecognizer())
                }
                
            }
            
        } else {
            
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(ResortDirectoryViewController.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
        }
        
        if resortTableView != nil {
            resortTableView.reloadData()
        } else if resortCollectionView != nil {
            resortCollectionView.reloadData()
        }
    }
    
    //*****Function for back button press.*****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {

        if self.navigationController?.viewControllers.count > 1 {
            
            self.navigationController?.popViewController(animated: true)
        } else {
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
        }
    }
    func reloadView() {
        if self.resortTableView != nil {
            if Constant.MyClassConstants.btnTag != -1 {
                addRemoveFavorite()
            }
            resortTableView.reloadData()
            setNavigationBar()
        }
    }
    
    func reloadTable() {
        
        self.view.tag = 3
        self.viewWillAppear(true)
        self.viewDidLoad()
        
    }
    
    // MARK: - Fuction to add remove favorite after Pre-Login
    func addRemoveFavorite() {
            guard let resortCode = Constant.MyClassConstants.resortDirectoryResortArray[Constant.MyClassConstants.btnTag].resortCode else { return }
            Constant.MyClassConstants.btnTag = -1
            let isFavorite = Helper.isResrotFavorite(resortCode: resortCode)
            let favoriteTempButton = UIButton()
            favoriteTempButton.isSelected = isFavorite
            favoriteButtonClicked(favoriteTempButton)
    }
    
    //***** method called when login help button pressed and redirect to webview *****//
    func helpClicked() {
        
        Constant.MyClassConstants.requestedWebviewURL = ""
        Constant.MyClassConstants.webviewTtile = ""
        
        Constant.MyClassConstants.webviewTtile = Constant.ControllerTitles.loginHelpViewController
        Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.loginHelpURL
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.loginIPhone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.webViewController)
        
        //***** Creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        self.navigationController?.setViewControllers([viewController], animated: false)
    }
    
    //***** Function is called when done button is clicked in details side menu *****/
    func closeButtonClicked() {
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            (self.view.subviews.last?.frame = CGRect(x: -(self.view.subviews.last?.frame.width)!, y: 64, width: (self.view.subviews.last?.frame.width)!, height: (self.view.subviews.last?.frame.height)!))!
            
        }, completion: { _ in
            self.view.subviews.last?.isHidden = true
        })
    }
    
    //***** Notification to load list of available regions *****//
    func reloadRegionTable() {
        
        for tblVw in self.view.subviews {
            if tblVw.isKind(of: UITableView.self) {
                let regionTable: UITableView = tblVw as! UITableView
                regionTable.isHidden = false
                regionTable.reloadData()
            }
        }
        
    }
    
    //***** Notification to show region details. *****//
    func showAreaDetails() {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.areaSegue, sender: nil)
        
    }
    
    //***** method to check device orientation for ipad *****//
    func getScreenFrameForOrientation() {
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            Constant.RunningDevice.deviceOrientation = UIDeviceOrientation.landscapeLeft
        } else {
            
            Constant.RunningDevice.deviceOrientation = UIDeviceOrientation.portrait
        }
        if resortTableView != nil && self.containerView != nil {
            
            self.containerView.isHidden = true
            resortTableView.reloadData()
        }
        if childViewControllers.count > 0 {
            let containerVC = self.childViewControllers[0] as! ResortDetailsViewController
            containerVC.senderViewController = Constant.MyClassConstants.searchResult
            containerVC.viewWillAppear(true)
        }
    }
    
    //***** overriding storyboard segue methods *****//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constant.segueIdentifiers.resortDetailsSegue {
            let setVC = ResortDetailsViewController()
            setVC.senderViewController = Constant.MyClassConstants.searchResult
        } else if segue.identifier == Constant.segueIdentifiers.resortByAreaSegue {
            
        }
    }
    
    func favoriteButtonClicked(_ sender: UIButton) {
        guard let resortCode = Constant.MyClassConstants.resortDirectoryResortArray[sender.tag].resortCode else { return }
        if Session.sharedSession.userAccessToken != nil {
            
            if !sender.isSelected {
                showHudAsync()
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode:resortCode, onSuccess: { response in
                    intervalPrint(response)
                    self.hideHudAsync()
                    sender.isSelected = true
                    Constant.MyClassConstants.favoritesResortCodeArray.add(resortCode)
                    self.resortTableView.reloadData()
                    
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    intervalPrint(error)
                })
            } else {
                
                showHudAsync()
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { response in
                    intervalPrint(response)
                    sender.isSelected = false
                    self.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
                    self.resortTableView.reloadData()
                    
                }, onError: { [weak self] error in
                    self?.hideHudAsync()
                    intervalPrint(error)
                })
                
            }
        } else {
            Constant.MyClassConstants.btnTag = sender.tag
            self.performSegue(withIdentifier: Constant.segueIdentifiers.preLoginSegue, sender: nil)
        }
    }
    
}

//***** extension class to define tableview delegate methods *****//
extension ResortDirectoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Constant.MyClassConstants.btnTag = -1
        switch tableView.tag {
        case 0 :
            let region = Constant.MyClassConstants.resortDirectoryRegionArray[indexPath.row]
            Constant.MyClassConstants.resortDirectoryCommonHearderText = region.regionName!
            
            if region.regions.count > 0 {
                Constant.MyClassConstants.resortDirectorySubRegionArray = region.regions
                
                self.performSegue(withIdentifier: Constant.segueIdentifiers.subRegionSegue, sender: nil)
            } else {
                
                showHudAsync()
                DirectoryClient.getAreasByRegion(Constant.MyClassConstants.systemAccessToken, regionCode: region.regionCode, onSuccess: {(response) in
                    self.hideHudAsync()
                    Constant.MyClassConstants.resortDirectoryAreaListArray = response
                    self.showAreaDetails()
                    Helper.trackOmnitureCallForPageView(name: "\(Constant.MyClassConstants.resortDirectoryTitle) \(region.regionName!)")
                    
                }, onError: {(_) in
                    self.hideHudAsync()
                })
            }
        case 1 :
            
            showHudAsync()
            let subregion = Constant.MyClassConstants.resortDirectorySubRegionArray[indexPath.row]
            Constant.MyClassConstants.resortDirectoryCommonHearderText = subregion.regionName!
            
            DirectoryClient.getAreasByRegion(Constant.MyClassConstants.systemAccessToken, regionCode: subregion.regionCode, onSuccess: {(response) in
                
                self.hideHudAsync()
                Constant.MyClassConstants.resortDirectoryAreaListArray = response
                self.showAreaDetails()
                Helper.trackOmnitureCallForPageView(name: "\(Constant.MyClassConstants.resortDirectoryTitle) \(subregion.regionName!)")
                
            }, onError: {(_) in
                self.hideHudAsync()
            })
            
        case 2 :
            
            let area = Constant.MyClassConstants.resortDirectoryAreaListArray[indexPath.row]
            Constant.MyClassConstants.resortDirectoryCommonHearderText = area.areaName!
            if area.images.count > 0 && backgroundImageView != nil {
                
                Constant.MyClassConstants.backgroundImageUrl = area.images[1].url!
                self.backgroundImageView.setImageWith(URL(string: area.images[1].url!), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                    if error != nil {
                        self.backgroundImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    }
                    
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                
            }
            
            showHudAsync()
            DirectoryClient.getResortsByArea(Constant.MyClassConstants.systemAccessToken, areaCode: area.areaCode, onSuccess: {(response) in
                Constant.MyClassConstants.resortDirectoryResortArray = response
                
                self.hideHudAsync()
                Helper.trackOmnitureCallForPageView(name: "\(Constant.MyClassConstants.resortDirectoryTitle) \(area.areaName!)")
                self.performSegue(withIdentifier: Constant.segueIdentifiers.resortByAreaSegue, sender: nil)
                
            }, onError: {(_) in
                self.hideHudAsync()
            })
        case 3 :
            
            if Constant.MyClassConstants.systemAccessToken != nil {
                resort = Constant.MyClassConstants.resortDirectoryResortArray[indexPath.row]
                let selectedResort = Constant.MyClassConstants.resortDirectoryResortArray[indexPath.row]
                showHudAsync()
                //***** Favorites resort API call after successfull call *****//
                Constant.MyClassConstants.isFromSearchResult = false
                Helper.getUserFavorites {[unowned self] error in
                    if case .some = error {
                        self.presentAlert(with: "Error".localized(), message: error?.localizedDescription ?? "")
                    }
                }
                if selectedResort.resortCode != nil {
                    
                    Helper.getResortWithResortCode(code: selectedResort.resortCode!, viewcontroller: self)
                }
            }
        case 5 :
            let containerView = UIView()
            containerView.frame = CGRect(x: 0, y: 0, width: 200, height: 568)
            self.view.addSubview(containerView)
            
            let storyboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
            let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortDirectoryVCTitle) as UIViewController
            containerView.addSubview(controller.view)
            self.addChildViewController(controller)
        default :
            return
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //***** configure header cell for each section to show header labels *****//
        let  headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        let nameLabel = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.bounds.width - 40, height: 30))
        
        if tableView.tag == 0 {
            nameLabel.text = "Choose Region"
            nameLabel.textColor = IUIKColorPalette.secondaryText.color
            headerView.addSubview(nameLabel)
        } else {
            nameLabel.text = Constant.MyClassConstants.resortDirectoryCommonHearderText
            nameLabel.textColor = IUIKColorPalette.secondaryText.color
            headerView.addSubview(nameLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 3 {
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                
                return 450
                
            } else {
                
                return 256
            }
        } else if tableView.tag == 4 {
            
            if indexPath.row == 0 {
                
                return 450
            } else {
                var count: CGFloat = 0
                if Constant.MyClassConstants.resortDirectoryResortArray.count % 2 == 0 {
                    count = CGFloat(Constant.MyClassConstants.resortDirectoryResortArray.count / 2)
                } else {
                    count = CGFloat(Constant.MyClassConstants.resortDirectoryResortArray.count / 2 + 1)
                }
                var height: CGFloat!
                height = (tableView.frame.size.width - 10) / 2
                
                return CGFloat(count * height)
            }
        } else {
            
            return 50
        }
    }
}

//***** extension class to define tableview datasource methods *****//
extension ResortDirectoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0 :
            return Constant.MyClassConstants.resortDirectoryRegionArray.count
        case 1 :
            return Constant.MyClassConstants.resortDirectorySubRegionArray.count
        case 2 :
            return Constant.MyClassConstants.resortDirectoryAreaListArray.count
        case 4 :
            return 2
        default :
            return Constant.MyClassConstants.resortDirectoryResortArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 4 {
            
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reUsableIdentifiers.favoritesCellIdentifier, for: indexPath) as? ResortFavoritesTableViewCell else { return UITableViewCell() }
                cell.delegate = self
                
                for layer in cell.backgroundNameView.layer.sublayers! {
                    if layer.isKind(of: CAGradientLayer.self) {
                        layer.removeFromSuperlayer()
                    }
                }
                cell.backgroundNameView.backgroundColor = UIColor.clear
                let frame = CGRect(x: 0, y: 0, width: view.frame.size.width + 300, height: cell.backgroundNameView.frame.size.height)
                cell.backgroundNameView.frame = frame
                Helper.addLinearGradientToView(view: cell.backgroundNameView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
                cell.resortAreaName.frame = frame
                cell.resortAreaName.text = Constant.MyClassConstants.resortDirectoryTitle
                cell.resortDescription.frame = frame
                cell.resortDescription.text = Constant.MyClassConstants.resortDescriptionString
                if cell.favoritesCollectionView != nil {
                    cell.favoritesCollectionView.reloadData()
                }
                
                if resort.images.count > 0 {
                    cell.imageViewTop.setImageWith(URL(string: Constant.MyClassConstants.backgroundImageUrl as String), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                        if error != nil {
                            cell.imageViewTop.image = UIImage(named: Constant.MyClassConstants.noImage)
                        }
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                }
                return cell
                
            } else {
                
                resort = Constant.MyClassConstants.resortDirectoryResortArray[indexPath.row - 1]
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.resortDirectoryResortCell, for: indexPath) as? ResortFavoritesTableViewCell else { return UITableViewCell() }
                cell.favoritesCollectionView.reloadData()
                cell.delegate = self
                
                return cell
            }
        } else if tableView.tag == 3 {
            
            resort = Constant.MyClassConstants.resortDirectoryResortArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.searchResultContentTableCell, for: indexPath) as? SearchResultContentTableCell else { return UITableViewCell() }
            
            for layer in cell.resortNameGradientView.layer.sublayers! {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
            let frame = CGRect(x: 0, y: 0, width: view.frame.size.width + 300, height: cell.resortNameGradientView.frame.size.height)
            cell.resortNameGradientView.frame = frame
            Helper.addLinearGradientToView(view: cell.resortNameGradientView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.backgroundColor = IUIKColorPalette.contentBackground.color
            
            let status = Helper.isResrotFavorite(resortCode: resort.resortCode!)
            if status {
                cell.favoriteButton.isSelected = true
            } else {
                cell.favoriteButton.isSelected = false
            }
            cell.favoriteButton.tag = indexPath.row
            let tierImageName = Helper.getTierImageName(tier: resort.tier!.uppercased())
            cell.tierImageView.image = UIImage(named: tierImageName)
            
            if resort.images.count > 0 {
                
                if let stirngUrl = resort.images[2].url {
                    let url = URL(string: stirngUrl)
                    cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                } else {
                    
                }
            }
            cell.resortName.textColor = IUIKColorPalette.primary1.color
            cell.resortName.text = resort.resortName
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonClicked(_:)), for: .touchUpInside)
            
            cell.resortCountry.text = [resort.address?.cityName, resort.address?.territoryCode.unwrappedString.stateForTerritoryCode].flatMap { $0 }.joined(separator: ", ")
            cell.resortCode.text = resort.resortCode
            return cell
            
        }
        
        if tableView.tag == 2 {
            
            let area = Constant.MyClassConstants.resortDirectoryAreaListArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.resortDirectoryTBLCell, for: indexPath) as! ResortDirectoryTBLCell
            
            cell.regionNameLabel.text = area.areaName
            return cell
        }
        if tableView.tag == 1 {
            
            let region = Constant.MyClassConstants.resortDirectorySubRegionArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.resortDirectoryTBLCell, for: indexPath) as! ResortDirectoryTBLCell
            
            cell.regionNameLabel.text = region.regionName
            return cell
        } else {
            
            let region = Constant.MyClassConstants.resortDirectoryRegionArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.resortDirectoryTBLCell, for: indexPath) as? ResortDirectoryTBLCell else { return UITableViewCell() }
            cell.regionNameLabel.text = region.regionName
            return cell
        }
        
    }
}

//***** extension class to define custom cell delegate methods *****//
extension ResortDirectoryViewController: ResortDirectoryResortCellDelegate {
    
    func favoritesButtonSelectedAtIndex(_ index: Int) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
        let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginController) as? SignInPreLoginViewController
        let navController = UINavigationController(rootViewController: resultController!)
        self.present(navController, animated: true, completion: nil)
        
    }
}

//***** Extension to show side view  with container in iPad. *****.//
extension ResortDirectoryViewController: ResortFavoritesTableViewCellDelegate {
    
    func showResortDetails(_ index: Int) {
        
        Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortDirectoryResortArray[index]
        
        Constant.MyClassConstants.resortDescriptionString = Constant.MyClassConstants.resortDirectoryResortArray[index].description ?? ""
        
        if self.containerView != nil {
            
            self.containerView.isHidden = false
            self.containerView.bringSubview(toFront: self.containerView)
            let selectedResort = Constant.MyClassConstants.resortDirectoryResortArray[index]
            
            UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                (self.view.subviews.last?.frame = CGRect(x: 0, y: 64, width: (self.view.subviews.last?.frame.width)!, height: (self.view.subviews.last?.frame.height)!))!
                
            }, completion: { _ in
                if let resortCode = selectedResort.resortCode {
                    //self.callAPI(selectedResort.resortCode!)
                    Helper.getResortWithResortCode(code: resortCode, viewcontroller: self)
                }
                
            })
            
        }
    }
    func favoritesResortSelectedAtIndex(_ index: Int, signInRequired: Bool, isFavorite: Bool) {
        Constant.MyClassConstants.btnTag = index
        if signInRequired {
            let mainStoryboard = UIStoryboard(name: Constant.storyboardNames.resortDirectoryIpad, bundle: nil)
            guard let resultController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardNames.signInPreLoginViewControlleriPad) as? SignInPreLoginViewController else { return }
            navigationController?.pushViewController(resultController, animated: true)
        } else {
            guard let resortCode = Constant.MyClassConstants.resortDirectoryResortArray[index].resortCode else { return }
             showHudAsync()
            if !isFavorite {
                UserClient.addFavoriteResort(Session.sharedSession.userAccessToken, resortCode:resortCode, onSuccess: { [weak self]  in
                    guard let strongSelf = self else { return }
                    strongSelf.hideHudAsync()
                }, onError: { [weak self] error in
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                    self?.hideHudAsync()
                })
                
            } else {
                
                UserClient.removeFavoriteResort(Session.sharedSession.userAccessToken, resortCode: resortCode, onSuccess: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.hideHudAsync()
                    Constant.MyClassConstants.favoritesResortCodeArray.remove(resortCode)
    
                }, onError: {[weak self] error in
                    self?.hideHudAsync()
                    self?.presentErrorAlert(UserFacingCommonError.handleError(error))
                })
                
            }
        }
    }
}
