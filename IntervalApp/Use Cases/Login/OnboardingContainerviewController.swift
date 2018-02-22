//
//  OnboardingContainerviewController.swift
//  IntervalApp
//
//  Created by Chetu on 20/02/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

class OnboardingContainerviewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var OnboardingCompletionStatus: ((Bool) ->())?
    
    var OnboardingCompleted = Bool () {
        didSet {
            OnboardingCompletionStatus?(OnboardingCompleted)
        }
    }
    var needToUpdatePageControl = true
    var pageViewController: UIPageViewController?
    var pageControl = UIPageControl()
    var doneButton = UIButton()
    var viewsArray = [UIViewController]()
    var handler: (Bool) -> Void = { _ in }
    let imageNames = ["Exchange Illustration", "EX+GA Illustration", "Usage Illustration", "Multi-Des Illustration", "Upcoming Trips Illustration", "TouchID Illustration"]
    let cardTitle = "What's New"
    let cardTopicTitles = ["Exchange Like Never Before.".localized(),
                           "Exchange + Getaways Combined".localized(),
                           "Choose What To Use".localized(),
                           "Search Multiple Destinations".localized(),
                           "Upcoming Trips".localized(),
                           "Fast Touch Login".localized()]
    let cardTopicDescription = ["This is what we call a game changer. Exclusively on the App, you can search for an exchange using any of your available weeks or points.".localized(),
                                "We've made it easier to see your vacation options! Search for both exchanges and Getaways together, or search each separately.".localized(),
                                "Search first, then decide the best way to book your vacation. Exchange using any of your available weeks or points - the rest is up to you.".localized(),
                                "Choose one or more resorts or desinations by name, or select resorts from the map.".localized(),
                                "View your upcoming vacations all in one place with fast and easy access to your trip confirmation details. Share your reservation information with friends and family.".localized(), "Quick and secure sign in with a touch of your finger. Available on devices that support fingerprint recognition.".localized()]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "LoginIPhone", bundle: nil)
        
        if let PageViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingBaseViewController") as? UIPageViewController {
            
            PageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 100)
            view.addSubview(PageViewController.view)
            PageViewController.dataSource = self
            PageViewController.delegate = self
            pageViewController = PageViewController
        }
        
        if let cardVC = viewControllerAtIndex(index: 0) {
             pageViewController?.setViewControllers([cardVC], direction: .forward, animated: true, completion: nil)
        }
       
        view.addSubview(doneButton)
        view.addSubview(pageControl)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Skip".localized(), for: .normal)
        doneButton.setTitleColor( #colorLiteral(red: 0.6642427444, green: 0.6647043228, blue: 0.6783328652, alpha: 1), for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 30))
        
        self.view.addConstraint( NSLayoutConstraint(item: doneButton, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute:.trailingMargin, multiplier: 1.0, constant: -20))
        
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .height, multiplier: 1.0, constant: 50))
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -30))
        
        pageControl.frame = CGRect.zero
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 6
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 0.5465167761, blue: 0.7919967175, alpha: 1)
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0, green: 0.5465167761, blue: 0.7919967175, alpha: 0.4952108305)
        pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 30))
        
        view.addConstraint( NSLayoutConstraint(item: pageControl, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute:.trailingMargin, multiplier: 1.0, constant: -20))
        
        view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .height, multiplier: 1.0, constant: 50))
        view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -80))
        
        view.bringSubview(toFront: doneButton)
        view.bringSubview(toFront: pageControl)
    }
    
    func doneButtonPressed() {
        OnboardingCompleted = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePageControlAndButtonTitle(index: Int) {
        
        if needToUpdatePageControl {
            needToUpdatePageControl = false
            pageControl.currentPage = index
            if index == cardTopicTitles.count - 1 {
                doneButton.setTitle("Done", for: .normal)
                doneButton.backgroundColor = #colorLiteral(red: 0, green: 0.5465167761, blue: 0.7919967175, alpha: 1)
                doneButton.setTitleColor( #colorLiteral(red: 0.9254121184, green: 0.9255419374, blue: 0.9254901961, alpha: 1), for: .normal)
                doneButton.layer.cornerRadius = 7
            } else {
                doneButton.setTitle("Skip", for: .normal)
                doneButton.backgroundColor = .clear
                doneButton.setTitleColor( #colorLiteral(red: 0.6642427444, green: 0.6647043228, blue: 0.6783328652, alpha: 1), for: .normal)
            }
        }
        
    }
    
    func viewControllerAtIndex(index: Int) -> OnboardingViewController? {
        let storyboard: UIStoryboard = UIStoryboard(name: "LoginIPhone", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Onboarding1") as? OnboardingViewController else { return nil }
        
        vc.completionHandler = {[weak self] response in
            self?.handler(true)
        }
        vc.mainTitle = cardTitle
        vc.topicDescription = cardTopicDescription[index]
        vc.topicTitle = cardTopicTitles[index]
        vc.currentPageIndex = index
        vc.imageName = imageNames[index]
        
        vc.view.tag = index
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        updatePageControlAndButtonTitle(index: index)
        if index == cardTopicTitles.count - 1 {
            return nil
        } else {
            return viewControllerAtIndex(index: index + 1)
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        updatePageControlAndButtonTitle(index: index)
        if index == 0 {
            return nil
        } else {
            return viewControllerAtIndex(index: index - 1)
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        needToUpdatePageControl = true
    }

}
