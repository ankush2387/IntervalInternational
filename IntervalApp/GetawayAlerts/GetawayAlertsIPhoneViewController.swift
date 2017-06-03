//
//  GetawayAlertsiPhoneViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 8/16/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit
import SVProgressHUD

class GetawayAlertsIPhoneViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var alertDisplayTableView: UITableView!
    
    private var alertsDictionary:NSMutableDictionary = [:]
    var alertsSearchDates:NSMutableDictionary = [:]
    private var alertsResortCodeDictionary:NSMutableDictionary = [:]
    var alertName : String!
    var alertId : Int64!
    var alertStatusId = 0
    
    override func viewWillAppear(_ animated: Bool) {
        
        //***** Adding notification to reload table when all alerts have been fetched *****//
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAlertsTableView), name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
        alertDisplayTableView.reloadData()
    }
    
    //***** Function for notification for all alerts *****//
    
    func reloadAlertsTableView(){
        alertDisplayTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***** Set general Nav attributes *****//
        self.title = Constant.ControllerTitles.getawayAlertsViewController
        
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = self.revealViewController() {
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            
            
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** creating and adding right bar button for more option button *****//
            let moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(moreNavButtonPressed(sender:)))
            moreButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = moreButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constant.segueIdentifiers.editAlertSegue){
            let viewController = segue.destination as! EditMyAlertIpadViewController
            viewController.editAlertName = self.alertName
            viewController.alertId = self.alertId
        }
    }
    
    //**** Function for vacation search for an alert ****//
    
    //**** Function for more button action ****//
    func moreNavButtonPressed(sender:UIBarButtonItem){
        
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.getwayAlertOptions, message: "", preferredStyle: .actionSheet)
        
        let attributedText = NSMutableAttributedString(string: Constant.buttonTitles.getwayAlertOptions)
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name: Constant.fontName.helveticaNeueMedium, size: 16.0)!, range: range)
        actionSheetController.setValue(attributedText, forKey: Constant.actionSheetAttributedString.attributedTitle)
        //***** Create and add the View my recent search *****//
        let searchAllMyAlertsNow: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.searchAllMyAlertsNow, style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.alertDisplayTableView.reloadData()
        }
        actionSheetController.addAction(searchAllMyAlertsNow)
        //***** Create and add the Reset my search *****//
        let aboutGetawayAlerts: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.aboutGetawayAlerts, style: .default) { action -> Void in
            
        }
        actionSheetController.addAction(aboutGetawayAlerts)
        //***** Create and add help *****//
        let helpAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.help, style: .default) { action -> Void in
        }
        actionSheetController.addAction(helpAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        if(Constant.RunningDevice.deviceIdiom == .pad){
            
            actionSheetController.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.size.width,y:0, width:100, height:60)
            actionSheetController.popoverPresentationController!.permittedArrowDirections = .up;
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    //***** Create a new alert button action. *****//
    @IBAction func createNewAlertButtonPressed(_ sender: AnyObject){
        self.alertDisplayTableView.setEditing(false, animated: true)
        Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
        self.performSegue(withIdentifier: Constant.segueIdentifiers.createAlertSegue, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***** Function called when nothing yet button for an alert is clicked. *****//
    func nothingYetClicked(){
        
        let alertController = UIAlertController(title: title, message: Constant.AlertErrorMessages.getawayAlertMessage, preferredStyle: .alert)
        
        var mainStoryboard = UIStoryboard()
        let startSearch = UIAlertAction(title: Constant.AlertPromtMessages.newSearch, style: .default) { (action:UIAlertAction!) in
            
            if(Constant.RunningDevice.deviceIdiom == .pad){
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            }else{
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            }
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
            
            //***** Creating animation transition to show custom transition animation *****//
            let transition: CATransition = CATransition()
            let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.duration = 0.25
            transition.timingFunction = timeFunc
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
        let close = UIAlertAction(title: Constant.AlertPromtMessages.close, style: .default) { (action:UIAlertAction!) in
            
        }
        
        //Add Custom Actions to Alert viewController
        alertController.addAction(startSearch)
        alertController.addAction(close)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    
    //***** Function called when view results for an active alerts is clicked ****//
    func viewResultsClicked(_ sender:AnyObject) {
        
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.getawayAlerts
        Constant.MyClassConstants.resortCodesArray = Constant.MyClassConstants.alertsResortCodeDictionary.value(forKey: String(sender.tag)) as! [String]
        Constant.MyClassConstants.checkInDates = self.alertsSearchDates.value(forKey: String(sender.tag)) as! [Date]
        Constant.MyClassConstants.resortsArray.removeAll()
        Constant.MyClassConstants.searchResultCollectionViewScrollToIndex = 1
        
        SVProgressHUD.show()
        let checkInDates:NSArray = self.alertsSearchDates.value(forKey: String(sender.tag)) as! NSArray
        if(checkInDates.count > 0){
        
        Constant.MyClassConstants.currentFromDate = checkInDates[0] as! Date
        }else{
           Constant.MyClassConstants.currentFromDate =  Date()
        }
        Helper.resortDetailsClicked(toDate: checkInDates[0] as! NSDate, senderVC: self)
    }
}

extension GetawayAlertsIPhoneViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here. *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: Constant.buttonTitles.remove) { (action,index) -> Void in
            Constant.MyClassConstants.getawayAlertsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                tableView.reloadSections(NSIndexSet(index:indexPath.section) as IndexSet, with: .automatic)
            })
        }
        delete.backgroundColor = UIColor(red: 224/255.0, green: 96.0/255.0, blue: 84.0/255.0, alpha: 1.0)
        
        if(!Constant.MyClassConstants.getawayAlertsArray[indexPath.row].enabled!){
            let activate = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.activate) { (action,index) -> Void in
                
            }
            activate.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            return [delete,activate]
            
        }else{
            
            let edit = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: Constant.buttonTitles.edit) { (action,index) -> Void in
                
                Constant.MyClassConstants.selectedGetawayAlertDestinationArray.removeAllObjects()
        
                let destination = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].destinations
                for dest in destination {
                    
                    Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(dest)
                }
                let resorts = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].resorts
                for resort in resorts {
                    
                    Constant.MyClassConstants.selectedGetawayAlertDestinationArray.add(resort)
                }
                
                self.alertName = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name
                self.alertId = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId
//               Constant.MyClassConstants.alertWindowStartDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].earliestCheckInDate
//               Constant.MyClassConstants.alertWindowStartDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].latestCheckInDate
                Constant.MyClassConstants.bedRoomSizeSelectedIndexArray.removeAllObjects()
                self.performSegue(withIdentifier: Constant.segueIdentifiers.editAlertSegue, sender: self)
                
            }
            edit.backgroundColor = UIColor(red: 0/255.0, green: 119.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            return [delete,edit]
        }
    }
}

extension GetawayAlertsIPhoneViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.MyClassConstants.getawayAlertsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.getawayScreenReusableIdentifiers.getawayAlertCell, for: indexPath as IndexPath) as! AlertTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.alertNameLabel.text = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].name
        
        let fromDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].earliestCheckInDate!

        let toDate = Constant.MyClassConstants.getawayAlertsArray[indexPath.row].latestCheckInDate!
        
        let dateRange = fromDate.appending(" - " + toDate)
        
        cell.alertDateLabel.text = dateRange
        
       
        if(Constant.MyClassConstants.getawayAlertsArray[indexPath.row].enabled)!{
            cell.alertStatusButton.isHidden = true
            cell.alertStatusButton.backgroundColor = UIColor(red: 240.0/255.0, green: 111.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            cell.alertStatusButton.setTitleColor(UIColor.white, for: .normal)
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }else{
            cell.alertStatusButton.isHidden = false
            cell.activityIndicator.isHidden = true
        }
        
        cell.alertStatusButton.tag = Int(Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId!)
        let value = Constant.MyClassConstants.alertsSearchDatesDictionary.value(forKey: String(describing: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId!))
        if(value != nil){
        var checkInDates = NSArray()
        if(Constant.MyClassConstants.alertsSearchDatesDictionary.count > 0){
           checkInDates = Constant.MyClassConstants.alertsSearchDatesDictionary.value(forKey: String(describing: Constant.MyClassConstants.getawayAlertsArray[indexPath.row].alertId!)) as! NSArray
        }
        
        if(checkInDates.count == 0) {
            
            cell.alertStatusButton.isHidden = false
            cell.alertStatusButton.setTitle(Constant.buttonTitles.nothingYet, for: .normal)
            cell.alertStatusButton.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            cell.alertStatusButton.setTitleColor(UIColor.lightGray, for: .normal)
            
            cell.alertNameLabel.textColor = UIColor.black
            cell.alertStatusButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.alertStatusButton.removeTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
            cell.alertStatusButton.addTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
            cell.activityIndicator.isHidden = true
        }
        else {
            
            cell.alertStatusButton.isHidden = false
            cell.alertStatusButton.setTitle(Constant.buttonTitles.viewResults, for: .normal)
            self.alertsSearchDates.setValue(checkInDates, forKey: String(cell.alertStatusButton.tag))
            cell.alertStatusButton.removeTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
            cell.alertStatusButton.addTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
            cell.alertNameLabel.textColor = IUIKColorPalette.primaryB.color
            cell.activityIndicator.isHidden = true
            cell.alertStatusButton.layer.borderColor = UIColor(red: 240.0/255.0, green: 111.0/255.0, blue: 54.0/255.0, alpha: 1.0).cgColor
         }
        }else{
            cell.alertStatusButton.isHidden = false
            cell.alertStatusButton.setTitle(Constant.buttonTitles.nothingYet, for: .normal)
            cell.alertStatusButton.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            cell.alertStatusButton.setTitleColor(UIColor.lightGray, for: .normal)
            
            cell.alertNameLabel.textColor = UIColor.black
            cell.alertStatusButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.alertStatusButton.removeTarget(self, action: #selector(self.viewResultsClicked(_:)), for: .touchUpInside)
            cell.alertStatusButton.addTarget(self, action: #selector(self.nothingYetClicked), for: .touchUpInside)
            cell.activityIndicator.isHidden = true
        }
          return cell
    }
    
    //***** Function to enable Swap deletion functionality *****//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
