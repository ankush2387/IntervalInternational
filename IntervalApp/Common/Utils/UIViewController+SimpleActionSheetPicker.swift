//
//  UIViewController+SimpleActionSheetPicker.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import IntervalUIKit

extension UIViewController {
    func presentSimpleActionSheetPicker<T>(viewModel: SimpleActionSheetViewModel<T>) {
        let actionSheet = SimpleActionSheet<T>(viewModel: viewModel)
        actionSheet.popoverPresentationController?.sourceView = self.view
        let isRunningOnIpad = UIDevice.current.userInterfaceIdiom == .pad
        if isRunningOnIpad {
            actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        present(actionSheet, animated: true, completion: nil)
    }
}
