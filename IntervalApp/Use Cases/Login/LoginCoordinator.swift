//
//  LoginCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
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
        
        guard let index = persistentSettings.backgroundImageIndex else {
            persistentSettings.backgroundImageIndex = 0
            return 0
        }
        
        persistentSettings.backgroundImageIndex = rotate(index, within: 0..<6)
        return persistentSettings.backgroundImageIndex ?? 0
    }
    
    private var persistentSettings: PersistentSettingsStore

    // MARK: - Lifecycle
    init(backgroundImages: [UIImage],
         persistentStorage: PersistentSettingsStore,
         messaging: Messaging,
         configuration: Config,
         sessionStore: Session) {
        
        self.messaging = messaging
        self.sessionStore = sessionStore
        self.configuration = configuration
        self.backgroundImages = backgroundImages
        self.persistentSettings = persistentStorage
    }

    convenience init() {
        self.init(backgroundImages: [#imageLiteral(resourceName: "BackgroundImgLogin-A"), #imageLiteral(resourceName: "BackgroundImgLogin-B"), #imageLiteral(resourceName: "BackgroundImgLogin-C"), #imageLiteral(resourceName: "BackgroundImgLogin-D"), #imageLiteral(resourceName: "BackgroundImgLogin-E"), #imageLiteral(resourceName: "BackgroundImgLogin-F"), #imageLiteral(resourceName: "BackgroundImgLogin-G")],
                  persistentStorage: PersistentSettings(),
                  messaging: Messaging.messaging(),
                  configuration: Config.sharedInstance,
                  sessionStore: Session.sharedSession)
    }

    // MARK: - Public functions
    func loginView() -> UIViewController {
        let viewModel = LoginViewModel(backgroundImage: backgroundImages[backgroundImageIndex],
                                       sessionStore: Session.sharedSession,
                                       clientAPIStore: ClientAPI.sharedInstance,
                                       encryptedStore: LoginData(),
                                       persistentSettingsStore: persistentSettings,
                                       configuration: Config.sharedInstance,
                                       appBundle: AppBundle())

        viewModel.didLogin = didLogin
        self.viewModel = viewModel
        return LoginViewController(viewModel: viewModel)
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

        let newNotificationTopic = "/topics/\(configuration.get(.Environment, defaultValue: "NONE").uppercased())\(contact.contactId)"
        guard let oldNotificationTopic = persistentSettings.notificationTopic else {
            persistentSettings.notificationTopic = newNotificationTopic
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
