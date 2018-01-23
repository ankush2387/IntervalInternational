//
//  AdditionalInformationViewController.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/19/18.
//

import Bond
import ReactiveKit
import IntervalUIKit

final class AdditionalInformationViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonBackgroundView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    
    // MARK: - Private properties
    fileprivate let viewModel: AdditionalInformationViewModel
    
    // MARK: - Lifecycle
    init(viewModel: AdditionalInformationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: AdditionalInformationViewController.self),
                   bundle: Bundle(for: AdditionalInformationViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHudAsync()
        setUI()
        bindUI()
        viewModel.load()
            .then(reloadData)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }
    
    // MARK: - Private functions
    private func setUI() {
        title = "Additional Information".localized()
        saveButton.setTitle("Save Float Details".localized(), for: .normal)
        registerSimpleCellViews(withTableView: tableView)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 5
        saveButton.titleLabel?.font = IntervalThemeFactory.deviceTheme.font
        saveButton.backgroundColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
        buttonBackgroundView.backgroundColor = IntervalThemeFactory.deviceTheme.backgroundColorGray
    }

    private func bindUI() {

    }

    private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension AdditionalInformationViewController: UITableViewDelegate {
    
}

extension AdditionalInformationViewController: UITableViewDataSource, SimpleViewModelBinder {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard viewModel.title(for: section) != nil else { return 0 }
        return SimpleLabelHeaderView.estimatedHeight()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = SimpleLabelHeaderView.headerView() as? SimpleLabelHeaderView else { return nil }
        headerView.headerType = .sectionHeaderGray
        headerView.viewModel = SimpleLabelHeaderViewModel(headerTitle: viewModel.title(for: section))
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightOfCell(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = cellView(tableView, forIndexPath: indexPath, forViewModelType: cellViewModel.modelType())
        bindSimpleCellView(cell, withSimpleViewModel: cellViewModel)
        return cell
    }
}
