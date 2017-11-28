//
//  SimpleOnboardingViewController.swift
//  AnimatedPageView
//
//  Created by Alex K. on 12/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

final public class SimpleOnboardingViewController: UIViewController {

    // MARK: - private properties
    fileprivate let viewModel: SimpleOnboardingViewModel

    // MARK: - IBOutlets
    @IBOutlet fileprivate weak var doneButton: UIButton!

    // MARK: - Overrides
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - IBActions
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    

    // MARK: - Lifecycle
    public init(viewModel: SimpleOnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SimpleOnboardingViewController", bundle: Bundle(for: SimpleOnboardingViewController.self))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties
    private func setUI() {
        setOnboardingView()
        setDoneButton()
    }

    private func setOnboardingView() {
        let onboardingView = SimpleOnboardingView()
        onboardingView.dataSource = self
        onboardingView.delegate = self
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboardingView)
        setConstraints(on: onboardingView)
    }

    private func setDoneButton() {
        doneButton.setTitle(viewModel.skipIntroButtonTitle, for: .normal)
        doneButton.setTitleColor(viewModel.onboardingPageEntities.first?.titleTextColor, for: .normal)
        view.addSubview(doneButton)
        doneButton.isHidden = !viewModel.allowsOnboardingSkip
    }

    private func setConstraints(on onboardingView: UIView) {
        [NSLayoutAttribute.left, NSLayoutAttribute.right, NSLayoutAttribute.top, NSLayoutAttribute.bottom].forEach {
            view.addConstraint(NSLayoutConstraint(item: onboardingView,
                                                  attribute: $0,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: $0,
                                                  multiplier: 1,
                                                  constant: 0))
        }
    }
}

// MARK: - PaperOnboardingDelegate
extension SimpleOnboardingViewController: SimpleOnboardingViewDelegate {
    public func onboardingWillTransitonToIndex(_ index: Int) {
        doneButton.setTitleColor(viewModel.onboardingPageEntities[index].titleTextColor, for: .normal)
        if viewModel.onboardingPageEntities.count - 1 == index {
            doneButton.setTitle(viewModel.doneButtonTitle, for: .normal)
            doneButton.isHidden = false
        }
    }
}

// MARK: - SimpleOnboardingDataSource
extension SimpleOnboardingViewController: SimpleOnboardingDataSource {

    public func onboardingItemAtIndex(_ index: Int) -> SimpleOnboardingPageEntity {
        return viewModel.onboardingPageEntities[index]
    }

    public func onboardingItemsCount() -> Int {
        return viewModel.onboardingPageEntities.count
    }
}
