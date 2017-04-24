//
//  MagazinesIPadViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/16/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import SDWebImage
import DarwinSDK

class MagazinesIPadViewController: UIViewController {
    
    @IBOutlet weak var magazinesCollectionView: UICollectionView!
    var magazine = Magazine()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = Constant.ControllerTitles.magazinesControllerTitle
        
        //***** Handle hamburgur menu button for prelogin and post login case *****//
        if((UserContext.sharedInstance.accessToken) != nil && Constant.MyClassConstants.isLoginSuccessfull) {
            
            if let rvc = self.revealViewController() {
                
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
            //self.tabBarController?.delegate = self
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.getMagazines()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMagazines), name: NSNotification.Name(rawValue: Constant.notificationNames.magazineAlertNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getAllMagazines), name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
    }
    
    //**** Remove added observers ****//
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.magazineAlertNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.accessTokenAlertNotification), object: nil)
        
    }

    
    //***** Notification fired when response is obtained from service call *****//
    func reloadMagazines(){
        magazinesCollectionView.reloadData()
    }
    
    //***** Notification fired when system access token is received. *****//
    func getAllMagazines() {
        Helper.getMagazines()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailedVC = segue.destination as! DetailedIssueViewController
        detailedVC.issueUrl = magazine.url
        detailedVC.magazinTitile = "\(magazine.label!) \(magazine.year!)"
        
    }
    //***** Method for back button *****//
    func menuBackButtonPressed(sender:UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)

    }
    
}

//***** MARK: Extension classes starts from here *****//

extension MagazinesIPadViewController:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        magazine = Constant.MyClassConstants.magazinesArray![indexPath.item]
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showIssueSegue, sender: self)
        
    }
}
extension MagazinesIPadViewController:UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //return CGSizeMake(UIScreen.main.bounds.width/3-20,UIScreen.main.bounds.width/3+100)
        return CGSize(width:UIScreen.main.bounds.width/3-20, height:UIScreen.main.bounds.width/3+100)
    }
}

extension MagazinesIPadViewController:UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (Constant.MyClassConstants.magazinesArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.IntervalHDReusableIdentifiers.magazinesCell, for: indexPath as IndexPath) as! MagazineCollectionViewCell
        
        let magazine = Constant.MyClassConstants.magazinesArray![indexPath.item]
        cell.currentIssueView.layer.masksToBounds = true
        cell.currentIssueView.layer.cornerRadius = 35
        if(indexPath.row != 0) {
            cell.currentIssueView.isHidden = true
        }
        else {
            cell.currentIssueView.isHidden = false
        }
        cell.magazineImageView.backgroundColor = UIColor.lightGray
        
        cell.magazineImageView.setImageWith(NSURL(string: magazine.images[0].url!) as URL!, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        cell.magazineTitle.text = "\(magazine.label!) \(magazine.year!)"
        return cell
    }
}
