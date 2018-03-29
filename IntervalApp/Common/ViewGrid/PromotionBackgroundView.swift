//
//  PromotionBackgroundView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 3/23/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

final class PromotionBackgroundView: NSObject {

    // MARK: - Public properties
    static let genericFrame = CGRect(x: 0, y: 0, width: genericCellDimension.width, height: genericCellDimension.height)

    @objc(CellbackgroundGridResizingBehavior)
    enum ResizingBehavior: Int {

        /// The content is proportionally resized to fit into the target rectangle.
        case aspectFit

        /// The content is proportionally resized to completely fill the target rectangle.
        case aspectFill

        /// The content is stretched to match the entire target rectangle.
        case stretch

        /// The content is centered in the target rectangle, but it is NOT resized.
        case center

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }

    // MARK: - Private properties
    // Note: Need to make lower/upper limit more dynamic if we want to use in very large views.
    // For now this should work for most scenarios.
    static private let bezierLowerLimit = 0
    static private let bezierUpperLimit = 1016
    static private let genericCellDimension: (width: CGFloat, height: CGFloat) = (width: 375, height: 73)

    // MARK: - Drawing Methods
    public class func drawPromotionUI(with targetFrame: CGRect = PromotionBackgroundView.genericFrame,
                                      resizing: ResizingBehavior = .aspectFit,
                                      ofType promotionType: PromotionType?) throws {

        guard let context = UIGraphicsGetCurrentContext() else { throw CommonErrors.emptyInstance }
        guard let promotionType = promotionType else { throw CommonErrors.emptyInstance }
        drawGrid(for: promotionType, and: context, within: targetFrame, while: resizing)
        drawPromotionLabel(for: promotionType, and: context, within: targetFrame)
    }

    private static func drawGrid(for promotionType: PromotionType,
                                 and context: CGContext,
                                 within targetFrame: CGRect,
                                 while resizing: ResizingBehavior) {

        // Resize to Target Frame
        context.saveGState()
        let targetRect = CGRect(x: 0, y: 0, width: genericCellDimension.width, height: genericCellDimension.height)
        let resizedFrame: CGRect = resizing.apply(rect: targetRect, target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / genericCellDimension.width,
                        y: resizedFrame.height / genericCellDimension.height)

        var startingMoveCoordinateX = 294.5
        var startingAddLineCoordinateX = -155.5
        let startingMoveCoordinateY = -214.5
        let startingAddLineCoordinateY = 118.5

        (bezierLowerLimit...bezierUpperLimit).forEach { _ in
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: startingMoveCoordinateX, y: startingMoveCoordinateY))
            bezierPath.addLine(to: CGPoint(x: startingAddLineCoordinateX, y: startingAddLineCoordinateY))
            promotionType.UIConfiguration.promotionGridColor.setStroke()
            bezierPath.lineWidth = 1
            bezierPath.lineCapStyle = .square
            bezierPath.stroke()
            startingMoveCoordinateX += 5
            startingAddLineCoordinateX += 5
        }

        context.restoreGState()
    }

    private static func drawPromotionLabel(for promotionType: PromotionType,
                                           and context: CGContext,
                                           within targetFrame: CGRect) {

        context.saveGState()
        context.translateBy(x: 19.5, y: 0)
        context.rotate(by: CGFloat.pi / 2)
        let textRect = CGRect(x: 0, y: 0, width: targetFrame.height, height: 20)
        let textPath = UIBezierPath(rect: textRect)

        promotionType.UIConfiguration.promotionLabelBackgroundColor.setFill()
        textPath.fill()
        let textTextContent = promotionType.UIConfiguration.promotionText
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: promotionType.UIConfiguration.fontSize),
                                  NSForegroundColorAttributeName: promotionType.UIConfiguration.promotionTextForegroundColor,
                                  NSParagraphStyleAttributeName: textStyle]

        let size = CGSize(width: textRect.width, height: CGFloat.infinity)
        let textTextHeight: CGFloat = textTextContent.boundingRect(with: size,
                                                                   options: .usesLineFragmentOrigin,
                                                                   attributes: textFontAttributes,
                                                                   context: nil).height
        context.saveGState()
        context.clip(to: textRect)
        let drawRect = CGRect(x: textRect.minX,
                              y: textRect.minY + (textRect.height - textTextHeight) / 2,
                              width: textRect.width,
                              height: textTextHeight)
        textTextContent.draw(in: drawRect, withAttributes: textFontAttributes)
        context.restoreGState()
    }
}
