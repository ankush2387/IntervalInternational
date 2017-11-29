//
//  PageViewItem.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class PageViewItem: UIView {

    // MARK: - Public properties
    let lineWidth: CGFloat
    let borderColor: UIColor
    let circleRadius: CGFloat
    let selectedCircleRadius: CGFloat
    let activeSegmentBorderColor: UIColor

    var select: Bool
    var tickIndex: Int = 0
    var centerView: UIView?
    var imageView: UIImageView?
    var circleLayer: CAShapeLayer?

    // MARK: - Lifecycle
    init(radius: CGFloat,
         selectedRadius: CGFloat,
         activeSegmentBorderColor: UIColor,
         borderColor: UIColor = .white,
         lineWidth: CGFloat = 3,
         isSelect: Bool = false) {

        self.select = isSelect
        self.lineWidth = lineWidth
        self.circleRadius = radius
        self.borderColor = borderColor
        self.selectedCircleRadius = selectedRadius
        self.activeSegmentBorderColor = activeSegmentBorderColor
        super.init(frame: CGRect.zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions
    func animationSelected(_ selected: Bool, duration: Double, fillColor: Bool) {
        let toAlpha: CGFloat = selected == true ? 1 : 0
        imageAlphaAnimation(toAlpha, duration: duration)
        let currentRadius  = selected == true ? selectedCircleRadius : circleRadius
        let scaleAnimation = circleScaleAnimation(currentRadius - lineWidth / 2.0, duration: duration)
        let toColor        = fillColor == true ? UIColor.white : UIColor.clear
        let colorAnimation = circleBackgroundAnimation(toColor, duration: duration)
        circleLayer?.add(scaleAnimation, forKey: nil)
        circleLayer?.add(colorAnimation, forKey: nil)
    }

    // MARK: - Private functions
    private func commonInit() {
        centerView = createBorderView()
        imageView = createImageView()
    }

    private func createBorderView() -> UIView {

        let view = Init(UIView(frame:CGRect.zero)) {
            $0.backgroundColor = .blue
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        addSubview(view)
        // Create circle layer
        let currentRadius = select == true ? selectedCircleRadius : circleRadius
        let circleLayer = createCircleLayer(currentRadius, lineWidth: lineWidth)
        view.layer.addSublayer(circleLayer)
        self.circleLayer = circleLayer

        [NSLayoutAttribute.centerX, NSLayoutAttribute.centerY].forEach { attribute in
            (self , view) >>>- { $0.attribute = attribute; return }
        }

        [NSLayoutAttribute.height, NSLayoutAttribute.width].forEach { attribute in
            view >>>- { $0.attribute = attribute; return }
        }

        return view
    }

    private func createCircleLayer(_ radius: CGFloat, lineWidth: CGFloat) -> CAShapeLayer {

        let path = UIBezierPath(arcCenter: CGPoint.zero,
                                radius: radius - lineWidth / 2.0,
                                startAngle: 0,
                                endAngle: CGFloat(2.0 * Double.pi),
                                clockwise: true)

        let layer = Init(CAShapeLayer()) {
            $0.path = path.cgPath
            $0.lineWidth = lineWidth
            $0.strokeColor = activeSegmentBorderColor.cgColor
            $0.fillColor = UIColor.clear.cgColor
        }

        return layer
    }

    private func createImageView() -> UIImageView {

        let imageView = Init(UIImageView(frame: CGRect.zero)) {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.alpha = select == true ? 1 : 0
        }

        addSubview(imageView)
        [NSLayoutAttribute.left, NSLayoutAttribute.right, NSLayoutAttribute.top, NSLayoutAttribute.bottom].forEach { attribute in (self , imageView) >>>- { $0.attribute = attribute; return }
        }

        return imageView
    }

    private func circleScaleAnimation(_ toRadius: CGFloat, duration: Double) -> CABasicAnimation {

        let path = UIBezierPath(arcCenter: CGPoint.zero,
                                radius: toRadius,
                                startAngle: 0,
                                endAngle: CGFloat(2.0 * Double.pi),
                                clockwise: true)

        let animation = Init(CABasicAnimation(keyPath: "path")) {
            $0.duration = duration
            $0.toValue = path.cgPath
            $0.isRemovedOnCompletion = false
            $0.fillMode = kCAFillModeForwards
        }

        return animation
    }

    private func circleBackgroundAnimation(_ toColor: UIColor, duration: Double) -> CABasicAnimation {
        let animation = Init(CABasicAnimation(keyPath: "fillColor")) {
            $0.duration = duration
            $0.toValue = toColor.cgColor
            $0.isRemovedOnCompletion = false
            $0.fillMode = kCAFillModeForwards
            $0.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        }

        return animation
    }

    private func imageAlphaAnimation(_ toValue: CGFloat, duration: Double) {

        let animations: () -> Void = { [weak self] in
            self?.imageView?.alpha = toValue
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIViewAnimationOptions(),
                       animations: animations,
                       completion: nil)
    }
}
