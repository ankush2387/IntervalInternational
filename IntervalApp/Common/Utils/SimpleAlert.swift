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
            if(title == "CheckOut"){
                sender.navigationController?.popViewController(animated: true)
            }
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
    
    static func searchAlert(_ sender:UIViewController, title:String, message:String ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var cancelTitle = "Cancel"
        var okTitle = "Ok"
        if(sender.isKind(of: GoogleMapViewController.self)){
            cancelTitle = Constant.AlertPromtMessages.no
            okTitle = Constant.AlertPromtMessages.yes
        }
        
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { (action:UIAlertAction!) in
        }
        
        let ok = UIAlertAction(title: okTitle, style:  .default){
            (action:UIAlertAction!) in
            
            if(sender.isKind(of: GoogleMapViewController.self)){
                (sender as! GoogleMapViewController).searchYesClicked()
            }else if(sender.isKind(of: WhoWillBeCheckingInViewController.self)){
                (sender as! WhoWillBeCheckingInViewController).noThanksPressed()
            }
            
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
