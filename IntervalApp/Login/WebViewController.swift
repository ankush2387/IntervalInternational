//
//  WebViewController.swift
//  IntervalApp
//
//  Created by Chetu on 15/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import SVProgressHUD

class WebViewController: UIViewController {
    
   
    @IBOutlet weak var webviewForOpenSites: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        self.title = Constant.MyClassConstants.webviewTtile
        let   doneButton = UIBarButtonItem(title:Constant.AlertPromtMessages.done, style:.plain, target: self, action: #selector(JoinTodayViewController.donePressed(_:)))
        doneButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = doneButton
        webviewForOpenSites.delegate = self
        
        //1. Load web site into my web view
        let myURL = URL(string: Constant.MyClassConstants.requestedWebviewURL!)
        let myURLRequest:URLRequest = URLRequest(url: myURL!);
        webviewForOpenSites.loadRequest(myURLRequest)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func donePressed(_ sender:UIBarButtonItem) {
        SVProgressHUD.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension WebViewController:UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        //Helper.addServiceCallBackgroundView(view: self.view)
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        SVProgressHUD.dismiss()
        //Helper.removeServiceCallBackgroundView(view: self.view)
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        SVProgressHUD.dismiss()
        //Helper.removeServiceCallBackgroundView(view: self.view)
    }
}
