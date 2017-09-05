//
//  SelectedResortsIpadViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 04/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class SelectedResortsIpadViewController: UIViewController {
    
    
    
    var areaDictionary = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(areaDictionary)
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



extension SelectedResortsIpadViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.selectedResortsCell) as! SelectedResortsCell
        
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
            print("row deleted")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        view.backgroundColor = UIColor.init(colorLiteralRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        
        let headerNameLabel = UILabel(frame: CGRect(x: 20, y: 5, width: view.frame.size.width-20, height: 30))
        
        headerNameLabel.text = "USA"
        headerNameLabel.textColor = UIColor.white
        
        view.addSubview(headerNameLabel)
       
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
