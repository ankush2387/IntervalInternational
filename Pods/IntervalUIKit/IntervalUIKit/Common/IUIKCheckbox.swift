//
//  IUIKCheckbox.swift
//  IntervalUIKit
//
//  Created by Ralph Fiol on 12/15/15.
//  Copyright © 2015 Interval International. All rights reserved.
//
//  Based on work by Nick Griffith in IBDesignableDemo github post
//
import UIKit

@IBDesignable 
open class IUIKCheckbox : UIControl {
    
    override open var description: String {
        get {
            return "<UICheckbox>: checked? \(self.checked)"
        }
    }
    
    override open var backgroundColor: UIColor? {
        set(newColor) {
            super.backgroundColor = UIColor.clear
            self._backgroundColor = newColor ?? UIColor.clear
        }
        get {
            return self._backgroundColor
        }
    }
    
    fileprivate var _backgroundColor: UIColor = UIColor.clear {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var round: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var checked: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var checkmarkSize: CGFloat = 5.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var checkmarkColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var filled: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var checkedFillColor: UIColor = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var uncheckedFillColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isTouchInside) {
            self.checked = !self.checked
            self.sendActions(for: .valueChanged)
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    fileprivate var currentFillColor: UIColor {
        get {
            if self.checked {
                return self.checkedFillColor
            } else if self.filled {
                return self.uncheckedFillColor
            } else {
                return UIColor.clear
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        
        var frame = rect
        if frame.size.width != frame.size.height {
            let shortestSide = min(frame.size.width, frame.size.height)
            let longestSide = max(frame.size.width, frame.size.height)
            
            let originY = (longestSide - frame.size.width) / 2
            let originX = (longestSide - frame.size.height) / 2
            
            frame = CGRect(x: originX, y: originY, width: shortestSide, height: shortestSide)
        }
        
        let group = frame.insetBy(dx: self.borderWidth, dy: self.borderWidth)
        let ovalPath = (self.round == true  ? UIBezierPath(ovalIn: group) : UIBezierPath(roundedRect: group, cornerRadius: 6))
        
        context?.saveGState()
        
        self.currentFillColor.setFill()
        ovalPath.fill()
        context?.restoreGState()
        
        self.borderColor.setStroke()
        ovalPath.lineWidth = self.borderWidth
        ovalPath.stroke()
        
        if self.checked || self.filled {
            let checkPath = UIBezierPath()
            
            let startX = group.minX + 0.27083 * group.width
            let startY = group.minY + 0.54167 * group.height
            let startPoint = CGPoint(x: startX, y: startY)
            
            let midX = group.minX + 0.41667 * group.width
            let midY = group.minY + 0.68750 * group.height
            let midPoint = CGPoint(x: midX, y: midY)
            
            let endX = group.minX + 0.75000 * group.width
            let endY = group.minY + 0.35417 * group.height
            let endPoint = CGPoint(x: endX, y: endY)
            
            checkPath.move(to: startPoint)
            checkPath.addLine(to: midPoint)
            checkPath.addLine(to: endPoint)
            checkPath.lineCapStyle = CGLineCap.square
            checkPath.lineWidth = self.checkmarkSize
            self.checkmarkColor.setStroke()
            
            context?.setBlendMode(CGBlendMode.clear)
            checkPath.stroke()
            context?.setBlendMode(CGBlendMode.normal)
            checkPath.stroke()
        }
    }
}
