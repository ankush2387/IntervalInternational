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
                  encryptedStore: KeychainWrapper(),
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
