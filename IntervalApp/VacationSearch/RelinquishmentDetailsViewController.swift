//
//  RelinguishmentDetailsViewController.swift
//  IntervalApp
//
//  Created by Chetu on 12/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import SDWebImage
import then

class RelinquishmentDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedRelinquishment = ExchangeRelinquishment()
  
    var resort: Resort = Resort()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80

        // Do any additional setup after loading the view.
        self.tableView.layer.cornerRadius = 5
        self.tableView.layer.borderWidth = 2.0
        //self.tableView.layer.masksToBounds = true
        self.tableView.layer.borderColor = UIColor.lightGray.cgColor
       
        guard let accessToken = Session.sharedSession.userAccessToken else {
            return
        }
        
        var element = self.selectedRelinquishment.deposit?.resort
        if element == nil {
            element = self.selectedRelinquishment.accommodationCertificate?.resort
        }
        if element == nil {
            element = self.selectedRelinquishment.openWeek?.resort
        }
        if element == nil {
            element = self.selectedRelinquishment.clubPoints?.resort
        }
        if element == nil {
            element = self.selectedRelinquishment.accommodationCertificate?.resort
        }
        
        guard let resortCode = element?.resortCode else {
            return
        }
        
        ClientAPI.sharedInstance.readResort(for: accessToken, and: resortCode)
            .then { r in
                self.resort = r
                self.tableView.reloadData()
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RelinquishmentDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RelinquishmentDetailsCell", for: indexPath) as? RelinquishmentDetailsCell else { return UITableViewCell() }
           
            cell.resortCode.text = resort.resortCode
            cell.resortName.text = resort.resortName
            
            if let address = resort.address {
                cell.resortCountry.text = address.postalAddresAsString()
            }
            if let image = resort.getDefaultImage(), let imageUrl = image.url {
                cell.resortImage.setImageWith(URL(string: imageUrl), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            } else {
                cell.resortImage.image = #imageLiteral(resourceName: "NoImageIcon")
            }

            cell.gradientView.frame = CGRect(x: cell.gradientView.frame.origin.x, y: cell.gradientView.frame.origin.y, width: cell.contentView.frame.width, height: cell.gradientView.frame.height)
            Helper.addLinearGradientToView(view: cell.gradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
            return cell
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeCell1", for: indexPath) as? RelinquishmentSelectionOpenWeeksCell else { return UITableViewCell() }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            if let clubPoints = selectedRelinquishment.clubPoints {
                cell.dayAndDateLabel.text = ""
                if let pointsSpent = clubPoints.pointsSpent {
                    cell.yearLabel.text = "\(pointsSpent))"
                    cell.totalWeekLabel.text = "Club Points"
                } else {
                    cell.yearLabel.text = ""
                    cell.totalWeekLabel.text = ""
                }
                
                cell.resortName.text = clubPoints.resort?.resortName
                cell.bedroomSizeAndKitchenClient.text = ""
                cell.totalSleepAndPrivate.text = ""
                
            } else if let openWeek = selectedRelinquishment.openWeek {
                
                if let checkInDate = Date.dateFromString(openWeek.checkInDate.unwrappedString)?.formatDateAs("MM-dd"),
                    let month = checkInDate.split(separator: "-").first,
                    let day = checkInDate.split(separator: "-").last,
                    let monthNumber = Int(month) {
                    let monthName = Helper.getMonthnameFromInt(monthNumber: monthNumber).uppercased()
                    cell.dayAndDateLabel.text = "\(monthName) \(day)"
                }
                
                if let relinquishmentYear = openWeek.relinquishmentYear {
                    cell.yearLabel.text = "\(relinquishmentYear)"
                }
                
                if let weekNumber = openWeek.weekNumber {
                    cell.totalWeekLabel.text =  "Week \(Constant.getWeekNumber(weekType: weekNumber))"
                }
                
                if let resortName = openWeek.resort?.resortName {
                    cell.resortName.text = resortName
                }
                if let unitSize = selectedRelinquishment.openWeek?.unit?.unitSize, let kitchenType = selectedRelinquishment.openWeek?.unit?.kitchenType {
                    cell.bedroomSizeAndKitchenClient.text = "\(Helper.getBedroomNumbers(bedroomType:unitSize)), \(Helper.getKitchenEnums(kitchenType: kitchenType))"
                }
                
                if let publicSleeps = selectedRelinquishment.openWeek?.unit?.publicSleepCapacity, let privateSleeps = selectedRelinquishment.openWeek?.unit?.privateSleepCapacity {
                   cell.totalSleepAndPrivate.text = "Sleeps \(publicSleeps), \(privateSleeps) Private"
                }
                
            } else if let deposits = selectedRelinquishment.deposit {
                
                if let checkInDate = Date.dateFromString(deposits.checkInDate.unwrappedString)?.formatDateAs("MM-dd"),
                    let month = checkInDate.split(separator: "-").first,
                    let day = checkInDate.split(separator: "-").last,
                    let monthNumber = Int(month) {
                    let monthName = Helper.getMonthnameFromInt(monthNumber: monthNumber).uppercased()
                    cell.dayAndDateLabel.text = "\(monthName) \(day)"
                }
                
                if let relinquishmentYear = deposits.relinquishmentYear {
                    cell.yearLabel.text = "\(relinquishmentYear)"
                }
                
                if let weekNumber = deposits.weekNumber {
                cell.totalWeekLabel.text =  "Week \(Constant.getWeekNumber(weekType: weekNumber))"
                }
                
                if let resortName = deposits.resort?.resortName {
                    cell.resortName.text = resortName
                }
                
                var bedroomKitchenString = ""
                if let unitSize = deposits.unit?.unitSize {
                    bedroomKitchenString = Helper.getBedroomNumbers(bedroomType:unitSize)
                }
                
                if let kitchenType = deposits.unit?.kitchenType {
                    let kitchenString = Helper.getKitchenEnums(kitchenType: kitchenType)
                    bedroomKitchenString = bedroomKitchenString.appending(", \(kitchenString)")
                }
                
                cell.bedroomSizeAndKitchenClient.text = bedroomKitchenString
                
                var totalSleeps = ""
                if let publicSleepCapacity = deposits.unit?.publicSleepCapacity {
                    totalSleeps = "\(publicSleepCapacity)"
                }
                if let privateSleepCapacity = deposits.unit?.privateSleepCapacity {
                    totalSleeps = totalSleeps.appending(", \(privateSleepCapacity)")
                }
                
                cell.totalSleepAndPrivate.text = "Sleeps \(totalSleeps) Private"
            }
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if Constant.RunningDevice.deviceIdiom == .phone {
                return 280
            } else {
                return 450
            }
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
}
