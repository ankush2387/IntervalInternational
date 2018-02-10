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
                                      preferredStyle: .actionSheet)

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
    
    //upcoming trips
    func presentAlertInUpcomingTripDetails(with title: String,
                      message: String,
                      hideCancelButton: Bool = false,
                      cancelButtonTitle: String = "Call".localized(),
                      acceptButtonTitle: String = "Close".localized(),
                      acceptButtonStyle: UIAlertActionStyle = .default,
                      cancelHandler: AlertActionHandler? = nil,
                      acceptHandler: AlertActionHandler? = nil) {
        
        let actionSheet = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        actionSheet.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 250
        )
        let height: NSLayoutConstraint = NSLayoutConstraint(item: actionSheet.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 280)
        
        actionSheet.view.addConstraint(height)
        //set label title
        let lblTitle = UILabel(frame: CGRect(x: 10, y: 5, width: actionSheet.view.bounds.size.width - 20, height: 25))
        lblTitle.font = UIFont(name: Constant.fontName.helveticaNeue, size: 18.0)
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.text = "Purchase Trip Protection"
        lblTitle.textAlignment = .center
        
        let lblMessage = UILabel(frame: CGRect(x: 10, y: 35, width: actionSheet.view.bounds.size.width - 20, height: 100))
        
        let alertMessage = "In order to purchase Trip Protection you\nmay contact us we will gladly help\nyou add trip protection to your vacation.\nPlease reference\nconfirmation number:5264856"
        
        let longestWord = "Please reference\nconfirmation number"
        
        let longestWordRange = (alertMessage as NSString).range(of: longestWord)
        
        let attributedString1 = NSMutableAttributedString(string: alertMessage, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
        
        attributedString1.setAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)], range: longestWordRange)

        lblMessage.numberOfLines = 0
        lblMessage.textAlignment = .center
        lblMessage.attributedText = attributedString1
        actionSheet.view.addSubview(lblTitle)
        actionSheet.view.addSubview(lblMessage)
        
        // add separator
        let viewSeparator = UIView(frame: CGRect(x: 0, y: 160, width: actionSheet.view.bounds.size.width, height: 1.0))
        viewSeparator.backgroundColor = UIColor.lightGray
        actionSheet.view.addSubview(viewSeparator)
        
        let buttonCall = UIButton(frame: CGRect(x: 0, y: 163, width: actionSheet.view.bounds.size.width, height: 40.0))
        
        buttonCall.setTitle("Call".localized(), for: .normal)
        buttonCall.setTitleColor(UIColor.green, for: .normal)
        buttonCall.titleLabel?.font = UIFont(name: Constant.fontName.helveticaNeueBold, size: 20.0)!
        buttonCall.addTarget(self, action: #selector(tapCallButton), for: .touchUpInside)
        actionSheet.view.addSubview(buttonCall)
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { _ in cancelHandler?()
        })
        
        actionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(actionSheet, animated: true, completion: nil)
        }
    }

    func tapCallButton(button: UIButton) {
        NSLog("tapCallButton!")
    }

    func presentErrorAlert(_ error: ViewError) {

        let alertViewController = UIAlertController(title: error.description.title,
                                                    message: error.description.body,
                                                    preferredStyle: .alert)

        alertViewController.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))

        DispatchQueue.main.async { [weak self] in
            self?.present(alertViewController, animated: true, completion: nil)
        }
    }
}
