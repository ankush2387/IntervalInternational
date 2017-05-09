//
//  ClubPointPageItemViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/9/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
class ClubPointPageItemViewController: UIViewController {
    /** Outlets */
    @IBOutlet weak var verticalLine: UIView!
    @IBOutlet weak var clubPointTableView: UITableView!

     /**
    Set View of First Check Box when first check box clicked
    - parameter sender : AnyObject
    - returns : No return Value
    */
    @IBAction func firstCheckBoxValueIsChanged(_ sender: AnyObject) {
       
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
        
    }
    /**
     Set View of Second Check Box when first check box clicked
     - parameter sender : AnyObject
     - returns : No return Value
     */
    @IBAction func secondCheckBoxValueIsChanged(_ sender: AnyObject) {
        
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
        //self.view.bringSubview(toFront: verticalLine)
        
        
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
    fileprivate func reloadTableViewData(){
        clubPointTableView.reloadData()
    }
    

}
/** Extension for UITableViewDataSource */
extension ClubPointPageItemViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
     
     let  cell =  tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.tdiTableViewCell) as? TdiTableViewCell
//       
//        let checkboxTagsArray = ClubPointPageItemViewController.checkBoxDictionaryWithpageNumber[pageItemIndex]
//        
//        TdiTableViewCell?.getCell(ischeckbox, index: (indexPath as NSIndexPath).row, checkBoxTagArray: checkboxTagsArray!)
//        
//        if (indexPath as NSIndexPath).row%2 == 0{
//           
//            TdiTableViewCell?.backgroundColor = UIColor.white
//           // cell1?.pointLabel.text = Constant.MyClassConstants.labelarray
//        }
        
        
        return cell!
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
        let headerTextLabel = UILabel(frame: CGRect(x: 30, y: 35, width: 30, height: 10))
        
       
            headerView.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 246.0/255.0, alpha: 1.0)
            headerTextLabel.text = Constant.MyClassConstants.tdi
            headerTextLabel.textColor = IUIKColorPalette.primaryText.color
            headerView.addSubview(headerTextLabel)
            return headerView
        
    }

    
}
/** Extension for UITableViewDelegate */
extension ClubPointPageItemViewController:UITableViewDelegate{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
		return 800
	}
}

extension ClubPointPageItemViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 0) {
            return 10
        }
        else if(collectionView.tag == 1){
            return 5
        }
        return 0
    }

 }

extension ClubPointPageItemViewController:UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

      
        
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:Constant.vacationSearchScreenReusableIdentifiers.tdiCollectionViewCell, for: indexPath)as! TdiCollectionViewCell
            
            return cell

        }
        else {
           
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.unitSizeTdiCollectionViewCell, for: indexPath)as! UnitSizeTdiCollectionViewCell
            
            return cell1

        }
        
            }

}







