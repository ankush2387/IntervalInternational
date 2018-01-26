//
//  AdditionalInformationViewController.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/19/18.
//

import Bond
import DarwinSDK
import ReactiveKit
import IntervalUIKit
import ActionSheetPicker_3_0

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
        viewModel.load()
            .then(reloadData)
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
    }

    private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    fileprivate func showPicker(for textField: UITextField, and viewModel: SimpleFloatingLabelTextFieldCellViewModel) {

        showHudAsync()
        self.viewModel.getResortUnits().then { [weak self] units in
            
            guard let strongSelf = self else { return }
            var rows = units.flatMap { $0.unitNumber }
            if rows.isEmpty {
                
                strongSelf.viewModel.getResortUnitSizes().then { unitSizes in
                    rows = unitSizes.flatMap { $0.unitSize }
                    strongSelf.viewModel.unitNumberVM?.isEditing.next(true)
                    strongSelf.viewModel.unitNumberVM?.showArrowIcon.next(false)
                    strongSelf.viewModel.unitNumberVM?.isTappableTextField.next(false)
                    if rows.isEmpty {
                        // Perform fallback...
                    }
                    
                    }
                    .onViewError(strongSelf.presentErrorAlert)
                    .finally(strongSelf.hideHudAsync)
            }
            
            if rows.count > 1 {

                let currentSelection = rows.index(of: textField.text.unwrappedString) ?? 0

                let done = { (_: Any, index: Int, selectedValue: Any) in                    
                    let selectedStringValue = selectedValue as? String
                    let selectedUnit = units.first(where: {
                        $0.unitNumber == selectedStringValue || $0.unitSize == selectedStringValue
                    })
                    
                    strongSelf.viewModel.update(inventoryUnit: selectedUnit)
                    strongSelf.viewModel.unitNumberVM?.textFieldValue.next(selectedUnit?.unitNumber)
                    strongSelf.viewModel.numberOfBedroomsVM?.textFieldValue.next(selectedUnit?.unitSize)
                }

                ActionSheetStringPicker.show(withTitle: "Select Unit".localized(),
                                             rows: rows,
                                             initialSelection: currentSelection,
                                             doneBlock: done,
                                             cancel: nil,
                                             origin: textField)
            } else {
                viewModel.textFieldValue.next(rows.first)
            }
        }
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    fileprivate func pushResortPickerView() {
        showHudAsync()
        let pushSelectorView = { [weak self] (resorts: [Resort]) in
            guard let strongSelf = self else { return }
            let resortNames = resorts.map { $0.resortName }
            let selectionViewModel = SelectionTableViewModel(cellTexts: resortNames)
            let viewController = SelectionTableViewController(viewModel: selectionViewModel)

            viewController.didSelectRow = { index in
                strongSelf.viewModel.resort.next(resorts[index])
                strongSelf.viewModel.resortHasBeenSelected()
                strongSelf.navigationController?.popViewController(animated: true)
            }

            strongSelf.navigationController?.pushViewController(viewController, animated: true)
        }

        viewModel.getResortsForClub()
            .then(pushSelectorView)
            .onViewError(presentErrorAlert)
            .finally(hideHudAsync)
    }

    @objc private func processNavigation() {
        let message = "Your reservation details will be reset if you leave this screen".localized()
        notifyUserIfDataReset(message: message) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
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
            let format = "yyyy-MM-dd"
            var resortCalendars: [ResortCalendar]?
            viewController.didSelectDate = { date in
                
                let selectedResortCalendar = resortCalendars?.first(where: {
                    let resortDate = $0.checkInDate.unwrappedString.dateFromString(for: format)
                    return resortDate?.intervalShortDate() == date?.intervalShortDate()
                })
                
                self.viewModel.update(checkInDate: selectedResortCalendar?.checkInDate, weekNumber: selectedResortCalendar?.weekNumber)
                let dateFormattedForUI = selectedResortCalendar?.checkInDate?.dateFromString(for: format)
                viewModel.textFieldValue.next(dateFormattedForUI?.shortDateFormat())
            }

            var datesToAllow = self.viewModel.checkInDates()
            
            if datesToAllow.isEmpty {
                showHudAsync()
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
        return viewModel.viewForHeader(in: section)
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
            cell.cellTapped = { [unowned self] in
                if self.viewModel.dataHasBeenEntered {
                    self.notifyUserIfDataReset(message: "Your reservation details will be reset if you change your selection".localized(),
                                               handler: self.pushResortPickerView)
                } else {
                    self.pushResortPickerView()
                }
            }
        }

        if let cell = cell as? SimpleFloatingLabelTextFieldCell, let viewModel = cellViewModel as? SimpleFloatingLabelTextFieldCellViewModel {
            cell.didSelectTextField = { [unowned self] in
                if viewModel.showArrowIcon.value {
                    // If has disclosure indicator perform picker action
                    self.showPicker(for: cell.textField, and: viewModel)
                } else {
                    // Perform calendar selection
                    self.pushCalendarView(for: viewModel)
                }
            }
        }
        
        return cell
    }
}
