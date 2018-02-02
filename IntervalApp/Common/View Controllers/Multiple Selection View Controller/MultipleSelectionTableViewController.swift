//
//  MultipleSelectionTableViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/2/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

final class MultipleSelectionTableViewController<T>: UITableViewController where T: MultipleSelectionElement {

    // MARK: - Public properties
    var didFinish: (([T]) -> Void)?
    
    // MARK: - Private properties
    private let viewModel: MultipleSelectionTableViewModel<T>
    private var selectedElements: [IndexPath: T] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    init(viewModel: MultipleSelectionTableViewModel<T>) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    private func setUI() {
        title = viewModel.viewTitle
        tableView.estimatedRowHeight = 50
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneButtonTapped))
        tableView.register(MultipleSelectionTableViewCell.xib, forCellReuseIdentifier: MultipleSelectionTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    private func dataSetPreviouslySelected(for indexPath: IndexPath) -> Bool {
        let element = viewModel.dataSet[indexPath.row]
        var previouslySelected = false
        viewModel.previouslySelectedDataSet.forEach {
            if element.cellTitle == $0.cellTitle && element.cellSubtitle == $0.cellSubtitle {
                previouslySelected = true
            }
        }
        
        return previouslySelected
    }
    
    @objc private func doneButtonTapped() {
        didFinish?(selectedElements.flatMap { $0.value })
    }
    
    // MARK: - Tableview datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSet.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MultipleSelectionTableViewCell.identifier) as? MultipleSelectionTableViewCell
            else { return UITableViewCell() }

        let previouslySelected = dataSetPreviouslySelected(for: indexPath)
        cell.setCell(element: viewModel.dataSet[indexPath.row], isSelected: previouslySelected)
        
        cell.didSelect = { [weak self] isSelected in
            guard let strongSelf = self else { return }
            if isSelected {
                strongSelf.selectedElements[indexPath] = strongSelf.viewModel.dataSet[indexPath.row]
            } else {
                strongSelf.selectedElements.removeValue(forKey: indexPath)
            }
        }
        
        return cell
    }
}
