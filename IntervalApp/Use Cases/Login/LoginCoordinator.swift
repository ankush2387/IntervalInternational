//
//  LoginCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

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
    
    // MARK: - Private properties
    private let configuration: Config
    private let sessionStore: Session
    private let backgroundImages: [UIImage]
    private var messaging: Messaging
    private var viewModel: LoginViewModel?
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
         sessionStore: Session) {
        
        self.messaging = messaging
        self.sessionStore = sessionStore
        self.configuration = configuration
        self.encryptedStore = encryptedStore
        self.decryptedStore = decryptedStore
        self.backgroundImages = backgroundImages
    }

    convenience init() {
        self.init(backgroundImages: [#imageLiteral(resourceName: "BackgroundImgLogin-A"), #imageLiteral(resourceName: "BackgroundImgLogin-B"), #imageLiteral(resourceName: "BackgroundImgLogin-C"), #imageLiteral(resourceName: "BackgroundImgLogin-D"), #imageLiteral(resourceName: "BackgroundImgLogin-E"), #imageLiteral(resourceName: "BackgroundImgLogin-F"), #imageLiteral(resourceName: "BackgroundImgLogin-G")],
                  encryptedStore: Keychain(),
                  decryptedStore: UserDafaultsWrapper(),
                  messaging: Messaging.messaging(),
                  configuration: Config.sharedInstance,
                  sessionStore: Session.sharedSession)
    }

    // MARK: - Public functions
    func loginView() -> UIViewController {
        
        let viewModel = LoginViewModel(backgroundImage: backgroundImages[backgroundImageIndex],
                                       sessionStore: Session.sharedSession,
                                       clientAPIStore: ClientAPI.sharedInstance,
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
                                                          screenColor: UIColor(red: 0.94, green: 0.98, blue: 1.00, alpha: 1.0))
            
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
                                                              screenColor: UIColor(red: 0.94, green: 0.98, blue: 1.00, alpha: 1.0),
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
                                                               screenColor: UIColor(red: 0.94, green: 0.98, blue: 1.00, alpha: 1.0),
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
        return LoginViewController(viewModel: viewModel, simpleOnboardingViewModel: simpleOnboardingViewModel)
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
        
        delegate?.didLogin()
    }
}
