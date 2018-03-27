//
//  PrivacyLegalViewController.swift
//  IntervalApp
//
//  Created by Chetu on 01/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class PrivacyLegalViewController: UIViewController {

    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.privacyLegalViewController
        let   doneButton = UIBarButtonItem(title: Constant.AlertPromtMessages.ok, style: .plain, target: self, action: #selector(PrivacyLegalViewController.donePressed(_:)))
        doneButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    //***** method to dismis current controller *****//
    func donePressed(_ sender: UIBarButtonItem) {
        
          self.dismiss(animated: true, completion: nil)
    }

}
extension  PrivacyLegalViewController: UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            return 80
        } else {
            return 40
        }
    }
    
    //table view delegate method to identify  row selection from tableview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != 6 {
            
            Constant.MyClassConstants.requestedWebviewURL = ""
            Constant.MyClassConstants.webviewTtile = ""
            Constant.MyClassConstants.requestedWebviewURL = Constant.WebUrls.privacyPolicyUrlArray[indexPath .row]
            Constant.MyClassConstants.webviewTtile = Constant.MyClassConstants.policyListTblCellContentArray[indexPath.row]
            self.performSegue(withIdentifier: Constant.segueIdentifiers.PolicyWebviewSegue, sender: nil)
            
        }
    }
    
}
extension PrivacyLegalViewController: UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constant.MyClassConstants.policyListTblCellContentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.loginScreenReusableIdentifiers.policyListTBLCell, for: indexPath) as! PolicyListTBLCell
        
        cell.policyListContentLabel.text = Constant.MyClassConstants.policyListTblCellContentArray[(indexPath as NSIndexPath).row]
        
        return cell
        
    }
    
}
