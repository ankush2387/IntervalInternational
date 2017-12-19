//
//  GetawayAlertCoordinator.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 12/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import DarwinSDK

protocol GetawayAlertCoordinatorDelegate: class {
    func didLoad(token: DarwinAccessToken, settings: Settings)
    func didError()
}

final class GetawayAlertCoordinator {
    
    // MARK: - Public properties
    weak var delegate: GetawayAlertCoordinatorDelegate?
    
    // MARK: - Private properties
    private let clientAPIStore: ClientAPIStore
    
    // MARK: - Count for all alertsall
    private let alertCount = 0
    
    // MARK: - Lifecycle
    init(clientAPIStore: ClientAPIStore) {
        self.clientAPIStore = clientAPIStore
    }
    
    func readAllRentalAlerts(accessToken: DarwinAccessToken) {
        clientAPIStore.readAllRentalAlerts(for: accessToken)
            .then { rentalAlertArray in
                
                Constant.MyClassConstants.getawayAlertsArray.removeAll()
                Constant.MyClassConstants.getawayAlertsArray = rentalAlertArray
                Constant.MyClassConstants.activeAlertsArray.removeAllObjects()

                for alert in rentalAlertArray {
                    if let alertId = alert.alertId {
                        self.readRentalAlert(accessToken: accessToken, alertId: alertId)
                    }
                }
            }
            .onError(onError)
    }
    
    func readRentalAlert(accessToken: DarwinAccessToken, alertId: Int64) {
        Constant.MyClassConstants.searchDateResponse.removeAll()
        clientAPIStore.readRentalAlert(for: accessToken, and: alertId)
            .then { rentalAlert in
                
                let rentalSearchDatesRequest = RentalSearchDatesRequest()
                if let checkInTodate = rentalAlert.latestCheckInDate {
                    rentalSearchDatesRequest.checkInToDate = Helper.convertStringToDate(dateString:checkInTodate, format:Constant.MyClassConstants.dateFormat)
                }
                if let checkInFromdate = rentalAlert.earliestCheckInDate {
                    rentalSearchDatesRequest.checkInFromDate = Helper.convertStringToDate(dateString:checkInFromdate, format:Constant.MyClassConstants.dateFormat)
                }
                rentalSearchDatesRequest.resorts = rentalAlert.resorts
                rentalSearchDatesRequest.destinations = rentalAlert.destinations
                
                Constant.MyClassConstants.dashBoardAlertsArray = Constant.MyClassConstants.getawayAlertsArray
                self.readDates(accessToken: accessToken, request: rentalSearchDatesRequest, rentalAlert: rentalAlert)
            }
            .onError(onError)
    }
    
    func readDates(accessToken: DarwinAccessToken, request: RentalSearchDatesRequest, rentalAlert: RentalAlert) {
        clientAPIStore.readDates(for: accessToken, and: request)
            .then { rentalSearchDatesResponse in
                intervalPrint("____-->\(rentalSearchDatesResponse)")
                Constant.MyClassConstants.searchDateResponse.append(rentalAlert, rentalSearchDatesResponse)
                self.performSortingForMemberNumberWithViewResultAndNothingYet()
                
            }
        .onError(onError)
    }
    
    private func performSortingForMemberNumberWithViewResultAndNothingYet() {
    
        Constant.MyClassConstants.searchDateResponse.sort { $0.0.alertId ?? 0 > $1.0.alertId ?? 0 }
        Constant.MyClassConstants.searchDateResponse.sort { $0.1.checkInDates.count > $1.1.checkInDates.count }
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.getawayAlertsNotification), object: nil)
    }
    
    // MARK: - Private functions
    
    private func onSuccess() {
        
        _ = { [unowned self] (alertsArray: [RentalAlert]) in
           intervalPrint(alertsArray)
        }
        
        _ = { [unowned self] (error: Error) in
            self.onError(error: error)
        }
    }
    
    private func onError(error: Error) {
        intervalPrint(error)
        delegate?.didError()
    }
 }
