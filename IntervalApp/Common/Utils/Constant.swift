//
//  Constant.swift
//  IntervalApp
//
//  Created by Chetu on 08/02/16.
//  Copyright 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import GoogleMaps

class Constant: NSObject {
    
    static var holdingTimer: Timer?
    static var holdingTime = 17
    static var decreaseValue = 1
    static var activeAlertCount = 0
    static var needToReloadAlert = false
    static var selectedAlertToEdit: RentalAlert?
  
      //***** common function to get device orientation *****//
    struct RunningDevice {
        static var deviceOrientation: UIDeviceOrientation?
        static var deviceIdiom = UIDevice().userInterfaceIdiom
    }
    
    //Getaways SearchResult CardFormDetail Data
    struct GetawaySearchResultGuestFormDetailData {
    
        static var countryCodeArray = [String]()
        static var stateCodeArray = [String]()
        static var countryListArray = [Country]()
        static var stateListArray = [State]()
        static var textFieldChangedInSection = -1
        static var firstName = ""
        static var lastName = ""
        static var country = ""
        static var address1 = ""
        static var address2 = ""
        static var city = ""
        static var state = ""
        static var pinCode = ""
        static var email = ""
        static var homePhoneNumber = ""
        static var businessPhoneNumber = ""
        
    }
    
    struct AdditionalUnitDetailsData {
        
        static var clubresort = ""
        static var reservationNumber = ""
        static var unitNumber = ""
        static var bedroomUnit = ""
        static var checkInDate = ""
    
    }
    
    //Float additional info textfield variabls
    struct FloatDetails {
        
        static var unitNumber = ""
        static var reservationNumber = ""
    }
    
    struct RGBColorCode {
        
        static var centerViewRgb = UIColor(red: 176.0 / 255.0, green: 215.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
        
        static var textFieldBorderRGB = UIColor(red: 241.0 / 255.0, green: 241.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0).cgColor
    }
    
    //GetawaySearchResultCardFormDetailData
    struct GetawaySearchResultCardFormDetailData {
        
        static var countryListArray = ["Canada", "USA", "India", "Austrelia", "South Africa"]
        static var countryCodeArray: [String] = []
        static var textFieldChangedInSection = -1
        static var nameOnCard = ""
        static var cardNumber = ""
        static var country = ""
        static var address1 = ""
        static var address2 = ""
        static var city = ""
        static var state = ""
        static var pinCode = ""
        static var cardType = ""
        static var expDate = ""
        static var cvv = ""
        static var countryCode = ""
        static var stateCode = ""
    }
    
    struct MyClassConstants {
        static var isRunningOnIphone: Bool {
            return UIDevice.current.userInterfaceIdiom == .phone
        }
        static var alertOriginationPoint: String = ""
        static var depositPromotionNav = "DepositPromotionsNav"
        static var sorting = "Sorting"
        static var filterSearchResult = "Filter Search Result".localized()
        static var loginOriginationPoint: String = ""
        static var vacationSearchResultHeaderLabel: String = ""
        static var upcomingOriginationPoint: String = ""
        static var loginType: String = ""
        static var selectedDestinationNames: String = ""
        static var addressStringForCardDetailSection = "Address"
        static var destinationOrResortSelectedBy: String = ""
        static var selectionType = -1
        static var searchOriginationPoint = "Default"
        static var searchForSegmentIndex = 0
        static var checkoutInsurencePurchased = "No"
        static var checkoutPromotionPurchased = ""
        
        //upcoming trip type counter value
        static var exchangeCounter = 0
        static var getawayCounter = 0
        static var shortStayCounter = 0
        static var acomodationCertificateCounter = 0
        static var flightCounter = 0
        static var carRentalCounter = 0
        static var isEvent2Ready = 0
        
        static var rentalSortingOptionArray = ["Recommended", "Resort Name:", "Resort Name:", "Price:", "Price:", "City:", "City:", "Resort Tier:", "Resort Tier:"]
        static var sortingSetValues = ["DEFAULT", "RESORT_NAME_ASC", "RESORT_NAME_DESC", "CITY_NAME_ASC", "CITY_NAME_DESC", "RESORT_TIER_LOW_TO_HIGH", "RESORT_TIER_HIGH_TO_LOW", "PRICE_LOW_TO_HIGH", "PRICE_HIGH_TO_LOW", "UNKNOWN"]
        
        static var rentalSortingRangeArray = ["Default", "A - Z", "Z - A", "Low - High", "High - Low", "A - Z", "Z - A", "Low - High", "High - Low"]
        
        static var exchangeSortingOptionArray = ["Default", "Resort Name:", "Resort Name:", "City:", "City:", "Resort Tier:", "Resort Tier:"]
        static var exchangeSortingRangeArray = ["Default", "A - Z", "Z - A", "A - Z", "Z - A", "Low - High", "High - Low"]
        
        static var filteredIndex = 0
        static var sortingIndex = -1
        
        //Relinquishment available points program
        static var relinquishmentAvailablePointsProgram = 0
      
        //global variable to hold stepper Adult current value
        static var stepperAdultCurrentValue = 2
        
        //global variable to hold stepper children current value
        static var stepperChildCurrentValue = 1
        
        //global variable to hold the vacation search segment selected index
        static var vacationSearchSelectedSegmentIndex = 0
        
        //***** global variable that hold vacationSearchRunningDetailsResortIndex *****//
        var vacationSearchRunningDetailsResortIndex = 0
        
        //***** global variable that hold side menu option selection *****//
        static var sideMenuOptionSelected = ""
        
        static var allBedrommSizes = "All BedRoom Sizes"
        
        //global variable to hold last Getaway Booking Process
        
        static var getawayBookingLastStartedProcess: RentalProcess?
        
        //global variable to hold last exchange getaway booking process
        
        static var exchangeBookingLastStartedProcess: ExchangeProcess?
        
        //***** global variable that hold system access token *****//
        static var systemAccessToken: DarwinAccessToken? {
            return Session.sharedSession.clientAccessToken
        }
        
        //***** global variable that identify the running functionality *****//
        static var runningFunctionality = ""
        
        //***** global variable that identify which controller requested for login *****//
        static var signInRequestedController: UIViewController?
        
        //***** global variable that hold the collection view index *****//
        static var searchResultCollectionViewScrollToIndex = 0
        
        //***** global variable  that hold  Boolean value successfull login status *****//
        static var isLoginSuccessfull = false
        
        static var isFromSorting = false
        
        static var isFromSearchResult = false
        
        //***** global variable to hold webview instance data *****//
        static var requestedWebviewURL: String = ""
        static var webviewTtile: String = ""
        static var resortDirectoryTitle = "Resort Directory".localized()
        static var resortDirectoryCommonHearderText = "Choose Region".localized()
        static var selectedBedRoomSize = "All Bedroom Sizes".localized()
        
        //***** New creditcard screen constant string *****//
        static var newCardalertTitle = "New Creditcard Form".localized()
        static var newCardalertMess = "Card already exist.".localized()
        static var alertReqFieldMsg = "Please fill mandatory fields!".localized()
        static var noResultError = "No Result".localized()
        static var tryAgainError = "Try Again".localized()
        static var tdi = "TDI".localized()
        static var season = "Season".localized()
        static var certificateDetailsCellTitle = "Certificate Details".localized()
        
        //***** Vacation search screen constant string header array *****//
        static var threeSegmentHeaderTextArray = ["Where do you want to go".localized(), "Check in closest to".localized(), "Who is travelling".localized()]
        
        //***** Who will be checking-In header text array *****//
        static var whoWillBeCheckingInHeaderTextArray = ["From the list below, Who on your  membership might be checking-in?".localized(), "", "Guest Name".localized(), "Guest Address", "Guest Contact info".localized(), ""]
        
        //***** checkout screen table header footer string array *****//
        static var checkOutScreenHeaderTextArray = ["", "Promotions".localized(), "Exchange Options".localized(), "Add Trip Protection(Recommended)".localized(), "Your Booking Costs".localized(), "", "", "", "Payment Method".localized(), "Confirmation Email".localized()]
        static var checkOutScreenHeaderIPadTextArray = ["", "Promotions".localized(), "Exchange Options".localized(), "Add Trip Protection(Recommended)".localized(), "Payment Method".localized(), "Confirmation Email".localized(), "", "", "", ""]
        
        //***** Initializing plicy list table cell content array *****//
        static var policyListTblCellContentArray = ["Terms & Conditions".localized(), "Privacy Policy".localized(), "Legal Information".localized(), "Contact Us".localized(), "Email Us".localized(), "Our Offices".localized(), "Interval World".localized(), "Version \(Helper.getBuildVersion())".localized()]
        
        static var fourSegmentHeaderTextArray = ["Where do you want to go".localized(), "What do you want to trade".localized(), "Check in closest to".localized(), "Who is travelling".localized()]
        
         static var headerTextFlexchangeDestination = "Your selected Flexchange Destination".localized()
        
        static var sectionHeaderArray = ["Destinations".localized(), "Resorts".localized()]
        static var relinquishmentHeaderArray = ["Club Interval Gold Weeks".localized(), "", "Club Points".localized(), "Interval Weeks".localized(), "Deposited".localized()]
        static var lockOffCapable = "Lock Off Capable".localized()
        
        static var membershipContactArray = [Contact]()
        static var vacationSearchDestinationArray: NSMutableArray = []
        static var calendarDatesArray = [CalendarItem]()
        static var calendarCount = 0
        static var realmStoredDestIdOrCodeArray: NSMutableArray = []
        static var resortCodesArray: [String] = []
        static var searchAvailabilityHeader = ""
        static var filterOptionsArray: [ResortDestination] = []
        static var areaWithAreaCode: [AreaInfo] = []
        static var relinquishmentsArray: [RelinquishmentTypes] = []
        static var selectedAreaCodeDictionary = NSMutableDictionary()
        static var selectedAreaCodeArray = NSMutableArray()
        
        static var surroundingResortCodesArray: [String] = []
        static var resortsArray = [Resort]()
        static var regionArray = [Region]()
        static var regionAreaDictionary = NSMutableDictionary()
        static var favoritesResortArray = [Resort]()
        static var favoritesResortCodeArray: NSMutableArray = []
        static var getawayAlertsArray = [RentalAlert]()
        static var dashBoardAlertsArray = [RentalAlert]()
        static var alertsDictionary = NSMutableDictionary()
        static var upcomingTripsArray = [UpcomingTrip]()
        static var transactionType = ""
        static var activeAlertsArray: NSMutableArray = []
        static var membershipdetails = [Membership]()
        static var memberdetailsarray: NSMutableArray = []
        static var memberNumber: String = ""
        
        static var whereTogoContentArray: NSMutableArray = []
        static var whatToTradeArray: NSMutableArray = []
        static var floatRemovedArray: NSMutableArray = []
        static var pointsArray: NSMutableArray = []
        static var selectedGetawayAlertDestinationArray = [selectedDestType]()
        static var alertSelectedResorts = [Resort]()
        static var alertSelectedDestination = [AreaOfInfluenceDestination]()
        static var fromdatearray: NSMutableArray = []
        static var todatearray: NSMutableArray = []
        static var labelarray: NSMutableArray = []
        
        static var googleMarkerArray = [GMSMarker]()
        
        static let sidemenuIntervalInternationalCorporationLabel = "2015 Interval International. Privacy/Legal".localized()
        static let noRelinquishmentavailable = "No Relinquishment available".localized()
        static let relinquishmentTitle = "Select all or any lock-off portion".localized()
        static let floatTitle = "Select one lock-off portion at a time".localized()
        static let bedroomTitle = "Choose Bedrooms".localized()
    
        static var selectedIndex = 0
        static var vacationSearchContentPagerRunningIndex = 0
        static var vacationSearchShowDate = Date()
        static var alertWindowStartDate: Date?
        static var alertWindowEndDate: Date?
        static var todaysDate = Date()
        static var dateAfterTwoYear = NSCalendar.current.date(byAdding: .month, value: 24, to: NSDate() as Date)
        
        static var bundelVersionUsedString = "CFBundleShortVersionString".localized()
        static var member = "Member #  ".localized()
        static var switchToView = "SwitchToView"
        static var signOutSelected = "signOutSelected"
        
        // intervalHD arrays
        static var intervalHDDestinations = [Video]()
        static var intervalHDResorts = [Video]()
        static var intervalHDTutorials = [Video]()
        static var magazinesArray = [Magazine]()
        
        // Pick destinations array
        static var resorts: [Resort]? = []
        static var destinations: [AreaOfInfluenceDestination]? = []
        static var allDestinations = "All Available Destinations".localized()
        
        static var redirect: (alertID: Int?, rentalAlert: RentalAlert?) = (nil, nil)
        static var searchDateResponse: [(RentalAlert, RentalSearchDatesResponse)]  = []
        static var currentFromDate: Date?
        static var currentToDate: Date?
        static var checkInDates = [Date]()
        static var surroundingCheckInDates = [Date]()
        static var combinedCheckInDates = [Date]()
        static var totalWindow = 90
        static var bedRoomSize = ["STUDIO", "ONE_BEDROOM", "TWO_BEDROOM", "THREE_BEDROOM", "FOUR_BEDROOM"]
        static var alertSelectedUnitSizeArray = [String]()
        static var topDeals: [RentalDeal] = []
        static var flexExchangeDeals: [FlexExchangeDeal] = []
        static var resortDirectoryRegionArray = [Region]()
        static var resortDirectorySubRegionArray = [Region]()
        static var resortDirectoryAreaListArray = [Area]()
        static var resortDirectoryResortArray = [Resort]()
        static var viewController = UIViewController()
        static var btnTag = -1
        static var showAlert: Bool = false
        static let arrayResortInfo = ["Resort Information", "Amenities", "Member Ratings", "Travel Demand Index"]
        static var backgroundImageUrl: String = ""
        static var resortDescriptionString: String = ""
        static var resortsDescriptionArray = Resort()
        static var collectionViewScrolledIndex = 0
        static var imagesArray = [String]()
        static var bedRoomSizeSelectedIndexArray: NSMutableArray = []
        static var alertSelectedBedroom = [String]()
        static var unitNumberSelectedArray: NSMutableArray = []
        static var amenitiesDictionary = NSMutableDictionary()
        static var advisementsDictionary = NSMutableDictionary()
        static var imageSize = "LARGE"
        static var imageSizeXL = "XLARGE"
        static var noImage = "NoImageIcon"
        static var logoMenuImage = "LogoMenu"
        
        static var year = "Year"
        static var month = "Month"
        static var date = "Date"
        static var weekDay = "Weekday"
        
        static var inactive = "INACTIVE".localized()
        static var expired = "EXPIRED".localized()
        static var active = "ACTIVE".localized()
        static var bedroomSizes = "All BedRoom Sizes".localized()
        static var start = "start"
        static var end = "end"
        static var first = "First"
        static var last = "Last"
        static var resortFunctionalityCheck = "ResortDirectory"
        static var favoritesFunctionalityCheck = "Favorites"
        static var magazinesFunctionalityCheck = "Magazines"
        static var videosFunctionalityCheck = "Videos"
        static var vacationSearchFunctionalityCheck = "VacationSearch"
        static var seledtedSegmentGetaway = "Getaway"
        static var selectedSegmentExchange = "Exchange"
        
        static var draw = "Draw".localized()
        static var clear = "Clear".localized()
        static var list = "List".localized()
        static var map = "Map".localized()
        static var isFromNothingYet: Bool = false
        
        static var createAlert = "CreateAlert"
        static var editAlert = "EditAlert"
        static var resortDirectoryVC = "ResortDirectoryViewController"
        static var currentIssue = "Current Issue!".localized()
        static var vacationSearch = "VacationSearch"
        static var searchResult = "SearchResult"
        
        static var right = "Right"
        static var left = "Left"
        
        static var addResortSelectedIndex = [Int]()
        static var collectionVwCurrentIndex = 0
        
        static var childCounterString = "childCounter".localized()
        static var adultCounterString = "adultCounter".localized()
        static var selectedDate = "SelectedDate"
        
        static var childCounter = 0
        static var adultCounter = 2
        
        static var resortVC = "ResortDetailsViewController"
        static var destinationResortDetail = "DestinationResortViewController"
        static var resortsString = "Resort".localized()
        static var tutorialsString = "Tutorial".localized()
        static var areaString = "Area"
        static var searchPlaceHolder = "Search".localized()
        static var getawayAlerts = "GetawayAlerts"
        
        static var surroundingAreaString = "Resorts in surrounding areas.".localized()
        static var viewResponse = PrepareView()
        static var exchangeViewResponse = ExchangeProcessPrepareView()
        static var generalAdvisementsArray = [Advisement]()
        static var additionalAdvisementsArray = [Advisement]()
        static var processStartResponse = RentalProcessPrepareResponse()
        static var exchangeProcessStartResponse = ExchangeProcessPrepareResponse()
        static var continueToCheckoutResponse = RentalProcessRecapResponse()
        static var exchangeContinueToCheckoutResponse = ExchangeProcessRecapResponse()
        static var continueToPayResponse = RentalProcessEndResponse()
        static var exchangeContinueToPayResponse = ExchangeProcessEndResponse()
        static var recapViewPromotionCodeArray = [Promotion]()
        static var allowedCreditCardType = [AllowedCreditCardType]()
        static var rentalFees = [RentalFees]()
        static var exchangeFees = [ExchangeFees]()
        static var memberCreditCardList = [Creditcard]()
        static var selectedCreditCard = [Creditcard]()
        static var guestCertificate: GuestCertificate?
        static var allowedCurrencies = [String]()
        
        //Relinquishment selection date for float and avaialable tool
        static var  relinquishmentAvalableToolSelectedDate: Date?
        static var  relinquishmentFloatDetialSelectedDate: Date?
        static var  relinquishmentFloatDetialMinDate: Date?
        static var  relinquishmentFloatDetialMaxDate: Date?
        static var  floatDetailsCalendarDateArray = [Date]()
        static var  floatDetailsCalendarWeekArray = NSMutableArray()
        static var relinquishmentFlaotWeek = "RelinquishmentFloatWeek"
        static var realmOpenWeeksID = NSMutableArray()
        
        static var  onsiteArray = NSMutableArray()
        static var  nearbyArray = NSMutableArray()
        static var  relinquishmentIdArray = [String]()
        static var  relinquishmentUnitsArray = NSMutableArray()
        static var  idUnitsRelinquishmentDictionary = NSMutableDictionary()
        static var  userSelectedUnitsArray = NSMutableArray()
        static var  senderRelinquishmentID = ""
        static var  relinquishmentDeposits = [Deposit]()
        static var  relinquishmentOpenWeeks = [OpenWeek]()
        static var  relinquishmentProgram = PointsProgram()
        static var  relinquishmentSelectedWeek = OpenWeek()
        static var relinquismentSelectedDeposit = Deposit()
        static var  clubPointResortsArray = [Resort]()
        static var  userSelectedStringArray = [String]()
        
        static var onsiteString: String = "Nearby" + "\n"
        static var nearbyString: String  = "On-Site" + "\n"
        static var indexSlideButton = 0
        static var onsiteDictKey = "Onsite"
        static var nearbyDictKey = "Nearby"
        static var status = "true"
        
        static var inventoryPrice = [InventoryPrice]()
        static var selectedResort = Resort()
        static var selectedExchange = ""
        
        static var paymentMethodTitle = "Payment Method".localized()
        static var webViewGetElementById = "document.getElementById('WASCInsuranceOfferOption0').checked == true;"
        static var webViewGetElementById1 = "document.getElementById('WASCInsuranceOfferOption1').checked == true;"
        static var paymentInfo = "Select your payment method".localized()
        static var verifying = "Verifying...".localized()
        static var insurance = "Trip Protection".localized()
        static var upgradeCost = "Upgrade".localized()
        static var guestCertificateTitle = "Guest Certificate".localized()
        static var renewals = "Renewals".localized()
        static var exchangeFeeTitle = "Exchange Fee"
        static var getawayFee = "Getaway Fee"
        static var eplus = "EPlus"
        static var taxesTitle = "Taxes"
        static var emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        static var selfMatches = "SELF MATCHES %@"
        static var endingIn = "ending in"
        
        static var enableTaxes = false
        static var enableGuestCertificate = false
        static var guestCertificatePrice = 0.0
        
        static var hasAdditionalCharges = false
        static var guestString = "guest"
        static var additionalAdv = "ADDITIONAL INFORMATION"
        static var dateFormat = "yyyy-MM-dd"
        static var monthDateFormat = "yyyy-MM"
        static var dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        //use for no Availability Cell
        static var isShowAvailability = false
        
        static var isTrue = "true"
        static var isFalse = "false"
        static var isOn = "on"
        static var isOff = "off"
        static var relinquishment = "Relinquishment"
        static var resortDirectoryVCTitle = "ResortDetailsVC"
        static var alertsResortCodeDictionary = NSMutableDictionary()
        static var alertsSearchDatesDictionary = NSMutableDictionary()
        static var headerArray = ["Getaway Alerts".localized(), "My Upcoming Trips".localized()]
        
        static var transactionNumber = "021638132"
        static var pointMatrixDictionary = NSMutableDictionary()
        static var clubIntervalDictionary = NSMutableDictionary()
        static var clubIntervalPointsForUnit = NSMutableArray()
        static var clubPointMatrixHeaderArray = NSMutableArray()
        static var matrixDataArray = NSMutableArray()
        static var matrixTypeSingle = "SINGLE"
        static var matrixTypePremium = "PREMIUM"
        static var matrixTypeColor = "STANDARD"
        static var matrixDescription = ""
        static var pointsCell = "PointsCell"
        static var showSegment = true
        static var resortCodeForClub = "EVC"
        static var matrixType = ""
        static var checkBoxTag = 0
        static var segmentFirstString = "First"
        static var segmentSecondString = "Second"
        static var segmentThirdString = "Third"
        static var clubFloatResorts = [Resort]()
        static var savedClubFloatResort = ""
        static var savedClubFloatResortCode = ""
        static var savedBedroom = ""
        static var buttontitle = ""
        static var resortAttributedString = ""
        
        //Reservation Attributes
        static var resortAttributes = "RESORT ATTRIBUTES".localized()
        static var resortClubAttribute = "RESORT CLUB".localized()
        static var resortReservationAttribute = "RESERVATION NUMBER".localized()
        static var checkInDateAttribute =   "CHECK IN DATE".localized()
        static var unitNumberAttribute = "UNIT NUMBER".localized()
        static var resortDetailsAttribute = "RESORT DETAILS".localized()
        static var saveAttribute = "SAVE DETAILS".localized()
        static var callResortAttribute = "CALL DETAILS".localized()
        static var noOfBedroomAttribute = "NO OF BEDROOMS".localized()
        static var selectClubResort = "Select club or Resort".localized()
        
        //Float week to store information for editing
        static var selectedFloatWeek = OpenWeeks()
        static var unitNumberLockOff = ""
        static var saveLockOffDetailsArray = [String]()
        
        //Header for search results
        static var searchResultHeader = "Nearest Check-in Date selected.\nWe found availibility close to your desired date.".localized()
        static var isFromExchange = false
        static var isFromExchangeAllAvailable = false
        static var isFromRentalAllAvailable = false
        static var isFromWhatToUse = false
        static var isFromSearchBoth = false
        static var travelPartyInfo = TravelParty()
        static var bucketsArray = [ExchangeBucket]()
        static var exchangeInventory = [ExchangeInventory]()
        static var inventoryUnitsArray =  [InventoryUnit]()
        static var promotionsArray = [Promotion]()
        static var htmlHeader = "<html><body>"
        static var htmlFooter = "</html></body>"
    
        // Choose relinquishments
        static var filterRelinquishments = [ExchangeRelinquishment]()

        //UserDefaults
        static var userName = "userName"
        static var firstTimeRunning = "firstTimeRunnig"
        static var exchangeDestination = ExchangeDestination()
        
        //Changed promotions to global
        static var isPromotionsEnabled = false
        static var recapPromotionsArray = [Promotion]()
        
        //Keypath for picker
        static var keyTextColor = "textColor"

        static var initialVacationSearch = VacationSearch()

        //used to not remove observers on ipad googleMapViewController when going to map or weather view
        static var goingToMapOrWeatherView = false
        //Global App Settings
        static var appSettings = AppSettings()
        static var noAvailabilityView = false
        static var selectedUnitIndex = 0
        
        // Search both check for rental and exchange
        
        static var rentalHasNotAvailableCheckInDatesForInitial: Bool = false
        static var exchangeHasNotAvailableCheckInDatesForInitial: Bool = false
        
        static var rentalHasNotAvailableCheckInDatesAfterSelectInterval: Bool = false
        static var exchangeHasNotAvailableCheckInDatesAfterSelectInterval: Bool = false
        static var searchBothExchange = false
        
        // Flex change
        static var flexChangeSearch = "Flexchange Search".localized()
        
        // All available destinations
        static var allDestinationsOption = "All Destinations Options".localized()
         static var viewSelectedDestination = "View Selected Destinations".localized()
        
        // Renewals
        static var renewalsHeaderTitle = ""
        static var comboHeaderTitle = "Keep your Interval Benefits".localized()
        static var coreHeaderTitle = "Renew your Membership".localized()
        static var freeGuestCertificateTitle = "FREE GUEST CERTIFICATES".localized()
        static var isNoThanksFromRenewalAgain = false
        
        static var otherOptions = "Other Options".localized()
        static var renewNow = "Renew Now".localized()
        static var select = "Select".localized()
        static var noThanks = "No Thanks".localized()
        
        static var noThanksForNonCore = false
        
        static var isChangeNoThanksButtonTitle = false
        
        static var isDismissWhoWillBeCheckin = false
                
        static var guestCertificateString = "Get a FREE Guest Certificate now and every time with Interval Platinum. Your Interval Platinum must be active through your travel dates to receive FREE Guest Certificates. To upgrade or renew, a".localized()
        
        static var popToLoginView =  "PopToLoginView"
        
        static var certifcateCount = 0
        static var certificateArray = [AccommodationCertificate]()
        static var noFilterOptions = false
        static var isCIGAvailable = false
        static var isClubPointsAvailable = false
        static var lowestTerm = 12
    }
    
    // Enum to store openWeek types
     enum RelinquishmentTypes {
        case Deposit(Deposits)
        case ClubPoints(ClubPoints)
        case CIGPoints(rlmPointsProgram)
        case FixedWeek(OpenWeeks)
    }
    
    enum selectedDestType {
        case resort(Resort)
        case destination(AreaOfInfluenceDestination)
        case resorts([Resort])
    }
    // Enum to store resorts and destinations
    enum ResortDestination {
        case Resort(ResortList)
        case Destination(DestinationList)
        case ResortList([ResortByMap])
        case Area(NSMutableDictionary)
    }
    
    //Enum for not saved resort destinations
    enum AlertResortDestination {
       case Resort(Resort)
       case Destination(AreaOfInfluenceDestination)
    }
    
    // Enum to store area and area code
    enum AreaInfo {
        static var area = [Area]()
        static var areaCode = ""
    }
    
    struct CommonColor {
        static var greenColor = "Green"
        static var blueColor = "Blue"
        static var headerGreenColor = UIColor(red: 112.0 / 255.0, green: 185.0 / 255.0, blue: 9.0 / 255.0, alpha: 1)
    }
    
    struct CommonStringIdentifiers {
        static var floatWeek = "FLOAT_WEEK"
        static var pointWeek = "POINTS_WEEK"
        static var noRelinquishmentAvailable = "NO_RELINQUISHMENT"
        static var alertOriginationPoint = "Unsuccessful Getaway Search 3"
    }
    
    struct CommonLocalisedString {
        
        static var memberNumber = "Member No".localized()
        static var user_id = "User ID".localized()
        static var user_password = "Password".localized()
        static var sign_in = "Sign In".localized()
        static var totalString = " Total, ".localized()
        static var privateString = " Private".localized()
        static var exactString = "Resorts in ".localized()
        static var surroundingString = "Resorts near ".localized()

        static var contactName = "contactname"
        static var cardName = "cardname"
        static var loginID = "loginid"
        static var email = "email"
        static var memberNum = "membernumber"
        static var memberDate = "memberdate"
        static var membershipExpirationDate = "membershipexpirationdate"
        static var cardExpirationDate = "cardexpiration"
    }
    
    //***** common  structure to provide all constant header strings *****//
    struct HeaderViewConstantStrings {
        
        static var exchange = "Exchange"
        static var getaways = "Getaway"
        static var search = "All Available Destinations"
        static var resortUnitDetails = "Unit Details"
        static var reservationDetails = "Reservation Details"
        
    }
    
    //***** common  structure to provide all webview url as string *****//
    struct WebUrls {
        
        static let privacyPolicyUrlArray = ["http://www.intervalworld.com/iimedia/pdf/iw/buyers-guide.pdf", "http://www.intervalworld.com/web/cs?a=60&p=privacy-policy", "http://www.intervalworld.com/web/cs?a=60&p=legal", "http://www.intervalworld.com/web/cs?a=60&p=customer-service", "http://www.intervalworld.com/web/cs?a=80", "http://www.intervalworld.com/web/cs?a=60&p=offices", "http://www.intervalworld.com"]
        
        static var joinTodayURL = "https://www.intervalworld.com/web/my/account/createProfileOrJoin"
        static var loginHelpURL = "https://www.intervalworld.com/web/my/account/forgotSignInInfo"
    }
    //***** common  structure to provide upcoming trip cell localised string *****//
    struct UpComingTripHeaderCellSting {
        
        static var additionalProducts = "Additional Products"
        static var payment = "Payment"
        static var policy = "Policy"
    }
    
    //***** common  structure to provide alert messages *****//
    struct AlertErrorMessages {
        
        static var loginFailed = "Login Failed".localized()
        static var errorString = "Error".localized()
        static var networkError = "No Internet Connection".localized()
        static var noResultError = "No Result".localized()
        static var tryAgainError = "Try Again".localized()
        static var loginFailedError = "Login Failed".localized()
        static var getawayAlertMessage = "Check back with us in a bit or we will keep searching and contact you when we have a match!\n\n You can also start your own search".localized()
        static var emailAlertMessage = "Please enter valid email".localized()
        static var noDestinationRelinquishmentError = "Add \("Destinations") and \("Items to trade")".localized()
        
    }
    
    //***** common structure to provide alert messages *****//
    struct AlertMessages {
        
        static var searchAlertTitle = "Search All Available Destinations".localized()
        
        static var searchAlertMessage = "Selecting this option will remove all other currently selected destinations/resorts . Are you sure you want to do this?".localized()
        static var emptyLoginIdMessage = "Please enter your Login ID.".localized()
        static var emptyPasswordLoginMessage = "Please enter your Password.".localized()
        static var createAlertMessage = "Alert created successfully".localized()
        static var editAlertMessage = "Alert updated successfully".localized()
        static var noMembershipMessage = "Please contact your servicing office.  No membership information was found for your account.".localized()
        static var noResultMessage = "Sorry there is no availability within 90 days of your selected date.".localized()
        static var networkErrorMessage = "Make sure your device is connected to the internet.".localized()
        static var editAlertEmptyNameMessage = "Valid alert Name required.".localized()
        static var editAlertEmptyWidowStartDateMessage = "Please select window start date. ".localized()
        static var editAlertEmptyWidowEndDateMessage = "Please select window End date. ".localized()
        static var editAlertdetinationrequiredMessage = "Please select at least one destination or resort. ".localized()
        static var editAlertdetinationMessage = "Select at least one Destination".localized()
        static var maximumLimitReachedMessage = "Maximum limit reached".localized()
        static var bedroomSizeAlertMessage = "Please select at least one master or lock-off portion. ".localized()
        static var feesAlertMessage = "Slide to agree to fees. ".localized()
        static var insuranceSelectionMessage = "Select trip protection or choose \("\"No I decline coverage.\"")".localized()
        static var paymentSelectionMessage = "Please select any payment method. ".localized()
        static var promotionsMessage = "Please select any promotions. ".localized()
        static var feesPaymentMessage = "I acknowledge and agree that the mandatory resort fees will be payable to the resort. Fees are per person and per day".localized()
        static var agreeToFeesMessage = "Agreed to Fees".localized()
        static var termsConditionMessage = "I have read and accepted the Terms and Conditions and Privacy Policy".localized()
        static var agreePayMessage = "Slide to Agree and Pay".localized()
        static var operationFailedMessage =  "Unable to perform back button operatin due to server error, Try again!".localized()
        static var availablePointToolDefaultSelectedDateAlert =  "if no date is selected the Available Points Balance displayed is based on today's date.".localized()
        static var holdingTimeLostTitle = "Holding time lost".localized()
        static var holdingTimeLostMessage = "Oops You have lost your holding time for this resort!.".localized()
        static var searchVacationTitle = "Search Vacation".localized()
        static var searchVacationMessage = "Please select any destination or resort".localized()
        static var travellingDetailMessage = "Traveling: Tue Oct 15, 2015 - Sun May 20, 2018".localized()
        static var vacationSearchMessage = "We were unable to find any availability for the travel dates you requested. Please check other available dates by scrolling above.".localized()
        static var vactionSearchDateMessage = "No match found. Please select another date.".localized()
        static var userInterestMessage = "How's about you go favorite some resorts and when you come back they will be here all warm and toasty waiting for you!".localized()
        static var goGetMessage = "Go on Get! ".localized()
        static var noDatesMessage = "No Dates availabel".localized()
        static var tradeItemMessage = "Add items to \("What do you want to trade?") section".localized()
    }
    
    //***** common  structure to provide alert promt button titles *****//
    struct AlertPromtMessages {
        
        static var ok = "Ok".localized()
        static var close = "Close".localized()
        static var newSearch = " Go Start A New Getaway Search!".localized()
        static var cancel = "Cancel".localized()
        static var done = "Done".localized()
        static var no = "No".localized()
        static var yes = "Yes".localized()
        static var aboutTouchId = "About Touch Id".localized()
        static var loginTitle = "Login".localized()
        static var createAlertTitle = "Create Alert".localized()
        static var editAlertTitle = "Edit Alert".localized()
        static var bedRoomSizeTitle = "BedRoom Sizes".localized()
        static var applyButtonTitle = "Apply".localized()
        static var failureTitle = "Failure".localized()
        static var noUpComingTrips = "No upcoming trips.".localized()
        static var membershipFailureMessage = "Please contact your servicing office.  Could not select membership".localized()
        static var upcomingTripMessage = "You have no upcoming trips at this time.".localized()
        static var upcomingTripSearchVacationButtonMessage = " Search for a Vacation".localized()
        
    }
    
    //***** Common structure to provide names for all notifications *****//
    
    struct notificationNames {
        
        static var getawayAlertsNotification = "reloadAlerts"
        static var magazineAlertNotification = "reloadMagazines"
        static var closeButtonClickedNotification = "closeButtonClicked"
        static var reloadFavoritesTabNotification = "reloadFavoritesTab"
        static var reloadMapNotification = "reloadMap"
        static var addMarkerWithRactangleRequestNotification = "addMarkerWithRactangleRequest"
        static var reloadVideosNotification = "reloadVideos"
        static var reloadMapForApply = "MapReload"
        static var refreshTableNotification = "refreshMyTableView"
        static var updateResortHoldingTime = "updateResortHoldingTime"
        static var enableGuestFormCheckout = "enableGuestFormCheckout"
        static var enableSaveUnitDetails = "enableSaveButtonUnitDetails"
        static var changeSliderStatus = "ChangeLabel"
        static var showHelp = "showHelp"
        static var showUnfavorite = "showUnFav"
        static var reloadTableNotification = "reloadTable"
        static var reloadRegionNotification = "reloadRegionTable"
        static var reloadTripDetailsNotification = "reloadDetails"
        
    }
    
    //***** common  structure to provide all dynamic controller button titles *****//
    struct buttonTitles {
        
        static var detail = "Detail".localized()
        static var nothingYet = "Nothing Yet".localized()
        static var add = "Add".localized()
        static var delete = "Delete".localized()
        static var searchOption = "Search Option".localized()
        static var sharingOption = "Sharing Option".localized()
        static var optionTitle = "Options".localized()
        static var viewMyRecentSearches = "View my recent searches".localized()
        static var shareViaEmail = "Share Via Email".localized()
        static var shareViaText = "Share Via Text".localized()
        static var resetMySearch =  "Reset my search".localized()
        static var help = "Help".localized()
        static var tweet = "Tweet".localized()
        static var facebook = "Facebook".localized()
        static var pinterest = "Pinterest".localized()
        static var cancel = "Cancel".localized()
        static var remove = "Remove".localized()
        static var edit = "Edit".localized()
        static var details = "Details".localized()
        static var activate = "Activate".localized()
        static var searchAllMyAlertsNow = "Search All My Alerts Now".localized()
        static var getwayAlertOptions = "Getaway Alerts Options".localized()
        static var aboutGetawayAlerts = "About Getaway Alerts".localized()
        static var select = "Select".localized()
        static var viewAllAlerts = "Edit Alerts".localized()
        static var viewAllTrips = "View All Trips".localized()
        static var searchVacation = "Search Vacations".localized()
        static var favoritesTitle = "Favorites".localized()
        static var resortTitle = "Resort Directory".localized()
        static var magazineTitle = "Magazines".localized()
        static var intervalHDTitle = "Interval HD".localized()
        static var joinTodayTitle = "Join Today".localized()
        static var privacyTitle = "Privacy/Legal".localized()
        static var resendTitle = "Resend Confirmation".localized()
        static var emailTripTitle = "Email Trip Details".localized()
        static var textTripTitle = "Text Trip Details".localized()
        static var purchaseInsuranceTitle = "Purchase Trip Protection".localized()
        static var viewResults = "View Results".localized()
        static var updateSwitchTitle = "Update email".localized()
    }
    
    //****common structure to provide all dynamic controller text field titles****//
    struct textFieldTitles {
        static var usernamePlaceholder = "Login ID".localized()
        static var passwordPlaceholder = "Password".localized()
        static var alertNamePlaceholder = "Name Your Getaway Alert".localized()
        static var guestFormFnamePlaceholder = "First Name".localized()
        static var guestFormLnamePlaceholder = "Last Name".localized()
        static var guestFormSelectCountryPlaceholder = "Select Country".localized()
        static var guestFormAddress1 = "Address 1".localized()
        static var guestFormAddress2 = "Address 2".localized()
        static var guestFormCity = "City".localized()
        static var guestFormSelectState = "Select State / Province".localized()
        static var guestFormPostalCode = "Zip / Postal Code".localized()
        static var guestFormEmail = "Email".localized()
        static var guestFormHomePhoneNumber = "Home Phone Number".localized()
        static var guestFormBusinessPhoneNumber = "Business Phone Number".localized()
        //card details
        static var nameOnCard = "Name on Card".localized()
        static var cardNumber = "Card Number".localized()
        static var type = "Type".localized()
        static var expirationDate = "Select Expiration Date".localized()
        static var cvv = NSLocalizedString("CVV", comment: "")
        static var expirationDatePlaceHolder = "MM/YY".localized()
        static var country = "Country".localized()
        //Ownership text field placeholder
        static var reservationNumber = "Reservation Number".localized()
        static var unitNumber = "Unit Number".localized()
        static var numberOfBedrooms = "Number of Bedrooms".localized()
        static var checkInDate = "Check-in Date".localized()
        //Payment selection view controller
        
    }
    
    //****common structure to provide all dynamic controller label titles****//
    struct labelTitles {
        static var enableTouchIDLabel = "Enable Touch Id".localized()
    }
    
    //***** common  structure to provide all side menu title name *****//
    struct sideMenuTitles {
        static var sideMenuInitialController = "RevialViewController"
        
        static var home = "Home".localized()
        static var searchVacation = "Search Vacation".localized()
        static var upcomingTrips = "Upcoming Trips".localized()
        static var getawayAlerts = "Getaway Alerts".localized()
        static var favorites = "Favorites".localized()
        static var ownershipUnits = "Ownership/Units".localized()
        static var resortDirectory = "Resort Directory".localized()
        static var intervalHD = "Interval HD".localized()
        static var magazines = "Magazines".localized()
        static var signOut = "Sign Out".localized()
        
    }
    
    //***** common  structure to provide all controller title string *****//
    struct ControllerTitles {
        
        static var privacyLegalViewController = "Privacy/Legal".localized()
        static var vacationSearchDestinationController = "Select Destinations or Resorts".localized()
        static var searchResultViewController = "Search Results".localized()
        static var availablePointToolViewController = "Available Point Tool".localized()
        static var floatDetailViewController = "Additional Unit Details".localized()
        static var clubresortsViewController = "Club Resorts".localized()
        static var bedroomSizeViewController = "Bedroom Size".localized()
        static var loginHelpViewController = "Login Help".localized()
        static var JoinTodayViewController = "Join_Today".localized()
        static var calendarViewController = "Pick Date".localized()
        static var accomodationCertsDetailController = "Accommodation Certificates".localized()
        static var bookYourSelectionController = "Choose What To Use".localized()
        static var vacationSearchTabBarController = "Vacation_Search".localized()
        static var dashboardTableViewController = "Home".localized()
        static var upComingTripDetailController = "Trip Details".localized()
        static var myUpcomingTripViewController = "My Upcoming Trips".localized()
        static var ownershipViewController = "My Ownership/Units".localized()
        static var memberShipViewController = "My Membership".localized()
        static var relinquishmentViewController = "Relinquishment Select".localized()
        static var resortDirectoryViewController = "Resort Directory".localized()
        static var favoritesViewController = "Favorites".localized()
        static var detailMapViewController = "Units Map".localized()
        static var getawayAlertsViewController = "Getaway Alerts".localized()
        static var creategetawayAlertsViewController = "Create a Getaway Alert".localized()
        static var editgetawayAlertsViewController = "Edit Getaway Alert".localized()
        static var intervalHDIpadControllerTitle = "Interval HD".localized()
        static var magazinesControllerTitle = "Magazines".localized()
        static var whoWillBeCheckingInControllerTitle = "Who will be checking-in?".localized()
        static var checkOutControllerTitle = "Check Out".localized()
        static var relinquishmentSelectiongControllerTitle = "Relinquishment Selection".localized()
        static var confirmationControllerTitle = "Confirmation".localized()
        static var intervalHDiPadControllerTitle =  "IntervalHDIpadPlayerViewController".localized()
        static var clubpointselection = "Club Point Selection".localized()
        static var selectedControllerTitle = ""
        static var sorting = "Sorting".localized()
        static var choosewhattouse = "Choose what to use".localized()
        static var flexChangeSearch = "Flexchange Search".localized()
         static var availableDestinations = "Available Destinations".localized()
    }
    
    //***** Common structure for custom cell identifiers ******//
    
    struct cellIdentifiers {
        static var clubPointCell = "cell1"
        static var checkBoxCell = "cell2"
        static var featuredCell = "FeaturedCell"
        static var checkCell = "CheckCell"
        static var headerCell = "HeaderCell"
        static var checkoutPromotionCell = "CheckoutPromotionCell"
    }
    
    //***** common  structure to provide all storyboard names *****//
    struct storyboardNames {
        
        static var vacationSearchDestinationControllerIPhoneStoryboard = "VacationSearchDestinationControllerIPhoneStoryboard"
        static var membershipIphone = "MembershipIphone"
        static var membershipIPad = "MembershipIPad"
        static var dashboardIPhone = "DashboardIPhone"
        static var dashboardIPad = "DashboardIPad"
        static var vacationSearchIphone = "VacationSearchIphone"
        static var vacationSearchIPad = "VacationSearchIpad"
        static var myUpcomingTripIphone = "MyUpcomingTripIphone"
        static var myUpcomingTripIpad = "MyUpcomingTripIpad"
        static var ownershipIphone = "OwnershipIphone"
        static var ownershipIpad = "OwnershipIpad"
        static var loginIPhone = "LoginIPhone"
        static var loginIPad = "LoginIPad"
        static var iphone = "Iphone"
        static var resortDirectoryIpad = "ResortDirectoryIPad"
        static var getawayAlertsIphone = "GetawayAlertsIphone"
        static var getawayAlertsIpad = "GetawayAlertsIpad"
        static var intervalHDIphone = "IntervalHDPhone"
        static var intervalHDIpad = "IntervalHDIpad"
        static var magazinesIphone = "Magazines"
        static var magazinesIpad = "MagazinesIpad"
        static var signInPreLoginController = "SignInPreLoginViewController"
        static var signInPreLoginViewControlleriPad = "SignInPreLoginViewControllerIPad"
        static var availableDestinationsIphone = "AvailableDestinationsIphone"
        
    }
    
    //***** common  structure to provide all segment control item  strings *****//
    struct segmentControlItems {
        static var selectedSearchSegment = "Exchange".localized()
        static var getaways = "Getaways".localized()
        static var exchange = "Exchange".localized()
        static var searchBoth = "Search Both".localized()
        static var flexchangeLabelText = "FLEXCHANGE".localized()
        static var getawaysLabelText = "TOP 10 GETAWAYS".localized()
        static var getawaysIpadText = "Top 10 Getaway Destinations".localized()
    }
    
    //***** common  structure to provide storyboard id  *****//
    struct storyboardControllerID {
        
        static var vacationSearchDestinationController = "VacationDestinationController"
        static var loginViewController = "LoginViewController"
        static var loginViewControllerIPad = "LoginIPadViewController"
        static var clubPointSelectionViewController = "ClubPointSelectionViewController"
        static var revialViewController = "RevialViewController"
        static var accomodationCertsDetailController = "AccomodationCertsDetailController"
        static var certificateTabBarViewController = "VacationSearchTabBarController"
        static var ownershipViewController = "OwnershipViewController"
        static var floatViewController = "FloatDetailViewController"
        static var resortDirectoryViewController = "ResortDirectoryViewController"
        static var webViewController = "WebViewController"
        static var calendarViewController = "CalendarViewController"
        static var bedroomSizeViewController = "BedroomSizeViewController"
        static var vacationSearchController = "SearchResultViewController"
        static var editMyAlertIpadViewController = "EditMyAlertIpadViewController"
        static var infoDetailViewController = "InfoDetailViewController"
        static var intervalHDPlayerViewController = "IntervalHDPlayerViewController"
        static var whoWillBeCheckingInViewController = "WhoWillBeCheckingInViewController"
        static var whoWillBeCheckingInIpadViewController = "WhoWillBeCheckingInIPadViewController"
        static var checkOutViewController = "CheckOutViewController"
        static var addDebitOrCreditCardViewController = "AddDebitOrCreditCardViewController"
        static var relinquishmentSelectionViewController = "RelinquishmentSelectionViewController"
        static var availablePointToolViewController = "AvailablePointToolViewController"
        static var clubPointViewController = "ClubPointPageItemViewController"
        static var clubPointsSelectionViewController = "clubpointselectionPageviewcontroller"
        static var upcomingTripsViewController = "UpComingTripDetailController"
        static var tripDetailsViewController = "TripDetailsNavigationController"
        static var createAlertViewController = "CreateAlertViewController"
        static var signInPreLoginViewController = "SignInPreLoginViewController"
        static var whatToUseViewController = "WhatToUseViewController"
        static var sortingViewController = "SortingViewController"
        static var flexChangeSearchIpadViewController = "FlexChangeSearchIpadViewController"
        static var flexchangeViewController = "FlexchangeViewController"
        static var RenewelViewController = "RenewelViewController"
        static var renewalOtherOptionsVC = "RenewalOtherOptionsVC"
        static var certificateDetailsViewController = "CertificateDetailsViewController"
        
    }
    
    //***** common  structure to provide all custom nib cell names *****//
    struct customCellNibNames {
        
        static var unitDetailCell = "UnitDetailCell"
        static var guestCertificateCell = "GuestCertificateCell"
        static var paymentCell = "PaymentCell"
        static var policyCell = "PolicyCell"
        static var memberCell = "MemberCell"
        static var sideMenuBackgroundTableCell = "SideMenuBackgroundTableCell"
        static var actionSheetTblCell = "ActionSheetTblCell"
        static var whoIsTravelingCell = "WhoIsTravelingCell"
        static var searchResultCollectionCell = "SearchResultCollectionCell"
        static var searchResultContentTableCell = "SearchResultContentTableCell"
        static var relinquishmentDetailsCell = "RelinquishmentDetailsCell"
        static var moreSearchResult = "MoreCollectionCell"
        static var whereToGoTableViewCell = "WereToGo"
        static var wereToGoTableViewCell = "wereToGo"
        static var whereToTradeTableViewCell = "WereToTrade"
        static var searchTableViewCell = "SearchCell"
        static var dateAndPassengerTableViewCell = "DateAndPassenger"
        static var featuredTableViewCell = "FeaturedTableCell"
        static var resortDetailCell = "ResortCell"
        static var actionSheetMemberShipCell = "ActionSheetMemberShipCell"
        static var totalCostCell = "TotalCostCell"
        static var promotionsDiscountCell = "PromotionsDiscountCell"
        static var exchangeOrProtectionCell = "ExchangeOrProtectionCell"
        static var slideAgreeButtonCell = "SlideAgreeButtonCell"
        static var flexchangeCell = "FlexchangeCell"
        static var upComingTripsCell = "UpComingTripsCell"
        static var upcomingCell = "UpComingCell"
        static var vacationCell = "VacationCell"
        static var upcomingTrip = "UpcomingTrip"
        static var clubPointsCell = "ClubPoints"
        static var headerCell = "HeaderCollectionCell"
        static var checkCell = "CheckCollectionCell"
    }
    
    //***** common  structure to provide all upComingTripDetailControllerReusableIdentifiers *****//
    struct upComingTripDetailControllerReusableIdentifiers {
        
        static var unitDetailCell = "UnitDetailCell"
        static var customTableViewCell = "CustomTableViewCell"
        static var paymentDetailCell = "PaymentCell"
        static var policyCell = "PolicyCell"
        static var paymentDetailsCell = "PaymentDetailsCell"
        static var insuranceCell = "EplusTableViewCell"
        static var modifyInsuranceCell = "ModifyTripInsurance"
        static var purchasedInsuranceCell = "PurchasedTripInsurence"
        static var upComingTripCell = "UpComingTripCell"
        static var emptyUpcomingTrip = "EmptyUpcomingTrip"
        static var guestCertificateCell = "GuestCertificateCell"
        static var resortCell = "Deposit"
        static var unitCell = "RelinquishmentUnitCell"
        static var clubCell = "ClubPointCell"
        static var pointsProgramCell = "PointsProgramCell"
        static var accomodationCell = "AccomodationCell"
        static var transactionDetailsCell = "TransactionDetailsTableViewCell"
        static var outHeadingString = "Return Date:"
        static var inHeadingString = "Sailing Date:"
        static var bottomCell = "BottomCell"
        static var exchangeDetails = ExchangeDetails()
    }
    
    //***** Common  structure to provide all destination Resort ViewController CellIdentifiers And HardCoded Strings *****//
    struct destinationResortViewControllerCellIdentifiersAndHardCodedStrings {
        
        static var unitsDetailCell = "UnitsDetailCell"
        static var textUnitDetails = "Unit Details"
        static var textAdditionalAdvisements = "Additional Advisements"
        static var amenitiesCell = "AmenitiesCell"
        static var advisementCell = "AdvisementCell"
        static var unitDetailsCell1 = "UnitDetails"
        static var dateCell = "DateCell"
        static var additionalAdvisementCell = "AdditionalAdvisementCell"
      
    }
    
    //***** common  structure to provide all Payment Selection View Controller CellIdentifiers And HardCoded Strings *****//
    struct PaymentSelectionControllerCellIdentifiersAndHardCodedStrings {
        
        static var cvvAlertTitle = "Please enter the credit card CVV code".localized()
        static var cvvandExpiryDateAlertTitle = "Your card is expired. Please enter your credit card CVV code and the new expiration date.".localized()
    }
    
    //***** common  structure to provide all CheckOut IPad View Controller CellIdentifiers And HardCoded Strings *****//
    struct CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings {
        
        static var headerCell = "HeaderCell"
        static var agreeToFeesCell = "AgreeToFeesCell"
        static var acceptedTermAndConditionString = "I have read and accepted the Terms and Conditions and Privacy Policy".localized()
        static var acknowledgeAndAgreeString = "I acknowledge and agree that the Mandatory Resort Fees will be payable to the resort.".localized()
        static var agreedToFeesString = "Agreed to Fees".localized()
        static var slideToAgreeToFeesString = "Slide to agree to Fees".localized()
        static var slideToAgreeAndPayString = "Slide to Agree and Pay".localized()
        static var selectYourPaymentMethodString = "Select your payment method".localized()
        static var paymentMethodLabelString = "Payment Method".localized()
        static var additionalAdvisementLabelString = "Additional Advisements".localized()
        static var additionalAdvisementTitle = "ADDITIONAL INFORMATION".localized()
        
    }
    
    //***** common  structure to provide all  Who Will Be CheckingIn View Controller CellIdentifiers And HardCoded Strings *****//
    struct  WhoWillBeCheckingInViewControllerCellIdentifiersAndHardCodedStrings {
        
        static var cvvAlertTitle = NSLocalizedString("Please enter the credit card CVV code", comment: "")
        static var noneOfAboveContactString = NSLocalizedString("None of the above", comment: "")
        static var contactListHeaderString = NSLocalizedString("From the list below, who on your  membership might be checking-in?", comment: "")
        
    }
    
    //***** common  structure to provide all loginScreenReusableIdentifiers *****//
    struct loginScreenReusableIdentifiers {
        
        static var headerCell = "LogoCell"
        static var logoFormCell = "loginFormCell"
        static var cell = "Cell"
        static var CustomCell = "CustomCell"
        static var menuCell = "menuCell"
        static var memberCell = "MemberCell"
        static var policyListTBLCell = "PolicyListTBLCell"
        static var resortDirectoryTBLCell = "ResortDirectoryTBLCell"
        static var resortDirectoryResortCell = "ResortDirectoryResortCell"
        static var actionSheetMemberShipCell = "ActionSheetMemberShipCell"
        static var mapTableViewCell = "MapCell"
        static var resortInfoTableCell = "ResortInfoCell"
        static var vacationSearchCell = "SearchCell"
        
    }
    
    //*****Common cell reusable identifiers *****//
    struct reUsableIdentifiers {
        
        static var favoritesCellIdentifier = "ResortFavoritesCell"
        static var advisementsCellIdentifier = "AdditionalAdvCell"
        static var clubHeaderCell = "HeaderCell"
        static var checkBoxCell = "CheckCell"
        static var attributesCell = "attributesTableCell"
        static var buttonCell = "ButtonTableCell"
        static var resortDetailCell = "ImageCell"
        static var searchBothInventoryCell = "SearchBothInventory"
        static var resortInventoryCell = "RentalInventory"
        static var exchangeInventoryCell = "ExchangeInventory"
        static var availabilityCell = "AvailbilityCell"
        static var novailabilityCell = "noAvailbilityCell"
    }
    
    //***** common  structure to provide all dashboardTableViewControllerHeaderText *****//
    struct dashboardTableViewControllerHeaderText {
        
        static var gatewayAlerts = "Getaway Alerts".localized()
        static var myUpcomingTrips = "My Upcoming Trips".localized()
        static var planVacation = "Plan a Vacation".localized()
        
    }
    
    //***** common  structure to provide all dashboardTableScreenReusableIdentifiers *****//
    struct dashboardTableScreenReusableIdentifiers {
        
        static var headerCell = "HeaderCell"
        static var cellIdentifier = "CellIdentifier"
        static var sectionCell = "SectionCell"
        static var secCell = "SecCell"
        static var cell = "Cell"
        static var memberCell = "MemberCell"
        static var reuseIdentifier = "ReuseIdentifier"
        
        static var alert = "Alert"
        static var upcoming = "Upcoming"
        static var search = "Search"
        static var exchange = "Exchange"
        static var getaway = "Getaways"

    }
    
    //***** common  structure to provide all IntervalHDReusableIdentifiers *****//
    struct IntervalHDReusableIdentifiers {
        
        static var videoTBLCell = "VideoTBLCell"
        static var intervalHDCollectionViewCell = "IntervalHDCollectionViewCell"
        static var magazinesCell = "MagazineCell"
        
    }
    
    //***** common  structure to provide all detailScreenReusableIdentifiers *****//
    struct detailScreenReusableIdentifiers {
        
        static var detailcell = "detailcell"
    }
    
    //**** common structure to provide all getawayScreenReusableIdentifiers *****//
    struct getawayScreenReusableIdentifiers {
        
        static var getawayAlertCell = "AlertCell"
    }
    
    //***** common  structure to provide all certificateScreenReusableIdentifiers *****//
    struct certificateScreenReusableIdentifiers {
        
        static var certificateCell = "CertificateCell"
        static var certificateDetailsCell = "CertificateDetailsCell"
        
    }
    
    //***** common  structure to provide all vacationSearchScreenReusableIdentifiers *****//
    struct vacationSearchScreenReusableIdentifiers {
        
        static var whereToGoContentCell = "WhereToGoContentCell"
        static var caledarDateCell = "CaledarDateCell"
        static var whoIsTravelingCell = "WhoIsTravelingCell"
        static var SearchVacationCell = "SearchVacationCell"
        static var relinquishmentSelectionOpenWeeksCell = "RelinquishmentSelectionOpenWeeksCell"
        static var floatWeekUnsavedCell = "FloatUnsavedCell"
        static var floatWeekSavedCell = "FloatSavedCell"
        static var relinquishmentSelectionCIGCell = "RelinquishmentSelectionCIGCell"
        static var destinationCell = "destinationCell"
        static var resortCell = "resortsCell"
        static var resortBedroomDetails = "ResortBedroomDetails"
        static var resortBedroomDetailwithInfo = "ResortBedroomDetailWithInfoCell"
        static var resortBedroomDetailexchange = "ResortBedroomDetailExchangeCell"
        static var relinquishmentForExchange = "RelinquishmentForExchange"
        static var travelWindowSelectionCell = "TravelWindowSelectionCell"
        static var eligibleDestinationCell = "EligibleDestinationCell"
        static var destinationResortDetailCell = "DestinationResortDetailCell"
        static var exchangeCell0 = "ExchangeCell0"
        static var exchangeCell1 = "ExchangeCell1"
        static var exchangeCell2 = "ExchangeCell2"
        static var getawaysCell  = "GetawaysCell"
        static var moreCell = "MoreCell"
        static var searchResultDateCell = "SearchResultDateCell"
        static var imageWithNameCell = "ImageWithNameCell"
        static var getawayCell = "GetawayCell"
        static var relinquishmentCell = "RelinquishCell"
        static var goldPointsCell = "GoldPoints"
        static var actionSheetCell = "ActionSheetCell"
        static var ratingCell = "RatingCell"
        static var tdiCell = "TDICell"
        static var destinationReusableCell = "DestCellIdentifier"
        static var viewDetailsTBLcell = "ViewDetailsTBLcell"
        static var checkingInUserListTBLcell = "CheckingInUserListTBLcell"
        static var guestTextFieldCell = "GuestTextFieldCell"
        static var dropDownListCell = "DropDownListCell"
        static var guestCertificatePriceCell = "GuestCertificatePriceCell"
        static var advisementsCell = "AdvisementsCell"
        static var promotionsCell = "PromotionsCell"
        static var exchangeOptionsCell = "ExchangeOptionsCell"
        static var additionalAdvisementCell = "AdditionalAdvisementCell"
        static var selectPaymentMethodCell = "SelectPaymentMethodCell"
        static var addNewCreditCardCell = "AddNewCreditCardCell"
        static var slideAgreeButtonCell = "SlideAgreeButtonCell"
        static var addYourCardButtonCell = "AddYourCardButtonCell"
        static var saveCardOptionCell = "SaveCardOptionCell"
        static var tripProtectionCell = "TripProtectionCell"
        static var emailCell = "EmailCell"
        static var agreeToFeesCell = "AgreeToFeesCell"
        static var bookingCell = "BookingCostCell"
        static var exchangeCell = "ExchangeCell"
        static var insuranceCell = "InsuranceCell"
        static var discountCell = "DiscountCell"
        static var termsConditionsCell = "TermsAndConditionsCell"
        static var checkOutCell = "CheckoutCell"
        static var clubPointCell = "ClubPointCell"
        static var tdiCollectionViewCell = "TdiCollectionViewCell"
        static var unitSizeTdiCollectionViewCell = "UnitSizeTdiCollectionViewCell"
        static var tdiTableViewCell = "TdiTableViewCell"
        static var exchange = "Exchange"
        static var sortingOptionCell = "sortingOptionCell"
        static var filterOptionCell = "filterOptionCell"
        static var areaCell = "areaCell"
        static var regionCell = "regionCell"
        static var whereToGoCell = "WhereToGoCell"
        static var availablePoints = "AvailablePoints"
        static var selectedResortsCell = "selectedResortsCell"
        static var renewelCell = "renewelCell"
        static var renewalAdditionalCell = "renewalAdditionalCell"
        static var flexChangeDestinationCell = "FlexchangeDestinationCell"
        static var flexchangeSearchButtonCell = "FlexchangeSearchButtonCell"
        
    }
    
    //***** Common structure for dynamic strings combinining strings *****//
    
    struct getDynamicString {
         static var clubInterValPointsUpTo = "Club Interval Gold Points up to".localized()
         static var andString = "and".localized()
        static var moreString = "more".localized()
        static var fromString = "From ".localized()
        static var weekString = " Wk.".localized()
    }
    
    //***** Common structure for font names and type *****//
    
    struct fontName {
        
        static var helveticaNeue = "HelveticaNeue"
        static var helveticaNeueMedium = "HelveticaNeue-Medium"
        static var helveticaNeueBold = "Helvetica-Bold"
    }
    
    //***** common  structure to provide all enableTouchId messages and titles *****//
    struct enableTouchIdMessages {
        
        static var reasonString = "Authentication is needed to login.".localized()
        static var authenticationFailedTitle = "Enable Touch ID".localized()
        static var authenticationFailedMessage = "There was a problem verifying your identity.".localized()
        static var systemCancelMessage = "Authentication was cancelled by the system.".localized()
        static var defaultMessage = "Touch Id can not be configured ".localized()
        static var otherMessage = "There is no touch id feature exist.".localized()
        static var onSuccessMessage = "Please login with your Login ID and \n Password in order to activate Touch Id".localized()
        static var onTouchCancelMessage = "Touch Id was canceled\n Login with your Login ID and Password".localized()
    }
    
    //***** common  structure to provide all segue identifiers *****//
    struct segueIdentifiers {
        
        static var dashboradSegueIdentifier = "dashboardSegue"
        static var CalendarViewSegue = "CalendarViewSegue"
        static var detailDestinationSegue = "DetailDestinationSegue"
        static var privacyPolicyWebviewSegue = "privacyPolicySegue"
        static var searchResultSegue = "SearchResultSegue"
        static var webViewSegue = "webviewSegue"
        static var relinquishmentSegue = "RelinquishmentSegue"
        static var resortDirectorySegue = "resortDirectorySegue"
        static var subRegionSegue = "subRegionSegue"
        static var areaSegue = "areaSegue"
        static var resortByAreaSegue = "resortByAreaSegue"
        static var segueSignInForPreLogin = "segueSignInForPreLogin"
        static var preLoginSegue = "preLoginSegue"
        static var resortDetailsSegue = "detailsSegue"
        static var vacationSearchDetailSegue = "vacationSearchDetailSegue"
        static var detailMapSegue = "detailMapSegue"
        static var editAlertSegue = "editAlertSegue"
        static var createAlertSegue = "createAlertSegue"
        static var intervalHDSegue = "intervalHDSegue"
        static var intervalHDIpadSegue = "intervalHDIpadSegue"
        static var magazinesSegue = "magazinesSegue"
        static var magazinesIpadSegue = "magazinesIpadSegue"
        static var showIssueSegue = "showIssueSegue"
        static var confirmationViewTripSegue = "confirmationViewTripSegue"
        static var whoWillBeCheckingInSegue = "whoWillBeCheckingInSegue"
        static var checkoutScreenSegue = "checkoutScreenSegue"
        static var confirmationScreenSegue = "confirmationSegue"
        static var selectPaymentMethodSegue = "selectPaymentSegue"
        static var showResortDetailsSegue = "showResortDetails"
        static var showRelinguishmentsDetailsSegue = "showRelinguishmentsDetails"
        static var showRenewelSegue = "RenewelSegue"

        static var confirmationUpcomingTripSegue = "confirmationUpcomingTripSegue"
        static var newCreditCardSegue = "newCreditCardSegue"
        static var PolicyWebviewSegue = "privacyPolicyWebviewSegue"
        static var detailSegue = "detailSegue"
        static var searchVacation = "searchVacation"
        static var upcomingDetailSegue = "UpComingTripDetailSegue"
        static var searchResultMapSegue = "searchResultMapSegue"
        static var sortingSegue = "sortingSegue"
        static var whatToUseSegue = "whatToUse"
        static var bookingSelectionSegue = "BookYourSelectionSegue"
        static var chooseWhatToUse = "ChooseWhatToUse"
        static var showSelectedResortsIpad = "showSelectedResorts"
        static var allAvailableDestinations = "allAvailableDestination"
    }
    
    //***** common  structure to provide all actionSheetAttributedString *****//
    struct actionSheetAttributedString {
        
        static var selectMembership = "Choose Membership".localized()
        static var sharingOptions = "Sharing Options".localized()
        static var noMatches = "No matches right now".localized()
        static var attributedTitle = "attributedTitle"
        static var contentViewController = "contentViewController"
    }
    
    //***** common  structure to provide all assetImageNames *****//
    struct assetImageNames {
        static var TouchIdOn = "TouchID-On"
        static var TouchIdOff = "TouchID-Off"
        static var backArrowNav = "BackArrowNav"
        static var ic_menu = "ic_menu"
        static var MoreNav = "MoreNav"
        static var member = "Member"
        static var home = "Home"
        static var searchVacation = "Search"
        static var upcomingTrips = "Trips"
        static var getawayAlerts = "Alerts"
        static var favorites = "Favorites"
        static var ownershipUnits = "Ownership"
        static var resortDirectory = "Directory"
        static var intervalHD = "IntHD"
        static var magazines = "Magazines"
        static var signOut = "Sign Out"
        static let dropArrow  = "DropArrowIcon"
        static let backArrowBlue = "BackArrowNav-Blue"
        static var pinActiveImage = "PinActive"
        static var pinFocusImage = "PinFocus"
        static var upArrowImage = "up_arrow_icon"
        static var optOffImage = "Opt-Off"
        static var optOnImage = "Opt-On"
        static var favoritesOffImage = "FavoriteIcon-Off"
        static var favoritesOnImage = "FavoriteIcon-On"
        static var pinSelectedImage = "PinSelected"
        static var forwardArrowIcon = "ForwardArrowIcon"
        static var americanExpressCardImage = "AmericanExpress_CO"
        static var dinersClubCardImage = "DinersClub_CO"
        static var discoverCardImage = "Discover_CO"
        static var masterCardImage = "MasterCard_CO"
        static var visaCardImage = "Visa_CO"
        static var swipeArrowOrgImage = "SwipeArrow_ORG"
        static var swipeArrowGryImage = "SwipeArrow_GRY"
        static var resortImage = "RST_CO"
        static var exchangeImage = "EPlus"
        static var checkMarkOn = "Checkmark-On"
        static var plusIcon = "PlusIcon"
        static var infoImage = "InfoIcon"
        static var relinquishmentImage = "EXG_CO"
        static var promoImage = "PromoImage"
        static var refreshAlert = "ic_refresh"
    }
    
    //***** Bedroom ViewController *****//
    struct bedroomSizeViewController {
        static let bedroomsizeCellIdentifier = "bedroomsizeCell"
        static var doneButtonCellIdentifier = "doneButtonCell"
    }
    //***** AvailablePointToolViewController *****//
    struct availablePointToolViewController {
        static let pointToolDetailpointcellIdentifier = "pointToolDetailpoint"
        static var notesCell = "NotesCell"
        static var availablePointCell = "AvailablePointCell"
        static var headerCell = "HeaderCell"
        static let depositedpointhistorycellIdentifier = "DepositedPointHistoryTableViewCell"
        static let depositedPointHistoryinformationLabelText = "  Deposited Point History"
        static let pointsInformationLabelText = "Points:".localized()
        static let expirationdateInformationLabelText = "Expiration Date:".localized()
        static let pointsearnedByInformationLabelText = "Points Earned by:".localized()
        static let availablePointsinformationLabelText = "Available Points".localized()
        static let pointbalanceInformationlableText = "if no date is selected the Available Points Balance displayed is based on today's date.".localized()
        static let donebuttoncellIdentifier = "donebuttoncell"
        struct availablePointsAsOfTableViewCell {
            static let pointasOflabelText = "Points as of:".localized()
        }
        
    }
    //***** ClubResortViewController *****//
    struct clubresortsViewController {
        static let clubresortcellIdentifier = "clubresortcell"
    }
    //***** FloatDetailViewController *****//
    struct floatDetailViewController {
        static let resortcallidentifer = "resortcallidentifer"
        static let vacationdetailcellIdentifier = "vacationdetail"
        static let selectclubcellIdentifier = "selectclubcell"
        static let registrationNumbercellIdentifier = "registrationNumbercell"
        static let unitnumberandbedroomdetailcellIdentifier = "unitnumberandbedroomdetailcell"
        static let checkindatecellIdentifier = "checkindatecell"
        static let saveandcancelcellIdentifier = "saveandcancelcell"
        static let clubresortviewcontrollerIdentifier = "clubresortviewcontroller"
        
        struct callYourResortTableViewCell {
            static let callresortbuttonTitle = "Call your resort".localized()
            static let donothaveresortLabelText = "Don't have your \n resort details?".localized()
        }
        
        //FloatDetailsCheckIndateTableViewCell
        struct floatDetailsCheckIndateTableViewCell {
            static let checkInDateInformationLabelText = "Check in date".localized()
        }
        //FloatSaveAndCancelButtonTableViewCell
        struct floatSaveAndCancelButtonTableViewCell {
            static let saveFloatDetailButtonTitle = "Save Unit Details".localized()
        }
    }
    //***** OwnershipViewController *****//
    struct ownershipViewController {
        static let myownershipAvailablepointTableViewCellIdentifier = "myownershipavailablepointcell"
        static let myownershipclubintervalgoldpointdetailcellIdentifier = "myownershipclubintervalgoldpointdetailcell"
        static let myownershipVacationResortcellIdentifier = "myownershipVacationResortcell"
        static let ownershipdetailcellIdentifier = "ownershipdetailscell"
        static let ownershipclubpointIdentifier = "ownershipclubpoint"
        static let ownershipdetailwithfreedepositIdentifier = "ownershipdetailwithfreedeposit"
        static let ownershipwithdepositeinformationIdentifier = "ownershipwithdepositeinformation"
        static let ownershipfloatIdentifier = "ownershipfloat"
        static let floatdetailViewControllerIdentifier = "FloatDetailViewController"
        static let clubIntervalGoldWeeksSectionHeaderTitle = "Club Interval Gold Weeks"
        static let clubPointsSectionHeaderTitle = "Club Points"
        static let intervalWeeksSectionHeaderTitle = "Interval Weeks"
        
        static let vacationForSearchTitle = "Search \n for a \n Vacation"
        //ClubIntervalGoldPointTableViewCell
        struct  clubIntervalGoldPointTableViewCell {
            static let clubIntervalGoldpointLabelText = "Club Interval Gold points"
            static let availablePointsToolbuttonTitle = "Avalable Points Tool"
            
        }
        //AvailablePointTableViewCell
        struct clubIntervalAvailableGoldPointTableViewCell {
            static let availabelinfoLabeltext = "Availabel"
            static let pointsinfoLabelText = "Club Interval Gold Points"
            static let asOfPointsinfoLabelText = "Available Points as of Today"
        }
        //ClubpointTableViewCell
        struct clubpointTableViewCell {
            static let clubInfoLabeltext = "Club"
            static let pointInfoLabelText = "Points"
        }
    
        //OwnershipDetailWithFreeDepositTableViewCell
        struct ownershipDetailWithFreeDepositTableViewCell {
            static let depositForFreeButtonTitle = "Deposit for a free \n Exchange"
        }
        //OwnershipDetailWithDepositinformationTableViewCell
        struct ownershipDetailWithDepositinformationTableViewCell {
            static let depositedInfoLabelText = "Deposited"
            
        }
        //OwnershipFloatTableViewCell
        struct ownershipFloatTableViewCell {
            static let floatInfoLabelText = "Float"
        }
        
    }
    //***** MemberShipViewController *****//
    struct memberShipViewController {
        static let ownershipDetailCellIdentifier = "ownershipDetailCell"
        static let membershipDetailCellIdentifier = "membershipDetailCell"
        static let ownershipHeaderTitletext = "Ownerships".localized()
        static let switchMembershipAlertMessage = "You have chosen to use a different membership account. Please note, benefit and exchange access may change. Would you like to continue?".localized()
        static let switchMembershipAlertTitle = "You are Switchinig Memberships".localized()
        //membershipDetailTableViewCell
        struct membershipDetailTableViewCell {
            static let contactnameInfoLabelText = "Contact Name"
            static let activeLabelText = "Active"
            static let loginInfoLabelText = "Login ID"
            static let emailInfoLabelText = "Email"
            static let memberNumberInfoLabelText = "Member Number"
            static let memberSinceInfoLabelText = "Member Since"
            static let membershipInfoLabelText = "Interval Membership"
            
            static let memberCardInfoLabelText = "Interval Membership"
            static let switchMembershipButtonTitle = "Switch Membership"
            static let placeCode = "placecode"
            static let placeAddress = "placeaddress"
            static let placeName = "placename"
            static let bedroomDetail = "bedroomdetail"
            static let weekNumber = "weeknumber"
            
        }
        //ownerShipDetailTableViewCell
        struct ownerShipDetailTableViewCell {
            
            static let unitdetailLabelText = "Unit"
            static let weekDetailLabelText = "Week"
            
        }
        
    }
    
    struct myUpcomingTripCommonString {
        
        static let rental = "RENTAL"
        static let getaway = "GETAWAY"
        static let shop = "SHOP"
        static let exchange = "Exchange"
    }
    
    //***** Availabel Destination viewcontroller *****//
    struct availableDestinationsTableViewController {
        static let availableDestinationCountryOrContinentsTableViewCell = "continentsorcountrycell"
        static let availableDestinationPlaceTableViewCell = "placecell"
    }
    //Properties of View
    struct viewProperties {
        static let cornerRadious: CGFloat = 3
    }
    struct roomType {
        static let studio = "0BR"
        static let oneBedRoom = "1BR"
        static let twoBedRoom = "2BR"
        static let threeBedRoom = "3BR"
        static let fourBedRoom = "4BR"
        static let unKnown = "UnKnown"
    }
    struct kitchenType {
        static let noKitchen = "No Kitchen"
        static let limitedKitchen = "Limited Kitchen"
        static let fullKitchen = "Full Kitchen"
        static let unKnown = "UnKnown"
    }
    
    static func startTimer() {
        
        self.holdingTime = 17
        self.holdingTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateResortHoldingTimeLabel), userInfo: nil, repeats: true)
    }
    
    static func updateResortHoldingTimeLabel() {
        holdingTime = holdingTime - decreaseValue
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    static func getPointWeek(weektype: String) -> String {
        
        return "Point Week"
    }
    
    static func getFlotWeek(weekType: String) -> String {
        
        return "Float Week"
    }
    
    static func  getWeekNumber(weekType: String) -> String {
        
        switch weekType {
            
        case "FIXED_WEEK_1":
            return "1"
            
        case "FIXED_WEEK_2":
            return "2"
            
        case "FIXED_WEEK_3":
            return "3"
            
        case "FIXED_WEEK_4":
            return "4"
            
        case "FIXED_WEEK_5":
            return "5"
            
        case "FIXED_WEEK_6":
            return "6"
            
        case "FIXED_WEEK_7":
            return "7"
            
        case "FIXED_WEEK_8":
            return "8"
            
        case "FIXED_WEEK_9":
            return "9"
            
        case "FIXED_WEEK_10":
            return "10"
            
        case "FIXED_WEEK_11":
            return "11"
            
        case "FIXED_WEEK_12":
            return "12"
            
        case "FIXED_WEEK_13":
            return "13"
            
        case "FIXED_WEEK_14":
            return "14"
            
        case "FIXED_WEEK_15":
            return "15"
            
        case "FIXED_WEEK_16":
            return "16"
            
        case "FIXED_WEEK_17":
            return "17"
            
        case "FIXED_WEEK_18":
            return "18"
            
        case "FIXED_WEEK_19":
            return "19"
            
        case "FIXED_WEEK_20":
            return "20"
            
        case "FIXED_WEEK_21":
            return "21"
            
        case "FIXED_WEEK_22":
            return "22"
            
        case "FIXED_WEEK_23":
            return "23"
            
        case "FIXED_WEEK_24":
            return "24"
            
        case "FIXED_WEEK_25":
            return "25"
            
        case "FIXED_WEEK_26":
            return "26"
            
        case "FIXED_WEEK_27":
            return "27"
            
        case "FIXED_WEEK_28":
            return "28"
            
        case "FIXED_WEEK_29":
            return "29"
            
        case "FIXED_WEEK_30":
            return "30"
            
        case "FIXED_WEEK_31":
            return "31"
            
        case "FIXED_WEEK_32":
            return "32"
            
        case "FIXED_WEEK_33":
            return "33"
            
        case "FIXED_WEEK_34":
            return "34"
            
        case "FIXED_WEEK_35":
            return "35"
            
        case "FIXED_WEEK_36":
            return "36"
            
        case "FIXED_WEEK_37":
            return "37"
            
        case "FIXED_WEEK_38":
            return "38"
            
        case "FIXED_WEEK_39":
            return "39"
            
        case "FIXED_WEEK_40":
            return "40"
            
        case "FIXED_WEEK_41":
            return "41"
            
        case "FIXED_WEEK_42":
            return "42"
            
        case "FIXED_WEEK_43":
            return "43"
            
        case "FIXED_WEEK_44":
            return "44"
            
        case "FIXED_WEEK_45":
            return "45"
            
        case "FIXED_WEEK_46":
            return "46"
            
        case "FIXED_WEEK_47":
            return "47"
            
        case "FIXED_WEEK_48":
            return "48"
            
        case "FIXED_WEEK_49":
            return "49"
            
        case "FIXED_WEEK_50":
            return "50"
            
        case "FIXED_WEEK_51":
            return "51"
            
        case "FIXED_WEEK_52":
            return "52"
            
        case "FIXED_WEEK_53":
            return "53"
            
        default:
            return  ""
        }
    }
    
    struct omnitureCommonString {
        
        static var signIn = "Sign In"
        static var signInPage = "Sign In Page"
        static var signInModal = "Sign-In Modal"
        static var enableTouchId = "Enable Touch ID"
        static var preloginChooseMemberShip = "Pre-Login Choose Membership"
        static var vactionSearch = "Vacation Search"
        static var allDestination = "All Destination"
        static var typedSelection = "Typed Selection"
        static var mapSelection = "Map Selection"
        static var listItem = "s.list1"
        static var alert = "Alerts"
        static var primarySearchDateAvailable = "Primary – Search Date Available"
        static var primaryAlternateDateAvailable = "Primary – Alternative Date Available"
        static var primaryAndAoiSearchDateAvailable = "Primary & AOI – Search Date Available"
        static var primaryAndAoiAlternateDateAvailable = "Primary & AOI – Alternative Date Available "
        static var aoiOnlySearchDateAvailable = "AOI Only – Search Date Available"
        static var aoiOnlyAlternateDateAvailable = "AOI Only – Alternative Date Available"
        static var noAvailability = "No Availability"
        static var productItem = "s.products"
        static var vacationSearchCheckingIn = "Vacation search - Checking In"
        static var products = "Products"
        static var vacationSearchPaymentInformation = "Vacation Search - Payment Information"
        static var vacationSearchRelinquishmentSelect = "Vacation Search - Relinquishment Select"
        static var vacationSearch = "Vacation Search"
        static var available = "Available"
        static var notAvailable = "Not Available"
        static var clubPointsSelection = "Club Points Selection"
        static var simpleLockOffUnitOptions = "Simple Lock-Off Unit Options"
        static var noTrips = "NO Trips"
        static var sideMenu = "Side Menu"
        static var homeDashboard = "Home Dashboard"
        static var cigPoints = "CIGPoints"
        static var clubPoints = "ClubPoints"
        static var confirmation = "Vacation Search – Transaction Completed"
        static var exchage = "EX"
        static var getaway = "GW"
        static var acomodationCertificate = "AC"
        static var shortStay = "SS"
        static var flightBooking = "FB"
        static var toorBooking = "TB"
        static var carRental = "CR"
        static var notApplicable = "NA"
        static var resortDirectoryHome = "Resort Directory Home"
        static var createAnAlert = "Create an Alert"
        static var editAnAlert = "Edit an Alert"
        static var sideMenuAppeared = "Side Menu Appeared"
        static var floatDetails = "Float Details 1"
        static var lockOffFloatUnitOptions = "Lock Off and Float Unit Options"
      
    }
    
    //Omniture Evars
    struct omnitureEvars {
        
        static var eVar1 = "eVar1"
        static var eVar2 = "eVar2"
        static var eVar3 = "eVar3"
        static var eVar4 = "eVar4"
        static var eVar5 = "eVar5"
        static var eVar6 = "eVar6"
        static var eVar7 = "eVar7"
        static var eVar8 = "eVar8"
        static var eVar9 = "eVar9"
        static var eVar10 = "eVar10"
        static var eVar11 = "eVar11"
        static var eVar12 = "eVar12"
        static var eVar13 = "eVar13"
        static var eVar14 = "eVar14"
        static var eVar15 = "eVar15"
        static var eVar16 = "eVar16"
        static var eVar17 = "eVar17"
        static var eVar18 = "eVar18"
        static var eVar19 = "eVar19"
        static var eVar20 = "eVar20"
        static var eVar21 = "eVar21"
        static var eVar22 = "eVar22"
        static var eVar23 = "eVar23"
        static var eVar24 = "eVar24"
        static var eVar25 = "eVar25"
        static var eVar26 = "eVar26"
        static var eVar27 = "eVar27"
        static var eVar28 = "eVar28"
        static var eVar29 = "eVar29"
        static var eVar30 = "eVar30"
        static var eVar31 = "eVar31"
        static var eVar32 = "eVar32"
        static var eVar33 = "eVar33"
        static var eVar34 = "eVar34"
        static var eVar35 = "eVar35"
        static var eVar36 = "eVar36"
        static var eVar37 = "eVar37"
        static var eVar38 = "eVar38"
        static var eVar39 = "eVar39"
        static var eVar40 = "eVar40"
        static var eVar41 = "eVar41"
        static var eVar42 = "eVar42"
        static var eVar43 = "eVar43"
        static var eVar44 = "eVar44"
        static var eVar45 = "eVar45"
        static var eVar46 = "eVar46"
        static var eVar47 = "eVar47"
        static var eVar48 = "eVar48"
        static var eVar49 = "eVar49"
        static var eVar50 = "eVar50"
        static var eVar51 = "eVar51"
        static var eVar52 = "eVar52"
        static var eVar53 = "eVar53"
        static var eVar54 = "eVar54"
        static var eVar55 = "eVar55"
        static var eVar56 = "eVar56"
        static var eVar57 = "eVar57"
        static var eVar58 = "eVar58"
        static var eVar59 = "eVar59"
        static var eVar60 = "eVar60"
        static var eVar61 = "eVar61"
        static var eVar62 = "eVar62"
        static var eVar63 = "eVar63"
        static var eVar64 = "eVar64"
        static var eVar65 = "eVar65"
        static var eVar66 = "eVar66"
        static var eVar67 = "eVar67"
        static var eVar68 = "eVar68"
        static var eVar69 = "eVar69"
        static var eVar70 = "eVar70"
        static var eVar71 = "eVar71"
        static var eVar72 = "eVar72"
        static var eVar73 = "eVar73"
        static var eVar74 = "eVar74"
        static var eVar75 = "eVar75"
        static var eVar76 = "eVar76"
        static var eVar77 = "eVar77"
        static var eVar78 = "eVar78"
        static var eVar79 = "eVar79"
        static var eVar80 = "eVar80"
        static var eVar81 = "eVar81"
        static var eVar82 = "eVar82"
        static var eVar83 = "eVar83"
        static var eVar84 = "eVar84"
        static var eVar85 = "eVar85"
        static var eVar86 = "eVar86"
        static var eVar87 = "eVar87"
        static var eVar88 = "eVar88"
        static var eVar89 = "eVar89"
        static var eVar90 = "eVar90"
        static var eVar91 = "eVar91"
        static var eVar92 = "eVar92"
        static var eVar93 = "eVar93"
        static var eVar94 = "eVar94"
        static var eVar95 = "eVar95"
        static var eVar96 = "eVar96"
        static var eVar97 = "eVar97"
        static var eVar98 = "eVar98"
        static var eVar99 = "eVar99"
        static var eVar100 = "eVar100"
        
    }
    
    //Omniture Events
    struct omnitureEvents {
        
        static var event1 = "Event1"
        static var event2 = "Event2"
        static var event3 = "Event3"
        static var event4 = "Event4"
        static var event5 = "Event5"
        static var event6 = "Event6"
        static var event7 = "Event7"
        static var event8 = "Event8"
        static var event9 = "Event9"
        static var event10 = "Event10"
        static var event11 = "Event11"
        static var event12 = "Event12"
        static var event13 = "Event13"
        static var event14 = "Event14"
        static var event15 = "Event15"
        static var event16 = "Event16"
        static var event17 = "Event17"
        static var event18 = "Event18"
        static var event19 = "Event19"
        static var event20 = "Event20"
        static var event21 = "Event21"
        static var event22 = "Event22"
        static var event23 = "Event23"
        static var event24 = "Event24"
        static var event25 = "Event25"
        static var event26 = "Event26"
        static var event27 = "Event27"
        static var event28 = "Event28"
        static var event29 = "Event29"
        static var event30 = "Event30"
        static var event31 = "Event31"
        static var event32 = "Event32"
        static var event33 = "Event33"
        static var event34 = "Event34"
        static var event35 = "Event35"
        static var event36 = "Event36"
        static var event37 = "Event37"
        static var event38 = "Event38"
        static var event39 = "Event39"
        static var event40 = "Event40"
        static var event41 = "Event41"
        static var event42 = "Event42"
        static var event43 = "Event43"
        static var event44 = "Event44"
        static var event45 = "Event45"
        static var event46 = "Event46"
        static var event47 = "Event47"
        static var event48 = "Event48"
        static var event49 = "Event49"
        static var event50 = "Event50"
        static var event51 = "Event51"
        static var event52 = "Event52"
        static var event53 = "Event53"
        static var event54 = "Event54"
        static var event55 = "Event55"
        static var event56 = "Event56"
        static var event57 = "Event57"
        static var event58 = "Event58"
        static var event59 = "Event59"
        static var event60 = "Event60"
        static var event61 = "Event61"
        static var event62 = "Event62"
        static var event63 = "Event63"
        static var event64 = "Event64"
        static var event65 = "Event65"
        static var event66 = "Event66"
        static var event67 = "Event67"
        static var event68 = "Event68"
        static var event69 = "Event69"
        static var event70 = "Event70"
        static var event71 = "Event71"
        static var event72 = "Event72"
        static var event73 = "Event73"
        static var event74 = "Event74"
        static var event75 = "Event75"
        static var event76 = "Event76"
        static var event77 = "Event77"
        static var event78 = "Event78"
        static var event79 = "Event79"
        static var event80 = "Event80"
        static var event81 = "Event81"
        static var event82 = "Event82"
        static var event83 = "Event83"
        static var event84 = "Event84"
        static var event85 = "Event85"
        static var event86 = "Event86"
        static var event87 = "Event87"
        static var event88 = "Event88"
        static var event89 = "Event89"
        static var event90 = "Event90"
        static var event91 = "Event91"
        static var event92 = "Event92"
        static var event93 = "Event93"
        static var event94 = "Event94"
        static var event95 = "Event95"
        static var event96 = "Event96"
        static var event97 = "Event97"
        static var event98 = "Event98"
        static var event99 = "Event99"
        static var event100 = "Event100"
        
    }
    
    // structure for productCode ImageNames
    struct productCodeImageNames {
        
        static var basic = "BSC"
        static var cig = "CIG"
        static var gold = "GLD"
        static var platinum = "PLT"
    }
    struct  buttonId {
        static var bedroomselection = "Bedroomtapped"
        static var resortSelection  = "ResortSelect"
    }

}
