//
//  SimpleMaskedTextField.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

import Bond
import ReactiveKit
import UIKit

public class SimpleMaskedTextField: SimpleValidatedTextField {

    var textFieldMask: SimpleMaskProtocol? {
        didSet {
            if let textFieldMask = textFieldMask {
                textFieldMask.registerNotifications(for: self)
            }
        }
    }

    // This method is used to initially set the text for the
    // field and have it formatted using the mask.

    public func maskText(_ text: String) {
        self.text = text

        // There is probably a better way to do this...

        // we need to invoke this to keep track of the
        // unformatted text.

        textFieldMask?.textDidChange(for: self)

        let notificationName = Notification.Name(rawValue: TextFieldNotification.didEndEditing.rawValue)
        NotificationCenter.default.post(name: notificationName, object: self)
    }

    // Forcing the caret to always be at the end of the UITextfield
    // document. This is to remedy the user from modifying the text
    // Keeping track of changes, also forces us to keep track of the
    // unformatted text, which can be difficult.

    override public func caretRect(for position: UITextPosition) -> CGRect {
        return super.caretRect(for: endOfDocument)
    }

    // This is necessary to prevent pasting.

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:)) ? false : super.canPerformAction(action, withSender: sender)
    }
}
