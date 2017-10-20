//
//  UIViewController+UIAlertController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension UIViewController {

    typealias AlertActionHandler = () -> Void

    func presentAlert(with title: String,
                      message: String,
                      hideCancelButton: Bool = false,
                      cancelButtonTitle: String = "Cancel".localized(),
                      acceptButtonTitle: String = "OK".localized(),
                      acceptButtonStyle: UIAlertActionStyle = .default,
                      cancelHandler: AlertActionHandler? = nil,
                      acceptHandler: AlertActionHandler? = nil) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { _ in cancelHandler?() })
        let okAction = UIAlertAction(title: acceptButtonTitle, style: acceptButtonStyle, handler: { _ in acceptHandler?() })

        if !hideCancelButton {
            alert.addAction(cancelAction)
        }

        alert.addAction(okAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }

    func presentErrorAlert(_ error: ViewError) {

        let alertViewController = UIAlertController(title: error.description.title,
                                                    message: error.description.body,
                                                    preferredStyle:.alert)

        alertViewController.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))

        DispatchQueue.main.async { [weak self] in
            self?.present(alertViewController, animated: true, completion: nil)
        }
    }
}
