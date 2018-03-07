//
//  AppCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Foundation
import DarwinSDK
import IntervalUIKit

final class AppCoordinator {
    
    // MARK: - Public properties
    var initialViewController = UIViewController()
    
    // MARK: - Private properties
    private let relinquishmentProgram = PointsProgram()
    private var appState: AppState = .foreground
    
    fileprivate let session = Session.sharedSession
    fileprivate let loginCoordinator: LoginCoordinator
    fileprivate let autoLogoutTimer = AutoLogoutTimer()
    private let preLoginCoordinator = PreLoginCoordinator()
    
    fileprivate var userIsLoggedIn = false
    fileprivate var apnsCoordinator = APNSCoordinator()
    fileprivate var entityStore = EntityDataSource.sharedInstance
    fileprivate var autoLogoutViewController: UIAlertController?
    fileprivate var navigationController: UINavigationController?
    
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
        addObserver()
    }
    
    // MARK: - Public functions
    
    func startApplication(with navigationController: UINavigationController) {
        
        setDelegates()
        
        // TODO: This needs to be replaced with a UI Widget Framework to not perform inconsistent global UI changes
        IUIKitManager.updateAppearance()
        
        preLoginCoordinator.start()
        self.navigationController = navigationController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func applicationEntered(state: AppState) {
        appState = state
        switch state {
        case .foreground:
            autoLogoutTimer.applicationEnteredForeground()
        case .background:
            autoLogoutTimer.applicationEnteredBackground()
        }
    }
    
    func didReceive(_ payload: [AnyHashable: Any], in state: AppState) {
        appState = state
        apnsCoordinator.start(payload: APNSPayload(payload), appState: appState, userIsLoggedIn: userIsLoggedIn)
    }
    
    // TODO: - Things to remove
    // Notifications are intended for communications accross Modules/Targets/Projects
    // Using them as a form of delegations breaks MVC, MVVM and other data flow models
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: "PopToLoginView"), object: nil)
    }
    
    @objc private func logout() {
        startLogout()
    }
    
    //
    
    // MARK: - Private functions
    private func setDelegates() {
        apnsCoordinator.delegate = self
        autoLogoutTimer.delegate = self
        loginCoordinator.delegate = self
        preLoginCoordinator.delegate = self
    }
    
    private func presentAutologoutNotification() {
        topViewController?.presentAlert(with: "Logged Out".localized(),
                                        message: "You have been automatically logged out due to inactivity.".localized(),
                                        hideCancelButton: true)
    }
    
    fileprivate func startLogout(isAutologout: Bool = false) {
        
        session.signOut() // Hmm.. this might be more appropriately moved into the DarwinSDK
        
        //Remove all favorites for a user.
        Constant.MyClassConstants.favoritesResortArray.removeAll()
        Constant.MyClassConstants.favoritesResortCodeArray.removeAll()
        //Remove all saved alerts for a user.
        Constant.MyClassConstants.getawayAlertsArray.removeAll()
        Constant.MyClassConstants.searchDateResponse.removeAll()
        Constant.MyClassConstants.isLoginSuccessfull = false
        Constant.MyClassConstants.sideMenuOptionSelected = Constant.MyClassConstants.resortFunctionalityCheck
        
        Constant.MyClassConstants.memberCreditCardList.removeAll()
        Constant.MyClassConstants.upcomingTripsArray.removeAll()
        Constant.MyClassConstants.enableGuestCertificate = false
        
        // TODO: - Need to refactor code/calls above
        
        logoutDidFinish()
        if isAutologout {
            presentAutologoutNotification()
        }
    }
    
    fileprivate func logoutDidFinish() {
        navigationController?.popToRootViewController(animated: true)
        userIsLoggedIn = false
        autoLogoutTimer.stop()
        autoLogoutViewController?.dismiss(animated: false)
        autoLogoutViewController = nil
    }
    
    fileprivate func readEncryptionKey(for contactID: String) -> Promise<Data> {
        
        return Promise { resolve, reject in
            
            let keychain = Keychain()
            guard let data = try? keychain.getItem(for: Persistent.encryption.key, and: contactID, ofType: Data()),
                let key = data else {
                    
                    // If no key previously created for this contactID
                    // Generate a new key, save it, and return it
                    let key = Data.encryptionKey
                    
                    do {
                        try keychain.save(item: key,
                                          for: Persistent.encryption.key,
                                          and: contactID)
                        resolve(key)
                    } catch {
                        reject(UserFacingCommonError.noData)
                    }
                    
                    return
            }
            
            resolve(key)
        }
    }
    
    fileprivate func showDashboard() {
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.dashboardIPhone : Constant.storyboardNames.dashboardIPad
        if let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    fileprivate func presentViewError(viewError: ViewError = UserFacingCommonError.generic) {
        topViewController?.presentErrorAlert(viewError)
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

extension AppCoordinator: APNSCoordinatorDelegate {
    
    private func showRedirectFailureAlert() {
        presentViewError(viewError: UserFacingCommonError.custom(title: "Redirect Error".localized(),
                                                                 body: "We apologize, we could not redirect you to get away alerts at this time".localized()))
        showDashboard()
    }
    
    func redirectUser() {
        
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.getawayAlertsIphone : Constant.storyboardNames.getawayAlertsIpad
        
        guard let clientAccessToken = session.userAccessToken,
            let payload = apnsCoordinator.payload,
            let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() else {
            showRedirectFailureAlert()
            return
        }
        
        // This belongs in a coordinator for the getaway alert...
        ClientAPI.sharedInstance.readRentalAlert(for: clientAccessToken, and: Int64(payload.alertID) ?? -1)
            
            .then { [unowned self] rentalAlert in
                // No way around this until we refactor out the SWReveal Screen, add coordinator, and can inject dependencies...
                Constant.MyClassConstants.redirect = (Int(rentalAlert.alertId ?? -1), rentalAlert)
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            
            .onError { [unowned self] _ in
                self.showRedirectFailureAlert()
            }
            
            .finally { [unowned self] in
                self.apnsCoordinator.reset()
            }
    }
    
    func showRedirectAlert(with title: String, message: String) {
        let callBack: CallBack? = userIsLoggedIn ? redirectUser : nil
        topViewController?.showAPNSPushBanner(for: title, with: message, callBack: callBack)
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
        
        // TODO: - ... These singletons must be removed gradually a.k.a. "Code Choke" them out.
        Constant.MyClassConstants.loginOriginationPoint = Constant.omnitureCommonString.signInPage
        Constant.MyClassConstants.signInRequestedController = topViewController!

        CreateActionSheet().membershipWasSelected(isForSearchVacation: false)
        ///
        
        guard let contactID = session.contact?.contactId else {
            presentViewError()
            return
        }
        
        let createDatabase = { [unowned self] (encryptionKey: Data) in
            self.entityStore.setDatabaseConfigurations(for: String(contactID), with: encryptionKey)
        }
        
        readEncryptionKey(for: String(contactID))
            .then(createDatabase)
            .onViewError(presentViewError)
        
        if apnsCoordinator.shouldRedirectOnlogin && apnsCoordinator.pushViabilityHasNotExpired {
            redirectUser()
        } else {
            showDashboard()
        }
        
        autoLogoutTimer.restart()
    }
    
    func didError(message: String) {
        topViewController?.showBannerNotification(with: "Error".localized(), subtitle: message, for: .error)
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
        startLogout(isAutologout: true)
    }
}
