//
//  LoginViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import ReactiveKit


final class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var signInBackgroundView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var webActivitiesButtonsView: UIView!
    @IBOutlet private weak var portraitStackView: UIStackView!
    @IBOutlet private weak var landscapeStackView: UIStackView!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var loginIDTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var enableTouchIDLabel: UILabel!
    @IBOutlet private weak var touchIDButton: UIButton!
    @IBOutlet private weak var touchIDImageView: UIImageView!
    @IBOutlet private weak var loginHelpButton: UIButton!
    @IBOutlet private weak var joinTodayButton: UIButton!
    @IBOutlet private weak var resortDirectoryButton: UIButton!
    @IBOutlet private weak var intervalHDButton: UIButton!
    @IBOutlet private weak var privacyButton: UIButton!
    @IBOutlet private weak var magazinesButton: UIButton!
    @IBOutlet fileprivate weak var versionLabel: UILabel!
    @IBOutlet private var touchIDArea: [UIView]!
    @IBOutlet private var webActivityButtons: [UIButton]!

    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let touchID = TouchIDAuth()
    fileprivate let viewModel: LoginViewModel
    
    // MARK: - Lifecycle
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
        performTouchIDLoginIfEnabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.password.next(nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateUIForOrientation()
    }
    
    // MARK: - Private functions
    private func login() {
        showHudAsync()
        viewModel.login()
            .onViewError(handler: presentErrorAlert)
            .finally(hideHudAsync)
    }

    private func presentTouchIDOptions() {

        if viewModel.touchIDEnabled.value {

            presentAlert(with: "Action".localized(),
                         message: "Would you like to disable sign in with touch ID?".localized(),
                         hideCancelButton: false, cancelButtonTitle: "No".localized(),
                         acceptButtonTitle: "Yes".localized(),
                         acceptHandler: { [unowned self] in
                            self.viewModel.touchIDEnabled.next(false)
            })

        } else {

            presentAlert(with: "Action".localized(),
                         message: "Would you like to enable sign in with touch ID?".localized(),
                         hideCancelButton: false, cancelButtonTitle: "No".localized(),
                         acceptButtonTitle: "Yes".localized(),
                         acceptHandler: { [unowned self] in
                            self.viewModel.touchIDEnabled.next(true)
                            self.login()
            })
        }
    }

    private func setUI() {

        if !touchID.canEvaluatePolicy {
            touchIDArea.forEach { $0.isHidden = true }
        }
        
        backgroundImageView.image = viewModel.backgroundImage.value
        signInBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        updateUIForOrientation()
        setVersionLabelForNonProductionBuild()
    }

    private func updateTouchIDText(enabled: Bool) {
        if enabled {
            enableTouchIDLabel.text = "Disable Touch ID".localized()
            self.touchIDImageView.image = #imageLiteral(resourceName: "TouchID-On")
        } else {
            enableTouchIDLabel.text = "Enable Touch ID".localized()
            self.touchIDImageView.image = #imageLiteral(resourceName: "TouchID-Off")
        }
    }
    
    private func bindUI() {
        viewModel.username.bidirectionalBind(to: loginIDTextField.reactive.text)
        viewModel.password.bidirectionalBind(to: passwordTextField.reactive.text)
        signInButton.reactive.tap.observeNext(with: login).dispose(in: disposeBag)
        viewModel.touchIDEnabled.observeNext(with: updateTouchIDText).dispose(in: disposeBag)
        privacyButton.reactive.tap.observeNext(with: privacyButtonTapped).dispose(in: disposeBag)
        touchIDButton.reactive.tap.observeNext(with: presentTouchIDOptions).dispose(in: disposeBag)
        viewModel.buttonEnabledState.observeNext(with: updateLoginButtonsUI).dispose(in: disposeBag)
        loginHelpButton.reactive.tap.observeNext(with: showLoginHelpWebView).dispose(in: disposeBag)
        joinTodayButton.reactive.tap.observeNext(with: showJoinTodayWebView).dispose(in: disposeBag)
        magazinesButton.reactive.tap.observeNext(with: magazinesButtonTapped).dispose(in: disposeBag)
        viewModel.buttonEnabledState.bind(to: signInButton.reactive.isEnabled).dispose(in: disposeBag)
        intervalHDButton.reactive.tap.observeNext(with: intervalHDButtonTapped).dispose(in: disposeBag)
        viewModel.clientTokenLoaded.observeNext(with: enabledWebActivityButton).dispose(in: disposeBag)
        viewModel.appSettings.flatMap { $0 }.observeNext(with: checkAppVersion).dispose(in: disposeBag)
        viewModel.isLoggingIn.map { !$0 }.bind(to: loginIDTextField.reactive.isEnabled).dispose(in: disposeBag)
        viewModel.isLoggingIn.map { !$0 }.bind(to: passwordTextField.reactive.isEnabled).dispose(in: disposeBag)
        resortDirectoryButton.reactive.tap.observeNext(with: resortDirectoryButtonTapped).dispose(in: disposeBag)
    }

    private func performTouchIDLoginIfEnabled() {
        guard viewModel.touchIDEnabled.value else { return }
        touchID.authenticateUser()
            .then(login)
            .onViewError { [unowned self] error in
                if error.description.title != "Login cancelled".localized() {
                    self.presentErrorAlert(error)
                }
        }
    }

    private func enabledWebActivityButton(enable: Bool) {
        let backgroundColor = enable ? #colorLiteral(red: 0.008116544224, green: 0.4669411182, blue: 0.7459072471, alpha: 1) : .gray
        webActivitiesButtonsView.subviews.forEach { $0.backgroundColor = backgroundColor }
        webActivityButtons.forEach { $0.isEnabled = enable }
    }

    private func showLoginHelpWebView() {
        let webView = SimpleFileViewController(load: "https://www.intervalworld.com/web/my/account/forgotSignInInfo")
        show(webView, sender: self)
    }

    private func showJoinTodayWebView() {
        let webView = SimpleFileViewController(load: "https://www.intervalworld.com/web/my/account/createProfileOrJoin")
        show(webView, sender: self)
    }
    
    private func setLandscapeStackView() {
        landscapeStackView.insertArrangedSubview(signInBackgroundView, at: 0)
        landscapeStackView.insertArrangedSubview(webActivitiesButtonsView, at: 1)
    }
    
    private func setPortraitStackView() {
        portraitStackView.insertArrangedSubview(signInBackgroundView, at: 0)
        portraitStackView.insertArrangedSubview(webActivitiesButtonsView, at: 1)
    }
    
    private func setVersionLabelForNonProductionBuild() {
        versionLabel.text = viewModel.versionLabel.text
        versionLabel.isHidden = viewModel.versionLabel.isHidden
    }
    
    private func updateLoginButtonsUI(enabled: Bool) {

        signInButton.isEnabled = enabled
        touchIDButton.isEnabled = enabled

        if enabled {
            enableTouchIDLabel.textColor = #colorLiteral(red: 0.1358070672, green: 0.5175437927, blue: 1, alpha: 1)
            signInButton.backgroundColor = #colorLiteral(red: 0.9414057136, green: 0.4359997809, blue: 0.210131973, alpha: 1)
        } else {
            enableTouchIDLabel.textColor = .gray
            signInButton.backgroundColor = .gray
        }
    }
    
    private func updateUIForOrientation() {
        let inPortraitMode = UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown
        landscapeStackView.isHidden = inPortraitMode
        portraitStackView.isHidden = !landscapeStackView.isHidden

        if inPortraitMode {
            setPortraitStackView()
        } else {
            setLandscapeStackView()
        }
    }
}

extension LoginViewController: ComputationHelper {
    
    private func update() {
        
        struct UpdateError: ViewError {
            var description: (title: String, body: String) {
                return ("Error".localized(), "Unable to redirect to the App Store. Please open the App store updates tab to update.".localized())
            }
        }
        
        guard let url = URL(string: "https://itunes.apple.com/us/app/interval-international/id388957867"),
            UIApplication.shared.canOpenURL(url) else {
                
                // If URL for app cannot be opened; open page for all IntervalInternational apps on App Store
                if let intervalAppsURL = URL(string: "https://itunes.apple.com/us/developer/interval-international/id388957870"),
                    UIApplication.shared.canOpenURL(intervalAppsURL) {
                    NetworkHelper.open(intervalAppsURL)
                } else {
                    presentErrorAlert(UpdateError())
                }
                
                return
        }
        
        NetworkHelper.open(url)
    }
    
    private func showForceUpdateAlert(for appSettings: AppSettings) {
        presentAlert(with: "Update Required".localized(),
                     message: appSettings.minimumSupportedVersionAlert.unwrappedString,
                     hideCancelButton: true,
                     acceptButtonTitle: "Update".localized(),
                     acceptHandler: update)
    }
    
    private func showUpdateAlert(for appSettings: AppSettings) {
        presentAlert(with: "Newer Version Available".localized(),
                     message: appSettings.currentVersionAlert.unwrappedString,
                     cancelButtonTitle: "Update".localized(),
                     acceptButtonTitle: "Not Now".localized(),
                     cancelHandler: update)
    }
    
    fileprivate func checkAppVersion(appSettings: AppSettings) {
        
        let updateRequired = checkIfPassedIn(appSettings.minimumSupportedVersion.unwrappedString, isNewerThan: viewModel.appBundle.appVersion)
        let newerVersionAvailable = checkIfPassedIn(appSettings.currentVersion.unwrappedString, isNewerThan: viewModel.appBundle.appVersion)
        
        guard !updateRequired else {
            showForceUpdateAlert(for: appSettings)
            return
        }
        
        if newerVersionAvailable {
            showUpdateAlert(for: appSettings)
        }
    }
}

// MARK: - TODO: Code to be removed; Temp location
// Workaround
extension LoginViewController {

    var isRunningOnIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    func resortDirectoryButtonTapped() {
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.iphone : Constant.storyboardNames.resortDirectoryIpad
        if let initialViewController = UIStoryboard(name:storyboardName, bundle: nil).instantiateInitialViewController() {
            show(initialViewController, sender: self)
        }
    }
    
    func intervalHDButtonTapped() {
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.intervalHDIphone : Constant.storyboardNames.intervalHDIpad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            show(initialViewController, sender: self)
        }
    }
    
    func magazinesButtonTapped() {
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.magazinesIphone : Constant.storyboardNames.magazinesIpad
        if let initialViewController = UIStoryboard(name:storyboardName, bundle: nil).instantiateInitialViewController() {
            show(initialViewController, sender: self)
        }
    }
    
    func privacyButtonTapped() {
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.loginIPhone : Constant.storyboardNames.loginIPad
        let storyboard = UIStoryboard(name:storyboardName, bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyLegalViewController")
        navigationController?.pushViewController(initialViewController, animated: true)
    }
}
