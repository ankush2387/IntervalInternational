//
//  Helper.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/18/16.
//  Copyright 2016 Interval International. All rights reserved.
//

import Foundation
import UIKit
import IntervalUIKit
import LocalAuthentication
import SVProgressHUD
import DarwinSDK
import RealmSwift


public class Helper{
    
    static var progressBarBackgroundView:UIView!
    static var window: UIWindow?
    //***** common function to get system access token *****//
    
    static func getSystemAccessToken(){
        let config = Config.sharedInstance
        
        // setup the logger
        logger.setup( level: config.getLogLevel(), showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true)
        // Setup Darwin API
        DarwinSDK.sharedInstance.config( config.getEnvironment(),
                                         client: config.get( .DarwinClientKey ),
                                         secret: config.get( .DarwinSecretKey ),
                                         logger:logger)
        
        //  getAccess token API call for obtain sys access token
        AuthProviderClient.getClientAccessToken( { (accessToken) in
            // Got an access token!  Save it for later use.
            
            Constant.MyClassConstants.systemAccessToken = accessToken
        },
                                                 onError:{ (error) in
                                                    SimpleAlert.alert((window?.rootViewController)!, title: "Error", message: error.localizedDescription)
        }
        )
    }
    /**
     Apply shadow on UIView or UIView subclass
     - parameter view,shadowcolor,shadowopacity,shadowoffset,shadowradius : view is UIView reference,shadowcolor is UIColor reference,shadowopacity is Float type,shadowoffset is CGSize type,shadowradious is CGFloat type.
     - returns : No value is return
     */
    
    static func applyShadowOnUIView(view:UIView,shadowcolor:UIColor,shadowopacity:Float,shadowoffset:CGSize = CGSize.zero,shadowradius:CGFloat) {
        
        view.layer.shadowColor = shadowcolor.cgColor
        view.layer.shadowOpacity = shadowopacity
        view.layer.shadowOffset = shadowoffset
        view.layer.shadowRadius = shadowradius
        view.layer.masksToBounds = false;
        view.clipsToBounds = false;
    }
    /**
     Apply Border on View
     - parameter :
     - returns : No value is return
     */
    static func applyBorderarroundView(view:UIView,bordercolor:UIColor,borderwidth:CGFloat,cornerradious:CGFloat) {
        
        view.layer.borderColor = bordercolor.cgColor
        view.layer.borderWidth = borderwidth
        view.layer.cornerRadius = cornerradious
    }
    /**
     Apply Corner radious to view
     - parameter view,cornerradious : view is UIView reference,cornerradious is CGFloat
     - returns : No value is returned
     */
    static func applyCornerRadious(view:UIView,cornerradious:CGFloat = 1){
        view.layer.cornerRadius = cornerradious
    }
    
    //***** Common function to format the date *****//
    static func getWeekDay(dateString:NSDate, getValue: String) -> String {
        let dateFormatter = DateFormatter()
        switch getValue {
        case "Date":
            dateFormatter.dateFormat = "d"
            var dateFromString = dateFormatter.string(from: dateString as Date)
            if(dateFromString.characters.count == 1){
                dateFromString = "0\(dateFromString)"
            }
            return dateFromString
        case "Month":
            dateFormatter.dateFormat = "LLL"
            let dateFromString = dateFormatter.string(from: dateString as Date)
            return dateFromString
        case "Weekday":
            dateFormatter.dateFormat = "EEEE"
            let dateFromString = dateFormatter.string(from: dateString as Date)
            return dateFromString
        case "Year":
            dateFormatter.dateFormat = "yyyy"
            let dateFromString = dateFormatter.string(from: dateString as Date)
            return dateFromString
        default :
            dateFormatter.dateFormat = "yyyy"
            let dateFromString = dateFormatter.string(from: dateString as Date)
            return dateFromString
            
        }
    }
    
    //***** common  function that  takes weekday as int value and return weekday name *****//
    static  func getWeekdayFromInt(weekDayNumber:Int) -> String {
        
        switch(weekDayNumber) {
            
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
    
    //***** common  function that  takes month as int value and return month  name *****//
    static func getMonthnameFromInt(monthNumber:Int) -> String {
        
        switch(monthNumber) {
            
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return ""
        }
    }
    
    //***** common  function that  takes UIView and color to and gradient view on passed view *****//
    static func addLinearGradientToView(view: UIView, colour: UIColor, transparntToOpaque: Bool, vertical: Bool)
    {
        let gradient = CAGradientLayer()
        let gradientFrame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        gradient.frame = gradientFrame
        
          let  colours = [
                colour.cgColor,
                colour.withAlphaComponent(0.7).cgColor,
                colour.withAlphaComponent(0.95).cgColor,
                colour.withAlphaComponent(1).cgColor,
                colour.withAlphaComponent(1).cgColor,
                UIColor.clear.cgColor
            ]
        
        
        if transparntToOpaque == true
        {
            gradient.locations = [-0.2,0.25,0.50,0.75]
           
        }
        
        if vertical == true
        {
            gradient.startPoint =  CGPoint(x:1.0, y: 0.5)
            gradient.endPoint =  CGPoint(x: 0.5, y: 1.0)
        }
       
        gradient.colors = colours
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // function for float week gredient color view
   static func addGredientColorOnFloatSavedCell(view:UIView) {
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        let colours = [UIColor(red: 175.0/255.0, green: 215.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor, UIColor.white.cgColor]
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    
        gradient.colors = colours
        view.layer.insertSublayer(gradient, at: 0)

    }

    //***** function to disable interactio with UI when API call is running until we got a response or error by adding new layer *****//
    static func addServiceCallBackgroundView(view:UIView){
        
        
        let window = UIApplication.shared.keyWindow!
        progressBarBackgroundView = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height))
        
        progressBarBackgroundView.backgroundColor = UIColor.clear
        window.addSubview(progressBarBackgroundView)
        
    }
    
    //***** function to remove disable layer and make UI interaction enable *****//
    static func removeServiceCallBackgroundView(view:UIView){
        
        self.progressBarBackgroundView.removeFromSuperview()
    }
    
    //***** common function that contains signIn API call with user name and password *****//
    static func loginButtonPressed(sender:UIViewController, userName:String, password:String, completionHandler:@escaping (_ success:Bool)->())
    {
        Constant.MyClassConstants.signInRequestedController = sender
        if Reachability.isConnectedToNetwork() == true {
            logger.debug("Attempting oauth with \(userName) and \(password)")
            showProgressBar(senderView:sender)
            // Try to do the OAuth Request to obtain an access token
            AuthProviderClient.getAccessToken( userName, password: password,onSuccess:{
                (accessToken) in
                //we are redirected to the success block but the access token is nil we check it first
                
                if(accessToken.token != nil) {
                    // Next, get the contact information.  See how many memberships this user has.
                    UserContext.sharedInstance.accessToken = accessToken
                    // let the caller UI know the status of the login
                    completionHandler(true)
                }
                else {
                    hideProgressBar(senderView:sender)
                    SimpleAlert.alert(sender, title:Constant.AlertErrorMessages.tryAgainError, message: Constant.AlertErrorMessages.loginFailedError)
                    completionHandler(false)
                }
                // Got an access token!  Save it for later use.
                // Next, get the contact information.  See how many memberships this user has.
            },
                                               onError:{ (error) in
                                                SVProgressHUD.dismiss()
                                                removeServiceCallBackgroundView(view: sender.view)
                                                logger.warning(error.description)
                                                SimpleAlert.alert(sender, title:Constant.AlertErrorMessages.tryAgainError, message: "\(error.localizedDescription)")
                                                completionHandler(false)
            }
            )
        }
        else{
            
            SimpleAlert.alert(sender, title:Constant.AlertErrorMessages.networkError, message: Constant.AlertMessages.networkErrorMessage)
            completionHandler(false)
        }
    }
    
    //***** function to get profile when we have found valid access token from server *****//
    static func accessTokenDidChange(sender: UIViewController){
        
        if Reachability.isConnectedToNetwork() == true{
            
            logger.debug("Attempting to get user info")
            
            //***** Try to do the OAuth Request to obtain an access token *****//
            UserClient.getCurrentProfile(UserContext.sharedInstance.accessToken,
                                         onSuccess:{(contact) in
                                            // Got an access token!  Save it for later use.
                                            SVProgressHUD.dismiss()
                                            removeServiceCallBackgroundView(view: sender.view)
                                            UserContext.sharedInstance.contact = contact
                                            
                                            //***** Next, get the contact information.  See how many memberships this user has. *****//
                                            
                                            contactDidChange(sender: sender)
            },
                                         onError:{(error) in
                                            SVProgressHUD.dismiss()
                                            removeServiceCallBackgroundView(view: sender.view)
                                            logger.warning(error.description)
                                            SimpleAlert.alert(sender, title:Constant.AlertErrorMessages.loginFailed, message: error.localizedDescription)
            }
                
                
                
            
                
            )
        }else{
            SimpleAlert.alert(sender, title:Constant.AlertErrorMessages.networkError, message: Constant.AlertMessages.networkErrorMessage)
        }
    }
    
    
    
    //***** functin called when we have found valid profileCurrent for user *****//
    static func contactDidChange(sender:UIViewController) {
        
        //***** If this contact has more than one membership, then show the Choose Member form.Otherwise, select the default (only) membership and continue.  There must always be at lease one membership. *****//
        if let contact = UserContext.sharedInstance.contact {
            
            if contact.hasMembership() {
                
                if contact.memberships!.count == 1 {
                    
                    if(Constant.MyClassConstants.signInRequestedController is SignInPreLoginViewController ) {
                        
                        UserContext.sharedInstance.selectedMembership = contact.memberships![0]
                        CreateActionSheet().membershipWasSelected()
                        
                    }
                    else {
                        
                        UserContext.sharedInstance.selectedMembership = contact.memberships![0]
                        CreateActionSheet().membershipWasSelected()
                    }
                }
                else {
                    
                    //***** TODO: Display Modal to allow the user to select a membership! *****//
                    if (UIDevice.current.userInterfaceIdiom == .pad) {
                        
                        if(sender is SignInPreLoginViewController){
                            sender.perform(#selector(SignInPreLoginViewController.createActionSheet(_:)), with: nil, afterDelay: 0.0)
                        }else{
                            sender.perform(#selector(LoginIPadViewController.createActionSheet(_:)), with: nil, afterDelay: 0.0)
                        }
                        
                    }
                    else {
                        
                        if(sender is SignInPreLoginViewController){
                            let userInfo: [String: String] = [
                                Constant.omnitureEvars.eVar81 : Constant.omnitureCommonString.preloginChooseMemberShip
                            ]
                            
                            ADBMobile.trackAction(Constant.omnitureEvents.event81, data: userInfo)
                        }
                        CreateActionSheet().createActionSheet(sender)
                        
                    }
                }
            }
            else {
                
                logger.error("The contact \(contact.contactId) has no membership information!")
                SimpleAlert.alert(sender, title:Constant.AlertErrorMessages.loginFailed, message: Constant.AlertMessages.noMembershipMessage)
            }
        }
    }
    
    //***** Common function for user Favorites resort API call after successfull call *****//
    static func getUserFavorites(){
        if(UserContext.sharedInstance.accessToken != nil){
        UserClient.getFavoriteResorts(UserContext.sharedInstance.accessToken, onSuccess: { (response) in
            Constant.MyClassConstants.favoritesResortArray.removeAll()
            for resortcode in [response][0] {
                Constant.MyClassConstants.favoritesResortCodeArray.add(resortcode)
            }
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constant.notificationNames.reloadFavoritesTabNotification), object: nil)
            
        })
        { (error) in
        }
        }
    }
    
    //**** Common function to get upcoming trips. ****//
   static func getUpcomingTripsForUser(){
        UserClient.getUpcomingTrips(UserContext.sharedInstance.accessToken, onSuccess: {(upComingTrips) in
            print("Call 4",upComingTrips)
            Constant.MyClassConstants.upcomingTripsArray = upComingTrips
            
            for trip in upComingTrips { if((trip.type) != nil) {
                
                print(trip.type as Any)
                
                }
            }
            Constant.MyClassConstants.isEvent2Ready = Constant.MyClassConstants.isEvent2Ready + 1

            if(Constant.MyClassConstants.isEvent2Ready > 1) {	 	               sendOmnitureTrackCallForEvent2()
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constant.notificationNames.refreshTableNotification), object: self)
        }, onError: {(error) in
            
            Constant.MyClassConstants.isEvent2Ready = Constant.MyClassConstants.isEvent2Ready + 1
            
            if(Constant.MyClassConstants.isEvent2Ready > 1) {	 	               sendOmnitureTrackCallForEvent2()
            }

        })
    }
    
    // get Countries
    static func getCountry(viewController:UIViewController) {
        showProgressBar(senderView: viewController)
        Constant.GetawaySearchResultGuestFormDetailData.countryListArray.removeAll()
        Constant.GetawaySearchResultGuestFormDetailData.countryCodeArray.removeAll()
        LookupClient.getCountries(Constant.MyClassConstants.systemAccessToken!, onSuccess: { (response) in
            
            for country in (response ){
                Constant.GetawaySearchResultGuestFormDetailData.countryListArray.append(country.countryName!)
                Constant.GetawaySearchResultGuestFormDetailData.countryCodeArray.append(country.countryCode!)
            }
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewController.view)

        }) { (error) in
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewController.view)
            SimpleAlert.alert(viewController, title:Constant.AlertErrorMessages.errorString, message: error.description)
        }
        
    }
    
    static func getStates(country:String, viewController:UIViewController) {
        showProgressBar(senderView: viewController)
        Constant.GetawaySearchResultGuestFormDetailData.stateListArray.removeAll()
        LookupClient.getStates(Constant.MyClassConstants.systemAccessToken!, countryCode: country, onSuccess: { (response) in
            SVProgressHUD.dismiss()
            for state in response{
                Constant.GetawaySearchResultGuestFormDetailData.stateListArray.append(state.name!)
                Constant.GetawaySearchResultGuestFormDetailData.stateCodeArray.append(state.code!)
            }
            removeServiceCallBackgroundView(view: viewController.view)
        }, onError: { (error) in
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewController.view)
            Constant.GetawaySearchResultGuestFormDetailData.stateListArray = ["California","Pennyslvenia"]
            SimpleAlert.alert(viewController, title:Constant.AlertErrorMessages.errorString, message: error.description)
        })
        
    }
    
    
    //Relinquishment details
    static func getRelinquishmentDetails(resortCode:String?, viewController:UIViewController) {
        showProgressBar(senderView: viewController)
        
        DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode!, onSuccess: { (response) in
            
            Constant.MyClassConstants.resortsDescriptionArray = response
            Constant.MyClassConstants.imagesArray.removeAllObjects()
            let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
            for imgStr in imagesArray {
                print(imgStr.url!)
                if(imgStr.size == Constant.MyClassConstants.imageSize) {
                    
                    Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                }
            }
            
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewController.view)
            viewController.performSegue(withIdentifier: Constant.segueIdentifiers.showRelinguishmentsDetailsSegue, sender: self)
        })
        { (error) in
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewController.view)
            SimpleAlert.alert(viewController, title:Constant.AlertErrorMessages.errorString, message: error.description)
        }
    
    }


    //***** common function that contains API call for  searchResorts with todate and resort code *****//
    static func resortDetailsClicked(toDate: NSDate, senderVC : UIViewController) {
        
        if Reachability.isConnectedToNetwork() == true {
            let searchResortRequest = RentalSearchResortsRequest()
            searchResortRequest.checkInDate = toDate as Date
            searchResortRequest.resortCodes = Constant.MyClassConstants.resortCodesArray
            showProgressBar(senderView:senderVC)
            RentalClient.searchResorts(UserContext.sharedInstance.accessToken, request: searchResortRequest, onSuccess: { (response) in
                Constant.MyClassConstants.showAlert = false
                Constant.MyClassConstants.resortsArray.removeAll()
                Constant.MyClassConstants.resortsArray = response.resorts
                //DarwinSDK.logger.debug(response.resorts[0].promotions)
                hideProgressBar(senderView: senderVC)
                if(senderVC is VacationSearchViewController || senderVC is VacationSearchIPadViewController ) {
                    
                    // omniture tracking with event 33
                    let userInfo: [String: Any] = [
                        Constant.omnitureCommonString.listItem: Constant.MyClassConstants.selectedDestinationNames,
                        Constant.omnitureEvars.eVar41 : Constant.omnitureCommonString.vactionSearch,
                        Constant.omnitureEvars.eVar23 : Constant.omnitureCommonString.primaryAlternateDateAvailable,
                        Constant.omnitureEvars.eVar36: "\(Helper.omnitureSegmentSearchType(index:  Constant.MyClassConstants.searchForSegmentIndex))-\(Constant.MyClassConstants.resortsArray.count)" ,
                        Constant.omnitureEvars.eVar39: "" ,
                        Constant.omnitureEvars.eVar48: "",
                        Constant.omnitureEvars.eVar53: "\(Constant.MyClassConstants.resortsArray.count)",
                        Constant.omnitureEvars.eVar54: ""
                    ]
                    
                    ADBMobile.trackAction(Constant.omnitureEvents.event33, data: userInfo)

                    
                    senderVC.performSegue(withIdentifier: Constant.segueIdentifiers.searchResultSegue, sender: self)
                }else if (senderVC is GetawayAlertsIPhoneViewController){
                    
                    if(Constant.RunningDevice.deviceIdiom == .pad){
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! VacationSearchResultIPadController
                        
                        let transitionManager = TransitionManager()
                        senderVC.navigationController?.transitioningDelegate = transitionManager
                        senderVC.navigationController!.pushViewController(viewController, animated: true)
                    }else{
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.vacationSearchController) as! SearchResultViewController
                        
                        let transitionManager = TransitionManager()
                        senderVC.navigationController?.transitioningDelegate = transitionManager
                        
                        senderVC.navigationController!.pushViewController(viewController, animated: true)
                    }
                    
                    
                    hideProgressBar(senderView: senderVC)
                }
                
            }, onError: { (error) in
                
                SVProgressHUD.dismiss()
                Helper.removeServiceCallBackgroundView(view: senderVC.view)
                Constant.MyClassConstants.showAlert = true
                SimpleAlert.alert(senderVC, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            })
        }
        else {
            SVProgressHUD.dismiss()
            Helper.removeServiceCallBackgroundView(view: senderVC.view)
            SimpleAlert.alert(senderVC, title:Constant.AlertErrorMessages.networkError, message: Constant.AlertMessages.networkErrorMessage)
        }
        
    }
    
    //***** function to get all local storage object on the basis of selected membership number *****//
    static func getLocalStorageWherewanttoGo() -> Results <RealmLocalStorage> {
        
        let realm = try! Realm()
        let Membership = UserContext.sharedInstance.selectedMembership
        let SelectedMembershipNumber = Membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = SelectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let realmLocalStorage = realm.objects(RealmLocalStorage.self).filter("membeshipNumber == '\(requiredMemberNumber)'")
        if(realmLocalStorage.count > 0) {
            return realmLocalStorage
        }
        else {
            
            let realm = try! Realm()
            let allDest = realm.objects(AllAvailableDestination.self)
            for obj in allDest {
                print(obj.destination)
                Constant.MyClassConstants.whereTogoContentArray.add(obj.destination)
            }
            return realmLocalStorage
        }

    }
    static func getLocalStorageWherewanttoTrade() -> Results <OpenWeeksStorage> {
        
        let realm = try! Realm()
        let Membership = UserContext.sharedInstance.selectedMembership
        let SelectedMembershipNumber = Membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = SelectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let realmLocalStorage = realm.objects(OpenWeeksStorage.self).filter("membeshipNumber == '\(requiredMemberNumber)'")
        
        return realmLocalStorage
        
    }
    //***** function to get all destination class objects from Realm storage *****//
    static func getLocalStorageAllDest() -> Results<AllAvailableDestination>{
        
        let realm = try! Realm()
        let allDest = realm.objects(AllAvailableDestination.self)
        return allDest
    }
    //***** function that remove all objects stored in all destionation class *****//
    static func deleteObjectFromAllDest() {
        
        let realm = try! Realm()
        let allDest = realm.objects(AllAvailableDestination.self)
        try! realm.write {
            realm.delete(allDest)
        }
        
    }
    //***** function that get all Realm storage data list for destination list or resort list according to selected membership number and initialize array globaly *****//
    static func InitializeArrayFromLocalStorage () {
        
        Constant.MyClassConstants.whereTogoContentArray.removeAllObjects()
        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.removeAllObjects()
        Constant.MyClassConstants.vacationSearchDestinationArray.removeAllObjects()
        
        let realm = try! Realm()
        let Membership = UserContext.sharedInstance.selectedMembership
        let SelectedMembershipNumber = Membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = SelectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let realmLocalStorage = realm.objects(RealmLocalStorage.self).filter("membeshipNumber == '\(requiredMemberNumber)'")
        if (realmLocalStorage.count > 0) {
            for obj in realmLocalStorage {
                let destination = obj.destinations
                for destname in destination {
                    Constant.MyClassConstants.whereTogoContentArray.add("\(destname.destinationName), \(destname.territorrycode)")
                    Constant.MyClassConstants.selectedDestinationNames = Constant.MyClassConstants.selectedDestinationNames.appending("\(destname.destinationName) \(destname.territorrycode) ,")
                    Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(destname.destinationId)
                    
                    Constant.MyClassConstants.vacationSearchDestinationArray.add(destname.destinationName)
                }
                let resort = obj.resorts
                for resortname in resort {
                    if(resortname.resortArray.count == 0) {
                        Constant.MyClassConstants.whereTogoContentArray.add(resortname.resortName)
                        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(resortname.resortCode)
                         Constant.MyClassConstants.selectedDestinationNames = Constant.MyClassConstants.selectedDestinationNames.appending("\(resortname.resortCode) ,")
                    }
                    else {
                        Constant.MyClassConstants.whereTogoContentArray.add(resortname.resortArray)
                        Constant.MyClassConstants.realmStoredDestIdOrCodeArray.add(resortname.resortArray[0].resortCode)
                    }
                }
            }
        }
        else {
            
            let realm = try! Realm()
            let allDest = realm.objects(AllAvailableDestination.self)
            for obj in allDest {
                Constant.MyClassConstants.whereTogoContentArray.add(obj.destination)
            }
        }
    }
    
    //***** Function that get all objects of type Open Weeks from Realm storage *****//
    
    static func InitializeOpenWeeksFromLocalStorage () {
        SVProgressHUD.show()
        Constant.MyClassConstants.relinquishmentIdArray.removeAllObjects()
        Constant.MyClassConstants.whatToTradeArray.removeAllObjects()
        Constant.MyClassConstants.idUnitsRelinquishmentDictionary.removeAllObjects()
        Constant.MyClassConstants.relinquishmentUnitsArray.removeAllObjects()
        Constant.MyClassConstants.floatRemovedArray.removeAllObjects()
        Constant.MyClassConstants.realmOpenWeeksID.removeAllObjects()

        let realm = try! Realm()
        let Membership = UserContext.sharedInstance.selectedMembership
        let SelectedMembershipNumber = Membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = SelectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let realmLocalStorage = realm.objects(OpenWeeksStorage.self).filter("membeshipNumber == '\(requiredMemberNumber)'")
        if (realmLocalStorage.count > 0) {
            for obj in realmLocalStorage {
                let openWeeks = obj.openWeeks
                for openWk in openWeeks {
                    if(openWk.openWeeks.count > 0){
                        
                        for object in openWk.openWeeks {
                            
                            Constant.MyClassConstants.realmOpenWeeksID.add(object.relinquishmentID)
                        let tempDict = NSMutableDictionary()
                            if(object.isFloat){
                            if(object.isFloatRemoved){
                                Constant.MyClassConstants.floatRemovedArray.add(object)
                            }else if(object.floatDetails.count > 0 && !object.isFloatRemoved && object.isFromRelinquishment){
                                Constant.MyClassConstants.whatToTradeArray.add(object)
                                Constant.MyClassConstants.relinquishmentIdArray.add(object.relinquishmentID)
                            }
                            }else{
                                Constant.MyClassConstants.whatToTradeArray.add(object)
                                Constant.MyClassConstants.relinquishmentIdArray.add(object.relinquishmentID)
                            }
                            Constant.MyClassConstants.idUnitsRelinquishmentDictionary.setValue(object.unitDetails, forKey: object.relinquishmentID)
                            tempDict.setValue(object.unitDetails, forKey: object.relinquishmentID)
                            if(!object.isFloatRemoved){
                            Constant.MyClassConstants.relinquishmentUnitsArray.add(tempDict)
                            }
                        }
                        
                    }else{
                        
                        Constant.MyClassConstants.whatToTradeArray.add(openWk.pProgram)
                        Constant.MyClassConstants.relinquishmentIdArray.add(openWk.pProgram[0].relinquishmentId)
                        Constant.MyClassConstants.relinquishmentAvailablePointsProgram = Int((openWk.pProgram[0].availablePoints))
                    }
                }
            }
        }else{
            print("No Data")
        }
        
        SVProgressHUD.dismiss()
    }
    
    //***** function that returns AreaOfInfluenceDestination list according to selected membership number that send to server for search dates API call *****//
    static func getAllDestinationFromLocalStorage() -> [AreaOfInfluenceDestination] {
        
        var influenceDestList = [AreaOfInfluenceDestination]()
        
        let realm = try! Realm()
        let Membership = UserContext.sharedInstance.selectedMembership
        let SelectedMembershipNumber = Membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = SelectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let realmLocalStorage = realm.objects(RealmLocalStorage.self).filter("membeshipNumber == '\(requiredMemberNumber)'")
        if (realmLocalStorage.count > 0) {
            
            for obj in realmLocalStorage {
                let destinations = obj.destinations
                for destination in destinations  {
                    let dest = AreaOfInfluenceDestination()
                    dest.aoiId = destination.aoid
                    dest.address?.countryCode = destination.countryCode
                    dest.destinationId = destination.destinationId
                    dest.destinationName = destination.destinationName
                    dest.address?.territoryCode = destination.territorrycode
                    influenceDestList.append(dest)
                }
            }
        }
        return influenceDestList
    }
    //***** function that returns Resort list according to selected membership number that send to server for search dates API call *****//
    static func getAllResortsFromLocalStorage() -> [Resort]  {
        
        var influenceResortList = [Resort]()
        
        let realm = try! Realm()
        let Membership = UserContext.sharedInstance.selectedMembership
        let SelectedMembershipNumber = Membership?.memberNumber
        var requiredMemberNumber = ""
        if let membernumber = SelectedMembershipNumber {
            requiredMemberNumber = membernumber
        }
        let realmLocalStorage = realm.objects(RealmLocalStorage.self).filter("membeshipNumber == '\(requiredMemberNumber)'")
        if (realmLocalStorage.count > 0) {
            
            for obj in realmLocalStorage {
                let resorts = obj.resorts
                for resot in resorts  {
                    let reosrt = Resort()
                    reosrt.resortName = resot.resortName
                    reosrt.resortCode = resot.resortCode
                    reosrt.address?.cityName = resot.resortCityName
                    reosrt.address?.territoryCode = resot.territorrycode
                    reosrt.address?.countryCode = resot.countryCode
                    influenceResortList.append(reosrt)
                }
            }
        }
        
        return influenceResortList
        
    }
    
    //***** function to return unitsize bedroom type in short form from full name *****//
    static func getBrEnums(brType:String) -> String {
        
        switch brType {
            
        case UnitSize.Studio.rawValue:
            return Constant.roomType.studio
        case UnitSize.OneBedroom.rawValue:
            return Constant.roomType.oneBedRoom
        case UnitSize.TwoBedroom.rawValue:
            return Constant.roomType.twoBedRoom
        case UnitSize.ThreeBedroom.rawValue:
            return Constant.roomType.threeBedRoom
        case UnitSize.FourBedroom.rawValue:
            return Constant.roomType.fourBedRoom
        default:
            return Constant.roomType.unKnown
        }
    }
    //***** function to return unitsize kitchen type in lower case with space form server kitchen type *****//
    static func getKitchenEnums(kitchenType:String) -> String {
        
        switch kitchenType {
            
        case KitchenType.NoKitchen.rawValue:
            return Constant.kitchenType.noKitchen
        case KitchenType.LimitedKitchen.rawValue:
            return Constant.kitchenType.limitedKitchen
        case KitchenType.FullKitchen.rawValue:
            return Constant.kitchenType.fullKitchen
        default:
            return Constant.kitchenType.unKnown
        }
    }
    //***** function to return unitsize kitchen type in lower case with space form server kitchen type *****//
    static func getBedroomNumbers(bedroomType:String) -> String {
        
        switch bedroomType {
            
        case UnitSize.Studio.rawValue:
            return "Studio"
        case UnitSize.OneBedroom.rawValue:
            return "1 Bedroom"
        case UnitSize.TwoBedroom.rawValue:
            return "2 Bedroom"
        case UnitSize.ThreeBedroom.rawValue:
            return "3 Bedroom"
        case UnitSize.FourBedroom.rawValue:
            return "4 Bedroom"
        default:
            return "Unknown"
        }
    }
    
    static func getSearchDates() ->(Date, Date){
        
        var fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow/2), to: Constant.MyClassConstants.vacationSearchShowDate, options: [])!
        
        var toDate:Date!
        if (fromDate.isGreaterThanDate(Constant.MyClassConstants.todaysDate)) {
            
            toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: (Constant.MyClassConstants.totalWindow/2), to: Constant.MyClassConstants.vacationSearchShowDate, options: [])!
        }
        else {
            _ = Helper.getDifferenceOfDates()
            fromDate = Constant.MyClassConstants.todaysDate
            toDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: (Constant.MyClassConstants.totalWindow) + Helper.getDifferenceOfDates(), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
        }
        
        if (toDate.isGreaterThanDate(Constant.MyClassConstants.dateAfterTwoYear!)) {
            
            toDate = Constant.MyClassConstants.dateAfterTwoYear
            fromDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -(Constant.MyClassConstants.totalWindow) + Helper.getDifferenceOfDatesAhead(), to: Constant.MyClassConstants.vacationSearchShowDate as Date, options: [])!
        }
        Constant.MyClassConstants.currentFromDate = fromDate
        Constant.MyClassConstants.currentToDate = toDate
        return(toDate,fromDate)
        
    }
    
    //***** common function that returns date difference between todate and fromdate *****//
    static func getDifferenceOfDates() -> Int{
        
        let cal = NSCalendar.current
        
        let returnDate = cal.dateComponents(Set<Calendar.Component>([.day]), from: Constant.MyClassConstants.vacationSearchShowDate as Date, to: Constant.MyClassConstants.todaysDate as Date)
        // let returnDate = Calendar.current.components(.Day, fromDate: Constant.MyClassConstants.vacationSearchShowDate, toDate: Constant.MyClassConstants.todaysDate, options: [])
        
        //let returnDate1 = (Calendar.current as NSCalendar).date
        
        return returnDate.day!
    }
    
    static func getUpcommingcheckinDatesDiffrence(date:Date) -> Int{
        
        let cal = NSCalendar.current
        
        let returnDate = cal.dateComponents(Set<Calendar.Component>([.day]), from: Constant.MyClassConstants.todaysDate, to: date)
        
          return returnDate.day!
    }
    //***** common function that returns date difference for two years between todate and fromdate *****//
    static func getDifferenceOfDatesAhead() -> Int{
        let cal = NSCalendar.current
        
        let returnDate = cal.dateComponents(Set<Calendar.Component>([.day]), from: Constant.MyClassConstants.vacationSearchShowDate as Date, to: Constant.MyClassConstants.dateAfterTwoYear!)
        
        return returnDate.day!
    }
    
    //***** common function that contains API call for top 10 deals *****//
    static func getTopDeals(senderVC : UIViewController){
        showProgressBar(senderView: senderVC)
        RentalClient.getTop10Deals(UserContext.sharedInstance.accessToken,onSuccess: {(response) in
            print("Call 5",response)
            Constant.MyClassConstants.topDeals = response
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.refreshTableNotification), object: nil)
            Helper.removeServiceCallBackgroundView(view: senderVC.view)
            SVProgressHUD.dismiss()
        },
                                   onError: {(error) in
                                    print("Call 5",error.localizedDescription)
                                    Helper.removeServiceCallBackgroundView(view: senderVC.view)
                                    SVProgressHUD.dismiss()
                                    SimpleAlert.alert(senderVC, title:Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
                                    
        })
    }
    
    //***** common function that contains API call to get areas with access token *****//
    static func getResortDirectoryRegionList(viewController:UIViewController) {
        
        if(Constant.MyClassConstants.systemAccessToken?.token != nil){
            
            showProgressBar(senderView: viewController)
            
            DirectoryClient.getRegions(Constant.MyClassConstants.systemAccessToken, onSuccess: {(response) in
                Constant.MyClassConstants.resortDirectoryRegionArray = response[0].regions
                if(!(viewController is ResortDirectoryTabController)){
                    
                    viewController.performSegue(withIdentifier: Constant.segueIdentifiers.resortDirectorySegue, sender: self)
                    
                }
                removeServiceCallBackgroundView(view: viewController.view)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRegionTable"), object: nil)
                SVProgressHUD.dismiss()
            },    onError: {(error) in
                removeServiceCallBackgroundView(view: viewController.view)
                SVProgressHUD.dismiss()
            })
        }
    }
    
    //***** common function that contains API call to get resorts with area code *****//
    static func getResortByAreaRequest(areaCode:Int) -> Bool {
        
        var value:Bool = false
        // let getResortByareaRequest = getResortByAreaRequest(areaCode: areaCode)
        
        DirectoryClient.getResortsByArea(UserContext.sharedInstance.accessToken, areaCode: areaCode, onSuccess: {(response) in
            Constant.MyClassConstants.resortDirectoryResortArray = response
            print(response[0].images)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.reloadRegionNotification), object: nil)
            value = true
            
        }, onError: {(error) in
            
            
            value = false
            
        })
        return value
    }
    
    //***** Function to check is resrt is favorites or not *****//
    static func isResrotFavorite(resortCode:String) -> Bool {
        var status = false
        
        if(Constant.MyClassConstants.favoritesResortCodeArray.contains(resortCode)) {
            
            status = true
        }
        return status
    }
    /***** Function to get resort directory region list *****/
    
    static func getResortsWithLatLongForShowingOnMap(request:GeoArea) -> Bool {
        var value:Bool = false
        DirectoryClient.getResortsWithinGeoArea(UserContext.sharedInstance.accessToken, geoArea: request, onSuccess: { (response) in
            Constant.MyClassConstants.resortsArray = response
            value = true
            
        }) { (error) in
            value = false
        }
        return value
    }
    
    /***** Get club resort API call for float details ******/
    
    static func getResortsByClubFloatDetails(resortCode:String, senderViewController:UIViewController, floatResortDetails:Resort){
        showProgressBar(senderView: senderViewController)
        DirectoryClient.getResortsByClub(UserContext.sharedInstance.accessToken, clubCode: resortCode, onSuccess: { (_ resorts: [Resort]) in
            hideProgressBar(senderView: senderViewController)
            Constant.MyClassConstants.clubFloatResorts = resorts
            senderViewController.performSegue(withIdentifier: Constant.floatDetailViewController.clubresortviewcontrollerIdentifier, sender: self)

            
        }) { (error) in
            
             hideProgressBar(senderView: senderViewController)
             SimpleAlert.alert(senderViewController, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
        }
    }
    
    // Switch to FloatDetailViewController
    static func navigateToViewController(senderViewController:UIViewController, floatResortDetails:Resort, isFromLockOff:Bool){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.ownershipIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.floatViewController) as! FloatDetailViewController
        viewController.floatResortDetails = floatResortDetails
        if(isFromLockOff){
            viewController.isFromLockOff = true
        }
        let transitionManager = TransitionManager()
        senderViewController.navigationController?.transitioningDelegate = transitionManager
        senderViewController.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /***** Get check-in dates API to show in calendar ******/
    static func getCheckInDatesForCalendar(senderViewController:UIViewController, resortCode:String, relinquishmentYear:Int){
        showProgressBar(senderView: senderViewController)
        DirectoryClient.getResortCalendars(UserContext.sharedInstance.accessToken, resortCode: resortCode, year: relinquishmentYear, onSuccess: { (resortCalendar: [ResortCalendar]) in
            
            SVProgressHUD.dismiss()
            self.removeServiceCallBackgroundView(view: senderViewController.view)
            if(resortCalendar.count > 0){
            Constant.MyClassConstants.relinquishmentFloatDetialMinDate = self.convertStringToDate(dateString: resortCalendar[0].checkInDate!, format: Constant.MyClassConstants.dateFormat)
            Constant.MyClassConstants.relinquishmentFloatDetialMaxDate = self.convertStringToDate(dateString: (resortCalendar.last?.checkInDate!)!, format: Constant.MyClassConstants.dateFormat)
            for calendarDetails in resortCalendar{
               print(calendarDetails.checkInDate!)
               Constant.MyClassConstants.floatDetailsCalendarDateArray.append((Helper.convertStringToDate(dateString: calendarDetails.checkInDate!, format: Constant.MyClassConstants.dateFormat)))
            }
            
            var mainStoryboard = UIStoryboard()
            if(Constant.RunningDevice.deviceIdiom == .pad) {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIPad, bundle: nil)
            }
            else {
                mainStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
            }
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.calendarViewController) as! CalendarViewController
            viewController.requestedController = Constant.MyClassConstants.relinquishmentFlaotWeek
            let transitionManager = TransitionManager()
            senderViewController.navigationController?.transitioningDelegate = transitionManager
            senderViewController.navigationController?.pushViewController(viewController, animated: true)
            }else{
                SimpleAlert.alert(senderViewController, title: Constant.AlertErrorMessages.errorString, message: Constant.AlertMessages.noDatesMessage)
            }
        
        }) { (error) in
            
            SVProgressHUD.dismiss()
            self.removeServiceCallBackgroundView(view: senderViewController.view)
            SimpleAlert.alert(senderViewController, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
        }
    }
    
    /***** common function for adding uivew as a pop up with some mesage *****/
    static func displayEmptyFavoritesMessage(requestedView:UIView) -> UIView {
        let messageView = UIView()
        
        messageView.frame = CGRect(x: 20, y: 84, width: requestedView.frame.width-40, height: requestedView.frame.height/2 + 50)
        messageView.layer.cornerRadius = 7
        messageView.backgroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        let messageLabel1 = UILabel()
        
        messageLabel1.frame = CGRect(x: 20, y: 20, width: messageView.frame.width - 40, height: 50)
        messageLabel1.text = "Oops looks like you dont have any favorites!"
        messageLabel1.numberOfLines = 2
        messageLabel1.textAlignment = NSTextAlignment.center
        messageView.addSubview(messageLabel1)
        
        let messageLabel2 = UILabel()
        messageLabel2.frame = CGRect(x: 20, y: 80, width: messageView.frame.width - 40, height: 30)
        messageLabel2.text = "You poor soul, you!"
        messageLabel2.textAlignment = NSTextAlignment.center
        messageView.addSubview(messageLabel2)
        
        let brokenHeartImageView = UIImageView()
        brokenHeartImageView.frame = CGRect(x: messageView.frame.width/2 - 25, y: 130, width: 40, height: 40)
        brokenHeartImageView.image = UIImage(named: "FavoritesIcon")
        messageView.addSubview(brokenHeartImageView)
        
        let messageLabel3 = UILabel()
        messageLabel3.frame = CGRect(x: 10, y: 180, width: messageView.frame.width - 20, height: 100)
        messageLabel3.text = "How's about you go favorite some resorts and when you come back they will be here all warm and toasty waiting for you!"
        messageLabel3.numberOfLines = 3
        messageLabel3.textAlignment = NSTextAlignment.center
        messageLabel3.font = UIFont(name: "HelveticaNeue", size: 13)
        messageView.addSubview(messageLabel3)
        
        let messageLabel4 = UILabel()
        messageLabel4.frame = CGRect(x: 20, y: 290, width: messageView.frame.width - 40, height: 20)
        messageLabel4.text = "Go on Get! "
        messageLabel4.textAlignment = NSTextAlignment.center
        messageView.addSubview(messageLabel4)
        
        return messageView
    }
    /***** common function for adding uivew as a pop up with some mesage *****/
    static func noResortView(senderView: UIView) -> UIView{
        
        let noResortView = UIView()
        let titleView = UIView()
        let titleLabel = UILabel()
        let detailView = UIView()
        let detailLabel = UILabel()
        
        
        noResortView.frame = CGRect(x: 20, y: 150, width: (UIScreen.main.bounds.width) - 40, height: Constant.MyClassConstants.runningDeviceHeight!/3)
        noResortView.backgroundColor = UIColor(red: 209.0/255.0, green: 226.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        senderView.addSubview(noResortView)
        
        titleView.frame = CGRect(x: 0, y: 0, width: noResortView.frame.size.width, height: noResortView.frame.size.height/5)
        titleView.backgroundColor = UIColor.darkGray
        noResortView.addSubview(titleView)
        
        titleLabel.frame = CGRect(x: 10, y: 0, width: noResortView.frame.size.width - 20, height: noResortView.frame.size.height/5)
        titleLabel.text = "No match found. Please select another date."
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Helvetica",size: 12)
        noResortView.addSubview(titleLabel)
        
        detailView.frame = CGRect(x: 0, y: noResortView.frame.size.height/4, width: noResortView.frame.size.width - 20, height: 3*(noResortView.frame.size.height/4))
        detailView.backgroundColor = UIColor(red: 209.0/255.0, green: 226.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        noResortView.addSubview(detailView)
        
        
        detailLabel.frame = CGRect(x: 10, y: noResortView.frame.size.height/4, width: noResortView.frame.size.width - 20, height: 3*(noResortView.frame.size.height/4))
        detailLabel.numberOfLines = 0
        detailLabel.text = "This date does not contain availability for the area you were looking for. Please check other available dates by scrolling above."
        detailLabel.textColor = UIColor.gray
        detailLabel.font = UIFont(name: "Helvetica",size: 12)
        noResortView.addSubview(detailLabel)
        
        if(Constant.RunningDevice.deviceIdiom == .pad){
            detailLabel.font = UIFont(name: "Helvetica", size:30)
            titleLabel.font = UIFont(name: "Helvetica", size:30)
        }
        
        return noResortView
    }
    
    /***** common function name mapping of tier with swich case *****/
    static func getTierImageName(tier:String) -> String{
        switch tier {
        case  "SELECT":
            return "Resort_Select"
        case "SELECT_BOUTIQUE":
            return "Resort_Select_BTQ"
        case "PREMIER":
            return "Resort_Premier"
        case "PREMIER_BOUTIQUE":
            return "Resort_Premier_BTQ"
        case "ELITE":
            return "Resort_Elite"
        case "ELITE_BOUTIQUE":
            return "Resort_Elite_BTQ"
        case "PREFFERED_RESIDENCE":
            return "Resort_Preferred_Residence"
        default:
            return ""
        }
    }
    
    //****** Function to get the resort rating category ******//
    
    static func getRatingCategory(category:String) -> String{
        switch category {
        case "OVERALL":
            return "Overall"
            
        case "RESORT_SERVICES":
            return "Resort Services"
            
        case "RESORT_PROPERTY":
            return "Resort Property"
            
        case "RESORT_ACCOMMODATIONS":
            return "Resort Accommodation"
            
        case "VACATION_EXPERIENCE":
            return "Vacation Experience"
        default:
            return ""
        }
    }
    
    
    /***** common function for API call to get resort with resort code *****/
    static func getResortWithResortCode(code:String , viewcontroller:UIViewController) {
        showProgressBar(senderView: viewcontroller)
        DirectoryClient.getResortDetails(Constant.MyClassConstants.systemAccessToken, resortCode: code, onSuccess: { (response) in
    
            Constant.MyClassConstants.resortsDescriptionArray = response
            Constant.MyClassConstants.imagesArray.removeAllObjects()
            let imagesArray = Constant.MyClassConstants.resortsDescriptionArray.images
            for imgStr in imagesArray {
                print(imgStr.url!)
                if(imgStr.size == Constant.MyClassConstants.imageSize) {
                    
                    Constant.MyClassConstants.imagesArray.add(imgStr.url!)
                }
            }
            
            if(Constant.MyClassConstants.isgetResortFromGoogleSearch == false) {
                
                if(Constant.RunningDevice.deviceIdiom == .pad) {
                    
                    
                    if(Constant.MyClassConstants.isFromExchange){
                        
                        
                        let storyBoard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
                        let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortVC)
                        let transition = CATransition()
                        transition.duration = 0.4
                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        transition.type = kCATransitionMoveIn
                        transition.subtype = kCATransitionFromTop
                        
                        viewcontroller.navigationController!.view.layer.add(transition, forKey: kCATransition)
                        viewcontroller.navigationController?.pushViewController(viewController, animated: false)

                        
                    }
                    else{
                        
                        let containerVC = viewcontroller.childViewControllers[0] as! ResortDetailsViewController
                        containerVC.senderViewController = Constant.MyClassConstants.searchResult
                        containerVC.viewWillAppear(true)
                        
                        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
                            
                            viewcontroller.view.subviews.last?.frame = CGRect(x: 0, y: (viewcontroller.view.subviews.last?.frame.origin.y)!, width: (viewcontroller.view.subviews.last?.frame.size.width)!, height: (viewcontroller.view.subviews.last?.frame.size.height)!)
                            
                        }, completion: { _ in
                            
                        })

                        
                    }
                    
                }
                else {
                    let storyBoard = UIStoryboard(name: Constant.storyboardNames.iphone, bundle: nil)
                    let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.MyClassConstants.resortVC)
                    let transition = CATransition()
                    transition.duration = 0.4
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionMoveIn
                    transition.subtype = kCATransitionFromTop
                    
                    viewcontroller.navigationController!.view.layer.add(transition, forKey: kCATransition)
                    viewcontroller.navigationController?.pushViewController(viewController, animated: false)

                }
            }
            else {
                Constant.MyClassConstants.resortsArray.removeAll()
                Constant.MyClassConstants.resortsArray.append(response)
                Constant.MyClassConstants.resortsDescriptionArray = Constant.MyClassConstants.resortsArray[0]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.reloadMapNotification), object: nil)
            }
            
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewcontroller.view)
        })
        { (error) in
            SVProgressHUD.dismiss()
            removeServiceCallBackgroundView(view: viewcontroller.view)
            SimpleAlert.alert(viewcontroller, title:Constant.AlertErrorMessages.errorString, message: error.description)
        }
        
        
    }
    
    static func getBuildVersion() -> String {
        let nsObject:AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String
        
        var buildVersion = "Version \(version)"
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildVersion += ".\(build)"
        }
        
        if (Config.sharedInstance.getEnvironment() != Environment.production && Config.sharedInstance.getEnvironment() != Environment.production_dns) {
            let env = Config.sharedInstance.get(.Environment, defaultValue: "NONE").uppercased();
            buildVersion += " (\(env))"
        }
        
        return buildVersion
    }
    
    //***** function to return date from date components ***** //
    static func dateFromDateComponents(year:Int, month:Int, day:Int) -> NSDate {
        let c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
        
        let gregorian = NSCalendar(identifier:NSCalendar.Identifier.gregorian)
        let date = gregorian!.date(from: c as DateComponents)
        return date! as NSDate
    }
    
    //***** Function to get interval HD Videos *****//
    static func getVideos(searchBy:String){
        
        
        var categoryString:VideoCategory
        switch searchBy {
        case Constant.MyClassConstants.resortsString:
            categoryString = VideoCategory.Resort
        case Constant.MyClassConstants.tutorialsString:
            categoryString = VideoCategory.Tutorial
        default:
            categoryString = VideoCategory.Area
        }
        
        if(Constant.MyClassConstants.systemAccessToken?.token != nil){
            SVProgressHUD.show()
            LookupClient.getVideos(Constant.MyClassConstants.systemAccessToken!, category: categoryString, onSuccess: {(videos) in
                
                
                switch searchBy {
                    
                case Constant.MyClassConstants.resortsString:
                    Constant.MyClassConstants.internalHDResorts?.removeAll()
                    Constant.MyClassConstants.internalHDResorts! = videos
                    
                case Constant.MyClassConstants.tutorialsString:
                    Constant.MyClassConstants.internalHDTutorials?.removeAll()
                    Constant.MyClassConstants.internalHDTutorials = videos
                    
                default:
                    Constant.MyClassConstants.intervalHDDestinations?.removeAll()
                    Constant.MyClassConstants.intervalHDDestinations! = videos
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.reloadVideosNotification), object: nil)
                SVProgressHUD.dismiss()
            },
                                   onError: {(error) in
                                    
                                    SVProgressHUD.dismiss()
            })
        }else{
            
        }
    }
    
    //***** Function to get a list of magazines. *****//
    static func getMagazines(){
        if(Constant.MyClassConstants.systemAccessToken?.token != nil){
            SVProgressHUD.show()
            LookupClient.getMagazines(Constant.MyClassConstants.systemAccessToken!,
                                      onSuccess: {(magazines) in
                                        
                                        Constant.MyClassConstants.magazinesArray = magazines
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.magazineAlertNotification), object: nil)
                                        SVProgressHUD.dismiss()
            },
                                      onError: {(error) in
                                        SVProgressHUD.dismiss()
            })
        }
    }
    
    // function to return credit card code by mapping with specific name
    static func cardTypeCodeMapping(cardType:String) -> String{
        switch cardType {
        case "MC":
            return "Master card"
            
        case "AX":
            return "American Express"
            
        case "VS":
            return "Visa"
            
        case "DC":
            return "Diners Club"
            
        case "DS":
            return "Discover Card"
        default:
            return ""
        }
    }
    
    // function for card name mappping with code and return code
    static func cardNameMapping(cardName:String) -> String{
        switch cardName {
        case "MASTER CARD":
            return "MC"
            
        case "AMERICAN EXPRESS":
            return "AX"
            
        case "VISA":
            return "VS"
            
        case "DINERS CLUB":
            return "DC"
            
        case "DISCOVER CARD":
            return "DS"
        default:
            return ""
        }
    }
    
    //function for credit card image mapping
    static func cardImageMapping(cardType:String) -> String{
        switch cardType {
        case "MC":
            return "MasterCard_CO"
            
        case "AX":
            return "AmericanExpress_CO"
            
        case "VS":
            return "Visa_CO"
            
        case "DC":
            return "DinersClub_CO"
            
        case "DS":
            return "Discover_CO"
        default:
            return ""
        }
    }
    
    
    // function to return attributed string
    static func attributedString(from string: String, nonBoldRange: NSRange?, font:UIFont) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        let nonBoldAttribute = [
            NSFontAttributeName: font,
            ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
    
    // function to return date string from date
    static func convertDateToString(date:Date,format:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let dateStr = dateFormatter.string(from: date)
        
        return dateStr
    }
    // function to return date from dateString
    static func convertStringToDate(dateString:String,format:String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: dateString)
        
        return date!
    }
    // Function to get trip details
    static func getTripDetails(senderViewController: UIViewController){
        showProgressBar(senderView:senderViewController)
        ExchangeClient.getExchangeTripDetails(UserContext.sharedInstance.accessToken, confirmationNumber: Constant.MyClassConstants.transactionNumber, onSuccess: { (exchangeResponse) in
            
            Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails = exchangeResponse
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.notificationNames.reloadTripDetailsNotification), object: nil)
            
        }) { (error) in
            Helper.removeServiceCallBackgroundView(view: senderViewController.view)
            SVProgressHUD.dismiss()
            SimpleAlert.alert(senderViewController, title: Constant.AlertErrorMessages.errorString, message: error.localizedDescription)
            
        }
    }
    //Common function to add notifications.
    static func addNotifications(notificationNames: NSArray, senderVC : UIViewController){
        
    }
    
    // mapping function to return unit details header string with space
    static func getMappedStringForDetailedHeaderSection(sectonHeader:String) -> String {
        
        switch sectonHeader {
        case "SLEEPING_ACCOMMODATIONS":
            return "SLEEPING ACCOMMODATION"
            
        case "BATHROOM_FACILITIES":
            return "BATHROOM FACILITIES"
            
        case "KITCHEN_FACILITIES":
            return "KITCHEN FACILITIES"
            
        case "OTHER_FACILITIES":
            return "OTHER FACILITIES"
            
        default:
            return ""
        }
        
        
    }
    static func removeStoredGuestFormDetials() {
        
        Constant.GetawaySearchResultGuestFormDetailData.firstName = ""
        Constant.GetawaySearchResultGuestFormDetailData.lastName = ""
        Constant.GetawaySearchResultGuestFormDetailData.country = ""
        Constant.GetawaySearchResultGuestFormDetailData.address1 = ""
        Constant.GetawaySearchResultGuestFormDetailData.address2 = ""
        Constant.GetawaySearchResultGuestFormDetailData.city = ""
        Constant.GetawaySearchResultGuestFormDetailData.state = ""
        Constant.GetawaySearchResultGuestFormDetailData.pinCode = ""
        Constant.GetawaySearchResultGuestFormDetailData.email = ""
        Constant.GetawaySearchResultGuestFormDetailData.homePhoneNumber = ""
        Constant.GetawaySearchResultGuestFormDetailData.businessPhoneNumber = ""
        
    }
    
    //function to map bedroom size into integer string
    static func bedRoomSizeToStringInteger(bedRoomSize:String) -> String{
        switch bedRoomSize {
        case "STUDIO":
            return "0"
            
        case "ONE_BEDROOM":
            return "1"
            
        case "TWO_BEDROOM":
            return "2"
            
        case "THREE_BEDROOM":
            return "3"
            
        case "FOUR_BEDROOM":
            return "4"
        default:
            return ""
        }
    }
    static func selectedSegment(index:Int) -> String {
        
        switch index {
        case 0:
            return "Search Both"
            
        case 1:
            return "Getaways"
            
        case 2:
            return "Exchange"
        default:
            return ""
        }

        
    }
    static func omnitureSegmentSearchType(index:Int) -> String {
        
        switch index {
        case 0:
            return "Both"
            
        case 1:
            return "GW"
            
        case 2:
            return "EX"
        default:
            return ""
        }
        
        
    }
    static func trackOmnitureCallForPageView(name:String) {
        
        // omniture tracking with event 40
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar44 : name
            ]
        
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: userInfo)

    }
    
    //Method for navigating to another storyboard
    static func switchStoryBoard(storyBoardNameIphone:String, storyBoardNameIpad:String, senderViewController:UIViewController){
        var mainStoryboard = UIStoryboard()
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            mainStoryboard = UIStoryboard(name: storyBoardNameIphone, bundle: nil)
        }
        else {
            mainStoryboard = UIStoryboard(name: storyBoardNameIpad, bundle: nil)
        }
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.bedroomSizeViewController) as! BedroomSizeViewController
        viewController.delegate = senderViewController as? BedroomSizeViewControllerDelegate
        Constant.ControllerTitles.selectedControllerTitle = Constant.storyboardControllerID.floatViewController
        let transitionManager = TransitionManager()
        senderViewController.navigationController?.transitioningDelegate = transitionManager
        senderViewController.navigationController!.present(viewController, animated: true, completion: nil)
    }
    
    static func showProgressBar(senderView:UIViewController){
        Helper.addServiceCallBackgroundView(view: senderView.view)
        SVProgressHUD.show()
    }
    
    static func hideProgressBar(senderView:UIViewController){
        SVProgressHUD.dismiss()
        removeServiceCallBackgroundView(view: senderView.view)
    }
    
    static func currencyCodetoSymbol(code:String)->String{
        let currencyCode : String? = code
        let curr = Locale.availableIdentifiers.map{ Locale(identifier: $0)}.filter { return currencyCode == $0.currencyCode }.map { ($0.identifier, $0.currencySymbol) }.flatMap {$0}.first
        return (curr?.1?.description)!
    }
}


