//
//  OnboardingContentView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

protocol OnboardingContentViewDelegate: class {
    func onboardingItemAtIndex(_ index: Int) -> SimpleOnboardingPageEntity
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int)
}

final class OnboardingContentView: UIView {

    // MARK: - Public properties
    weak var delegate: OnboardingContentViewDelegate?

    // MARK: - Private properties
    private let showDuration = 0.8
    private let hideDuration = 0.2
    private let dyOffsetAnimation: CGFloat = 110
    private var onboardingViewItem: OnboardingContentViewItem?

    // MARK: - Lifecycle
    public init(itemsCount: Int, delegate: OnboardingContentViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions
    func currentViewItem(at index: Int, animated: Bool) {

        let showItem = createItem(index)
        showItemView(showItem, duration: showDuration)
        hideItemView(onboardingViewItem, duration: hideDuration)
        onboardingViewItem = showItem
    }

    // MARK: - Public static functions
    class func contentViewOnView(_ view: UIView,
                                 delegate: OnboardingContentViewDelegate,
                                 itemsCount: Int,
                                 bottomConstant: CGFloat) -> OnboardingContentView {

        let contentView = Init(OnboardingContentView(itemsCount: itemsCount, delegate: delegate)) {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(contentView)
        setContraint(for: contentView, in: view, with: bottomConstant)
        return contentView
    }

    class func setContraint(for contentView: OnboardingContentView, in view: UIView, with bottomConstant: CGFloat) {

        for attribute in [NSLayoutAttribute.left, NSLayoutAttribute.right, NSLayoutAttribute.top] {
            (view, contentView) >>>- { $0.attribute = attribute; return }
        }

        (view, contentView) >>>- {
            $0.attribute = .bottom
            $0.constant  = bottomConstant
            return
        }
    }

    // MARK: - Private functions
    private func commonInit() {
        onboardingViewItem = createItem(0)
    }

    private func createItem(_ index: Int) -> OnboardingContentViewItem {

        let info = delegate?.onboardingItemAtIndex(index)
        let item = Init(OnboardingContentViewItem.itemOnView(self)) {
            $0.titleLabel?.text = info?.title
            $0.imageView?.image = info?.mainImage
            $0.titleLabel?.font = info?.titleFont
            $0.titleLabel?.textColor = info?.titleTextColor
            $0.descriptionLabel?.text = info?.description
            $0.descriptionLabel?.font = info?.descriptionFont
            $0.descriptionLabel?.textColor = info?.descriptionTextColor
        }

        delegate?.onboardingConfigurationItem(item, index: index)
        return item
    }

    private func hideItemView(_ item: OnboardingContentViewItem?, duration: Double) {

        guard let item = item else { return }
        item.bottomConstraint?.constant -= dyOffsetAnimation
        item.centerConstraint?.constant *= 1.3

        let animation = {
            item.alpha = 0
            self.layoutIfNeeded()
        }

        let completion = { (success: Bool) in
            item.removeFromSuperview()
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: animation,
                       completion: completion)
    }

    private func showItemView(_ item: OnboardingContentViewItem, duration: Double) {

        item.bottomConstraint?.constant = dyOffsetAnimation
        item.centerConstraint?.constant /= 2
        item.alpha = 0
        layoutIfNeeded()
        item.bottomConstraint?.constant = 0
        item.centerConstraint?.constant *= 2

        let animations = { [unowned self] in
            item.alpha = 0
            item.alpha = 1
            self.layoutIfNeeded()
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: animations)
    }
}
