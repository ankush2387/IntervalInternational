//
//  TransitionManager.swift
//  AutoLayoutTest
//
//  Created by Chetuiwk1601 on 2/27/16.
//  Copyright © 2016 Chetuiwk1601. All rights reserved.
//

import Foundation
import UIKit
class TransitionManager: NSObject,UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate
{
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // TODO: Perform the animation
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
        
        // start the toView to the right of the screen
        toView.transform = offScreenRight
        
        // add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)
        
        // get the duration of the animation
        // DON'T just type '0.5s' -- the reason why won't make sense until the next post
        // but for now it's important to just follow this approach
        let duration = self.transitionDuration(using: transitionContext)
        
        // perform the animation!
        // for this example, just slid both fromView and toView to the left at the same time
        // meaning fromView is pushed off the screen and toView slides into view
        // we also use the block animation usingSpringWithDamping for a little bounce
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options:UIViewAnimationOptions(), animations: {
            
            fromView.transform = offScreenLeft
            toView.transform = CGAffineTransform.identity
            
        }, completion: { finished in
            
            // tell our transitionContext object that we've finished animating
            transitionContext.completeTransition(true)
            
        })
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self
        //return PresentationAnimator()
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //return DismissalAnimator()
        return self
    }
    
}
