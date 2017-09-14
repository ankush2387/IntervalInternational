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
    
    //***** common function to get device orientation *****//
    static var holdingTimer:Timer!
    static var holdingTime = 17
    static var decreaseValue = 1
    static var holdingResortForRemainingMinutes = "We are holding this unit for \(holdingTime) minutes"
    
    struct RunningDevice {
        static var deviceOrientation:UIDeviceOrientation?
        static var deviceIdiom = UIDevice().userInterfaceIdiom
    }
    
    //Getaways SearchResult CardFormDetail Data
    struct GetawaySearchResultGuestFormDetailData {
        

        //static var countryListArray = [String]()
        static var countryCodeArray = [String]()
        //static var stateListArray = [String]()
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
    
    struct AdditionalUnitDetailsData  {
        
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
        
        static var centerViewRgb = UIColor(red: 176.0/255.0, green: 215.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        
        static var textFieldBorderRGB = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
    }
    
    //GetawaySearchResultCardFormDetailData
    struct GetawaySearchResultCardFormDetailData {
        
        static var countryListArray = ["Canada","USA","India","Austrelia","South Africa"]
        static var countryCodeArray: [String] = []
        static var cardTypeArray = ["Visa","Master","Coral"]
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
        static var expDate:Date? = nil
        static var cvv = ""
        static var countryCode = ""
        static var stateCode = ""
    }
    
    struct MyClassConstants{
        
        static var alertOriginationPoint:String!
        static var depositPromotionNav = "DepositPromotionsNav"
        static var sorting = "Sorting"
        static var filterSearchResult = "Filter Search Result"
        static var loginOriginationPoint:String!
        static var vacationSearchResultHeaderLabel:String = ""
        static var upcomingOriginationPoint : String!
        static var loginType:String!
        static var selectedDestinationNames:String = ""
        static var addressStringForCardDetailSection = "Address"
        static var destinationOrResortSelectedBy:String = ""
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
        
        //global variable to hold advisement type text
        static var advisementTypeStringaArray = ["Important Advisements","General Advisements","Additional Advisements"]
        
        // Sorting or filter options array
        static var filteredOptiondArray = ["Crecent resort on...+3 more", "Hyatt Beach Resort House", "Key West, Florida", "Las Vegas, Nevada"]
        
        static var rentalSortingOptionArray = ["Resort Name:", "Resort Name:", "Price:", "Price:", "City:", "City:", "Resort Tier:", "Resort Tier:"]
        static var sortingSetValues = ["RESORT_NAME_ASC", "RESORT_NAME_DESC", "CITY_NAME_ASC", "CITY_NAME_DESC", "RESORT_TIER_LOW_TO_HIGH", "RESORT_TIER_HIGH_TO_LOW", "PRICE_LOW_TO_HIGH", "PRICE_HIGH_TO_LOW", "UNKNOWN"]
        
        static var rentalSortingRangeArray = ["A - Z", "Z - A", "Low - High", "High - Low", "A - Z", "Z - A", "Low - High", "High - Low"]
        
        static var exchangeSortingOptionArray = ["Resort Name:", "Resort Name:", "City:", "City:", "Resort Tier:", "Resort Tier:"]
        static var exchangeSortingRangeArray = ["A - Z", "Z - A", "A - Z", "Z - A", "Low - High", "High - Low"]
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
        
        static var getawayBookingLastStartedProcess:RentalProcess!
        
        //global variable to hold last exchange getaway booking process
        
        static var exchangeBookingLastStartedProcess:ExchangeProcess!
        
        //***** global variable that hold system access token *****//
        static var systemAccessToken:DarwinAccessToken?
        
        //***** global variable that identify the running functionality *****//
        static var runningFunctionality = ""
        
        //***** global variable that identify the API call source *****//
        static var isgetResortFromGoogleSearch = false
        
        //***** global variable that identify which controller requested for login *****//
        static var signInRequestedController:UIViewController!
        
        //***** global variable that hold the collection view index *****//
        static var searchResultCollectionViewScrollToIndex = 0
        
        //***** global variable  that hold  Boolean value successfull login status *****//
        static var isLoginSuccessfull = false
        
        static var isFromSorting = false
        
        static var isFromSearchResult = false
        
        //***** global variable that contains running device width from appdelegate method *****//
        static var runningDeviceWidth:CGFloat? = UIScreen.main.bounds.width
        static var runningDeviceHeight:CGFloat? = UIScreen.main.bounds.height
        
        //***** global variable to hold webview instance data *****//
        static var requestedWebviewURL:String!
        static var webviewTtile:String!
        static var resortDirectoryTitle = "Resort Directory"
        static var resortDirectoryCommonHearderText = "Choose Region"
        static var selectedBedRoomSize = "All Bedroom Sizes"
        //***** global array that contains background images *****//
        static let backgroundImageArray = ["BackgroundImgLogin-A","BackgroundImgLogin-B","BackgroundImgLogin-C","BackgroundImgLogin-D","BackgroundImgLogin-E","BackgroundImgLogin-F","BackgroundImgLogin-G"]
        
        static var collectionImageArray = ["","","","","","","","","",""]
        
        //***** global variable to contain random number each time app delegate called *****//
        static var random:Int?
        
        
        //***** New creditcard screen constant string *****//
        static var newCardalertTitle = NSLocalizedString("New Creditcard Form", comment: "")
        static var newCardalertMess = NSLocalizedString("Card already exist.", comment: "")
        static var alertReqFieldMsg = NSLocalizedString("All fields are mandatory", comment: "")
        static var noResultError = NSLocalizedString("No Result", comment: "")
        static var tryAgainError = NSLocalizedString("Try Again", comment: "")
        static var tdi = NSLocalizedString("TDI", comment: "")
        static var season = NSLocalizedString("Season", comment: "")
        
        
        
        //***** Vacation search screen constant string header array *****//
        
        static var threeSegmentHeaderTextArray = [NSLocalizedString("Where_do_you_want_to_go", comment: ""),NSLocalizedString("Check_in_closest_to", comment: ""),NSLocalizedString("Who_is_travelling", comment: "")]
        
        //***** Who will be checking-In header text array *****//
        static var whoWillBeCheckingInHeaderTextArray = ["From the list below, Who on your  membership might be checking-in?","","Guest Name","Guest Address","Guest Contact info",""]
        
        //***** checkout screen table header footer string array *****//
        static var checkOutScreenHeaderTextArray = ["","Promotions","Exchange Options","Add Trip Protection(Recommended)","Your Booking Costs","","","","Payment Method","Confirmation Email"]
        static var checkOutScreenHeaderIPadTextArray = ["","Promotions","Exchange Options","Add Trip Protection(Recommended)","Payment Method","Confirmation Email","","","",""]
        
        
        
        //***** Initializing plicy list table cell content array *****//
        static var policyListTblCellContentArray = ["Terms & Conditions","Privacy Policy","Legal Information","Contact Us","Email Us","Our Offices","Interval World","Version \(Helper.getBuildVersion())"]
        
        static var fourSegmentHeaderTextArray = [NSLocalizedString("Where_do_you_want_to_go", comment: ""),NSLocalizedString("What_do_you_want_to_trade", comment: ""),NSLocalizedString("Check_in_closest_to", comment: ""),NSLocalizedString("Who_is_travelling", comment: "")]
        
        static var sectionHeaderArray = [NSLocalizedString("Destinations", comment: ""),NSLocalizedString("Resorts", comment: "")]
        
        static var relinquishmentHeaderArray = [NSLocalizedString("Club Interval Gold Weeks", comment: ""),NSLocalizedString("", comment: ""),NSLocalizedString("Club Points", comment: ""),NSLocalizedString("Interval Weeks", comment: ""),NSLocalizedString("Deposited", comment: "")]
        static var lockOffCapable = NSLocalizedString("Lock Off Capable", comment: "")
        
        static var membershipContactArray = [Contact]()
        static var vacationSearchDestinationArray:NSMutableArray = []
        static var calendarDatesArray = [CalendarItem]()
        static var totalBucketArray = [CalendarItem]()
        static var calendarCount:Int!
        static var realmStoredDestIdOrCodeArray:NSMutableArray = []
        static var resortCodesArray : [String] = []
        static var searchAvailabilityHeader = ""
        static var filterOptionsArray: [ResortDestination] = []
        static var areaWithAreaCode: [AreaInfo] = []
        static var selectedAreaCodeDictionary = NSMutableDictionary()
        static var selectedAreaCodeArray = NSMutableArray()
        
        static var surroundingResortCodesArray : [String] = []
        static var resortsArray = [Resort]()
        static var regionArray = [Region]()
        static var regionAreaDictionary = NSMutableDictionary()
        static var favoritesResortArray = [Resort]()
        static var favoritesResortCodeArray:NSMutableArray = []
        static var getawayAlertsArray = [RentalAlert]()
        static var upcomingTripsArray = [UpcomingTrip]()
        static var activeAlertsArray:NSMutableArray = []
        static var membershipdetails = [Membership]()
        static var memberdetailsarray:NSMutableArray = []
        static var memberNumber: String!
        
        static var whereTogoContentArray:NSMutableArray = []
        static var whatToTradeArray:NSMutableArray = []
        static var floatRemovedArray:NSMutableArray = []
        static var pointsArray:NSMutableArray = []
        static var selectedGetawayAlertDestinationArray:NSMutableArray = []
        static var alertSelectedResorts = [Resort]()
        static var alertSelectedDestination = [AreaOfInfluenceDestination]()
        static var checkInClosestContentArray:NSMutableArray = []
        static var fromdatearray:NSMutableArray = []
        static var todatearray:NSMutableArray = []
        static var labelarray:NSMutableArray = []
        
        static var googleMarkerArray = [GMSMarker]()
        
        static let sidemenuIntervalInternationalCorporationLabel = NSLocalizedString("2015 Interval International. Privacy/Legal", comment: "")
        static let noRelinquishmentavailable = NSLocalizedString("No Relinquishment available", comment: "")
        static let relinquishmentTitle = NSLocalizedString("Select all or any lock-off portion", comment: "")
        static let floatTitle = NSLocalizedString("Select one lock-off portion at a time", comment: "")
        static let bedroomTitle = NSLocalizedString("Choose Bedrooms", comment: "")
    
        static var selectedIndex:Int!
        static var vacationSearchContentPagerRunningIndex  = 0
        static var vacationSearchShowDate:Date!
        static var alertWindowStartDate:Date!
        static var alertWindowEndDate:Date!
        static var rightBarButtonTitle = "Today"
        static var todaysDate = Date()
        static var dateAfterTwoYear = NSCalendar.current.date(byAdding: .month, value: 24, to: NSDate() as Date) //NSCalendar.currentCalendar.dateByAddingUnit(.Month, value: 24, toDate: NSDate(), options: [])!
        
        static var bundelVersionUsedString = "CFBundleShortVersionString"
        static var member = "Member #  "
        static var switchToView = "SwitchToView"
        static var signOutSelected = "signOutSelected"
        
        // intervalHD arrays
        static var intervalHDDestinations:[Video]? = []
        static var internalHDResorts:[Video]? = []
        static var internalHDTutorials:[Video]? = []
        static var magazinesArray:[Magazine]? = []
        
        // Pick destinations array
        static var resorts : [Resort]? = []
        static var destinations : [AreaOfInfluenceDestination]? = []
        static var allDestinations = "All Available Destinations"
        
        static var currentFromDate:Date!
        static var currentToDate:Date!
        static var checkInDates = [Date]()
        static var surroundingCheckInDates = [Date]()
        static var combinedCheckInDates = [Date]()
        static var totalWindow = 90
        static var bedRoomSize = ["STUDIO","ONE_BEDROOM","TWO_BEDROOM","THREE_BEDROOM","FOUR_BEDROOM"]
        static var alertSelectedUnitSizeArray:NSMutableArray = NSMutableArray()
        static var topDeals : [RentalDeal] = []
        static var flexExchangeDeals : [FlexExchangeDeal] = []
        static var resortDirectoryRegionArray = [Region]()
        static var resortDirectorySubRegionArray = [Region]()
        static var resortDirectoryAreaListArray = [Area]()
        static var resortDirectoryResortArray = [Resort]()
        static var viewController:UIViewController!
        static var btnTag:Int! = -1
        static var showAlert : Bool = false
        static let arrayResortInfo = ["Resort Information","Amenities","Member Ratings","Travel Demand Index"]
        static var backgroundImageUrl:String! = ""
        static var resortDescriptionString:String! = ""
        static var resortsDescriptionArray = Resort()
        static var collectionViewScrolledIndex:Int = 0
        static var imagesArray:NSMutableArray = []
        static var bedRoomSizeSelectedIndexArray:NSMutableArray = []
        static var alertSelectedBedroom: NSMutableArray = []
        static var unitNumberSelectedArray:NSMutableArray = []
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
        
        static var inactive = "INACTIVE"
        static var expired = "EXPIRED"
        static var active = "ACTIVE"
        static var bedroomSizes = "All BedRoom Sizes"
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
        static var selectedSegment = ""
        
        static var draw = "Draw"
        static var clear = "Clear"
        static var list = "List"
        static var map = "Map"
        static var isFromNothingYet:Bool = false
        
        static var createAlert = "CreateAlert"
        static var editAlert = "EditAlert"
        static var resortDirectoryVC = "ResortDirectoryViewController"
        static var currentIssue = "Current Issue!"
        static var vacationSearch = "VacationSearch"
        static var searchResult = "SearchResult"
        
        static var right = "Right"
        static var left = "Left"
        
        static var addResortSelectedIndex:NSMutableArray = []
        static var collectionVwCurrentIndex:Int = 0
        
        static var childCounterString = "childCounter"
        static var adultCounterString = "adultCounter"
        static var selectedDate = "SelectedDate"
        
        static var childCounter = 0
        static var adultCounter = 2
        
        static var resortVC = "ResortDetailsViewController"
        static var destinationResortDetail = "DestinationResortViewController"
        static var resortsString = "Resort"
        static var tutorialsString = "Tutorial"
        static var areaString = "Area"
        static var searchPlaceHolder = "Search"
        static var orientationString = "orientation"
        static var getawayAlerts = "GetawayAlerts"
        
        static var surroundingAreaString = "Resorts in surrounding areas."
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
        static var guestCertificate:GuestCertificate!
        static var allowedCurrencies = [String]()
        
        
        //Relinquishment selection screen response arrays
        
        //Relinquishment selection date for float and avaialable tool
        static var  relinquishmentAvalableToolSelectedDate:Date!
        static var  relinquishmentFloatDetialSelectedDate:Date!
        static var  relinquishmentFloatDetialMinDate:Date!
        static var  relinquishmentFloatDetialMaxDate:Date!
        static var  floatDetailsCalendarDateArray = [Date]()
        static var relinquishmentFlaotWeek = "RelinquishmentFloatWeek"
        static var realmOpenWeeksID = NSMutableArray()
        
        static var  onsiteArray = NSMutableArray()
        static var  nearbyArray = NSMutableArray()
        static var  relinquishmentIdArray = NSMutableArray()
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
        
        
        static var onsiteString : String! = "Nearby" + "\n"
        static var nearbyString : String!  = "On-Site" + "\n"
        static var indexSlideButton : Int = 0
        static var onsiteDictKey = "Onsite"
        static var nearbyDictKey = "Nearby"
        static var status = "true"
        
        static var inventoryPrice = [InventoryPrice]()
        static var selectedResort = Resort()
        static var selectedExchange = ""
        
        static var paymentMethodTitle = "Payment Method"
        static var webViewGetElementById = "document.getElementById('WASCInsuranceOfferOption0').checked == true;"
        static var webViewGetElementById1 = "document.getElementById('WASCInsuranceOfferOption1').checked == true;"
        static var paymentInfo = "Select your payment method"
        static var verifying = "Verifying..."
        static var insurance = "Trip Protection"
        static var guestCertificateTitle = "Guest Certificate"
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
        static var dateFormat1 = "yyyy-MM-dd"
        
        //use for no Availability Cell
        static var isShowAvailability = false
        
        static var isTrue = "true"
        static var isFalse = "false"
        static var isOn = "on"
        static var isOff = "off"
        static var relinquishment = "Relinquishment"
        static var resortDirectoryVCTitle = "ResortDetailsVC"
        static var googleMapKey = "AIzaSyCFg7iWNVVm_0tjKsBb9NFREVjQrExDlhE"//AIzaSyCCJ7PzZaaefMvNc-CnGX-Ky-9E1Xx3x6k
        static var alertsResortCodeDictionary = NSMutableDictionary()
        static var alertsSearchDatesDictionary = NSMutableDictionary()
        static var headerArray = ["Getaway Alerts","My Upcoming Trips"]
        
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
        static var savedBedroom = ""
        static var buttontitle = ""
        static var resortAttributedString = ""
        
        //Reservation Attributes
        static var resortAttributes = "RESORT_ATTRIBUTES"
        static var resortClubAttribute = "RESORT_CLUB"
        static var resortReservationAttribute = "RESERVATION_NUMBER"
        static var checkInDateAttribute =   "CHECK_IN_DATE"
        static var unitNumberAttribute = "UNIT_NUMBER"
        static var resortDetailsAttribute = "RESORT_DETAILS"
        static var saveAttribute = "SAVE_DETAILS"
        static var callResortAttribute = "CALL_DETAILS"
        static var noOfBedroomAttribute = "NO_OF_BEDROOMS"
        static var selectClubResort = "Select club or Resort"
        
        //Float week to store information for editing
        static var selectedFloatWeek = OpenWeeks()
        static var unitNumberLockOff = ""
        static var saveLockOffDetailsArray = NSMutableArray()
        
        //Header for search results
        static var searchResultHeader = NSLocalizedString("Nearest Check-in Date selected.\nWe found availibility close to your desired date.", comment: "")
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
        
        static var rentalHasNotAvailableCheckInDatesForInitial : Bool = false
        static var exchangeHasNotAvailableCheckInDatesForInitial : Bool = false
        
        static var rentalHasNotAvailableCheckInDatesAfterSelectInterval : Bool = false
        static var exchangeHasNotAvailableCheckInDatesAfterSelectInterval : Bool = false
        static var searchBothExchange = false
    }
    
    // Enum to store resorts and destinations
    enum ResortDestination{
        case Resort(ResortList)
        case Destination(DestinationList)
        case ResortList([ResortByMap])
        case Area(NSMutableDictionary)
    }
    
    // Enum to store area and area code
    enum AreaInfo {
        static var area = [Area]()
        static var areaCode = ""
    }
    
    struct CommonColor {
        static var greenColor = "Green"
        static var blueColor = "Blue"
        static var headerGreenColor = UIColor(red: 112.0/255.0, green: 185.0/255.0, blue: 9.0/255.0, alpha: 1)
    }
    
    struct CommonStringIdentifiers {
        static var floatWeek = "FLOAT_WEEK"
        static var pointWeek = "POINTS_WEEK"
        static var noRelinquishmentAvailable = "NO_RELINQUISHMENT"
        static var alertOriginationPoint = "Unsuccessful Getaway Search 3"
    }
    
    struct CommonLocalisedString {
        
        static var memberNumber = NSLocalizedString("Member No", comment: "")
        static var user_id = NSLocalizedString("User ID", comment: "")
        static var user_password = NSLocalizedString("Password", comment: "")
        static var sign_in = NSLocalizedString("Sign_In", comment: "")
        static var totalString = NSLocalizedString(" Total, ", comment: "")
        static var privateString = NSLocalizedString(" Private", comment: "")
        static var exactString = NSLocalizedString("Resorts in ", comment: "")
        static var surroundingString = NSLocalizedString("Resorts near ", comment: "")

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
        
        
        static let privacyPolicyUrlArray = ["http://www.intervalworld.com/iimedia/pdf/iw/buyers-guide.pdf","http://www.intervalworld.com/web/cs?a=60&p=privacy-policy","http://www.intervalworld.com/web/cs?a=60&p=legal","http://www.intervalworld.com/web/cs?a=60&p=customer-service","http://www.intervalworld.com/web/cs?a=80","http://www.intervalworld.com/web/cs?a=60&p=offices","http://www.intervalworld.com"]
        
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
        
        static var loginFailed = NSLocalizedString("Login_Failed", comment: "")
        static var errorString = NSLocalizedString("Error", comment: "")
        static var networkError = NSLocalizedString("No Internet Connection", comment: "")
        static var noResultError = NSLocalizedString("No Result", comment: "")
        static var tryAgainError = NSLocalizedString("Try Again", comment: "")
        static var loginFailedError = NSLocalizedString("Login Failed", comment: "")
        static var getawayAlertMessage = NSLocalizedString("Check back with us in a bit or we will keep searching and contact you when we have a match!\n\n You can also start your own search", comment: "")
        static var emailAlertMessage = NSLocalizedString("Please enter valid email", comment: "")
        static var noDestinationRelinquishmentError = NSLocalizedString("Add \("Destinations") and \("Items to trade")", comment: "")
        
    }
    
    //***** common structure to provide alert messages *****//
    struct AlertMessages {
        
        static var searchAlertTitle = NSLocalizedString("Search All Available Destinations", comment:"")
        
        static var searchAlertMessage = NSLocalizedString("Selecting this option will remove all other currently selected destinations/resorts . Are you sure you want to do this?", comment: "")
        static var emptyLoginIdMessage = NSLocalizedString("Please enter your Login ID.", comment: "")
        static var emptyPasswordLoginMessage = NSLocalizedString("Please enter your Password.", comment: "")
        static var createAlertMessage = NSLocalizedString("Alert created successfully", comment: "")
        static var editAlertMessage = NSLocalizedString("Alert updated successfully", comment: "")
        
        static var noMembershipMessage = NSLocalizedString("Please contact your servicing office.  No membership information was found for your account.", comment: "")
        
        static var noResultMessage = NSLocalizedString("Sorry there is no availability within 90 days of your selected date.", comment: "")
        
        static var networkErrorMessage = NSLocalizedString("Make sure your device is connected to the internet.", comment: "")
        
        static var editAlertEmptyNameMessage = NSLocalizedString("Valid alert Name required.", comment: "")
        static var editAlertEmptyWidowStartDateMessage = NSLocalizedString("Please select window start date. ", comment: "")
        static var editAlertEmptyWidowEndDateMessage = NSLocalizedString("Please select window End date. ", comment: "")
        static var editAlertdetinationrequiredMessage = NSLocalizedString("Please select at least one destination or resort. ", comment: "")
        //static var bedroomSizeAlertMessage = NSLocalizedString("Please select at least one bedroom size. ", comment: "")
        static var bedroomSizeAlertMessage = NSLocalizedString("Please select at least one master or lock-off portion. ", comment: "")
        static var feesAlertMessage = NSLocalizedString("Slide to agree to fees. ", comment:"")
        static var insuranceSelectionMessage = NSLocalizedString("Select trip protection or choose \("\"No I decline coverage.\"")", comment: "")
        static var paymentSelectionMessage = NSLocalizedString("Please select any payment method. ", comment:"")
        static var promotionsMessage = NSLocalizedString("Please select any promotions. ", comment:"")
        static var feesPaymentMessage = NSLocalizedString("I acknowledge and agree that the mandatory resort fees will be payable to the resort. Fees are per person and per day", comment: "")
        static var agreeToFeesMessage = NSLocalizedString("Agreed to Fees", comment: "")
        static var termsConditionMessage = NSLocalizedString("I have read and accepted the Terms and Conditions and Privacy Policy", comment: "")
        static var agreePayMessage = NSLocalizedString("Slide to Agree and Pay", comment: "")
        static var operationFailedMessage =  NSLocalizedString("Unable to perform back button operatin due to server error, Try again!", comment: "")
        static var availablePointToolDefaultSelectedDateAlert =  NSLocalizedString("if no date is selected the Available Points Balance displayed is based on today's date.", comment: "")
        static var holdingTimeLostTitle = NSLocalizedString("Holding time lost", comment: "")
        static var holdingTimeLostMessage = NSLocalizedString("Oops You have lost your holding time for this resort!." , comment: "")
        static var searchVacationTitle = NSLocalizedString("Search Vacation", comment: "")
        static var searchVacationMessage = NSLocalizedString("Please select any destination or resort", comment: "")
        static var travellingDetailMessage = NSLocalizedString("Traveling: Tue Oct 15, 2015 - Sun May 20, 2018", comment: "")
        static var vacationSearchMessage = NSLocalizedString("We were unable to find any availability for the travel dates you requested. Please check other available dates by scrolling above.", comment: "")
        static var vactionSearchDateMessage = NSLocalizedString("No match found. Please select another date.", comment: "")
        static var userInterestMessage = NSLocalizedString("How's about you go favorite some resorts and when you come back they will be here all warm and toasty waiting for you!", comment: "")
        static var goGetMessage = NSLocalizedString("Go on Get! ", comment: "")
        static var noDatesMessage = NSLocalizedString("No Dates availabel", comment: "")
        static var tradeItemMessage = NSLocalizedString("Add items to \("What do you want to trade?") section", comment: "")
    }
    
    //***** common  structure to provide alert promt button titles *****//
    struct AlertPromtMessages {
        
        static var ok = NSLocalizedString("Ok", comment: "")
        static var close = NSLocalizedString("Close", comment: "")
        static var newSearch = NSLocalizedString(" Go Start A New Getaway Search!", comment: "")
        static var cancel = NSLocalizedString("Cancel", comment: "")
        static var done = NSLocalizedString("Done", comment: "")
        static var no = NSLocalizedString("No", comment: "")
        static var yes = NSLocalizedString("Yes", comment: "")
        static var aboutTouchId = NSLocalizedString("About_Touch_Id", comment: "")
        static var loginTitle = NSLocalizedString("Login", comment: "")
        static var createAlertTitle = NSLocalizedString("Create Alert", comment: "")
        static var editAlertTitle = NSLocalizedString("Edit Alert", comment: "")
        static var bedRoomSizeTitle = NSLocalizedString("BedRoom Sizes", comment: "")
        static var applyButtonTitle = NSLocalizedString("Apply", comment: "")
        static var failureTitle = NSLocalizedString("Failure", comment: "")
        static var noUpComingTrips = NSLocalizedString("No upcoming trips.", comment: "")
        static var membershipFailureMessage = NSLocalizedString("Please contact your servicing office.  Could not select membership", comment: "")
        static var upcomingTripMessage = NSLocalizedString("Good news! \nYour next Trip to Fizi is in 3 months.", comment: "")
        
    }
    
    //***** Common structure to provide names for all notifications *****//
    
    struct notificationNames {
        
        static var getawayAlertsNotification = "reloadAlerts"
        static var magazineAlertNotification = "reloadMagazines"
        static var accessTokenAlertNotification = "gotAccessToken"
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
        
        static var detail = NSLocalizedString("Detail", comment: "")
        static var nothingYet = NSLocalizedString("Nothing Yet", comment: "")
        static var add = NSLocalizedString("Add", comment: "")
        static var delete = NSLocalizedString("Delete", comment: "")
        static var searchOption = NSLocalizedString("Search Option", comment: "")
        static var sharingOption = NSLocalizedString("Sharing Option", comment: "")
        static var optionTitle = NSLocalizedString("Options", comment: "")
        static var viewMyRecentSearches =  NSLocalizedString("View my recent searches", comment: "")
        static var shareViaEmail =  NSLocalizedString("Share Via Email", comment: "")
        static var shareViaText =  NSLocalizedString("Share Via Text", comment: "")
        static var resetMySearch =  NSLocalizedString("Reset my search", comment: "")
        static var help = NSLocalizedString("Help", comment: "")
        static var tweet = NSLocalizedString("Tweet", comment: "")
        static var facebook = NSLocalizedString("Facebook", comment: "")
        static var pinterest = NSLocalizedString("Pinterest", comment: "")
        static var cancel = NSLocalizedString("Cancel", comment: "")
        static var remove = NSLocalizedString("Remove", comment: "")
        static var edit = NSLocalizedString("Edit", comment: "")
        static var details = NSLocalizedString("Details", comment: "")
        static var activate = NSLocalizedString("Activate", comment: "")
        static var searchAllMyAlertsNow =  NSLocalizedString("Search All My Alerts Now", comment:"")
        static var getwayAlertOptions =  NSLocalizedString("Getaway Alerts Options", comment:"")
        static var aboutGetawayAlerts =  NSLocalizedString("About Getaway Alerts", comment: "")
        static var select = NSLocalizedString("Select", comment: "")
        static var viewAllAlerts = NSLocalizedString("View All Alerts", comment: "")
        static var viewAllTrips = NSLocalizedString("View All Trips", comment: "")
        static var searchVacation = NSLocalizedString("Search Vacations",comment:"")
        static var favoritesTitle = NSLocalizedString("Favorites", comment: "")
        static var resortTitle = NSLocalizedString("Resort_Directory", comment: "")
        static var magazineTitle = NSLocalizedString("Magazines", comment: "")
        static var intervalHDTitle = NSLocalizedString("Interval_HD", comment: "")
        static var joinTodayTitle = NSLocalizedString("Join_Today", comment: "")
        static var privacyTitle = NSLocalizedString("Privacy/Legal", comment: "")
        static var resendTitle = NSLocalizedString("Resend Confirmation", comment: "")
        static var emailTripTitle = NSLocalizedString("Email Trip Details", comment: "")
        static var textTripTitle = NSLocalizedString("Text Trip Details", comment: "")
        static var purchaseInsuranceTitle = NSLocalizedString("Purchase Trip Protection", comment: "")
        static var viewResults = NSLocalizedString("View Results", comment: "")
        static var updateSwitchTitle = NSLocalizedString("Update email", comment: "")
    }
    
    //****common structure to provide all dynamic controller text field titles****//
    struct textFieldTitles {
        static var usernamePlaceholder = NSLocalizedString("Login ID", comment: "")
        static var passwordPlaceholder = NSLocalizedString("Password", comment: "")
        static var alertNamePlaceholder = NSLocalizedString("Name Your Getaway Alert", comment: "")
        static var guestFormFnamePlaceholder = NSLocalizedString("First Name", comment: "")
        static var guestFormLnamePlaceholder = NSLocalizedString("Last Name", comment: "")
        static var guestFormSelectCountryPlaceholder = NSLocalizedString("Select Country", comment: "")
        static var guestFormAddress1 = NSLocalizedString("Address 1", comment: "")
        static var guestFormAddress2 = NSLocalizedString("Address 2", comment: "")
        static var guestFormCity = NSLocalizedString("City", comment: "")
        static var guestFormSelectState = NSLocalizedString("Select State / Province", comment: "")
        static var guestFormPostalCode = NSLocalizedString("Zip / Postal Code", comment: "")
        static var guestFormEmail = NSLocalizedString("Email", comment: "")
        static var guestFormHomePhoneNumber = NSLocalizedString("Home Phone Number", comment: "")
        static var guestFormBusinessPhoneNumber = NSLocalizedString("Business Phone Number", comment: "")
        //card details
        static var nameOnCard = NSLocalizedString("Name on Card", comment: "")
        static var cardNumber = NSLocalizedString("Card Number", comment: "")
        static var type = NSLocalizedString("Type", comment: "")
        static var expirationDate = NSLocalizedString("Select Expiration Date", comment: "")
        static var cvv = NSLocalizedString("CVV", comment: "")
        static var expirationDatePlaceHolder = NSLocalizedString("MM/YY", comment: "")
        static var country = NSLocalizedString("Country", comment: "")
        //Ownership text field placeholder
        static var reservationNumber = NSLocalizedString("Reservation Number", comment: "")
        static var unitNumber = NSLocalizedString("Unit Number", comment: "")
        static var numberOfBedrooms = NSLocalizedString("Number of Bedrooms", comment: "")
        static var checkInDate = NSLocalizedString("Check-in Date", comment: "")
        
        //Payment selection view controller
        
    }
    
    //****common structure to provide all dynamic controller label titles****//
    struct labelTitles {
        static var enableTouchIDLabel = NSLocalizedString("Enable_Touch_Id", comment: "");
    }
    
    //***** common  structure to provide all side menu title name *****//
    struct sideMenuTitles {
        static var sideMenuInitialController = "RevialViewController"
        
        static var home = NSLocalizedString("Home", comment: "")
        static var searchVacation = NSLocalizedString("Search_Vacation", comment: "")
        static var upcomingTrips = NSLocalizedString("Upcoming_Trips", comment: "")
        static var getawayAlerts = NSLocalizedString("Getaway_Alerts", comment: "")
        static var favorites = NSLocalizedString("Favorites", comment: "")
        static var ownershipUnits = NSLocalizedString("Ownership/Units", comment: "")
        static var resortDirectory = NSLocalizedString("Resort_Directory", comment: "")
        static var intervalHD = NSLocalizedString("Interval_HD", comment: "")
        static var magazines = NSLocalizedString("Magazines", comment: "")
        static var signOut = NSLocalizedString("Sign_Out", comment: "")
        
    }
    
    //***** common  structure to provide all controller title string *****//
    struct ControllerTitles {
        
        static var privacyLegalViewController = NSLocalizedString("Privacy/Legal", comment: "")
        static var vacationSearchDestinationController = NSLocalizedString("Select Destinations or Resorts", comment: "")
        static var searchResultViewController = NSLocalizedString("Search Results", comment: "")
        static var availablePointToolViewController = NSLocalizedString("Available Point Tool", comment: "")
        static var floatDetailViewController = NSLocalizedString("Additional Unit Details", comment: "")
        static var clubresortsViewController = NSLocalizedString("Club Resorts", comment: "")
        static var bedroomSizeViewController = NSLocalizedString("Bedroom_Size", comment: "")
        static var loginHelpViewController = NSLocalizedString("Login Help", comment: "")
        static var JoinTodayViewController = NSLocalizedString("Join_Today", comment: "")
        static var calendarViewController = NSLocalizedString("Pick_Date", comment: "")
        static var accomodationCertsDetailController = NSLocalizedString("My Certificates", comment: "")
        static var bookYourSelectionController = NSLocalizedString("Choose What To Use", comment: "")
        static var vacationSearchTabBarController = NSLocalizedString("Vacation_Search", comment: "")
        static var dashboardTableViewController = NSLocalizedString("Home", comment: "")
        static var upComingTripDetailController = NSLocalizedString("Trip_Details", comment: "")
        static var myUpcomingTripViewController = NSLocalizedString("My_Upcoming_Trips", comment: "")
        static var ownershipViewController = NSLocalizedString("My_Ownership/Units", comment: "")
        static var memberShipViewController = NSLocalizedString("My_Membership", comment: "")
        static var relinquishmentViewController = NSLocalizedString("Relinquishment_Select", comment: "")
        static var resortDirectoryViewController = NSLocalizedString("Resort Directory", comment: "")
        static var favoritesViewController = NSLocalizedString("Favorites", comment: "")
        static var detailMapViewController = NSLocalizedString("Units Map", comment: "")
        static var getawayAlertsViewController = NSLocalizedString("Getaway Alerts", comment: "")
        static var creategetawayAlertsViewController = NSLocalizedString("Create a Getaway Alert", comment: "")
        static var editgetawayAlertsViewController = NSLocalizedString("Edit Getaway Alert", comment: "")
        static var intervalHDIpadControllerTitle = NSLocalizedString("Interval_HD", comment: "")
        static var magazinesControllerTitle = NSLocalizedString("Magazines", comment: "")
        static var whoWillBeCheckingInControllerTitle = NSLocalizedString("Who will be checking-in?", comment: "")
        static var checkOutControllerTitle = NSLocalizedString("Check Out", comment: "")
        static var relinquishmentSelectiongControllerTitle = NSLocalizedString("Relinquishment Selection", comment: "")
        static var confirmationControllerTitle = NSLocalizedString("Confirmation", comment: "")
        static var intervalHDiPadControllerTitle =  NSLocalizedString("IntervalHDIpadPlayerViewController", comment: "")
        static var clubpointselection = NSLocalizedString("Club Point Selection", comment: "")
        static var selectedControllerTitle = ""
        static var sorting = NSLocalizedString("Sorting", comment: "")
        static var choosewhattouse = NSLocalizedString("Choose what to use", comment: "")
    }
    
    //***** Common structure for custom cell identifiers ******//
    
    struct cellIdentifiers{
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
        static var selectedSearchSegment = "Exchange"
        static var getaways = NSLocalizedString("Getaways", comment: "")
        static var exchange = NSLocalizedString("Exchange", comment: "")
        static var searchBoth = NSLocalizedString("Search Both", comment: "")
        static var flexchangeLabelText = "FLEXCHANGE"
        static var getawaysLabelText = NSLocalizedString("TOP 10 GETAWAYS", comment: "")
        static var getawaysIpadText = NSLocalizedString("Top 10 Getaway Destinations", comment: "")
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
        static var insuranceCell = "EplusTableViewCell"
        static var modifyInsuranceCell = "ModifyTripInsurance"
        static var purchasedInsuranceCell = "PurchasedTripInsurence"
        static var upComingTripCell = "UpComingTripCell"
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
        
        static var dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        static var yyyymmddDateFormat = "yyyy-MM-dd"
    }
    
    //***** common  structure to provide all Payment Selection View Controller CellIdentifiers And HardCoded Strings *****//
    struct PaymentSelectionViewControllerCellIdentifiersAndHardCodedStrings {
        
        static var cvvAlertTitle = NSLocalizedString("Please enter the credit card CVV code", comment: "")
        static var cvvandExpiryDateAlertTitle = NSLocalizedString("Your card is expired. Please enter your credit card CVV code and the new expiration date.", comment: "")
    }
    
    //***** common  structure to provide all CheckOut IPad View Controller CellIdentifiers And HardCoded Strings *****//
    struct CheckOutIPadViewControllerCellIdentifiersAndHardCodedStrings {
        
        static var headerCell = "HeaderCell"
        static var agreeToFeesCell = "AgreeToFeesCell"
        static var acceptedTermAndConditionString = NSLocalizedString("I have read and accepted the Terms and Conditions and Privacy Policy", comment: "")
        static var acknowledgeAndAgreeString = NSLocalizedString("I acknowledge and agree that the Mandatory Resort Fees will be payable to the resort.", comment: "")
        static var agreedToFeesString = NSLocalizedString("Agreed to Fees", comment: "")
        
        static var slideToAgreeToFeesString = NSLocalizedString("Slide to agree to Fees", comment: "")
        
        static var slideToAgreeAndPayString = NSLocalizedString("Slide to Agree and Pay", comment: "")
        
        static var selectYourPaymentMethodString = NSLocalizedString("Select your payment method", comment: "")
        static var paymentMethodLabelString = NSLocalizedString("Payment Method", comment: "")
        
        static var additionalAdvisementLabelString = NSLocalizedString("Additional Advisements", comment: "")
        static var additionalAdvisementTitle = NSLocalizedString("ADDITIONAL INFORMATION", comment: "")
        
        
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
        
        static var gatewayAlerts = NSLocalizedString("Getaway_Alerts", comment: "")
        static var myUpcomingTrips = NSLocalizedString("My_Upcoming_Trips", comment: "")
        static var planVacation = NSLocalizedString("Plan_a_Vacation", comment: "")
        
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
    }
    
    //***** Common structure for dynamic strings combinining strings *****//
    
    struct getDynamicString {
         static var clubInterValPointsUpTo = NSLocalizedString("Club Interval Gold Points up to", comment: "")
         static var andString = NSLocalizedString("and", comment: "")
        static var moreString = NSLocalizedString("more", comment: "")
        static var fromString = NSLocalizedString("From ", comment:"")
        static var weekString = NSLocalizedString(" Wk.", comment:"")
    }
    
    //***** Common structure for font names and type *****//
    
    struct fontName {
        
        
        static var helveticaNeue = "HelveticaNeue"
        static var helveticaNeueMedium = "HelveticaNeue-Medium"
        static var helveticaNeueBold = "Helvetica-Bold"
    }
    
    //***** common  structure to provide all enableTouchId messages and titles *****//
    struct enableTouchIdMessages {
        
        static var reasonString = "Authentication is needed to login."
        static var authenticationFailedTitle = "Enable Touch ID"
        static var authenticationFailedMessage = "There was a problem verifying your identity."
        static var systemCancelMessage = "Authentication was cancelled by the system."
        static var defaultMessage = "Touch Id can not be configured "
        static var otherMessage = "There is no touch id feature exist."
        static var onSuccessMessage = "Please login with your Login ID and \n Password in order to activate Touch Id"
        static var onTouchCancelMessage = "Touch Id was canceled\n Login with your Login ID and Password"
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
        
        static var selectMembership = NSLocalizedString("Choose Membership", comment: "")//"Select Membership"
        static var sharingOptions = NSLocalizedString("Sharing Options", comment: "")//"Select Sharing option"
        static var noMatches = NSLocalizedString("No matches right now", comment: "")
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
        static let pointsInformationLabelText = "Points:"
        static let expirationdateInformationLabelText = "Expiration Date:"
        static let pointsearnedByInformationLabelText = "Points Earned by:"
        static let availablePointsinformationLabelText = "Available Points"
        static let pointbalanceInformationlableText = "if no date is selected the Available Points Balance displayed is based on today's date."
        static let donebuttoncellIdentifier = "donebuttoncell"
        struct availablePointsAsOfTableViewCell {
            static let pointasOflabelText = "Points as of:"
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
            static let callresortbuttonTitle = NSLocalizedString("Call_your_resort", comment: "")
            static let donothaveresortLabelText = NSLocalizedString("Don't_have_your_\n_resort details?", comment: "")
        }
        //FloatDetailsCheckIndateTableViewCell
        struct floatDetailsCheckIndateTableViewCell {
            static let checkInDateInformationLabelText = NSLocalizedString("Check_in_date", comment: "")
        }
        //FloatSaveAndCancelButtonTableViewCell
        struct floatSaveAndCancelButtonTableViewCell {
            static let saveFloatDetailButtonTitle = "Save Unit Details"
            static let cancelButtonTitle = NSLocalizedString("Cancel", comment:"")
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
        static let ownershipHeaderTitletext = "Ownerships"
        static let switchMembershipAlertMessage = "You have chosen to use a different membership account. Please note, benefit and exchange access may change. Would you like to continue?"
        static let switchMembershipAlertTitle = "You are Switchinig Memberships"
        //membershipDetailTableViewCell
        struct membershipDetailTableViewCell{
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
        struct ownerShipDetailTableViewCell{
            
            static let unitdetailLabelText = "Unit"
            static let weekDetailLabelText = "Week"
            
        }
        
    }
    
   
    
    //***** Availabel Destination viewcontroller *****//
    struct availableDestinationsTableViewController {
        static let availableDestinationCountryOrContinentsTableViewCell = "continentsorcountrycell"
        static let availableDestinationPlaceTableViewCell = "placecell"
    }
    //Properties of View
    struct viewProperties {
        static let cornerRadious :CGFloat = 3
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
        self.holdingTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector:  #selector(updateResortHoldingTimeLabel), userInfo: nil, repeats: true)
    }
    static func updateResortHoldingTimeLabel(){
        holdingTime = holdingTime - decreaseValue
        self.holdingResortForRemainingMinutes = "We are holding this unit for \(holdingTime) minutes"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.updateResortHoldingTime), object: nil)
    }
    
    static func  getWeekNumber(weekType:String) -> String {
        
        switch (weekType) {
            
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



