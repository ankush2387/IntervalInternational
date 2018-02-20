//
//  AttributedString+Bold.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/20/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    // No Unit Test needed for this
    // This can be interpreted as UI logic
    // Perhaps a UI Unit Test?
    
    @discardableResult func bold(_ text: String?, size: CGFloat = 20, weight: CGFloat = UIFontWeightMedium) -> NSMutableAttributedString {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: size, weight: weight)]
        let boldString = NSMutableAttributedString(string: "\(text.unwrappedString)", attributes: attributes)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String?) -> NSMutableAttributedString {
        let normal =  NSAttributedString(string: text.unwrappedString)
        self.append(normal)
        return self
    }
}

