//
//  CertificateInfoViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 8/16/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class CertificateInfoViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "Individuals under the age of 21 are not eligible to receive a Guest Certificate.")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 12, length: 36))
       // messageLabel.attributedText = attributedString
        
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
