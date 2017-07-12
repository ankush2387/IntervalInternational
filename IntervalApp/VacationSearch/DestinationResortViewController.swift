//
//  DestinationResortViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 11/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class DestinationResortViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var tableViewDestinations:UITableView!

    //class variables
    fileprivate var tappedButtonDictionary = [Int:Bool]()
    var amenitiesString:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44 : Constant.omnitureCommonString.createAnAlert
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        // omniture tracking with event 35
        let userInfo: [String: String]
        if Constant.MyClassConstants.isFromExchange {
             userInfo = [
                Constant.omnitureCommonString.productItem : (Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.resortCode)!,
                Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
            ]
            
        } else {
             userInfo = [
                Constant.omnitureCommonString.productItem : (Constant.MyClassConstants.viewResponse.resort?.resortCode!)!,
                Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch
            ]
        }
        
        
        ADBMobile.trackAction(Constant.omnitureEvents.event35, data: userInfo)
        amenitiesString = Constant.MyClassConstants.onsiteString.appending(Constant.MyClassConstants.nearbyString)
        // Do any additional setup after loading the view.
        
    }
    
    // function body to dismiss current controller when destination resort done button pressed.
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Used to expand and contract sections
    @IBAction func toggleButtonIsTapped(_ sender: UIButton) {
        
        if let tag = tappedButtonDictionary[sender.tag]{
            
            if tag {
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
            else{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
        }
        else{
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.tableViewDestinations.reloadSections(IndexSet(integer: sender.tag), with:.automatic)
    }
    
    //***** Function to calculate dynamic height. ******//
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
}

// extension class with implementation on tableview data source methods.
extension DestinationResortViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 4 || section == 5){
            if let isOpen = tappedButtonDictionary[section]{
                if(isOpen){
                    return 2
                }else{
                    return 1
                }
                
            }else{
                return 1
            }
        } else if(section == 3 && Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements.count == 0)  {
            return 0
        }else{
            return 1
        }
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0){
            if(Constant.RunningDevice.deviceIdiom == .pad){
                return 130
            }else{
                return 80
            }
        }else if(indexPath.section == 1){
            if(Constant.RunningDevice.deviceIdiom == .pad){
                return 120
            }else{
                return 80
            }
        }else if(indexPath.section == 2){
            if(Constant.RunningDevice.deviceIdiom == .pad){
                return 130
            }else{
                return 80
            }
        }else if(indexPath.section == 3){
            var height:CGFloat
            if(Constant.RunningDevice.deviceIdiom == .pad){
                let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                if Constant.MyClassConstants.isFromExchange {
                    height = heightForView((Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements[0].description)!, font: font!, width: (Constant.MyClassConstants.runningDeviceWidth!/2) - 100)
                    return height
                    
                } else {
                    height = heightForView((Constant.MyClassConstants.viewResponse.resort?.advisements[0].description)!, font: font!, width: (Constant.MyClassConstants.runningDeviceWidth!/2) - 100)
                    return height
                }
               
            }else{
                let font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
                if Constant.MyClassConstants.isFromExchange {
                    height = heightForView((Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements[0].description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth!)
                    return height + 60
                } else {
                    height = heightForView((Constant.MyClassConstants.viewResponse.resort?.advisements[0].description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth!)
                    return height + 60
                    
                }
               
            }
        }else if(indexPath.section == 4 || indexPath.section == 5){
            
            if(indexPath.row == 1 && indexPath.section == 4){
                
              let count = Constant.MyClassConstants.onsiteArray.count + Constant.MyClassConstants.nearbyArray.count
                  //count = count + 2
                
              return CGFloat (count * 20)
                
            }else if(indexPath.row == 1 && indexPath.section == 5){
                
                if ((Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements.count)! > 1 && Constant.MyClassConstants.isFromExchange) {
                    
                    let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                    var height:CGFloat
                    if(Constant.RunningDevice.deviceIdiom == .pad){
                        height = heightForView((Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements[1].description)!, font: font!, width: (Constant.MyClassConstants.runningDeviceWidth!/2) - 100)
                        return height
                    }else{
                        height = heightForView((Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements[1].description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth!)
                        return height + 20
                    }
                }else {
                    let font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                    var height:CGFloat
                    if(Constant.RunningDevice.deviceIdiom == .pad){
                        height = heightForView((Constant.MyClassConstants.viewResponse.resort?.advisements[1].description)!, font: font!, width: (Constant.MyClassConstants.runningDeviceWidth!/2) - 100)
                        return height
                    }else{
                        height = heightForView((Constant.MyClassConstants.viewResponse.resort?.advisements[1].description)!, font: font!, width: Constant.MyClassConstants.runningDeviceWidth!)
                        return height + 20
                    }
                }
       
            }else{
              return 80
            }
        }else{
            
            if(Constant.RunningDevice.deviceIdiom == .pad){
                return 200
            }else{
                return 80
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell

            var url = URL(string: "")
            var imagesArray = [Image]()
            if Constant.MyClassConstants.isFromExchange {
                 imagesArray = (Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.images)!
            } else {
                 imagesArray = (Constant.MyClassConstants.viewResponse.resort?.images)!
                
            }
            
            for imgStr in imagesArray {
                if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                    url = URL(string: imgStr.url!)!
                    break
                }
            }
            cell.resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            
            if Constant.MyClassConstants.isFromExchange {
                cell.resortName?.text = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.resortName
                cell.resortAddress?.text = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.address?.cityName?.appending(", ").appending((Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.address?.territoryCode!)!)
                cell.resortCode?.text = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.resortCode
                
            } else {
                cell.resortName?.text = Constant.MyClassConstants.viewResponse.resort?.resortName
                cell.resortAddress?.text = Constant.MyClassConstants.viewResponse.resort?.address?.cityName?.appending(", ").appending((Constant.MyClassConstants.viewResponse.resort?.address?.territoryCode!)!)
                cell.resortCode?.text = Constant.MyClassConstants.viewResponse.resort?.resortCode
            }
            return cell
            
        }else if(indexPath.section == 1) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateCell, for: indexPath) as! CaledarDateCell
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat
           
            if Constant.MyClassConstants.isFromExchange { // for exchange process
                if let checkInDate = dateFormatter.date(from: (Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.checkInDate)!) {
                    //creating calendar date components to get date components sepratelly
                    let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate)
                    cell.checkInDayDateLabel.text = String(describing: myComponents.day!)
                    cell.checkInDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                    cell.checkInMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(myComponents.year!)"
                }
                
                let myCalendar1 = Calendar(identifier: Calendar.Identifier.gregorian)
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat
                //checkout date
                if  let checkOutDate = dateFormatter.date(from: (Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.checkOutDate)!) {
                    let myComponents1 = (myCalendar1 as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate)
                    //updating date label with date components.
                    cell.checkOutDayDateLabel.text = String(describing: myComponents1.day!)
                    cell.checkOutDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!))"
                    cell.checkOutMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(myComponents1.year!)"
                    
                }
                return cell
            } else {
                
                //for rental process
                let checkInDate = dateFormatter.date(from: (Constant.MyClassConstants.viewResponse.unit?.checkInDate)!)
                
                //creating calendar date components to get date components sepratelly
                let myComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: checkInDate!)
                cell.checkInDayDateLabel.text = String(describing: myComponents.day!)
                cell.checkInDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents.weekday!))"
                cell.checkInMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(myComponents.year!)"
                
                let myCalendar1 = Calendar(identifier: Calendar.Identifier.gregorian)
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat
                let checkOutDate = dateFormatter.date(from: (Constant.MyClassConstants.viewResponse.unit?.checkOutDate)!)
                let myComponents1 = (myCalendar1 as NSCalendar).components([.day,.weekday,.month,.year], from: checkOutDate!)
                //updating date label with date components.
                cell.checkOutDayDateLabel.text = String(describing: myComponents1.day!)
                cell.checkOutDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: myComponents1.weekday!))"
                cell.checkOutMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: myComponents1.month!)) \(myComponents1.year!)"
                
                return cell
            }
            
        }else if(indexPath.section == 2) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.unitDetailsCell1, for: indexPath) as! UnitDetailCell
            // for exchange
            
            if Constant.MyClassConstants.isFromExchange {
                
                if let roomSize = UnitSize(rawValue: (Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.unitSize!)!) {
                    
                    if let kitchenSize = KitchenType(rawValue: (Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.kitchenType!)!) {
                        cell.bedroomKitchenLabel.text = Helper.getBedroomNumbers(bedroomType: roomSize.rawValue).appending(", ").appending(Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue))
                    }
                }
                
                let totalSleepCapacity:String = String((Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.publicSleepCapacity)! + (Constant.MyClassConstants.viewResponse.unit?.privateSleepCapacity)!)
                let privateSleepCapacity:String = String(describing: (Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.privateSleepCapacity)!)
                cell.sleepLabel.text = "Sleeps " + totalSleepCapacity + " Total, " + privateSleepCapacity + " Private"
                
                return cell
            } else {
                // for rental
                
                if let roomSize = UnitSize(rawValue: (Constant.MyClassConstants.viewResponse.unit?.unitSize!)!) {
                    
                    if let kitchenSize = KitchenType(rawValue: (Constant.MyClassConstants.viewResponse.unit?.kitchenType!)!) {
                        cell.bedroomKitchenLabel.text = Helper.getBedroomNumbers(bedroomType: roomSize.rawValue).appending(", ").appending(Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue))
                    }
                }
                
                let totalSleepCapacity:String = String((Constant.MyClassConstants.viewResponse.unit?.publicSleepCapacity)! + (Constant.MyClassConstants.viewResponse.unit?.privateSleepCapacity)!)
                let privateSleepCapacity:String = String(describing: (Constant.MyClassConstants.viewResponse.unit?.privateSleepCapacity)!)
                cell.sleepLabel.text = "Sleeps " + totalSleepCapacity + " Total, " + privateSleepCapacity + " Private"
                
                return cell
                
            }
            
     
            
        }else if(indexPath.section == 3){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.advisementCell, for: indexPath) as! AdvisementsTableViewCell
            if Constant.MyClassConstants.isFromExchange {
                cell.advisementsLabel.text = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements[0].description
            } else {
                cell.advisementsLabel.text = Constant.MyClassConstants.viewResponse.resort?.advisements[0].description
            }
            
            return cell
            
        }else if(indexPath.section == 4 || indexPath.section == 5) {
            
            if(indexPath.row == 0){
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.unitsDetailCell, for: indexPath) as! AvailableDestinationCountryOrContinentsTableViewCell
                cell.tooglebutton.tag = indexPath.section
                if(indexPath.section == 4){
                    cell.countryOrContinentLabel.text = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.textUnitDetails
                }else{
                    cell.countryOrContinentLabel.text = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.textAdditionalAdvisements
                }
                
                return cell
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier:Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.amenitiesCell, for: indexPath) as! AvailableDestinationPlaceTableViewCell
                if(indexPath.section == 4){
                   
                    cell.infoLabel.text = Constant.MyClassConstants.nearbyString.appending("\n\n").appending(Constant.MyClassConstants.onsiteString)
                }else{
                    if (Constant.MyClassConstants.viewResponse.resort?.advisements.count)! > 1 {
                        
                        cell.infoLabel.text = Constant.MyClassConstants.viewResponse.resort?.advisements[1].description
                    }
                    
                }
                cell.infoLabel.sizeToFit()
                return cell
                
            }
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.additionalAdvisementCell, for: indexPath) as! UpComingTripCell
            return cell
        }
    }
}
