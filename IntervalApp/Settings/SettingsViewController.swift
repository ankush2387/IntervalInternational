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
    fileprivate var omnitureFieldIndexPath: IndexPath?
    
    // Since we are currently forced to use a storyBoard we cannot inject a viewModel
    // Therefore, must initialize the dependency internally...
    fileprivate let viewModel = SettingsViewModel()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    // MARK: - Private functions
    private func setUI() {
        title = "Settings".localized()
        versionLabel.textColor = IntervalThemeFactory.deviceTheme.textColorGray
        setMenuButton()
        registerSimpleCellViews(withTableView: tableView)
        tableView.tableFooterView = UIView()
    }
    
    private func bindUI() {
        viewModel.appVersion.bind(to: versionLabel.reactive.text).dispose(in: disposeBag)

        viewModel.simpleLabelSwitchCellViewModel.switchOn.observeNext { [unowned self] _ in

            if let omnitureFieldIndexPath = self.omnitureFieldIndexPath {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [omnitureFieldIndexPath], with: .automatic)
                self.tableView.endUpdates()
            }

            }.dispose(in: disposeBag)
    }

    private func setMenuButton() {
        if let revealView = revealViewController() {
            revealView.delegate = self
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu),
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

    fileprivate func signOut() {
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
        Constant.MyClassConstants.topDeals.removeAll()
        Constant.MyClassConstants.flexExchangeDeals.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.MyClassConstants.popToLoginView), object: nil)
    }

    fileprivate func presentRestartNeededAlert() {

        let alertMessage = "In order for these changes to take affect you must terminate this session, and restart the application. Do you wish to terminate this application session now?"

        presentAlert(with: "Alert",
                     message: alertMessage,
                     cancelButtonTitle: "Later",
                     acceptButtonTitle: "Restart Now") { preconditionFailure("Killed App on purpose") }
    }
}

extension SettingsViewController: UITableViewDataSource, SimpleViewModelBinder {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if viewModel.cellViewModels[indexPath.row] is SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel {
            omnitureFieldIndexPath = indexPath
            if viewModel.simpleLabelSwitchCellViewModel.switchOn.value {
                return 180
            } else {
                return 0
            }
        }

        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let cell = cellView(tableView, forIndexPath: indexPath, forViewModelType: cellViewModel.modelType())

        if let cell = cell as? SimpleLabelLabelCell {
            cell.accessoryType = .disclosureIndicator
        }

        if let cell = cell as? SimpleButtonCell {
            cell.buttonPressed = { [weak self] in
                self?.signOut()
            }
        }

        if let cell = cell as? SimpleLabelTextFieldLabelTextFieldButtonButtonCell {

            cell.button1Pressed = { [unowned self] in
                // Reset button pressed
                // Note: Won't go to production, no need to localize

                guard !(self.viewModel.omnitureConfigurationViewModel?.textFieldValue1.value).unwrappedString.isEmpty
                    || !(self.viewModel.omnitureConfigurationViewModel?.textFieldValue2.value).unwrappedString.isEmpty else {
                        self.presentAlert(with: "Alert", message: "There is nothing to reset", hideCancelButton: true)
                        return
                }

                let confirmationMessage = "This will remove custom omniture url configuration, are you sure you wish to continue?"
                let acceptHandler = {
                    self.viewModel.simpleLabelSwitchCellViewModel.switchOn.next(false)
                    self.viewModel.omnitureConfigurationViewModel?.textFieldValue1.next(nil)
                    self.viewModel.omnitureConfigurationViewModel?.textFieldValue2.next(nil)
                    self.viewModel.resetOmnitureURL()
                    self.presentRestartNeededAlert()
                }

                self.presentAlert(with: "Alert",
                                  message: confirmationMessage,
                                  cancelButtonTitle: "Cancel",
                                  acceptButtonTitle: "Continue",
                                  acceptHandler: acceptHandler)
            }

            cell.button2Pressed = {
                // Save button pressed
                self.viewModel.saveCustomOmnitureURL()
                    .then(self.presentRestartNeededAlert)
                    .onViewError(self.presentErrorAlert)
            }
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
