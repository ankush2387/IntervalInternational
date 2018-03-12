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
    
    //class variables
    var certificateArray = [AccommodationCertificate]()
    
    @IBOutlet weak private var certificateTable: UITableView!
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

    @IBAction func unwindToCertificateViewController(segue: UIStoryboardSegue) {
        // Left blank intentionally
    }
    
    @IBAction func redeemMyCertificateButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://www.intervalworld.com/web/my/home") {
            NetworkHelper.open(url)
        }
    }
    
    func getAccommodationCertificateSummary(sendertag: Int) {
       
        // show hud
        showHudAsync()
        if let certificateNumber = Constant.MyClassConstants.certificateArray[sendertag].certificateNumber {
            
            let number = certificateNumber as NSNumber
            let certificateNumber: String = number.stringValue
            UserClient.getAccommodationCertificateSummary(Session.sharedSession.userAccessToken, certificateNumber: certificateNumber, onSuccess: { (response) in
                
                self.hideHudAsync()
                self.navigateToCertificateDetailsVC(response: response)
                
            }, onError: { (_) in
                self.hideHudAsync()
            })
        }
    }
    
    func navigateToCertificateDetailsVC(response: AccommodationCertificateSummary) {
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.vacationSearchIphone : Constant.storyboardNames.vacationSearchIPad
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.certificateDetailsViewController) as? CertificateDetailsViewController {
            viewController.certificateDetailsResponse = response
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //show hud
        showHudAsync()
    UserClient.getAccommodationCertificates(Session.sharedSession.userAccessToken, onSuccess: { (certificates) in
        self.hideHudAsync()
        Constant.MyClassConstants.certifcateCount = certificates.count
        Constant.MyClassConstants.certificateArray = certificates
        self.certificateTable.delegate = self
        self.certificateTable.dataSource = self
        self.certificateTable.reloadData()
        
        }, onError: { (_) in
            self.hideHudAsync()
        })
    }
}

// MARK: - Tableview delegage
extension CertificateViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 480
        
    }
}

// MARK: - Tableview datasource
extension CertificateViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.certifcateCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.certificateScreenReusableIdentifiers.certificateCell, for: indexPath) as? CertificateCell else {
            
            return UITableViewCell()
        }
        cell.cellBaseView.layer.masksToBounds = true
        cell.cellBaseView.layer.cornerRadius = 5
        if let certificateNumber = Constant.MyClassConstants.certificateArray[indexPath.row].certificateNumber {
                  cell.certificateNumber.text = "#\(certificateNumber)".localized()
        }
        if let expiredDate = Constant.MyClassConstants.certificateArray[indexPath.row].expirationDate {
            
            if let expireDateString = Date.dateFromString(expiredDate)?.formatDateAs("MM/dd/yyyy") {
                let diffInDays = Constant.MyClassConstants.certificateArray[indexPath.row].getDaysUntilExpirationDate()
                cell.expireDate.text =  "\(Helper.diffInDaysCalculation(String(diffInDays))), \(expireDateString)"
            }
        }
        
        let diffInDays = Constant.MyClassConstants.certificateArray[indexPath.row].getDaysUntilExpirationDate()
        intervalPrint(diffInDays)
        
        if let unitSize = Constant.MyClassConstants.certificateArray[indexPath.row].unit?.unitSize, let kitchenType = Constant.MyClassConstants.certificateArray[indexPath.row].unit?.kitchenType {
            
                cell.bedroomSize.text = "\((Helper.getBedroomNumbers(bedroomType: unitSize )) ), \((Helper.getKitchenEnums(kitchenType: kitchenType)))".localized()
        }
        
        if let fromDate = Constant.MyClassConstants.certificateArray[indexPath.row].travelWindow?.fromDate,
            let toDate = Constant.MyClassConstants.certificateArray[indexPath.row].travelWindow?.toDate {
            
            let calendarFromDate = Helper.convertStringToDate(dateString: fromDate, format: Constant.MyClassConstants.dateFormat)
            let calendarToDate = Helper.convertStringToDate(dateString: toDate, format: Constant.MyClassConstants.dateFormat)
   
            let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
            let startComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: calendarFromDate)
            let endComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: calendarToDate)
            if let year = startComponents.year, let month = startComponents.month, let day = startComponents.day, let weekDay = startComponents.weekday {
                let monthName = "\(Helper.getMonthnameFromInt(monthNumber: month))"
                cell.travelWindowStartDateLbl.text = "\(day)".uppercased()
                cell.travelWindowStartDayLbl.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))".localized()
                cell.travelWindowStartMonthYearLbl.text = "\(monthName) \(year)".localized()
            }
            if let year = endComponents.year, let month = endComponents.month, let day = endComponents.day, let weekDay = endComponents.weekday {
                cell.travelWindowEndDateLbl.text = "\(day)".localized()
                cell.travelWindowEndDayLbl.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))".localized()
                cell.travelWindowEndMonthYearLbl.text = "\(Helper.getMonthnameFromInt(monthNumber: month))  \(year)".localized()
            }
        }

        var status: String = Constant.MyClassConstants.certificateArray[indexPath.row].certificateStatus ?? ""
        status = status.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
        // all of the statuses translate perfect only unredeem needs to be changed to unredeemed
        // maybe move this to SDK at some point
        if status == "UNREDEEM" {
            status = "UNREDEEMED"
        }
        status = status.capitalized
        cell.statusLbl.text = status
        Helper.applyShadowOnUIView(view: cell.cellBaseView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        //set button tag
        cell.certificateInfoButton.tag = indexPath.row
        
        return cell
    }
}
