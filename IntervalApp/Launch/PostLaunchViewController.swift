//
//  PostLaunchViewController.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class PostLaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // TODO: Check Reachability
        
        // TODO: Check for "force upgrade"
        
        // TODO: Get the System Access Token
        
        // TODO: Check to see if we should present the onboarding views
        
        
        // Show the login view
        self.displayLogin()
    }
    
    
    func displayLogin()
    {
        // Go to device-specific login view
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.performSegue(withIdentifier: Constant.storyboardNames.loginIPad, sender: self)
        }
        else {
            self.performSegue(withIdentifier: Constant.storyboardNames.loginIPhone, sender: self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
