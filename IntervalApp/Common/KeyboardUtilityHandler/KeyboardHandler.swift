//
//  KeyboardHandler.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 30/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class KeyboardHandler: NSObject {
    
    private class func topLevelViewForView(view: UIView) -> UIView {
        
        if view.superview == nil {
            return view
        } else if view.superview is UIWindow {
            return view
        } else {
            if let View = view.superview {
                return topLevelViewForView(view: View)
            } else {
                return view
            }
        }
    }
    private class func activeViewForView(view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        } else {
            for subview in view.subviews {
                
                let activeView = activeViewForView(view: subview)
                if activeView != nil {
                    return activeView
                }
            }
        }
        return nil
    }
    
    class func keyboardWasShown(aNotification: NSNotification, adjustScrollView scrollview: UIScrollView) {
        
        let info = aNotification.userInfo
        guard let dict = info else {
            return
        }
        let frame1: CGRect? = (dict[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let kbFrame = frame1 else {
            return
        }
        guard let scrollviewWindow = scrollview.window else {
            return
        }
        let kbAdjustedFrame: CGRect = scrollviewWindow.convert(kbFrame, to: scrollview)
        let kbSize: CGSize = kbAdjustedFrame.size
        
        let scrollFrame: CGRect = scrollview.frame
        let topLevelView: UIView = topLevelViewForView(view: scrollview)
        let adjustedScrollFrame: CGRect = topLevelView.convert(scrollFrame, from: scrollview.superview)
        let maxY: CGFloat = adjustedScrollFrame.maxY
        let topLevelViewHeight: CGFloat = topLevelView.bounds.size.height
        let viewGap: CGFloat = topLevelViewHeight - maxY
        
        // Add 10 for more gap between textfield and keyboard.
        let offset: CGFloat = kbSize.height - viewGap
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset + 10, right: 0)
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
        
        let activeView: UIView? = activeViewForView(view: scrollview)
        if activeView != nil {
            var aRect: CGRect = scrollview.frame
            aRect.size.height -= offset
            let visibleRect: CGRect = scrollview.convert((activeView?.frame)!, from: activeView?.superview)
            if !aRect.contains(visibleRect) {
                scrollview.scrollRectToVisible(visibleRect, animated: true)
            }
        }
    }
    
    class func keyboardWillBeHidden(aNotification: NSNotification, adjustScrollView scrollview: UIScrollView) {
        
        let info = aNotification.userInfo
        guard let dict = info else {
            return
        }
        let duration: NSNumber = dict[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        _ = dict[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration.doubleValue)
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
        UIView.commitAnimations()
        
    }
    
    class func keyboardDidShow(aNotification: NSNotification, adjustScrollView scrollview: UIScrollView) {
        
        let info = aNotification.userInfo
        guard let dict = info else {
            return
        }
        let frame1: CGRect? = (dict[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let kbFrame = frame1 else {
            return
        }
        guard let scrollviewWindow = scrollview.window else {
            return
        }
        let kbAdjustedFrame: CGRect = scrollviewWindow.convert(kbFrame, to: scrollview)
        let kbSize: CGSize = kbAdjustedFrame.size
        
        let scrollFrame: CGRect = scrollview.frame
        let topLevelView: UIView = topLevelViewForView(view: scrollview)
        let adjustedScrollFrame: CGRect = topLevelView.convert(scrollFrame, from: scrollview.superview)
        let maxY: CGFloat = adjustedScrollFrame.maxY
        let topLevelViewHeight: CGFloat = topLevelView.bounds.size.height
        let viewGap: CGFloat = topLevelViewHeight - maxY
        
        let offset: CGFloat = kbSize.height - viewGap
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -offset, right: 0)
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
    }
}
