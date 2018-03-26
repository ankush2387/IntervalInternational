//
//  WeatherViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/8/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK
import IntervalUIKit

class WeatherViewController: UIViewController {
    
    var resortWeather: ResortWeather?
    let selectedButtonTextColor = UIColor.black
    var resortName: String?
    var countryCode: String?
    var presentedModally = true

    @IBOutlet weak var temperaureLowLabel: UILabel!
    @IBOutlet weak var temperatureHighLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var resortNameLabel: UILabel!
    @IBOutlet var highTempeartureBars: [VerticalProgressView]!
    @IBOutlet var LowTempeartureBars: [VerticalProgressView]!
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presentedModally {
            setupNavBarForModalPresentation()
        } else {
            setupDoneButtonView()
        }
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !presentedModally {
            navigationController?.navigationBar.isHidden = false
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    func setupDoneButtonView() {
        
        let doneButtonView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64))
        doneButtonView.backgroundColor = UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
        let doneButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 60, y: 7, width: 50, height: 50))
        doneButton.setTitleColor(IUIKColorPalette.primary1.color, for: .normal)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(WeatherViewController.doneButtonPressed(_:)), for: .touchUpInside)
        doneButtonView.addSubview(doneButton)
        
        self.view.addSubview(doneButtonView)
    }

    func doneButtonPressed(_ sender: UIButton) {
        Constant.MyClassConstants.showResortDetailsWhenClickedDone = true
        navigationController?.view.layer.add(Helper.topToBottomTransition(), forKey: nil)
        navigationController?.popViewController(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presentedModally {
            tabBarController?.tabBar.isHidden = true
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    func setupNavBarForModalPresentation() {
        //Nav-bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(WeatherViewController.menuBackButtonPressed(_:)))
        doneButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func setup() {
        if let resortName = self.resortName {
            resortNameLabel.text = "\(resortName)"
        }
        
        if let countryCode = self.countryCode {
            resortNameLabel.text?.append(", \(countryCode)")
        }
        weatherConditionLabel.text = resortWeather?.condition
        displayFarenheit()
    
    }
    
    func displayCelsius() {
        if let temp = resortWeather?.temperature?.celsius {
            temperatureLabel.text = "\(temp)°"
        }
        
        if let monthAvg = resortWeather?.monthlyAverage {
            var i = 0
            var n = 0
            var highAvg = 0
            var lowAvg = 0
            for month in monthAvg {
                let progress = month.high?.celsius
                highAvg += progress!
                highTempeartureBars[i].progress = Float(progress!) / 100
                i += 1
            }
        
            for month in monthAvg {
                let progress = month.low?.celsius
                lowAvg += progress!
                LowTempeartureBars[n].progress = Float(progress!) / 100
                n += 1
            }
            
            self.temperatureHighLabel.text = "\(Int(highAvg / 12))°"
            self.temperaureLowLabel.text = "\(Int(lowAvg / 12))°"
        }
    }
    
    func displayFarenheit() {
        if let temp = resortWeather?.temperature?.fahrenheit {
            temperatureLabel.text = "\(temp)°"
        }
        
        if let monthAvg = resortWeather?.monthlyAverage {
            var i = 0
            var n = 0
            var highAvg = 0
            var lowAvg = 0
            for month in monthAvg {
                let progress = month.high?.fahrenheit
                highAvg += progress!
                highTempeartureBars[i].progress = Float(progress!) / 100
                i += 1
            }
            
            for month in monthAvg {
                let progress = month.low?.fahrenheit
                lowAvg += progress!
                LowTempeartureBars[n].progress = Float(progress!) / 100
                n += 1
            }
            
            self.temperatureHighLabel.text = "\(Int(highAvg / 12))°"
            self.temperaureLowLabel.text = "\(Int(lowAvg / 12))°"
        }
    }
    
    @IBAction func didPressCelsiusButton(_ sender: Any) {
       fahrenheitButton.setTitleColor(UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1.0), for: .normal)
        celsiusButton.setTitleColor(selectedButtonTextColor, for: .normal)
        displayCelsius()
    }
    @IBAction func didPressFahrenheitButton(_ sender: Any) {
        fahrenheitButton.setTitleColor(selectedButtonTextColor, for: .normal)
        celsiusButton.setTitleColor(UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1.0), for: .normal)
        displayFarenheit()
    }
    
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        view.layer.add(Helper.topToBottomTransition(), forKey: nil)
        dismiss(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIViewController {
    func displayWeatherView(resortCode: String, resortCity: String, countryCode: String, presentModal: Bool, completionHandler: @escaping (_ response: Bool) -> Void) {
        DirectoryClient.getResortWeather(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { [weak self] response in
            guard let strongSelf = self else { return }
            let weatherResponse = response
            let storyboard = UIStoryboard(name: "MyUpcomingTripIphone", bundle: nil)
            guard let weatherDetailsNav = storyboard.instantiateViewController(withIdentifier: "weatherNav") as? UINavigationController else { return }
            guard let weatherVC = weatherDetailsNav.viewControllers.first as? WeatherViewController else { return }
            weatherVC.resortWeather = weatherResponse
            weatherVC.countryCode = countryCode
            weatherVC.resortName = resortCity
            
            if presentModal {
                strongSelf.present(weatherDetailsNav, animated: true, completion: nil)
            } else {
                strongSelf.navigationController?.view.layer.add(Helper.bottomToTopTransition(), forKey: nil); strongSelf.navigationController?.pushViewController(weatherVC, animated: false)
                weatherVC.presentedModally = false
            }
            
            completionHandler(true)
            
        }) {[unowned self] error in
            completionHandler(false)
            self.presentErrorAlert(UserFacingCommonError.handleError(error))
        }
    }
}
