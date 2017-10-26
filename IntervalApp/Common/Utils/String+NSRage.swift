//
//  String+NSRage.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension String {
    
    enum RangeSpecifier { case before, after }
    
    /// Find the range for the specified delimiter (before or after) passed in character
    func NSRangeFor(_ rangeSpecifier: RangeSpecifier, character: Character) -> NSRange? {
        guard let indexOfFirstOccurance = self.index(of: character) else { return nil }
        let firstSequence = rangeSpecifier == .before ? self[...indexOfFirstOccurance] : self[indexOfFirstOccurance...]
        guard let range: Range<Index> = self.range(of: firstSequence) else { return nil }
        return NSRange(range, in: self)
    }
}
