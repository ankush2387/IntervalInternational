//
//  RelinquishmentWhatToUseViewController.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 29/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RelinquishmentWhatToUseViewController: UIViewController {
    
    
    @IBOutlet weak var whatToUsetableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title  = Constant.ControllerTitles.choosewhattouse

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 
  

}

extension RelinquishmentWhatToUseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
          let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.resortBedroomDetailexchange, for: indexPath) as UITableViewCell
        
        return cell
    }
    
}



extension RelinquishmentWhatToUseViewController: UITableViewDelegate{
    
    
    
 
}




