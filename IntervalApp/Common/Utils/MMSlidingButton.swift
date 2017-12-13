//
//  MMSlidingButton.swift
//  MMSlidingButton
//
//  Created by Mohamed Maail on 6/7/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import Foundation
import UIKit

protocol SlideButtonDelegate {
    func buttonStatus(_ status: String, sender: MMSlidingButton)
}

@IBDesignable class MMSlidingButton: UIView {
    
    var delegate: SlideButtonDelegate?
    
    @IBInspectable var dragPointWidth: CGFloat = 70 {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var dragPointColor: UIColor = UIColor.clear {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var buttonColor: UIColor = UIColor.clear {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var buttonText: String = "" {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var imageName: UIImage = UIImage() {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var buttonTextColor: UIColor = UIColor.white {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var dragPointTextColor: UIColor = UIColor.white {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var buttonUnlockedTextColor: UIColor = UIColor.white {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var buttonCornerRadius: CGFloat = 0 {
        didSet {
            setStyle()
        }
    }
    
    @IBInspectable var buttonUnlockedText: String   = ""
    @IBInspectable var buttonUnlockedColor: UIColor = UIColor.black
    var buttonFont = UIFont.boldSystemFont(ofSize: 17)
    
    var dragPoint = UIView()
    var buttonLabel = UILabel()
    var dragPointButtonLabel = UILabel()
    var imageView = UIImageView()
    var unlocked = false
    var layoutSet = true
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    override func layoutSubviews() {
        if layoutSet {
            self.setUpButton()
            self.layoutSet = true
        }
    }
    
    func setStyle() {
        buttonLabel.text = self.buttonText
        dragPointButtonLabel.text = self.buttonText
        dragPoint.frame.size.width = self.dragPointWidth
        dragPoint.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        imageView.image = imageName
        buttonLabel.textColor = self.buttonTextColor
        dragPointButtonLabel.textColor = self.dragPointTextColor
        
        self.dragPoint.layer.cornerRadius = buttonCornerRadius
        self.layer.cornerRadius = buttonCornerRadius
    }
    
    func setUpButton() {
        
        if dragPoint.subviews.count >= 1 {
            dragPoint.removeFromSuperview()
        }
        self.backgroundColor = UIColor.clear
        dragPoint = UIView(frame: CGRect(x: dragPointWidth - self.frame.size.width, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        dragPoint.backgroundColor = UIColor.clear
        dragPoint.layer.cornerRadius = buttonCornerRadius
        self.addSubview(dragPoint)
        
        if !buttonText.isEmpty {
            buttonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            buttonLabel.textAlignment = .center
            buttonLabel.text = buttonText
            buttonLabel.textColor = UIColor.white
            buttonLabel.font = self.buttonFont
            buttonLabel.textColor = self.buttonTextColor
            addSubview(self.buttonLabel)
            dragPointButtonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
           dragPointButtonLabel.textAlignment = .center
            dragPointButtonLabel.text = buttonText
            dragPointButtonLabel.textColor = UIColor.white
            dragPointButtonLabel.font = self.buttonFont
            dragPointButtonLabel.textColor = self.dragPointTextColor
           dragPoint.addSubview(self.dragPointButtonLabel)
        }
        self.bringSubview(toFront:dragPoint)
        
        if self.imageName != UIImage() {
            if Constant.RunningDevice.deviceIdiom == .phone {
                self.imageView = UIImageView(frame: CGRect(x: self.frame.size.width - dragPointWidth + 5, y: 0, width: 30, height: self.frame.size.height))
            } else {
                imageView = UIImageView(frame: CGRect(x: self.frame.size.width - dragPointWidth + 15, y: 5, width: 50, height: self.frame.size.height - 10))
            }
            imageView.isHidden = false
            imageView.image = imageName
            imageView.backgroundColor = UIColor.clear
            dragPoint.addSubview(imageView)
        }
        self.layer.masksToBounds = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        self.dragPoint.addGestureRecognizer(panGestureRecognizer)
    }
    
    func panDetected(_ sender: UIPanGestureRecognizer) {
        var translatedPoint = sender.translation(in: self)
        translatedPoint = CGPoint(x: translatedPoint.x, y: self.frame.size.height / 2)
        sender.view?.frame.origin.x = (dragPointWidth - self.frame.size.width) + translatedPoint.x
        if sender.state == .ended {
            
            let velocityX = sender.velocity(in: self).x * 0.2
            var finalX = translatedPoint.x + velocityX
            if finalX < 0 {
                finalX = 0
            } else if finalX + self.dragPointWidth > (self.frame.size.width - 60) {
                unlocked = true
                self.unlock()
            }
            
            let animationDuration: Double = abs(Double(velocityX) * 0.0002) + 0.2
            UIView.transition(with: self, duration: animationDuration, options: UIViewAnimationOptions.curveEaseOut, animations: {
            }, completion: { (Status) in
                if Status {
                    self.animationFinished()
                }
            })
        }
    }
    
    func animationFinished() {
        if !unlocked {
            self.reset()
        }
    }
    
    //lock button animation (SUCCESS)
    func unlock() {
        Constant.MyClassConstants.indexSlideButton = self.tag
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragPoint.frame = CGRect(x: self.frame.size.width - self.dragPoint.frame.size.width, y: 0, width: self.dragPoint.frame.size.width, height: self.dragPoint.frame.size.height)
        }) { (Status) in
            if Status {
                
                if Constant.RunningDevice.deviceIdiom == .phone {
                    self.imageView.frame = CGRect(x: self.frame.width - 50, y: 0, width: 30, height: self.frame.size.height)
                } else {
                    self.imageView.frame = CGRect(x: self.frame.width - 50, y: 0, width: 50, height: self.frame.size.height)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeLabel"), object: self.imageView)
                self.delegate?.buttonStatus("", sender: self)
            }
        }
    }
    
    //reset button animation (RESET)
    func reset() {
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragPoint.frame = CGRect(x: self.dragPointWidth - self.frame.size.width, y: 0, width: self.dragPoint.frame.size.width, height: self.dragPoint.frame.size.height)
        }) { (Status) in
            if Status {
                self.dragPointButtonLabel.text = self.buttonText
                self.unlocked = false
            }
        }
    }
}
