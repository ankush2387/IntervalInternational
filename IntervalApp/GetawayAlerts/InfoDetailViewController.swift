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
        
        /*let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[selectedIndex] as! NSArray
        
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
        }*/
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

//***** extensiion class to define tableview datasource methods *****//
extension InfoDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension InfoDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[0] as! NSArray
       // let count  = object as! Int
        //let resort = object[0] as! NSArray
        return object.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath as IndexPath) as! ResortInfoTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let object = Constant.MyClassConstants.selectedGetawayAlertDestinationArray[0] as! NSArray
        let resort = object[indexPath.row] as! Resort
        cell.resortInfoLabel.text =
            resort.resortName
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
