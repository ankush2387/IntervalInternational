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

class MyUpcomingTripViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet var myUpcommingTBL: UITableView!
    @IBOutlet var conformationNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constant.ControllerTitles.myUpcomingTripViewController
        
        if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
            showHudAsync()
            Helper.getUpcomingTripsForUser {[weak self] error in
                self?.hideHudAsync()
                if let upcomingTripLoadError = error {
                    self?.presentErrorAlert(UserFacingCommonError.handleError(upcomingTripLoadError))
                } else {
                    self?.myUpcommingTBL.reloadData()
                }
            }
        }
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
        let noTrips: Int? = Int(Constant.omnitureCommonString.noTrips)
        
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar18 : "",
            //TODO (Jhon): error found in iPad with user bwilling
            //            Constant.omnitureEvars.eVar18 : Constant.MyClassConstants.upcomingOriginationPoint,
            Constant.omnitureEvars.eVar31 : "\(String(describing: Constant.MyClassConstants.upcomingTripsArray.count > 0 ? Constant.MyClassConstants.upcomingTripsArray.count : noTrips))\(Constant.omnitureEvars.eVar18)"
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event73, data: userInfo)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //***** Dispose of any resources that can be recreated. *****//
    }
    func vacationSearchButtonPressed(_ sender: UIButton) {
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
}

//***** MARK: Extension classes starts from here *****//

extension MyUpcomingTripViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if UIDevice().userInterfaceIdiom == .pad {
            return 500
        } else {
            if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
                return 300
            } else {
                return 435
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
extension MyUpcomingTripViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.emptyUpcomingTrip, for: indexPath) as! UpComingTripCell
             cell.searchVacationButton.layer.cornerRadius = 5
            cell.searchVacationButton.addTarget(self, action: #selector(MyUpcomingTripViewController.vacationSearchButtonPressed(_:)), for: .touchUpInside)
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
                cell.headerStatusLabel.text = ExchangeStatus.fromName(name: exchangeStatus).friendlyNameForUpcomingTrip().localized()
            }

            if let tripType = upComingTrip.type {
                let type = ExchangeTransactionType.fromName(name: tripType).friendlyNameForUpcomingTrip()
                cell.resortType.text = type.localized().uppercased()
            }
            cell.resortImageView.backgroundColor = UIColor.lightGray
            var imgURL: String?
            if let imagesArray = upComingTrip.resort?.images {
                for largeResortImage in imagesArray {
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
            cell.footerViewDetailedButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            if let checkInDate = upComingTrip.unit?.checkInDate, let checkOutDate = upComingTrip.unit?.checkOutDate, let myCheckInDate = checkInDate.dateFromShortFormat() {
                
                let myCalendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                let myComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: myCheckInDate)
                
                if let weekday = myComponents.weekday, let month = myComponents.month, let day = myComponents.day, let year = myComponents.year {
                    let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday)) \(Helper.getMonthnameFromInt(monthNumber: month)) \(day), \(year)"
                    
                    if let checkOutDate = checkOutDate.dateFromShortFormat() {
                        let myComponents1 = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: checkOutDate)
                        
                        if let weekday = myComponents1.weekday, let month = myComponents1.month, let day = myComponents1.day, let year = myComponents1.year {
                            let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday)) \(Helper.getMonthnameFromInt(monthNumber: month)) \(day), \(year)"
                            cell.tripDateLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)".localized()
                        }
                    }
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            for layer in cell.resortNameBaseView.layer.sublayers! {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.footerViewDetailedButton.tag = indexPath.section
            
            guard let addressDetails = upComingTrip.resort?.address else {
                return cell
            }
            cell.resortLocationLabel.text = addressDetails.postalAddresAsString().localized()
            cell.resortCodeLabel.text = upComingTrip.resort?.resortCode
            return cell
        }
    }
    
    @IBAction func viewTripDetailsClicked(_ sender: UIButton) {
        if let transactionNumber = Constant.MyClassConstants.upcomingTripsArray[sender.tag].exchangeNumber {
            Constant.MyClassConstants.transactionNumber = "\(transactionNumber)"
        }
        if let transactionType = Constant.MyClassConstants.upcomingTripsArray[sender.tag].type {
            Constant.MyClassConstants.transactionType = transactionType
        }
        showHudAsync()
        ExchangeClient.getExchangeTripDetails(Session.sharedSession.userAccessToken, confirmationNumber: Constant.MyClassConstants.transactionNumber, onSuccess: { (exchangeResponse) in
            
            Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails = exchangeResponse
            self.hideHudAsync()
            self.performSegue(withIdentifier:Constant.segueIdentifiers.upcomingDetailSegue, sender:nil)
        }) { error in
            self.hideHudAsync()
            self.presentErrorAlert(UserFacingCommonError.handleError(error))
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
