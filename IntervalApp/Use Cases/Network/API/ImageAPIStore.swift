//
//  ImageAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import UIKit

protocol ImageAPIStore {
    func readImage(for url: URL) -> Promise<UIImage>
}
