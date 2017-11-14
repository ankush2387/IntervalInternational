//
//  OnboardingViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 9/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var topicTtitleLabel: UILabel!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var actionButton: UIButton!
 
    var completionHandler: (Bool) -> Void = { _ in }
    var topicTitle: String?
    var topicDescription: String?
    var mainTitle: String?
    var imageName: String?
    var currentPageIndex: Int?
    var buttonTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setupView() {
        //shadow and corner radius
        view.layer.cornerRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        view.layer.shadowOpacity = 3
        view.layer.shadowRadius = 6
        
        //set Copies and look of view
        mainTitleLabel.text = mainTitle
        topicTtitleLabel.text = topicTitle
        topicTtitleLabel.textColor = UIColor(colorLiteralRed: 0.38, green: 0.38, blue: 0.38, alpha: 1)
        topicDescriptionLabel.text = topicDescription
        pageControl.currentPage = currentPageIndex!
        actionButton.setTitle(buttonTitle, for: .normal)
        
        mainImageView.image = UIImage(named: imageName!)
        if buttonTitle == "Done" {
            actionButton.setTitleColor(UIColor.white, for: .normal)
            actionButton.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.47, blue: 0.75, alpha: 1.0)
            actionButton.layer.cornerRadius = 12
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onboardingActionButtonPressed(_ sender: UIButton) {
        completionHandler(true)
    }
}
