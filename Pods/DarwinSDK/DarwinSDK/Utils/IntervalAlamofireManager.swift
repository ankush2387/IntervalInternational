//
//  IntervalAlamofireManager.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 12/8/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import Alamofire


class IntervalAlamofireManager
{
    static let sharedInstance = IntervalAlamofireManager()
	
	let defaultManager: Alamofire.SessionManager = {
        
        // Exclude Internal Interval domains from the normal SSL Certificate Chain
        // check.  See the #Security section in Alamofire docs for more information.
        let serverTrustPolicies : [String : ServerTrustPolicy] = [
            "dev-mag.ii-apps.com"       : .disableEvaluation,
            "dev2-mag.ii-apps.com"      : .disableEvaluation,
            "qa-mag.ii-apps.com"        : .disableEvaluation,
            "qa2-mag.ii-apps.com"       : .disableEvaluation,
            "staging-mag.ii-apps.com"   : .disableEvaluation,
            "mag.ii-apps.com"           : .disableEvaluation
        ]
		
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30 * 1000 // seconds
        
        DarwinSDK.logger.debug("Excluding serverTrustPolicies \(serverTrustPolicies)")
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
}
