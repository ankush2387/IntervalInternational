//
//  BookYourSelectionViewController.swift
//  IntervalApp
//
//  Created by Chetu on 07/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class BookYourSelectionViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Get dynamic rows
        self.getNumberOfRows()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constant.ControllerTitles.bookYourSelectionController
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(AccomodationCertsDetailController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
       self.dismiss(animated: true, completion: nil)
    }
    
    // Function to get dynamic number of rows according to API response
    
    func getNumberOfRows(){
        
    }
}

//***** MARK: Extension classes starts from here *****//

extension BookYourSelectionViewController:UITableViewDelegate {
    
    //***** UITableview delegate methods definition here *****//
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            //***** Return height according to section cell requirement *****//
            switch((indexPath as NSIndexPath).section) {
            case 0 :
                return 70
            case 1:
                    if((indexPath as NSIndexPath).row == 0) {
                        return 100
                    }
                    else {
                        return 100
                    }
                
            case 2:
                return 70
            default :
                return 70
        }
    }
    
    //***** Implementing header and footer cell for all sections  *****//
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        let headerTextLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.bounds.width - 30, height: 30))
        
        if(section == 0) {
            
                headerView.backgroundColor = UIColor.yellow
                headerTextLabel.text = ""
                headerTextLabel.textColor = IUIKColorPalette.primaryText.color
                headerView.addSubview(headerTextLabel)
                return headerView
           
        }
        else if(section == 1) {
                headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
                headerTextLabel.text = Constant.HeaderViewConstantStrings.exchange
                headerTextLabel.textColor = UIColor.black
                headerView.addSubview(headerTextLabel)
                return headerView
            }
        else {
                
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            headerTextLabel.text = Constant.HeaderViewConstantStrings.getaways
            headerTextLabel.textColor = UIColor.black
            headerView.addSubview(headerTextLabel)
            return headerView

            }
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }

}

extension BookYourSelectionViewController:UITableViewDataSource {
    
    //***** UITableview dataSource methods definition here *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            
        case 0:
                return 1
        case 1:
                return Constant.MyClassConstants.filterRelinquishments.count
        case 2:
                return 1
        default:
                return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
            if((indexPath as NSIndexPath).section == 0 ) {
                
                //***** Configure and return cell according to sections in tableview *****//
                    
                    let cell: DestinationResortDetailCell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.destinationResortDetailCell, for: indexPath) as! DestinationResortDetailCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                    
                    return cell
            }
        
            else if((indexPath as NSIndexPath).section == 1) {
                
               let exchange = Constant.MyClassConstants.filterRelinquishments[indexPath.row]
                
                if((exchange.pointsProgram) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.contentBackgroundView.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                }else if((exchange.clubPoints) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.contentBackgroundView.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                }else if((exchange.openWeek) != nil){
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell
                    cell.contentView.layer.cornerRadius = 7
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
                
                //***** Configure and return calendar cell  *****//
               /* if((indexPath as NSIndexPath).row == 0) {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell0, for: indexPath) as! ExchangeCell0
                    cell.contentBackgroundView.layer.cornerRadius = 7
                    Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
                else {
                    
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! ExchangeCell1
                cell.contentBackgroundView.layer.cornerRadius = 7
                Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell*/
            }
            else {
                
                //***** Configure and return search vacation cell *****//
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.getawaysCell, for: indexPath) as! GetawaysCell
                cell.contentBackgroundView.layer.cornerRadius = 7
                Helper.applyShadowOnUIView(view: cell.contentBackgroundView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
                
            }
    }
}
