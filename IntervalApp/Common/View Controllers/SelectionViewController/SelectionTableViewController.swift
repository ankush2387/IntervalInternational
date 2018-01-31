//
//  SelectionTableViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

protocol SelectionCell {
    var labelText: String? { get }
}

final class SelectionTableViewController: UITableViewController {

    // MARK: - Public properties
    var didSelectRow: ((Int) -> Void)?

    // MARK: - Private properties
    private let viewModel: SelectionTableViewModel

    // MARK: - Lifecycle
    init(viewModel: SelectionTableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectionTableViewCell.xib,
                           forCellReuseIdentifier: SelectionTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellTexts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SelectionTableViewCell.cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectionTableViewCell.identifier) as? SelectionTableViewCell else { return UITableViewCell() }
        let currentSelectionCell = viewModel.cellTexts[indexPath.row]
        let isSelected = currentSelectionCell.labelText == viewModel.currentSelection?.labelText
        cell.setCell(labelText: currentSelectionCell.labelText, isSelected: isSelected)

        cell.tapped = { [weak self] in
            self?.didSelectRow?(indexPath.row)
        }

        return cell
    }
}
