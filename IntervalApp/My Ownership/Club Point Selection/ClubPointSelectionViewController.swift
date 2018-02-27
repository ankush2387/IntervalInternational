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
    @IBOutlet private weak var clubPoinScrollVw: UIScrollView!
    @IBOutlet private weak var standardFlexChartSegment: UISegmentedControl!
    @IBOutlet fileprivate weak var travelingDetailView: UIView!
    @IBOutlet fileprivate weak var secondView: UIView!
    @IBOutlet private weak var secondtravelwindowbtn: IUIKButton!
    @IBOutlet private weak var firsttravelwindowbtn: IUIKButton!
    @IBOutlet private weak var doneButton: IUIKButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var lineBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var firstTravelWindowConstraint: NSLayoutConstraint!
    @IBOutlet private weak var secondTravelWindowConstraint: NSLayoutConstraint!
    
    //@IBOutlet weak var travelingDetailLabel: UILabel!
    /** Class Variables */
    var clubpointselectionPageViewController: UIPageViewController?
    var clubIntervalDictionary = NSMutableDictionary()
    private weak var clubsCollectionView: UICollectionView!
    @IBOutlet private weak var startdatefirstbtn: UILabel!
    @IBOutlet private weak var startmonthfirstbtn: UILabel!
    @IBOutlet private weak var enddatefirstbtn: UILabel!
    @IBOutlet private weak var endmonthfirstbtn: UILabel!
    
    @IBOutlet private weak var startdatesecondbtn: UILabel!
    @IBOutlet private weak var startmonthsecondbtn: UILabel!
    @IBOutlet private weak var enddatesecondbtn: UILabel!
    @IBOutlet private weak var endmonthsecondbtn: UILabel!
    
    @IBOutlet fileprivate weak var firstTravelWindowWidth: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var equalWidthsBetweenFirstAndSecondTravelWindow: NSLayoutConstraint!
    @IBOutlet private weak var indisefirstview: UIView!
    
    @IBOutlet private weak var insidesecondview: UIView!

    var didSave: ((ClubPoints) -> Void)?

    let infoImageView = UIImageView()
    var labelsCollectionView: UICollectionView!
    var clublabel = ""
    var clubIntervalValuesCollectionView: UICollectionView!
    var clubPointsValue = "0"
    var selectedIndexPath: IndexPath?
    var testArr = [1]
    var firstCheckedCheckBoxTag = 0
    var secondCheckedCheckBoxTag = 0
    var buttonSelectedString = ""
    var segmentSelectedString = Constant.MyClassConstants.segmentFirstString
    var dictionaryForSegmentCheckBox = NSMutableDictionary()
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
   
    }
    
    //***Action event for change value for clubpoint according to button pressed.***//
    
    @IBAction func firstbuttonpressed(_ sender: Any) {
        buttonSelectedString = Constant.MyClassConstants.segmentFirstString
        mapClubIntervalPoints(index: (sender as AnyObject).tag - 100)
        createClubsCollectionView()
        travelingDetailView.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        indisefirstview.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        secondView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        insidesecondview.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        startdatesecondbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        startmonthsecondbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        enddatesecondbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        endmonthsecondbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        
        startdatefirstbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        startmonthfirstbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        enddatefirstbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        endmonthfirstbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
    
    @IBAction func secondbuttonpressed(_ sender: Any) {
        
        buttonSelectedString = Constant.MyClassConstants.segmentSecondString
        insidesecondview.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        secondView.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        startdatesecondbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        startmonthsecondbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        enddatesecondbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        endmonthsecondbtn.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        travelingDetailView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        indisefirstview.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        startdatefirstbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        startmonthfirstbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        enddatefirstbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        endmonthfirstbtn.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0.7764705882, alpha: 1)
        
        mapClubIntervalPoints(index: (sender as AnyObject).tag - 100)
        
        createClubsCollectionView()
        
    }
    
    // MARK: - Function for done button click
    @IBAction func doneButtonClicked(_ sender: IUIKButton) {
        showHudAsync()
        guard let relinquishmentID = Constant.MyClassConstants.relinquishmentSelectedWeek.relinquishmentId,
            let indexPath = selectedIndexPath,
            let unitSize = processUnitSize(for: indexPath) else {
                hideHudAsync()
                return
        }

        let pointMatrixType = PointsMatrixReservation()
        pointMatrixType.clubPointsMatrixType = Constant.MyClassConstants.matrixType
        pointMatrixType.clubPointsMatrixDescription = Constant.MyClassConstants.matrixDescription
        pointMatrixType.clubPointsMatrixGridRowLabel = Constant.MyClassConstants.labelarray[0] as? String
        intervalPrint(Constant.MyClassConstants.fromdatearray[0])
        pointMatrixType.fromDate = Constant.MyClassConstants.fromdatearray[0] as? String
        pointMatrixType.toDate = Constant.MyClassConstants.todatearray[0] as? String
        pointMatrixType.clubPointsMatrixGridRowLabel = processClubPointMatrixRowLable(for: indexPath)
        _ = Constant.MyClassConstants.relinquishmentSelectedWeek.unit
        intervalPrint(Constant.MyClassConstants.matrixDataArray)
        intervalPrint(segmentSelectedString)
        
        dictionaryForSegmentCheckBox.value(forKey: segmentSelectedString)
        
           let invenUnit = InventoryUnit()
           invenUnit.unitSize = unitSize
           let clubPoints = clubPointsValue.replacingOccurrences(of: ",", with: "")
           invenUnit.clubPoints = Int(clubPoints) ?? 0
        
                pointMatrixType.unit = invenUnit
         ExchangeClient.updatePointsMatrixReservation(Session.sharedSession.userAccessToken, relinquishmentId: relinquishmentID, reservation: pointMatrixType, onSuccess: { [weak self] (response) in
            let clubPoints = ClubPoints()
            clubPoints.isPointsMatrix = true
            clubPoints.pointsSpent = invenUnit.clubPoints
            self?.hideHudAsync()
            self?.didSave?(clubPoints)
         }, onError: { [weak self] error in
            self?.hideHudAsync()
            self?.presentErrorAlert(UserFacingCommonError.handleError(error))
        })
        
    }

    private func processClubPointMatrixRowLable(for indexPath: IndexPath) -> String? {
        return Constant.MyClassConstants.labelarray[indexPath.row - 1] as? String
    }

    private func processUnitSize(for indexPath: IndexPath) -> String? {

        // This is not right..
        // This class needs to be rewritten...
        // This will break in other languages since its driven by UI and localization will change these values...
        let selectedSize = Constant.MyClassConstants.clubPointMatrixHeaderArray[indexPath.section] as? String

        switch selectedSize.unwrappedString {

        case "Studio":
            return UnitSize.STUDIO.rawValue

        case "1 Bedroom":
            return UnitSize.ONE_BEDROOM.rawValue

        case "2 Bedroom":
            return UnitSize.TWO_BEDROOM.rawValue

        case "3 Bedroom":
            return UnitSize.THREE_BEDROOM.rawValue

        case "4 Bedroom":
            return UnitSize.FOUR_BEDROOM.rawValue

        default:
            return nil
        }
    }

    // MARK: - Save Club points to database
    func saveSelectedClubPoints() {

    }
    
    //*** Change frame layout while change iPad in Portrait and Landscape mode.***//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if Constant.RunningDevice.deviceIdiom == .pad {
            frameChangeOnPortraitandLandscape()
        }
    }
    
    func frameChangeOnPortraitandLandscape() {
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            //lineBottomConstraint.constant = 80
            if clubIntervalValuesCollectionView != nil || labelsCollectionView != nil {
                clubIntervalValuesCollectionView.collectionViewLayout.invalidateLayout()
                labelsCollectionView.collectionViewLayout.invalidateLayout()
                createClubsCollectionView()
            }
        } else {
            if clubIntervalValuesCollectionView != nil || labelsCollectionView != nil {
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
        let contentWidth = Float(clubIntervalValuesCollectionView.contentSize.width  )
        var newPage = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if newPage > contentWidth / pageWidth {
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
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowNav"), style: .plain, target: self, action: #selector(ClubPointSelectionViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.title = Constant.ControllerTitles.clubpointselection
        travelingDetailView.layer.borderWidth = 2
        travelingDetailView.layer.borderColor = UIColor.lightGray.cgColor
        travelingDetailView.layer.cornerRadius = 5
        
        secondView.layer.borderWidth = 2
        secondView.layer.borderColor = UIColor.lightGray.cgColor
        secondView.layer.cornerRadius = 5
        
        if Constant.MyClassConstants.showSegment == false {
            standardFlexChartSegment.isHidden = true
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
        if Constant.RunningDevice.deviceIdiom == .pad {
            frameChangeOnPortraitandLandscape()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createClubsCollectionView()
    }
    
    //***** Function to create collection view to show club points. *****//
    func createClubsCollectionView() {
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
            let frame = CGRect(x: 80, y: 0, width: Int(UIScreen.main.bounds.width - 80), height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 150)
            clubIntervalValuesCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout1)
            clubIntervalValuesCollectionView?.register(UINib(nibName:Constant.customCellNibNames.clubPointsCell, bundle: nil), forCellWithReuseIdentifier:Constant.loginScreenReusableIdentifiers.cell)
            
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
            let frame = CGRect(x: 80, y: 0, width: Int(UIScreen.main.bounds.width - 80), height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 150)
            clubIntervalValuesCollectionView.frame = frame
            clubIntervalValuesCollectionView.reloadData()
        }
        
        if labelsCollectionView == nil {
            let frame = CGRect(x: 0, y: 0, width: 80, height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 50)
            labelsCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
            
            labelsCollectionView.register(UINib(nibName: Constant.customCellNibNames.clubPointsCell, bundle: nil), forCellWithReuseIdentifier: Constant.loginScreenReusableIdentifiers.cell)
            labelsCollectionView.register(UINib(nibName: Constant.customCellNibNames.headerCell, bundle: nil), forCellWithReuseIdentifier: Constant.reUsableIdentifiers.clubHeaderCell)
            labelsCollectionView.tag = 70
            labelsCollectionView.isScrollEnabled = false
            labelsCollectionView.delegate = self
            labelsCollectionView.dataSource = self
            labelsCollectionView.backgroundColor = UIColor.white
            if let cv = labelsCollectionView {
                clubPoinScrollVw.addSubview(cv)
            }
        } else {
            labelsCollectionView.frame = CGRect(x: 0, y: 0, width: 80, height: (Constant.MyClassConstants.clubIntervalDictionary.allKeys.count * 70) + 50)
            labelsCollectionView.reloadData()
        }
        
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Function to map club interval points
    
    func mapClubIntervalPoints(index: Int) {

        let dictKey = "\(Constant.MyClassConstants.fromdatearray[index]) - \(Constant.MyClassConstants.todatearray[index])"
        guard let rowsForClubInterval = Constant.MyClassConstants.pointMatrixDictionary.object(forKey: dictKey) as? [ClubPointsMatrixGridRow] else { return }
        
        Constant.MyClassConstants.clubIntervalDictionary.removeAllObjects()
        for clubIntervalRow in rowsForClubInterval {
            let clubPointsArray = NSMutableArray()
            Constant.MyClassConstants.clubPointMatrixHeaderArray.removeAllObjects()
            for units in clubIntervalRow.units {
                clubPointsArray.add(units.clubPoints)
                if let unitSize = units.unitSize {
                    let bedRoomString = Helper.getBedroomNumbers(bedroomType: unitSize)
                    Constant.MyClassConstants.clubPointMatrixHeaderArray.add(bedRoomString)
                }
                
            }
           
            if let label = clubIntervalRow.label {
                Constant.MyClassConstants.clubIntervalDictionary.setObject(clubPointsArray, forKey: label as NSCopying)
            }
        }
        
        createClubsCollectionView()
    }
    //Function to set date on buttons.
    
    func setDate() {
        
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        guard let fromStartDateString = Constant.MyClassConstants.todatearray[0] as? String else { return }
        guard let toStartDateString = Constant.MyClassConstants.fromdatearray[0] as? String else { return }
        guard let fromEndDateString = Constant.MyClassConstants.todatearray.lastObject as? String else { return }
        guard let toEndDateString = Constant.MyClassConstants.fromdatearray.lastObject as? String else { return }
        let fromStartComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: fromStartDateString, format: "yyyy-MM-dd"))
        let toStartComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: toStartDateString, format: "yyyy-MM-dd"))
        let fromEndComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: fromEndDateString, format: "yyyy-MM-dd"))
        let toEndComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: Helper.convertStringToDate(dateString: toEndDateString, format: Constant.MyClassConstants.dateFormat))
        
        startdatefirstbtn.text = String(describing: toStartComponents.day!)
        enddatefirstbtn.text = String(describing: fromStartComponents.day!)
        
        startdatesecondbtn.text = String(describing: toEndComponents.day!)
        enddatesecondbtn.text = String(describing: fromEndComponents.day!)
        
        if startdatefirstbtn.text!.characters.count == 1 {
            startdatefirstbtn.text = "0\( startdatefirstbtn.text!)"
        }
        if startdatesecondbtn.text!.characters.count == 1 {
            startdatesecondbtn.text = "0\( startdatesecondbtn.text!)"
        }
        if enddatefirstbtn.text!.characters.count == 1 {
            enddatefirstbtn.text = "0\( enddatefirstbtn.text!)"
        }
        if enddatesecondbtn.text!.characters.count == 1 {
            enddatesecondbtn.text = "0\( enddatesecondbtn.text!)"
        }
        startmonthfirstbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: toStartComponents.month!)) \(toStartComponents.year!)"
        endmonthfirstbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: fromStartComponents.month!)) \(fromStartComponents.year!)"
        startmonthsecondbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: toEndComponents.month!)) \(toEndComponents.year!)"
        endmonthsecondbtn.text = "\(Helper.getMonthnameFromInt(monthNumber: fromEndComponents.month!)) \(fromEndComponents.year!)"
        
        if startmonthfirstbtn.text == startmonthsecondbtn.text && endmonthfirstbtn.text == endmonthsecondbtn.text {
            equalWidthsBetweenFirstAndSecondTravelWindow.priority = 250
            secondView.isHidden = true
            firstTravelWindowWidth.constant = view.frame.width
        }
    }
    
    //Function for button toDate and FromDate click action
    @IBAction func loadClubData(_ sender: UIButton) {
        mapClubIntervalPoints(index: sender.tag - 100)
        let view1 = self.view.viewWithTag(100)
        let view2 = self.view.viewWithTag(101)
        if sender.tag == 100 {
            travelingDetailView.backgroundColor = IUIKColorPalette.primary1.color
            startdatefirstbtn.textColor = UIColor.white
            startmonthfirstbtn.textColor = UIColor.white
            
            for subView in (view2?.superview?.subviews)! {
                if subView.isKind(of: UILabel.self) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = UIColor.white
                }
            }
            
            for subView in (view1?.superview?.subviews)! {
                if subView.isKind(of: UILabel.self) {
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
                if subView.isKind(of: UILabel.self) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = UIColor.white
                }
            }
            
            for subView in (view2?.superview?.subviews)! {
                if subView.isKind(of: UILabel.self) {
                    let subViewLabel = subView as! UILabel
                    subViewLabel.textColor = IUIKColorPalette.primary1.color
                }
            }
            secondView.backgroundColor = IUIKColorPalette.primary1.color
        }
        createClubsCollectionView()
    }
    
    //Function to get check box status
    @IBAction func checkBoxClicked(_ sender: UIButton) {
        doneButton.isHidden = false
        let indexPath = IndexPath(item: sender.tag % 10, section: sender.tag / 10)
        selectedIndexPath = indexPath
        Constant.MyClassConstants.checkBoxTag = sender.tag % 10
        guard let collectionVwCell = clubIntervalValuesCollectionView.cellForItem(at: indexPath) else { return }

        for collectionItem in collectionVwCell.contentView.subviews {
            if collectionItem.isKind(of: UILabel.self) {
                let pointsLabel = collectionItem as? UILabel
                if let points = pointsLabel?.text {
                    clubPointsValue = points
                }
            } else if collectionItem.isKind(of: IUIKCheckbox.self) {
                let checkBox = collectionItem as! IUIKCheckbox
                if checkBox.checked {
                    checkBox.checked = false
                    doneButton.isHidden = true
                    if buttonSelectedString == "First" {
                        firstCheckedCheckBoxTag = 0
                    } else {
                        secondCheckedCheckBoxTag = 0
                    }
                } else {
                    checkBox.checked = true
                    doneButton.isHidden = false
                    if buttonSelectedString == "First" {
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
        if value {
            firstCheckedCheckBoxTag = 0
            secondCheckedCheckBoxTag = 0
        }
        let tempTagCheckBoxFirst = firstCheckedCheckBoxTag
        let tempTagCheckBoxSecond = secondCheckedCheckBoxTag
        let dictionaryForCheckBox = NSMutableDictionary()
        dictionaryForCheckBox.setValue( tempTagCheckBoxFirst, forKey: Constant.MyClassConstants.segmentFirstString)
        dictionaryForCheckBox.setValue( tempTagCheckBoxSecond, forKey: Constant.MyClassConstants.segmentSecondString)
        if segmentSelectedString == Constant.MyClassConstants.segmentFirstString {
            
        }
        dictionaryForSegmentCheckBox.setValue(dictionaryForCheckBox, forKey: segmentSelectedString)
        intervalPrint(dictionaryForSegmentCheckBox)
    }
    
    //Function called when segment control value change
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            segmentSelectedString = Constant.MyClassConstants.first
        } else if sender.selectedSegmentIndex == 1 {
            segmentSelectedString = Constant.MyClassConstants.segmentSecondString
        } else {
            segmentSelectedString = Constant.MyClassConstants.segmentThirdString
        }
        Constant.MyClassConstants.pointMatrixDictionary.removeAllObjects()
        Constant.MyClassConstants.pointMatrixDictionary.addEntries(from: Constant.MyClassConstants.matrixDataArray[sender.selectedSegmentIndex] as! [AnyHashable: Any])
        self.mapClubIntervalPoints(index: 0)
        createClubsCollectionView()
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

extension ClubPointSelectionViewController: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 70 {
            return 1
        } else {
            return Constant.MyClassConstants.clubPointMatrixHeaderArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.MyClassConstants.clubIntervalDictionary.allKeys.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 70 {
            if indexPath.row == 0 {
                guard let dateCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as? TdiCollectionViewCell else { return UICollectionViewCell() }
                dateCell.backgroundColor = IUIKColorPalette.titleBackdrop.color
                dateCell.contentLabel.textColor = UIColor.black
                
                dateCell.contentLabel.text = Constant.MyClassConstants.tdi
                dateCell.contentLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                if Constant.MyClassConstants.matrixDescription == Constant.MyClassConstants.matrixTypeColor {
                    dateCell.contentLabel.text = Constant.MyClassConstants.season.capitalized
                }
                dateCell.addSubview(infoImageView)
                dateCell.lineImage.isHidden = false
                
                return dateCell
            } else {
                guard let contentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TdiCollectionViewCell else { return UICollectionViewCell() }
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
                guard let dateCell = collectionView .dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TdiCollectionViewCell else { return UICollectionViewCell() }
                dateCell.contentLabel.font = UIFont(name: Constant.fontName.helveticaNeueMedium, size: 15)
                dateCell.horizontalLineImage.isHidden = true
                dateCell.contentLabel.textColor = UIColor.black
                dateCell.lineImage.isHidden = false
                if indexPath.section == Constant.MyClassConstants.clubPointMatrixHeaderArray.count {
                    dateCell.contentLabel.text = ""
                } else {
                    dateCell.contentLabel.text = String(describing: Constant.MyClassConstants.clubPointMatrixHeaderArray[indexPath.section])
                }
                dateCell.backgroundColor = IUIKColorPalette.titleBackdrop.color
                return dateCell
            } else {
                
                guard let contentCell = collectionView .dequeueReusableCell(withReuseIdentifier: "CheckCell", for: indexPath) as? TdiCollectionViewCell else { return UICollectionViewCell() }
                contentCell.contentLabel.textColor = UIColor.black
                contentCell.lineImage.isHidden = true
                let labelUnitArray = Constant.MyClassConstants.clubIntervalDictionary.value(forKey: Constant.MyClassConstants.labelarray[indexPath.row - 1] as! String)! as! NSMutableArray

                intervalPrint(labelUnitArray)
                if indexPath.section == Constant.MyClassConstants.clubPointMatrixHeaderArray.count {
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
                    let labelUnitNumber = labelUnitArray[indexPath.section] as? NSNumber ?? 0
                   contentCell.contentLabel.text = formatter.string(from: labelUnitNumber)
                    
                }
                contentCell.checkButton.tag = Int("\(indexPath.section )\(indexPath.row)")!
                contentCell.checkButton.addTarget(self, action: #selector(ClubPointSelectionViewController.checkBoxClicked(_:)), for: .touchUpInside)
                contentCell.checkBoxView.backgroundColor = UIColor.brown
                if dictionaryForSegmentCheckBox.count > 0 {
                    let checkBoxDictionary: NSDictionary = dictionaryForSegmentCheckBox.value(forKey: segmentSelectedString) as! NSDictionary
                    
                    intervalPrint(checkBoxDictionary)
                    if contentCell.checkButton.tag == checkBoxDictionary.value(forKey: "First") as! Int && buttonSelectedString == "First" {
                        contentCell.checkBoxView.checked = true
                    } else if contentCell.checkButton.tag == checkBoxDictionary.value(forKey: "Second") as! Int && buttonSelectedString == "Second" {
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
        if collectionView.tag == 70 {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.frame.size.width, height: 50.0)
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 70.0)
            }
        } else {
            if indexPath.row == 0 {
                if Constant.RunningDevice.deviceIdiom == .phone {
                    return CGSize(width: (collectionView.frame.size.width) / 2, height: 50.0)
                } else {
                    
                    if UIDevice.current.orientation.isLandscape {
                        return CGSize(width: (collectionView.frame.size.width) / 5, height: 50.0)
                    } else {
                        return CGSize(width: (collectionView.frame.size.width) / 5, height: 50.0)
                    }
                    
                }
            } else {
                if Constant.RunningDevice.deviceIdiom == .phone {
                    if indexPath.row == 0 {
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
