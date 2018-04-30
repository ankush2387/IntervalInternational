//
//  AdditionalInformationViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/19/18.
//

import then
import Bond
import DarwinSDK
import ReactiveKit
import IntervalUIKit

final class AdditionalInformationViewModel {

    // MARK: - Public properties
    var resort: Observable<Resort?> = Observable(nil)
    var resortUnitDetailsViewModel: SimpleDisclosureIndicatorCellViewModel?
    var reservationNumberVM: SimpleFloatingLabelTextFieldCellViewModel?
    var numberOfBedroomsVM: SimpleFloatingLabelTextFieldCellViewModel?
    var unitNumberVM: SimpleFloatingLabelTextFieldCellViewModel?
    var checkInDateVM: SimpleFloatingLabelTextFieldCellViewModel?
    var dataHasBeenEntered: Bool {
        return reservationNumberVM?.textFieldValue.value.unwrappedString.isEmpty == false ||
        unitNumberVM?.textFieldValue.value.unwrappedString.isEmpty == false ||
        numberOfBedroomsVM?.textFieldValue.value.unwrappedString.isEmpty == false ||
        checkInDateVM?.textFieldValue.value.unwrappedString.isEmpty == false
    }

    var resortPhoneNumber: String? {
        return resort.value?.phone ?? relinquishment.resort?.phone
    }

    // MARK: - Private properties
    private var onlyOneResortInRelinquishment = false
    private let disposeBag = DisposeBag()
    private let sessionStore: SessionStore
    private let relinquishment: Relinquishment
    private let exchangeClientAPIStore: ExchangeClientAPIStore
    private let directoryClientAPIStore: DirectoryClientAPIStore
    private let sectionTitle = [nil, "Resort Unit Details".localized(), "Reservation Details".localized()]
    private enum Section: Int { case resortDetails, unitDetails, reservationDetails }
    private var simpleCellViewModels: [Section: [SimpleCellViewModel?]] = [:]
    private var resortsForClub: [Resort]?

    private var requiresReservationDetailSection: Bool {
        return relinquishment.requireReservationNumber()
            || relinquishment.requireUnitNumberAndUnitSize()
            || relinquishment.requireCheckInDateAndWeekNumber()
    }
    
    // MARK: - Init
    init(relinquishment: Relinquishment,
         sessionStore: SessionStore = Session.sharedSession,
         directoryClientAPIStore: DirectoryClientAPIStore = ClientAPI.sharedInstance,
         exchangeClientAPIStore: ExchangeClientAPIStore = ClientAPI.sharedInstance) {

        self.sessionStore = sessionStore
        self.relinquishment = relinquishment
        self.directoryClientAPIStore = directoryClientAPIStore
        self.exchangeClientAPIStore = exchangeClientAPIStore
    }

    // MARK: - Public functions
    func load() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in

            guard let accessToken = self.sessionStore.userAccessToken else {
                reject(UserFacingCommonError.invalidSession)
                return
            }

            guard let resortCode = self.relinquishment.resort?.resortCode else {
                reject(UserFacingCommonError.generic)
                return
            }
        
            self.resort.observeNext { [unowned self] resort in
                self.relinquishment.fixWeekReservation?.resort = resort
                self.setResortUnitDetailsViewModel().then(self.enableReservationDetailInput)
                }.dispose(in: self.disposeBag)

            self.directoryClientAPIStore.readResort(for: accessToken, and: resortCode)
                .then(self.updateResortInRelinquishment)
                .then(self.setResortDetailViewModel)
                .then(self.setResortUnitDetailsViewModel)
                .then(self.setReservationDetailsViewModel)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.noData) }
        }
    }
    
    func reload() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            guard let resort = self.resort.value else {
                return reject(UserFacingCommonError.noData)
            }

            self.relinquishment.refreshReservationAttributes(reservationAttributes: resort.reservationAttributes)
            self.setResortUnitDetailsViewModel()
                .then(self.setReservationDetailsViewModel)
                .then(self.enableReservationDetailInput)
                .then(resolve)
                .onError(reject)
        }
    }

    func title(for section: Int) -> String? {
        return sectionTitle[section]
    }

    func numberOfSections() -> Int {
        return simpleCellViewModels.count
    }

    func numberOfRows(for section: Int) -> Int {
        guard let sectionIdentifier = Section(rawValue: section) else { return 0 }
        return simpleCellViewModels[sectionIdentifier]?.count ?? 0
    }

    func heightOfCell(for indexPath: IndexPath) -> CGFloat {
        return cellViewModel(for: indexPath).cellHeight.value
    }

    // MARK: - Private functions
    private func enableReservationDetailInput() -> Promise<Void> {
        self.reservationNumberVM?.textFieldValue.next(nil)
        self.reservationNumberVM?.isEditing.next(true)
        self.unitNumberVM?.isTappableTextField.next(true)
        self.unitNumberVM?.textFieldValue.next(nil)
        self.numberOfBedroomsVM?.isTappableTextField.next(true)
        self.numberOfBedroomsVM?.textFieldValue.next(nil)
        self.checkInDateVM?.textFieldValue.next(nil)
        self.numberOfBedroomsVM?.isTappableTextField.next(true)
        self.checkInDateVM?.isTappableTextField.next(true)
        return Promise.resolve()
    }
    
    private func updateResortInRelinquishment(with resort: Resort) -> Promise<Void> {
        self.resort.next(resort)
        return Promise.resolve()
    }

    func cellViewModel(for indexPath: IndexPath) -> SimpleCellViewModel {
        guard let section = Section(rawValue: indexPath.section),
            let cellViewModel = simpleCellViewModels[section]?[indexPath.row] else { return SimpleSeperatorCellViewModel() }
        return cellViewModel
    }

    func hasCellViewModels(for section: Int) -> Bool {
        guard let sectionIdentifier = Section(rawValue: section),
            let count = simpleCellViewModels[sectionIdentifier]?.count else { return false }
        return count > 0
    }
    
    func heightForHeader(in section: Int) -> CGFloat {
        guard let sectionIdentifier = Section(rawValue: section) else { return 0 }
        switch sectionIdentifier {
        case .resortDetails:
            return AdditionalInformationHeaderView.height

        case .unitDetails:
            return relinquishment.requireClubResort() ? SimpleLabelHeaderView.estimatedHeight() : 0

        case .reservationDetails:
            return requiresReservationDetailSection ? SimpleLabelHeaderView.estimatedHeight() : 0
        }
    }
    
    func viewForHeader(in section: Int) -> UIView? {
        guard let sectionIdentifier = Section(rawValue: section) else { return nil }
        switch sectionIdentifier {

        case .resortDetails:
            return AdditionalInformationHeaderView.headerView()

        case .unitDetails:
            guard let headerView = SimpleLabelHeaderView.headerView() as? SimpleLabelHeaderView else { return nil }
            headerView.headerType = .sectionHeaderGray
            headerView.viewModel = SimpleLabelHeaderViewModel(headerTitle: title(for: section))
            return relinquishment.requireClubResort() ? headerView : nil

        case .reservationDetails:
            guard let headerView = SimpleLabelHeaderView.headerView() as? SimpleLabelHeaderView else { return nil }
            headerView.headerType = .sectionHeaderGray
            headerView.viewModel = SimpleLabelHeaderViewModel(headerTitle: title(for: section))
            return requiresReservationDetailSection ? headerView : nil
        }
    }

    func getResortsForClub() -> Promise<[Resort]> {
        return Promise { [unowned self] resolve, reject in
            guard let accessToken = self.sessionStore.userAccessToken,
                let relinquishmentID = self.relinquishment.relinquishmentId,
                let resortCode = self.resort.value?.resortCode else {
                reject(UserFacingCommonError.generic)
                return
            }

            if let resortsForClub = self.resortsForClub {
                resolve(resortsForClub)
            } else {
                self.exchangeClientAPIStore.readResorts(for: accessToken, relinquishmentID: relinquishmentID, and: resortCode)
                    .then(self.storeResortsInViewModel)
                    .then(resolve)
                    .onError { _ in reject(UserFacingCommonError.noData) }
            }
        }
    }

    func getResortUnits() -> Promise<[InventoryUnit]> {
        return Promise { [unowned self] resolve, reject in
            guard let accessToken = self.sessionStore.userAccessToken else {
                reject(UserFacingCommonError.invalidSession)
                return
            }

            self.directoryClientAPIStore.readResortUnits(for: accessToken, and: self.resort.value?.resortCode ?? "")
                .then { [unowned self] units in
                    let filteredUnits = units.filter { !$0.unitSize.unwrappedString.isEmpty && !$0.unitNumber.unwrappedString.isEmpty }
                    self.resort.value?.inventory?.units = filteredUnits
                    resolve(filteredUnits)
                }.onError { _ in reject(UserFacingCommonError.noData) }
        }
    }
    
    func getResortUnitSizes() -> Promise<[InventoryUnit]> {
        return Promise { resolve, reject in
            guard let accessToken = self.sessionStore.userAccessToken else {
                reject(UserFacingCommonError.invalidSession)
                return
            }
            
            self.directoryClientAPIStore.readResortUnitSizes(for: accessToken, and: self.resort.value?.resortCode ?? "")
                .then { [unowned self] units in
                    let filteredUnits = units.filter { !$0.unitSize.unwrappedString.isEmpty }
                    self.resort.value?.inventory?.units = filteredUnits
                    resolve(filteredUnits)
                }.onError { _ in reject(UserFacingCommonError.noData) }
        }
    }
    
    func updateDate(with resortCalendar: ResortCalendar?) {
        relinquishment.fixWeekReservation?.checkInDate = resortCalendar?.checkInDate
        if let weekNumber = resortCalendar?.weekNumber {
            relinquishment.fixWeekReservation?.weekNumber = weekNumber
        } else {
            relinquishment.fixWeekReservation?.weekNumber = relinquishment.weekNumber
        }
    }
    
    func getResortCalendars() -> Promise<[ResortCalendar]> {
        return Promise { [unowned self] resolve, reject in
            guard let accessToken = self.sessionStore.userAccessToken else {
                reject(UserFacingCommonError.invalidSession)
                return
            }
            
            self.directoryClientAPIStore.readResortCalendars(for: accessToken,
                                                             and: self.resort.value?.resortCode ?? "",
                                                             and: self.relinquishment.relinquishmentYear ?? 0)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.noServerResponse) }
        }
    }
    
    func checkInDates() -> [Date] {
        let format = "yyyy-MM-dd"
        return relinquishment.checkInDates.flatMap { $0.dateFromString(for: format) }
    }
    func updateFixWeekReservation() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            guard let accessToken = self.sessionStore.userAccessToken,
                let relinquishmentID = self.relinquishment.relinquishmentId,
                let fixWeekReservation = self.relinquishment.fixWeekReservation else {
                reject(UserFacingCommonError.generic)
                return
            }
            
            if !self.relinquishment.requireUnitNumberAndUnitSize() {
                fixWeekReservation.unit = nil
            } else if fixWeekReservation.unit?.unitNumber?.isEmpty == true || fixWeekReservation.unit?.unitSize?.isEmpty == true {
                reject(UserFacingCommonError.handleError("Please select a unit type.".localized()))
                return
            } else {
                guard let unitSize = fixWeekReservation.unit?.unitSize else { return }
                fixWeekReservation.unit?.unitSize = UnitSize.fromFriendlyName(unitSize)?.rawValue
            }
            
            if !self.relinquishment.requireCheckInDateAndWeekNumber() {
                fixWeekReservation.checkInDate = nil
                fixWeekReservation.weekNumber = nil
            } else if fixWeekReservation.checkInDate?.isEmpty == true || fixWeekReservation.weekNumber?.isEmpty == true {
                reject(UserFacingCommonError.handleError("Please select a check in date.".localized()))
                return
            }
            
            if !self.relinquishment.requireReservationNumber() {
                fixWeekReservation.reservationNumber = nil
            } else if fixWeekReservation.reservationNumber?.isEmpty == true {
                reject(UserFacingCommonError.handleError("Please enter a reservation number.".localized()))
                return
            }
            
            if !self.relinquishment.requireClubResort() {
                fixWeekReservation.resort = nil
            } else if fixWeekReservation.resort?.resortCode?.isEmpty == true {
                reject(UserFacingCommonError.handleError("Please select a resort.".localized()))
                return
            }
            
            self.exchangeClientAPIStore.writeFixWeekReservation(for: accessToken,
                                                                relinquishmentID: relinquishmentID,
                                                                reservation: fixWeekReservation)
                .then(resolve)
                .onError { reject(UserFacingCommonError.handleError($0)) }
        }
    }

    private func storeResortsInViewModel(resorts: [Resort]) -> Promise<[Resort]> {
        resortsForClub = resorts
        return Promise.resolve(resorts)
    }

    private func setResortDetailViewModel() -> Promise<Void> {
        let resort = self.relinquishment.resort
        let defaultResortImage = resort?.getDefaultImage()
        let resortLocationText = [resort?.address?.cityName, resort?.address?.territoryCode].flatMap { $0 }.joined(separator: ", ")

        self.simpleCellViewModels[.resortDetails] = [SimpleSeperatorCellViewModel(),
                                                     SimpleResortDetailViewModel(resortNameLabelText: resort?.resortName,
                                                                                 resortLocationLabelText: resortLocationText,
                                                                                 resortCodeLabelText: resort?.resortCode,
                                                                                 resortImageURL: defaultResortImage?.url,
                                                                                 placeholderImage: #imageLiteral(resourceName: "NoImageIcon"))]
        return Promise.resolve()
    }

    private func setResortUnitDetailsViewModel() -> Promise<Void> {

        if let resortUnitDetailsViewModel = resortUnitDetailsViewModel {
            let resortName = self.resort.value?.resortName ?? ""
            let resortCode = self.resort.value?.resortCode ?? ""
            let newHeaderText = "\(resortName) / \(resortCode)"
            let formattedHeaderText = self.createResortUnitDetailsHeaderText(with: newHeaderText, userSelection: true)
            resortUnitDetailsViewModel.headerLabelText.next(formattedHeaderText)

        } else {
            let headerText = createResortUnitDetailsHeaderText(with: "Select a Club Resort".localized())
            resortUnitDetailsViewModel = SimpleDisclosureIndicatorCellViewModel(headerLabelText: headerText)
            if !relinquishment.requireClubResort() {
                resortUnitDetailsViewModel?.cellHeight.next(0)
                resortUnitDetailsViewModel?.isEditing.next(false)
            }

            simpleCellViewModels[.unitDetails] = [resortUnitDetailsViewModel]
        }

        return Promise.resolve()
    }

    private func createResortUnitDetailsHeaderText(with string: String, userSelection: Bool = false) -> NSAttributedString {
        var attributes: [String: Any] = [:]
        if userSelection {
            attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20),
                          NSForegroundColorAttributeName: IntervalThemeFactory.deviceTheme.textColorBlack]
        } else {
            attributes = [NSForegroundColorAttributeName: IntervalThemeFactory.deviceTheme.textColorGray]
        }
        
        return NSAttributedString(string: string, attributes: attributes)
    }

    private func setReservationDetailsViewModel() -> Promise<Void> {

        reservationNumberVM = SimpleFloatingLabelTextFieldCellViewModel(placeholderText: "Reservation Number".localized())
        reservationNumberVM?.isEditing.next(relinquishment.requireReservationNumber() && !relinquishment.requireClubResort())
        reservationNumberVM?.textFieldValue.observeNext { [unowned self] reservationNumber in
            self.relinquishment.fixWeekReservation?.reservationNumber = reservationNumber
        }.dispose(in: disposeBag)

        if !relinquishment.requireReservationNumber() {
            reservationNumberVM?.cellHeight.next(0)
            reservationNumberVM?.placeholderText.next(nil)
        }

        unitNumberVM = SimpleFloatingLabelTextFieldCellViewModel(placeholderText: "Unit Number".localized())

        unitNumberVM?.isEditing.next(!relinquishment.requireUnitNumberAndUnitSize())
        unitNumberVM?.isTappableTextField.next(relinquishment.requireUnitNumberAndUnitSize() && !relinquishment.requireClubResort())
        unitNumberVM?.showArrowIcon.next(relinquishment.requireUnitNumberAndUnitSize())

        numberOfBedroomsVM = SimpleFloatingLabelTextFieldCellViewModel(placeholderText: "Number of Bedrooms".localized())
        numberOfBedroomsVM?.isEditing.next(!relinquishment.requireUnitNumberAndUnitSize())
        numberOfBedroomsVM?.isTappableTextField.next(relinquishment.requireUnitNumberAndUnitSize() && !relinquishment.requireClubResort())
        numberOfBedroomsVM?.showArrowIcon.next(relinquishment.requireUnitNumberAndUnitSize())

        if !relinquishment.requireUnitNumberAndUnitSize() {
            unitNumberVM?.cellHeight.next(0)
            unitNumberVM?.placeholderText.next(nil)
            unitNumberVM?.showArrowIcon.next(false)
            numberOfBedroomsVM?.cellHeight.next(0)
            numberOfBedroomsVM?.placeholderText.next(nil)
            numberOfBedroomsVM?.showArrowIcon.next(false)
        }

        checkInDateVM = SimpleFloatingLabelTextFieldCellViewModel(placeholderText: "Check-in Date".localized())
        checkInDateVM?.isEditing.next(!relinquishment.requireCheckInDateAndWeekNumber())
        checkInDateVM?.isTappableTextField.next(relinquishment.requireCheckInDateAndWeekNumber() && !relinquishment.requireClubResort())

        if !relinquishment.requireCheckInDateAndWeekNumber() {
            checkInDateVM?.cellHeight.next(0)
            checkInDateVM?.placeholderText.next(nil)
        }
        
        self.unitNumberVM?.textFieldValue.observeNext { [unowned self] unitNumber in
            let unit = InventoryUnit()
            unit.unitNumber = unitNumber
            self.relinquishment.fixWeekReservation?.unit = unit
            }.dispose(in: self.disposeBag)
        
        self.numberOfBedroomsVM?.textFieldValue.observeNext { [unowned self] numberOfBedrooms in
            self.relinquishment.fixWeekReservation?.unit?.unitSize = numberOfBedrooms
            }.dispose(in: self.disposeBag)

        simpleCellViewModels[.reservationDetails] = [reservationNumberVM, unitNumberVM, numberOfBedroomsVM, checkInDateVM]
        return Promise.resolve()
    }
}
