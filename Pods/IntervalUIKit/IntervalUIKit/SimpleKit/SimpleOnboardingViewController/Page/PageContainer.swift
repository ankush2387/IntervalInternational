//
//  PageContaineView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class PageContrainer: UIView {

    // MARK: - Public properties
    var items: [PageViewItem]?
    let space: CGFloat // space between items
    var currentIndex = 0

    // MARK: - Private properties
    private let activeSegmentBorderColor: UIColor
    private let itemRadius: CGFloat
    private let selectedItemRadius: CGFloat
    private let itemsCount: Int
    private let animationKey = "animationKey"

    // MARK: - Lifecycle
    init(radius: CGFloat, selectedRadius: CGFloat, space: CGFloat, itemsCount: Int, activeSegmentBorderColor: UIColor) {
        self.space = space
        self.itemRadius = radius
        self.itemsCount = itemsCount
        self.selectedItemRadius = selectedRadius
        self.activeSegmentBorderColor = activeSegmentBorderColor
        super.init(frame: CGRect.zero)
        items = createItems(itemsCount, radius: radius, selectedRadius: selectedRadius)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions
    func currenteIndex(_ index: Int, duration: Double, animated: Bool) {
        guard let items = self.items, index != currentIndex else {return}
        animationItem(items[index], selected: true, duration: duration)
        let fillColor = index > currentIndex ? true : false
        animationItem(items[currentIndex], selected: false, duration: duration, fillColor: fillColor)
        currentIndex = index
    }

    // MARK: - Private functions
    // Animations
    private func animationItem(_ item: PageViewItem, selected: Bool, duration: Double, fillColor: Bool = false) {
        let toValue = selected == true ? selectedItemRadius * 2 : itemRadius * 2
        item.constraints
            .filter { $0.identifier == "animationKey" }
            .forEach {
                $0.constant = toValue
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { self.layoutIfNeeded() },
                       completion: nil)

        item.animationSelected(selected, duration: duration, fillColor: fillColor)
    }

    private func createItems(_ count: Int, radius: CGFloat, selectedRadius: CGFloat) -> [PageViewItem] {
        var items = [PageViewItem]()
        // create first item
        var tag = 1
        var item = createItem(radius, selectedRadius: selectedRadius, isSelect: true)
        item.tag = tag
        addConstraintsToView(item, radius: selectedRadius)
        items.append(item)

        for _ in 1..<count {
            tag += 1
            let nextItem = createItem(radius, selectedRadius: selectedRadius)
            addConstraintsToView(nextItem, leftItem: item, radius: radius)
            items.append(nextItem)
            item = nextItem
            item.tag = tag
        }

        return items
    }

    private func createItem(_ radius: CGFloat, selectedRadius: CGFloat, isSelect: Bool = false) -> PageViewItem {
        let item = Init(PageViewItem(radius: radius, selectedRadius: selectedRadius, activeSegmentBorderColor: activeSegmentBorderColor, isSelect: isSelect)) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
        }

        self.addSubview(item)
        return item
    }

    private func addConstraintsToView(_ item: UIView, radius: CGFloat) {
        [NSLayoutAttribute.left, NSLayoutAttribute.centerY].forEach { attribute in
            (self, item) >>>- { $0.attribute = attribute; return }
        }

        [NSLayoutAttribute.width, NSLayoutAttribute.height].forEach { attribute in
            item >>>- {
                $0.attribute = attribute
                $0.constant = radius * 2.0
                $0.identifier = animationKey
                return
            }
        }
    }

    private func addConstraintsToView(_ item: UIView, leftItem: UIView, radius: CGFloat) {
        (self, item) >>>- { $0.attribute = .centerY; return }
        (self, item, leftItem) >>>- {
            $0.attribute = .leading
            $0.secondAttribute = .trailing
            $0.constant = space
            return
        }

        [NSLayoutAttribute.width, NSLayoutAttribute.height].forEach { attribute in
            item >>>- {
                $0.attribute  = attribute
                $0.constant   = radius * 2.0
                $0.identifier = animationKey
                return
            }
        }
    }
}
