//
//  CertificateDetailsViewController.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 10/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class CertificateDetailsViewController: UIViewController {

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CertificateDetailsViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
        
    }
}


extension CertificateDetailsViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.certificateScreenReusableIdentifiers.certificateDetailsCell, for: indexPath) as! CertificateDetailsCell
        
        //parse certificate details datacertificate
        let certificateSummary = Constant.MyClassConstants.certificateDetailsArray
        let certificateSummary1 = [certificateSummary.header, certificateSummary.restrictedArea!.areas.map{$0.areaName!}, certificateSummary.restrictedResort!.resorts.map{$0.resortName!}, certificateSummary.footer]
        print(certificateSummary1)
        
        let strCertificateDetails = certificateSummary1.flatMap {$0}
        
        print(strCertificateDetails)
        var newStr:String = ""
       /* for str in strCertificateDetails{
            newStr.append(str)
            cell.lblCertificateDetails.text = cell.lblCertificateDetails.text! + "\(str)"
        }
        cell.lblCertificateDetails.text = newStr*/
        
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
}




