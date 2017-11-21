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

class RelinquishmentDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var resort: Resort?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.layer.cornerRadius = 5
        self.tableView.layer.borderWidth = 2.0
        //self.tableView.layer.masksToBounds = true
        self.tableView.layer.borderColor = UIColor.lightGray.cgColor
        
        resort = Constant.MyClassConstants.resortsDescriptionArray
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
        
        let objRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RelinquishmentDetailsCell", for: indexPath) as? RelinquishmentDetailsCell else { return UITableViewCell() }
            
                if let resortImages = resort?.images {
                    if resortImages.isEmpty == false {
                    if let urlString = resortImages[indexPath.row].url {
                        cell.resortImage.setImageWith(URL(string: urlString), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                    }
                  }
                } else {
                    cell.resortImage.image = #imageLiteral(resourceName: "NoImageIcon")
                }
            cell.resortName.text = resort?.resortName
            
            if let city = resort?.address?.cityName {
                
                cell.resortCountry.text = city
            }
            if let Country = resort?.address?.countryCode {
                
                cell.resortCountry.text?.append(", \(Country)")
            }

            cell.resortCode.text = resort?.resortCode
            
            cell.gradientView.frame = CGRect(x: cell.gradientView.frame.origin.x, y: cell.gradientView.frame.origin.y, width: cell.contentView.frame.width, height: cell.gradientView.frame.height)
            Helper.addLinearGradientToView(view: cell.gradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeCell1", for: indexPath) as? RelinquishmentSelectionOpenWeeksCell else { return UITableViewCell() }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            if let clubPoints = objRelinquishment.clubPoints {
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
            } else if let openWeek = objRelinquishment.openWeek {
                
                let dateString = openWeek.checkInDate
                let date = Helper.convertStringToDate(dateString: dateString!, format: "yyyy-MM-dd")
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = myCalendar.dateComponents([.day, .weekday, .month, .year], from: date)
                let day = myComponents.day!
                var month = ""
                if day < 10 {
                    month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) 0\(day)"
                } else {
                    month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month!)) \(day)"
                }
                
                cell.dayAndDateLabel.text = month.uppercased()
                
                if let relinquishmentYear = openWeek.relinquishmentYear {
                    cell.yearLabel.text = "\(relinquishmentYear)"
                }
                
                if let weekNumber = openWeek.weekNumber {
                    cell.totalWeekLabel.text =  "Week \(Constant.getWeekNumber(weekType: weekNumber))"
                }
                
                if let resortName = openWeek.resort?.resortName {
                    cell.resortName.text = resortName
                }
                
                cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType: (objRelinquishment.openWeek?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType: (objRelinquishment.openWeek?.unit!.kitchenType!)!))"
                cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: objRelinquishment.openWeek!.unit!.publicSleepCapacity)), \(String(describing: objRelinquishment.openWeek!.unit!.privateSleepCapacity)) Private"
                
            } else if let deposits = objRelinquishment.deposit {
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
            return 80

        }
    }
    
}
