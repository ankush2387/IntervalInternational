//
//  MyUpcomingTripVC.swift
//  IntervalApp
//
//  Created by Chetu-macmini-26 on 01/02/16.
//  Copyright © 2016 Interval International. All rights reserved®.
//

import UIKit
import IntervalUIKit
import SVProgressHUD
import DarwinSDK
import SDWebImage

class MyUpcomingTripViewController: UIViewController{
    
    //***** Outlets *****//
    @IBOutlet var myUpcommingTBL: UITableView!
    @IBOutlet var conformationNumber:String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.myUpcomingTripViewController
        
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer())
            self.myUpcommingTBL.reloadData()
        }
        
        // Omniture tracking with event 73
        let noTrips:Int? = Int(Constant.omnitureCommonString.noTrips)
       
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar18 : "",
            //TODO (Jhon): error found in iPad with user bwilling
//            Constant.omnitureEvars.eVar18 : Constant.MyClassConstants.upcomingOriginationPoint,
            Constant.omnitureEvars.eVar31 : "\(String(describing: Constant.MyClassConstants.upcomingTripsArray.count > 0 ? Constant.MyClassConstants.upcomingTripsArray.count : noTrips))\(Constant.omnitureEvars.eVar18)"
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event73, data: userInfo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //***** Dispose of any resources that can be recreated. *****//
    }
}

//***** MARK: Extension classes starts from here *****//

extension MyUpcomingTripViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(UIDevice().userInterfaceIdiom == .pad) {
            return 500
        }
        else {
            if(Constant.MyClassConstants.upcomingTripsArray.count == 0){
                return 300
                
            }else{
                return 435
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

extension MyUpcomingTripViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(Constant.MyClassConstants.upcomingTripsArray.count == 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.emptyUpcomingTrip, for: indexPath) as! UpComingTripCell
             cell.searchVacationButton.layer.cornerRadius = 5
             cell.selectionStyle = .none
            return cell
            
            
        }else{

            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as! UpComingTripCell
            let upComingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.section]
            cell.headerLabel.text = "Confirmation #\(upComingTrip.exchangeNumber!)"
            Constant.MyClassConstants.transactionNumber = "\(upComingTrip.exchangeNumber!)"
            cell.headerStatusLabel.text = upComingTrip.exchangeStatus!
            var type = ExchangeTransactionType.fromName(name: upComingTrip.type!).rawValue
            if(upComingTrip.type == Constant.myUpcomingTripCommonString.rental){
                
                upComingTrip.type = Constant.myUpcomingTripCommonString.getaway
                type = upComingTrip.type!
            }
            if (upComingTrip.type == Constant.myUpcomingTripCommonString.shop) {
                
                upComingTrip.type = Constant.myUpcomingTripCommonString.exchange
                type = upComingTrip.type!
            }
            //cell.resortType.text = ExchangeTransactionType.fromName(name: upComingTrip.type!).rawValue
            cell.resortType.text = type
            
            cell.resortImageView.backgroundColor = UIColor.lightGray
            
            let imagesArray = upComingTrip.resort?.images
            var imgURL: String?
            for largeResortImage in imagesArray!{
                if(largeResortImage.size == Constant.MyClassConstants.imageSizeXL){
                    imgURL = largeResortImage.url
                }else{
                    imgURL = imagesArray?.first?.url
                }
            }
            
            
            if let url = imgURL {
                cell.resortImageView.setImageWith(URL(string: url), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if (error != nil) {
                        intervalPrint("Width: \(String(describing: image?.size.width)) - Height: \(image?.size.height)")
                        cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        cell.resortImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                cell.resortImageView.image = UIImage(named: "\(Constant.MyClassConstants.noImage)")
                cell.resortImageView.contentMode = .center
            }
            
            cell.resortNameLabel.text = upComingTrip.resort!.resortName
            cell.resortLocationLabel.text = "\(upComingTrip.resort!.address!.cityName!), \(upComingTrip.resort!.address!.countryCode!)"
            cell.resortCodeLabel.text = upComingTrip.resort!.resortCode
            cell.footerViewDetailedButton.contentHorizontalAlignment = .left
            cell.footerViewDetailedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
            let checkInDate = Helper.convertStringToDate(dateString:upComingTrip.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
            
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
            
            
            let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.day!), \(myComponents.year!)"
            
            let checkOutDate = Helper.convertStringToDate(dateString: upComingTrip.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat)
            
            let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
            
            let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.day!), \(myComponents1.year!)"
            
            cell.tripDateLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)"
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for layer in cell.resortNameBaseView.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.footerViewDetailedButton.tag = indexPath.section
            return cell
         }
        
 
    }
    
    @IBAction func viewTripDetailsClicked(_ sender:UIButton){
        
      Constant.MyClassConstants.transactionNumber = "\(Constant.MyClassConstants.upcomingTripsArray[sender.tag].exchangeNumber!)"
        Constant.MyClassConstants.transactionType = Constant.MyClassConstants.upcomingTripsArray[sender.tag].type!
        
        
        showHudAsync()
        ExchangeClient.getExchangeTripDetails(Session.sharedSession.userAccessToken, confirmationNumber: Constant.MyClassConstants.transactionNumber, onSuccess: { (exchangeResponse) in
            
            Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails = exchangeResponse
            self.hideHudAsync()
            SVProgressHUD.dismiss()
        self.performSegue(withIdentifier:Constant.segueIdentifiers.upcomingDetailSegue, sender:nil)
        }) { (error) in
            self.hideHudAsync()
            SVProgressHUD.dismiss()
            SimpleAlert.alert(self, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        if(Constant.MyClassConstants.upcomingTripsArray.count == 0){
            return 1
        }else{
            return Constant.MyClassConstants.upcomingTripsArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        return 1
    }
}

