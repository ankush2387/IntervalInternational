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
    @IBOutlet weak var tableViewDestinations: UITableView!
    
    //class variables
    fileprivate var tappedButtonDictionary = [Int: Bool]()
    var amenitiesString: String = ""
    var unitDetialsCellHeight: CGFloat = 0.0
    var advisementSectionHeight: CGFloat = 0.0
    var additionalAdvisementCellHeight: CGFloat = 0.0
    var detailsView: UIView?
    var advisementView: UIView?
    var additionalAdvisementView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.createAnAlert
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        // omniture tracking with event 35
        /* let userInfo: [String: String]
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
         amenitiesString = Constant.MyClassConstants.onsiteString.appending(Constant.MyClassConstants.nearbyString)*/
        // Do any additional setup after loading the view.
        
    }
    
    // function body to dismiss current controller when destination resort done button pressed.
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Used to expand and contract sections
    @IBAction func toggleButtonIsTapped(_ sender: UIButton) {
        
        if let tag = tappedButtonDictionary[sender.tag] {
            
            if tag {
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            } else {
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
        } else {
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        self.tableViewDestinations.reloadData()
    }
    
    func addSepratorView(onView: UIView?) {
        
        guard let onview = onView else { return }
        let sepratorView = UIView(frame: CGRect(x: 0, y: onview.frame.size.height - 3, width: view.frame.size.width, height: 2))
            sepratorView.backgroundColor = #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7921568627, alpha: 1)
        
        onview.addSubview(sepratorView)
    }
    
    // function to get all advisement from API response and return view with all advisement with title and description
    func getAdvisements() -> UIView {
        
        var isSepratorNeeded = false
        var advisements: [Advisement]?
        if Constant.MyClassConstants.isFromExchange ||
            Constant.MyClassConstants.searchBothExchange {
            advisements = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements
            let advisements = Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.amenities.count ?? 0
            isSepratorNeeded = advisements > 0 ? true : false
        } else {
            advisements = Constant.MyClassConstants.viewResponse.destination?.resort?.advisements
            let advisements = Constant.MyClassConstants.viewResponse.destination?.resort?.amenities.count ?? 0
            isSepratorNeeded = advisements > 0 ? true : false
        }
        guard let resortAdvisements = advisements else { return UIView() }
        advisementView = UIView()
        advisementSectionHeight = 10
        for advisement in resortAdvisements {
            let isAdditionalAdvisement = advisement.title?.contains("ADDITIONAL INFORMATION") ?? false
            if !isAdditionalAdvisement {
                let titleLabel = UILabel(frame: CGRect(x: 20, y: advisementSectionHeight, width: view.frame.width - 20, height: 20))
                titleLabel.text = advisement.title
                titleLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
                titleLabel.textColor = UIColor.lightGray
                advisementView?.addSubview(titleLabel)
                advisementSectionHeight = advisementSectionHeight + 25
                
                let descriptionLabel: UILabel = UILabel(frame: CGRect(x: 20, y: advisementSectionHeight, width: view.frame.size.width - 40, height: 0))
                
                descriptionLabel.numberOfLines = 0
                descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                descriptionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                descriptionLabel.text = advisement.description.joined(separator: "")
                descriptionLabel.sizeToFit()
                advisementView?.addSubview(descriptionLabel)
                advisementSectionHeight = advisementSectionHeight + descriptionLabel.frame.height + 10
            } else {
                additionalAdvisementView = UIView()
                additionalAdvisementCellHeight = 10
                let descriptionLabel: UILabel = UILabel(frame: CGRect(x: 20, y: additionalAdvisementCellHeight, width: view.frame.size.width - 40, height: 0))
                descriptionLabel.numberOfLines = 0
                descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                descriptionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 16.0)
                descriptionLabel.text = advisement.description.joined(separator: "")
                descriptionLabel.sizeToFit()
                additionalAdvisementView?.addSubview(descriptionLabel)
                additionalAdvisementCellHeight = additionalAdvisementCellHeight + descriptionLabel.frame.height + 10
                additionalAdvisementView?.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: additionalAdvisementCellHeight)
            }
           
        }
        advisementView?.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: advisementSectionHeight)
        if isSepratorNeeded {
            addSepratorView(onView: advisementView)
        }
        return advisementView ?? UIView()
    }
    
    // function to get all amenities under unit from API response and return view with all amenities with title and description
    func getUnitDetails() -> UIView {
        
        var isSepratorNeeded = false
        var inventoryUnit: InventoryUnit?
        if Constant.MyClassConstants.isFromExchange ||
            Constant.MyClassConstants.searchBothExchange {
            inventoryUnit = Constant.MyClassConstants.exchangeViewResponse.destination?.unit
            let advisements = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements.count ?? 0
            isSepratorNeeded = advisements > 0 ? true : false
        } else {
            inventoryUnit = Constant.MyClassConstants.viewResponse.destination?.unit
            let advisements = Constant.MyClassConstants.viewResponse.destination?.resort?.advisements.count ?? 0
            isSepratorNeeded = advisements > 0 ? true : false
        }
        guard let unitDetils = inventoryUnit else { return UIView() }
        detailsView = UIView()
        for amunities in unitDetils.amenities {
            
            let sectionLabel = UILabel(frame: CGRect(x: 20, y: unitDetialsCellHeight, width: view.frame.width - 20, height: 20))
            if let category = amunities.category {
                sectionLabel.text = Helper.getMappedStringForDetailedHeaderSection(sectonHeader: category).localized()
            }
            sectionLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
            sectionLabel.textColor = UIColor.lightGray
            detailsView?.addSubview(sectionLabel)
            unitDetialsCellHeight = unitDetialsCellHeight + 25
            
            for details in amunities.details {
                
                let detailSectionLabel = UILabel(frame: CGRect(x: 20, y: unitDetialsCellHeight, width: view.frame.width - 20, height: 20))
                if let  section = details.section {
                    detailSectionLabel.text = section.capitalized
                }
                detailSectionLabel.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 16.0)
                detailSectionLabel.sizeToFit()
                
                detailsView?.addSubview(detailSectionLabel)
                if let detailString = detailSectionLabel.text {
                    if detailString.count > 0 {
                        unitDetialsCellHeight = unitDetialsCellHeight + 20
                    }
                }
                
                for desc in details.descriptions {
                    
                    let detaildescLabel = UILabel(frame: CGRect(x: 20, y: unitDetialsCellHeight, width: view.frame.width - 20, height: 20))
                    if sectionLabel.text == "Other Facilities" || sectionLabel.text == "Kitchen Facilities" {
                        detaildescLabel.text = "\u{2022} \(desc)".localized()
                    } else {
                        detaildescLabel.text = desc
                    }
                    detaildescLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 14.0)
                    detaildescLabel.sizeToFit()
                    detailsView?.addSubview(detaildescLabel)
                    unitDetialsCellHeight = unitDetialsCellHeight + 20
                }
                unitDetialsCellHeight = unitDetialsCellHeight + 20
            }
        }
        detailsView?.frame = CGRect(x: 0, y: 20, width: view.frame.size.width, height: unitDetialsCellHeight)
        if isSepratorNeeded {
            addSepratorView(onView: detailsView)
        }
        return detailsView ?? UIView()
    }
    
}

// extension class with implementation on tableview data source methods.
extension DestinationResortViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0, 1, 2:
            return 1
        case 3:
            if Constant.MyClassConstants.isFromExchange ||
                Constant.MyClassConstants.searchBothExchange {
                guard let advisements = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements else { return 0 }
                return advisements.count > 0 ? 1 : 0
            } else {
                 guard let advisements = Constant.MyClassConstants.viewResponse.destination?.resort?.advisements else { return 0 }
                return advisements.count > 0 ? 1 : 0
            }
        case 4:
            if Constant.MyClassConstants.isFromExchange ||
                Constant.MyClassConstants.searchBothExchange {
                guard let amenities = Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.amenities else { return 0 }
                if amenities.isEmpty {
                    return 0
                } else {
                    let isOpen = tappedButtonDictionary[section] ?? false
                    return isOpen ? 2 : 1
                }
               
            } else {
                guard let amenities = Constant.MyClassConstants.viewResponse.destination?.unit?.amenities else { return 0 }
                if amenities.isEmpty {
                    return 0
                } else {
                    let isOpen = tappedButtonDictionary[section] ?? false
                    return isOpen ? 2 : 1
                }
            }
        case 5:
            if Constant.MyClassConstants.isFromExchange ||
                Constant.MyClassConstants.searchBothExchange {
                guard let advisements = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.advisements else { return 0 }
                if advisements.isEmpty {
                    return 0
                } else {
                    let isOpen = tappedButtonDictionary[section] ?? false
                    return isOpen ? 2 : 1
                }
               
            } else {
                guard let advisement = Constant.MyClassConstants.viewResponse.destination?.resort?.advisements else { return 0 }
                if advisement.isEmpty {
                    return 0
                } else {
                    let isOpen = tappedButtonDictionary[section] ?? false
                    return isOpen ? 2 : 1
                }
               
            }
        default:
            return 0
        }
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0, 2:
            if Constant.RunningDevice.deviceIdiom == .pad {
                return 130
            } else {
                return 80
            }
        case 1:
            if Constant.RunningDevice.deviceIdiom == .pad {
                return 120
            } else {
                return 80
            }
        case 3:
            return advisementSectionHeight + 20
        case 4:
            if indexPath.row == 0 {
                return 50
            } else {
                if tappedButtonDictionary[indexPath.section] == false {
                    return 50
                } else {
                    return unitDetialsCellHeight + 20
                }
            }
        case 5:
            if indexPath.row == 0 {
                return 50
            } else {
                if tappedButtonDictionary[indexPath.section] == false {
                    return 50
                } else {
                    return additionalAdvisementCellHeight + 20
                }
            }
        default :
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.viewDetailsTBLcell, for: indexPath) as! ViewDetailsTBLcell
            
            var url = URL(string: "")
            var imagesArray = [Image]()
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                imagesArray = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.images ?? []
            } else {
                imagesArray = Constant.MyClassConstants.viewResponse.destination?.resort?.images ?? []
                
            }
            
            for imgStr in imagesArray {
                if imgStr.size?.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame {
                    if let imgURL = imgStr.url {
                        url = URL(string: imgURL)
                    }
                    break
                }
            }
            cell.resortImageView?.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                
                cell.resortName?.text = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.resortName
                if let address = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.address {
                    cell.resortAddress?.text = address.postalAddresAsString()
                }
                cell.resortCode?.text = Constant.MyClassConstants.exchangeViewResponse.destination?.resort?.resortCode
                
            } else {
                
                cell.resortName?.text = Constant.MyClassConstants.viewResponse.destination?.resort?.resortName
                if let address = Constant.MyClassConstants.viewResponse.destination?.resort?.address {
                    cell.resortAddress?.text = address.postalAddresAsString()
                }
                cell.resortCode?.text = Constant.MyClassConstants.viewResponse.destination?.resort?.resortCode
            }
            return cell
            
        case 1 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.dateCell, for: indexPath) as? CaledarDateCell else { return UITableViewCell() }
           
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                
                // for exchange process
                if let checkInDate = Constant.MyClassConstants.exchangeViewResponse.destination?.checkInDate?.dateFromString(for: Constant.MyClassConstants.dateFormat) {
                    
                    let DateComponents = Calendar.current.dateComponents([.day, .weekday, .month, .year], from: checkInDate)
                    cell.checkInDayDateLabel.text = "\(DateComponents.day ?? 0)".localized()
                    cell.checkInDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: DateComponents.weekday ?? 0))".localized()
                    cell.checkInMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: DateComponents.month ?? 0)) \(DateComponents.year ?? 0)".localized()
                } else {
                    cell.checkInDayDateLabel.text = ""
                    cell.checkInDayNameLabel.text = ""
                    cell.checkInMonthYearLabel.text = ""
                }
                
                if let checkOutDate = Constant.MyClassConstants.exchangeViewResponse.destination?.checkOutDate?.dateFromString(for: Constant.MyClassConstants.dateFormat) {
                    
                    let checkOutDateComponents = Calendar.current.dateComponents([.day, .weekday, .month, .year], from: checkOutDate)
                    cell.checkOutDayDateLabel.text = String(checkOutDateComponents.day ?? 0).localized()
                    cell.checkOutDayNameLabel.text = String(Helper.getWeekdayFromInt(weekDayNumber: checkOutDateComponents.weekday ?? 0)).localized()
                    cell.checkOutMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: checkOutDateComponents.month ?? 0)) \(checkOutDateComponents.year ?? 0)".localized()
                } else {
                    cell.checkOutDayDateLabel.text = ""
                    cell.checkOutDayNameLabel.text = ""
                    cell.checkOutMonthYearLabel.text = ""
                }
                return cell
                
            } else {
                
                //for rental process
                if let checkInDate = Constant.MyClassConstants.viewResponse.destination?.unit?.checkInDate?.dateFromString(for: Constant.MyClassConstants.dateFormat) {
                    
                    let checkInDateComponents = Calendar.current.dateComponents([.day, .weekday, .month, .year], from: checkInDate)
                    cell.checkInDayDateLabel.text = String(checkInDateComponents.day ?? 0).localized()
                    cell.checkInDayNameLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: checkInDateComponents.weekday ?? 0))"
                    cell.checkInMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: checkInDateComponents.month ?? 0)) \(checkInDateComponents.year ?? 0)"
                } else {
                    cell.checkInDayDateLabel.text = ""
                    cell.checkInDayNameLabel.text = ""
                    cell.checkInMonthYearLabel.text = ""
                }
            
                if let checkOutDate = Constant.MyClassConstants.viewResponse.destination?.unit?.checkOutDate?.dateFromString(for: Constant.MyClassConstants.dateFormat) {
                    
                    let checkOutDateComponents = Calendar.current.dateComponents([.day, .weekday, .month, .year], from: checkOutDate)
                    //updating date label with date components.
                    cell.checkOutDayDateLabel.text = String(checkOutDateComponents.day ?? 0).localized()
                    cell.checkOutDayNameLabel.text = String(Helper.getWeekdayFromInt(weekDayNumber: checkOutDateComponents.weekday ?? 0))?.localized()
                    cell.checkOutMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: checkOutDateComponents.month ?? 0)) \(checkOutDateComponents.year ?? 0)"
                } else {
                    
                    cell.checkOutDayDateLabel.text = ""
                    cell.checkOutDayNameLabel.text = ""
                    cell.checkOutMonthYearLabel.text = ""
                }
                
                return cell
            }
        case 2 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.unitDetailsCell1, for: indexPath) as? UnitDetailCell else { return UITableViewCell() }
            
            // for exchange search
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                
                var roomSize = ""
                var kitchenSize = ""
                var totalSleepCapacity = 0
                var privateSleepCapacity = 0
                
                if let unitSize = Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.unitSize {
                    if let bedRoomSize = UnitSize(rawValue: unitSize) {
                        roomSize = Helper.getBedroomNumbers(bedroomType: bedRoomSize.rawValue)
                    }
                }
                if let kitchen = Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.kitchenType {
                    if let kitchenType = KitchenType(rawValue:  kitchen) {
                        kitchenSize = Helper.getKitchenEnums(kitchenType: kitchenType.rawValue)
                    }
                }
                cell.bedroomKitchenLabel.text = "\(roomSize), \(kitchenSize)".localized()
                
                if let publicSleepCapacity = Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.publicSleepCapacity {
                    totalSleepCapacity += publicSleepCapacity
                }
                if let privateCapacity = Constant.MyClassConstants.exchangeViewResponse.destination?.unit?.privateSleepCapacity {
                    totalSleepCapacity += privateCapacity
                    privateSleepCapacity = privateCapacity
                }
                cell.sleepLabel.text = "Sleeps \(totalSleepCapacity) Total, \(privateSleepCapacity) Private".localized()
                return cell
                
            } else {
                // for rental search
                if let roomSize = Constant.MyClassConstants.viewResponse.destination?.unit?.unitSize, let kitchen = Constant.MyClassConstants.viewResponse.destination?.unit?.kitchenType {
                    guard let roomSize = UnitSize(rawValue: roomSize) else { return cell }
                    guard let kitchenSize = KitchenType(rawValue: kitchen) else { return cell }
                    cell.bedroomKitchenLabel.text = Helper.getBedroomNumbers(bedroomType: roomSize.rawValue).appending(", ").appending(Helper.getKitchenEnums(kitchenType: kitchenSize.rawValue))
                }
                if let totalSleeps = Constant.MyClassConstants.viewResponse.destination?.unit?.publicSleepCapacity, let privateSleeps = Constant.MyClassConstants.viewResponse.destination?.unit?.privateSleepCapacity {
                    cell.sleepLabel.text = "Sleeps \(totalSleeps) Total, \(privateSleeps) Private"
                }
                return cell
                
            }
        case 3 :
            let cell = UITableViewCell()
            if advisementView == nil {
                cell.addSubview(getAdvisements())
            } else {
                guard let advisementview = advisementView else { return cell }
                cell.addSubview(advisementview)
            }
            
            return cell
        case 4, 5 :
            if indexPath.row == 0 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.unitsDetailCell, for: indexPath) as? AvailableDestinationCountryOrContinentsTableViewCell else { return UITableViewCell() }
                    cell.tooglebutton.tag = indexPath.section
                    let isOpen = tappedButtonDictionary[indexPath.section] ?? false
                    if isOpen {
                        cell.dropDownArrowImage.image = #imageLiteral(resourceName: "up_arrow_icon")
                    } else {
                        cell.dropDownArrowImage.image = #imageLiteral(resourceName: "DropArrowIcon")
                    }
                if indexPath.section == 4 {
                    cell.countryOrContinentLabel.text = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.textUnitDetails
                } else {
                    cell.countryOrContinentLabel.text = Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.textAdditionalAdvisements
                }
                return cell
                
            } else {
                let cell = UITableViewCell()
                if indexPath.section == 4 {
                    if detailsView == nil {
                        cell.addSubview(getUnitDetails())
                    } else {
                        guard let unitDetialsView = detailsView else { return cell }
                        cell.addSubview(unitDetialsView)
                    }
                    return cell
                } else {
                    guard let additionalAdvisementView = additionalAdvisementView else { return cell }
                    cell.addSubview(additionalAdvisementView)
                    return cell
                }
            }
        default :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.additionalAdvisementCell, for: indexPath) as? UpComingTripCell else { return UITableViewCell() }
            return cell
        }
    }
}
