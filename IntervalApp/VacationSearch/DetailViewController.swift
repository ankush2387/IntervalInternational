//
//  DetailViewController.swift
//  AutoLayoutTest
//
//  Created by Chetuiwk1601 on 2/18/16.
//  Copyright © 2016 Chetuiwk1601. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .Plain, target: self, action: #selector(DetailViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = menuButton
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func menuBackButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension DetailViewController: UITableViewDelegate {

}
extension DetailViewController: UITableViewDataSource {

    // MARK: Number of rows in section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dicValue = Constant.MyClassConstants.whereTogoContentArray[Constant.MyClassConstants.selectedIndex]
        print(dicValue)
        return dicValue.count
    }
    // MARK: cell fro indexpath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.detailScreenReusableIdentifiers.detailcell)
        
        let dicValue = Constant.MyClassConstants.whereTogoContentArray[Constant.MyClassConstants.selectedIndex]
        cell?.textLabel?.text = dicValue.valueForKey("value\(indexPath.row)") as? String
       
        return cell!
    }

}
