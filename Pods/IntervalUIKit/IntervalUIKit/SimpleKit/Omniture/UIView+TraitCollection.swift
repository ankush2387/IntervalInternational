//
//  UIView+TraitCollection.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

import Foundation

public extension UIView {

    public func isIPadTraitCollection() -> Bool {
        return traitCollection.horizontalSizeClass == .regular &&
            traitCollection.verticalSizeClass == .regular
    }
}
