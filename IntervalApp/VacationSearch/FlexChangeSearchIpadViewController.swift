//
//  FlexChangeSearchIpadViewController.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 9/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SVProgressHUD
import DarwinSDK
import QuartzCore
import RealmSwift

class FlexChangeSearchIpadViewController: UIViewController {
    
    //MARK:- clas  outlets
    @IBOutlet weak var flexchangeSearchTableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    //MARK:- class varibles

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Flexchange Search"
        
        //set corner radius
        
        self.searchButton.layer.cornerRadius = 7
  
        // set navigation right bar buttons
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(FlexChangeSearchIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = menuButton
        
        // custom back button
        
        let menuButtonleft = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(FlexChangeSearchIpadViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButtonleft

    }
    
    func menuButtonClicked() {
        print("menu button clicked")
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
    }
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addLocationInSection0Pressed(_ sender:IUIKButton) {
        
        SVProgressHUD.show()
        Helper.addServiceCallBackgroundView(view: self.view)
        ExchangeClient.getMyUnits(UserContext.sharedInstance.accessToken, onSuccess: { (Relinquishments) in
            
            DarwinSDK.logger.debug(Relinquishments)
            Constant.MyClassConstants.relinquishmentDeposits = Relinquishments.deposits
            Constant.MyClassConstants.relinquishmentOpenWeeks = Relinquishments.openWeeks
            
            if(Relinquishments.pointsProgram != nil){
                Constant.MyClassConstants.relinquishmentProgram = Relinquishments.pointsProgram!
                
                if (Relinquishments.pointsProgram!.availablePoints != nil) {
                    Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Relinquishments.pointsProgram!.availablePoints!
                }
                
            }
            
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.relinquishmentSelectionViewController) as! RelinquishmentSelectionViewController
            
            let transitionManager = TransitionManager()
            self.navigationController?.transitioningDelegate = transitionManager
            let navController = UINavigationController(rootViewController: viewController)
            self.navigationController!.present(navController, animated: true)
            
        }, onError: {(error) in
            
            print(error.description)
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: self.view)
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            
        })
    }

}


extension FlexChangeSearchIpadViewController:UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.flexChangeDestinationCell, for: indexPath) as! FlexchangeDestinationCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else {
            
            
            if(Constant.MyClassConstants.whereTogoContentArray.count == 0 || (indexPath as NSIndexPath).row == Constant.MyClassConstants.whereTogoContentArray.count) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cellIdentifier, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                for subview in cell.subviews {
                    subview.removeFromSuperview()
                }
                
                let addLocationButton = IUIKButton(frame: CGRect(x: cell.contentView.bounds.width/2 - 25, y: 15, width: 50, height: 50))
                
                //addLocationButton.setTitle(Constant.buttonTitles.add, for: UIControlState.normal)
                
                addLocationButton.setBackgroundImage(UIImage.init(named: "PlusIcon"), for: .normal)
                
                //addLocationButton.setTitle("+", for: .normal)
                
                addLocationButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                
                //addLocationButton.setTitleColor(UIColor.white, for: .normal)
                
                //addLocationButton.layer.borderColor = IUIKColorPalette.primary3.color.cgColor
                
                addLocationButton.layer.cornerRadius = 25
                
                //addLocationButton.backgroundColor = IUIKColorPalette.primary3.color
                
                //addLocationButton.layer.borderWidth = 2
                addLocationButton.addTarget(self, action: #selector(VacationSearchViewController.addLocationInSection0Pressed(_:)), for: .touchUpInside)
                cell.addSubview(addLocationButton)
                
                return cell
                
            } else {
                
                let cell: WhereToGoContentCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.whereToGoCell, for: indexPath) as! WhereToGoContentCell
                
                
                
                /*if((indexPath as NSIndexPath).row == destinationOrResort.count - 1 || destinationOrResort.count == 0) {
                    
                    cell.sepratorOr.isHidden = true
                }
                else {
                    
                    cell.sepratorOr.isHidden = false
                }*/
                
                let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as AnyObject
                if(object.isKind(of:Resort.self)){
                    
                    var resortNm = ""
                    var resortCode = ""
                    if let restName = (object as! Resort).resortName {
                        resortNm = restName
                    }
                    
                    if let restcode = (object as! Resort).resortCode {
                        resortCode = restcode
                    }
                    var resortNameString = "\(resortNm) (\(resortCode))"
                    if((object as AnyObject).count > 1){
                        resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \((object as AnyObject).count - 1) \(Constant.getDynamicString.moreString)"
                    }
                    cell.whereTogoTextLabel.text = resortNameString
                    
                }else if (object.isKind(of: List<ResortByMap>.self)){
                    
                    let object = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as! List<ResortByMap>
                    
                    let resort = object[0]
                    
                    var resortNameString = "\(resort.resortName) (\(resort.resortCode))"
                    if(object.count > 1){
                        resortNameString = resortNameString + " \(Constant.getDynamicString.andString) \(object.count - 1) \(Constant.getDynamicString.moreString)"
                    }
                    
                    cell.whereTogoTextLabel.text = resortNameString
                }
                    
                else {
                    print(Constant.MyClassConstants.whereTogoContentArray[indexPath.row] as! String)
                    cell.whereTogoTextLabel.text = Constant.MyClassConstants.whereTogoContentArray[(indexPath as NSIndexPath).row] as? String
                }
                
                //cell.bedroomLabel.isHidden = true
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = UIColor.clear
                return cell
            }
            
        }
    }
    
}


extension FlexChangeSearchIpadViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch((indexPath as NSIndexPath).section) {
        case 0 :
            if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whereTogoContentArray.count) {
                return UITableViewAutomaticDimension
            }else {
                return 60
            }
        case 1:
            if((indexPath as NSIndexPath).row < Constant.MyClassConstants.whatToTradeArray.count) {
                return UITableViewAutomaticDimension
            }
            else {
                return 60
            }
            
        default :
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
       // view.backgroundColor = UIColor.init(colorLiteralRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        
        view.backgroundColor = UIColor.clear

        let headerNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        
        headerNameLabel.textAlignment = .center
        
        if section == 0 {
            headerNameLabel.text = "Your selected Flexchange Destination"
        } else {
            headerNameLabel.text = "What do you want to trade?"
            
        }
        
        headerNameLabel.textColor = UIColor.lightGray
        headerNameLabel.font = UIFont(name:Constant.fontName.helveticaNeue, size:18)
        
        view.addSubview(headerNameLabel)
        
        return view
        
    }
    
}




