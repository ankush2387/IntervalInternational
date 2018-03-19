//
//  ChargeSummaryViewController.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/24/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class ChargeSummaryViewController: UIViewController {

    // MARK: - IBOulets
    @IBOutlet private var tableViewFooter: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var currencyTypeLabel: UILabel!
    @IBOutlet private weak var totalAmountTitleLabel: UILabel!
    @IBOutlet private weak var totalAmountValueLabel: UILabel!
    
    // MARK: - Private properties
    fileprivate let viewModel: ChargeSummaryViewModel

    // MARK: - Public properties
    var doneButtonPressed: CallBack?

     // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.isScrollEnabled = tableView.contentSize.height > view.frame.height
    }

    // MARK: - Lifecycle
    init(viewModel: ChargeSummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private functions
    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneButtonPressed?()
    }

    private func setUI() {
        tableView.tableFooterView = tableViewFooter
        titleLabel.text = viewModel.headerTitle
        currencyTypeLabel.text = viewModel.currencyCode
        descriptionLabel.text = viewModel.descriptionTitle
        totalAmountTitleLabel.text = viewModel.totalTitle
        totalAmountValueLabel.attributedText = viewModel.attributedTotal
        tableView.register(ChargeSummaryTableViewCell.nib, forCellReuseIdentifier: ChargeSummaryTableViewCell.identifier)
    }
}

extension ChargeSummaryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ChargeSummaryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.charge.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChargeSummaryTableViewCell.identifier,
                                                       for: indexPath) as? ChargeSummaryTableViewCell else {
                                                        return UITableViewCell()
        }

        cell.setUI(with: viewModel.charge[indexPath.row].description, and: viewModel.currencyCode, and: viewModel.charge[indexPath.row].amount, and: viewModel.countryCode)
        return cell       
    }
}
