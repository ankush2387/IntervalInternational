//
//  SimpleActionSheet.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final public class SimpleActionSheet<T: UITableViewCell>: UIAlertController where T: SimpleGenericTableViewCell {
    
    // MARK: - Private properties
    private let viewModel: SimpleActionSheetViewModel<T>
    
    // MARK: - Lifecycle
    public init(viewModel: SimpleActionSheetViewModel<T>) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle(for: SimpleActionSheet.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - Private properties
    private func setUI() {
        addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Action sheet cancel button title"), style: .cancel, handler: dismisView))
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.black]
        let title = NSAttributedString(string: viewModel.title, attributes: attributes)
        setValue(title, forKey: "attributedTitle")
        let tableViewController = SimpleGenericTableViewController(dataSource: viewModel.dataSource)
        setValue(tableViewController, forKey: "contentViewController")
        setConstraints(on: tableViewController)
    }
    
    private func setConstraints(on tableViewController: SimpleGenericTableViewController) {
        let views: [String: Any] = ["tableView": tableViewController.tableView]
        let verticalConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[tableView(\(tableViewController.dataSource.cells.count * Int(tableViewController.dataSource.heightForCells)))]",
            options: [],
            metrics: nil,
            views: views)
        
        NSLayoutConstraint.activate(verticalConstraint)
    }
    
    private func dismisView(_: UIAlertAction) {
        viewModel.cells.first?.reset()
        viewModel.didCancel?()
    }
}
