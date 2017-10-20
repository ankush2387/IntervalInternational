//
//  AppBundle.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/19/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

struct AppBundle {
    
    // MARK: - Public properties
    let build: String
    let appVersion: String
    let gitCommit: String
}

extension AppBundle {
    
    // Lifecycle: - convenience init
    init() {
        self.init(build: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")  as? String ?? "",
                  appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                  gitCommit: Bundle.main.object(forInfoDictionaryKey: "MMGitRevisionNumber") as? String ?? "")
    }
}
