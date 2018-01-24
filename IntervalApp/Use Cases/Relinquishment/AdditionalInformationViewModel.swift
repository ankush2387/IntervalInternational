//
//  AdditionalInformationViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/19/18.
//

import then
import Bond
import DarwinSDK
import IntervalUIKit

final class AdditionalInformationViewModel {

    // MARK: - Public properties

    // MARK: - Private properties
    private let sessionStore: SessionStore
    private let relinquishment: Relinquishment
    private let imageAPIStore: ImageAPIStore
    private let directoryClientAPIStore: DirectoryClientAPIStore
    private let sectionTitle = [nil, "Resort Unit Details".localized(), "Reservation Details".localized()]
    private enum Section: Int { case resortDetails, unitDetails, reservationDetails }
    private var simpleCellViewModels: [Section: [SimpleCellViewModel]] = [:]
    
    // MARK: - Init
    init(relinquishment: Relinquishment,
         sessionStore: SessionStore = Session.sharedSession,
         imageAPIStore: ImageAPIStore = ClientAPI.sharedInstance,
         directoryClientAPIStore: DirectoryClientAPIStore = ClientAPI.sharedInstance) {

        self.sessionStore = sessionStore
        self.relinquishment = relinquishment
        self.imageAPIStore = imageAPIStore
        self.directoryClientAPIStore = directoryClientAPIStore
    }

    // MARK: - Public functions
    func load() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in

            guard let accessToken = self.sessionStore.clientAccessToken else {
                reject(UserFacingCommonError.invalidSession)
                return
            }

            guard let resortCode = self.relinquishment.resort?.resortCode else {
                reject(UserFacingCommonError.generic)
                return
            }

            self.directoryClientAPIStore.readResort(for: accessToken, and: resortCode)
                .then(self.updateResortInRelinquishment)
                .then(self.setResortDetailViewModel)
                .then(self.checkIfUserNeedsToPickInventoryUnit)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.noData) }
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
    private func updateResortInRelinquishment(with resort: Resort) -> Promise<Void> {
        relinquishment.resort = resort
        return Promise.resolve()
    }

    func cellViewModel(for indexPath: IndexPath) -> SimpleCellViewModel {
        guard let section = Section(rawValue: indexPath.section),
            let cellViewModel = simpleCellViewModels[section]?[indexPath.row] else { return SimpleSeperatorCellViewModel() }
        return cellViewModel
    }

    private func setResortDetailViewModel() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in

            guard let imageEntity = self.relinquishment.resort?.images.first(where: { $0.size == "XLARGE" }),
                let url = URL(string: imageEntity.url.unwrappedString) else {
                reject(CommonErrors.parsingError)
                return
            }

            let createResortDetailViewModel = { (image: UIImage) in
                let resort = self.relinquishment.resort
                self.simpleCellViewModels[.resortDetails] = [SimpleSeperatorCellViewModel(),
                                                             SimpleResortDetailViewModel(resortNameLabelText: resort?.resortName,
                                                                                         resortLocationLabelText: resort?.address?.cityName,
                                                                                         resortCodeLabelText: resort?.resortCode,
                                                                                         resortImage: image)]
            }

            self.imageAPIStore.readImage(for: url)
                .then(createResortDetailViewModel)
                .then(resolve)
                .onError(reject)
        }
    }

    private func checkIfUserNeedsToPickInventoryUnit() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            if self.relinquishment.requireClubResort() {

                guard let accessToken = self.sessionStore.clientAccessToken else {
                    reject(CommonErrors.emptyInstance)
                    return
                }

                guard let resortCode = self.relinquishment.resort?.resortCode else {
                    reject(CommonErrors.emptyInstance)
                    return
                }

                self.directoryClientAPIStore.readResortUnits(for: accessToken, and: resortCode).then {
                    print($0)
                    resolve()
                }.onError(reject)

            } else {
                resolve()
            }
        }
    }
}
