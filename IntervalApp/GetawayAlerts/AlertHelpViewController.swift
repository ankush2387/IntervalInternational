//
//  AlertHelpViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class AlertHelpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstTopicLabel: UILabel!
    @IBOutlet weak var firstTopicHeaderLabel: UILabel!
    @IBOutlet weak var firstTopicBodyLabel: UILabel!
    @IBOutlet weak var secondTopicLabel: UILabel!
    @IBOutlet weak var seondTopicBodyLabel: UILabel!
    @IBOutlet weak var thirdTopicLabel: UILabel!
    @IBOutlet weak var thirdTopicBodyLabel: UILabel!
    @IBOutlet var separatorViews: Array<UIView>?
    @IBOutlet weak var firstTopicBodyTopConstraint: NSLayoutConstraint!
    
    var ishelpView = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        //change height of scrollview depending on current device
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.contentViewHeight.constant = self.view.bounds.height - 20
            self.scrollView.isScrollEnabled = false
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            if self.view.bounds.height < 600 {
                self.contentViewHeight.constant = 700
            }
        }
        
        //hide views if its a help message
        if ishelpView {
            self.setupView()
        }
    }
    
    func setupView() {
        self.titleLabel.text = "Help"
        self.firstTopicLabel.isHidden = true
        self.firstTopicHeaderLabel.isHidden = true
        self.secondTopicLabel.isHidden = true
        self.seondTopicBodyLabel.isHidden = true
        self.thirdTopicLabel.isHidden = true
        self.thirdTopicBodyLabel.isHidden = true
        
        firstTopicBodyTopConstraint.constant = 20
        for view in separatorViews! {
            view.isHidden = true
        }
        
        self.scrollView.isScrollEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Nav Bar Color
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
    }

    @IBAction func didPressDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
