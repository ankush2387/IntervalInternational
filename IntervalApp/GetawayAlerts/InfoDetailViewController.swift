//
//  InfoDetailViewController.swift
//  IntervalApp
//
//  Created by Chetu on 07/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class InfoDetailViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var resortDetailView: UIView!
    
    //****** class variables *****//
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[selectedIndex] as! NSArray
        
        var y = 60
        
        for resort in object {
            
            let rest  = resort as! Resort
            let bullet = UIView()
            if(Constant.RunningDevice.deviceIdiom == .pad){
                bullet.frame = CGRect(x: 60, y: y + 10, width: 6, height: 6)
            }else{
                bullet.frame = CGRect(x: 10, y: y + 10, width: 6, height: 6)
            }
            bullet.backgroundColor = UIColor.black
            bullet.layer.masksToBounds = true
            bullet.layer.cornerRadius = 3
            let nameLabel = UILabel()
            nameLabel.numberOfLines = 0
            if(Constant.RunningDevice.deviceIdiom == .pad){
                nameLabel.frame = CGRect(x: 80, y: y, width: 300, height: 25)
            }else{
                nameLabel.frame = CGRect(x: 25, y: y, width: Int(UIScreen.main.bounds.size.width - 50), height: 25)
            }
            
            nameLabel.text = rest.resortName
            
            self.resortDetailView.addSubview(bullet)
            self.resortDetailView.addSubview(nameLabel)
            y = y + Int(nameLabel.frame.height)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
