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

    let vacationVC = VacationSearchViewController()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Constant.ControllerTitles.vacationSearchTabBarController
        UITabBar.appearance().selectionIndicatorImage = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
}

//***** Extension class for tababar delegate method *****//

extension VacationSearchTabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items else { return }
        if items.index(of: item) == 0 {
            title = Constant.ControllerTitles.vacationSearchTabBarController
        } else {
            self.navigationItem.rightBarButtonItem = nil
            title = Constant.ControllerTitles.accomodationCertsDetailController
        }
    }
}
