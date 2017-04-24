//
//  ClubPointPageItemViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/9/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class ClubPointPageItemViewController: UIViewController {
    /** Outlets */
    @IBOutlet weak var verticalLine: UIView!
    @IBOutlet weak var clubPointTableView: UITableView!
    /** 
    Set View of First Check Box when first check box clicked
    - parameter sender : AnyObject
    - returns : No return Value
    */
    @IBAction func firstCheckBoxValueIsChanged(sender: AnyObject) {
       
        let firstCheckBox = sender as! IUIKCheckbox
        if firstCheckBox.checked{
        currentCheckBoxTags = sender.tag
        ischeckbox = true
        
        ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.updateValue(currentCheckBoxTags, forKey: pageItemIndex)
            reloadTableViewData()
        }
        else{
            ischeckbox = false
            currentCheckBoxTags = 0
             ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.updateValue(currentCheckBoxTags, forKey: pageItemIndex)
            reloadTableViewData()
        }
        
        //print(currentCheckBoxTags)
    }
    /**
     Set View of Second Check Box when first check box clicked
     - parameter sender : AnyObject
     - returns : No return Value
     */
    @IBAction func secondCheckBoxValueIsChanged(sender: AnyObject) {
        
        let secondCheckBox = sender as! IUIKCheckbox
        if secondCheckBox.checked{
            ischeckbox = true
            currentCheckBoxTags = sender.tag
            ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.updateValue(currentCheckBoxTags, forKey: pageItemIndex)
            reloadTableViewData()
        }
        else{
            ischeckbox = false
            currentCheckBoxTags = 0
            ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.updateValue(currentCheckBoxTags, forKey: pageItemIndex)
            reloadTableViewData()
        }
        
       //print(currentCheckBoxTags)
    }
    
    /** Class Variables  */
    var currentCheckBoxTags  = 0
    static var checkBoxDictionaryWithpageNumber = [Int : Int]()
    var ischeckbox:Bool = false
    var pageItemIndex: Int = 0{
        didSet{
            guard let _ = ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber[pageItemIndex] else{
                ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.updateValue(currentCheckBoxTags, forKey: pageItemIndex)
                return
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(verticalLine)
        //print("itemindex=\(pageItemIndex)")
        if ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.count  == 0{
            ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber.updateValue(currentCheckBoxTags, forKey: pageItemIndex)
        }
        

        // Do any additional setup after loading the view.
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    /** 
    Reload table view data
    - parameter No Parameter:
    - returns : No return value
    */
    private func reloadTableViewData(){
        clubPointTableView.reloadData()
    }
    

}
/** Extension for UITableViewDataSource */
extension ClubPointPageItemViewController:UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell1:ClubPointWithCheckBoxTableViewCell?
        let cell2 :ClubPointTableViewCell?
        if indexPath.row%2 == 0{
           
             cell1 =  tableView.dequeueReusableCellWithIdentifier("cell2") as? ClubPointWithCheckBoxTableViewCell
            
            let checkboxTagsArray = ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber[pageItemIndex]
            
                cell1?.getCell(ischeckbox: ischeckbox, index: indexPath.row, checkBoxTagArray: checkboxTagsArray!)
               
            
            
            return cell1!
        }
        else{
           cell2 =  tableView.dequeueReusableCellWithIdentifier("cell1") as? ClubPointTableViewCell
            return cell2!
        }
        
        
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
}
/** Extension for UITableViewDelegate */
extension ClubPointPageItemViewController:UITableViewDelegate{
    
}
