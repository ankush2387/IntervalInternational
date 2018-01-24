//
//  ResortDirectoryTabController.swift
//  IntervalApp
//
//  Created by Chetu on 08/06/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class ResortDirectoryTabController: UITabBarController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName: UIFont(name: Constant.fontName.helveticaNeue, size: 15)!, NSForegroundColorAttributeName: IUIKColorPalette.primary1.color]
        appearance.setTitleTextAttributes(attributes, for: UIControlState())

        //***** Handle hamberger menu button for prelogin and post login case *****//
        if((Session.sharedSession.userAccessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {

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

        } else {

            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(ResortDirectoryTabController.menuBackButtonPressed(_:)))
            menuButton.tintColor = UIColor.white
            self.tabBarController?.delegate = self
            self.navigationItem.leftBarButtonItem = menuButton

        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
//        //***** Register notification for this class to call the specific method when notification fired *****//
        //NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)

        if(Constant.MyClassConstants.sideMenuOptionSelected == Constant.MyClassConstants.favoritesFunctionalityCheck) {

            self.title = Constant.ControllerTitles.favoritesViewController
            self.selectedIndex = 2
        } else if(Constant.MyClassConstants.sideMenuOptionSelected == Constant.MyClassConstants.list) {
            self.selectedIndex = 1
        } else {
            if(Constant.MyClassConstants.runningFunctionality != Constant.MyClassConstants.resortFunctionalityCheck) {
                self.title = Constant.ControllerTitles.vacationSearchDestinationController
            } else {

                self.title = Constant.ControllerTitles.resortDirectoryViewController
                self.selectedIndex = 0

            }
        }
        if(Constant.RunningDevice.deviceIdiom == .phone) {
            UITabBar.appearance().barTintColor = IUIKColorPalette.titleBackdrop.color
            UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.white, size: CGSize(width: UIScreen.main.bounds.width / 3, height: tabBar.frame.height))
        }
        
        setUI()
    }
    
    private func setUI() {
    
        tabBar.items?.forEach { $0.title = nil }
        tabBar.items?[0].image = #imageLiteral(resourceName: "RD_Map_Blue")
        tabBar.items?[1].image = #imageLiteral(resourceName: "RD_List_Blue")
        tabBar.items?[2].image = #imageLiteral(resourceName: "RD_Fav_Blue")
    }
    
    //***** Remove added notifications. *****//
    override func viewWillDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
    }
    
    //***** Method called when navigaton back button pressed to dismis current controller from stack *****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func reloadSubview() {
        UITabBar.appearance().selectionIndicatorImage = nil
        
    }
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if(UIDeviceOrientationIsLandscape(UIDeviceOrientation.landscapeLeft)) {
            reloadSubview()
        }
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if(UIDeviceOrientationIsLandscape(UIDeviceOrientation.landscapeLeft)) {
            reloadSubview()
        }
    }
    
    //***** Method called when the added notification reloadFavoritesTab fired from other classes *****//
    func reloadView () {
        
        self.viewDidLoad()
    }
    
}

//***** Extension class for implementing tabbar delegate methods *****//
extension ResortDirectoryTabController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(item.tag == 0) {
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.map
            Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.resortFunctionalityCheck
            self.title = Constant.ControllerTitles.resortDirectoryViewController
        } else if(item.tag == 1) {
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.list
            Constant.MyClassConstants.resortDirectoryTitle = Constant.ControllerTitles.resortDirectoryViewController
            self.title = Constant.ControllerTitles.resortDirectoryViewController
            Helper.getResortDirectoryRegionList(viewController: self)
        } else {
            Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.favoritesFunctionalityCheck
            self.title = Constant.ControllerTitles.favoritesViewController
            if(Session.sharedSession.userAccessToken != nil) {
                
            } else {
                //self.performSegue(withIdentifier: Constant.segueIdentifiers.segueSignInForPreLogin, sender: self)
            }
        }
    }
}

//***** Extension class for creating custom image with color and size and return image *****//
extension UIImage {
    func makeImageWithColorAndSize(_ color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: 0.5)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
