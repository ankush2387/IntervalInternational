//
//  RelinquishmentViewController.swift
//  IntervalApp
//
//  Filled in requirement Gaps, and refactored by Aylwing Olivas on 1/11/18.
//  Copyright © 2017 Interval International. All rights reserved.
//

import DarwinSDK
import IntervalUIKit

final class RelinquishmentViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties
    fileprivate let viewModel = RelinquishmentViewModel()
    private let adobeAnalyticsManager = ADBAnalyticsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        showHudAsync()
        setUI()
        
        viewModel.load()
            .then(reloadData)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
        
        sendAnalytics()
    }
    
    // MARK: - Private functions
    private func setUI() {
        title = "Relinquishment Selection".localized()
        registerSimpleCellViews(withTableView: tableView)
    }
    
    private func reloadData() {
        tableView.reloadData()
    }
    
    private func sendAnalytics() {
        
        adobeAnalyticsManager.sendAnalyticEvent(withIdentifier: .event40,
                                                data: [OmnitureEvar.eVar44.value: OmnitureIdentifier.vacationSearchRelinquishmentSelect.value])

        adobeAnalyticsManager.sendAnalyticEvent(withIdentifier: .event61,
                                                data: [OmnitureEvar.eVar41.value: OmnitureIdentifier.vacationSearch.value])
    }
    
    fileprivate func seperatorSection() -> UIView {
        let view = UIView()
        view.backgroundColor = IntervalThemeFactory.deviceTheme.backgroundColorGray
        return view
    }
    
    fileprivate func pushAvailablePointToolViewController() {
        
        // Ugh... Why was this not made into a Xib?
        if let viewController = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
            .instantiateViewController(withIdentifier: Constant.storyboardControllerID.availablePointToolViewController)
            as? AvailablePointToolViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    fileprivate func relinquishAvailablePoints() {
        
        let relinquishmentID = Constant.MyClassConstants.relinquishmentProgram.relinquishmentId
        let availablePoints = Constant.MyClassConstants.relinquishmentProgram.availablePoints
        let code = Constant.MyClassConstants.relinquishmentProgram.code
        let popViewController = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        
        Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentProgram)
        Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentID.unwrappedString)
        
        viewModel.relinquish(availablePoints, for: code, and: relinquishmentID)
            .then(popViewController)
            .onViewError(presentErrorAlert)
    }
    
    fileprivate func processNavigationAction(for relinquishment: Relinquishment) {
        
        if relinquishment.requireAdditionalInfo() {
            // This viewController must delegate back when the relinquishment has been saved
            // Must find out how this data must be stored... to make changes in viewModel
            let viewModel = AdditionalInformationViewModel(relinquishment: relinquishment)
            let additionalInformationViewController = AdditionalInformationViewController(viewModel: viewModel)
            navigationController?.pushViewController(additionalInformationViewController, animated: true)
        }
    }
}

extension RelinquishmentViewController: UITableViewDelegate {

}

extension RelinquishmentViewController: UITableViewDataSource, SimpleViewModelBinder {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard viewModel.hasCellViewModels(for: section) else { return 0 }
        guard viewModel.title(for: section) != nil else { return 4 }
        return SimpleLabelHeaderView.estimatedHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = SimpleLabelHeaderView.headerView() as? SimpleLabelHeaderView else { return nil }
        guard let headerTitle = viewModel.title(for: section) else { return seperatorSection() }
        headerView.headerType = .sectionHeaderGray
        headerView.viewModel = SimpleLabelHeaderViewModel(headerTitle: headerTitle)
        return headerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
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
        
        if let cell = cell as? SimpleAvailableRelinquishmentPointsCell {
            cell.availablePointsToolButtonTapped = pushAvailablePointToolViewController
            cell.actionButtonTapped = relinquishAvailablePoints
        }
        
        if let cell = cell as? SimpleOwnershipCell {
            cell.actionButtonTapped = { [unowned self] in
                self.viewModel.relinquishment(for: indexPath)
                    .then(self.processNavigationAction)
                    .onViewError(self.presentErrorAlert)
            }
        }
        
        return cell
    }
}
