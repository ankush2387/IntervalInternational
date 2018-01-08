//
//  SimpleSSNMask.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/6/18.
//

import Bond
import Foundation
import ReactiveKit
import UIKit

enum TextFieldNotification: String {
    case textDidChange = "UITextFieldTextDidChangeNotification"
    case didBeginEditing = "UITextFieldTextDidBeginEditingNotification"
    case didEndEditing = "UITextFieldTextDidEndEditingNotification"
}

extension SimpleSSNMask: UITextFieldDelegate { }

public class SimpleSSNMask: NSObject, SimpleMaskProtocol {
    public var mask = "XXX-XX-$1"
    public var replacementChar = "X"
    public var unmaskedText: Observable<String?> = Observable("")
    public var formattingPattern = "XXX-XX-XXXX"
    public var regexPatternFormat = "(?:\\d{3})-(?:\\d{2})-(\\d{4})"

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func registerNotifications(for textField: UITextField) {
        let textFieldDidChangeNotificationName = NSNotification.Name(rawValue: TextFieldNotification.textDidChange.rawValue)
        let textFieldDidBeginNotificationName = NSNotification.Name(rawValue: TextFieldNotification.didBeginEditing.rawValue)
        let textFieldDidEndNotificationName = NSNotification.Name(rawValue: TextFieldNotification.didEndEditing.rawValue)

        let notifications = [textFieldDidChangeNotificationName,
                             textFieldDidBeginNotificationName,
                             textFieldDidEndNotificationName]

        notifications.forEach { notificationName in
            let editingChangedSelector = #selector(SimpleSSNMask.editingDidChange(notification:))

            NotificationCenter.default.addObserver(self, selector: editingChangedSelector,
                                                   name: notificationName,
                                                   object: textField)
        }
    }

    func editingDidChange(notification: NSNotification) {
        guard let textField: UITextField = notification.object as? UITextField else {
            return
        }

        textField.delegate = self
        switch notification.name.rawValue {
        case TextFieldNotification.didBeginEditing.rawValue:
            didBeginEditing(for: textField)
        case TextFieldNotification.didEndEditing.rawValue:
            didEndEditing(for: textField)
        case TextFieldNotification.textDidChange.rawValue:
            textDidChange(for: textField)
        default:
            fatalError("Did not respond to switch case.")
        }
    }

    func didBeginEditing(for textField: UITextField) {
        textField.text = unmaskedText.value
    }

    func didEndEditing(for textField: UITextField) {
        textField.text = maskText(text: textField.text)
    }

    public func textDidChange(for textField: UITextField) {
        let text = textField.text ?? ""

        // Modified Version with credit: http://vojtastavik.com/2015/03/29/real-time-formatting-in-uitextfield-swift-basics/

        if count(string: text) > 0 && count(string: formattingPattern) > 0 {
            let tempString = textWithoutFormatting(string: text)

            var stop = false
            var finalText = ""
            var tempIndex = tempString.startIndex
            var formatterIndex = formattingPattern.startIndex

            while !stop {
                let patternRange = formatterIndex ..< formattingPattern.index(formatterIndex, offsetBy: 1)

                let patternSubString = formattingPattern.substring(with: patternRange)

                if patternSubString != String(replacementChar) {
                    finalText += patternSubString
                } else if count(string: tempString) > 0 {
                    let pureStringRange = tempIndex ..< tempString.index(tempIndex, offsetBy: 1)
                    finalText += tempString.substring(with: pureStringRange)

                    tempIndex = tempString.index(after: tempIndex)
                }

                formatterIndex = formattingPattern.index(after: formatterIndex)

                if formatterIndex >= formattingPattern.endIndex || tempIndex >= tempString.endIndex {
                    stop = true
                }
            }

            unmaskedText.value = finalText
            textField.text = finalText
        } else {
            unmaskedText.value = ""
            textField.text = ""
        }
    }
}

