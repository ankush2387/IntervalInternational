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
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(AccomodationCertsDetailController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton

        // Do any additional setup after loading the view.
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
         self.dismiss(animated: true, completion: nil)
    }
 
  
    @IBAction func onDetailButtonClick(_ sender: Any) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.showDestinationResortsSegue, sender: nil)
    }
 

}

extension RelinquishmentWhatToUseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            
            return Constant.MyClassConstants.filterRelinquishments.count + 1
        }
        else{
            
            return 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            if(indexPath.row == 0) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.availablePoints, for: indexPath) as! AvailablePointCell
                
                
                return cell
            }
            else{
                let exchange = Constant.MyClassConstants.filterRelinquishments[indexPath.row-1]
                
                
                if((exchange.openWeek) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    cell.contentView.layer.cornerRadius = 7
                    cell.resortDetailsView.layer.borderColor = UIColor.clear.cgColor
                    cell.dayandDateLabel.layer.borderColor = UIColor.clear.cgColor
                    Helper.applyShadowOnUIView(view: cell.contentView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.resortName.text = exchange.openWeek?.resort?.resortName!
                    cell.yearLabel.text = "\(String(describing: (exchange.openWeek?.relinquishmentYear!)!))"
                    cell.totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: (exchange.openWeek?.weekNumber!)!))"
                    cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:(exchange.openWeek?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType:(exchange.openWeek?.unit!.kitchenType!)!))"
                    cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: exchange.openWeek!.unit!.publicSleepCapacity)), \(String(describing: exchange.openWeek!.unit!.privateSleepCapacity)) Private"
                    let date = exchange.openWeek!.checkInDates
                    if(date.count > 0) {
                        
                        let dateString = date[0]
                        let date =  Helper.convertStringToDate(dateString: dateString, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
                        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                        let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: date)
                        let day = myComponents.day!
                        var month = ""
                        if(day < 10) {
                            month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                        }
                        else {
                            month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                        }
                        
                        cell.dayAndDateLabel.text = month.uppercased()
                        
                    }
                    else {
                        
                        cell.dayAndDateLabel.text = ""
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.contentBackgroundView.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }

               
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
                return 100
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




