//
//  Validator.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

public protocol TextValidator {
    func isValid(_ text: String) -> Bool
}

open class TextLengthValidator: TextValidator {
    let minimumLength: Int?
    let maximumLength: Int?

    public init(min: Int?, max: Int?) {
        minimumLength = min
        maximumLength = max
    }

    open func isValid(_ text: String) -> Bool {
        if let minimumLength = minimumLength, text.count < minimumLength {
            return false
        }
        if let maximumLength = maximumLength, text.count > maximumLength {
            return false
        }
        return true
    }
}

/// Only for "MM/dd/yyyy"
public class DateValidator: BaseValidator {

    let canBeFuture: Bool
    let dateFormat: String = "MM/dd/yyyy"

    public init(canBeFuture: Bool = false) {
        self.canBeFuture = canBeFuture
    }

    public override func isValid(_ text: String) -> Bool {
        guard !text.isEmpty else {
            return true
        }
        // Use RegEx to verify the structure and size of the entered date before verifying it's an actual valid date
        expression = try? NSRegularExpression(pattern: "^\\d{2}[/]\\d{2}[/]\\d{4}$", options: .caseInsensitive)
        let matches = expression?.numberOfMatches(in: text, options: .reportProgress, range: NSRange(0..<(text.count)))
        if let matches = matches, matches <= 0 {
            return false
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        guard let date = dateFormatter.date(from: text) else {
            return false
        }
        if canBeFuture == false && date.timeIntervalSinceNow > 0 {
            return false
        }
        return true
    }
}

/// Abstract base class for the specialized Validators. Don't instantiate directly.
public class BaseValidator: TextValidator {
    var expression: NSRegularExpression?

    /// Validates the passed in string based on the regex assigned to the expression property. Empty strings always evaluate to true.
    ///
    /// - Parameter text: String to be matched the regex. Empty strings always evaluate to true.
    /// - Returns: Boolean of whether the text matches the expression regex
    public func isValid(_ text: String) -> Bool {
        guard !text.isEmpty else {
            return true
        }
        let matches = expression?.numberOfMatches(in: text, options: .reportProgress, range: NSRange(0..<(text.count)))
        if let matches = matches, matches <= 0 {
            return false
        }
        return true
    }
}

/// Phone number validator for the US specific phone number format: (XXX)XXX-XXXX
public class PhoneNumberFormatValidator: BaseValidator {
    public override init() {
        super.init()
        expression = try? NSRegularExpression(pattern:"^[(](\\d{3})[)](\\d{3})([-])(\\d{4}$)",
                                              options: .caseInsensitive)
    }
}

/// Zipcode validator for the US specific numerical zip code format: XXXXX
public class ZipCodeValidator: BaseValidator {
    public override init() {
        super.init()
        expression = try? NSRegularExpression(pattern: "^\\d{5}$", options: .caseInsensitive)
    }
}

