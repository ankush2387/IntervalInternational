//
//  SingleSelectionViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

final class SingleSelectionViewController: UITableViewController {

    // MARK: - Public properties
    var didSelectRow: ((Int) -> Void)?

    // MARK: - Private properties
    private let viewModel: SingleSelectionViewModel

    // MARK: - Lifecycle
    init(viewModel: SingleSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SingleSelectionTableViewCell.identifier) as? SingleSelectionTableViewCell else { return UITableViewCell() }
        let currentCellModel = viewModel.cellModels[indexPath.row]
        let isSelected = currentCellModel.cellTitle == viewModel.currentSelectionCellModel?.cellTitle
        cell.setCell(cellTitle: currentCellModel.cellTitle,
                     cellSubtitle: currentCellModel.cellSubtitle,
                     isSelected: isSelected,
                     cellType: viewModel.cellUIType)

        cell.tapped = { [weak self] in
            self?.didSelectRow?(indexPath.row)
        }

        return cell
    }
    
    // MARK: - Private properties
    private func setUI() {
        title = viewModel.title
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(SingleSelectionTableViewCell.xib,
                           forCellReuseIdentifier: SingleSelectionTableViewCell.identifier)

        if case .disclosure = viewModel.cellUIType {
            tableView.separatorStyle = .none
        }
    }
}
