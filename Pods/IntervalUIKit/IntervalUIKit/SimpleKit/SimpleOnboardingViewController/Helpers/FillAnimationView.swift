//
//  FillAnimationView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class FillAnimationView: UIView {

    // MARK: - Private properties
    fileprivate let path = "path"
    fileprivate let circle = "circle"

    // MARK: - Public functions
    func fillAnimation(_ color: UIColor, centerPosition: CGPoint, duration: Double) {
        let radius = max(bounds.size.width, bounds.size.height) * 1.5
        let circle = createCircleLayer(centerPosition, color: color)
        let animation = animationToRadius(radius, center: centerPosition, duration: duration)
        animation.setValue(circle, forKey: self.circle)
        circle.add(animation, forKey: nil)
    }

    class func animavtionViewOnView(_ view: UIView, color: UIColor) -> FillAnimationView {
        let animationView = Init(FillAnimationView(frame: CGRect.zero)) {
            $0.backgroundColor = color
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(animationView)

        // Add constraints
        for attribute in [NSLayoutAttribute.left, NSLayoutAttribute.right, NSLayoutAttribute.top, NSLayoutAttribute.bottom] {
            (view, animationView) >>>- { $0.attribute = attribute; return}
        }

        return animationView
    }

    // MARK: - Private functions
    private func createCircleLayer(_ position: CGPoint, color: UIColor) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: position, radius: 1, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
        let layer = Init(CAShapeLayer()) {
            $0.path            = path.cgPath
            $0.fillColor       = color.cgColor
            $0.shouldRasterize = true
        }

        self.layer.addSublayer(layer)
        return layer
    }
}

extension FillAnimationView: CAAnimationDelegate {

    fileprivate func animationToRadius(_ radius: CGFloat, center: CGPoint, duration: Double) -> CABasicAnimation {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
        let animation = Init(CABasicAnimation(keyPath: self.path)) {
            $0.duration = duration
            $0.toValue = path.cgPath
            $0.isRemovedOnCompletion = false
            $0.fillMode = kCAFillModeForwards
            $0.delegate = self
            $0.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        }

        return animation
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        guard let circleLayer = anim.value(forKey: self.circle) as? CAShapeLayer else {
            return
        }

        layer.backgroundColor = circleLayer.fillColor
        circleLayer.removeFromSuperlayer()
    }
}
