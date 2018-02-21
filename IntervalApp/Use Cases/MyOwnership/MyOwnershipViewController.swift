//
//  MyOwnershipViewController.swift
//  IntervalApp
//
//  Filled in requirement Gaps, and refactored by Aylwing Olivas on 1/11/18.
//  Copyright © 2016 Interval International. All rights reserved.
//

import then
import DarwinSDK
import IntervalUIKit

final class MyOwnershipViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Private properties
    fileprivate let viewModel = MyOwnershipViewModel()
    private let adobeAnalyticsManager = ADBAnalyticsManager()
    
    // MARK: - Lifecycle
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "My Ownerships / Units".localized()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
    
    // MARK: - Private functions
    private func setUI() {
        setMenuButton()
        registerSimpleCellViews(withTableView: tableView)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    private func setMenuButton() {
        if let revealView = revealViewController() {
            revealView.delegate = self

            let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_menu"),
                                             style: .plain,
                                             target: revealView,
                                             action: #selector(SWRevealViewController.revealToggle(_:)))

            menuButton.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = menuButton
            view.addGestureRecognizer(revealView.panGestureRecognizer())
        }
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
    
    private func createCellModel(for inventoryUnit: InventoryUnit) -> SingleSelectionCellModel {
        return SingleSelectionCellModel(cellTitle: inventoryUnit.unitDetailsUIFormatted,
                                        cellSubtitle: inventoryUnit.unitCapacityUIFormatted)
    }
    
    private func createCellModel(for inventoryUnit: InventoryUnit) -> MultipleSelectionCellModel {
        return MultipleSelectionCellModel(cellTitle: inventoryUnit.unitDetailsUIFormatted,
                                          cellSubtitle: inventoryUnit.unitCapacityUIFormatted)
    }
    
    private func createCellModel(for resortUnitDetails: ResortUnitDetails) -> MultipleSelectionCellModel {
        return MultipleSelectionCellModel(cellTitle: resortUnitDetails.kitchenType,
                                          cellSubtitle: resortUnitDetails.unitSize)
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
    
    fileprivate func relinquishAvailablePoints(_: Any, _: Any) {
        
        let relinquishmentID = Constant.MyClassConstants.relinquishmentProgram.relinquishmentId
        let availablePoints = Constant.MyClassConstants.relinquishmentProgram.availablePoints
        let code = Constant.MyClassConstants.relinquishmentProgram.code
        
        Constant.MyClassConstants.whatToTradeArray.add(Constant.MyClassConstants.relinquishmentProgram)
        Constant.MyClassConstants.relinquishmentIdArray.append(relinquishmentID.unwrappedString)

        viewModel.resetDatabase()
            .then(viewModel.relinquish(availablePoints, for: code, and: relinquishmentID))
            .then(popFromRelinquishmentViewController)
            .onViewError(presentErrorAlert)
    }
    
    fileprivate func processNavigationAction(for relinquishment: Relinquishment) {

        showHudAsync()
        if (relinquishment.memberUnitLocked || relinquishment.bulkAssignment)
            && !relinquishment.hasActions() && relinquishment.hasResortPhoneNumber() {
            // Does not have actions
            // User can only call resort
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
            
        } else if relinquishment.hasLockOffUnits && relinquishment.requireAdditionalInfo() {
            
            viewModel.readPreviouslySelectedLockOffUnits(for: relinquishment).then { [weak self] lockedOffUnits in
                guard let strongSelf = self, let units = strongSelf.viewModel.processLockOffUnits(for: relinquishment) else {
                    self?.presentErrorAlert(UserFacingCommonError.generic)
                    return
                }
                
                strongSelf.pushSingleSelectionView(title: "Select lock-off portion".localized(),
                                                   with: units.map(strongSelf.createCellModel)) { selectedIndex in
                                                    
                                                    let selectedUnit = units[selectedIndex]
                                                    relinquishment.relinquishmentId = selectedUnit.relinquishmentId
                                                    relinquishment.fixWeekReservation?.unit = selectedUnit
                                                    strongSelf.pushAdditionalInformationView(for: relinquishment,
                                                                                             didUpdateFixWeekReservation: {
                                                                                                strongSelf.navigationController?.popToViewController(strongSelf, animated: false)
                                                                                                strongSelf.save(relinquishment)
                                                    })
                }
                }
                
                .onViewError(presentErrorAlert)
                .finally(hideHudAsync)
            
        } else if relinquishment.requireAdditionalInfo() {
            defer { hideHudAsync() }
            pushAdditionalInformationView(for: relinquishment) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.navigationController?.popViewController(animated: false)
                strongSelf.save(relinquishment)
            }
            
        } else if relinquishment.hasLockOffUnits {
            
            viewModel.readPreviouslySelectedLockOffUnits(for: relinquishment).then { [weak self] lockedOffUnits in
                guard let strongSelf = self, let units = strongSelf.viewModel.processLockOffUnits(for: relinquishment) else {
                    self?.presentErrorAlert(UserFacingCommonError.generic)
                    return
                }
                let previousSelectionDataSet = lockedOffUnits.flatMap { $0.unitDetails }.map { strongSelf.createCellModel(for: $0) }
                strongSelf.pushMultipleSelectionView(title: "Select lock-off portion".localized(),
                                                     with: units.map(strongSelf.createCellModel),
                                                     previousSelectionDataSet: previousSelectionDataSet) { [weak self] selectedLockedOffUnits in
                                                        guard let strongSelf = self else { return }
                                                        strongSelf.showHudAsync()
                                                        let inventoryUnitsToRelinquish = units.filter {
                                                            return selectedLockedOffUnits.map { $0.cellTitle }.contains($0.unitDetailsUIFormatted)
                                                        }
                                                        strongSelf.viewModel.relinquish(relinquishment, with: inventoryUnitsToRelinquish)
                                                            .then(strongSelf.popToMyOwnershipViewController)
                                                            .then(strongSelf.popFromRelinquishmentViewController)
                                                            .onViewError(strongSelf.presentErrorAlert)
                                                            .finally(strongSelf.hideHudAsync)
                }
                }
                
                .onViewError(presentErrorAlert)
                .finally(hideHudAsync)
            
        } else {
            save(relinquishment)
            hideHudAsync()
        }
    }
    
    private func pushSingleSelectionView(title: String? = nil,
                                         with dataSet: [SingleSelectionCellModel],
                                         didSelect: @escaping (Int) -> Void) {
        
        let singleSelectionViewModel = SingleSelectionViewModel(title: title,
                                                                cellModels: dataSet,
                                                                cellUIType: .disclosure)
        
        let singleSelectionViewController = SingleSelectionViewController(viewModel: singleSelectionViewModel)
        singleSelectionViewController.didSelectRow = didSelect
        navigationController?.pushViewController(singleSelectionViewController, animated: true)
    }
    
    private func pushMultipleSelectionView(title: String? = nil,
                                           with dataSet: [MultipleSelectionCellModel],
                                           previousSelectionDataSet: [MultipleSelectionCellModel] = [],
                                           didSelect: @escaping ([MultipleSelectionCellModel]) -> Void) {
        
        let multipleSelectionViewModel = MultipleSelectionTableViewModel(viewTitle: title,
                                                                         dataSet: dataSet,
                                                                         previouslySelectedDataSet: previousSelectionDataSet)
        
        let multipleSelectionViewController = MultipleSelectionTableViewController(viewModel: multipleSelectionViewModel)
        multipleSelectionViewController.didFinish = didSelect
        navigationController?.pushViewController(multipleSelectionViewController, animated: true)
    }
    
    private func pushAdditionalInformationView(for relinquishment: Relinquishment, didUpdateFixWeekReservation: @escaping CallBack) {
        let viewModel = AdditionalInformationViewModel(relinquishment: relinquishment)
        let additionalInformationViewController = AdditionalInformationViewController(viewModel: viewModel)
        additionalInformationViewController.didUpdateFixWeekReservation = didUpdateFixWeekReservation
        navigationController?.pushViewController(additionalInformationViewController, animated: true)
    }
    
    private func popToMyOwnershipViewController() {
        navigationController?.popToViewController(self, animated: false)
    }
    
    private func popFromRelinquishmentViewController() {
        pushVacationSearchView()
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
                    .then(strongSelf.popToMyOwnershipViewController)
                    .then(strongSelf.popFromRelinquishmentViewController)
                    .onViewError(strongSelf.presentErrorAlert)
            }
            
            strongSelf.navigationController?.pushViewController(viewController, animated: true)
            resolve()
        }
    }

    private func pushVacationSearchView() {
        guard let vacationSearchViewController = UIStoryboard(name: "VacationSearchIphone",
                                                              bundle: nil).instantiateInitialViewController() else {
                                                                presentErrorAlert(UserFacingCommonError.generic)
                                                                return
        }

        Constant.MyClassConstants.whatToTradeArray.removeAllObjects()
        let navController = UINavigationController(rootViewController: vacationSearchViewController)
        navController.isNavigationBarHidden = true
        navController.setViewControllers([vacationSearchViewController], animated: false)
        revealViewController().setFront(navController, animated: true)
    }

    private func save(_ relinquishment: Relinquishment) {
        viewModel.resetDatabase()
            .then(viewModel.relinquish(relinquishment))
            .then(pushVacationSearchView)
            .onViewError(presentErrorAlert)
    }
}

extension MyOwnershipViewController: UITableViewDelegate {
    
}

extension MyOwnershipViewController: UITableViewDataSource, SimpleViewModelBinder {
    
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.processActionButton(for: indexPath) != nil
            || viewModel.cellViewModel(for: indexPath) is SimpleAvailableRelinquishmentPointsCellViewModel
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if viewModel.cellViewModel(for: indexPath) is SimpleAvailableRelinquishmentPointsCellViewModel {
            let relinquishPointsAction = UITableViewRowAction(style: .normal,
                                                              title: "Search for a Vacation".localized(),
                                                              handler: relinquishAvailablePoints)

            relinquishPointsAction.backgroundColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
            return [relinquishPointsAction]
        }

        guard let action = viewModel.processActionButton(for: indexPath) else { return nil }
        let callAction = UITableViewRowAction(style: .normal,
                                              title: "Call your Resort".localized()) { [weak self] _ in
                                                guard let strongSelf = self else { return }
                                                strongSelf.viewModel.relinquishment(for: indexPath)
                                                    .then(strongSelf.processNavigationAction)
                                                    .onViewError(strongSelf.presentErrorAlert)
        }

        let searchAction = UITableViewRowAction(style: .normal,
                                                title: "Search for a Vacation".localized()) { [weak self] _ in
                                                    guard let strongSelf = self else { return }
                                                    strongSelf.viewModel.relinquishment(for: indexPath)
                                                        .then(strongSelf.processNavigationAction)
                                                        .onViewError(strongSelf.presentErrorAlert)
        }

        [callAction, searchAction].forEach { $0.backgroundColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange }

        switch action {

        case .call:
            return [callAction]

        case .search:
            return [searchAction]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = cellView(tableView, forIndexPath: indexPath, forViewModelType: cellViewModel.modelType())
        bindSimpleCellView(cell, withSimpleViewModel: cellViewModel)
        
        if let cell = cell as? SimpleAvailableRelinquishmentPointsCell {
            cell.availablePointsToolButtonTapped = pushAvailablePointToolViewController
        }

        return cell
    }
}
