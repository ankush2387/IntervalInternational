//
//  LoginCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol LoginCoordinatorDelegate: class {
    func didLogin()
}

final class LoginCoordinator: ComputationHelper {
    
    // MARK: - Public properties
    weak var delegate: LoginCoordinatorDelegate?
    
    // MARK: - Private properties
    private var persistentSettings: PersistentSettingsStore
    private let backgroundImages: [UIImage]
    private var viewModel: LoginViewModel?
    private var backgroundImageIndex: Int {
        
        guard let index = persistentSettings.backgroundImageIndex else {
            persistentSettings.backgroundImageIndex = 0
            return 0
        }
        
        persistentSettings.backgroundImageIndex = rotate(index, within: 0..<6)
        return persistentSettings.backgroundImageIndex ?? 0
    }

    // MARK: - Lifecycle
    init(backgroundImages: [UIImage], persistentStorage: PersistentSettingsStore) {
        self.backgroundImages = backgroundImages
        self.persistentSettings = persistentStorage
    }

    convenience init() {
        self.init(backgroundImages: [#imageLiteral(resourceName: "BackgroundImgLogin-A"), #imageLiteral(resourceName: "BackgroundImgLogin-B"), #imageLiteral(resourceName: "BackgroundImgLogin-C"), #imageLiteral(resourceName: "BackgroundImgLogin-D"), #imageLiteral(resourceName: "BackgroundImgLogin-E"), #imageLiteral(resourceName: "BackgroundImgLogin-F"), #imageLiteral(resourceName: "BackgroundImgLogin-G")], persistentStorage: PersistentSettings())
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

        viewModel.didLogin = { [unowned self] in self.delegate?.didLogin() }
        self.viewModel = viewModel
        return LoginViewController(viewModel: viewModel)
    }

    func clientTokenLoaded() {
        viewModel?.clientTokenLoaded.next(true)
    }
}
