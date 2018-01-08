//
//  SimpleMaskProtocol.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/6/18.
//

import Bond
import Foundation
import UIKit

public protocol SimpleMaskProtocol {

    // MARK: - Properties

    // Template string used when masking
    // This is typically a Reg-ex string.

    var mask: String { get set }

    // Replacement character used
    // as a reference when setting the final text
    // for the UITextField.

    var replacementChar: String { get set }

    // Original textfield text without formatting.

    var unmaskedText: Observable<String?> { get set }

    // The pattern used when formatting the text
    // while the user is editing.

    var formattingPattern: String { get set }

    // Reg-ex pattern used to mask the UITextField
    // text, this is used in conjunction with mask.

    var regexPatternFormat: String { get set }

    // MARK: - Method(s)

    // Called anytime the textField text should be formatted.

    func textDidChange(for textField: UITextField)

    // Convenience methods to register the notification's for
    // UITextField Editing

    func registerNotifications(for textField: UITextField)
}

public extension SimpleMaskProtocol {

    public func count(string: String) -> Int {
        return string.count
    }

    public func textWithoutFormatting(string: String) -> String {
        let decimalCharacterSet = NSCharacterSet.decimalDigits.inverted
        return string.components(separatedBy: decimalCharacterSet).joined(separator: "")
    }

    public func maskText(text: String?) -> String {
        let currentTextFieldText = text ?? ""
        var modifiedString = ""

        if let regex = try? NSRegularExpression(pattern: regexPatternFormat, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: currentTextFieldText.count)
            modifiedString = regex.stringByReplacingMatches(in: currentTextFieldText,
                                                            options: .reportCompletion,
                                                            range: range,
                                                            withTemplate: mask)
        }

        return modifiedString.isEmpty ? currentTextFieldText : modifiedString
    }
}

