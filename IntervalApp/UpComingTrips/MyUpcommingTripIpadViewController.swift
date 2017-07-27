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
    @IBOutlet weak var upcommingTripTblView: UITableView!
    @IBOutlet var conformationNumber:String?
    @IBOutlet weak var leadingTableVwConstraint:NSLayoutConstraint!
    @IBOutlet weak var trailingTableVwConstraint:NSLayoutConstraint!
    var orientationIsPortrait = true
    
    override func viewWillLayoutSubviews(){
        //Managing table view spacing for orientation changes.
        self.checkOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.checkOrientation()
        upcommingTripTblView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkOrientation()
        upcommingTripTblView.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.checkOrientation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upcommingTripTblView.isScrollEnabled = false
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
            self.upcommingTripTblView.reloadData()
        }
    }
    
    //***** Function to check if device is in portrait or landscape. *****//
    
    func checkOrientation(){
        if(UIDevice.current.orientation.isPortrait){
            orientationIsPortrait = true
            leadingTableVwConstraint.constant = 20
            trailingTableVwConstraint.constant = 20
        }else{
            orientationIsPortrait = false
            leadingTableVwConstraint.constant = 0
            trailingTableVwConstraint.constant = 0
        }
    }

    //***** Function called when view trip details button is pressed for upcoming trip. *****//

    
    func viewTripDetailsPressed(_ sender:IUIKButton){
        self.performSegue(withIdentifier: Constant.segueIdentifiers.detailSegue, sender: self)
    }
}

//***** MARK: Extension classes starts from here *****//

extension MyUpcommingTripIpadViewController:UITableViewDelegate {
    
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
        
        if((indexPath as NSIndexPath).section == 0) {
            
            return tableView.frame.size.height
        }
        else {
            
            return 1200
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

extension MyUpcommingTripIpadViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.upComingTripDetailControllerReusableIdentifiers.upComingTripCell, for: indexPath) as! UpComingTripCell
        for subviews in cell.subviews {
            subviews.removeFromSuperview()
        }
        if(orientationIsPortrait){
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 1.0
            layout.minimumLineSpacing = 1.0
            layout.scrollDirection = .vertical
            let upcomingTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.frame.size.height-20 ), collectionViewLayout: layout)
            upcomingTableCollectionView.backgroundColor = UIColor.white
            upcomingTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            upcomingTableCollectionView.delegate = self
            upcomingTableCollectionView.dataSource = self
            upcomingTableCollectionView.register(UINib(nibName:Constant.customCellNibNames.upcomingTrip, bundle: nil), forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell)
            cell.addSubview(upcomingTableCollectionView)
        }else{
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 80.0
            layout.minimumLineSpacing = 1.0
            layout.scrollDirection = .horizontal
            let upcomingTableCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.frame.size.height ), collectionViewLayout: layout)
            upcomingTableCollectionView.delegate = self
            upcomingTableCollectionView.dataSource = self
            upcomingTableCollectionView.backgroundColor = UIColor.white
            upcomingTableCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell)
            upcomingTableCollectionView.register(UINib(nibName:Constant.customCellNibNames.upcomingTrip, bundle: nil), forCellWithReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell)

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

extension MyUpcommingTripIpadViewController:UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension MyUpcommingTripIpadViewController:UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(orientationIsPortrait){
            if(indexPath.item == 0){
                return CGSize(width: collectionView.frame.size.width, height: 100.0)
            }else{
                return CGSize(width: collectionView.frame.size.width, height: 600.0)
            }
        }else{
            if(indexPath.item == 0){
                return CGSize(width: 300.0, height: 400.0)
            }else{
                return CGSize(width: 500.0, height: 550.0)
            }
        }
    }
}

extension MyUpcommingTripIpadViewController:UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.upcomingTripsArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.item == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.cell, for: indexPath) as! CustomCollectionCell
            
            let headerLabel = UILabel()
            if(orientationIsPortrait){
                headerLabel.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 100)
            }else{
                headerLabel.frame = CGRect(x: 20, y: 0, width: cell.frame.size.width - 20, height: 400)

            }
            headerLabel.numberOfLines = 0
            headerLabel.text = Constant.AlertPromtMessages.upcomingTripMessage
            headerLabel.textColor = UIColor.gray
            headerLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 25.0)
            cell.addSubview(headerLabel)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dashboardTableScreenReusableIdentifiers.secCell, for: indexPath) as! UpcomingTripsCollectionViewCell
            
            let upcomingTrip = Constant.MyClassConstants.upcomingTripsArray[indexPath.row - 1]
            let imageUrls = upcomingTrip.resort!.images
            let imageUrl = (imageUrls[(imageUrls.count) - 1].url)! as String
            
            cell.resortImageView.setImageWith(URL(string: imageUrl), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                if (error != nil) {
                    cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            
            cell.headerLabel.text = "Confirmation #\(upcomingTrip.exchangeNumber!)"
            cell.headerStatusLabel.text = upcomingTrip.exchangeStatus!
            cell.resortNameLabel.text = upcomingTrip.resort!.resortName
            cell.resortLocationLabel.text = "\(upcomingTrip.resort!.address!.cityName!), \(upcomingTrip.resort!.address!.countryCode!)"
            cell.resortCodeLabel.text = upcomingTrip.resort!.address!.countryCode!
            let checkInDate = Helper.convertStringToDate(dateString:upcomingTrip.unit!.checkInDate!, format: Constant.MyClassConstants.dateFormat)
            
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
            
            
            let formatedCheckInDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)). \(myComponents.day!), \(myComponents.year!)"
            
            let checkOutDate = Helper.convertStringToDate(dateString: upcomingTrip.unit!.checkOutDate!, format: Constant.MyClassConstants.dateFormat)
            
            let myComponents1 = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
            
            let formatedCheckOutDate = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!)) \(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)). \(myComponents1.day!), \(myComponents1.year!)"
            
            cell.tripDateLabel.text = "\(formatedCheckInDate) - \(formatedCheckOutDate)"
            
            for layer in cell.resortNameBaseView.layer.sublayers!{
                if(layer.isKind(of: CAGradientLayer.self)) {
                    layer.removeFromSuperlayer()
                }
            }
            Helper.addLinearGradientToView(view: cell.resortNameBaseView, colour: UIColor.white, transparntToOpaque: true, vertical: false)
            cell.backgroundColor = UIColor.white
            cell.footerViewDetailedButton.addTarget(self, action: #selector(MyUpcommingTripIpadViewController.viewTripDetailsPressed(_:)), for: UIControlEvents.touchUpInside)
            return cell
        }
    }
}

