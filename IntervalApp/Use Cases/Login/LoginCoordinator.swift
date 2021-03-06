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
    fileprivate let session = Session.sharedSession
    private let darwinSDK: DarwinSDK
    private let sessionStore: Session
    private let backgroundImages: [UIImage]
    private let userClientAPIStore: UserClientAPIStore
    private let entityDataStore: EntityDataStore
    private var messaging: Messaging
    private var backgroundImageIndex: Int {
        
        guard let index = try? decryptedStore.getItem(for: Persistent.backgroundImageIndex.key, ofType: Int()),
            let imageIndex = index else {
                let startIndex = 0
                try? decryptedStore.save(item: startIndex, for: Persistent.backgroundImageIndex.key)
                return startIndex
        }
        
        let nextIndex = rotate(imageIndex, within: 0..<8)
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
         darwinSDK: DarwinSDK,
         sessionStore: Session,
         userClientAPIStore: UserClientAPIStore,
         entityDataStore: EntityDataStore) {
        
        self.messaging = messaging
        self.sessionStore = sessionStore
        self.darwinSDK = darwinSDK
        self.encryptedStore = encryptedStore
        self.decryptedStore = decryptedStore
        self.entityDataStore = entityDataStore
        self.userClientAPIStore = userClientAPIStore
        self.backgroundImages = backgroundImages
    }

    convenience init() {
        self.init(backgroundImages: [#imageLiteral(resourceName: "BackgroundImgLogin-A"), #imageLiteral(resourceName: "BackgroundImgLogin-B"), #imageLiteral(resourceName: "BackgroundImgLogin-C"), #imageLiteral(resourceName: "BackgroundImgLogin-D"), #imageLiteral(resourceName: "BackgroundImgLogin-E"), #imageLiteral(resourceName: "BackgroundImgLogin-F"), #imageLiteral(resourceName: "BackgroundImgLogin-G"), #imageLiteral(resourceName:"BackgroundImgLogin-H"), #imageLiteral(resourceName: "BackgroundImgLogin-I")],
                  encryptedStore: Keychain(),
                  decryptedStore: UserDafaultsWrapper(),
                  messaging: Messaging.messaging(),
                  darwinSDK: DarwinSDK.sharedInstance,
                  sessionStore: Session.sharedSession,
                  userClientAPIStore: ClientAPI.sharedInstance,
                  entityDataStore: EntityDataSource.sharedInstance)
    }

    // MARK: - Public functions
    func loginView() -> UIViewController {
        
        defer { newAppInstance = false }
        let viewModel = LoginViewModel(backgroundImage: backgroundImages[backgroundImageIndex],
                                       sessionStore: Session.sharedSession,
                                       userClientAPIStore: userClientAPIStore,
                                       authProviderClientAPIStore: ClientAPI.sharedInstance,
                                       encryptedStore: encryptedStore,
                                       decryptedStore: UserDafaultsWrapper(),
                                       darwinSDK: DarwinSDK.sharedInstance,
                                       appBundle: AppBundle())
        
        viewModel.didLogin = didLogin
        self.viewModel = viewModel
        loginViewController = LoginViewController(viewModel: viewModel, newAppInstance: newAppInstance)
        
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
        if session.contact?.memberships?.count == 1 {
            Session.sharedSession.selectedMembership = session.contact?.memberships?[0]
        }

        let contactID = String(contact.contactId)
        let newNotificationTopic = "/topics/\(darwinSDK.getPushNotificationsEnv().uppercased())\(contact.contactId)"
        
        if let notificationTopic = try? encryptedStore.getItem(for: Persistent.notificationTopic.key, and: contactID, ofType: String()),
            let oldNotificationTopic = notificationTopic, oldNotificationTopic != newNotificationTopic {
            messaging.unsubscribe(fromTopic: oldNotificationTopic)
            messaging.subscribe(toTopic: newNotificationTopic)
        } else {
            messaging.subscribe(toTopic: newNotificationTopic)
            try? encryptedStore.save(item: newNotificationTopic, for: Persistent.notificationTopic.key, and: contactID)
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
                        let productName = Helper.getDisplayNameFor(membership: membership, product: product),
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
                
                self.userClientAPIStore.readMembership(for: accessToken, and: membership.memberNumber ?? "")
                    
                    .then { newMembership in
                        self.sessionStore.selectedMembership = newMembership
                        delegate.didLogin()
                    }
                    
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

        entityDataStore.delete(type: OpenWeeksStorage.self, for: .decrypted)
            .then { [weak self] in self?.delegate?.didLogin() }
            .onError { [weak self] _ in self?.delegate?.didError(message: UserFacingCommonError.generic.description.body) }
    }
}
