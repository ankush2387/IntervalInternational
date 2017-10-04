//
//  AppCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import DarwinSDK
import IntervalUIKit

final class AppCoordinator {
    
    // MARK: - Public properties

    var initialViewController = UIViewController()
    
    // MARK: - Private properties
    private let preLoginCoordinator: PreLoginCoordinator
    private let relinquishmentProgram = PointsProgram()
    private var navigationController: UINavigationController?

    fileprivate let session = Session.sharedSession
    fileprivate let loginCoordinator: LoginCoordinator
    fileprivate let autoLogoutTimer = AutoLogoutTimer()

    fileprivate var userIsLoggedIn = false
    fileprivate var autoLogoutViewController: UIAlertController?

    var topViewController: UIViewController? {
        if var topViewController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            return topViewController
        }
        return nil
    }
    
    // MARK: - Lifecycle
    init() {
        loginCoordinator = LoginCoordinator()
        initialViewController = loginCoordinator.loginView()
        preLoginCoordinator = PreLoginCoordinator(clientAPIStore: ClientAPI.sharedInstance)
    }
    
    // MARK: - Public functions
    
    func startApplication(with navigationController: UINavigationController) {
        
        setDelegates()
        
        // TODO: This needs to be removed; When you see this think code smell.
        Constant.MyClassConstants.runningDeviceWidth = UIScreen.main.bounds.width

        // TODO: This needs to be replaced with a UI Widget Framework to not perform inconsistent global UI changes
        IUIKitManager.updateAppearance()
        
        preLoginCoordinator.start()
        self.navigationController = navigationController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func applicationEnteredForeground() {
        autoLogoutTimer.applicationEnteredForeground()
    }

    func applicationDidEnterBackground() {
        autoLogoutTimer.applicationEnteredBackground()
    }
    
    // MARK: - Private functions
    
    private func setDelegates() {
        autoLogoutTimer.delegate = self
        loginCoordinator.delegate = self
        preLoginCoordinator.delegate = self
    }

    private func presentAutologoutNotification() {
        topViewController?.presentAlert(with: "Logged Out".localized(),
                                        message: "You have been automatically logged out due to inactivity.".localized(),
                                        hideCancelButton: true)
    }

    fileprivate func startLogout() {
        
        session.signOut() // Hmm.. this might be more appropriately moved into the DarwinSDK

        //Remove all favorites for a user.
        Constant.MyClassConstants.favoritesResortArray.removeAll()
        Constant.MyClassConstants.favoritesResortCodeArray.removeAllObjects()
        //Remove all saved alerts for a user.
        Constant.MyClassConstants.getawayAlertsArray.removeAll()
        Constant.MyClassConstants.isLoginSuccessfull = false
        Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        TouchID().deactivateTouchID()

        // TODO: - Need to refactor code/calls above

        logoutDidFinish()
    }

    fileprivate func logoutDidFinish() {
        navigationController?.popToRootViewController(animated: true)
        userIsLoggedIn = false
        autoLogoutTimer.stop()
        autoLogoutViewController?.dismiss(animated: false)
        autoLogoutViewController = nil
        presentAutologoutNotification()
    }
}

extension AppCoordinator: IntervalApplicationDelegate {
    
    func userDidTouchScreen() {
        // Restart the timer if user is logged in AND autoLogout is not already started
        if userIsLoggedIn && autoLogoutViewController == nil {
            autoLogoutTimer.restart()
        }
    }
}

extension AppCoordinator: PreLoginCoordinatorDelegate {
    
    func didLoad(token: DarwinAccessToken, settings: Settings) {
        session.clientAccessToken = token
        session.appSettings = settings
        loginCoordinator.clientTokenLoaded()
    }
    
    func didError() {
        topViewController?.showBannerNotification(with: "Connection Failure".localized(),
                                                  subtitle: "Some services may be temporarily unavailable".localized(),
                                                  for: .warning)

    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    
    func didLogin() {
        userIsLoggedIn = true
        autoLogoutTimer.restart()
    }
}

extension AppCoordinator: AutoLogoutDelegate {
    
    func startWarning() {
        guard userIsLoggedIn else { return }

        let action = { [unowned self] (_: UIAlertAction) in
            self.autoLogoutTimer.restart()
            self.autoLogoutViewController = nil
        }

        autoLogoutViewController = UIAlertController(title: "Autologout".localized(),
                                                     message: "Press Cancel to stop autologout".localized(),
                                                     preferredStyle: .alert)

        if let autoLogoutViewController = autoLogoutViewController, let topViewController = topViewController {
            autoLogoutViewController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: action))
            if UIApplication.shared.applicationState == .active {
                topViewController.present(autoLogoutViewController, animated: true)
            }
        }
    }
    
    func stopWarning() {
        if case .some = autoLogoutViewController?.presentingViewController {
            topViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func warningTimeLeft(seconds: Int) {
        let secondsLeft = seconds == 1 ? "second left".localized() : "seconds left".localized()
        autoLogoutViewController?.setValue("\(seconds) " + secondsLeft, forKey: "title")
    }
    
    func startAutoLogout() {
        startLogout()
    }
}
