//
//  ClubPointSelectionViewController.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/9/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import Realm
import RealmSwift

class ClubPointSelectionViewController: UIViewController {
    /** Outlets */
    @IBOutlet weak var clubPoinScrollVw: UIScrollView!
    @IBOutlet weak var standardFlexChartSegment: UISegmentedControl!
    
    @IBOutlet weak var travelingDetailView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var secondtravelwindowbtn: IUIKButton!
    @IBOutlet weak var firsttravelwindowbtn: IUIKButton!
    
    @IBOutlet weak var firstdiffrencelabel: UILabel!
    
    @IBOutlet weak var seconddiffrencelabel: UILabel!
    
    @IBOutlet weak var doneButton: IUIKButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var secondTravelWindowConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstTravelWindowConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    //@IBOutlet weak var travelingDetailLabel: UILabel!
    /** Class Variables */
    var clubpointselectionPageViewController: UIPageViewController?
    var clubIntervalDictionary = NSMutableDictionary()
    @IBOutlet weak var clubsCollectionView: UICollectionView!
    @IBOutlet weak var startdatefirstbtn: UILabel!
    @IBOutlet weak var startmonthfirstbtn: UILabel!
    @IBOutlet weak var enddatefirstbtn: UILabel!
    @IBOutlet weak var endmonthfirstbtn: UILabel!
    
    @IBOutlet weak var startdatesecondbtn: UILabel!
    @IBOutlet weak var startmonthsecondbtn: UILabel!
    @IBOutlet weak var enddatesecondbtn: UILabel!
    @IBOutlet weak var endmonthsecondbtn: UILabel!
    
    @IBOutlet weak var indisefirstview: UIView!
    
    @IBOutlet weak var insidesecondview: UIView!
    
    let infoImageView = UIImageView()
    var labelsCollectionView:UICollectionView!
    var clublabel:String = ""
    var clubIntervalValuesCollectionView:UICollectionView!
    var clubPointsValue = "0"
   
    var testArr = [1]
    var firstCheckedCheckBoxTag = 0
    var secondCheckedCheckBoxTag = 0
    var buttonSelectedString = ""
    var segmentSelectedString = Constant.MyClassConstants.segmentFirstString
    var dictionaryForSegmentCheckBox = NSMutableDictionary()
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //lastContentOffset = scrollView.contentOffset;
    }
    
    //***Action event for change value for clubpoint according to button pressed.***//
    
    @IBAction func firstbuttonpressed(_ sender: Any) {
        buttonSelectedString = Constant.MyClassConstants.segmentFirstString
        mapClubIntervalPoints(index: (sender as AnyObject).tag - 100)
        createClubsCollectionView()
        
        //seconddiffrencelabel.textColor = UIColor(red: 0/255.0, green: 143/255.0, blue: 198/255.0, alpha: 1.0)
        //firstdiffrencelabel.textColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255.0/255.0, alpha: 1.0)
        travelingDetailView.backgroundColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        indisefirstview.backgroundColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        secondView.backgroundColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        insidesecondview.backgroundColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        startdatesecondbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        startmonthsecondbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        enddatesecondbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        endmonthsecondbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        
        startdatefirstbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        startmonthfirstbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        enddatefirstbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        endmonthfirstbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
    }
    
    @IBAction func secondbuttonpressed(_ sender: Any) {
        
        buttonSelectedString = Constant.MyClassConstants.segmentSecondString
        insidesecondview.backgroundColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        secondView.backgroundColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        startdatesecondbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        startmonthsecondbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        enddatesecondbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        endmonthsecondbtn.textColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        travelingDetailView.backgroundColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        indisefirstview.backgroundColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        startdatefirstbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        startmonthfirstbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        enddatefirstbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        endmonthfirstbtn.textColor = UIColor(red: 0 / 255.0, green: 143 / 255.0, blue: 198 / 255.0, alpha: 1.0)
        
        mapClubIntervalPoints(index: (sender as AnyObject).tag - 100)
        
        createClubsCollectionView()
        
    }
    
    //MARK:- Function for done button click
    @IBAction func doneButtonClicked(_ sender:IUIKButton) {
        
        guard let relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId else {
         return }
        
        let pointMatrixType = PointsMatrixReservation()
        pointMatrixType.clubPointsMatrixType = Constant.MyClassConstants.matrixType
        pointMatrixType.clubPointsMatrixDescription = Constant.MyClassConstants.matrixDescription
        pointMatrixType.clubPointsMatrixGridRowLabel = Constant.MyClassConstants.labelarray[0] as? String
        intervalPrint(Constant.MyClassConstants.fromdatearray[0])
        pointMatrixType.fromDate = Constant.MyClassConstants.fromdatearray[0] as? String
        pointMatrixType.toDate = Constant.MyClassConstants.todatearray[0] as? String
        
        let units = Constant.MyClassConstants.relinquishmentSelectedWeek.unit
        intervalPrint(Constant.MyClassConstants.matrixDataArray)
        intervalPrint(segmentSelectedString)
        
        dictionaryForSegmentCheckBox.value(forKey: segmentSelectedString)
        
        let labelUnitArray:NSMutableArray = Constant.MyClassConstants.clubIntervalDictionary.value(forKey: Constant.MyClassConstants.labelarray[1] as! String)! as! NSMutableArray
        
           let invenUnit:InventoryUnit = InventoryUnit()
           invenUnit.unitSize = "STUDIO"
           let clubPoints = clubPointsValue.replacingOccurrences(of: ",", with: "")
           invenUnit.clubPoints = Int(clubPoints) ?? 0
        
                pointMatrixType.unit = invenUnit
         ExchangeClient.updatePointsMatrixReservation(Session.sharedSession.userAccessToken, relinquishmentId: relinquishmentID, reservation: pointMatrixType, onSuccess: {(response) in
            intervalPrint(response)
            
         }, onError: { (error) in
            
            let storedata = OpenWeeksStorage()
            let membership = Session.sharedSession.selectedMembership
            let relinquishmentList = TradeLocalData()
            
            let selectedClubPoint = ClubPoints()
            if let relinquishmentId = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId {
                selectedClubPoint.relinquishmentId = relinquishmentId
            }
            
            selectedClubPoint.isPointsMatrix = true
            selectedClubPoint.relinquishmentYear = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentYear ?? 0
            selectedClubPoint.pointsSpent = invenUnit.clubPoints
            
            let resort = ResortList()
            if let resortName = Constant.MyClassConstants.relinquishmentSelectedWeek.resort?.resortName {
                resort.resortName = resortName
            }
            selectedClubPoint.resort.append(resort)
            relinquishmentList.clubPoints.append(selectedClubPoint)
            storedata.openWeeks.append(relinquishmentList)
            if let memberNumber = membership?.memberNumber {
                storedata.membeshipNumber = memberNumber
            }
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(storedata)
                }
            } catch {
                self.presentErrorAlert(UserFacingCommonError.generic)
            }
         })
        
    }
    
    //MARK :- Save Club points to database
    func saveSelectedClubPoints(){
        
    }
    
    //*** Change frame layout while change iPad in Portrait and Landscape mode.***//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            frameChangeOnPortraitandLandscape()
        }
        
    }
    
    func frameChangeOnPortraitandLandscape() {
        
        if(UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight) {
            lineBottomConstraint.constant = 80
            if(clubIntervalValuesCollectionView != nil || labelsCollectionView != nil) {
                clubIntervalValuesCollectionView.collectionViewLayout.invalidateLayout()
                labelsCollectionView.collectionViewLayout.invalidateLayout()
                createClubsCollectionView()
            }
        } else {
            lineBottomConstraint.constant = 355
            if(clubIntervalValuesCollectionView != nil || labelsCollectionView != nil) {
                clubIntervalValuesCollectionView.collectionViewLayout.invalidateLayout()
                labelsCollectionView.collectionViewLayout.invalidateLayout()
                createClubsCollectionView()
            }
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemWidth = Int(UIScreen.main.bounds.width - 80)
        let itemSpacing = 0
        let pageWidth = Float(itemWidth + itemSpacing)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(clubIntervalValuesCollectionView!.contentSize.width  )
        var newPage = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        self.pageControl.currentPage = Int(newPage)
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // omniture tracking with event 40
        let pageView: [String: String] = [
            Constant.omnitureEvars.eVar44: Constant.omnitureCommonString.clubPointsSelection
        ]
        ADBMobile.trackAction(Constant.omnitureEvents.event40, data: pageView)

        doneButton.isHidden = true
        buttonSelectedString = Constant.MyClassConstants.segmentFirstString

        if Constant.RunningDevice.deviceIdiom == .pad {
            frameChangeOnPortraitandLandscape()
        }
        Constant.MyClassConstants.pointMatrixDictionary.removeAllObjects()
        Constant.MyClassConstants.pointMatrixDictionary.addEntries(from: Constant.MyClassConstants.matrixDataArray[0] as! [AnyHashable: Any])
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(ClubPointSelectionViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.title = Constant.ControllerTitles.clubpointselection
        travelingDetailView.layer.borderWidth = 2
        travelingDetailView.layer.borderColor = UIColor.lightGray.cgColor
        travelingDetailView.layer.cornerRadius = 5
        
        secondView.layer.borderWidth = 2
        secondView.layer.borderColor = UIColor.lightGray.cgColor
        secondView.layer.cornerRadius = 5
        
        if( Constant.MyClassConstants.showSegment == false) {
            standardFlexChartSegment.isHidden = true
            secondTravelWindowConstraint.constant = -30
            firstTravelWindowConstraint.constant = -30
        } else {
            standardFlexChartSegment.isHidden = false
        }
        
        self.mapClubIntervalPoints(index: 0)
        setDate()
        let dictionaryForCheckBox = NSMutableDictionary()
        dictionaryForCheckBox.setValue( 0, forKey: Constant.MyClassConstants.segmentFirstString)
        dictionaryForCheckBox.setValue( 0, forKey: Constant.MyClassConstants.segmentSecondString)
        dictionaryForSegmentCheckBox.setValue(dictionaryForCheckBox, forKey: Constant.MyClassConstants.segmentFirstString)
        dictionaryForSegmentCheckBox.setValue(dictionaryForCheckBox, forKey: Constant.MyClassConstants.segmentSecondString)
        dictionaryForSegmentCheckBox.setValue(dictionaryForCheckBox, forKey: Constant.MyClassConstants.segmentThirdString)
        intervalPrint(dictionaryForSegmentCheckBox)

    }
    
    func viewWillAppear() {
        if(Constant.RunningDevice.deviceIdiom == .pad) {
            frameChangeOnPortraitandLandscape()
        }
    }
    
    //***** Function to create collection view to show club points. *****//
    func createClubsCollectionView(){
        self.clubPoinScrollVw.contentSize = CGSize(width: 0, height: ((Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 50))
        scrollViewHeightConstraint.constant = self.clubPoinScrollVw.contentSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .vertical
        
        let layout1: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout1.minimumLineSpacing = 0.0
        layout1.minimumInteritemSpacing = 0.0
        layout1.scrollDirection = .horizontal
        
        if clubIntervalValuesCollectionView == nil {
            clubIntervalValuesCollectionView = UICollectionView(frame: CGRect(x: 80, y: 0, width: Int(UIScreen.main.bounds.width - 80) , height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 150), collectionViewLayout: layout1)
            clubIntervalValuesCollectionView.register(UINib(nibName:Constant.customCellNibNames.clubPointsCell, bundle: nil), forCellWithReuseIdentifier:Constant.loginScreenReusableIdentifiers.cell)
            
            clubIntervalValuesCollectionView.showsHorizontalScrollIndicator = false
            clubIntervalValuesCollectionView.register(UINib(nibName: Constant.customCellNibNames.checkCell, bundle: nil), forCellWithReuseIdentifier: Constant.reUsableIdentifiers.checkBoxCell)
            clubIntervalValuesCollectionView.bounces = false
            clubIntervalValuesCollectionView.backgroundColor = UIColor.white
            clubIntervalValuesCollectionView.delegate = self
            clubIntervalValuesCollectionView.dataSource = self
            clubIntervalValuesCollectionView.tag = 80
            clubIntervalValuesCollectionView.isScrollEnabled = true
            clubPoinScrollVw.addSubview(clubIntervalValuesCollectionView)
        } else {
            clubIntervalValuesCollectionView.frame = CGRect(x: 80, y: 0, width: Int(UIScreen.main.bounds.width - 80) , height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 150)
            clubIntervalValuesCollectionView.reloadData()
        }
        
        if labelsCollectionView == nil {
            labelsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 80 , height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 50), collectionViewLayout: layout)
            
            labelsCollectionView.register(UINib(nibName: Constant.customCellNibNames.clubPointsCell, bundle: nil), forCellWithReuseIdentifier: Constant.loginScreenReusableIdentifiers.cell)
            labelsCollectionView.register(UINib(nibName: Constant.customCellNibNames.headerCell, bundle: nil), forCellWithReuseIdentifier: Constant.reUsableIdentifiers.clubHeaderCell)
            labelsCollectionView.tag = 70
            labelsCollectionView.isScrollEnabled = false
            labelsCollectionView.delegate = self
            labelsCollectionView.dataSource = self
            labelsCollectionView.backgroundColor = UIColor.white
            clubPoinScrollVw.addSubview(labelsCollectionView)
        } else {
            labelsCollectionView.frame = CGRect(x: 0, y: 0, width: 80 , height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 50)
            labelsCollectionView.reloadData()
        }
        
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Function to map club interval points
    
    func mapClubIntervalPoints(index: Int) {

        intervalPrint(Constant.MyClassConstants.fromdatearray[0], Constant.MyClassConstants.fromdatearray[1])
        let dictKey = "\(Constant.MyClassConstants.fromdatearray[index]) - \(Constant.MyClassConstants.todatearray[index])"
        let rowsForClubInterval = Constant.MyClassConstants.pointMatrixDictionary.object(forKey: dictKey) as! [ClubPointsMatrixGridRow]
        
        Constant.MyClassConstants.clubIntervalDictionary.removeAllObjects()
        for clubIntervalRow in rowsForClubInterval {
            let clubPointsArray = NSMutableArray()
            Constant.MyClassConstants.clubPointMatrixHeaderArray.removeAllObjects()
            for units in clubIntervalRow.units {
                clubPointsArray.add(units.clubPoints)
                let bedRoomString = Helper.getBedroomNumbers(bedroomType: units.unitSize!)
                Constant.MyClassConstants.clubPointMatrixHeaderArray.add(bedRoomString)
            }
            Constant.MyClassConstants.clubIntervalDictionary.setObject(clubPointsArray, forKey: clubIntervalRow.label! as NSCopying)
        }
        
        createClubsCollectionView()
    }
    //Function to set date on buttons.
    
    func setDate() {
        
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let fromStartComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: Constant.MyClassConstants.todatearray[0] as! String, format: Constant.MyClassConstants.dateFormat) as Date)
        let toStartComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: Constant.MyClassConstants.fromdatearray[0] as! String, format: Constant.MyClassConstants.dateFormat) as Date)
        let fromEndComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: Constant.MyClassConstants.todatearray[1] as! String, format: Constant.MyClassConstants.dateFormat) as Date)
        let toEndComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: Constant.MyClassConstants.fromdatearray[1] as! String, format: Constant.MyClassConstants.dateFormat) as Date)
        
        startdatefirstbtn.text = String(describing: toStartComponents.day!)
        enddatefirstbtn.text = String(describing: fromStartComponents.day!)
        
        startdatesecondbtn.text = String(describing: toEndComponents.day!)
        enddatesecondbtn.text = String(describing: fromEndComponents.day!)
        
        if( startdatefirstbtn.text!.characters.count == 1) {
            startdatefirstbtn.text = "0\( startdatefirstbtn.text!)"
        }
        if( startdatesecondbtn.text!.characters.count == 1) {
            startdatesecondbtn.text = "0\( startdatesecondbtn.text!)"
        }
        if( enddatefirstbtn.text!.characters.count == 1) {
            enddatefirstbtn.text = "0\( enddatefirstbtn.text!)"
        }
        if( enddatesecondbtn.text!.characters.count == 1) {
            enddatesecondbtn.text = "0\( enddatesecondbtn.text!)"
        }
        startmonthfirstbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: toStartComponents.month!)) \(toStartComponents.year!)"
        endmonthfirstbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: fromStartComponents.month!)) \(fromStartComponents.year!)"
        startmonthsecondbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: toEndComponents.month!)) \(toEndComponents.year!)"
        endmonthsecondbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: fromEndComponents.month!)) \(fromEndComponents.year!)"
    }
    
    //Function for button toDate and FromDate click action
    @IBAction func loadClubData(_ sender: UIButton) {
        //checkedCheckBoxTag = 0
        mapClubIntervalPoints(index: sender.tag - 100)
        let view1 = self.view.viewWithTag(100)
        let view2 = self.view.viewWithTag(101)
        /*for subView in (view1?.superview?.subviews)!{
         if(subView.isKind(of: UILabel.self)){
         let subViewLabel = subView as! UILabel
         subViewLabel.textColor = IUIKColorPalette.primary1.color
         }
         }
         for subView in (view2?.superview?.subviews)!{
         if(subView.isKind(of: UILabel.self)){
         let subViewLabel = subView as! UILabel
         subViewLabel.textColor = IUIKColorPalette.primary1.color
         }
         }
         view1?.superview?.backgroundColor = UIColor.white
         view2?.superview?.backgroundColor = UIColor.white*/
        
        if(sender.tag == 100) {
            travelingDetailView.backgroundColor = IUIKColorPalette.primary1.color
            startdatefirstbtn.textColor = UIColor.white
            startmonthfirstbtn.textColor = UIColor.white
            
            for subView in (view2?.superview?.subviews)! {
                if(subView.isKind(of: UILabel.self)) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = UIColor.white
                }
            }
            
            for subView in (view1?.superview?.subviews)! {
                if(subView.isKind(of: UILabel.self)) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = IUIKColorPalette.primary1.color
                }
            }
            secondView.backgroundColor = UIColor.white
            /*startdatefirstbtn.backgroundColor = IUIKColorPalette.primary1.color
             startmonthfirstbtn
             enddatefirstbtn
             endmonthfirstbtn
             startdatesecondbtn
             startmonthsecondbtn
             enddatesecondbtn
             endmonthsecondbtn*/
        } else {
            travelingDetailView.backgroundColor = UIColor.white
            enddatefirstbtn.textColor = UIColor.white
            endmonthsecondbtn.textColor = UIColor.white
            
            for subView in (view1?.superview?.subviews)! {
                if(subView.isKind(of: UILabel.self)) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = UIColor.white
                }
            }
            
            for subView in (view2?.superview?.subviews)! {
                if(subView.isKind(of: UILabel.self)) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = IUIKColorPalette.primary1.color
                }
            }
            secondView.backgroundColor = IUIKColorPalette.primary1.color
        }
        /*sender.superview!.backgroundColor = IUIKColorPalette.primary1.color
         for subView in (sender.superview!.subviews){
         if(subView.isKind(of: UILabel.self)){
         let subViewLabel = subView as! UILabel
         subViewLabel.textColor = UIColor.white
         }
         }*/
        createClubsCollectionView()
    }
    
    //Function to get check box status
    @IBAction func checkBoxClicked(_ sender: UIButton) {
        doneButton.isHidden = false
        let indexPath = IndexPath(item: sender.tag % 10, section: sender.tag / 10)
        Constant.MyClassConstants.checkBoxTag = sender.tag % 10
        let collectionVwCell = clubIntervalValuesCollectionView.cellForItem(at: indexPath)

        for collectionItem in (collectionVwCell?.contentView.subviews)! {
            
            if(collectionItem.isKind(of: UILabel.self))
            {
                let pointsLabel = collectionItem as? UILabel
                if let points = pointsLabel?.text {
                    clubPointsValue = points
                }
            } else if collectionItem.isKind(of: IUIKCheckbox.self) {
                let checkBox = collectionItem as! IUIKCheckbox
                if(checkBox.checked) {
                    checkBox.checked = false
                    doneButton.isHidden = true
                    if(buttonSelectedString == "First") {
                        firstCheckedCheckBoxTag = 0
                    } else {
                        secondCheckedCheckBoxTag = 0
                    }
                } else {
                    checkBox.checked = true
                    doneButton.isHidden = false
                    if(buttonSelectedString == "First") {
                        firstCheckedCheckBoxTag = sender.tag
                    } else {
                        secondCheckedCheckBoxTag = sender.tag
                    }
                }
            }
        }
        setDictionaryForCheckBox()
        clubIntervalValuesCollectionView.reloadData()
    }
    
    // Set checkbox according to segment control
    func setDictionaryForCheckBox() {
        let value = dictionaryForSegmentCheckBox[segmentSelectedString] == nil
        if (value) {
            firstCheckedCheckBoxTag = 0
            secondCheckedCheckBoxTag = 0
        }
        let tempTagCheckBoxFirst = firstCheckedCheckBoxTag
        let tempTagCheckBoxSecond = secondCheckedCheckBoxTag
        let dictionaryForCheckBox = NSMutableDictionary()
        dictionaryForCheckBox.setValue( tempTagCheckBoxFirst, forKey: Constant.MyClassConstants.segmentFirstString)
        dictionaryForCheckBox.setValue( tempTagCheckBoxSecond, forKey: Constant.MyClassConstants.segmentSecondString)
        if(segmentSelectedString == Constant.MyClassConstants.segmentFirstString) {
            
        }
        dictionaryForSegmentCheckBox.setValue(dictionaryForCheckBox, forKey: segmentSelectedString)
        intervalPrint(dictionaryForSegmentCheckBox)
    }
    
    //Function called when segment control value change
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            segmentSelectedString = Constant.MyClassConstants.first
        } else if(sender.selectedSegmentIndex == 1) {
            segmentSelectedString = Constant.MyClassConstants.segmentSecondString
        } else {
            segmentSelectedString = Constant.MyClassConstants.segmentThirdString
        }
        Constant.MyClassConstants.pointMatrixDictionary.removeAllObjects()
        Constant.MyClassConstants.pointMatrixDictionary.addEntries(from: Constant.MyClassConstants.matrixDataArray[sender.selectedSegmentIndex] as! [AnyHashable: Any])
        self.mapClubIntervalPoints(index: 0)
        createClubsCollectionView()
    }
    
    // MARK: Text Attributes with font size
    /**
     Create  a TextAttributes to change the font size of Segment controll text.
     - parameter fontsize: used to change font size
     - returns : TextAttributes.
     */
    fileprivate func getTextAttributes(_ fontsize: CGFloat) -> [String: NSObject] {
        let segmentFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.caption1)
        let font = UIFont(descriptor: segmentFontDescriptor, size: fontsize)
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.red,
            NSFontAttributeName: font
        ]
        return normalTextAttributes
    }
    // MARK: Instantiate clubpointselectionPageviewController
    /**
     Create instance of pageViewController when horizontal scrolling is performed
     - parameter No parameter :
     - returns : No value is return
     */
    fileprivate func createClubpointselectionPageviewController() {
        let pageViewController = self.storyboard!.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointsSelectionViewController) as? UIPageViewController
        pageViewController?.dataSource = self
        
        if testArr.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageViewController!.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
            
        }
        
        clubpointselectionPageViewController = pageViewController
        addChildViewController(clubpointselectionPageViewController!)
        self.view.addSubview(clubpointselectionPageViewController!.view)
        clubpointselectionPageViewController!.didMove(toParentViewController: self)
    }
    // MARK: set page controll
    /**
     Set Pagecontroll properties on PageViewController
     - parameter No Parameter :
     - returns : No return value
     */
    fileprivate func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        
        appearance.currentPageIndicatorTintColor = UIColor.green
        appearance.backgroundColor = UIColor.clear
    }
    
    // MARK: Auto Layout for child view controller(page view controller)
    /**
     Add PageViewController as ChildViewController with AutoLayout Constraints
     - parameter No Parameter :
     - returns : No return value
     */
    fileprivate func addPageViewControllerWithAutoLayoutConstraint() {
        var leadeingconstraint: NSLayoutConstraint?
        var trailingconstraint: NSLayoutConstraint?
        var topconstraint: NSLayoutConstraint?
        var bottomconstraint: NSLayoutConstraint?
        
        leadeingconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
        trailingconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1.0, constant: 20)
        topconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .top, relatedBy: .equal, toItem: travelingDetailView, attribute: .bottom, multiplier: 1.0, constant: 8)
        bottomconstraint = NSLayoutConstraint(item: clubpointselectionPageViewController!.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -50)
        clubpointselectionPageViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leadeingconstraint!, trailingconstraint!, topconstraint!, bottomconstraint!])
        self.view.addConstraints([leadeingconstraint!, trailingconstraint!, topconstraint!, bottomconstraint!])
    }
    // MARK: initialise clubpoint page item view controller
    /**
     Initialise View*/
    fileprivate func getItemController(_ itemIndex: Int) -> ClubPointPageItemViewController? {
        
        if itemIndex < testArr.count {
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: Constant.storyboardControllerID.clubPointViewController) as! ClubPointPageItemViewController
            pageItemController.pageItemIndex = itemIndex
            return pageItemController
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension ClubPointSelectionViewController: UIPageViewControllerDataSource {
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ClubPointPageItemViewController
        
        if itemController.pageItemIndex > 0 {
            return getItemController(itemController.pageItemIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! ClubPointPageItemViewController
        
        if itemController.pageItemIndex + 1 < testArr.count {
            return getItemController(itemController.pageItemIndex + 1)
        }
        
        return nil
    }
    // MARK: - Page Indicator
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return testArr.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
        
    }
}

extension ClubPointSelectionViewController: UICollectionViewDataSource {
    // MARK - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(collectionView.tag == 70) {
            return 1
        } else {
            return Constant.MyClassConstants.clubPointMatrixHeaderArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.clubIntervalDictionary.allKeys.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 70) {
            if indexPath.row == 0 {
                let dateCell: TdiCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: Constant.cellIdentifiers.headerCell, for: indexPath) as! TdiCollectionViewCell
                dateCell.backgroundColor = IUIKColorPalette.titleBackdrop.color
                dateCell.contentLabel.textColor = UIColor.black
                
                dateCell.contentLabel.text = Constant.MyClassConstants.tdi
                dateCell.contentLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                if(Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeColor) {
                    dateCell.contentLabel.text = Constant.MyClassConstants.season.capitalized
                }
                dateCell.addSubview(infoImageView)
                dateCell.lineImage.isHidden = false
                
                return dateCell
            } else {
                let contentCell: TdiCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: Constant.loginScreenReusableIdentifiers.cell, for: indexPath) as! TdiCollectionViewCell
                contentCell.contentLabel.textColor = UIColor.black
                contentCell.contentLabel.text = String(describing: Constant.MyClassConstants.labelarray[indexPath.row - 1])
                if indexPath.row % 2 != 0 {
                    contentCell.backgroundColor = UIColor.white
                } else {
                    contentCell.backgroundColor = IUIKColorPalette.titleBackdrop.color
                }
                contentCell.lineImage.isHidden = true
                return contentCell
            }
        } else {
            if indexPath.row == 0 {
                let dateCell: TdiCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: Constant.loginScreenReusableIdentifiers.cell, for: indexPath) as! TdiCollectionViewCell
                dateCell.contentLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                dateCell.horizontalLineImage.isHidden = true
                dateCell.contentLabel.textColor = UIColor.black
                dateCell.lineImage.isHidden = false
                if(indexPath.section == Constant.MyClassConstants.clubPointMatrixHeaderArray.count) {
                    dateCell.contentLabel.text = ""
                } else {
                    dateCell.contentLabel.text = String(describing: Constant.MyClassConstants.clubPointMatrixHeaderArray[indexPath.section])
                }
                dateCell.backgroundColor = IUIKColorPalette.titleBackdrop.color
                return dateCell
            } else {
                
                let contentCell: TdiCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: Constant.cellIdentifiers.checkCell, for: indexPath) as! TdiCollectionViewCell
                contentCell.contentLabel.textColor = UIColor.black
                contentCell.lineImage.isHidden = true
                let labelUnitArray: NSMutableArray = Constant.MyClassConstants.clubIntervalDictionary.value(forKey: Constant.MyClassConstants.labelarray[indexPath.row - 1] as! String)! as! NSMutableArray

                intervalPrint(labelUnitArray)
                if(indexPath.section == Constant.MyClassConstants.clubPointMatrixHeaderArray.count) {
                    contentCell.checkBoxView.isHidden = true
                    contentCell.checkButton.isHidden = true
                    contentCell.contentLabel.text = ""
                } else {
                    contentCell.checkBoxView.isHidden = false
                    contentCell.checkButton.isHidden = false
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    
                    //*** Add comma seperator for number digits on uilabel. ***//
                    let formatter = numberFormatter
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 0
                   contentCell.contentLabel.text = formatter.string(from: labelUnitArray[indexPath.section] as! NSNumber)
                    
                }
                contentCell.checkButton.tag = Int("\(indexPath.section )\(indexPath.row)")!
                contentCell.checkButton.addTarget(self, action: #selector(ClubPointSelectionViewController.checkBoxClicked(_:)), for: .touchUpInside)
                contentCell.checkBoxView.backgroundColor = UIColor.brown
                if(dictionaryForSegmentCheckBox.count > 0) {
                    let checkBoxDictionary: NSDictionary = dictionaryForSegmentCheckBox.value(forKey: segmentSelectedString) as! NSDictionary
                    
                    intervalPrint(checkBoxDictionary)
                    if(contentCell.checkButton.tag == checkBoxDictionary.value(forKey: "First") as! Int && buttonSelectedString == "First") {
                        contentCell.checkBoxView.checked = true
                    } else if(contentCell.checkButton.tag == checkBoxDictionary.value(forKey: "Second") as! Int && buttonSelectedString == "Second") {
                        contentCell.checkBoxView.checked = true
                    } else {
                        contentCell.checkBoxView.checked = false
                    }
                }
                if indexPath.row % 2 != 0 {
                    contentCell.backgroundColor = UIColor.white
                } else {
                    contentCell.backgroundColor = IUIKColorPalette.titleBackdrop.color
                }
                return contentCell
            }
        }
    }
}
//***** MARK: Extension classes starts from here *****//

extension ClubPointSelectionViewController: UICollectionViewDelegate {
    
    //***** Collection delegate methods definition here *****//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        intervalPrint(indexPath.row, indexPath.section)
    }
}

extension ClubPointSelectionViewController: UICollectionViewDelegateFlowLayout {
    
    //***** Collection delegate methods definition here *****//
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView.tag == 70) {
            if(indexPath.row == 0) {
                return CGSize(width: collectionView.frame.size.width, height: 50.0)
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 70.0)
            }
        } else {
            if(indexPath.row == 0) {
                if(Constant.RunningDevice.deviceIdiom == .phone) {
                    return CGSize(width: (collectionView.frame.size.width) / 2, height: 50.0)
                } else {
                    
                    if UIDevice.current.orientation.isLandscape {
                        return CGSize(width: (collectionView.frame.size.width) / 5, height: 50.0)
                    } else {
                        return CGSize(width: (collectionView.frame.size.width) / 5, height: 50.0)
                    }
                    
                }
            } else {
                if(Constant.RunningDevice.deviceIdiom == .phone) {
                    if(indexPath.row == 0) {
                        return CGSize(width: (collectionView.frame.size.width) / 2, height: 50.0)
                    } else {
                        return CGSize(width: (collectionView.frame.size.width) / 2, height: 70.0)
                    }
                } else {
                    
                    if UIDevice.current.orientation.isLandscape {
                        return CGSize(width: (collectionView.frame.size.width) / 5, height: 70.0)
                    } else {
                        return CGSize(width: (collectionView.frame.size.width) / 5, height: 70.0)
                    }
                }
            }
        }
    }
}
