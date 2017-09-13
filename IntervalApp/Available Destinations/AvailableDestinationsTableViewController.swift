//
//  AvailableDestinationsTableViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/14/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class AvailableDestinationsTableViewController: UIViewController {

    //Outlets
    @IBOutlet var availableCountryListTableView: UITableView!
    
    //Used to expand and contract sections
    @IBAction func toggleButtonIsTapped(_ sender: UIButton) {
        if let tag = tappedButtonDictionary[sender.tag]{
            if tag{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
            else{
                tappedButtonDictionary.updateValue(!tag, forKey: sender.tag)
            }
            
        }
        else{
            tappedButtonDictionary.updateValue(true, forKey: sender.tag)
        }
        availableCountryListTableView.reloadSections(IndexSet(integer: sender.tag), with:.automatic)
        
    }
    
    @IBAction func placeCheckBoxIsTapped(_ sender: UIView) {
        
        let tagString = String(sender.tag)
       let placeSelectionMainDictionarykey = Int(String(tagString.characters.last!))
       
        if let key = placeSelectionDictionary[sender.tag]{
            if key{
                placeSelectionDictionary.removeValue(forKey: sender.tag)
            }
        }
        else{
            
            placeSelectionDictionary.updateValue(true, forKey: sender.tag)
        }
        
        var tempSelectionDictionary = [Int:Bool]()
        for (key,value) in placeSelectionDictionary{
            let keyString = String(key)
            let dictionaryKey = Int(String(keyString.characters.last!))
            if placeSelectionMainDictionarykey == dictionaryKey{
                tempSelectionDictionary.updateValue(value, forKey: key)
            }

        }
        placeSelectionMainDictionary.updateValue(tempSelectionDictionary, forKey: placeSelectionMainDictionarykey!)
        //placeSelectionMainDictionary.updateValue(placeSelectionDictionary, forKey: placeSelectionMainDictionarykey!)
        availableCountryListTableView.reloadSections(IndexSet(integer: placeSelectionMainDictionarykey!), with:.automatic)
        
    }
    
    
    
    
    // Class Variables
    fileprivate let countryArray = ["India","US","UK","Africa"]
    fileprivate var placeSelectionMainDictionary = [Int:[Int:Bool]]()
    fileprivate var placeSelectionDictionary = [Int:Bool]()
    
    
    fileprivate var tappedButtonDictionary = [Int:Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
       
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let isOpen = tappedButtonDictionary[section]{
            if isOpen{
                return countryArray.count + 1
            }
            else{
                return 1
            }
            
        }
        return 1
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var availabledestionCountryOrContinentsCell :AvailableDestinationCountryOrContinentsTableViewCell?
        var availableCountryCell:AvailableDestinationPlaceTableViewCell?
       
        if let isOpen = tappedButtonDictionary[(indexPath as NSIndexPath).section]{
            if isOpen && (indexPath as NSIndexPath).row > 0{
                availableCountryCell = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationPlaceTableViewCell) as? AvailableDestinationPlaceTableViewCell
                if let _ = placeSelectionMainDictionary[(indexPath as NSIndexPath).section]{
                    availableCountryCell?.getCell(indexPath,selectedPlaceDictionary:placeSelectionMainDictionary[(indexPath as NSIndexPath).section]!)
                }
                else{
                    availableCountryCell?.getCell(indexPath)
                }
                
                
                return availableCountryCell!
            }
            else{
                availabledestionCountryOrContinentsCell  = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationCountryOrContinentsTableViewCell) as? AvailableDestinationCountryOrContinentsTableViewCell
                if let selectedPlacedictionary = placeSelectionMainDictionary[(indexPath as NSIndexPath).section]{
                    availabledestionCountryOrContinentsCell?.getCell((indexPath as NSIndexPath).section,islistOfCountry:isOpen,selectedPlaceDictionary:selectedPlacedictionary)
                }
                else{
                    availabledestionCountryOrContinentsCell?.getCell((indexPath as NSIndexPath).section,islistOfCountry:isOpen)
                }
                
                return availabledestionCountryOrContinentsCell!
            }
        }
        else{
            availabledestionCountryOrContinentsCell  = tableView.dequeueReusableCell(withIdentifier: Constant.availableDestinationsTableViewController.availableDestinationCountryOrContinentsTableViewCell) as? AvailableDestinationCountryOrContinentsTableViewCell
           
                availabledestionCountryOrContinentsCell?.getCell((indexPath as NSIndexPath).section)
            
            return availabledestionCountryOrContinentsCell!
        }
        
        
    }
    
    /*override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "A"
    }*/

     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var leading:NSLayoutConstraint?
        var trailing:NSLayoutConstraint?
        var top:NSLayoutConstraint?
        var bottom:NSLayoutConstraint?
        var height:NSLayoutConstraint?
        
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.size.width,height: 30))
            
        headerView.backgroundColor = UIColor.clear
        //Sub views for header view
        let topHorizontalSeperatorView = UIView()
        if section != 0{
            headerView.addSubview(topHorizontalSeperatorView)
        }
        
        topHorizontalSeperatorView.backgroundColor = UIColor.gray
        //Label for header title
        let titleLabel = UILabel()
        headerView.addSubview(titleLabel)
        titleLabel.text = "United States"
        
        leading = NSLayoutConstraint(item: titleLabel, attribute: .leadingMargin, relatedBy: .equal, toItem: headerView, attribute: .leadingMargin, multiplier: 1.0, constant: 10)
        trailing = NSLayoutConstraint(item: titleLabel, attribute: .trailingMargin, relatedBy: .equal, toItem: headerView, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
        if section == 0{
            top = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1.0, constant: 0)
        }
        else{
            top = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: topHorizontalSeperatorView, attribute: .top, multiplier: 1.0, constant: 0)

        }
                bottom = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1.0, constant: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leading!,trailing!,top!,bottom!])
        headerView.addConstraints([leading!,trailing!,top!,bottom!])

        
        /** Auto layout for horizontal seperator */
        
         leading = NSLayoutConstraint(item: topHorizontalSeperatorView, attribute: .leadingMargin, relatedBy: .equal, toItem: headerView, attribute: .leadingMargin, multiplier: 1.0, constant: 0)
         trailing = NSLayoutConstraint(item: topHorizontalSeperatorView, attribute: .trailingMargin, relatedBy: .equal, toItem: headerView, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
         top = NSLayoutConstraint(item: topHorizontalSeperatorView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1.0, constant: 0)
         height = NSLayoutConstraint(item: topHorizontalSeperatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 2)
        if section != 0{
            topHorizontalSeperatorView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([leading!,trailing!,top!,height!])
            headerView.addConstraints([leading!,trailing!,top!,height!])
        }
        
        
        return headerView
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
