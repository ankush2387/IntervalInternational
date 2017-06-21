//
//  CertificateViewController.swift
//  IntervalApp
//
//  Created by Chetu on 22/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class CertificateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension CertificateViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 385
    }
}

extension CertificateViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.certificateScreenReusableIdentifiers.certificateCell, for: indexPath) as! CertificateCell
            cell.cellBaseView.layer.masksToBounds = true
            cell.cellBaseView.layer.cornerRadius = 5
            Helper.applyShadowOnUIView(view: cell.cellBaseView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
    }
    
}
