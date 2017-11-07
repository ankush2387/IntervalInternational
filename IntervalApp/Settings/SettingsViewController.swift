//
//  SettingsViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/7/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import UIKit
import DarwinSDK
import ReactiveKit
import IntervalUIKit

final class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var versionLabel: UILabel!
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    
    // Since we are currently forced to use a storyBoard we cannot inject a viewModel
    // Therefore, must initialize the dependency internally...
    fileprivate let viewModel = SettingsViewModel(appBundle: AppBundle(), encryptedStore: Keychain(), authentication: BiometricAuthentication())
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    // MARK: - Private functions
    private func setUI() {
        title = "Settings".localized()
        versionLabel.textColor = IntervalThemeFactory.deviceTheme.secondaryTextColor
        setMenuButton()
        registerSimpleCellViews(withTableView: tableView)
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out".localized(),
                                                            style: .plain, target: self, action: #selector(signOut))
    }
    
    private func bindUI() {
        viewModel.appVersion.bind(to: versionLabel.reactive.text).dispose(in: disposeBag)
    }
    
    private func setMenuButton() {
        if let revealView = revealViewController() {
            revealView.delegate = self
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu),
                                             style: .plain,
                                             target: revealView,
                                             action: #selector(revealView.revealToggle(_:)))
            
            menuButton.tintColor = UIColor.white
            view.addGestureRecognizer(revealView.panGestureRecognizer())
            navigationItem.leftBarButtonItem = menuButton
        }
    }

    @objc private func menuBackButtonPressed() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
    }

    @objc private func signOut() {
        // Horrible sigleton code moved from other viewController here...
        // Also this singleton pattern forces me to import the DarwinSDK just to reset the PointsProgram.
        // I could add code to the constants class to do it via an interface but don't want to keep feeding the beast.
        Session.sharedSession.signOut()
        //Remove all favorites for a user.
        Constant.MyClassConstants.favoritesResortArray.removeAll()
        Constant.MyClassConstants.favoritesResortCodeArray.removeAllObjects()
        //Remove available points for relinquishment program
        Constant.MyClassConstants.relinquishmentProgram = PointsProgram()
        //Remove all saved alerts for a user.
        Constant.MyClassConstants.getawayAlertsArray.removeAll()
        Constant.MyClassConstants.isLoginSuccessfull = false
        Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
    }
}

extension SettingsViewController: UITableViewDataSource, SimpleViewModelBinder {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let cell = cellView(tableView, forIndexPath: indexPath, forViewModelType: cellViewModel.modelType())

        if let cell = cell as? SimpleLabelLabelCell {
            cell.accessoryType = .disclosureIndicator
        }

        bindSimpleCellView(cell, withSimpleViewModel: cellViewModel)
        cell.selectionStyle = .none
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {

    private func showPrivacyView() {
        let url = "http://www.intervalworld.com/web/cs?a=60&p=privacy-policy"
        let fileViewController = SimpleFileViewController(url: url)
        navigationController?.pushViewController(fileViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellViewModel = viewModel.cellViewModels[indexPath.row] as? SimpleLabelLabelCellViewModel, cellViewModel.label2.value == viewModel.privacyPolicy.value {
            showPrivacyView()
        }
    }
}
