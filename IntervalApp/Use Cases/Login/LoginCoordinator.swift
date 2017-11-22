//
//  LoginCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import DarwinSDK
import Foundation
import IntervalUIKit
import FirebaseMessaging

protocol LoginCoordinatorDelegate: class {
    func didLogin()
    func didError(message: String)
}

final class LoginCoordinator: ComputationHelper {
    
    // MARK: - Public properties
    weak var delegate: LoginCoordinatorDelegate?
    
    // MARK: - Outlet properties (Must exist - Otherwise application should not run)
    // swiftlint:disable implicitly_unwrapped_optional
    private var viewModel: LoginViewModel!
    private var loginViewController: LoginViewController!
    
    // MARK: - Private properties
    private let configuration: Config
    private let sessionStore: Session
    private let backgroundImages: [UIImage]
    private let clientAPIStore: ClientAPIStore
    private var messaging: Messaging
    private var backgroundImageIndex: Int {
        
        guard let index = try? decryptedStore.getItem(for: Persistent.backgroundImageIndex.key, ofType: Int()),
            let imageIndex = index else {
                let startIndex = 0
                try? decryptedStore.save(item: startIndex, for: Persistent.backgroundImageIndex.key)
                return startIndex
        }
        
        let nextIndex = rotate(imageIndex, within: 0..<6)
        try? decryptedStore.save(item: nextIndex, for: Persistent.backgroundImageIndex.key)
        return nextIndex
    }
    
    var newAppInstance: Bool {
        get { return (try? decryptedStore.getItem(for: Persistent.newAppInstance.key, ofType: Bool()) ?? true) ?? true }
        set { try? decryptedStore.save(item: newValue, for: Persistent.newAppInstance.key) }
    }
    
    private var encryptedStore: EncryptedItemDataStore
    private var decryptedStore: DecryptedItemDataStore

    // MARK: - Lifecycle
    init(backgroundImages: [UIImage],
         encryptedStore: EncryptedItemDataStore,
         decryptedStore: DecryptedItemDataStore,
         messaging: Messaging,
         configuration: Config,
         sessionStore: Session,
         clientAPIStore: ClientAPIStore) {
        
        self.messaging = messaging
        self.sessionStore = sessionStore
        self.configuration = configuration
        self.encryptedStore = encryptedStore
        self.decryptedStore = decryptedStore
        self.clientAPIStore = clientAPIStore
        self.backgroundImages = backgroundImages
    }

    convenience init() {
        self.init(backgroundImages: [#imageLiteral(resourceName: "BackgroundImgLogin-A"), #imageLiteral(resourceName: "BackgroundImgLogin-B"), #imageLiteral(resourceName: "BackgroundImgLogin-C"), #imageLiteral(resourceName: "BackgroundImgLogin-D"), #imageLiteral(resourceName: "BackgroundImgLogin-E"), #imageLiteral(resourceName: "BackgroundImgLogin-F"), #imageLiteral(resourceName: "BackgroundImgLogin-G")],
                  encryptedStore: Keychain(),
                  decryptedStore: UserDafaultsWrapper(),
                  messaging: Messaging.messaging(),
                  configuration: Config.sharedInstance,
                  sessionStore: Session.sharedSession,
                  clientAPIStore: ClientAPI.sharedInstance)
    }

    // MARK: - Public functions
    func loginView() -> UIViewController {
        
        let viewModel = LoginViewModel(backgroundImage: backgroundImages[backgroundImageIndex],
                                       sessionStore: Session.sharedSession,
                                       clientAPIStore: clientAPIStore,
                                       encryptedStore: encryptedStore,
                                       decryptedStore: UserDafaultsWrapper(),
                                       configuration: Config.sharedInstance,
                                       appBundle: AppBundle())
        var simpleOnboardingViewModel: SimpleOnboardingViewModel?
        if newAppInstance {
            
            defer { newAppInstance = false } 
            let exchangePage = SimpleOnboardingPageEntity(mainImage: #imageLiteral(resourceName: "Exchange Illustration"),
                                                          title: "Game Changer".localized(),
                                                          titleTextColor: IntervalThemeFactory.deviceTheme.primaryTextColor,
                                                          description: "Exchange like never before! Exclusively on the App, you can now search for an exchange with different ownership interests at the same time.".localized(),
                                                          descriptionTextColor: IntervalThemeFactory.deviceTheme.secondaryTextColor,
                                                          iconNavigator: #imageLiteral(resourceName: "Active Segment"),
                                                          screenColor: #colorLiteral(red: 0.9412514567, green: 0.9814893603, blue: 0.9980912805, alpha: 1))
            
            let exchangeAndGetawayPage = SimpleOnboardingPageEntity(mainImage: #imageLiteral(resourceName: "EX+GA Illustration"),
                                                                    title: "Combined".localized(),
                                                                    titleTextColor: IntervalThemeFactory.deviceTheme.primaryTextColor,
                                                                    description: "We've made it easier to see your vacation options! Search for both exchanges and Getaways together, or search each separately.".localized(),
                                                                    descriptionTextColor: IntervalThemeFactory.deviceTheme.secondaryTextColor,
                                                                    iconNavigator: #imageLiteral(resourceName: "Active Segment"),
                                                                    screenColor: .white)
            
            let chooseAndUsePage = SimpleOnboardingPageEntity(mainImage: #imageLiteral(resourceName: "Usage Illustration"),
                                                              title: "Choose what to use".localized(),
                                                              titleTextColor: IntervalThemeFactory.deviceTheme.primaryTextColor,
                                                              description: "Search first, then decide the best way to book your vacation. Search for an exchange using any or all of your available weeks or points - or book a Getaway. We'll show you options, the rest is up to you.".localized(),
                                                              descriptionTextColor: IntervalThemeFactory.deviceTheme.secondaryTextColor,
                                                              iconNavigator: #imageLiteral(resourceName: "Active Segment"),
                                                              screenColor: #colorLiteral(red: 0.9412514567, green: 0.9814893603, blue: 0.9980912805, alpha: 1),
                                                              titleFont: UIFont.boldSystemFont(ofSize: 30.0))
            
            let multipleDestinationsPage = SimpleOnboardingPageEntity(mainImage: #imageLiteral(resourceName: "Multi-Des Illustration"),
                                                                      title: "Multiple Destinations".localized(),
                                                                      titleTextColor: IntervalThemeFactory.deviceTheme.primaryTextColor,
                                                                      description: "Choose one or more resorts or desinations by name, or select from the map.".localized(),
                                                                      descriptionTextColor: IntervalThemeFactory.deviceTheme.secondaryTextColor,
                                                                      iconNavigator: #imageLiteral(resourceName: "Active Segment"),
                                                                      screenColor: .white,
                                                                      titleFont: UIFont.boldSystemFont(ofSize: 30.0))
            
            let upcomingTripsPage = SimpleOnboardingPageEntity(mainImage: #imageLiteral(resourceName: "Upcoming Trips Illustration"),
                                                               title: "Upcoming Trips".localized(),
                                                               titleTextColor: IntervalThemeFactory.deviceTheme.primaryTextColor,
                                                               description: "View your upcoming vacations all in one place with fast and easy access to your trip confirmation details. Even share your reservation information with friends and family!".localized(),
                                                               descriptionTextColor: IntervalThemeFactory.deviceTheme.secondaryTextColor,
                                                               iconNavigator: #imageLiteral(resourceName: "Active Segment"),
                                                               screenColor: #colorLiteral(red: 0.9412514567, green: 0.9814893603, blue: 0.9980912805, alpha: 1),
                                                               titleFont: UIFont.boldSystemFont(ofSize: 30.0))
            
            let touchIDLoginPage = SimpleOnboardingPageEntity(mainImage: #imageLiteral(resourceName: "TouchID Illustration"),
                                                              title: "Biometric Login".localized(),
                                                              titleTextColor: IntervalThemeFactory.deviceTheme.primaryTextColor,
                                                              description: "A finger or a face is all you need to access your account. Sign in quickly and securely on phones and tablets that support fingerprint or facial recognition.".localized(),
                                                              descriptionTextColor: IntervalThemeFactory.deviceTheme.secondaryTextColor,
                                                              iconNavigator: #imageLiteral(resourceName: "Active Segment"),
                                                              screenColor: .white,
                                                              titleFont: UIFont.boldSystemFont(ofSize: 30.0))
            
            let entities = [exchangePage,
                            exchangeAndGetawayPage,
                            chooseAndUsePage,
                            multipleDestinationsPage,
                            upcomingTripsPage,
                            touchIDLoginPage]
            
            simpleOnboardingViewModel = SimpleOnboardingViewModel(onboardingPageEntities: entities,
                                                      doneButtonTitle: "Done".localized(),
                                                      skipIntroButtonTitle: "Skip Intro".localized())
        }

        viewModel.didLogin = didLogin
        self.viewModel = viewModel
        loginViewController = LoginViewController(viewModel: viewModel, simpleOnboardingViewModel: simpleOnboardingViewModel)
        return loginViewController
    }

    func clientTokenLoaded() {
        viewModel?.clientTokenLoaded.next(true)
    }
    
    // MARK: - Private functions
    private func didLogin() {
        
        guard let contact = sessionStore.contact else {
            delegate?.didError(message: "Could not load contact. Please try logging in again".localized())
            return
        }

        let contactID = String(contact.contactId)
        let newNotificationTopic = "/topics/\(configuration.get(.Environment, defaultValue: "NONE").uppercased())\(contact.contactId)"
        guard let notificationTopic = try? encryptedStore.getItem(for: Persistent.notificationTopic.key, and: contactID, ofType: String()),
        let oldNotificationTopic = notificationTopic else {
            try? encryptedStore.save(item: newNotificationTopic, for: Persistent.notificationTopic.key, and: contactID)
            messaging.subscribe(toTopic: newNotificationTopic)
            return
        }
        
        if oldNotificationTopic != newNotificationTopic {
            messaging.unsubscribe(fromTopic: oldNotificationTopic)
            messaging.subscribe(toTopic: newNotificationTopic)
        }

        guard let memberShips = sessionStore.contact?.memberships else {
            loginViewController.presentErrorAlert(UserFacingCommonError.generic)
            return
        }

        if viewModel.fetchedMoreThanOneMembership {
            loginViewController.hideHudAsync()
            var filteredMemberships: [Membership] = []
            let cells = memberShips
                .map { (membership: $0, product: $0.getProductWithHighestTier()) }
                .flatMap { (membership: Membership, product: Product?) -> MembershipSelectionTableViewCell? in
                    if let productCode = product?.productCode,
                        let productName = product?.productName,
                        let membershipNumber = membership.memberNumber,
                        let image = UIImage(named: productCode) {
                        let cell = MembershipSelectionTableViewCell()
                        cell.setCell(membershipImage: image, membershipName: productName, membershipNumber: membershipNumber)
                        filteredMemberships.append(membership)
                        return cell
                    }
                    
                    return nil
                }
            
            let didCancel: CallBack = { [unowned self] in
                self.sessionStore.signOut()
            }
            
            let didSelect = { [unowned self] (index: Int) in
                self.loginViewController.showHudAsync()
                self.sessionStore.selectedMembership = filteredMemberships[index]
                guard let membership = self.sessionStore.selectedMembership,
                    let accessToken = self.sessionStore.userAccessToken,
                    let delegate = self.delegate else {
                    self.loginViewController.presentErrorAlert(UserFacingCommonError.generic)
                    return
                }
                
                self.clientAPIStore.writeSelected(membership: membership, for: accessToken)
                    .then(delegate.didLogin)
                    .onError { [unowned self] error in
                        self.loginViewController.presentErrorAlert(UserFacingCommonError.custom(title: "Error".localized(),
                                                                                                body: error.localizedDescription)) }
            }
            
            let viewModel = SimpleActionSheetViewModel<MembershipSelectionTableViewCell>(cells: cells,
                                                                                         heightForCells: 60,
                                                                                         title: "Choose Membership".localized(),
                                                                                         didCancel: didCancel,
                                                                                         didSelectRow: didSelect)
            
            loginViewController.presentSimpleActionSheetPicker(viewModel: viewModel)
            return
        }

        delegate?.didLogin()
    }
}
