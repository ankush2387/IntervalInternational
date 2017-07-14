//
//  RelinguishmentDetailsViewController.swift
//  IntervalApp
//
//  Created by Chetu on 12/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RelinquishmentDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClickDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RelinquishmentDetailsViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objRelinquishment = Constant.MyClassConstants.filterRelinquishments[0]

        
        if (indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customCellNibNames.relinquishmentDetailsCell, for: indexPath) as! RelinquishmentDetailsCell
            
            
            if(Constant.MyClassConstants.resortsArray.count != 0){
                if (Constant.MyClassConstants.resortsArray[indexPath.section].images.count>0){
                    var url = URL(string: "")
                    
                    let imagesArray = Constant.MyClassConstants.resortsArray[indexPath.section].images
                    for imgStr in imagesArray {
                        if(imgStr.size!.caseInsensitiveCompare(Constant.MyClassConstants.imageSize) == ComparisonResult.orderedSame) {
                            
                            url = URL(string: imgStr.url!)!
                            break
                        }
                    }
                    cell.resortImageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                    cell.resortImageView.setImageWith(url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                }
                else {
                    
                }
            }
            
            
            cell.resortName.text = objRelinquishment.openWeek?.resort?.resortName!
            cell.resortCountry.text = objRelinquishment.openWeek?.resort?.address?.cityName
            cell.resortCode.text = objRelinquishment.openWeek?.resort?.resortCode
            
            cell.gradientView.frame = CGRect(x: cell.gradientView.frame.origin.x, y: cell.gradientView.frame.origin.y, width: cell.contentView.frame.width, height: cell.gradientView.frame.height)
            Helper.addLinearGradientToView(view: cell.gradientView, colour: UIColor.white, transparntToOpaque: true, vertical: true)
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 7
            cell.layer.masksToBounds = true
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.exchangeCell1, for: indexPath) as! RelinquishmentSelectionOpenWeeksCell

            let dateString = objRelinquishment.openWeek!.checkInDate
            let date =  Helper.convertStringToDate(dateString: dateString!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
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
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.yearLabel.text = "\(String(describing: (objRelinquishment.openWeek?.relinquishmentYear!)!))"
            
            cell.totalWeekLabel.text =  "Week \(Constant.getWeekNumber(weekType: (objRelinquishment.openWeek?.weekNumber!)!))"
            
            cell.resortName.text = objRelinquishment.openWeek?.resort?.resortName!
           
            cell.bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType:(objRelinquishment.openWeek?.unit!.unitSize!)!))), \(Helper.getKitchenEnums(kitchenType:(objRelinquishment.openWeek?.unit!.kitchenType!)!))"
            cell.totalSleepAndPrivate.text = "Sleeps \(String(describing: objRelinquishment.openWeek!.unit!.publicSleepCapacity)), \(String(describing: objRelinquishment.openWeek!.unit!.privateSleepCapacity)) Private"

            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 280
        } else {
            return 70

        }
    }
    
}
