//
//  RenewelViewController.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 9/21/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class RenewelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Clicked
    
    @IBAction func selecteClicked(_ sender: UIButton) {
    }

    
    @IBAction func cancelClicked(_ sender: UIButton) {
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


//MARK:- table view datasource
extension RenewelViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.renewelCell) as! RenewelCell
        
        cell.renewelLbl.text = "Your interval membership expire before your travel date.To continue, a 1 year membership fee of $89.00 USD will be included with this transaction."
        
        
        
        
        return cell
        
    }
    
}

//MARK:- table view delegate
extension RenewelViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
    


