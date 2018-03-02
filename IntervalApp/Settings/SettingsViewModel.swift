//
//  SettingsViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/7/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Bond
import Foundation
import ReactiveKit
import IntervalUIKit

final class SettingsViewModel {
    
    // MARK: - Public properties
    let appVersion: Observable<String>
    let privacyPolicy: Observable<String>
    let cellViewModels: [SimpleCellViewModel]
    let simpleLabelSwitchCellViewModel: SimpleLabelSwitchCellViewModel
    var omnitureConfigurationViewModel: SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel?
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let adobeConfigManager: ADBMobileConfigManager

    // MARK: - Lifecycle

    convenience init () {
        self.init(appBundle: AppBundle(),
                  encryptedStore: Keychain(),
                  adobeConfigManager: ADBMobileConfigManager(),
                  authentication: BiometricAuthentication())
    }

    init(appBundle: AppBundle,
         encryptedStore: EncryptedItemDataStore,
         adobeConfigManager: ADBMobileConfigManager,
         authentication: BiometricAuthentication) {
        
        appVersion = Observable("App Version: \(appBundle.appVersion) (\(appBundle.build))")
        let touchIDEnabled = (try? encryptedStore.getItem(for: Persistent.touchIDEnabled.key, ofType: Bool()) ?? false) ?? false
        
        var viewModels = [SimpleCellViewModel]()

        if let biometricType = authentication.biometricType, authentication.canEvaluatePolicy {
            let biometricMessage = biometricType == .faceID ? "Enable face ID".localized() : "Enable Touch ID".localized()
            let simpleLabelSwitchCellViewModel = SimpleLabelSwitchCellViewModel(label: biometricMessage,
                                                                                switchOn: touchIDEnabled)

            simpleLabelSwitchCellViewModel.switchOn.observeNext { enabled in
                try? encryptedStore.save(item: enabled, for: Persistent.touchIDEnabled.key)
                }.dispose(in: disposeBag)

            viewModels.append(simpleLabelSwitchCellViewModel)
        }

        privacyPolicy = Observable("Privacy Policy".localized())
        viewModels.append(SimpleLabelLabelCellViewModel(label2: privacyPolicy.value))

        // Note: Won't go to production, no need to localize
        self.adobeConfigManager = adobeConfigManager
        simpleLabelSwitchCellViewModel = SimpleLabelSwitchCellViewModel(label: "Enable Bloodhound",
                                                                            switchOn: adobeConfigManager.customURLPathBeingUsed)

        viewModels.append(simpleLabelSwitchCellViewModel)
        if adobeConfigManager.isRunningInTestingEnvironment {
            
            let omnitureConfigurationViewModel = SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel(label1: "Server",
                                                                                                             textFieldValue1: adobeConfigManager.base,
                                                                                                             placeholderText1: "172.24.105.156",
                                                                                                             label2: "Port",
                                                                                                             textFieldValue2: adobeConfigManager.port,
                                                                                                             placeholderText2: "50000",
                                                                                                             button1Title: "Reset",
                                                                                                             button2Title: "Save")
            self.omnitureConfigurationViewModel = omnitureConfigurationViewModel
            viewModels.append(omnitureConfigurationViewModel)
        }

        let simpleButtonCellViewModel = SimpleButtonCellViewModel(buttonCellTitle: "Sign Out".localized())
        viewModels.append(simpleButtonCellViewModel)
        cellViewModels = viewModels
    }

    // MARK: - Public functions
    func saveCustomOmnitureURL() -> Promise<Void> {

        // Note: Won't go to production, no need to localize
        return Promise { [unowned self] resolve, reject in
            if let omnitureConfigurationViewModel = self.omnitureConfigurationViewModel {
                guard var url = omnitureConfigurationViewModel.textFieldValue1.value, !url.isEmpty else {
                    reject(UserFacingCommonError.custom(title: "Missing URL", body: "Please fill in to save"))
                    return
                }

                if let port = omnitureConfigurationViewModel.textFieldValue2.value, !port.isEmpty {
                    url += ":" + port
                }

                do {
                    try self.adobeConfigManager.set(serverURL: url)
                    resolve()
                } catch {
                    reject(UserFacingCommonError.generic)
                }
            }
        }
    }

    func resetOmnitureURL() {
        try? self.adobeConfigManager.reset()
    }
}
