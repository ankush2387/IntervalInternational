//
//  RelinquishmentViewController.swift
//  IntervalApp
//
//  Filled in requirement Gaps, and refactored by Aylwing Olivas on 1/11/18.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
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
        title = "Select Relinquishment".localized()
        registerSimpleCellViews(withTableView: tableView)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
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
        
        Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentProgram)
        Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentID.unwrappedString)
        
        viewModel.relinquish(availablePoints, for: code, and: relinquishmentID)
            .then(popViewControllerAnimated)
            .onViewError(presentErrorAlert)
    }
    
    fileprivate func processNavigationAction(for relinquishment: Relinquishment) {

        showHudAsync()
        
        if (relinquishment.memberUnitLocked || relinquishment.bulkAssignment)
            && !relinquishment.hasActions() && relinquishment.hasResortPhoneNumber() {
            defer { hideHudAsync() }
            guard let resortPhoneNumber = relinquishment.resort?.phone,
                let url = URL(string: "tel://\(resortPhoneNumber)"),
                UIApplication.shared.canOpenURL(url) else {
                presentErrorAlert(UserFacingCommonError.noData)
                return
            }
            
            NetworkHelper.open(url)
        } else if relinquishment.pointsMatrix {

            Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId = relinquishment.relinquishmentId
            viewModel.readResortClubPointChart(for: relinquishment)
                .then(performHorribleSingletonCode)
                .then(pushClubPointSelectionView(for: relinquishment))
                .onViewError(presentErrorAlert)
                .finally(hideHudAsync)

        } else if relinquishment.requireAdditionalInfo() {
            defer { hideHudAsync() }
            // This viewController must delegate back when the relinquishment has been saved
            // Must find out how this data must be stored... to make changes in viewModel
            let viewModel = AdditionalInformationViewModel(relinquishment: relinquishment)
            let additionalInformationViewController = AdditionalInformationViewController(viewModel: viewModel)
            additionalInformationViewController.didUpdateFixWeekReservation = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.navigationController?.popViewController(animated: false)
                strongSelf.relinquish(relinquishment)
            }
            navigationController?.pushViewController(additionalInformationViewController, animated: true)
        } else if relinquishment.hasLockOffUnits {

            viewModel.fetchSelectedLockOffUnits(for: relinquishment).then { [weak self] lockedOffUnits in
                guard let strongSelf = self, let units = strongSelf.viewModel.processLockOffUnits(for: relinquishment) else {
                    self?.presentErrorAlert(UserFacingCommonError.generic)
                    return
                }
                
                let multipleSelectionViewModel = MultipleSelectionTableViewModel<InventoryUnit>(viewTitle: "Select lock-off portion".localized(),
                                                                                                dataSet: units,
                                                                                                previouslySelectedDataSet: lockedOffUnits)

                let multipleSelectionViewController = MultipleSelectionTableViewController(viewModel: multipleSelectionViewModel)
                multipleSelectionViewController.didFinish = { [weak self] lockedOffUnits in
                    guard let strongSelf = self else { return }
                    strongSelf.showHudAsync()
                    strongSelf.viewModel.relinquish(relinquishment, with: lockedOffUnits)
                        .then(strongSelf.popViewControllerNonAnimated)
                        .then(strongSelf.popViewControllerAnimated)
                        .onViewError(strongSelf.presentErrorAlert)
                        .finally(strongSelf.hideHudAsync)
                }

                strongSelf.navigationController?.pushViewController(multipleSelectionViewController, animated: true)
            }
                .onViewError(presentErrorAlert)
                .finally(hideHudAsync)

        } else {
            relinquish(relinquishment)
        }
    }
    
    private func relinquish(_ relinquishment: Relinquishment) {
        viewModel.relinquish(relinquishment)
            .then(popViewControllerAnimated)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    private func popViewControllerNonAnimated() {
        navigationController?.popViewController(animated: false)
    }

    private func popViewControllerAnimated() {
        navigationController?.popViewController(animated: true)
    }
    
    private func performHorribleSingletonCode(for clubPointsChart: ClubPointsChart) -> Promise<Void> {
        return Promise { resolve, _ in

            // Not my code...
            // Old code to keep existing behavior...

            Constant.MyClassConstants.matrixDataArray.removeAllObjects()
            Constant.MyClassConstants.selectionType = 1
            Constant.MyClassConstants.matrixType = clubPointsChart.type.unwrappedString
            Constant.MyClassConstants.matrixDescription = clubPointsChart.matrices[0].description.unwrappedString
            let showSegment = Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeSingle
                || Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeColor
            Constant.MyClassConstants.showSegment = !showSegment

            clubPointsChart.matrices.forEach {
                let pointsDictionary = NSMutableDictionary()
                $0.grids.forEach { grid in
                    guard let gridFromDate = grid.fromDate else { return }
                    Constant.MyClassConstants.fromdatearray.add(gridFromDate)
                    guard let gridToDate = grid.toDate else { return }
                    Constant.MyClassConstants.todatearray.add(gridToDate)
                    grid.rows.forEach { row in
                        if let rowLabel = row.label {
                            Constant.MyClassConstants.labelarray.add(rowLabel)
                        }
                    }

                    let dictKey = "\(String(describing: gridFromDate)) - \(String(describing: gridToDate))"
                    pointsDictionary.setObject(grid.rows, forKey: String(describing: dictKey) as NSCopying)
                }

                Constant.MyClassConstants.matrixDataArray.add(pointsDictionary)
            }

            resolve()
        }
    }

    private func pushClubPointSelectionView(for relinquishment: Relinquishment) -> Promise<Void> {
        return Promise { [weak self] resolve, reject in
            guard let strongSelf = self else { return }
            guard let viewController = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                .instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController)
                as? ClubPointSelectionViewController else {
                    reject(UserFacingCommonError.generic)
                    return
            }

            viewController.didSave = { clubPoints in
                clubPoints.relinquishmentId = relinquishment.relinquishmentId.unwrappedString
                clubPoints.relinquishmentYear = relinquishment.relinquishmentYear ?? 0
                
                strongSelf.viewModel.relinquish(clubPoints)
                    .then(strongSelf.popViewControllerNonAnimated)
                    .then(strongSelf.popViewControllerAnimated)
                    .onViewError(strongSelf.presentErrorAlert)
            }

            strongSelf.navigationController?.pushViewController(viewController, animated: true)
            resolve()
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
