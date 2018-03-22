//
//  MyOwnershipViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import RealmSwift
import IntervalUIKit

import then
import DarwinSDK
import RealmSwift
import IntervalUIKit

final class MyOwnershipViewModel {

    // MARK: - Public properties
    enum ActionType { case call, search }

    // MARK: - Private properties
    private let clientAPI: ExchangeClientAPIStore
    private let directoryClientAPIStore: DirectoryClientAPIStore
    private let sessionStore: SessionStore
    private let entityDataStore: EntityDataStore
    private let relinquishmentManager: RelinquishmentManager
    private let sectionTitle = ["Club Interval Gold Weeks".localized(), nil, "Points".localized(), "Interval Weeks".localized()]

    private enum Section: Int { case cigProgram, cigWeeks, points, intervalWeeks }
    private var relinquishments: [Section: [Relinquishment?]] = [:]
    private var simpleCellViewModels: [Section: [SimpleCellViewModel]] = [:]

    // MARK: - Lifecycle
    init(clientAPI: ExchangeClientAPIStore,
         directoryClientAPIStore: DirectoryClientAPIStore,
         sessionStore: SessionStore,
         entityDataStore: EntityDataStore,
         relinquishmentManager: RelinquishmentManager) {

        self.clientAPI = clientAPI
        self.sessionStore = sessionStore
        self.entityDataStore = entityDataStore
        self.relinquishmentManager = relinquishmentManager
        self.directoryClientAPIStore = directoryClientAPIStore
    }

    convenience init() {
        self.init(clientAPI: ClientAPI.sharedInstance,
                  directoryClientAPIStore: ClientAPI.sharedInstance,
                  sessionStore: Session.sharedSession,
                  entityDataStore: EntityDataSource.sharedInstance,
                  relinquishmentManager: RelinquishmentManager())
    }

    // MARK: - Public functions
    func load() -> Promise<Void> {
        guard let accessToken = sessionStore.userAccessToken else { return Promise.reject(UserFacingCommonError.generic) }
        return Promise { [unowned self] resolve, reject in
            self.clientAPI.readMyUnits(for: accessToken)
                .then(self.processRelinquishmentGroups)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
        }
    }

    func title(for section: Int) -> String? {
        guard let sectionIdentifier = Section(rawValue: section) else { return nil }
        if let cigProgramCount = simpleCellViewModels[.cigProgram]?.count, cigProgramCount < 1, sectionIdentifier == .cigWeeks {
            return sectionTitle.first as? String
        }

        return sectionTitle[section]
    }

    func numberOfSections() -> Int {
        return simpleCellViewModels.count
    }

    func hasCellViewModels(for section: Int) -> Bool {
        guard let sectionIdentifier = Section(rawValue: section),
            let count = simpleCellViewModels[sectionIdentifier]?.count else { return false }
        return count > 0
    }

    func numberOfRows(for section: Int) -> Int {
        guard let sectionIdentifier = Section(rawValue: section) else { return 0 }
        return simpleCellViewModels[sectionIdentifier]?.count ?? 0
    }

    func heightOfCell(for indexPath: IndexPath) -> CGFloat {
        return simpleCellViewModel(for: indexPath).cellHeight.value
    }

    func cellViewModel(for indexPath: IndexPath) -> SimpleCellViewModel {
        return simpleCellViewModel(for: indexPath)
    }

    func relinquishment(for indexPath: IndexPath) -> Promise<Relinquishment> {
        return Promise { [unowned self] resolve, reject in

            guard let relinquishment = self.fetchRelinquishment(for: indexPath) else {
                reject(UserFacingCommonError.generic)
                return
            }

            resolve(relinquishment)
        }
    }

    func relinquish(_ relinquishment: Relinquishment) -> Promise<Void> {
        // Currently only handling two states, `deposited`, and `open week`
        // Will later handle `pending`
        return relinquishment.isDeposit() ? depositDepositedWeek(for: relinquishment) : depositOpenWeek(for: relinquishment)
    }

    func readPreviouslySelectedLockOffUnits(for relinquishment: Relinquishment) -> Promise<[OpenWeeks]> {
        return Promise { resolve, reject in
            self.entityDataStore.readObjectsFromDisk(type: OpenWeeksStorage.self, predicate: nil, encoding: .decrypted)
                .then { openWeeksStorage in
                    let lockedOffUnits: [OpenWeeks] = openWeeksStorage
                        .flatMap { $0.openWeeks }
                        .flatMap { $0.openWeeks }
                        .filter { $0.relinquishmentID == relinquishment.relinquishmentId.unwrappedString }

                    resolve(lockedOffUnits)
                }
                .onError(reject)
        }
    }

    func relinquish(_ relinquishment: Relinquishment, with lockOffUnits: [InventoryUnit]) -> Promise<Void> {

        return Promise { [unowned self] resolve, reject in
            self.resetLockOffUnitsInDisk(for: relinquishment).then {
                lockOffUnits.forEach {
                    let resort = ResortList()
                    let storedata = OpenWeeksStorage()
                    let selectedOpenWeek = OpenWeeks()
                    let relinquishmentList = TradeLocalData()
                    selectedOpenWeek.isLockOff = true
                    selectedOpenWeek.weekNumber = relinquishment.weekNumber.unwrappedString
                    selectedOpenWeek.relinquishmentID = relinquishment.relinquishmentId.unwrappedString
                    selectedOpenWeek.relinquishmentYear = relinquishment.relinquishmentYear ?? 0
                    let unitDetails = ResortUnitDetails()
                    unitDetails.kitchenType = $0.unitDetailsUIFormatted
                    unitDetails.unitSize = $0.unitCapacityUIFormatted
                    selectedOpenWeek.unitDetails.append(unitDetails)
                    resort.resortName = relinquishment.resort?.resortName ?? ""
                    resort.resortCode = relinquishment.resort?.resortCode ?? ""
                    selectedOpenWeek.resort.append(resort)
                    relinquishmentList.openWeeks.append(selectedOpenWeek)
                    storedata.openWeeks.append(relinquishmentList)
                    storedata.contactID = self.sessionStore.contactID
                    self.entityDataStore.writeToDisk(storedata, encoding: .decrypted).onError(reject)
                }

                }.onError(reject)

            resolve()
        }
    }

    func relinquish(_ clubPoints: ClubPointsEntity) -> Promise<Void> {
        return Promise { resolve, reject in

            guard let membershipNumber = self.sessionStore.selectedMembership?.memberNumber else {
                reject(UserFacingCommonError.invalidSession)
                return
            }

            let openWeeksEntity = OpenWeeksStorage()
            let tradeLocalDataEntity = TradeLocalData()
            let pointsEntity = rlmPointsProgram()

            pointsEntity.relinquishmentId = clubPoints.relinquishmentId
            tradeLocalDataEntity.clubPoints.append(clubPoints)

            openWeeksEntity.openWeeks.append(tradeLocalDataEntity)
            openWeeksEntity.contactID = self.sessionStore.contactID

            self.entityDataStore.writeToDisk(openWeeksEntity, encoding: .decrypted)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
        }
    }

    func relinquish(_ availablePoints: Int?, for code: String?, and relinquishmentID: String?) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in

            guard let relinquishmentID = relinquishmentID,
                let availablePoints = availablePoints,
                let code = code,
                let memberNumber = self.sessionStore.selectedMembership?.memberNumber else {
                    reject(UserFacingCommonError.generic)
                    return
            }

            let openWeeksEntity = OpenWeeksStorage()
            let tradeLocalDataEntity = TradeLocalData()
            let pointsEntity = rlmPointsProgram()

            pointsEntity.relinquishmentId = relinquishmentID
            pointsEntity.availablePoints = availablePoints
            pointsEntity.code = code

            tradeLocalDataEntity.pProgram.append(pointsEntity)
            openWeeksEntity.openWeeks.append(tradeLocalDataEntity)
            openWeeksEntity.contactID = self.sessionStore.contactID

            self.entityDataStore.writeToDisk(openWeeksEntity, encoding: .decrypted)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
        }
    }

    func readResortClubPointChart(for relinquishment: Relinquishment) -> Promise<ClubPointsChart> {
        return Promise { [unowned self] resolve, reject in
            guard let accessToken = self.sessionStore.userAccessToken, let resortCode = relinquishment.resort?.resortCode else {
                reject(UserFacingCommonError.invalidSession)
                return
            }

            self.directoryClientAPIStore.readResortClubPointChart(for: accessToken, and: resortCode)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.noData) }
        }
    }

    func processLockOffUnits(for relinquishment: Relinquishment) -> [InventoryUnit]? {
        guard relinquishment.hasLockOffUnits else { return nil }
        var units: [InventoryUnit] = []
        if let masterUnit = relinquishment.unit {
            units.append(masterUnit)
        }

        if let lockedOffUnits = relinquishment.unit?.lockOffUnits {
            units += lockedOffUnits
        }

        return units
    }

    func processActionButton(for indexPath: IndexPath) -> ActionType? {
        guard let relinquishment = fetchRelinquishment(for: indexPath) else { return nil }
        if relinquishment.hasActions() && (relinquishment.actions.map { $0.uppercased() }.contains("SHOP")) {
            return .search
        }

        if (relinquishment.memberUnitLocked || relinquishment.bulkAssignment)
            && !relinquishment.hasActions() && relinquishment.hasResortPhoneNumber() {
            return .call
        }

        return nil
    }

    func resetDatabase() -> Promise<Void> {
        return self.entityDataStore.delete(type: OpenWeeksStorage.self, for: .decrypted)
    }

    // MARK: - Private functions
    private func processRelinquishmentGroups(myUnits: MyUnits) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in

            Helper.storeInConstants(myUnits: myUnits)
            let relinquishmentGroups = self.relinquishmentManager.getRelinquishmentSections(myUnits: myUnits)

            self.processCIGProgram(for: relinquishmentGroups).then {
                self.simpleCellViewModels[.cigProgram] = $0
                }.onError(reject)

            self.filterStored(relinquishmentGroups.cigPointsWeeks).then { relinquishments in
                self.processResortGrouping(for: relinquishments, in: .cigWeeks)
                }.onError(reject)

            self.filterStored(relinquishmentGroups.pointsWeeks).then { relinquishments in
                self.processResortGrouping(for: relinquishments, in: .points)
                }.onError(reject)

            self.filterStored(relinquishmentGroups.intervalWeeks).then { relinquishments in
                self.processResortGrouping(for: relinquishments, in: .intervalWeeks)
                }.onError(reject)

            resolve()
        }
    }

    private func processResortGrouping(for relinquishments: [Relinquishment], in section: Section) {
        let relinquishmentGroups = relinquishmentManager.groupRelinquishmentsByResort(relinquishments: relinquishments)
        createRelinquishmentByResortCellModels(for: relinquishmentGroups, in: section)
    }
    
    private func createRelinquishmentByResortCellModels(for relinquishmentGroups: [RelinquishmentGroup], in section: Section) {
        
        var sectionRelinquishments: [Relinquishment?] = []
        var sectionSimpleCellViewModels: [SimpleCellViewModel] = []

        relinquishmentGroups.forEach { [unowned self] relinquishmentGroup in
            if let resort = relinquishmentGroup.resort {
                sectionRelinquishments.append(nil)
                let resortLocationText = [resort.address?.cityName, resort.address?.territoryCode].flatMap { $0 }.joined(separator: ", ")
                sectionSimpleCellViewModels.append(SimpleResortDetailViewModel(resortNameLabelText: resort.resortName,
                                                                               resortLocationLabelText: resortLocationText,
                                                                               resortCodeLabelText: resort.resortCode,
                                                                               resortImageURL: resort.getDefaultImage()?.url,
                                                                               placeholderImage: #imageLiteral(resourceName: "NoImageIcon")))
            }

            relinquishmentGroup.relinquishments.forEach { relinquishment in
                sectionRelinquishments.append(relinquishment)
                sectionSimpleCellViewModels.append(self.process(relinquishment: relinquishment))
            }
        }

        relinquishments[section] = sectionRelinquishments
        simpleCellViewModels[section] = sectionSimpleCellViewModels
    }

    private func resetLockOffUnitsInDisk(for relinquishment: Relinquishment) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            self.readPreviouslySelectedLockOffUnits(for: relinquishment)
                .then { lockOffUnitsInDisk in
                    guard let realm = self.entityDataStore.decryptedRealmOnDiskGlobal else {
                        reject(CommonErrors.parsingError)
                        return
                    }

                    do {
                        try realm.write {
                            lockOffUnitsInDisk.forEach { $0.isFloatRemoved = true }
                            resolve()
                        }

                    } catch {
                        reject(error)
                    }

                }.onError(reject)
        }
    }

    private func filterStored(_ relinquishments: [Relinquishment]) -> Promise<[Relinquishment]> {
        return Promise { [unowned self] resolve, reject in

            self.entityDataStore.readObjectsFromDisk(type: OpenWeeksStorage.self, predicate: nil, encoding: .decrypted)
                .then { openWeeksStore in

                    let depositedWeeksRelinquishmentIDs = openWeeksStore
                        .flatMap { $0.openWeeks }
                        .flatMap { $0.deposits }
                        .flatMap { $0.relinquishmentID }

                    let depositedOpenWeeksRelinquishmentIDs = openWeeksStore
                        .flatMap { $0.openWeeks }
                        .flatMap { $0.openWeeks }
                        .flatMap { $0.relinquishmentID }

                    let depositedClubPointsRelinquishmentIDs = openWeeksStore
                        .flatMap { $0.openWeeks }
                        .flatMap { $0.clubPoints }
                        .flatMap { $0.relinquishmentId }

                    let relinquishmentIDs = depositedWeeksRelinquishmentIDs + depositedOpenWeeksRelinquishmentIDs + depositedClubPointsRelinquishmentIDs
                    let hasNonSelectedLockOffUnits = { (relinquishment: Relinquishment) -> Bool in

                        if let lockOffUnits = relinquishment.unit?.lockOffUnits {

                            let lockedOffUnits: [String] = openWeeksStore
                                .flatMap { $0.openWeeks }
                                .flatMap { $0.openWeeks }
                                .filter { $0.relinquishmentID == relinquishment.relinquishmentId.unwrappedString }
                                .flatMap { $0.unitDetails }
                                .flatMap { $0.kitchenType }

                            let lockOffUnitSet = Set(lockOffUnits.flatMap { $0.unitDetailsUIFormatted })
                            let lockedOffUnitSet = Set(lockedOffUnits)
                            return lockOffUnitSet.subtracting(lockedOffUnitSet).count > 0
                        }

                        return false
                    }

                    let filteredRelinquishments = relinquishments.filter {
                        if $0.hasLockOffUnits {
                            return hasNonSelectedLockOffUnits($0)
                        } else {
                            return !relinquishmentIDs.contains($0.relinquishmentId.unwrappedString)
                        }
                    }

                    resolve(filteredRelinquishments)

                }.onError(reject)
        }
    }

    private func processCIGProgram(for relinquishmentGroups: RelinquishmentSections) -> Promise<[SimpleCellViewModel]> {
        return Promise { [unowned self] resolve, reject in
            guard relinquishmentGroups.hasCIGPointsProgram() else {
                resolve([])
                return
            }

            self.entityDataStore.readObjectsFromDisk(type: OpenWeeksStorage.self,
                                                     predicate: "contactID == '\(self.sessionStore.contactID)'",
                encoding: .decrypted)

                .then { openWeeksStorage in

                    let depositedPoints = openWeeksStorage.first?.openWeeks.first?.pProgram.first?.availablePoints
                    if case .some = depositedPoints {
                        resolve([])
                    } else {
                        let availablePoints = relinquishmentGroups.cigPointsProgram?.availablePoints ?? 0
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        resolve([SimpleAvailableRelinquishmentPointsCellViewModel(cigImage:  #imageLiteral(resourceName: "CIG"),
                                                                                  actionButtonImage: nil,
                                                                                  numberOfPoints: numberFormatter.string(from: availablePoints as NSNumber),
                                                                                  availablePointsButtonText: "Available Points Tool".localized(),
                                                                                  goldPointsHeadingLabelText: "Club Interval Gold Points".localized(),
                                                                                  goldPointsSubHeadingLabel: "Available Points as of Today".localized())])
                    }

                }.onError(reject)
        }
    }

    private func process(relinquishment: Relinquishment) -> SimpleCellViewModel {

        let resortName = "\((relinquishment.resort?.resortName).unwrappedString), \((relinquishment.resort?.resortCode).unwrappedString)"
        let relinquishmentYear = relinquishment.relinquishmentYear == nil ? nil : String(relinquishment.relinquishmentYear ?? 0)
        let weekNumber = relinquishment.supressWeekNumber() ? nil : processWeek(for: relinquishment.weekNumber)
        let ownershipState = relinquishment.isDeposit() ? "Deposited".localized() : nil
        let exchangeNumber = relinquishment.isDeposit() ? String(relinquishment.exchangeNumber ?? 0) : nil
        let formattedExchangeNumber = exchangeNumber == nil ? nil : "#\(exchangeNumber ?? "")"

        return SimpleOwnershipCellViewModel(ownershipStateLabelText: ownershipState,
                                            exchangeNumberLabelText: formattedExchangeNumber,
                                            extraInformationLabelText: processExtraInformation(for: relinquishment),
                                            monthLabelText: processCheckInInformation(for: relinquishment),
                                            yearLabelText: relinquishmentYear,
                                            weekLabelText: weekNumber,
                                            resortNameLabelText: resortName,
                                            unitDetailsLabelText: processUnitDetails(for: relinquishment),
                                            unitCapacityLabelText: processUnitCapacity(for: relinquishment),
                                            statusLabelText: processStatus(for: relinquishment),
                                            expirationDateLabelText: processExpirationDate(for: relinquishment),
                                            flagsLabelText: processFormattedFlagsMessage(for: relinquishment),
                                            relinquishmentPromotionImage: nil,
                                            relinquishmentPromotionLabelText: nil,
                                            actionButton: nil)
    }

    private func processStatus(for relinquishment: Relinquishment) -> String? {
        guard relinquishment.isDeposit() else { return nil }
        guard let requestType = RequestType(rawValue: relinquishment.requestType.unwrappedString) else { return nil }
        if case .LATE_DEPOSIT = requestType {
            return requestType.friendlyName()
        } else {
            return ExchangeStatus(rawValue: relinquishment.exchangeStatus.unwrappedString)?.friendlyNameForRelinquishment(isDeposit: true)
        }
    }

    private func processExpirationDate(for relinquishment: Relinquishment) -> String? {
        guard relinquishment.isDeposit() else { return nil }
        guard let expirationDate = relinquishment.expirationDate?.dateFromString() else { return nil }
        guard expirationDate.numberOfDaysToToday() > 0 else { return "Expired".localized() }
        if expirationDate.numberOfDaysToToday() > 30 {
            return "Expires: \(expirationDate.shortDateFormat())".localized()
        } else {
            let days = expirationDate.numberOfDaysToToday() > 1 ? "days" : "day"
            return "Expires in: \(expirationDate.numberOfDaysToToday()) \(days)".localized()
        }
    }

    private func processExtraInformation(for relinquishment: Relinquishment) -> String? {

        var extraInformationText: String?

        if relinquishment.blackedOut {
            extraInformationText = "Unit not available for deposit at this time. Please contact resort/club."
            if let resortPhoneNumber = relinquishment.resort?.phone {
                extraInformationText?.removeLast()
                extraInformationText = extraInformationText.unwrappedString+" at \(resortPhoneNumber)."
            }

        }

        if relinquishment.memberUnitLocked && !relinquishment.hasActions() && relinquishment.hasResortPhoneNumber() {
            let message = "Unit not available due to resort lock. Please contact resort/club."
            extraInformationText = extraInformationText.unwrappedString.isEmpty ?
                message : extraInformationText.unwrappedString + "\n" + message
        }

        if relinquishment.bulkAssignment && !relinquishment.hasActions() && relinquishment.hasResortPhoneNumber() {
            var message = "Contact resort/club for reservation or assignment."
            if let resortPhoneNumber = relinquishment.resort?.phone {
                message.removeLast()
                message += " at \(resortPhoneNumber)."
            }
            extraInformationText = extraInformationText.unwrappedString.isEmpty ?
                message : extraInformationText.unwrappedString + "\n" + message
        }

        return extraInformationText?.localized()
    }

    private func processUnitDetails(for relinquishment: Relinquishment) -> String? {

        guard let unit = relinquishment.unit, relinquishment.weekNumber != "POINTS_WEEK" else { return nil }

        guard !relinquishment.hasLockOffUnits else {
            return "Lock Off Capable".localized()
        }

        return unit.unitDetailsUIFormatted
    }

    private func processUnitCapacity(for relinquishment: Relinquishment) -> String? {
        guard relinquishment.weekNumber != "POINTS_WEEK" else { return nil }
        guard let unit = relinquishment.unit, !relinquishment.hasLockOffUnits else { return nil }
        return "Sleeps \(unit.tradeOutCapacity)".localized()
    }

    private func processFormattedFlagsMessage(for relinquishment: Relinquishment) -> String? {
        var formattedFlagsMessage: String? = nil

        let flags = [(relinquishment.blackedOut, "Blackout".localized()),
                     (relinquishment.memberUnitLocked, "Locked".localized()),
                     (relinquishment.bulkAssignment, "Bulk Week".localized()),
                     (relinquishment.supplementalWeek, "Supplemental Week".localized()),
                     (relinquishment.waitList, "Waitlist".localized())]

        let processFlags = { (flag: (isActive: Bool, message: String)) in
            if flag.isActive {
                let currentFlagMessage = formattedFlagsMessage.unwrappedString
                formattedFlagsMessage = currentFlagMessage.isEmpty ? flag.message : currentFlagMessage + "\n" + flag.message
            }
        }

        flags.forEach(processFlags)
        return formattedFlagsMessage
    }

    private func simpleCellViewModel(for indexPath: IndexPath) -> SimpleCellViewModel {
        guard let section = Section(rawValue: indexPath.section),
            let cellViewModel = simpleCellViewModels[section]?[indexPath.row] else { return SimpleSeperatorCellViewModel() }
        return cellViewModel
    }

    private func fetchRelinquishment(for indexPath: IndexPath) -> Relinquishment? {
        guard let section = Section(rawValue: indexPath.section) else { return nil }
        return relinquishments[section]?[indexPath.row]
    }

    private func processCheckInInformation(for relinquishment: Relinquishment) -> String? {

        if relinquishment.weekNumber == "POINTS_WEEK" {
            return "POINTS".localized()
        }

        if relinquishment.weekNumber == "FLOAT_WEEK" {
            return "FLOAT".localized()
        }

        guard relinquishment.supressCheckInDate() == false else { return nil }
        guard let checkInDate = relinquishment.checkInDate else { return nil }
        let format = "yyyy-MM-dd"
        guard let date = checkInDate.dateFromString(for: format) else { return nil }
        let calendar = CalendarHelper().createCalendar()
        let parsedDate = calendar.dateComponents([.day, .weekday, .month, .year], from: date)
        guard let day = parsedDate.day, let month = parsedDate.month else { return nil }
        let lookedUpMonth = Helper.getMonthnameFromInt(monthNumber: month)
        let formattedCheckInDate = day < 10 ? "0\(day)" : String(day)
        return "\(lookedUpMonth.uppercased()) \(formattedCheckInDate)"
    }

    private func processWeek(for weekIdentifier: String?) -> String? {
        guard let weekIdentifier = weekIdentifier else { return nil }
        guard !Constant.getWeekNumber(weekType: weekIdentifier).isEmpty else { return nil }
        return "Week \(Constant.getWeekNumber(weekType: weekIdentifier))".localized()
    }

    private func depositDepositedWeek(for relinquishment: Relinquishment) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            let resort = ResortList()
            let selectedOpenWeek = Deposits()
            let storedata = OpenWeeksStorage()
            let relinquishmentList = TradeLocalData()
            selectedOpenWeek.weekNumber = relinquishment.weekNumber.unwrappedString
            selectedOpenWeek.relinquishmentYear = relinquishment.relinquishmentYear ?? 0
            selectedOpenWeek.relinquishmentID = relinquishment.relinquishmentId.unwrappedString
            resort.resortName = relinquishment.resort?.resortName ?? ""
            resort.resortCode = relinquishment.resort?.resortCode ?? ""
            selectedOpenWeek.resort.append(resort)
            relinquishmentList.deposits.append(selectedOpenWeek)
            storedata.openWeeks.append(relinquishmentList)
            storedata.contactID = self.sessionStore.contactID
            self.entityDataStore.writeToDisk(storedata, encoding: .decrypted)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
        }
    }

    private func depositOpenWeek(for relinquishment: Relinquishment) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            let resort = ResortList()
            let storedata = OpenWeeksStorage()
            let selectedOpenWeek = OpenWeeks()
            let relinquishmentList = TradeLocalData()
            selectedOpenWeek.weekNumber = relinquishment.weekNumber.unwrappedString
            selectedOpenWeek.relinquishmentID = relinquishment.relinquishmentId.unwrappedString
            selectedOpenWeek.relinquishmentYear = relinquishment.relinquishmentYear ?? 0
            resort.resortName = relinquishment.resort?.resortName ?? ""
            resort.resortCode = relinquishment.resort?.resortCode ?? ""
            selectedOpenWeek.resort.append(resort)
            relinquishmentList.openWeeks.append(selectedOpenWeek)
            storedata.openWeeks.append(relinquishmentList)
            storedata.contactID = self.sessionStore.contactID
            self.entityDataStore.writeToDisk(storedata, encoding: .decrypted)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
        }
    }
}
