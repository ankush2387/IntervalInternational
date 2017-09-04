//
//  AllAvailableDestinationsIpadViewController.swift
//  IntervalApp
//
//  Created by Chetu on 01/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class AllAvailableDestinationsIpadViewController: UIViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    //Class Varaiables
    var areaArray = [RegionArea]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set corneer radius of search button
        self.searchButton.layer.cornerRadius = 5
        // set navigation right bar buttons
        
        self.title = "Available Destinations"
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(AllAvailableDestinationsIpadViewController.menuButtonClicked))
        menuButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = menuButton

    }
    
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        print("search button clicked")
    }
    
    func menuButtonClicked()  {
        print("menu button clicked");
        
        
        let optionMenu = UIAlertController(title: nil, message: "All Destinations Options", preferredStyle: .actionSheet)
        
        let viewSelectedResorts = UIAlertAction(title: "View My Selected Resorts", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            self.performSegue(withIdentifier: Constant.segueIdentifiers.showSelectedResortsIpad, sender: self)
        })
        
     
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(viewSelectedResorts)
        optionMenu.addAction(cancelAction)
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
            optionMenu.popoverPresentationController?.sourceView = self.view
            optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width,y: 0, width: 100, height: 60)
            optionMenu.popoverPresentationController!.permittedArrowDirections = .up;
        }
        
        //Present the AlertController
        self.present(optionMenu, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Buttons  Clicked
    
    @IBAction func headerButtonClicked(_ sender: UIButton) {
        let cell = sender.superview?.superview as? AvailableDestinationCountryOrContinentsTableViewCell
        
        if sender.isSelected {
            cell?.imgIconPlus?.image = UIImage.init(named: "DropArrowIcon")
            sender.isSelected = false

        } else {
            sender.isSelected = true
            cell?.imgIconPlus?.image = UIImage.init(named: "up_arrow_icon")
            
        }
        
        
        
        //self.performSegue(withIdentifier: Constant.segueIdentifiers.showSelectedResortsIpad, sender: self)
        
    }
    
    @IBAction func checkBoxClicked(_ sender: IUIKCheckbox) {
        
    }
}


extension AllAvailableDestinationsIpadViewController:UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constant.MyClassConstants.regionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.areaArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.areaCell, for: indexPath) as! AvailableDestinationPlaceTableViewCell
        
        return cell
    }
    
}


extension AllAvailableDestinationsIpadViewController:UITableViewDelegate {
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.regionCell) as! AvailableDestinationCountryOrContinentsTableViewCell
        
        cell.countryOrContinentLabel.text = Constant.MyClassConstants.regionArray[section].regionName
        return cell
    }
        
}



    



