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
    
    // MARK: - Lifecycle
    init(build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")  as? String ?? "",
         appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
         gitCommit: String = Bundle.main.object(forInfoDictionaryKey: "MMGitRevisionNumber") as? String ?? "") {
        self.build = build
        self.appVersion = appVersion
        self.gitCommit = gitCommit
    }
}
