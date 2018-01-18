//
//  OmnitureIdentifier.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/11/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

enum OmnitureIdentifier: String {
    
    case signIn = "Sign In"
    case signInPage = "Sign In Page"
    case signInModal = "Sign-In Modal"
    case enableTouchId = "Enable Touch ID"
    case preloginChooseMemberShip = "Pre-Login Choose Membership"
    case allDestination = "All Destination"
    case typedSelection = "Typed Selection"
    case mapSelection = "Map Selection"
    case listItem = "s.list1"
    case alert = "Alerts"
    case primarySearchDateAvailable = "Primary – Search Date Available"
    case primaryAlternateDateAvailable = "Primary – Alternative Date Available"
    case primaryAndAoiSearchDateAvailable = "Primary & AOI – Search Date Available"
    case primaryAndAoiAlternateDateAvailable = "Primary & AOI – Alternative Date Available "
    case aoiOnlySearchDateAvailable = "AOI Only – Search Date Available"
    case aoiOnlyAlternateDateAvailable = "AOI Only – Alternative Date Available"
    case noAvailability = "No Availability"
    case productItem = "s.products"
    case vacationSearchCheckingIn = "Vacation search - Checking In"
    case products = "Products"
    case vacationSearchPaymentInformation = "Vacation Search - Payment Information"
    case vacationSearchRelinquishmentSelect = "Vacation Search - Relinquishment Select"
    case vacationSearch = "Vacation Search"
    case available = "Available"
    case notAvailable = "Not Available"
    case clubPointsSelection = "Club Points Selection"
    case simpleLockOffUnitOptions = "Simple Lock-Off Unit Options"
    case noTrips = "NO Trips"
    case sideMenu = "Side Menu"
    case homeDashboard = "Home Dashboard"
    case cigPoints = "CIGPoints"
    case clubPoints = "ClubPoints"
    case confirmation = "Vacation Search – Transaction Completed"
    case exchage = "EX"
    case getaway = "GW"
    case acomodationCertificate = "AC"
    case shortStay = "SS"
    case flightBooking = "FB"
    case toorBooking = "TB"
    case carRental = "CR"
    case notApplicable = "NA"
    case resortDirectoryHome = "Resort Directory Home"
    case createAnAlert = "Create an Alert"
    case editAnAlert = "Edit an Alert"
    case sideMenuAppeared = "Side Menu Appeared"
    case floatDetails = "Float Details 1"
    case lockOffFloatUnitOptions = "Lock Off and Float Unit Options"
    
    var value: String {
        return self.rawValue
    }
}
