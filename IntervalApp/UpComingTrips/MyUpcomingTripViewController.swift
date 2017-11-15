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
        
        title = Constant.ControllerTitles.myUpcomingTripViewController
        
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            view.addGestureRecognizer( rvc.panGestureRecognizer())
            myUpcommingTBL.reloadData()
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
        
        if UIDevice().userInterfaceIdiom == .pad {
            return 500
        } else {
            if Constant.MyClassConstants.upcomingTripsArray.count == 0 {
                return 300
                
            } else {
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
        
        if Constant.MyClassConstants.upcomingTripsArray.count == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.emptyUpcomingTrip, for: indexPath) as? UpComingTripCell else {
                
                return UITableViewCell()
            }
            cell.searchVacationButton.layer.cornerRadius = 5
            cell.selectionStyle = .none
            return cell
            
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as? UpComingTripCell else {
                
                return UITableViewCell()
            }
            let upComingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.section]
            if let exchangeNumber = upComingTrip.exchangeNumber {
                cell.headerLabel.text = "Confirmation #\(exchangeNumber)".localized()
                Constant.MyClassConstants.transactionNumber = "\(exchangeNumber)"
            }
            if let exchangeStatus = upComingTrip.exchangeStatus {
                cell.headerStatusLabel.text = exchangeStatus.localized()
            }
            if let tripType = upComingTrip.type {
                
                var type = ExchangeTransactionType.fromName(name: tripType).rawValue
                if tripType == Constant.myUpcomingTripCommonString.rental {
                    type = Constant.myUpcomingTripCommonString.getaway
                } else if tripType == Constant.myUpcomingTripCommonString.shop {
                    type = Constant.myUpcomingTripCommonString.exchange
                }
                cell.resortType.text = type.localized()
                upComingTrip.type = type
            }
            cell.resortImageView.backgroundColor = UIColor.lightGray
            var imgURL: String?
            if let imagesArray = upComingTrip.resort?.images {
                for largeResortImage in imagesArray{
                    if largeResortImage.size == Constant.MyClassConstants.imageSizeXL {
                        imgURL = largeResortImage.url
                    } else {
                        imgURL = imagesArray.first?.url
                    }
                }
            }
            if let url = imgURL {
                cell.resortImageView.setImageWith(URL(string: url), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if error != nil {
                        intervalPrint("Width: \(String(describing: image?.size.width)) - Height: \(image?.size.height ?? 0.0)")
                        cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                        cell.resortImageView.contentMode = .center
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                cell.resortImageView.image = UIImage(named: "\(Constant.MyClassConstants.noImage)")
                cell.resortImageView.contentMode = .center
            }
            
            if let resortName = upComingTrip.resort?.resortName {
                cell.resortNameLabel.text = resortName.localized()
            }
            cell.footerViewDetailedButton.contentHorizontalAlignment = .left
            cell.footerViewDetailedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
            if let checkInDate = upComingTrip.unit?.checkInDate, let checkOutDate =  upComingTrip.unit?.checkOutDate {
                
                let checkInDate = Helper.convertStringToDate(dateString:checkInDate, format: Constant.MyClassConstants.dateFormat)
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                if let weekday =  myComponents.weekday, let month = myComponents.month, let day = myComponents.day, let year = myComponents.year {
                    let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday)) \(Helper.getMonthnameFromInt(monthNumber: month)). \(day), \(year)"
                    let checkOutDate = Helper.convertStringToDate(dateString: checkOutDate, format: Constant.MyClassConstants.dateFormat)
                    let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                    if let weekday =  myComponents1.weekday, let month = myComponents1.month, let day = myComponents1.day, let year = myComponents1.year {
                        let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday)) \(Helper.getMonthnameFromInt(monthNumber: month)). \(day), \(year)"
                        cell.tripDateLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)".localized()
                    }
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for layer in cell.resortNameBaseView.layer.sublayers!{
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.footerViewDetailedButton.tag = indexPath.section
            
            guard let addressDetails = upComingTrip.resort?.address else {
                return cell
            }
            var resortAddress = [String]()
            if let city = addressDetails.cityName {
                resortAddress.append(city)
            }
            if let state = addressDetails.territoryCode {
                resortAddress.append(state)
            }
            if let countryCode = addressDetails.countryCode {
                resortAddress.append(countryCode)
            }
            cell.resortLocationLabel.text = resortAddress.joined(separator: ", ").localized()
            
            return cell
        }
    }
    
    @IBAction func viewTripDetailsClicked(_ sender:UIButton) {
        if let transactionNumber = Constant.MyClassConstants.upcomingTripsArray[sender.tag].exchangeNumber {
            Constant.MyClassConstants.transactionNumber = "\(transactionNumber)"
        }
        if let transactionType = Constant.MyClassConstants.upcomingTripsArray[sender.tag].type
        {
            Constant.MyClassConstants.transactionType = transactionType
        }
        showHudAsync()
        ExchangeClient.getExchangeTripDetails(Session.sharedSession.userAccessToken, confirmationNumber: Constant.MyClassConstants.transactionNumber, onSuccess: { (exchangeResponse) in
            
            Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails = exchangeResponse
            self.hideHudAsync()
            self.performSegue(withIdentifier:Constant.segueIdentifiers.upcomingDetailSegue, sender:nil)
        }) { error in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.generic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
            return 1
        } else {
            return Constant.MyClassConstants.upcomingTripsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        return 1
    }
}


