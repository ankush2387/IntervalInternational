//
//  IntervalHDTabController.swift
//  IntervalApp
//
//  Created by Chetu on 13/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class IntervalHDTabController: UITabBarController {

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.intervalHDIpadControllerTitle
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: Constant.fontName.helveticaNeue, size: 15)!, NSForegroundColorAttributeName: UIColor.lightGray]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        
        let attributesHighlighted: [String: AnyObject] = [NSFontAttributeName:UIFont(name: Constant.fontName.helveticaNeue, size: 15)!, NSForegroundColorAttributeName: IUIKColorPalette.primary1.color]
        appearance.setTitleTextAttributes(attributesHighlighted, for: .selected)
        
        self.title = Constant.ControllerTitles.intervalHDIpadControllerTitle
        
        
        //***** handle hamberger menu button for prelogin and post login case *****//
        if((Session.sharedSession.userAccessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {
            
            if let rvc = self.revealViewController() {
                //set SWRevealViewController's Delegate
                rvc.delegate = self
                
                //***** Add the hamburger menu *****//
				let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
                menuButton.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = menuButton
                
                //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
                self.view.addGestureRecognizer( rvc.panGestureRecognizer())
            }
            
        }
        else {
            
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed(sender:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
        

    }
    override func viewWillAppear(_ animated: Bool) {
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
            UITabBar.appearance().barTintColor = IUIKColorPalette.titleBackdrop.color
			UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.white, size: CGSize(width:UIScreen.main.bounds.width/3, height:tabBar.frame.height))
            
        }
        self.navigationController?.isNavigationBarHidden = false

    }
   
    func menuBackButtonPressed(sender:UIBarButtonItem) {
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "PopToLoginView"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
