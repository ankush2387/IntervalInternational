//
//  CustomPageControl.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/29/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

class PageControl: UIPageControl {
    var activeImage: UIImage!
    var inactiveImage: UIImage!
    override var currentPage: Int {
        //willSet {
        didSet { //so updates will take place after page changed
            self.updateDots()
        }
    }
    
    convenience init(activeImage: UIImage, inactiveImage: UIImage) {
        self.init()
        
        self.activeImage = activeImage
        self.inactiveImage = inactiveImage
        
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
    }
    
    func updateDots() {
        var i = 0
        var dot:UIImageView!
        for _ in self.subviews  {
            
            
            dot = addImageViewOnDotView(self.subviews[i])
            
            if(i == self.currentPage) {
                dot.image = UIImage().makeImageWithColorAndSize(UIColor.white, size: CGSize(width: 10, height: 10))
                dot.layer.cornerRadius = 5
            }
            else {
                
                let dotColor = UIColor(red: 155.0/255.0, green: 158.0/255.0, blue: 160.0/255.0, alpha: 0.4)
                dot.image = UIImage().makeImageWithColorAndSize(dotColor, size: CGSize(width: 10, height: 10))
                dot.layer.cornerRadius = 5
            }
            i = i + 1
        }
        
    }
}

// MARK: - Private

func addImageViewOnDotView(_ view: UIView)-> UIImageView {
    var dot:UIImageView!
    
    if(view .isKind(of: UIView.self)) {
        
        for subview in view.subviews {
            
            if(subview .isKind(of: UIImageView.self)) {
                dot = subview as! UIImageView
                break
            }
        }
        if( dot == nil) {
            
            dot = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            dot.layer.cornerRadius = 5
            dot.clipsToBounds = true
            dot.layer.borderWidth = 1
            dot.layer.borderColor = UIColor.white.cgColor
            view.addSubview(dot)
            
        }
        else {
            view.addSubview(dot)
        }
    }
    else {
        
        dot = view as! UIImageView
        view.addSubview(dot)
    }
    return dot
}
