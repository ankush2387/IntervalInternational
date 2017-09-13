//
//  SelectedResortsIpadViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 04/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class SelectedResortsIpadViewController: UIViewController {
    
    // clas  outlets
    @IBOutlet weak var selectedResortsTableView: UITableView!
    
    // class varibles
    var areaDictionary = NSMutableDictionary()
    var areasInRegionArray = [String]()
    var selectedCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


/*
 {
 "Australia & New Zealand" =     (
 "Australia, New South Wales, Central",
 "Australia, New South Wales, North Coast"
 );
 "Canada - Eastern" =     (
 "Nova Scotia",
 "Ontario, Calabogie"
 );
 "Caribbean & Atlantic Islands" =     (
 Antigua,
 Anguilla
 );
 }
 */


extension SelectedResortsIpadViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return areaDictionary.allKeys.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let sectionArray : NSMutableArray
        sectionArray = areaDictionary.allKeys as! NSMutableArray
        
        if let areas = areaDictionary.value(forKey: sectionArray[section] as! String){
            
            let areasInRegionArray = areas
            return (areasInRegionArray as AnyObject).count
            
        }else{
            
            return 0
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.selectedResortsCell) as! SelectedResortsCell
        
        let dicKey = Array(areaDictionary)[indexPath.section].key
        if let areas = areaDictionary.value(forKey: dicKey as! String){
            
            let localArray:NSMutableArray = NSMutableArray()
            
            for object in areas as! [String]{
                
                localArray.add(object)
            }
            cell.lblResortsName.text = localArray[indexPath.row] as? String
        }
        
        return cell
        
    }
    
}


extension SelectedResortsIpadViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
           
            let dicKey = Array(areaDictionary)[indexPath.section].key
            if let areas = areaDictionary.value(forKey: dicKey as! String){
                
                let localArray:NSMutableArray = NSMutableArray()
                
                for object in areas as! [String]{
                    
                    localArray.add(object)
                }
                
                for value in Constant.MyClassConstants.selectedAreaCodeDictionary.allValues{
                    if(value as! String == localArray[indexPath.row] as! String){
                        let key = Constant.MyClassConstants.selectedAreaCodeDictionary.allKeys(for: value)
                        print(key)
                        Constant.MyClassConstants.selectedAreaCodeDictionary.removeObject(forKey: "\(key[0])")
                        print(Constant.MyClassConstants.selectedAreaCodeDictionary)
                        Constant.MyClassConstants.selectedAreaCodeArray.remove("\(key[0])")
                        
                    }
                }
                localArray.removeObject(at: indexPath.row)

                selectedCounter = -1
                
                if(localArray.count > 0){
                    areaDictionary.setValue(localArray, forKey: dicKey as! String)
                }else{
                    areaDictionary.removeObject(forKey: dicKey as! String)
                    //Constant.MyClassConstant.
                }
                print(areaDictionary)
                print(Constant.MyClassConstants.selectedAreaCodeDictionary)
                print(Constant.MyClassConstants.selectedAreaCodeArray)

            
            }
            tableView.reloadData()
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        view.backgroundColor = UIColor.init(colorLiteralRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        
        // set shadow color
        
        view.layer.shadowColor = UIColor.blue.cgColor
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius = 2
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        
        let headerNameLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.size.width-20, height: 30))
        
        let headerArray : NSMutableArray
        headerArray = areaDictionary.allKeys as! NSMutableArray
        headerNameLabel.text = headerArray[section] as? String
        headerNameLabel.textColor = UIColor.lightGray
        headerNameLabel.font = UIFont(name:Constant.fontName.helveticaNeue, size:15)
        
        view.addSubview(headerNameLabel)
       
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
