//
//  UIViewControllerExtension.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 7/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension UIViewController: SWRevealViewControllerDelegate {
    //extension to Handle Tap Action to dismiss Nav Menu
    public func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            //hidden
            self.view.isUserInteractionEnabled = true
        }
        
        if position == FrontViewPosition.right {
            //visible, cancel userInteranction in ViewController's view and add tapGestureRecognizer on reveal controller frontViewController to handle Tap
            self.view.isUserInteractionEnabled = false
            revealController.frontViewController.view.addGestureRecognizer(revealController.tapGestureRecognizer())
        }
    }
}
