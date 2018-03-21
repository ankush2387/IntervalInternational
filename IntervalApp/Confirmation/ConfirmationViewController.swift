//
//  ConfirmationViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 12/6/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class ConfirmationViewController: UIViewController {
    
    //Outlets
    @IBOutlet var confirmationNumber: UILabel!
    //@IBOutlet var memberName:UILabel!
    @IBOutlet var memberNumber: UILabel!
    @IBOutlet var transactionDate: UILabel!
    
    @IBOutlet weak var goToUpcomingTripDetailsButton: IUIKButton!
    @IBOutlet weak var viewTripDetailsButton: IUIKButton!
    
    //Class variables
    var moreButton: UIBarButtonItem?
    var exchangeNum: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.confirmation
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)
        
        title = Constant.ControllerTitles.confirmationControllerTitle
        if let rvc = revealViewController() {
            //set SWRevealViewController's Delegate
            rvc.delegate = self
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action: #selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = menuButton
            
            //***** creating and adding right bar button for more option button *****//
            moreButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.MoreNav), style: .plain, target: self, action: #selector(MoreNavButtonPressed(_:)))
            moreButton!.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = moreButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            view.addGestureRecognizer( rvc.panGestureRecognizer() )
            
        }
        if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
            confirmationNumber.text = Constant.MyClassConstants.exchangeContinueToPayResponse.view?.fees?.shopExchange?.confirmationNumber
            if let number = Constant.MyClassConstants.exchangeContinueToPayResponse.view?.fees?.shopExchange?.confirmationNumber {
                exchangeNum = number
            }
            
        } else {
          confirmationNumber.text = Constant.MyClassConstants.continueToPayResponse.view?.fees?.rental?.confirmationNumber
            if let number = Constant.MyClassConstants.continueToPayResponse.view?.fees?.rental?.confirmationNumber {
                exchangeNum = number
            }
        }
        
        memberNumber.text = Session.sharedSession.selectedMembership?.memberNumber
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: Date())
        transactionDate.text = dateString
        var creditCards = 0
        if let cards = Session.sharedSession.contact?.creditcards {
            creditCards = cards.count
        }
        
        var resortCode = ""
        if let selectedResort = Constant.MyClassConstants.selectedAvailabilityResort {
            resortCode = selectedResort.code
        }
        
        //Omniture tracking calls for conformation screen with event
        let userInfo: [String: String] = [
            Constant.omnitureEvars.eVar41: Constant.omnitureCommonString.vactionSearch ,
            Constant.omnitureCommonString.productItem: resortCode,
            Constant.omnitureEvars.eVar13: "\(String(describing: Constant.MyClassConstants.continueToPayResponse.view?.fees?.rental?.confirmationNumber))",
            Constant.omnitureEvars.eVar22: "\(18 - Constant.holdingTime)",
            Constant.omnitureEvars.eVar29: Constant.MyClassConstants.vacationSearchShowDate.stringWithShortFormatForJSON(),
            Constant.omnitureEvars.eVar30: "" ,
            Constant.omnitureEvars.eVar37: Helper.selectedSegment(index: Constant.MyClassConstants.searchForSegmentIndex) ,
            Constant.omnitureEvars.eVar39: "" ,
            Constant.omnitureEvars.eVar40: "" ,
            Constant.omnitureEvars.eVar42: "" ,
            Constant.omnitureEvars.eVar62: "\(Helper.getDifferenceOfDates())" ,
            Constant.omnitureEvars.eVar63: "\(creditCards > 0 ? Constant.AlertPromtMessages.yes : Constant.AlertPromtMessages.no)" ,
            Constant.omnitureEvars.eVar73: Constant.MyClassConstants.checkoutInsurencePurchased,
            Constant.omnitureEvars.eVar77: Constant.MyClassConstants.checkoutPromotionPurchased
            
        ]
        //FIXME(FRANK) - what is happening here?
        //ADBMobile.trackAction(Constant.omnitureEvents.event44, data: userInfo)
        
    }
    
    //***** Function called when view trip details button is pressed. ******//
    @IBAction func viewTripDetailsPressed(_ sender: IUIKButton) {
        showHudAsync()
        
        ExchangeClient.getExchangeTripDetails(Session.sharedSession.userAccessToken, confirmationNumber: exchangeNum, onSuccess: {[weak self] exchangeResponse in
            
            Constant.MyClassConstants.upcomingTripsArray.removeAll()
            Constant.upComingTripDetailControllerReusableIdentifiers.exchangeDetails = exchangeResponse
            self?.hideHudAsync()
            let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
            let storyboardName = isRunningOnIphone ? Constant.storyboardNames.myUpcomingTripIphone : Constant.storyboardNames.myUpcomingTripIpad
            let storyBoard = UIStoryboard(name: storyboardName, bundle: nil)
            let detailViewController = storyBoard.instantiateViewController(withIdentifier: "UpComingTripDetailController")
             self?.navigationController?.pushViewController(detailViewController, animated: true)
            
        }) { [weak self]error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
    }
    
    //***** Function called when upcoming trip details button is pressed. *****//
    @IBAction func goToUpComingTripListPressed(_ sender: IUIKButton) {
       
        navigationController?.isNavigationBarHidden = true
        Constant.MyClassConstants.upcomingTripsArray.removeAll()
        let isRunningOnIphone = UIDevice.current.userInterfaceIdiom == .phone
        let storyboardName = isRunningOnIphone ? Constant.storyboardNames.myUpcomingTripIphone : Constant.storyboardNames.myUpcomingTripIpad
        guard let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() else { return }
        navigationController?.pushViewController(initialViewController, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func MoreNavButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title: Constant.buttonTitles.sharingOption, message: "", preferredStyle: .actionSheet)
        
        //***** Create and add the View my recent search *****//
        let shareViaEmailAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.shareViaEmail, style: .default) { _ -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(shareViaEmailAction)
        //***** Create and add the Reset my search *****//
        let shareViaText: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.shareViaText, style: .default) { _ -> Void in
        }
        actionSheetController.addAction(shareViaText)
        //***** Create and add help *****//
        let tweetAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.tweet, style: .default) { _ -> Void in
        }
        actionSheetController.addAction(tweetAction)
        
        //***** Create and add help *****//
        let facebookAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.facebook, style: .default) { _ -> Void in
        }
        actionSheetController.addAction(facebookAction)
        
        //***** Create and add help *****//
        let pinterestAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.pinterest, style: .default) { _ -> Void in
        }
        actionSheetController.addAction(pinterestAction)
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { _ -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        if Constant.RunningDevice.deviceIdiom == .pad {
            actionSheetController.popoverPresentationController?.sourceView = self.view
            actionSheetController.popoverPresentationController?.sourceRect = self.view.bounds
        }
        
        //Present the AlertController
        present(actionSheetController, animated: true, completion: nil)
    }
}
