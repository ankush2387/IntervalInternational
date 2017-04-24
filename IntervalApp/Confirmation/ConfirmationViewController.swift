//
//  ConfirmationViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 12/6/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class ConfirmationViewController: UIViewController {
    
    //Outlets
    @IBOutlet var confirmationNumber:UILabel!
    @IBOutlet var memberName:UILabel!
    @IBOutlet var memberNumber:UILabel!
    @IBOutlet var transactionDate:UILabel!
    
    @IBOutlet weak var goToUpcomingTripDetailsButton: IUIKButton!
    @IBOutlet weak var viewTripDetailsButton: IUIKButton!
    
    //Class variables
    var moreButton:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.title = Constant.ControllerTitles.confirmationControllerTitle
        if let rvc = self.revealViewController() {
            
            //***** Add the hamburger menu *****//
            let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.ic_menu), style: .plain, target: rvc, action:#selector(SWRevealViewController.revealToggle(_:)))
            menuButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = menuButton
            
            //***** creating and adding right bar button for more option button *****//
            moreButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.MoreNav), style: .plain, target: self, action:#selector(MoreNavButtonPressed(_:)))
            moreButton!.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = moreButton
            
            //***** This line allows the user to swipe left-to-right to reveal the menu. We might want to comment this out if it becomes confusing. *****//
            self.view.addGestureRecognizer( rvc.panGestureRecognizer() )
            
        }
        confirmationNumber.text = Constant.MyClassConstants.continueToPayResponse.view?.fees?.rental?.confirmationNumber
        
        let name = UserContext.sharedInstance.contact?.firstName?.capitalized
        memberName.text = "Booking Complete \n Congratulations \(name!)!"
        memberNumber.text = UserContext.sharedInstance.selectedMembership?.memberNumber
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: Date())
        transactionDate.text = dateString
        
        
        // Do any additional setup after loading the view.
    }
    
    //***** Function called when view trip details button is pressed. ******//
    @IBAction func viewTripDetailsPressed(_ sender:IUIKButton) {
        
        if(Constant.RunningDevice.deviceIdiom == .phone){
            
            let storyBoard = UIStoryboard(name: Constant.storyboardNames.myUpcomingTripIphone, bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController)
            
            let navController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.tripDetailsViewController) as! UINavigationController
            navController.setViewControllers([viewController], animated: true)
            self.navigationController?.present(navController, animated: true, completion: nil)
            
        }else{
            
            let storyBoard = UIStoryboard(name: Constant.storyboardNames.myUpcomingTripIpad, bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.upcomingTripsViewController)
            
            let navController = storyBoard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.tripDetailsViewController) as! UINavigationController
            navController.setViewControllers([viewController], animated: true)
            self.navigationController?.present(navController, animated: true, completion: nil)
            
        }
        
    }
    
    //***** Function called when upcoming trip details button is pressed. *****//
    @IBAction func UpComingTripDetailsPressed(_ sender: IUIKButton) {
        
        self.performSegue(withIdentifier: Constant.segueIdentifiers.confirmationUpcomingTripSegue, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func MoreNavButtonPressed(_ sender:UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title:Constant.buttonTitles.sharingOption, message: "", preferredStyle: .actionSheet)
        
        //***** Create and add the View my recent search *****//
        let shareViaEmailAction: UIAlertAction = UIAlertAction(title:Constant.buttonTitles.shareViaEmail, style: .default) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(shareViaEmailAction)
        //***** Create and add the Reset my search *****//
        let shareViaText: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.shareViaEmail, style: .default) { action -> Void in
        }
        actionSheetController.addAction(shareViaText)
        //***** Create and add help *****//
        let tweetAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.tweet, style: .default) { action -> Void in
        }
        actionSheetController.addAction(tweetAction)
        
        //***** Create and add help *****//
        let facebookAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.facebook, style: .default) { action -> Void in
        }
        actionSheetController.addAction(facebookAction)
        
        //***** Create and add help *****//
        let pinterestAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.pinterest, style: .default) { action -> Void in
        }
        actionSheetController.addAction(pinterestAction)
        
        
        //***** Create and add the cancel button *****//
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.buttonTitles.cancel, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
}
