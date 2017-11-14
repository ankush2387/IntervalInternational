//
//  AccomodationCertsDetailController.swift
//  IntervalApp
//
//  Created by Chetu on 29/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class AccomodationCertsDetailController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var pageControl: UIPageControl!
    
    var collectionviewSelectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Constant.ControllerTitles.accomodationCertsDetailController
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(AccomodationCertsDetailController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = menuButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constant.storyboardNames.vacationSearchIphone, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constant.storyboardControllerID.revialViewController) as! SWRevealViewController
        
        //***** creating animation transition to show custom transition animation *****//
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        viewController.view.layer.add(transition, forKey: Constant.MyClassConstants.switchToView)
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
}

//***** MARK: Extension classes starts from here *****//

extension AccomodationCertsDetailController: UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.collectionviewSelectedIndex = (indexPath as NSIndexPath).row
        collectionView.reloadData()
        self.pageControl.currentPage = (indexPath as NSIndexPath).row

    }
    
}

extension AccomodationCertsDetailController: UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 0.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150.0, height: 60.0)
    }
}

extension AccomodationCertsDetailController: UICollectionViewDataSource {
    
    //***** Collection dataSource methods definition here *****//
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.vacationSearchScreenReusableIdentifiers.travelWindowSelectionCell, for: indexPath) as! TravelWindowSelectionCell
        if((indexPath as NSIndexPath).row == collectionviewSelectedIndex) {
          
            cell.counterLabel.backgroundColor = IUIKColorPalette.alert.color
            cell.yearMonthBaseView.backgroundColor = IUIKColorPalette.titleBackdrop.color
            cell.monthLabel.textColor = UIColor.white
            cell.yearLabel.textColor = UIColor.white
            cell.counterLabel.isHidden = false
        } else {
            cell.yearMonthBaseView.backgroundColor = UIColor.white
            cell.monthLabel.textColor = IUIKColorPalette.primary1.color
            cell.yearLabel.textColor = IUIKColorPalette.primary1.color
            cell.counterLabel.isHidden = true
        }
        cell.counterLabel.layer.cornerRadius = 10
        cell.counterLabel.layer.masksToBounds = true
        cell.yearMonthBaseView.layer.cornerRadius = 7
        cell.yearMonthBaseView.layer.borderWidth = 2
        cell.yearMonthBaseView.layer.borderColor = IUIKColorPalette.altState.color.cgColor
        cell.backgroundColor = UIColor.white
        return cell
    }
}

extension AccomodationCertsDetailController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //***** configure header cell for each section to show header labels *****//
        let  headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
            headerView.backgroundColor = IUIKColorPalette.titleBackdrop.color
        let nameLabel = UILabel(frame: CGRect(x: 30, y: 0, width: tableView.bounds.width - 60, height: 30))
        
            nameLabel.text = "United States"//response country name
            nameLabel.textColor = IUIKColorPalette.secondaryText.color
            headerView.addSubview(nameLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
 
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		//***** return height for  row in each section of tableview *****//
		return 50
		
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return 30
	}
}

extension AccomodationCertsDetailController: UITableViewDataSource {
    
    //***** MARK: - Table view data source *****//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //***** return number of sections for tableview *****//
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //***** return number of rows for each section in tableview *****//
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //***** configuring  and returned cell for each row *****//
         let cell = tableView.dequeueReusableCell(withIdentifier: Constant.vacationSearchScreenReusableIdentifiers.eligibleDestinationCell, for: indexPath) as! EligibleDestinationCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
}
