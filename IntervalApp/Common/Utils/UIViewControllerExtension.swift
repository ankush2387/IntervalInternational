//
//  UIViewControllerExtension.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 7/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

//extension to Handle Tap and swipe Actions to dismiss Nav Menu
extension UIViewController: SWRevealViewControllerDelegate {
    
    public func revealControllerPanGestureShouldBegin(_ revealController: SWRevealViewController!) -> Bool {
        revealController.quickFlickVelocity = 5000 //default value 250, changed to make swipe less sensitive
        return true
    }
    
    
    public func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            //hidden
            self.view.isUserInteractionEnabled = true
        }
        
        if position == FrontViewPosition.right {
            //visible, cancel userInteranction in ViewController's view and add tapGestureRecognizer on reveal controller frontViewController to handle Tap
            self.view.isUserInteractionEnabled = false
            revealController.frontViewController.view.addGestureRecognizer(revealController.tapGestureRecognizer())
            revealController.frontViewController.view.addGestureRecognizer(revealController.panGestureRecognizer())
        }
    }
}
