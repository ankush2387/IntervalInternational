//
//  TriangeView.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
@IBDesignable
class TriangeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    /** Draw Triangle shape using rectangle frame */
    override func draw(_ rect: CGRect) {
        
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        
        ctx.beginPath();
        //Start point
        ctx.move   (to: CGPoint(x: rect.minX, y: rect.minY));
        //Draw a line
        ctx.addLine(to: CGPoint(x: rect.midX, y: rect.maxY));
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY));

        ctx.closePath();
        //Set color of trangle
        let color = UIColor.white
        ctx.setFillColor(color.cgColor )
        ctx.fillPath();
        
    }
}
