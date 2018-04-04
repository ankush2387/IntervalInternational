//
//  MyUpcommingTripIpadViewController.swift
//  IntervalApp
//
//  Created by Chetu on 05/08/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import SDWebImage
import DarwinSDK
import SVProgressHUD

class MyUpcommingTripIpadViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak private var upcommingTripTblView: UITableView!
    @IBOutlet private var conformationNumber: String?
    @IBOutlet weak var leadingTableVwConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingTableVwConstraint: NSLayoutConstraint!
    var orientationIsPortrait = true
    
    override func viewWillLayoutSubviews() {
        //Managing table view spacing for orientation changes.
        checkOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        checkOrientation()
        upcommingTripTblView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkOrientation()
        upcommingTripTblView.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        checkOrientation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upcommingTripTblView.isScrollEnabled = false
        title = Constant.ControllerTitles.myUpcomingTripViewController
        
        //***** Setup the hamburger menu.  This will reveal the side menu. *****//
        if let rvc = self.revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            view.addGestureRecognizer( rvc.panGestureRecognizer())
            upcommingTripTblView.reloadData()
        }
    }
    
    //***** Function to check if device is in portrait or landscape. *****//
    
    func checkOrientation() {
        if UIDevice.current.orientation.isLandscape {
            orientationIsPortrait = false
            leadingTableVwConstraint.constant = 0
            trailingTableVwConstraint.constant = 0
        } else {
            orientationIsPortrait = true
            leadingTableVwConstraint.constant = 20
            trailingTableVwConstraint.constant = 20
        }
    }
    
    //MARK :- Navigate to Vacation Search
    func vacationSearchButtonPressed(_ sender: UIButton) {
        if let initialViewController = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad
            , bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }

    //***** Function called when view trip details button is pressed for upcoming trip. *****//
    
    func viewTripDetailsPressed(_ sender: IUIKButton) {
        
        if let exchangeNumber = Constant.MyClassConstants.upcomingTripsArray[sender.tag - 1].exchangeNumber {
            Constant.MyClassConstants.transactionNumber = "\(exchangeNumber)"
        }
        
        showHudAsync()
        ExchangeClient.getExchangeTripDetails(Session.sharedSession.userAccessToken, confirmationNumber: Constant.MyClassConstants.transactionNumber, onSuccess: { exchangeResponse in
            Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails = exchangeResponse
            self.hideHudAsync()
            self.performSegue(withIdentifier: Constant.segueIdentifiers.detailSegue, sender: nil)
        }, onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
    }
}

//***** MARK: Extension classes starts from here *****//

extension MyUpcommingTripIpadViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 30, y: 0, width: self.view.bounds.width - 60, height: 100))
        headerView.backgroundColor = UIColor.red
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).section == 0 {
            
            return tableView.frame.size.height
        } else {
            
            return 1200
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension MyUpcommingTripIpadViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
        for subviews in cell.subviews {
            subviews.removeFromSuperview()
        }
        if orientationIsPortrait {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 1.0
            layout.minimumLineSpacing = 1.0
            layout.scrollDirection = .vertical
            let upcomingTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.frame.size.height - 20 ), collectionViewLayout: layout)
            upcomingTableCollectionView.backgroundColor = UIColor.white
            upcomingTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            upcomingTableCollectionView.delegate = self
            upcomingTableCollectionView.dataSource = self
            upcomingTableCollectionView.register(UINib(nibName: Constant.customCellNibNames.upcomingTrip, bundle: nil), forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell)
            cell.addSubview(upcomingTableCollectionView)
        } else {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 80.0
            layout.minimumLineSpacing = 1.0
            layout.scrollDirection = .horizontal
            let upcomingTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.frame.size.height ), collectionViewLayout: layout)
            upcomingTableCollectionView.delegate = self
            upcomingTableCollectionView.dataSource = self
            upcomingTableCollectionView.backgroundColor = UIColor.white
            upcomingTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            upcomingTableCollectionView.register(UINib(nibName: Constant.customCellNibNames.upcomingTrip, bundle: nil), forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell)

            cell.addSubview(upcomingTableCollectionView)
        }
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** Return number of sections required in tableview *****//
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** Return number of rows in section required in tableview *****//
        return 1
    }
}

//***** MARK: Extension classes starts from here *****//

extension MyUpcommingTripIpadViewController: UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension MyUpcommingTripIpadViewController: UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if orientationIsPortrait {
            if indexPath.item == 0 {
                if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
                  return CGSize(width: collectionView.frame.size.width, height: 700.0)
                } else {
                    return CGSize(width: collectionView.frame.size.width, height: 0)
                }
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 600.0)
            }
        } else {
            if indexPath.item == 0 {
                return CGSize(width: 300.0, height: 400.0)
            } else {
                return CGSize(width: 500.0, height: 550.0)
            }
        }
    }
}

extension MyUpcommingTripIpadViewController: UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
            return 1
        } else {
            return Constant.MyClassConstants.upcomingTripsArray.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath) as? CustomCollectionCell else { return UICollectionViewCell() }
            if Constant.MyClassConstants.upcomingTripsArray.isEmpty {
                let headerLabel = UILabel()
                let noTripsImage = UIImageView()
                let searchVacationButton = UIButton()
                if orientationIsPortrait {
                    headerLabel.frame = CGRect(x: 5, y: 325, width: cell.frame.size.width, height: 100)
                    noTripsImage.frame = CGRect(x: 0, y: 10, width: cell.frame.size.width, height: 320)
                    searchVacationButton.frame = CGRect(x: 0, y: 500, width: cell.frame.size.width, height: 60)
                } else {
                    headerLabel.frame = CGRect(x: 300, y: 0, width: cell.frame.size.width - 20, height: 400)
                    noTripsImage.frame = CGRect(x: 300, y: -140, width: cell.frame.size.width, height: 320)
                    searchVacationButton.frame = CGRect(x: 300, y: 400, width: cell.frame.size.width, height: 60)
                    
                }
                searchVacationButton.addTarget(self, action: #selector(MyUpcomingTripViewController.vacationSearchButtonPressed(_:)), for: .touchUpInside)
                headerLabel.numberOfLines = 0
                headerLabel.text = Constant.AlertPromtMessages.upcomingTripMessage
                headerLabel.textColor = UIColor.lightGray
                headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 25.0)
                noTripsImage.image = UIImage(named: Constant.MyClassConstants.noImage)
                searchVacationButton.setTitle(Constant.AlertPromtMessages.upcomingTripSearchVacationButtonMessage, for: UIControlState.normal)
                searchVacationButton.backgroundColor = UIColor(red: 255.0 / 255.0, green: 122.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
                searchVacationButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                searchVacationButton.layer.cornerRadius = 5
                cell.addSubview(headerLabel)
                cell.addSubview(noTripsImage)
                cell.addSubview(searchVacationButton)
                return cell
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell, for: indexPath) as? UpcomingTripsCollectionViewCell else {
                
                return UICollectionViewCell()
            }
            let upcomingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.row - 1]
            
            let image = upcomingTrip.resort?.images.filter { $0.size?.caseInsensitiveCompare("XLARGE") == ComparisonResult.orderedSame }.first
            if let imageUrl = image?.url {
                
                cell.resortImageView.setImageWith(URL(string: imageUrl), completed: { (image:UIImage?, error:Error?, _:SDImageCacheType, _:URL?) in
                    if case .some = error {
                        cell.resortImageView.image = #imageLiteral(resourceName: "NoImageIcon")
                    }
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                cell.resortImageView.image = #imageLiteral(resourceName: "NoImageIcon")
            }
 
            if let upcomingTripType = upcomingTrip.type {
                var type = ExchangeTransactionType.fromName(name: upcomingTripType).friendlyNameForUpcomingTrip()
                
                cell.resortType.text = type.uppercased()
            }
            if let exchangeNumber = upcomingTrip.exchangeNumber, let exchangeStatus = upcomingTrip.exchangeStatus {
                cell.headerLabel.text = "Confirmation #\(exchangeNumber)"
                cell.headerStatusLabel.text = exchangeStatus
            }
            
            if let resortName = upcomingTrip.resort?.resortName {
                cell.resortNameLabel.text = resortName
            }
            
            if let countryCode = upcomingTrip.resort?.address?.countryCode {
                cell.resortCodeLabel.text = countryCode
            }
            
            if let checkInDateForUpcomingTrips = upcomingTrip.unit?.checkInDate, let checkInDate = checkInDateForUpcomingTrips.dateFromShortFormat() {
            
            let myCalendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
            let myComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: checkInDate)
            
            if let weekday = myComponents.weekday, let month = myComponents.month, let day = myComponents.day, let year = myComponents.year {
                let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday)) \(Helper.getMonthnameFromInt(monthNumber: month)). \(day), \(year)"
                
                if let checkOutDateUpcomingTrips = upcomingTrip.unit?.checkOutDate, let checkOutDate = checkOutDateUpcomingTrips.dateFromShortFormat() {
                    let myComponents1 = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: checkOutDate)
                    if let weekday = myComponents1.weekday, let month = myComponents1.month, let day = myComponents1.day, let year = myComponents1.year {
                        let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: weekday)) \(Helper.getMonthnameFromInt(monthNumber: month)). \(day), \(year)"
                        
                        cell.tripDateLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)"
                    }
                }
            }
        }
            if let sublayers = cell.resortNameBaseView.layer.sublayers {
                for layer in sublayers {
                    if layer.isKind(of: CAGradientLayer.self) {
                        layer.removeFromSuperlayer()
                    }
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.backgroundColor = UIColor.white
            cell.footerViewDetailedButton.tag = indexPath.row
            cell.footerViewDetailedButton.addTarget(self, action: #selector(MyUpcommingTripIpadViewController.viewTripDetailsPressed(_:)), for: UIControlEvents.touchUpInside)
            guard let addressDetails = upcomingTrip.resort?.address else {
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
}
