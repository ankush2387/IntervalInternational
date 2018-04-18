//
//  AdditionalInformationViewController.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/19/18.
//

import then
import Bond
import DarwinSDK
import ReactiveKit
import IntervalUIKit
import ActionSheetPicker_3_0

private enum InventoryType { case unitNumber, unitSize }
private var selectedType: InventoryType = .unitNumber

final class AdditionalInformationViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonBackgroundView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    
    // MARK: - Public properties
    var didUpdateFixWeekReservation: CallBack?
    
    // MARK: - Private properties
    fileprivate let viewModel: AdditionalInformationViewModel
    private var previouslySelectedCellModel: SingleSelectionCellModel?
    
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
        viewModel.load()
            .then(reloadData)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }

    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let completionBlock = didUpdateFixWeekReservation else { return }
        showHudAsync()
        viewModel.updateFixWeekReservation()
            .then(completionBlock)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    // MARK: - Private functions
    private func setUI() {
        title = "Additional Information".localized()
        tableView.backgroundColor = .clear
        saveButton.setTitle("Save Float Details".localized(), for: .normal)
        registerSimpleCellViews(withTableView: tableView)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 5
        saveButton.titleLabel?.font = IntervalThemeFactory.deviceTheme.font
        saveButton.backgroundColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
        buttonBackgroundView.backgroundColor = IntervalThemeFactory.deviceTheme.backgroundColorGray
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(processNavigation))
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func createModels(for resort: Resort) -> SingleSelectionCellModel {
        return SingleSelectionCellModel(cellTitle: "\(resort.resortName.unwrappedString) - \(resort.resortCode.unwrappedString)")
    }
    
    private func createModels(for inventoryUnit: InventoryUnit) -> SingleSelectionCellModel {
        let text = selectedType == .unitNumber ? inventoryUnit.unitNumber : inventoryUnit.unitSize
        return SingleSelectionCellModel(cellTitle: text.unwrappedString)
    }

    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }

    fileprivate func showPicker(for viewModel: SimpleFloatingLabelTextFieldCellViewModel) {

        showHudAsync()
        self.viewModel.getResortUnits().then { [weak self] units in
            guard let strongSelf = self else { return }
            selectedType = strongSelf.viewModel.unitNumberVM === viewModel ? .unitNumber : .unitSize

            if !(units.flatMap { $0.unitNumber }).isEmpty {
                let cellModels = units.map(strongSelf.createModels)
                strongSelf.pushPickerViewController(with: cellModels) { selectedIndex in
                    let selectedInventoryUnit = units[selectedIndex]
                    strongSelf.previouslySelectedCellModel = cellModels[selectedIndex]
                    strongSelf.viewModel.unitNumberVM?.textFieldValue.next(selectedInventoryUnit.unitNumber)
                    strongSelf.viewModel.numberOfBedroomsVM?.textFieldValue.next(selectedInventoryUnit.unitSize)
                    strongSelf.tableView.reloadData()
                    strongSelf.navigationController?.popViewController(animated: true)
                }

            } else {
                strongSelf.viewModel.getResortUnitSizes().then { unitSizes in
                    if !(units.flatMap { $0.unitSize }).isEmpty {
                        let cellModels = unitSizes.map(strongSelf.createModels)
                        strongSelf.pushPickerViewController(with: cellModels) { selectedIndex in
                            let selectedInventoryUnit = unitSizes[selectedIndex]
                            strongSelf.previouslySelectedCellModel = cellModels[selectedIndex]
                            strongSelf.viewModel.unitNumberVM?.textFieldValue.next(selectedInventoryUnit.unitNumber)
                            strongSelf.viewModel.numberOfBedroomsVM?.textFieldValue.next(selectedInventoryUnit.unitSize)
                            strongSelf.tableView.reloadData()
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                        
                    } else {
                        // Perform fallback...
                    }

                    }
                    .onViewError(strongSelf.presentErrorAlert)
                    .finally(strongSelf.hideHudAsync)
            }

            }
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    fileprivate func pushResortPickerView() {
        showHudAsync()

        let pushSelectorView = { [weak self] (resorts: [Resort]) in
            guard let strongSelf = self else { return }
            let cellModels = resorts.map(strongSelf.createModels)
            strongSelf.pushPickerViewController(with: cellModels) { selectedIndex in
                strongSelf.previouslySelectedCellModel = cellModels[selectedIndex]
                strongSelf.viewModel.resort.next(resorts[selectedIndex])
                strongSelf.tableView.reloadData()
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }

        viewModel.getResortsForClub()
            .then(pushSelectorView)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    fileprivate func pushPickerViewController(with models: [SingleSelectionCellModel], didSelect: @escaping (Int) -> Void) {
        let selectionViewModel = SingleSelectionViewModel(cellModels: models, currentSelectionCellModel: previouslySelectedCellModel)
        let viewController = SingleSelectionViewController(viewModel: selectionViewModel)
        viewController.didSelectRow = didSelect
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func processNavigation() {
        let message = "Your reservation details will be reset if you leave this screen".localized()
        notifyUserIfDataReset(message: message) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    fileprivate func callResort() {

        guard let resortPhoneNumber = viewModel.resortPhoneNumber else {
            let title = "Alert".localized()
            let message = "Apologies, it appears we do not have a phone number on file for this resort. Please contact Interval International".localized()
            presentAlert(with: title, message: message)
            return
        }

        guard let url = URL(string: "tel://\(resortPhoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
                presentErrorAlert(UserFacingCommonError.noData)
                return
        }

        NetworkHelper.open(url)
    }

    fileprivate func checkIfUserEnteredData() {
        if viewModel.dataHasBeenEntered {
            notifyUserIfDataReset(message: "Your reservation details will be reset if you change your selection".localized(),
                                  handler: pushResortPickerView)
        } else {
            pushResortPickerView()
        }
    }

    fileprivate func notifyUserIfDataReset(message: String,
                                           handler: @escaping AlertActionHandler) {
        if viewModel.dataHasBeenEntered {
            presentAlert(with: "Alert".localized(),
                         message: message,
                         acceptButtonTitle: "Continue".localized(),
                         acceptHandler: handler)
        } else {
            handler()
        }
    }

    fileprivate func pushCalendarView(for viewModel: SimpleFloatingLabelTextFieldCellViewModel) {
        let storyBoardName = Constant.storyboardNames.vacationSearchIphone
        let identifier = "CalendarViewController"
        if let viewController = UIStoryboard(name: storyBoardName,
                                             bundle: nil).instantiateViewController(withIdentifier: identifier) as? CalendarViewController {
            let format = "yyyy/MM/dd"
            var resortCalendars: [ResortCalendar]?
            
            viewController.calendarContext = Constant.CalendarContext.additionalInformationFloatWeek
            viewController.didSelectDate = { [weak self] date in
                guard let strongSelf = self else { return }
                
                var selectedResortCalendar = resortCalendars?.first {
                    let resortDate = $0.checkInDate.unwrappedString.dateFromString(for: format)
                    return resortDate?.intervalShortDate() == date?.intervalShortDate()
                }

                if case .none = selectedResortCalendar {
                    // If server did not send resort calendar, or failed to find match just pass in allowed date
                    let resortCalendar = ResortCalendar()
                    resortCalendar.checkInDate = date?.intervalShortDate()
                    selectedResortCalendar = resortCalendar
                }
                
                strongSelf.viewModel.updateDate(with: selectedResortCalendar)
                let dateFormattedForUI = selectedResortCalendar?.checkInDate?.dateFromString(for: format)
                viewModel.textFieldValue.next(dateFormattedForUI?.shortDateFormat())
            }

            var datesToAllow = self.viewModel.checkInDates()
            
            if datesToAllow.isEmpty {
                showHudAsync()
                // TODO: What happens if the resort calendars come back empty...
                self.viewModel.getResortCalendars()
                    .then { calendars in
                        resortCalendars = calendars
                        datesToAllow = calendars.flatMap { $0.checkInDate.unwrappedString.dateFromString(for: format) }
                        viewController.datesToAllow = datesToAllow
                    }
                    .onViewError(presentErrorAlert)
                    .finally { [unowned self] in
                        self.hideHudAsync()
                        self.navigationController?.pushViewController(viewController, animated: true)
                }
            
            } else {
                viewController.datesToAllow = datesToAllow
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension AdditionalInformationViewController: UITableViewDelegate {
    
}

extension AdditionalInformationViewController: UITableViewDataSource, SimpleViewModelBinder {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeader(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = viewModel.viewForHeader(in: section)
        if let headerView = headerView as? AdditionalInformationHeaderView { headerView.callButtonTapped = callResort }
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

        if let cell = cell as? SimpleDisclosureIndicatorCell {
            cell.cellTapped = checkIfUserEnteredData
        }

        if let cell = cell as? SimpleFloatingLabelTextFieldCell, let viewModel = cellViewModel as? SimpleFloatingLabelTextFieldCellViewModel {
            cell.didSelectTextField = { [unowned self] in
                if viewModel.showArrowIcon.value {
                    // If has disclosure indicator perform picker action
                    self.showPicker(for: viewModel)
                } else {
                    // Perform calendar selection
                    self.pushCalendarView(for: viewModel)
                }
            }
        }
        
        return cell
    }
}
