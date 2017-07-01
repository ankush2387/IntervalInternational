//
//  RelinquishmentWhatToUseViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 29/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RelinquishmentWhatToUseViewController: UIViewController {
    
    
    @IBOutlet weak var whatToUsetableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title  = Constant.ControllerTitles.choosewhattouse

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 
  

}

extension RelinquishmentWhatToUseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            
            return 2
        }
        else{
            
            return 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            if(indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentForExchange, for: indexPath) as UITableViewCell
                return cell
            }
            else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortBedroomDetailexchange, for: indexPath) as UITableViewCell
                
                return cell
            }

        }
        
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.relinquishmentForExchange, for: indexPath) as UITableViewCell
            return cell
        }
        
        
    }
    
}



extension RelinquishmentWhatToUseViewController: UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** return number of sections for tableview *****//
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //***** configure header cell for each section to show header labels *****//
       
        let  headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        let headerLabel = UILabel(frame: CGRect(x: 30, y: 0, width: tableView.bounds.width - 60, height: 30))
        
        if(section == 0){
            headerView.backgroundColor =  UIColor.lightGray
            headerLabel.text = "Exchange"// Header Name
            headerLabel.textColor = UIColor.darkGray
            headerView.addSubview(headerLabel)
            return headerView
        }
        else{
            headerView.backgroundColor =  UIColor.lightGray
            headerLabel.text = "Getaway"// Header Name
            headerLabel.textColor = UIColor.darkGray
            headerView.addSubview(headerLabel)
            return headerView
        }
        

        
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //***** return height for  row in each section of tableview *****//
        switch((indexPath as NSIndexPath).section) {
        case 0 :
            if(indexPath.row == 0){
                return 50
            }
            else{
                return 110
            }
            
        case 1:
            
                return 110
            
        default :
                return 70
        }
        
    }
    
       //***** retun height for header in each section of tableview *****//
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
 
}




