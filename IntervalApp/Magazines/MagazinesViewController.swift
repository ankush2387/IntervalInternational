//
//  MagazinesViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import SDWebImage
import DarwinSDK
import IntervalUIKit

class MagazinesViewController: UIViewController {
    
    
    @IBOutlet weak var magazinesTBLView: UITableView!
    
    
    var magazine = Magazine()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = Constant.ControllerTitles.magazinesControllerTitle
        
        //***** Handle hamburgur menu button for prelogin and post login case *****//
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
            
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHudAsync()
        Helper.getMagazines(senderViewController: self)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMagazines), name: NSNotification.Name(rawValue: Constant.notificationNames.magazineAlertNotification), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(getAllMagazines), name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    //reloadMagazines
    func reloadMagazines(){
        magazinesTBLView.reloadData()
    }
    
    //reload Magazines
    func getAllMagazines(){
        Helper.getMagazines(senderViewController: self)
    }
    
    //***** Method for back button *****//
    func menuBackButtonPressed() {
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
    }
    
    func playTapped() {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailedVC = segue.destination as! DetailedIssueViewController
        detailedVC.issueUrl = magazine.url
        let magazineTitle = magazine.label!
       // magazineTitle = "\(String(describing: magazineTitle)) \(magazine.year!)"
        detailedVC.magazinTitile = magazineTitle
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//***** extension class to define tableview datasource methods *****//
extension MagazinesViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return (Constant.MyClassConstants.magazinesArray!.count)
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UIScreen.main.bounds.width + 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.IntervalHDReusableIdentifiers.magazinesCell, for: indexPath as IndexPath) as! MagazineTableViewCell
       
        magazine = Constant.MyClassConstants.magazinesArray![indexPath.section]
        
        //adding show on magazines list view
        cell.shadowView.layer.shadowColor = IUIKColorPalette.altState.color.cgColor
        cell.shadowView.layer.shadowOpacity = 1
        cell.shadowView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        cell.shadowView.layer.shadowRadius = 5
        cell.shadowView.layer.shadowPath = UIBezierPath(rect: cell.shadowView.bounds).cgPath
        cell.shadowView.layer.shouldRasterize = true
        
        let currentIssueView = UILabel()
        currentIssueView.text = Constant.MyClassConstants.currentIssue
        currentIssueView.numberOfLines = 2
        currentIssueView.textAlignment = NSTextAlignment.center
        currentIssueView.textColor = UIColor.white
        currentIssueView.frame = CGRect(origin: CGPoint(x: 0,y :cell.contentView.bounds.height-150), size: CGSize(width: 70, height: 70))
        currentIssueView.layer.cornerRadius = 35
        currentIssueView.clipsToBounds = true
        currentIssueView.backgroundColor = UIColor.orange
        cell.contentView.addSubview(currentIssueView)
        
        if(indexPath.section != 0){
            currentIssueView.removeFromSuperview()
        }
        
        
        cell.magazineImageView.backgroundColor = UIColor.lightGray
        cell.magazineImageView.setImageWith(NSURL(string: magazine.images[0].url!) as URL!, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        var magazineTitle = magazine.label
        magazineTitle = magazineTitle?.appending(" ")
        magazineTitle = "\(magazineTitle!) \(magazine.year!)"
        cell.magazineTitle.text = magazineTitle
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //just return dummy text to overload this methods to show footer
        return " "
    }

    
     private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //***** configure footerview for each section to show header labels *****//
        let  footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        footerView.backgroundColor = UIColor.white
        
        return footerView

    }
    
     private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
        return 30
    }
    
}

extension MagazinesViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        magazine = Constant.MyClassConstants.magazinesArray![indexPath.section]
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showIssueSegue, sender: self)
    }
    
}


