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
        
        Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentProgram)
        Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentID.unwrappedString)
        
        viewModel.relinquish(availablePoints, for: code, and: relinquishmentID)
            .then(popViewController)
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

//            showHudAsync()
//            viewModel.readResortClubPointChart(for: relinquishment)
//                .then(performHorribleSingletonCode)
//                .then(pushClubPointSelectionView)
//                .onViewError(presentErrorAlert)
//                .finally(hideHudAsync)

        } else if relinquishment.requireAdditionalInfo() {
            defer { hideHudAsync() }
            // This viewController must delegate back when the relinquishment has been saved
            // Must find out how this data must be stored... to make changes in viewModel
            let viewModel = AdditionalInformationViewModel(relinquishment: relinquishment)
            let additionalInformationViewController = AdditionalInformationViewController(viewModel: viewModel)
            navigationController?.pushViewController(additionalInformationViewController, animated: true)
        } else if relinquishment.lockOff {
            // Do nothing...
        } else {
            
            viewModel.relinquish(relinquishment)
                .then(popViewController)
                .onViewError(presentErrorAlert)
                .finally(hideHudAsync)
        }
    }
    
    private func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    private func performHorribleSingletonCode(for clubPointsChart: ClubPointsChart) -> Promise<Void> {
        return Promise { resolve, reject in

            // Not my code...
            // Old code to keep existing behavior...
            // Code not currently working...

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

    private func pushClubPointSelectionView() -> Promise<Void> {
        return Promise { [weak self] resolve, reject in
            guard let viewController = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
                .instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointSelectionViewController)
                as? ClubPointSelectionViewController else {
                    reject(UserFacingCommonError.generic)
                    return
            }

            self?.navigationController?.pushViewController(viewController, animated: true)
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

// Temporary code, to not change model across application

extension OpenWeek {
    public convenience init(relinquishment: Relinquishment) {
        self.init()
        relinquishmentId = relinquishment.relinquishmentId
        actions = relinquishment.actions
        relinquishmentYear = relinquishment.relinquishmentYear
        exchangeStatus = relinquishment.exchangeStatus
        weekNumber = relinquishment.exchangeStatus
        masterUnitNumber = relinquishment.masterUnitNumber
        checkInDates = relinquishment.checkInDates
        checkInDate = relinquishment.checkInDate
        checkOutDate = relinquishment.checkOutDate
        pointsProgramCode = relinquishment.pointsProgramCode
        resort = relinquishment.resort
        unit = relinquishment.unit
        pointsMatrix = relinquishment.pointsMatrix
        blackedOut = relinquishment.blackedOut
        bulkAssignment = relinquishment.bulkAssignment
        memberUnitLocked = relinquishment.memberUnitLocked
        payback = relinquishment.payback
        reservationAttributes = relinquishment.reservationAttributes
        virtualWeekActions = relinquishment.virtualWeekActions
        promotion = relinquishment.promotion
    }
}
