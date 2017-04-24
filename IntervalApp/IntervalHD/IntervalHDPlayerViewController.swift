//
//  IntervalHDPlayerViewController.swift
//  IntervalApp
//
//  Created by Chetu on 13/09/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK
import DarwinSDK
import IntervalUIKit

class IntervalHDPlayerViewController: UIViewController {
    
    //***** class variables//
    var video : Video?
    var controller : BCOVPlaybackController?
    @IBOutlet var videoContainerView:UIView!
    var doneButton:IUIKButton!
    var playerView:BCOVPUIPlayerView!
    var timer = Timer()
    //***** Outlets *****//
    
    
    
    // ** Customize these values with your own account information ** //
    
    let playbackService = BCOVPlaybackService(accountId: Config.sharedInstance.get(.BrightcoveAccountId), policyKey: Config.sharedInstance.get(.BrightcovePolicyKey))
    
    required init?(coder aDecoder: NSCoder) {
        let manager = BCOVPlayerSDKManager.shared()!
        self.controller = manager.createPlaybackController()
        
        super.init(coder: aDecoder)
        self.controller?.delegate = self
        self.controller?.isAutoAdvance = true
        self.controller?.isAutoPlay = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.videoContainerView = UIView()
        // Create and set options
        let options = BCOVPUIPlayerViewOptions()
        options.presentingViewController = self
        
        // Create and configure Control View
        let controlsView = BCOVPUIBasicControlView.withVODLayout()
        playerView = BCOVPUIPlayerView.init(playbackController: self.controller, options: options, controlsView: controlsView)!
        
        playerView.delegate = self
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height,height: UIScreen.main.bounds.size.width)
        videoContainerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height,height: UIScreen.main.bounds.size.width)
        videoContainerView.addSubview(playerView)
        
        requestContentFromPlaybackService()
    }
    
    
    override var shouldAutorotate : Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        return [UIInterfaceOrientationMask.landscapeLeft,UIInterfaceOrientationMask.landscapeRight]
        
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        
        return .landscapeLeft
        
    }
    
    
    func requestContentFromPlaybackService() {
        
        playbackService?.findVideo(withVideoID: video?.externalRefId ?? "", parameters: nil) {
            (video: BCOVVideo?, dict: [AnyHashable:Any]?, error: Error?) in
            if let v = video {
                self.controller?.setVideos([v] as NSFastEnumeration!)
            } else {
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarOrientation = .landscapeLeft
    
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            if(UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .faceUp || UIDevice.current.orientation == .faceDown){
                
                videoContainerView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                playerView.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                
            }else{
                
                videoContainerView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                playerView.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                
            }
            
        }
        else {
            
            videoContainerView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            playerView.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            
        }
        
        
        self.videoContainerView.backgroundColor = UIColor.blue
        self.view.addSubview(videoContainerView)
        createDoneButton()
        if(self.controller != nil){
            self.controller!.play()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        videoContainerView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
    }
    
    //****** Function to create done button to dismiss the video screen. ******//
    func createDoneButton(){
        
        doneButton = IUIKButton(frame: CGRect(x: UIScreen.main.bounds.width - 90, y: 20, width: 80, height: 40))
        
        doneButton.setTitle(Constant.AlertPromtMessages.done, for: UIControlState.normal)
        doneButton.tintColor = UIColor.white
        doneButton.backgroundColor = UIColor.orange
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 7
        doneButton.isUserInteractionEnabled = true
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        self.videoContainerView.addSubview(doneButton)
        
    }
    func doneButtonPressed(sender:IUIKButton) {
        self.navigationController?.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    func showDoneButton() {
        
        UIView.animate (withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            self.doneButton.frame = CGRect(x: UIScreen.main.bounds.width - 90, y: 20, width: 80, height: 40)
            
        }, completion: { _ in
            self.doneButton.isHidden = false
        })
        
        
    }
    func hideDoneButton() {
        
        UIView.animate (withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn ,animations: {
            self.doneButton.frame = CGRect(x: UIScreen.main.bounds.width - 90, y: -110, width: 80, height: 40)
            
        }, completion: { _ in
            self.doneButton.isHidden = true
        })
        
    }
}
extension IntervalHDPlayerViewController:BCOVPlaybackControllerDelegate {
    
}
extension IntervalHDPlayerViewController:BCOVPUIPlayerViewDelegate {
    
    func playerView(_ playerView: BCOVPUIPlayerView!, controlsFadingViewDidFadeOut controlsFadingView: UIView!) {
        
        self.hideDoneButton()
    }
    func playerView(_ playerView: BCOVPUIPlayerView!, controlsFadingViewDidFadeIn controlsFadingView: UIView!) {
        self.showDoneButton()
    }
}
