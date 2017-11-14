//
//  ClubPointSelectionViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/9/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ClubPointSelectionViewController: UIViewController {
    /** Outlets */
    @IBOutlet weak var standardFlexChartSegment: UISegmentedControl!
    
    @IBOutlet weak var travelingDetailLabel: UILabel!
    /** Class Variables */
    var clubpointselectionPageViewController: UIPageViewController?
    var testArr = [1, 2, 3, 4, 5, 6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        travelingDetailLabel.text = "Traveling: Tue Oct 15, 2015 - Sun May 20, 2018"
        // Do any additional setup after loading the view.
        
        standardFlexChartSegment.setTitleTextAttributes(getTextAttributes(fontsize: 19), forState: .Normal)
        self.createClubpointselectionPageviewController()
        setupPageControl()
        addPageViewControllerWithAutoLayoutConstraint()
    }
    // MARK: Text Attributes with font size
    /**
        Create  a TextAttributes to change the font size of Segment controll text.
        - parameter fontsize: used to change font size
        - returns : TextAttributes.
    */
    private func getTextAttributes(fontsize fontsize: CGFloat) -> [String: NSObject] {
        let segmentFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleCaption1)
        let font = UIFont(descriptor: segmentFontDescriptor, size: fontsize)
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSFontAttributeName: font
        ]
        return normalTextAttributes
    }
    // MARK: Instantiate clubpointselectionPageviewController
    /**
        Create instance of pageViewController when horizontal scrolling is performed 
        - parameter No parameter :
        - returns : No value is return
    */
    private func createClubpointselectionPageviewController() {
        let pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("clubpointselectionPageviewcontroller") as? UIPageViewController
        pageViewController?.dataSource = self
        
        if testArr.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageViewController!.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        }
        
        clubpointselectionPageViewController = pageViewController
        addChildViewController(clubpointselectionPageViewController!)
        self.view.addSubview(clubpointselectionPageViewController!.view)
        clubpointselectionPageViewController!.didMoveToParentViewController(self)
    }
    // MARK: set page controll
    /**
        Set Pagecontroll properties on PageViewController
        - parameter No Parameter :
        - returns : No return value
    */
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
       
        appearance.currentPageIndicatorTintColor = UIColor.greenColor()
        appearance.backgroundColor = UIColor.clearColor()
    }

    // MARK: Auto Layout for child view controller(page view controller)
    /** 
    Add PageViewController as ChildViewController with AutoLayout Constraints
    - parameter No Parameter :
    - returns : No return value
    */
    private func addPageViewControllerWithAutoLayoutConstraint() {
        var leadeingconstraint: NSLayoutConstraint?
        var trailingconstraint: NSLayoutConstraint?
        var topconstraint: NSLayoutConstraint?
        var bottomconstraint: NSLayoutConstraint?
        
        leadeingconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .LeadingMargin, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        trailingconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 20)
        topconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .Top, relatedBy: .Equal, toItem: travelingDetailLabel, attribute: .Bottom, multiplier: 1.0, constant: 8)
        bottomconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -50)
        clubpointselectionPageViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leadeingconstraint!, trailingconstraint!, topconstraint!, bottomconstraint!])
        self.view.addConstraints([leadeingconstraint!, trailingconstraint!, topconstraint!, bottomconstraint!])
    }
    // MARK: initialise clubpoint page item view controller
    /**
        Initialise View*/
    private func getItemController(itemIndex: Int) -> ClubPointPageItemViewController? {
        
        if itemIndex < testArr.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ClubPointPageItemViewController") as! ClubPointPageItemViewController
            pageItemController.pageItemIndex = itemIndex
            //pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
extension ClubPointSelectionViewController: UIPageViewControllerDataSource {
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ClubPointPageItemViewController
        
        if itemController.pageItemIndex > 0 {
        return getItemController(itemController.pageItemIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! ClubPointPageItemViewController
        
        if itemController.pageItemIndex + 1 < testArr.count {
        return getItemController(itemController.pageItemIndex + 1)
        }
        
        return nil
    }
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return testArr.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        return 0
        
    }
    
}
