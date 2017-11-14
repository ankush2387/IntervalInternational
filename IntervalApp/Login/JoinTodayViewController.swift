//
//  JoinTodayViewController.swift
//  IntervalApp
//
//  Created by Chetu on 01/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class JoinTodayViewController: UIViewController {

    //***** Outlets *****//
    @IBOutlet weak var joinTodayWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = Constant.ControllerTitles.JoinTodayViewController
        let   doneButton = UIBarButtonItem(title: Constant.AlertPromtMessages.done, style: .plain, target: self, action: #selector(JoinTodayViewController.donePressed(_:)))
        doneButton.tintColor = UIColor.white
    
        self.navigationItem.rightBarButtonItem = doneButton
        
        let url = URL (string: Constant.WebUrls.joinTodayURL )
        let requestObj = URLRequest(url: url!)
        self.joinTodayWebView.loadRequest(requestObj)

    }
    //***** function to dismiss view controller and back to login screen *****//
    func donePressed(_ sender: UIBarButtonItem) {
    
        self.dismiss(animated: true, completion: nil)
    }
}
