//
//  PageView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class PageView: UIView {

    // MARK: - Public properties
    var itemsCount = 3
    var space: CGFloat = 20
    var duration: Double = 0.7
    var itemRadius: CGFloat = 8.0
    var containerView: PageContrainer?
    var selectedItemRadius: CGFloat = 22.0
    var activeSegmentBorderColor: UIColor = .white

    // Configure items set image or chage color for border view
    var configuration: ((_ item: PageViewItem, _ index: Int) -> Void)? {
        didSet { configurePageItems(containerView?.items) }
    }

    // MARK: - Private properties
    private var containerX: NSLayoutConstraint?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    init(frame: CGRect, itemsCount: Int, radius: CGFloat, selectedRadius: CGFloat, activeSegmentBorderColor: UIColor) {
        self.itemsCount = itemsCount
        self.itemRadius = radius
        self.selectedItemRadius = selectedRadius
        self.activeSegmentBorderColor = activeSegmentBorderColor
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Overrides
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let containerView = self.containerView, let items = containerView.items else { return nil }

        for item in items {
            let frame = item.frame.insetBy(dx: -10, dy: -10)
            guard frame.contains(point) else { continue }
            return item
        }

        return nil
    }

    class func pageViewOnView(_ view: UIView,
                              itemsCount: Int,
                              bottomConstant: CGFloat,
                              radius: CGFloat,
                              selectedRadius: CGFloat,
                              activeSegmentBorderColor: UIColor) -> PageView {

        let pageView = Init(PageView(frame: CGRect.zero,
                                     itemsCount: itemsCount,
                                     radius: radius,
                                     selectedRadius: selectedRadius,
                                     activeSegmentBorderColor: activeSegmentBorderColor)) {
                                        $0.translatesAutoresizingMaskIntoConstraints = false
                                        $0.alpha = 0.4
        }

        view.addSubview(pageView)

        // add constraints
        for (attribute, constant) in [(NSLayoutAttribute.left, 0), (NSLayoutAttribute.right, 0), (NSLayoutAttribute.bottom, bottomConstant)] {
            (view, pageView) >>>- {
                $0.constant = CGFloat(constant)
                $0.attribute = attribute
                return
            }
        }

        pageView >>>- {
            $0.attribute = .height
            $0.constant = 30
            return
        }

        return pageView
    }

    func currentIndex(_ index: Int, animated: Bool) {

        if 0..<itemsCount ~= index {
            containerView?.currenteIndex(index, duration: duration * 0.5, animated: animated)
            moveContainerTo(index, animated: animated, duration: duration)
        }
    }

    func positionItemIndex(_ index: Int, onView: UIView) -> CGPoint? {
        if 0..<itemsCount ~= index {
            if let currentItem = containerView?.items?[index].imageView {
                let pos = currentItem.convert(currentItem.center, to: onView)
                return pos
            }
        }

        return nil
    }

    // MARK: - Private functions
    private func commonInit() {
        containerView = createContainerView()
        currentIndex(0, animated: false)
        self.backgroundColor = .clear
    }

    private func createContainerView() -> PageContrainer {
        let container = Init(PageContrainer(radius: itemRadius,
                                            selectedRadius: selectedItemRadius,
                                            space: space, itemsCount: itemsCount,
                                            activeSegmentBorderColor: activeSegmentBorderColor)) {
                                                $0.backgroundColor = .clear
                                                $0.translatesAutoresizingMaskIntoConstraints = false
        }

        self.addSubview(container)

        // add constraints
        for attribute in [NSLayoutAttribute.top, NSLayoutAttribute.bottom] {
            (self, container) >>>- { $0.attribute = attribute; return }
        }

        containerX = (self, container) >>>- { $0.attribute = .centerX; return }

        container >>>- {
            $0.attribute = .width
            $0.constant  = selectedItemRadius * 2 + CGFloat(itemsCount - 1) * (itemRadius * 2) + space * CGFloat(itemsCount - 1)
            return
        }
        return container
    }

    private func configurePageItems(_ items: [PageViewItem]?) {

        guard let items = items else {
            return
        }

        for index in 0..<items.count {
            configuration?(items[index], index)
        }
    }

    // Animation
    private func moveContainerTo(_ index: Int, animated: Bool = true, duration: Double = 0) {
        guard let containerX = self.containerX else {
            return
        }

        let containerWidth = CGFloat(itemsCount + 1) * selectedItemRadius + space * CGFloat(itemsCount - 1)
        let toValue = containerWidth / 2.0 - selectedItemRadius - (selectedItemRadius + space) * CGFloat(index)
        containerX.constant = toValue

        if animated == true {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: UIViewAnimationOptions(),
                           animations: {
                            self.layoutIfNeeded()
            },
                           completion: nil)
        } else {
            layoutIfNeeded()
        }
    }
}
