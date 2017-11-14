//
//  CertificateDetailsViewController.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 10/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SVProgressHUD

class CertificateDetailsViewController: UIViewController {

    // clas  variables
    var certificateDetailsResponse = AccommodationCertificateSummary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Clicked
    @IBAction func onClickedDone(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - tableview delegate
extension CertificateDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

// MARK: - tableview datasource
extension CertificateDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()
        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Constant.certificateScreenReusableIdentifiers.certificateDetailsCell)
        
        let response = certificateDetailsResponse
        let newLine = "\n"
        let newLine2 = "\n\n"
        
        let headerString = response.header.joined(separator: newLine)
        
        let footer = response.footer.joined(separator: newLine)
        
        //restricted area
        var areaLbl = ""
        if let label = response.restrictedArea?.label {
            areaLbl = label
        }
        
        let areasCombined = response.restrictedArea?.areas.map { $0.areaName } as! [String]
        let areaString = areasCombined.joined(separator: newLine)
        
        //resort
        var resortLbl = ""
        if let label = response.restrictedResort?.label {
            resortLbl = label
        }
        
        let resortCombined = response.restrictedResort?.resorts.map { $0.resortName } as! [String]
        let resortString = resortCombined.joined(separator: newLine)
        
        let finaStr = headerString + newLine2 + areaLbl + areaString + newLine2 + resortLbl + resortString + newLine2 + footer
        
        // cell title
        cell.textLabel?.text = Constant.MyClassConstants.certificateDetailsCellTitle + newLine
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: Constant.fontName.helveticaNeue, size: 20)

        //detail text
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = finaStr
        cell.detailTextLabel?.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
}
