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
import IntervalUIKit

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
    @IBOutlet private weak var touchIDImageView: UIImageView!
    @IBOutlet private weak var loginHelpButton: UIButton!
    @IBOutlet private weak var joinTodayButton: UIButton!
    @IBOutlet private weak var resortDirectoryButton: UIButton!
    @IBOutlet private weak var intervalHDButton: UIButton!
    @IBOutlet private weak var privacyButton: UIButton!
    @IBOutlet private weak var magazinesButton: UIButton!
    @IBOutlet fileprivate weak var versionLabel: UILabel!
    @IBOutlet private var webActivityButtons: [UIButton]!

    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let simpleOnboardingViewModel: SimpleOnboardingViewModel?
    fileprivate let viewModel: LoginViewModel
    
    // MARK: - Lifecycle
    init(viewModel: LoginViewModel, simpleOnboardingViewModel: SimpleOnboardingViewModel? = nil) {
        self.viewModel = viewModel
        self.simpleOnboardingViewModel = simpleOnboardingViewModel
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
        showOnboardingIfNewAppInstance()
        setSplashScreenAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        viewModel.password.next(nil)
        touchIDImageView.isHidden = !viewModel.touchIDEnabled
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateUIForOrientation()
    }
    
    // MARK: - Private functions
    private func showOnboardingIfNewAppInstance() {
        if let simpleOnboardingViewModel = simpleOnboardingViewModel {
            present(SimpleOnboardingViewController(viewModel: simpleOnboardingViewModel), animated: false, completion: nil)
        }
    }

    private func setSplashScreenAnimation() {
        let initialIconSize = CGSize(width: 168, height: 44)
        let simpleRevealingAppLaunchView = SimpleRevealingAppLaunchView(iconImage: #imageLiteral(resourceName: "Interval_Splash_Logo "),
                                                               iconInitialSize: initialIconSize,
                                                               backgroundColor: #colorLiteral(red: 0.004279129673, green: 0.452577889, blue: 0.7227205634, alpha: 1))

        self.view.addSubview(simpleRevealingAppLaunchView)
        simpleRevealingAppLaunchView.startAnimation(performTouchIDLoginIfEnabled)
    }
    
    private func login() {
        showHudAsync()
        viewModel.normalLogin()
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    private func setUI() {
        backgroundImageView.image = viewModel.backgroundImage.value
        signInBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        updateUIForOrientation()
        setVersionLabelForNonProductionBuild()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        touchIDImageView.addGestureRecognizer(tap)
    }
    
    private func bindUI() {
        viewModel.username.bidirectionalBind(to: loginIDTextField.reactive.text)
        viewModel.password.bidirectionalBind(to: passwordTextField.reactive.text)
        signInButton.reactive.tap.observeNext(with: login).dispose(in: disposeBag)
        privacyButton.reactive.tap.observeNext(with: privacyButtonTapped).dispose(in: disposeBag)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        performTouchIDLoginIfEnabled()
    }

    private func performTouchIDLoginIfEnabled() {
        guard viewModel.touchIDEnabled else { return }
        let touchID = BiometricAuthentication()
        touchID.authenticateUser()
            .then(showHudAsync)
            .then(viewModel.touchIDLogin)
            .onViewError { [unowned self] error in
                if error.description.title != "Login cancelled".localized() {
                    self.presentErrorAlert(error)
                }
            }.finally(hideHudAsync)
    }

    private func enabledWebActivityButton(enable: Bool) {
        let backgroundColor = enable ? #colorLiteral(red: 0.008116544224, green: 0.4669411182, blue: 0.7459072471, alpha: 1) : .gray
        webActivitiesButtonsView.subviews.forEach { $0.backgroundColor = backgroundColor }
        webActivityButtons.forEach { $0.isEnabled = enable }
    }

    private func showLoginHelpWebView() {
        navigationController?.isNavigationBarHidden = false
        let webView = SimpleFileViewController(load: "https://www.intervalworld.com/web/my/account/forgotSignInInfo")
        show(webView, sender: self)
    }

    private func showJoinTodayWebView() {
        navigationController?.isNavigationBarHidden = false
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

        if enabled {
            signInButton.backgroundColor = #colorLiteral(red: 0.9414057136, green: 0.4359997809, blue: 0.210131973, alpha: 1)
        } else {
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
        
        guard let url = URL(string: "https://itunes.apple.com/us/app/interval-international/id388957867"),
            UIApplication.shared.canOpenURL(url) else {
                
                // If URL for app cannot be opened; open page for all IntervalInternational apps on App Store
                if let intervalAppsURL = URL(string: "https://itunes.apple.com/us/developer/interval-international/id388957870"),
                    UIApplication.shared.canOpenURL(intervalAppsURL) {
                    NetworkHelper.open(intervalAppsURL)
                } else {
                    presentErrorAlert(UserFacingCommonError.custom(title: "Error".localized(),
                                                                   body: "Unable to redirect to the App Store. Please open the App store updates tab to update.".localized()))
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
        Constant.MyClassConstants.runningFunctionality = Constant.MyClassConstants.resortFunctionalityCheck
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.iphone : Constant.storyboardNames.resortDirectoryIpad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
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
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            show(initialViewController, sender: self)
        }
    }
    
    func privacyButtonTapped() {
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.loginIPhone : Constant.storyboardNames.loginIPad
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyLegalViewController")
        navigationController?.pushViewController(initialViewController, animated: true)
    }
}
