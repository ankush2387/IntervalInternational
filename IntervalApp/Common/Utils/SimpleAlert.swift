//
//  SimpleAlert.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class SimpleAlert : NSObject{
    
    static func alert(_ sender:UIViewController, title:String, message:String ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default) { (action:UIAlertAction!) in
            
        }
        //Add Custom Actions to Alert viewController
        alertController.addAction(ok)
        
        sender.present(alertController, animated: true, completion:nil)
    }
    
    static func alertTodismissController(_ sender:UIViewController, title:String, message:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default) { (action:UIAlertAction!) in
            
            if(sender.isKind(of:CreateAlertViewController.self)) {
                
                sender.dismiss(animated: true, completion: nil)
            }
            else if (sender.isKind(of:WhoWillBeCheckingInViewController.self) || sender.isKind(of:WhoWillBeCheckingInIPadViewController.self) || sender.isKind(of:CheckOutViewController.self) || sender.isKind(of:CheckOutIPadViewController.self)) {
                sender.dismiss(animated: true, completion: nil)
                _ = sender.navigationController?.popViewController(animated: true)
            }
            else if( sender .isKind(of:EditMyAlertIpadViewController.self)) {
                _ = sender.navigationController?.popViewController(animated: true)
            }
        }
        //Add Custom Actions to Alert viewController
        alertController.addAction(ok)
        
        sender.present(alertController, animated: true, completion:nil)
    }
    
    static func searchAlert(_ sender:GoogleMapViewController, title:String, message:String ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: Constant.AlertPromtMessages.no, style: .cancel) { (action:UIAlertAction!) in
        }
        
        let ok = UIAlertAction(title: Constant.AlertPromtMessages.yes, style:  .default){
            (action:UIAlertAction!) in
            sender.searchYesClicked()
        }
        //Add Custom Actions to Alert viewController
        alertController.addAction(cancel)
        alertController.addAction(ok)
        
        sender.present(alertController, animated: true, completion:nil)
    }
    
    static func touchAlert(_ sender:UIViewController, title:String, message:String ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: Constant.AlertPromtMessages.ok, style: .default) { (action:UIAlertAction!) in
        }
        //Code to display About Touch Id Action in AlertViewController
        let aboutTouchIdAction = UIAlertAction(title: Constant.AlertPromtMessages.aboutTouchId, style: .default) { (action) -> Void in
            
        }
        //Add Custom Actions to Alert viewController
        alertController.addAction(aboutTouchIdAction)
        alertController.addAction(ok)
        
        sender.present(alertController, animated: true, completion:nil)
    }
}
