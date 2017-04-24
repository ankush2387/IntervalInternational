//
//  DetailedIssueViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/16/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import SVProgressHUD

class DetailedIssueViewController: UIViewController {
    
    
    internal var issueUrl : String?
    internal var magazinTitile:String?
    @IBOutlet weak var webView:UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.magazinTitile
        //1. Load web site into my web view
        let myURL = NSURL(string: issueUrl!)
        let myURLRequest:NSURLRequest = NSURLRequest(url: myURL! as URL);
        webView!.loadRequest(myURLRequest as URLRequest)
        
        let menuButton = UIBarButtonItem(image: UIImage(named:Constant.assetImageNames.backArrowNav), style: .plain, target: self, action:#selector(menuBackButtonPressed(sender:)))
        menuButton.tintColor = UIColor.white
        //self.tabBarController?.delegate = self
        self.navigationItem.leftBarButtonItem = menuButton

        // Do any additional setup after loading the view.
    }
    
    //***** Dismiss progress bar if back button is pressed. *****//
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    func menuBackButtonPressed(sender:UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailedIssueViewController:UIWebViewDelegate {
	
	func webViewDidStartLoad(_ webView: UIWebView)
    {
        Helper.addServiceCallBackgroundView(view: self.view)
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        SVProgressHUD.dismiss()
        Helper.removeServiceCallBackgroundView(view: self.view)
    }
    
     func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        SVProgressHUD.dismiss()
        Helper.removeServiceCallBackgroundView(view: self.view)
    }
}

