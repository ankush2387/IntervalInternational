//
//  SimpleOnboardingView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

// An instance of SimpleOnboardingView which display collection of information.
final class SimpleOnboardingView: UIView {

    // MARK: - Public properties
    ///  The object that acts as the data source of the  PaperOnboardingDataSource.
    weak var dataSource: SimpleOnboardingViewDelegate? { didSet { commonInit() } }

    /// The object that acts as the delegate of the PaperOnboarding. PaperOnboardingDelegate protocol
    weak var delegate: SimpleOnboardingViewDelegate?

    // MARK: - Private properties
    fileprivate var pageView: PageView?
    fileprivate var currentIndex: Int = 0
    fileprivate var onboardingPages: Int = 0
    fileprivate var pageViewRadius: CGFloat = 8
    fileprivate var gestureControl: GestureControl?
    fileprivate var contentView: OnboardingContentView?
    fileprivate var pageViewBottomConstant: CGFloat = 32
    fileprivate var pageViewSelectedRadius: CGFloat = 22
    fileprivate var fillAnimationView: FillAnimationView?
    fileprivate var onboardingPageEntities: [SimpleOnboardingPageEntity] = []

    // MARK: - Private function
    private func commonInit() {

        if case let dataSource as SimpleOnboardingDataSource = self.dataSource { onboardingPages = dataSource.onboardingItemsCount() }
        onboardingPageEntities = createItemsInfo()
        translatesAutoresizingMaskIntoConstraints = false
        fillAnimationView = FillAnimationView.animavtionViewOnView(self, color: backgroundColor(currentIndex))
        contentView = OnboardingContentView.contentViewOnView(self,
                                                              delegate: self,
                                                              itemsCount: onboardingPages,
                                                              bottomConstant: pageViewBottomConstant * -1 - pageViewSelectedRadius)

        pageView = createPageView()
        gestureControl = GestureControl(view: self, delegate: self)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGesture)
    }

    @objc private func tapAction(_ sender: UITapGestureRecognizer) {

        guard let delegate = delegate,
            let pageView = self.pageView,
            let pageControl = pageView.containerView,
            delegate.enableTapsOnPageControl else { return }

        let touchLocation = sender.location(in: self)
        let convertedLocation = pageControl.convert(touchLocation, from: self)
        guard let pageItem = pageView.hitTest(convertedLocation, with: nil) else { return }
        let index = pageItem.tag - 1
        guard index != currentIndex else { return }
        currentIndex(index, animated: true)
        delegate.onboardingWillTransitonToIndex(index)
    }

    private func createPageView() -> PageView {

        let pageView = PageView.pageViewOnView(self,
                                               itemsCount: onboardingPages,
                                               bottomConstant: pageViewBottomConstant * -1,
                                               radius: pageViewRadius,
                                               selectedRadius: pageViewSelectedRadius,
                                               activeSegmentBorderColor: onboardingPageEntities[currentIndex].titleTextColor)

        pageView.configuration = { item, index in
            item.imageView?.image = self.onboardingPageEntities[index].iconNavigator
        }

        return pageView
    }

    private func createItemsInfo() -> [SimpleOnboardingPageEntity] {

        guard case let dataSource as SimpleOnboardingDataSource = self.dataSource else {
            fatalError("set dataSource")
        }

        var items = [SimpleOnboardingPageEntity]()
        for index in 0..<onboardingPages {
            let info = dataSource.onboardingItemAtIndex(index)
            items.append(info)
        }
        return items
    }

    // MARK: - Fileprivate function
    /**
     Scrolls through the SimpleOnboardingView until a index is at a particular location on the screen.

     - parameter index:    Scrolling to a curretn index item.
     - parameter animated: True if you want to animate the change in position; false if it should be immediate.
     */
    fileprivate func currentIndex(_ index: Int, animated: Bool) {

        if 0 ..< onboardingPages ~= index {
            delegate?.onboardingWillTransitonToIndex(index)
            currentIndex = index
            CATransaction.begin()
            CATransaction.setCompletionBlock { self.delegate?.onboardingDidTransitonToIndex(index) }

            if let postion = pageView?.positionItemIndex(index, onView: self) {
                fillAnimationView?.fillAnimation(backgroundColor(currentIndex), centerPosition: postion, duration: 0.5)
            }

            pageView?.currentIndex(index, animated: animated)
            contentView?.currentViewItem(at: index, animated: animated)
            CATransaction.commit()
        }
    }

    fileprivate func backgroundColor(_ index: Int) -> UIColor {
        return onboardingPageEntities[index].screenColor
    }
}

// MARK: - GestureControlDelegate
extension SimpleOnboardingView: GestureControlDelegate {

    func gestureControlDidSwipe(_ direction: UISwipeGestureRecognizerDirection) {

        switch direction {
        case UISwipeGestureRecognizerDirection.right:
            currentIndex(currentIndex - 1, animated: true)
        case UISwipeGestureRecognizerDirection.left:
            currentIndex(currentIndex + 1, animated: true)
        default:
            fatalError()
        }
    }
}

// MARK: - OnboardingContentViewDelegate
extension SimpleOnboardingView: OnboardingContentViewDelegate {

    func onboardingItemAtIndex(_ index: Int) -> SimpleOnboardingPageEntity {
        return onboardingPageEntities[index]
    }

    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        delegate?.onboardingConfigurationItem(item, index: index)
    }
}
