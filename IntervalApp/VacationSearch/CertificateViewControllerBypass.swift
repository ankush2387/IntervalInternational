//
//  CertificateViewControllerBypass.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 12/28/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class CertificateViewControllerBypass: UIViewController {

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = URL(string: "https://www.intervalworld.com/web/my/home") {
            NetworkHelper.open(url)
        }
    }
}
