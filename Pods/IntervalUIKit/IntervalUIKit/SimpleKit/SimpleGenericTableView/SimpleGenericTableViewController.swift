//
//  SimpleGenericTableViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final class SimpleGenericTableViewController: UITableViewController {
    
    // MARK: - Public properties
    let dataSource: SimpleGenericTableViewDataSource
    
    // MARK: - Lifecycle
    init(dataSource: SimpleGenericTableViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: Bundle(for: SimpleGenericTableViewController.self))
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.cells.forEach {
            if let cell = $0 as? SimpleGenericTableViewCell {
                tableView.register(cell.xib, forCellReuseIdentifier: cell.identifier)
            }
        }
    }
}
