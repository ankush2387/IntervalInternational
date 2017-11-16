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
        present(actionSheet, animated: true, completion: nil)
    }
}
