//
//  VacationSearchTabBarController.swift
//  IntervalApp
//
//  Created by Chetu-macmini-26 on 05/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import Realm

class VacationSearchTabBarController: UITabBarController {

    var moreButton:UIBarButtonItem?
    let vacationVC = VacationSearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.vacationSearchTabBarController
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
           UITabBar.appearance().selectionIndicatorImage = nil
      
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//***** Extension class for tababar delegate method *****//

extension VacationSearchTabBarController:UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(self.selectedIndex == 1) {
             self.title = Constant.ControllerTitles.vacationSearchTabBarController
            self.navigationItem.rightBarButtonItem = moreButton
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
            self.title = Constant.ControllerTitles.accomodationCertsDetailController
        }
    }
}
