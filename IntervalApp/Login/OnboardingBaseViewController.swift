//
//  OnboardingBaseViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 9/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class OnboardingBaseViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var viewsArray = [UIViewController]()
    var handler: (Bool) -> Void = { _ in }
    let imageNames = ["Exchange Illustration", "EX+GA Illustration", "Usage Illustration", "Multi-Des Illustration", "Upcoming Trips Illustration", "TouchID Illustration"]
    let cardTitle = "What's New"
    let cardTopicTitles = ["This is what we call a game changer.",
                           "Exchange + Getaways Combined",
                           "Choose What To Use",
                           "Search Multiple Destinations",
                           "Upcoming Trips",
                           "Fast Touch Login"]
    let cardTopicDescription = ["Exchange like never before. Exclusively on the App, you can search for an exchange with different ownership interests at the same time.",
                                "We've made it easier to see your vacation options! Search for both exchanges and Getaways together, or search each separately.",
                                "Search first, then decide the best way to book your vacation. Search for an exchange using any (or all) of your available weeks or points - or book a Getaway. We'll show you options, the rest is up to you.",
                                "Choose one or more resorts or destinations by name, or select resorts from the map.",
                                "View your upcoming vacations all in one place with fast and easy access to your trip confirmation details. Share your reservation information with friends and family.", "Your finger is all you need to access your account. Sign in quickly and securely on phones and tablets that support fingerprint recognition."]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        let cardVC = viewControllerAtIndex(index: 0)
        setViewControllers([cardVC], direction: .forward, animated: true, completion: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(index: Int) -> OnboardingViewController {
         let storyboard: UIStoryboard = UIStoryboard(name: "LoginIPhone", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Onboarding1") as! OnboardingViewController

        vc.completionHandler = { response in
            self.handler(true)
        }
        vc.mainTitle = cardTitle
        vc.topicDescription = cardTopicDescription[index]
        vc.topicTitle = cardTopicTitles[index]
        vc.currentPageIndex = index
        if index == cardTopicTitles.count - 1 {
            vc.buttonTitle = "Done"
        } else {
            vc.buttonTitle = "Skip"
        }
        vc.imageName = imageNames[index]
        vc.view.tag = index

        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index  = viewController.view.tag
        
        if index == cardTopicTitles.count - 1 {
            return nil
        } else {
            return viewControllerAtIndex(index: index + 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
         let index  = viewController.view.tag
        if index == 0 {
            return nil
        } else {
            return viewControllerAtIndex(index: index - 1)
        }
    }

}

