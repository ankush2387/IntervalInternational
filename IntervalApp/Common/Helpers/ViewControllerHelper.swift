//
//  ViewControllerHelper.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol ViewControllerHelper { }

extension ViewControllerHelper {

    var appVersion: String { return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0" }
    
    /// Returns a string with the bundle, build, git, numbers along with the environment designation
    var buildVersion: String {
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")  as? String ?? ""
        let gitCommit = Bundle.main.object(forInfoDictionaryKey: "MMGitRevisionNumber") as? String ?? ""
        let environment = Config.sharedInstance.get(.Environment, defaultValue: "NONE").uppercased()
        return "\("Version: ".localized()) \(appVersion).\(build) \(environment) (\(gitCommit))"
    }
}
