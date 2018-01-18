//
//  RelinquishmentViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/11/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import IntervalUIKit

final class RelinquishmentViewModel {
    
    // MARK: - Private properties
    private let clientAPI: ClientAPIStore
    private let sessionStore: SessionStore
    private let entityDataStore: EntityDataStore
    private let relinquishmentManager: RelinquishmentManager
    private let sectionTitle = ["Club Interval Gold Weeks".localized(), "Points".localized(), "Interval Weeks".localized()]
    
    private enum Section: Int { case cigProgram, points, intervalWeeks }
    private var relinquishments: [Section: [Relinquishment]] = [:]
    private var simpleCellViewModels: [Section: [SimpleCellViewModel]] = [:]
    
    // MARK: - Lifecycle
    init(clientAPI: ClientAPIStore, sessionStore: SessionStore, entityDataStore: EntityDataStore, relinquishmentManager: RelinquishmentManager) {
        self.clientAPI = clientAPI
        self.sessionStore = sessionStore
        self.entityDataStore = entityDataStore
        self.relinquishmentManager = relinquishmentManager
    }
    
    convenience init() {
        self.init(clientAPI: ClientAPI.sharedInstance,
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
            openWeeksEntity.membeshipNumber = memberNumber
            
            self.entityDataStore.writeToDisk(openWeeksEntity, encoding: .decrypted)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
        }
    }
    
    // MARK: - Private functions
    private func processRelinquishmentGroups(myUnits: MyUnits) -> Promise<Void> {
        let relinquishmentGroups = relinquishmentManager.getRelinquishmentGroups(myUnits: myUnits)
        relinquishments[.cigProgram] = relinquishmentGroups.cigPointsWeeks
        relinquishments[.points] = relinquishmentGroups.pointsWeeks
        relinquishments[.intervalWeeks] = relinquishmentGroups.intervalWeeks
        simpleCellViewModels[.cigProgram] = processCIGProgram(for: relinquishmentGroups)
        simpleCellViewModels[.points] = relinquishmentGroups.pointsWeeks.map(process)
        simpleCellViewModels[.intervalWeeks] = relinquishmentGroups.intervalWeeks.map(process)
        return Promise.resolve()
    }
    
    private func processCIGProgram(for relinquishmentGroups: RelinquishmentGroups) -> [SimpleCellViewModel] {

        var clubIntervalGoldWeeks: [SimpleCellViewModel] = []

        if let availablePoints = relinquishmentGroups.cigPointsProgram?.availablePoints {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            clubIntervalGoldWeeks.append(SimpleAvailableRelinquishmentPointsCellViewModel(cigImage: #imageLiteral(resourceName: "CIG"),
                                                                                          actionButtonImage: #imageLiteral(resourceName: "VS_List-Plus_ORNG"),
                                                                                          numberOfPoints: numberFormatter.string(from: availablePoints as NSNumber),
                                                                                          availablePointsButtonText: "Available Points Tool".localized(),
                                                                                          goldPointsHeadingLabelText: "Club Interval Gold Points".localized(),
                                                                                          goldPointsSubHeadingLabel: "Available Points as of Today".localized()))
        }
        
        if relinquishmentGroups.hasCIGPointsWeeks() {
            clubIntervalGoldWeeks.append(SimpleSeperatorCellViewModel())
            clubIntervalGoldWeeks += relinquishmentGroups.cigPointsWeeks.map(process)
        }

        return clubIntervalGoldWeeks
    }

    private func process(relinquishment: Relinquishment) -> SimpleCellViewModel {

        let processUnitDetails = { (unit: InventoryUnit?) -> String? in

            guard let unit = unit else { return nil }
            
            guard !relinquishment.lockOff else {
                return "Lock Off Capable".localized()
            }
            
            var unitDetails = ""

            if let unitSize = unit.unitSize {
                unitDetails = Helper.getBedroomNumbers(bedroomType: unitSize)
            }

            if let kitchenType = unit.kitchenType {
                unitDetails += ", \(Helper.getKitchenEnums(kitchenType: kitchenType))"
            }

            if let unitNumber = unit.unitNumber {
                unitDetails += ", \(unitNumber)"
            }

            return unitDetails
        }

        let resortName = "\((relinquishment.resort?.resortName).unwrappedString) / \((relinquishment.resort?.resortCode).unwrappedString)"
        let relinquishmentYear = relinquishment.relinquishmentYear == nil ? nil : String(relinquishment.relinquishmentYear ?? 0)
        let actionButtonImage = relinquishment.hasActions() ? #imageLiteral(resourceName: "VS_List-Plus_ORNG") : nil
        let checkInDate = relinquishment.supressCheckInDate() ? nil : processCheckInDate(relinquishment.checkInDate)
        let weekNumber = relinquishment.supressWeekNumber() ? nil : processWeek(for: relinquishment.weekNumber)
        let ownershipState = relinquishment.isDeposit() ? "Deposited".localized() : nil
        let exchangeNumber = relinquishment.isDeposit() ? String(relinquishment.exchangeNumber ?? 0) : nil
        let formattedExchangeNumber = exchangeNumber == nil ? nil : "#\(exchangeNumber ?? "")"

        var unitCapacity: String? = nil
        if let unit = relinquishment.unit, !relinquishment.lockOff {
            unitCapacity = "Sleeps \(unit.tradeOutCapacity)".localized()
        }

        return SimpleOwnershipCellViewModel(ownershipStateLabelText: ownershipState,
                                            exchangeNumberLabelText: formattedExchangeNumber,
                                            extraInformationLabelText: nil,
                                            monthLabelText: checkInDate,
                                            yearLabelText: relinquishmentYear,
                                            weekLabelText: weekNumber,
                                            resortNameLabelText: resortName,
                                            unitDetailsLabelText: processUnitDetails(relinquishment.unit),
                                            unitCapacityLabelText: unitCapacity,
                                            statusLabelText: nil,
                                            expirationDateLabelText: nil,
                                            flagsLabelText: nil,
                                            relinquishmentPromotionImage: nil,
                                            relinquishmentPromotionLabelText: nil,
                                            actionButton: actionButtonImage)
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

    private func processCheckInDate(_ checkInDate: String?) -> String? {
        // TODO: Based this off existing code, Frank is going to provide a helper method in SDK to do this based on UTC 0 always
        guard let checkInDate = checkInDate else { return nil }
        let format = "yyyy-MM-dd"
        guard let date = checkInDate.dateFromString(for: format) else { return nil }
        let calendar = NSCalendar.current
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
 }
