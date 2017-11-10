//
//  SettingsViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/7/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import IntervalUIKit

final class SettingsViewModel {
    
    // MARK: - Public properties
    let privacyPolicy: Observable<String>
    let appVersion: Observable<String>
    let cellViewModels: [SimpleCellViewModel]
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    
    init(appBundle: AppBundle, encryptedStore: EncryptedItemDataStore, authentication: BiometricAuthentication) {
        
        appVersion = Observable("App Version: \(appBundle.appVersion)")
        let touchIDEnabled = (try? encryptedStore.getItem(for: Persistent.touchIDEnabled.key, ofType: Bool()) ?? false) ?? false
        
        var viewModels = [SimpleCellViewModel]()
        
        if authentication.canEvaluatePolicy {

            let simpleLabelSwitchCellViewModel = SimpleLabelSwitchCellViewModel(label: "Touch ID".localized(),
                                                                                switchOn: touchIDEnabled)
            
            simpleLabelSwitchCellViewModel.switchOn.observeNext { enabled in
                try? encryptedStore.save(item: enabled, for: Persistent.touchIDEnabled.key)
                }.dispose(in: disposeBag)
            
            viewModels.append(simpleLabelSwitchCellViewModel)
        }

        privacyPolicy = Observable("Privacy Policy".localized())
        viewModels.append(SimpleLabelLabelCellViewModel(label2: privacyPolicy.value))
        cellViewModels = viewModels
    }
}
