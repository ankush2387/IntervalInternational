//
//  CertificateViewController.swift
//  IntervalApp
//
//  Created by Chetu on 22/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD

class CertificateViewController: UIViewController {
    
    
    @IBOutlet weak var certificateTable: UITableView!
    var certificateCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClickedCertificateInfoButton(_ sender: Any) {
        
        self.getAccommodationCertificateSummary(sendertag: (sender as AnyObject).tag)
    }
    
    func getAccommodationCertificateSummary(sendertag:Int) {
       
        showHudAsync()
        let number = Constant.MyClassConstants.certificateArray[sendertag].certificateNumber! as NSNumber
        
        let certificateNumber:String = number.stringValue
       
        UserClient.getAccommodationCertificateSummary(Session.sharedSession.userAccessToken, certificateNumber: certificateNumber, onSuccess: { (response) in
            self.hideHudAsync()
            Constant.MyClassConstants.certificateDetailsArray = response
            self.navigateToCertificateDetailsVC()
        }, onError: { (error) in
            self.hideHudAsync()
             print(error)
            
            })
    }
    
    func navigateToCertificateDetailsVC()  {
        
        if (Constant.MyClassConstants.isRunningOnIphone) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.certificateDetailsViewController) as! CertificateDetailsViewController
            self.present(viewController, animated: true, completion: nil)
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name:Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.certificateDetailsViewController) as! CertificateDetailsViewController
            self.present(viewController, animated: true, completion: nil)
            
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showHudAsync()
       // Helper.showProgressBar(senderView: self)
        UserClient.getAccommodationCertificates(Session.sharedSession.userAccessToken, onSuccess: { (certificates) in
            self.hideHudAsync()
            Constant.MyClassConstants.certifcateCount = certificates.count
            Constant.MyClassConstants.certificateArray =  certificates
            self.certificateTable.delegate = self
            self.certificateTable.dataSource = self
            self.certificateTable.reloadData()
            
        }, onError: { (error) in
            self.hideHudAsync()
        })
        
    }
    
}


extension CertificateViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 480
        
    }
}

extension CertificateViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.certifcateCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.certificateScreenReusableIdentifiers.certificateCell, for: indexPath) as! CertificateCell
        cell.cellBaseView.layer.masksToBounds = true
        cell.cellBaseView.layer.cornerRadius = 5
        
        cell.certificateNumber.text = "#\(Constant.MyClassConstants.certificateArray[indexPath.row].certificateNumber!)"
        
        let expireDateString = Constant.MyClassConstants.certificateArray[indexPath.row].expirationDate!
        let myStringArr = expireDateString.components(separatedBy: "-")
        
        let expireDateFinalString = myStringArr.flatMap({$0}).joined(separator: "/")
        
        cell.expireDate.text = "\(String(describing: Constant.MyClassConstants.certificateArray[indexPath.row].daysOut!)) Days, on \(String(describing: expireDateFinalString))"
        
        cell.bedroomSize.text = "\((Helper.getBedroomNumbers(bedroomType: (Constant.MyClassConstants.certificateArray[indexPath.row].unit?.unitSize)! )) ), \((Helper.getKitchenEnums(kitchenType: (Constant.MyClassConstants.certificateArray[indexPath.row].unit?.kitchenType)!)))"
        
        let totalSleeps =  "Sleeps \(Constant.MyClassConstants.certificateArray[indexPath.row].unit?.publicSleepCapacity ?? 0) Total"
        let privateSleeps = "\(Constant.MyClassConstants.certificateArray[indexPath.row].unit?.privateSleepCapacity ?? 0) Private"
        
        cell.totalSleeps.text = "\(totalSleeps), \(privateSleeps)"
        
        let calendarFromDate = Helper.convertStringToDate(dateString: (Constant.MyClassConstants.certificateArray[indexPath.row].travelWindow?.fromDate)!, format: Constant.MyClassConstants.dateFormat)
        
        let calendarToDate = Helper.convertStringToDate(dateString: (Constant.MyClassConstants.certificateArray[indexPath.row].travelWindow?.toDate)!, format: Constant.MyClassConstants.dateFormat)
        
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let startComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: calendarFromDate)
        let endComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: calendarToDate)
        let year = String(describing: startComponents.year!)
        let monthName = "\(Helper.getMonthnameFromInt(monthNumber: startComponents.month!))"
        cell.travelWindowStartDateLbl.text = "\(startComponents.day!)".uppercased()
        cell.travelWindowStartDayLbl.text = "\(Helper.getWeekdayFromInt(weekDayNumber:startComponents.weekday!))"
        
        cell.travelWindowStartMonthYearLbl.text = "\(monthName) \(year)"
        
        
        cell.travelWindowEndDateLbl.text = "\(endComponents.day!)"
        cell.travelWindowEndDayLbl.text = "\(Helper.getWeekdayFromInt(weekDayNumber:endComponents.weekday!))"
        
        cell.travelWindowEndMonthYearLbl.text = "\(Helper.getMonthnameFromInt(monthNumber: endComponents.month!))  \(String(describing: endComponents.year!))"
        
        cell.statusLbl.text = Constant.MyClassConstants.certificateArray[indexPath.row].certificateStatus
        
        Helper.applyShadowOnUIView(view: cell.cellBaseView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        //set button tag
        cell.certificateInfoButton.tag = indexPath.row
        
        return cell
    }
    
}

