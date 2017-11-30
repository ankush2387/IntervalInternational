//
//  PointsInfoViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 11/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class PointsInfoViewController: UIViewController {
    //***** Dismiss progress bar if back button is pressed. *****//
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
      self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     @IBAction private func doneClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
